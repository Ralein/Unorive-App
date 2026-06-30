import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unorive/core/services/alarm_service.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/features/auth/auth_provider.dart';
import 'package:unorive/features/home_map/map_provider.dart';
import 'package:unorive/features/trip_tracking/trip_provider.dart';
import 'package:unorive/features/alarm_screen/alarm_screen_placeholder.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}
class MockAlarmService extends Mock implements AlarmService {}

class FakeTripController extends TripController {
  FakeTripController(this.mockState);
  final TripState mockState;

  @override
  TripState build() {
    return mockState;
  }

  @override
  Future<void> dismissAlarm() async {
    state = const TripState(status: TripStatus.idle);
  }

  @override
  Future<void> snooze({required int minutes}) async {
    state = state.copyWith(
      status: TripStatus.active,
      targetRadius: (state.targetRadius * 0.5).clamp(100.0, double.infinity),
    );
  }
}

void main() {
  late MockLocalStorageService mockStorage;
  late MockAlarmService mockAlarm;

  setUp(() {
    mockStorage = MockLocalStorageService();
    mockAlarm = MockAlarmService();

    when(() => mockStorage.getActiveTripJson()).thenReturn(null);
    when(() => mockStorage.setActiveTripJson(any())).thenAnswer((_) async {});
    when(() => mockStorage.getSavedPlacesJson()).thenReturn([]);
    when(() => mockStorage.saveSavedPlaceJson(any(), any())).thenAnswer((_) async {});
    when(() => mockStorage.deleteSavedPlace(any())).thenAnswer((_) async {});
    when(() => mockStorage.getTripHistoryJson()).thenReturn([]);
    when(() => mockStorage.saveTripHistoryJson(any(), any())).thenAnswer((_) async {});
    when(() => mockStorage.deleteTripHistory(any())).thenAnswer((_) async {});
    when(() => mockStorage.getAlarmSound()).thenReturn('assets/sounds/alarm.wav');
    when(() => mockStorage.getDefaultAlertRadius()).thenReturn(500.0);
    when(() => mockStorage.getDistanceUnit()).thenReturn('km');
    when(() => mockStorage.getThemeMode()).thenReturn('system');
    when(() => mockAlarm.stopAlarm()).thenAnswer((_) async => true);
    when(() => mockAlarm.snoozeAlarm(minutes: any(named: 'minutes'))).thenAnswer((_) async {});
  });

  group('AlarmScreenPlaceholder Widget Tests', () {
    testWidgets('renders YOU HAVE ARRIVED and destination details correctly', (tester) async {
      const dest = Destination(
        name: 'Grand Central',
        latitude: 40.7527,
        longitude: -73.9772,
        address: '89 E 42nd St',
      );
      final arrivedState = TripState(
        status: TripStatus.arrived,
        destination: dest,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(mockStorage),
            alarmServiceProvider.overrideWithValue(mockAlarm),
            tripControllerProvider.overrideWith(() => FakeTripController(arrivedState)),
          ],
          child: const MaterialApp(
            home: AlarmScreenPlaceholder(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('YOU HAVE ARRIVED'), findsOneWidget);
      expect(find.text('Grand Central'), findsOneWidget);
      expect(find.text('89 E 42nd St'), findsOneWidget);
      expect(find.byKey(const ValueKey('dismiss_alarm_button')), findsOneWidget);
    });

    testWidgets('tapping Dismiss Alarm invokes dismissAlarm and updates state', (tester) async {
      const dest = Destination(
        name: 'Grand Central',
        latitude: 40.7527,
        longitude: -73.9772,
        address: '89 E 42nd St',
      );
      final arrivedState = TripState(
        status: TripStatus.arrived,
        destination: dest,
      );

      final controller = FakeTripController(arrivedState);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(mockStorage),
            alarmServiceProvider.overrideWithValue(mockAlarm),
            tripControllerProvider.overrideWith(() => controller),
          ],
          child: const MaterialApp(
            home: AlarmScreenPlaceholder(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('dismiss_alarm_button')));
      await tester.pumpAndSettle();

      expect(controller.state.status, equals(TripStatus.idle));
    });

    testWidgets('tapping Snooze invokes snooze and updates state status and radius', (tester) async {
      const dest = Destination(
        name: 'Grand Central',
        latitude: 40.7527,
        longitude: -73.9772,
        address: '89 E 42nd St',
      );
      final arrivedState = TripState(
        status: TripStatus.arrived,
        destination: dest,
        targetRadius: 800.0,
      );

      final controller = FakeTripController(arrivedState);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(mockStorage),
            alarmServiceProvider.overrideWithValue(mockAlarm),
            tripControllerProvider.overrideWith(() => controller),
          ],
          child: const MaterialApp(
            home: AlarmScreenPlaceholder(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('snooze_alarm_button')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('snooze_alarm_button')));
      await tester.pumpAndSettle();

      expect(controller.state.status, equals(TripStatus.active));
      expect(controller.state.targetRadius, equals(400.0));
    });
  });
}
