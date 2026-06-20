import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/data/models/user_profile.dart';
import 'package:unorive/data/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

/// Provider for the [LocalStorageService]. Should be overridden in [ProviderScope]
/// after initialization.
@riverpod
LocalStorageService localStorageService(Ref ref) {
  throw UnimplementedError('LocalStorageService has not been initialized');
}

/// Provider exposing the [AuthRepository] implementation.
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl();
}

/// Stream provider tracking changes in user authentication state.
@riverpod
Stream<UserProfile?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// Notifier managing and persisting the user onboarding completion status.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  bool build() {
    final storage = ref.read(localStorageServiceProvider);
    return storage.getHasCompletedOnboarding();
  }

  /// Mark onboarding as completed and persist to storage.
  Future<void> completeOnboarding() async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setHasCompletedOnboarding(completed: true);
    state = true;
  }

  /// Reset onboarding status (for testing or debugging).
  Future<void> resetOnboarding() async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setHasCompletedOnboarding(completed: false);
    state = false;
  }
}

/// Notifier managing and persisting guest mode activation.
@riverpod
class GuestModeController extends _$GuestModeController {
  @override
  bool build() {
    final storage = ref.read(localStorageServiceProvider);
    return storage.getIsGuestMode();
  }

  /// Toggle guest mode status.
  Future<void> setGuestMode({required bool active}) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setIsGuestMode(isGuest: active);
    state = active;
  }
}
