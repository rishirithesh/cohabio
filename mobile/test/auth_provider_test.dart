import 'package:flutter_test/flutter_test.dart';
import 'package:cohabio/core/providers/auth_provider.dart';

void main() {
  group('AuthState Unit Tests', () {
    test('Initial AuthState is unauthenticated', () {
      final state = AuthState();
      expect(state.isAuthenticated, false);
      expect(state.userId, null);
      expect(state.role, null);
      expect(state.isLoading, false);
    });

    test('AuthState copyWith updates authenticated status correctly', () {
      final state = AuthState();
      final updated = state.copyWith(
        isAuthenticated: true,
        userId: 'user_123_abc',
        role: 'student',
      );

      expect(updated.isAuthenticated, true);
      expect(updated.userId, 'user_123_abc');
      expect(updated.role, 'student');
    });
  });
}
