import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/app/router/rtc_invite_coordinator.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class SessionState {
  const SessionState({
    required this.status,
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  final AuthStatus status;
  final UserSummary? user;
  final String? accessToken;
  final String? refreshToken;

  bool get isLoggedIn => status == AuthStatus.authenticated;

  SessionState copyWith({
    AuthStatus? status,
    UserSummary? user,
    String? accessToken,
    String? refreshToken,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  static const unknown = SessionState(status: AuthStatus.unknown);
}

class SessionNotifier extends AsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    // ignore: avoid_print
    print('SESSION_PROVIDER_RTC_WATCHER_ATTACHED');
    startRtcInviteWatcher(ref);
    final secure = ref.read(secureStorageProvider);
    final local = ref.read(localStorageProvider);

    final accessToken = await secure.read(CacheKeys.accessToken);
    final refreshToken = await secure.read(CacheKeys.refreshToken);
    final profileJson = await local.getJson(CacheKeys.lastKnownProfile);

    assert(() {
      if (accessToken != null && accessToken.isNotEmpty) {
        // Temporary debug aid for emulator-side matching setup.
        // Removed from release builds by Dart asserts.
        // ignore: avoid_print
        print(
          'SESSION_BOOT_TOKEN token=$accessToken phone=${profileJson == null ? '' : (profileJson['phone'] ?? '')}',
        );
      }
      return true;
    }());

    if (accessToken == null || accessToken.isEmpty) {
      return const SessionState(status: AuthStatus.unauthenticated);
    }

    final user = profileJson == null ? null : UserSummary.fromJson(profileJson);
    return SessionState(
      status: AuthStatus.authenticated,
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> setAuthenticated({
    required String accessToken,
    String? refreshToken,
    UserSummary? user,
  }) async {
    // ignore: avoid_print
    print(
      'SESSION_SET_AUTH token=${accessToken.isNotEmpty} user=${user?.phone ?? ''}',
    );
    final secure = ref.read(secureStorageProvider);
    final local = ref.read(localStorageProvider);

    await secure.write(CacheKeys.accessToken, accessToken);
    if (refreshToken != null) {
      await secure.write(CacheKeys.refreshToken, refreshToken);
    }
    if (user != null) {
      await local.setJson(CacheKeys.lastKnownProfile, user.toJson());
    }

    state = AsyncData(
      SessionState(
        status: AuthStatus.authenticated,
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    );
  }

  Future<void> updateProfile(UserSummary user) async {
    final local = ref.read(localStorageProvider);
    final current = state.maybeWhen(data: (s) => s, orElse: () => null);
    final merged = UserSummary(
      id: user.id != 0 ? user.id : (current?.user?.id ?? 0),
      phone: user.phone.isNotEmpty ? user.phone : (current?.user?.phone ?? ''),
      nickname: user.nickname ?? current?.user?.nickname,
      birthday: user.birthday ?? current?.user?.birthday,
      birthTime: user.birthTime ?? current?.user?.birthTime,
      gender: user.gender ?? current?.user?.gender,
      city: user.city ?? current?.user?.city,
      relationshipGoal:
          user.relationshipGoal ?? current?.user?.relationshipGoal,
      birthPlace: user.birthPlace ?? current?.user?.birthPlace,
      birthLat: user.birthLat ?? current?.user?.birthLat,
      birthLng: user.birthLng ?? current?.user?.birthLng,
      avatarUrl: user.avatarUrl ?? current?.user?.avatarUrl,
      verified: user.verified || (current?.user?.verified ?? false),
      moderationStatus: user.moderationStatus.isNotEmpty
          ? user.moderationStatus
          : (current?.user?.moderationStatus ?? 'normal'),
      moderationNote: user.moderationNote ?? current?.user?.moderationNote,
    );

    await local.setJson(CacheKeys.lastKnownProfile, merged.toJson());
    state = AsyncData(
      (current ?? const SessionState(status: AuthStatus.authenticated))
          .copyWith(user: merged),
    );
  }

  Future<void> setUnauthenticated() async {
    final secure = ref.read(secureStorageProvider);
    await secure.delete(CacheKeys.accessToken);
    await secure.delete(CacheKeys.refreshToken);

    state = const AsyncData(SessionState(status: AuthStatus.unauthenticated));
  }
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);

final authStatusProvider = Provider<AuthStatus>((ref) {
  final session = ref.watch(sessionProvider);
  return session.maybeWhen(
    data: (state) => state.status,
    orElse: () => AuthStatus.unknown,
  );
});
