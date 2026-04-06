import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/profile/data/mapper/profile_mapper.dart';
import 'package:flutter_elitesync_module/features/profile/data/repository/profile_repository_impl.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_repository.dart';
import 'package:flutter_elitesync_module/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_elitesync_module/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/edit_profile_ui_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_ui_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return ProfileRemoteDataSource(apiClient: ref.watch(apiClientProvider), useMock: env.useMockProfile);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(remote: ref.watch(profileRemoteDataSourceProvider), mapper: const ProfileMapper());
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) => GetProfileUseCase(ref.watch(profileRepositoryProvider)));
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) => UpdateProfileUseCase(ref.watch(profileRepositoryProvider)));

Map<String, dynamic> _summaryToJson(ProfileSummaryEntity summary) => {
  'nickname': summary.nickname,
  'name': summary.nickname,
  'birthday': summary.birthday,
  'birth_time': summary.birthTime,
  'birth_place': summary.birthPlace,
  'city': summary.city,
  'target': summary.target,
  'relationship_goal': summary.target,
  'verified': summary.verified,
  'realname_verified': summary.verified,
  'moderation_status': summary.moderationStatus,
  'moderation_note': summary.moderationNote,
  'completion': summary.completion,
  'tags': summary.tags,
};

Map<String, dynamic> _detailToJson(ProfileDetailEntity detail) => {
  'nickname': detail.nickname,
  'name': detail.nickname,
  'gender': detail.gender,
  'birthday': detail.birthday,
  'birth_time': detail.birthTime,
  'city': detail.city,
  'target': detail.target,
  'relationship_goal': detail.target,
  'birth_place': detail.birthPlace,
  'birth_lat': detail.birthLat,
  'birth_lng': detail.birthLng,
};

ProfileSummaryEntity _summaryFromDetail(ProfileDetailEntity detail, ProfileSummaryEntity? currentSummary) {
  final tags = <String>[
    if (detail.birthday.isNotEmpty) '生日已保存',
    if (detail.birthTime.isNotEmpty) '出生时间已保存',
    if (detail.gender.isNotEmpty) '性别已保存',
    if (detail.target.isNotEmpty) '婚恋目标已保存',
    if (detail.city.isNotEmpty) '城市已保存',
    if ((detail.birthPlace ?? '').isNotEmpty) '出生地已保存',
    '资料已同步',
  ];
  return ProfileSummaryEntity(
    nickname: detail.nickname.isNotEmpty ? detail.nickname : (currentSummary?.nickname ?? ''),
    birthday: detail.birthday.isNotEmpty ? detail.birthday : (currentSummary?.birthday ?? ''),
    birthTime: detail.birthTime.isNotEmpty ? detail.birthTime : (currentSummary?.birthTime ?? ''),
    birthPlace: detail.birthPlace ?? currentSummary?.birthPlace,
    city: detail.city.isNotEmpty ? detail.city : (currentSummary?.city ?? ''),
    target: detail.target.isNotEmpty ? detail.target : (currentSummary?.target ?? ''),
    verified: currentSummary?.verified ?? false,
    moderationStatus: currentSummary?.moderationStatus ?? 'normal',
    moderationNote: currentSummary?.moderationNote,
    completion: 0.8,
    tags: tags,
  );
}

ProfileSummaryEntity? _summaryFromJson(Map<String, dynamic>? json) {
  if (json == null || json.isEmpty) return null;
  return ProfileSummaryEntity(
    nickname: (json['nickname'] ?? json['name'] ?? '').toString(),
    birthday: (json['birthday'] ?? '').toString(),
    birthTime: (json['birth_time'] ?? json['birthTime'] ?? '').toString(),
    birthPlace: (json['birth_place'] ?? json['private_birth_place'] ?? '').toString().isEmpty
        ? null
        : (json['birth_place'] ?? json['private_birth_place'] ?? '').toString(),
    city: (json['city'] ?? '').toString(),
    target: (json['target'] ?? json['relationship_goal'] ?? '').toString(),
    verified: (json['verified'] as bool?) ?? (json['realname_verified'] as bool?) ?? false,
    moderationStatus: (json['moderation_status'] ?? 'normal').toString(),
    moderationNote: (json['moderation_note'] ?? '').toString().isEmpty
        ? null
        : (json['moderation_note'] ?? '').toString(),
    completion: (json['completion'] as num?)?.toDouble() ?? 0,
    tags: (json['tags'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
  );
}

ProfileDetailEntity? _detailFromJson(Map<String, dynamic>? json) {
  if (json == null || json.isEmpty) return null;
  return ProfileDetailEntity(
    nickname: (json['nickname'] ?? json['name'] ?? '').toString(),
    gender: (json['gender'] ?? '').toString(),
    birthday: (json['birthday'] ?? '').toString(),
    birthTime: (json['birth_time'] ?? json['birthTime'] ?? '').toString(),
    city: (json['city'] ?? '').toString(),
    target: (json['target'] ?? json['relationship_goal'] ?? '').toString(),
    birthPlace: (json['birth_place'] ?? json['private_birth_place'] ?? '').toString().isEmpty
        ? null
        : (json['birth_place'] ?? json['private_birth_place'] ?? '').toString(),
    birthLat: (json['birth_lat'] as num?)?.toDouble() ?? (json['private_birth_lat'] as num?)?.toDouble(),
    birthLng: (json['birth_lng'] as num?)?.toDouble() ?? (json['private_birth_lng'] as num?)?.toDouble(),
  );
}

ProfileSummaryEntity? _summaryFromSessionJson(Map<String, dynamic>? json) {
  if (json == null || json.isEmpty) return null;
  return ProfileSummaryEntity(
    nickname: (json['nickname'] ?? json['name'] ?? '').toString(),
    birthday: (json['birthday'] ?? '').toString(),
    birthTime: (json['birth_time'] ?? json['birthTime'] ?? '').toString(),
    birthPlace: (json['birth_place'] ?? json['private_birth_place'] ?? '').toString().isEmpty
        ? null
        : (json['birth_place'] ?? json['private_birth_place'] ?? '').toString(),
    city: (json['city'] ?? '').toString(),
    target: (json['relationship_goal'] ?? json['target'] ?? '').toString(),
    verified: (json['verified'] as bool?) ?? (json['realname_verified'] as bool?) ?? false,
    moderationStatus: (json['moderation_status'] ?? 'normal').toString(),
    moderationNote: (json['moderation_note'] ?? '').toString().isEmpty
        ? null
        : (json['moderation_note'] ?? '').toString(),
    completion: 0.5,
    tags: [
      if ((json['birthday'] ?? '').toString().isNotEmpty) '生日已保存',
      if ((json['birth_time'] ?? json['birthTime'] ?? '').toString().isNotEmpty) '出生时间已保存',
      if ((json['gender'] ?? '').toString().isNotEmpty) '性别已保存',
      if ((json['relationship_goal'] ?? json['target'] ?? '').toString().isNotEmpty) '婚恋目标已保存',
      '资料已同步',
    ],
  );
}

ProfileDetailEntity? _detailFromSessionJson(Map<String, dynamic>? json) {
  if (json == null || json.isEmpty) return null;
  return ProfileDetailEntity(
    nickname: (json['nickname'] ?? json['name'] ?? '').toString(),
    gender: (json['gender'] ?? '').toString(),
    birthday: (json['birthday'] ?? '').toString(),
    birthTime: (json['birth_time'] ?? json['birthTime'] ?? '').toString(),
    city: (json['city'] ?? '').toString(),
    target: (json['relationship_goal'] ?? json['target'] ?? '').toString(),
    birthPlace: (json['birth_place'] ?? json['private_birth_place'] ?? '').toString().isEmpty
        ? null
        : (json['birth_place'] ?? json['private_birth_place'] ?? '').toString(),
    birthLat: (json['birth_lat'] as num?)?.toDouble() ?? (json['private_birth_lat'] as num?)?.toDouble(),
    birthLng: (json['birth_lng'] as num?)?.toDouble() ?? (json['private_birth_lng'] as num?)?.toDouble(),
  );
}

ProfileDetailEntity? _detailFromSessionUser(Map<String, dynamic>? map) {
  if (map == null || map.isEmpty) return null;
  return ProfileDetailEntity(
    nickname: (map['nickname'] ?? map['name'] ?? '').toString(),
    gender: (map['gender'] ?? '').toString(),
    birthday: (map['birthday'] ?? '').toString(),
    birthTime: (map['birth_time'] ?? map['birthTime'] ?? '').toString(),
    city: (map['city'] ?? '').toString(),
    target: (map['relationship_goal'] ?? map['target'] ?? '').toString(),
    birthPlace: (map['birth_place'] ?? map['private_birth_place'] ?? '').toString().isEmpty
        ? null
        : (map['birth_place'] ?? map['private_birth_place'] ?? '').toString(),
    birthLat: (map['birth_lat'] as num?)?.toDouble() ?? (map['private_birth_lat'] as num?)?.toDouble(),
    birthLng: (map['birth_lng'] as num?)?.toDouble() ?? (map['private_birth_lng'] as num?)?.toDouble(),
  );
}

final profileProvider = FutureProvider<ProfileUiState>((ref) async {
  final local = ref.read(localStorageProvider);
  try {
    final summary = await ref.read(getProfileUseCaseProvider).call();
    await local.setJson(CacheKeys.profileSummarySnapshot, _summaryToJson(summary));
    return ProfileUiState(summary: summary);
  } catch (e) {
    final cached = await local.getJson(CacheKeys.profileSummarySnapshot);
    final summary = _summaryFromJson(cached) ?? _summaryFromSessionJson(await local.getJson(CacheKeys.lastKnownProfile));
    return ProfileUiState(summary: summary, error: e.toString());
  }
});

class EditProfileNotifier extends AsyncNotifier<EditProfileUiState> {
  @override
  Future<EditProfileUiState> build() async {
    final local = ref.read(localStorageProvider);
    try {
      final detail = await ref.read(profileRepositoryProvider).getDetail();
      await local.setJson(CacheKeys.profileDetailSnapshot, _detailToJson(detail));
      return EditProfileUiState(detail: detail);
    } catch (_) {
      final cached = await local.getJson(CacheKeys.profileDetailSnapshot);
      final sessionUser = ref.read(sessionProvider).maybeWhen(
            data: (state) => state.user,
            orElse: () => null,
          );
      return EditProfileUiState(
        detail:
            _detailFromJson(cached) ??
            _detailFromSessionJson(await local.getJson(CacheKeys.lastKnownProfile)) ??
            (sessionUser == null
                ? null
                : _detailFromSessionUser({
                    'nickname': sessionUser.nickname,
                    'name': sessionUser.nickname,
                    'gender': sessionUser.gender,
                    'birthday': sessionUser.birthday,
                    'birth_time': sessionUser.birthTime,
                    'city': sessionUser.city,
                    'relationship_goal': sessionUser.relationshipGoal,
                    'target': sessionUser.relationshipGoal,
                    'birth_place': sessionUser.birthPlace,
                    'birth_lat': sessionUser.birthLat,
                    'birth_lng': sessionUser.birthLng,
                  })),
      );
    }
  }

  Future<ProfileDetailEntity> save(ProfileDetailEntity detail) async {
    final current = state.asData?.value ?? const EditProfileUiState();
    state = AsyncData(EditProfileUiState(detail: detail, saving: true));
    try {
      await ref.read(updateProfileUseCaseProvider).call(detail);
      final persistedDetail = await ref.read(profileRepositoryProvider).getDetail().catchError((_) => detail);
      final local = ref.read(localStorageProvider);
      await local.setJson(CacheKeys.profileDetailSnapshot, _detailToJson(persistedDetail));
      final currentSummary = ref.read(profileProvider).asData?.value.summary;
      final summary = _summaryFromDetail(persistedDetail, currentSummary);
      await local.setJson(CacheKeys.profileSummarySnapshot, _summaryToJson(summary));
      final sessionState = ref.read(sessionProvider).maybeWhen(
            data: (s) => s,
            orElse: () => null,
          );
      if (sessionState?.user != null) {
        final user = sessionState!.user!;
        await ref.read(sessionProvider.notifier).updateProfile(
              UserSummary(
                id: user.id,
                phone: user.phone,
                nickname: persistedDetail.nickname,
                birthday: persistedDetail.birthday,
                birthTime: persistedDetail.birthTime,
                gender: persistedDetail.gender,
                city: persistedDetail.city,
                relationshipGoal: persistedDetail.target,
                birthPlace: persistedDetail.birthPlace,
                birthLat: persistedDetail.birthLat,
                birthLng: persistedDetail.birthLng,
                avatarUrl: user.avatarUrl,
                verified: user.verified,
              ),
            );
      }
      ref.invalidate(editProfileProvider);
      ref.invalidate(profileProvider);
      ref.invalidate(astroServerProfileProvider);
      ref.invalidate(astroNatalChartProvider);
      state = AsyncData(EditProfileUiState(detail: persistedDetail, saving: false));
      return persistedDetail;
    } catch (e) {
      state = AsyncData(current.copyWith(error: e.toString()));
      rethrow;
    }
  }
}

extension on EditProfileUiState {
  EditProfileUiState copyWith({ProfileDetailEntity? detail, bool? saving, String? error}) {
    return EditProfileUiState(detail: detail ?? this.detail, saving: saving ?? this.saving, error: error ?? this.error);
  }
}

final editProfileProvider =
    AsyncNotifierProvider.autoDispose<EditProfileNotifier, EditProfileUiState>(EditProfileNotifier.new);
