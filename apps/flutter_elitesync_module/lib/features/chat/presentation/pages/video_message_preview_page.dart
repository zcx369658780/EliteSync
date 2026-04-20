import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoMessagePreviewPage extends StatefulWidget {
  const VideoMessagePreviewPage({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  final String title;
  final String videoUrl;

  @override
  State<VideoMessagePreviewPage> createState() =>
      _VideoMessagePreviewPageState();
}

class _VideoMessagePreviewPageState extends State<VideoMessagePreviewPage> {
  VideoPlayerController? _controller;
  bool _loading = true;
  String? _error;

  bool _isLocalFileUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    return trimmed.startsWith('file://') ||
        File(trimmed).existsSync() ||
        (trimmed.startsWith('/') && File(trimmed).existsSync());
  }

  VideoPlayerController _buildController() {
    final url = widget.videoUrl.trim();
    if (_isLocalFileUrl(url)) {
      final path = url.startsWith('file://')
          ? Uri.parse(url).toFilePath()
          : url;
      return VideoPlayerController.file(File(path));
    }
    return VideoPlayerController.networkUrl(Uri.parse(url));
  }

  Future<void> _init() async {
    try {
      final controller = _buildController();
      await controller.initialize();
      controller.setLooping(false);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _loading
              ? const CircularProgressIndicator()
              : _error != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      '视频暂时无法播放',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error ?? 'unknown error',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : controller == null || !controller.value.isInitialized
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            VideoPlayer(controller),
                            Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: controller.value.isPlaying
                                    ? const SizedBox.shrink()
                                    : Material(
                                        color: Colors.black.withValues(
                                          alpha: 0.32,
                                        ),
                                        shape: const CircleBorder(),
                                        child: IconButton(
                                          onPressed: _togglePlay,
                                          iconSize: 48,
                                          color: Colors.white,
                                          icon: const Icon(
                                            Icons.play_arrow_rounded,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    controller.value.isPlaying ? '播放中' : '视频',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: _togglePlay,
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(controller.value.isPlaying ? '暂停' : '播放'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('关闭'),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
