import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/features/auth/auth_provider.dart';
import 'package:unorive/features/settings/settings_provider.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockStorage;

  setUp(() {
    mockStorage = MockLocalStorageService();
    
    // Default values returned by storage mock
    when(() => mockStorage.getAlarmSound()).thenReturn('assets/sounds/alarm.wav');
    when(() => mockStorage.getDefaultAlertRadius()).thenReturn(500.0);
    when(() => mockStorage.getDistanceUnit()).thenReturn('km');
    when(() => mockStorage.getThemeMode()).thenReturn('system');

    when(() => mockStorage.setAlarmSound(any())).thenAnswer((_) async {});
    when(() => mockStorage.setDefaultAlertRadius(any())).thenAnswer((_) async {});
    when(() => mockStorage.setDistanceUnit(any())).thenAnswer((_) async {});
    when(() => mockStorage.setThemeMode(any())).thenAnswer((_) async {});
  });

  group('SettingsNotifier & Preferences Tests', () {
    test('SettingsNotifier loads default values correctly on build', () {
      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      final settings = container.read(settingsProvider);
      
      expect(settings.alarmSound, equals('assets/sounds/alarm.wav'));
      expect(settings.defaultAlertRadius, equals(500.0));
      expect(settings.distanceUnit, equals('km'));
      expect(settings.themeMode, equals('system'));
    });

    test('updating preferences triggers local storage set calls', () async {
      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier);

      // Sound update
      await notifier.updateAlarmSound('assets/sounds/beep.wav');
      expect(container.read(settingsProvider).alarmSound, equals('assets/sounds/beep.wav'));
      verify(() => mockStorage.setAlarmSound('assets/sounds/beep.wav')).called(1);

      // Radius update
      await notifier.updateDefaultAlertRadius(800.0);
      expect(container.read(settingsProvider).defaultAlertRadius, equals(800.0));
      verify(() => mockStorage.setDefaultAlertRadius(800.0)).called(1);

      // Unit update
      await notifier.updateDistanceUnit('mi');
      expect(container.read(settingsProvider).distanceUnit, equals('mi'));
      verify(() => mockStorage.setDistanceUnit('mi')).called(1);

      // Theme update
      await notifier.updateThemeMode('dark');
      expect(container.read(settingsProvider).themeMode, equals('dark'));
      verify(() => mockStorage.setThemeMode('dark')).called(1);
    });

    test('distance conversions compute correct values', () {
      const double meters = 1000.0;
      
      // Metric
      final double km = meters / 1000.0;
      expect(km, equals(1.0));

      // Imperial conversions
      final double miles = meters * 0.000621371;
      expect(miles, closeTo(0.621, 0.001));

      final double feet = meters * 3.28084;
      expect(feet, closeTo(3280.84, 0.01));
    });
  });
}
