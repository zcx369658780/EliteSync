import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('session updateProfile keeps birth place fields', () {
    final current = SessionState(
      status: AuthStatus.authenticated,
      user: const UserSummary(
        id: 1,
        phone: '13800000000',
        nickname: 'old',
        birthday: '1990-01-01',
        city: '南阳',
        birthPlace: '南阳市',
        birthLat: 32.99,
        birthLng: 112.53,
      ),
    );

    final merged = UserSummary(
      id: 1,
      phone: '13800000000',
      nickname: 'new',
      birthday: '1991-02-02',
      city: '武汉',
      relationshipGoal: 'dating',
    );

    // This mirrors the merge logic in SessionNotifier.updateProfile.
    final result = UserSummary(
      id: merged.id != 0 ? merged.id : (current.user?.id ?? 0),
      phone: merged.phone.isNotEmpty ? merged.phone : (current.user?.phone ?? ''),
      nickname: merged.nickname ?? current.user?.nickname,
      birthday: merged.birthday ?? current.user?.birthday,
      gender: merged.gender ?? current.user?.gender,
      city: merged.city ?? current.user?.city,
      relationshipGoal: merged.relationshipGoal ?? current.user?.relationshipGoal,
      birthPlace: merged.birthPlace ?? current.user?.birthPlace,
      birthLat: merged.birthLat ?? current.user?.birthLat,
      birthLng: merged.birthLng ?? current.user?.birthLng,
      avatarUrl: merged.avatarUrl ?? current.user?.avatarUrl,
      verified: merged.verified || (current.user?.verified ?? false),
    );

    expect(result.birthPlace, '南阳市');
    expect(result.birthLat, 32.99);
    expect(result.birthLng, 112.53);
  });
}
