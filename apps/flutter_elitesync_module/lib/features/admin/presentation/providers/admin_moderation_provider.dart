import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/admin/data/datasource/admin_moderation_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/admin/domain/entities/admin_moderation_entities.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class AdminModerationDashboardState {
  const AdminModerationDashboardState({
    required this.reports,
    required this.users,
    required this.verifyQueue,
    this.error,
    this.isLoading = false,
  });

  final List<AdminModerationReportEntity> reports;
  final List<AdminModerationUserEntity> users;
  final List<AdminModerationUserEntity> verifyQueue;
  final String? error;
  final bool isLoading;

  AdminModerationDashboardState copyWith({
    List<AdminModerationReportEntity>? reports,
    List<AdminModerationUserEntity>? users,
    List<AdminModerationUserEntity>? verifyQueue,
    String? error,
    bool clearError = false,
    bool? isLoading,
  }) {
    return AdminModerationDashboardState(
      reports: reports ?? this.reports,
      users: users ?? this.users,
      verifyQueue: verifyQueue ?? this.verifyQueue,
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final adminModerationRemoteDataSourceProvider =
    Provider<AdminModerationRemoteDataSource>((ref) {
      final env = ref.watch(appEnvProvider);
      return AdminModerationRemoteDataSource(
        apiClient: ref.watch(apiClientProvider),
        useMock: env.useMockData,
      useMockAdmin: env.useMockAdmin,
      );
    });

class AdminModerationNotifier
    extends AsyncNotifier<AdminModerationDashboardState> {
  @override
  Future<AdminModerationDashboardState> build() async {
    return _load();
  }

  Future<AdminModerationDashboardState> _load() async {
    final remote = ref.read(adminModerationRemoteDataSourceProvider);
    final results = await Future.wait([
      remote.fetchReports(),
      remote.fetchUsers(),
      remote.fetchVerifyQueue(),
    ]);
    return AdminModerationDashboardState(
      reports: results[0] as List<AdminModerationReportEntity>,
      users: results[1] as List<AdminModerationUserEntity>,
      verifyQueue: results[2] as List<AdminModerationUserEntity>,
    );
  }

  Future<void> refresh() async {
    final current =
        state.asData?.value ??
        const AdminModerationDashboardState(
          reports: [],
          users: [],
          verifyQueue: [],
        );
    state = AsyncData(current.copyWith(isLoading: true, clearError: true));
    try {
      final loaded = await _load();
      state = AsyncData(loaded);
    } catch (e) {
      state = AsyncData(
        current.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  Future<void> actionReport({
    required int reportId,
    required String action,
    String? note,
  }) async {
    await ref
        .read(adminModerationRemoteDataSourceProvider)
        .actionReport(reportId: reportId, action: action, note: note);
    ref.invalidateSelf();
  }

  Future<void> updateVerify({
    required int userId,
    required String status,
  }) async {
    await ref
        .read(adminModerationRemoteDataSourceProvider)
        .updateVerify(userId: userId, status: status);
    ref.invalidateSelf();
  }

  Future<void> disableUser({required int userId}) async {
    await ref
        .read(adminModerationRemoteDataSourceProvider)
        .disableUser(userId: userId);
    ref.invalidateSelf();
  }
}

final adminModerationProvider =
    AsyncNotifierProvider<
      AdminModerationNotifier,
      AdminModerationDashboardState
    >(AdminModerationNotifier.new);

final adminModerationReportDetailProvider =
    FutureProvider.family<AdminModerationReportEntity, int>((
      ref,
      reportId,
    ) async {
      return ref
          .read(adminModerationRemoteDataSourceProvider)
          .fetchReportDetail(reportId);
    });
