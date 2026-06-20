import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/data/models/user_profile.dart';
import 'package:unorive/data/repositories/auth_repository.dart';
import 'package:unorive/features/auth/auth_provider.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockLocalStorageService mockStorage;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockStorage = MockLocalStorageService();
    mockAuthRepo = MockAuthRepository();

    // Default mock behaviors
    when(() => mockStorage.getHasCompletedOnboarding()).thenReturn(false);
    when(() => mockStorage.getIsGuestMode()).thenReturn(false);
    when(() => mockStorage.setHasCompletedOnboarding(completed: any(named: 'completed')))
        .thenAnswer((_) async {});
    when(() => mockStorage.setIsGuestMode(isGuest: any(named: 'isGuest')))
        .thenAnswer((_) async {});
  });

  group('OnboardingController Tests', () {
    test('initial state matches storage value', () {
      when(() => mockStorage.getHasCompletedOnboarding()).thenReturn(true);

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );

      final onboardingState = container.read(onboardingControllerProvider);
      expect(onboardingState, isTrue);
    });

    test('completeOnboarding persists to storage and updates state', () async {
      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );

      expect(container.read(onboardingControllerProvider), isFalse);

      await container.read(onboardingControllerProvider.notifier).completeOnboarding();

      expect(container.read(onboardingControllerProvider), isTrue);
      verify(() => mockStorage.setHasCompletedOnboarding(completed: true)).called(1);
    });
  });

  group('GuestModeController Tests', () {
    test('initial state matches storage value', () {
      when(() => mockStorage.getIsGuestMode()).thenReturn(true);

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );

      final guestState = container.read(guestModeControllerProvider);
      expect(guestState, isTrue);
    });

    test('setGuestMode persists to storage and updates state', () async {
      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );

      expect(container.read(guestModeControllerProvider), isFalse);

      await container.read(guestModeControllerProvider.notifier).setGuestMode(active: true);

      expect(container.read(guestModeControllerProvider), isTrue);
      verify(() => mockStorage.setIsGuestMode(isGuest: true)).called(1);
    });
  });
}
