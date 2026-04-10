import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/admin/domain/entities/admin_moderation_entities.dart';

class AdminModerationRemoteDataSource {
  AdminModerationRemoteDataSource({
    required this.apiClient,
    required this.useMock,
    required this.useMockAdmin,
  });

  final ApiClient apiClient;
  final bool useMock;
  final bool useMockAdmin;

  static List<AdminModerationReportEntity> _mockReports() => [
    AdminModerationReportEntity(
      id: 101,
      status: 'pending',
      appealStatus: '',
      category: '骚扰',
      reasonCode: 'harassment',
      detail: '频繁发送无关消息，影响对话体验。',
      appealNote: '',
      adminNote: '',
      reporter: AdminModerationUserRef(
        id: 11,
        name: 'Mia',
        phone: '138****1101',
        disabled: false,
        moderationStatus: 'normal',
      ),
      targetUser: AdminModerationUserRef(
        id: 28,
        name: 'Leo',
        phone: '139****2208',
        disabled: false,
        moderationStatus: 'normal',
      ),
      resolver: AdminModerationUserRef(
        id: null,
        name: '',
        phone: '',
        disabled: false,
        moderationStatus: 'normal',
      ),
      appealedAt: null,
      resolvedAt: null,
    ),
    AdminModerationReportEntity(
      id: 102,
      status: 'resolved',
      appealStatus: 'none',
      category: '诈骗',
      reasonCode: 'fraud',
      detail: '要求转账后失联，已进入处理流程。',
      appealNote: '',
      adminNote: '已封禁并记录。',
      reporter: AdminModerationUserRef(
        id: 14,
        name: 'Nana',
        phone: '137****4414',
        disabled: false,
        moderationStatus: 'normal',
      ),
      targetUser: AdminModerationUserRef(
        id: 33,
        name: 'Kai',
        phone: '136****3303',
        disabled: true,
        moderationStatus: 'banned',
      ),
      resolver: AdminModerationUserRef(
        id: 1,
        name: 'Ops',
        phone: 'ops',
        disabled: false,
        moderationStatus: 'normal',
      ),
      appealedAt: null,
      resolvedAt: DateTime.now(),
    ),
  ];

  static List<AdminModerationUserEntity> _mockUsers() => [
    const AdminModerationUserEntity(
      id: 11,
      phone: '138****1101',
      name: 'Mia',
      disabled: false,
      moderationStatus: 'normal',
      verifyStatus: 'approved',
      accountType: 'normal',
      isSynthetic: false,
      isMatchEligible: true,
      isSquareVisible: true,
      excludeFromMetrics: false,
      syntheticBatch: '',
      syntheticBatchId: '',
      syntheticSeed: null,
      generationVersion: 'v1',
      accountStatus: 'active',
      visibilityScope: 'hidden',
      cleanupToken: '',
      bannedReason: '',
    ),
    const AdminModerationUserEntity(
      id: 28,
      phone: '139****2208',
      name: 'Leo',
      disabled: false,
      moderationStatus: 'normal',
      verifyStatus: 'pending',
      accountType: 'test',
      isSynthetic: false,
      isMatchEligible: true,
      isSquareVisible: true,
      excludeFromMetrics: true,
      syntheticBatch: '',
      syntheticBatchId: '',
      syntheticSeed: null,
      generationVersion: 'v1',
      accountStatus: 'active',
      visibilityScope: 'hidden',
      cleanupToken: '',
      bannedReason: '',
    ),
    const AdminModerationUserEntity(
      id: 33,
      phone: '136****3303',
      name: 'Kai',
      disabled: true,
      moderationStatus: 'banned',
      verifyStatus: 'rejected',
      accountType: 'test',
      isSynthetic: true,
      isMatchEligible: true,
      isSquareVisible: true,
      excludeFromMetrics: true,
      syntheticBatch: 'batch-20260406',
      syntheticBatchId: 'batch-20260406',
      syntheticSeed: 20260406,
      generationVersion: 'v32',
      accountStatus: 'disabled',
      visibilityScope: 'hidden',
      cleanupToken: 'cleanup-kai-20260406',
      bannedReason: '违规内容',
    ),
    const AdminModerationUserEntity(
      id: 44,
      phone: '135****4404',
      name: 'Ada',
      disabled: false,
      moderationStatus: 'normal',
      verifyStatus: 'pending',
      accountType: 'test',
      isSynthetic: true,
      isMatchEligible: true,
      isSquareVisible: true,
      excludeFromMetrics: true,
      syntheticBatch: 'batch-20260406',
      syntheticBatchId: 'batch-20260406',
      syntheticSeed: 20260407,
      generationVersion: 'v32',
      accountStatus: 'active',
      visibilityScope: 'square',
      cleanupToken: 'cleanup-ada-20260406',
      bannedReason: '',
    ),
  ];

  Future<List<AdminModerationReportEntity>> fetchReports() async {
    if (useMock || useMockAdmin) return _mockReports();
    final result = await apiClient.get('/api/v1/admin/reports');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final items = (result.data['items'] as List<dynamic>? ?? const []);
      return items
          .whereType<Map<String, dynamic>>()
          .map(AdminModerationReportEntity.fromJson)
          .toList();
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<AdminModerationReportEntity> fetchReportDetail(int reportId) async {
    if (useMock || useMockAdmin) {
      return _mockReports().firstWhere(
        (item) => item.id == reportId,
        orElse: () => _mockReports().first,
      );
    }
    final result = await apiClient.get('/api/v1/admin/reports/$reportId');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return AdminModerationReportEntity.fromJson(result.data);
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<List<AdminModerationUserEntity>> fetchUsers() async {
    if (useMock || useMockAdmin) return _mockUsers();
    final result = await apiClient.get('/api/v1/admin/users');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final items = (result.data['items'] as List<dynamic>? ?? const []);
      return items
          .whereType<Map<String, dynamic>>()
          .map(AdminModerationUserEntity.fromJson)
          .toList();
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<List<AdminModerationUserEntity>> fetchVerifyQueue() async {
    if (useMock || useMockAdmin) {
      return _mockUsers()
          .where((item) => item.verifyStatus == 'pending')
          .toList();
    }
    final result = await apiClient.get('/api/v1/admin/verify-queue');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final items = (result.data['items'] as List<dynamic>? ?? const []);
      return items
          .whereType<Map<String, dynamic>>()
          .map(AdminModerationUserEntity.fromJson)
          .toList();
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<void> actionReport({
    required int reportId,
    required String action,
    String? note,
  }) async {
    if (useMock || useMockAdmin) return;
    final result = await apiClient.post(
      '/api/v1/admin/reports/$reportId/action',
      body: {
        'action': action,
        if ((note ?? '').trim().isNotEmpty) 'note': note!.trim(),
      },
    );
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }

  Future<void> updateVerify({
    required int userId,
    required String status,
  }) async {
    if (useMock || useMockAdmin) return;
    final result = await apiClient.post(
      '/api/v1/admin/verify/$userId',
      body: {'status': status},
    );
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }

  Future<void> disableUser({required int userId}) async {
    if (useMock || useMockAdmin) return;
    final result = await apiClient.post('/api/v1/admin/users/$userId/disable');
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }
}
