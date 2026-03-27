import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/profile/data/mapper/profile_mapper.dart';
import 'package:flutter_elitesync_module/features/profile/data/repository/profile_repository_impl.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_repository.dart';
import 'package:flutter_elitesync_module/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_elitesync_module/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/edit_profile_ui_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_ui_state.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return ProfileRemoteDataSource(apiClient: ref.watch(apiClientProvider), useMock: env.useMockProfile);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(remote: ref.watch(profileRemoteDataSourceProvider), mapper: const ProfileMapper());
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) => GetProfileUseCase(ref.watch(profileRepositoryProvider)));
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) => UpdateProfileUseCase(ref.watch(profileRepositoryProvider)));

final profileProvider = FutureProvider<ProfileUiState>((ref) async {
  try {
    final summary = await ref.read(getProfileUseCaseProvider).call();
    return ProfileUiState(summary: summary);
  } catch (e) {
    return ProfileUiState(error: e.toString());
  }
});

class EditProfileNotifier extends AsyncNotifier<EditProfileUiState> {
  @override
  Future<EditProfileUiState> build() async {
    final detail = await ref.read(profileRepositoryProvider).getDetail();
    return EditProfileUiState(detail: detail);
  }

  Future<void> save(ProfileDetailEntity detail) async {
    final current = state.asData?.value ?? const EditProfileUiState();
    state = AsyncData(EditProfileUiState(detail: detail, saving: true));
    try {
      await ref.read(updateProfileUseCaseProvider).call(detail);
      state = AsyncData(EditProfileUiState(detail: detail, saving: false));
    } catch (e) {
      state = AsyncData(current.copyWith(error: e.toString()));
    }
  }
}

extension on EditProfileUiState {
  EditProfileUiState copyWith({ProfileDetailEntity? detail, bool? saving, String? error}) {
    return EditProfileUiState(detail: detail ?? this.detail, saving: saving ?? this.saving, error: error ?? this.error);
  }
}

final editProfileProvider = AsyncNotifierProvider<EditProfileNotifier, EditProfileUiState>(EditProfileNotifier.new);
