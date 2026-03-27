import 'package:flutter_elitesync/core/network/api_client.dart';
import 'package:flutter_elitesync/core/network/network_result.dart';
import 'package:flutter_elitesync/mocks/mock_data/match_mock.dart';
import 'package:flutter_elitesync/features/match/data/dto/intention_request_dto.dart';
import 'package:flutter_elitesync/features/match/data/dto/match_countdown_dto.dart';
import 'package:flutter_elitesync/features/match/data/dto/match_detail_dto.dart';
import 'package:flutter_elitesync/features/match/data/dto/match_result_dto.dart';

class MatchRemoteDataSource {
  const MatchRemoteDataSource({required this.apiClient, required this.useMock});

  final ApiClient apiClient;
  final bool useMock;

  Future<MatchCountdownDto> getCountdown() async {
    if (useMock) return MatchCountdownDto.fromJson(MatchMock.countdown);
    final result = await apiClient.get('/api/v1/match/countdown');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return MatchCountdownDto.fromJson(result.data['data'] as Map<String, dynamic>? ?? {});
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<MatchResultDto> getResult() async {
    if (useMock) return MatchResultDto.fromJson(MatchMock.resultHappy);
    final result = await apiClient.get('/api/v1/match/current');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return MatchResultDto.fromJson(result.data['data'] as Map<String, dynamic>? ?? {});
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<MatchDetailDto> getDetail() async {
    if (useMock) {
      return const MatchDetailDto(
        reasons: ['沟通风格互补', '关系目标一致', '同城活动便利'],
        weights: {'八字': 50, '属相': 30, '星座': 10, '星盘': 10},
      );
    }
    final result = await apiClient.get('/api/v1/match/detail');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return MatchDetailDto.fromJson(result.data['data'] as Map<String, dynamic>? ?? {});
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<void> submitIntention(String action) async {
    if (useMock) return;
    final result = await apiClient.post('/api/v1/match/intention', body: IntentionRequestDto(action: action).toJson());
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }
}
