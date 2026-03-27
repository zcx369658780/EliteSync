import 'package:flutter_elitesync/core/network/api_client.dart';
import 'package:flutter_elitesync/core/network/network_result.dart';
import 'package:flutter_elitesync/features/verification/data/dto/submit_verification_request_dto.dart';
import 'package:flutter_elitesync/features/verification/data/dto/verification_status_dto.dart';
import 'package:flutter_elitesync/shared/enums/verification_status.dart';

class VerificationRemoteDataSource {
  const VerificationRemoteDataSource({
    required this.apiClient,
    required this.useMock,
  });

  final ApiClient apiClient;
  final bool useMock;

  Future<VerificationStatusDto> fetchStatus() async {
    if (useMock) {
      return const VerificationStatusDto(
        status: VerificationStatus.unverified,
        title: '实名认证',
        description: '认证通过后可提升匹配可信度',
      );
    }

    final result = await apiClient.get('/api/v1/verification/status');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return VerificationStatusDto.fromJson(result.data['data'] as Map<String, dynamic>? ?? {});
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<void> submit(SubmitVerificationRequestDto dto) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return;
    }

    final result = await apiClient.post('/api/v1/verification/submit', body: dto.toJson());
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }
}
