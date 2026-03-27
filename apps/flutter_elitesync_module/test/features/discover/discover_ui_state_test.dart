import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/discover/presentation/state/discover_ui_state.dart';

void main() {
  group('DiscoverUiState.copyWith', () {
    test('keeps nextCursor when not provided', () {
      const state = DiscoverUiState(
        nextCursor: '12',
        hasMore: true,
      );

      final next = state.copyWith(isLoading: true);
      expect(next.nextCursor, '12');
      expect(next.hasMore, true);
      expect(next.isLoading, true);
    });

    test('can explicitly clear nextCursor', () {
      const state = DiscoverUiState(
        nextCursor: '24',
        hasMore: true,
      );

      final next = state.copyWith(nextCursor: null, hasMore: false);
      expect(next.nextCursor, isNull);
      expect(next.hasMore, false);
    });

    test('clearError removes previous error', () {
      const state = DiscoverUiState(error: 'network failed');
      final next = state.copyWith(clearError: true);
      expect(next.error, isNull);
    });
  });
}

