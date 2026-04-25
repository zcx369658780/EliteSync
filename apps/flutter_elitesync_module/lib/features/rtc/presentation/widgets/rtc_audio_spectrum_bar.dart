import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:livekit_client/livekit_client.dart';

class RtcAudioSpectrumBar extends StatefulWidget {
  const RtcAudioSpectrumBar({super.key, required this.audioTrack});

  final AudioTrack? audioTrack;

  @override
  State<RtcAudioSpectrumBar> createState() => _RtcAudioSpectrumBarState();
}

class _RtcAudioSpectrumBarState extends State<RtcAudioSpectrumBar> {
  static const int _barCount = 7;
  static const double _decay = 0.82;
  static const double _silentThreshold = 0.0001;

  CancelListenFunc? _cancelRenderer;
  List<double> _levels = List<double>.filled(_barCount, 0.0);
  String _status = '等待远端音轨…';
  int _frameCount = 0;
  DateTime? _lastFrameAt;
  String? _boundTrackId;
  double _lastPeak = 0.0;

  String? _safeTrackId(AudioTrack? track) {
    if (track == null) return null;
    try {
      return track.mediaStreamTrack.id;
    } catch (error) {
      debugPrint(
        'RTC_LIVEKIT_AUDIO_RENDER_TRACK_ID_FAIL '
        'device=${defaultTargetPlatform.name} '
        'error=$error',
      );
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    unawaited(_bindTrack(widget.audioTrack));
  }

  @override
  void didUpdateWidget(covariant RtcAudioSpectrumBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldId = _safeTrackId(oldWidget.audioTrack);
    final nextId = _safeTrackId(widget.audioTrack);
    if (oldId != nextId) {
      unawaited(_bindTrack(widget.audioTrack));
    }
  }

  @override
  void dispose() {
    unawaited(_unbindTrack());
    super.dispose();
  }

  Future<void> _bindTrack(AudioTrack? track) async {
    await _unbindTrack();
    if (!mounted) return;

    if (track == null) {
      setState(() {
        _boundTrackId = null;
        _levels = List<double>.filled(_barCount, 0.0);
        _status = '等待远端音轨…';
        _frameCount = 0;
        _lastFrameAt = null;
        _lastPeak = 0.0;
      });
      return;
    }

    final trackId = _safeTrackId(track);
    if (trackId == null) {
      if (!mounted) return;
      setState(() {
        _boundTrackId = null;
        _levels = List<double>.filled(_barCount, 0.0);
        _status = '远端音轨已释放';
        _frameCount = 0;
        _lastFrameAt = null;
        _lastPeak = 0.0;
      });
      return;
    }
    setState(() {
      _boundTrackId = trackId;
      _levels = List<double>.filled(_barCount, 0.0);
      _status = '远端音轨已接入';
      _frameCount = 0;
      _lastFrameAt = null;
      _lastPeak = 0.0;
    });

    debugPrint(
      'RTC_LIVEKIT_AUDIO_RENDER_BIND trackId=$trackId '
      'kind=${track.kind} '
      'device=${defaultTargetPlatform.name}',
    );

    try {
      _cancelRenderer = track.addAudioRenderer(
        onFrame: _onAudioFrame,
        options: const AudioRendererOptions(
          sampleRate: 24000,
          channels: 1,
          format: AudioFormat.Int16,
        ),
      );
    } catch (error) {
      debugPrint(
        'RTC_LIVEKIT_AUDIO_RENDER_BIND_FAIL trackId=$trackId '
        'device=${defaultTargetPlatform.name} '
        'error=$error',
      );
      if (!mounted) return;
      setState(() {
        _status = '音轨订阅失败';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _status = '远端音轨监听中';
    });
  }

  Future<void> _unbindTrack() async {
    final cancel = _cancelRenderer;
    _cancelRenderer = null;
    if (cancel != null) {
      try {
        await cancel();
      } catch (error) {
        debugPrint(
          'RTC_LIVEKIT_AUDIO_RENDER_UNBIND_FAIL '
          'trackId=${_boundTrackId ?? "none"} '
          'device=${defaultTargetPlatform.name} '
          'error=$error',
        );
      }
    }
  }

  void _onAudioFrame(AudioFrame frame) {
    final sampleCount = frame.data.lengthInBytes ~/ 2;
    if (sampleCount <= 0) {
      return;
    }

    final samples = frame.data.buffer.asInt16List(
      frame.data.offsetInBytes,
      sampleCount,
    );

    final nextLevels = List<double>.filled(_barCount, 0.0);
    final chunkSize = math.max(1, (samples.length / _barCount).floor());
    for (var i = 0; i < _barCount; i++) {
      final start = i * chunkSize;
      final end = i == _barCount - 1
          ? samples.length
          : math.min(samples.length, (i + 1) * chunkSize);
      if (start >= end) {
        break;
      }

      var total = 0.0;
      for (var j = start; j < end; j++) {
        total += samples[j].abs().toDouble();
      }
      final average = total / (end - start) / 32768.0;
      nextLevels[i] = math.min(1.0, math.sqrt(average));
    }

    final frameAbsAverage = samples.isEmpty
        ? 0.0
        : samples.fold<double>(
            0.0,
            (sum, sample) => sum + sample.abs().toDouble(),
          ) /
            samples.length /
            32768.0;
    final framePeak = samples.isEmpty
        ? 0.0
        : samples
            .map((sample) => sample.abs().toDouble())
            .fold<double>(0.0, math.max) /
            32768.0;

    if (!mounted) return;
    setState(() {
      _frameCount += 1;
      _lastFrameAt = DateTime.now();
      _lastPeak = framePeak;
      _status = framePeak <= _silentThreshold
          ? '远端音轨已接入但无声'
          : '远端音轨输入中';
      _levels = List<double>.generate(
        _barCount,
        (i) => math.max(nextLevels[i], _levels[i] * _decay),
      );
    });

    if (_frameCount == 1 || _frameCount % 25 == 0) {
      debugPrint(
        'RTC_LIVEKIT_AUDIO_FRAME '
        'trackId=${_boundTrackId ?? "none"} '
        'device=${defaultTargetPlatform.name} '
        'sampleRate=${frame.sampleRate} '
        'channels=${frame.channels} '
        'bytes=${frame.data.lengthInBytes} '
        'absAvg=${frameAbsAverage.toStringAsFixed(4)} '
        'peak=${framePeak.toStringAsFixed(4)} '
        'frames=$_frameCount',
      );
    }
  }

  String _lastFrameLabel() {
    final lastFrameAt = _lastFrameAt;
    if (lastFrameAt == null) {
      return '暂无音频帧';
    }
    final delta = DateTime.now().difference(lastFrameAt);
    return '最近帧 ${delta.inMilliseconds}ms 前';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final track = widget.audioTrack;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(t.spacing.md),
          decoration: BoxDecoration(
            color: t.secondarySurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.browseBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    track == null
                        ? Icons.graphic_eq_outlined
                        : Icons.graphic_eq,
                    color: track == null ? t.textTertiary : t.brandPrimary,
                    size: 20,
                  ),
                  SizedBox(width: t.spacing.xs),
                  Expanded(
                    child: Text(
                      _frameCount > 0 && _lastPeak <= _silentThreshold
                          ? '远端音轨已接入但无声'
                          : _status,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    _lastFrameLabel(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: t.textSecondary),
                  ),
                ],
              ),
              SizedBox(height: t.spacing.sm),
              SizedBox(
                height: 40,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_barCount, (index) {
                    final level = _levels[index].clamp(0.0, 1.0);
                    final height = 6.0 + (level * 34.0);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOutCubic,
                      width: 12,
                      height: height,
                      decoration: BoxDecoration(
                        color: track == null
                            ? t.textTertiary.withValues(alpha: 0.28)
                            : t.brandPrimary.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: t.spacing.xs),
        Text(
          track == null
              ? '当前还没有拿到远端音轨。若对端已在说话，请优先看 Room.connect / subscribe 日志。'
              : _frameCount == 0
                  ? 'track=${track.mediaStreamTrack.id} / 仍未收到音频帧。'
                  : _lastPeak <= _silentThreshold
                      ? 'track=${track.mediaStreamTrack.id} / 帧已到达但当前仍是静音信号。'
                      : 'track=${track.mediaStreamTrack.id} / frames=$_frameCount / 绑定后会持续刷新波形。',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.textSecondary, height: 1.35),
        ),
      ],
    );
  }
}
