import 'package:flutter_elitesync/core/network/api_client.dart';
import 'package:flutter_elitesync/core/network/network_result.dart';
import 'package:flutter_elitesync/features/profile/data/dto/profile_detail_dto.dart';
import 'package:flutter_elitesync/features/profile/data/dto/profile_summary_dto.dart';
import 'package:flutter_elitesync/features/profile/data/dto/update_profile_request_dto.dart';
import 'package:flutter_elitesync/mocks/mock_data/profile_mock.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource({required this.apiClient, required this.useMock});

  final ApiClient apiClient;
  final bool useMock;

  Future<ProfileSummaryDto> getSummary() async {
    if (useMock) return ProfileSummaryDto.fromJson(ProfileMock.summary);
    final result = await apiClient.get('/api/v1/profile/basic');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return ProfileSummaryDto.fromJson(result.data['data'] as Map<String, dynamic>? ?? {});
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<ProfileDetailDto> getDetail() async {
    if (useMock) return ProfileDetailDto.fromJson(ProfileMock.detail);
    final result = await apiClient.get('/api/v1/profile/basic');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return ProfileDetailDto.fromJson(result.data['data'] as Map<String, dynamic>? ?? {});
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<void> update(UpdateProfileRequestDto dto) async {
    if (useMock) return;
    final result = await apiClient.post('/api/v1/profile/basic', body: dto.toJson());
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }
}
