import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/birth_place_suggestion_entity.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/profile_detail_dto.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/profile_summary_dto.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/update_profile_request_dto.dart';
import 'package:flutter_elitesync_module/mocks/mock_data/profile_mock.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource({required this.apiClient, required this.useMock});

  final ApiClient apiClient;
  final bool useMock;

  Future<ProfileSummaryDto> getSummary() async {
    if (useMock) return ProfileSummaryDto.fromJson(ProfileMock.summary);
    final result = await apiClient.get('/api/v1/profile/basic');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return ProfileSummaryDto.fromJson(result.data);
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<ProfileDetailDto> getDetail() async {
    if (useMock) return ProfileDetailDto.fromJson(ProfileMock.detail);
    final result = await apiClient.get('/api/v1/profile/basic');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return ProfileDetailDto.fromJson(result.data);
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

  Future<List<BirthPlaceSuggestionEntity>> searchBirthPlaces({
    required String query,
    String region = '全国',
  }) async {
    if (useMock) {
      return ProfileMock.birthPlaces
          .where((item) => item['label'].toString().contains(query.trim()))
          .map(
            (item) => BirthPlaceSuggestionEntity(
              label: item['label'].toString(),
              address: item['address'].toString(),
              city: item['city'].toString(),
              district: item['district'].toString(),
              lat: (item['lat'] as num).toDouble(),
              lng: (item['lng'] as num).toDouble(),
            ),
          )
          .toList();
    }

    final result = await apiClient.get(
      '/api/v1/geo/places',
      query: {
        'query': query,
        'region': region,
      },
    );
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final places = result.data['places'];
      if (places is List) {
        return places.whereType<Map>().map((item) {
          final map = item.map((key, value) => MapEntry(key.toString(), value));
          return BirthPlaceSuggestionEntity(
            label: (map['label'] ?? '').toString(),
            address: (map['address'] ?? '').toString(),
            city: (map['city'] ?? '').toString(),
            district: (map['district'] ?? '').toString(),
            lat: (map['lat'] as num?)?.toDouble() ?? 0,
            lng: (map['lng'] as num?)?.toDouble() ?? 0,
          );
        }).toList();
      }
      return const [];
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }
}
