import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unorive/core/services/background_service.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/core/services/location_service.dart';
import 'package:unorive/features/auth/auth_provider.dart';
import 'package:unorive/features/home_map/map_provider.dart';
import 'package:unorive/features/trip_tracking/trip_provider.dart';
import 'package:unorive/features/trip_tracking/trip_tracking_sheet.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}
class MockBackgroundService extends Mock implements BackgroundService {}
class MockLocationService extends Mock implements LocationService {}

class FakeTripController extends TripController {
  FakeTripController(this.mockState);
  final TripState mockState;

  @override
  TripState build() {
    return mockState;
  }

  @override
  Future<void> cancelTrip() async {
    state = const TripState(status: TripStatus.cancelled);
  }
}

void main() {
  late MockLocalStorageService mockStorage;
  late MockBackgroundService mockBackground;
  late MockLocationService mockLocation;
  late StreamController<Map<String, dynamic>> updateController;

  setUpAll(() {
    registerFallbackValue(const TripState(status: TripStatus.idle));
  });

  setUp(() {
    mockStorage = MockLocalStorageService();
    mockBackground = MockBackgroundService();
    mockLocation = MockLocationService();
    updateController = StreamController<Map<String, dynamic>>.broadcast();

    // Default mock behaviors
    when(() => mockStorage.getActiveTripJson()).thenReturn(null);
    when(() => mockStorage.setActiveTripJson(any())).thenAnswer((_) async {});
    
    when(() => mockBackground.startService()).thenAnswer((_) async => true);
    when(() => mockBackground.stopService()).thenAnswer((_) async {});
    when(() => mockBackground.onSerializedUpdate).thenAnswer((_) => updateController.stream);
    
    when(() => mockLocation.setTargetDestination(
      latitude: any(named: 'latitude'),
      longitude: any(named: 'longitude'),
    )).thenAnswer((_) {});
    when(() => mockLocation.clearTargetDestination()).thenAnswer((_) {});
  });

  tearDown(() {
    updateController.close();
  });

  group('TripController Unit Tests', () {
    test('initial state matches idle if no active trip in storage', () {
      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
          backgroundServiceProvider.overrideWithValue(mockBackground),
          locationServiceProvider.overrideWithValue(mockLocation),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(tripControllerProvider);
      expect(state.status, equals(TripStatus.idle));
    });

    test('initial state restores active trip from storage', () {
      const dest = Destination(
        name: 'Target Station',
        latitude: 10.0,
        longitude: 20.0,
        address: '123 Street',
      );
      final activeState = TripState(
        status: TripStatus.active,
        destination: dest,
        targetRadius: 500.0,
        remainingDistance: 1200.0,
        etaMinutes: 10,
        lastLocationUpdate: DateTime(2026, 6, 20),
      );

      when(() => mockStorage.getActiveTripJson()).thenReturn(
        jsonEncode(activeState.toJson()),
      );

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
          backgroundServiceProvider.overrideWithValue(mockBackground),
          locationServiceProvider.overrideWithValue(mockLocation),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(tripControllerProvider);
      expect(state.status, equals(TripStatus.active));
      expect(state.destination?.name, equals('Target Station'));
      expect(state.targetRadius, equals(500.0));
      expect(state.remainingDistance, equals(1200.0));
    });

    test('startTrip transitions state to active, configures location service, and persists to storage', () async {
      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
          backgroundServiceProvider.overrideWithValue(mockBackground),
          locationServiceProvider.overrideWithValue(mockLocation),
        ],
      );
      addTearDown(container.dispose);

      const dest = Destination(
        name: 'Workplace',
        latitude: 12.345,
        longitude: 67.890,
        address: 'Tech Hub',
      );

      await container.read(tripControllerProvider.notifier).startTrip(dest, radius: 600.0);

      final state = container.read(tripControllerProvider);
      expect(state.status, equals(TripStatus.active));
      expect(state.destination, equals(dest));
      expect(state.targetRadius, equals(600.0));

      verify(() => mockLocation.setTargetDestination(latitude: 12.345, longitude: 67.890)).called(1);
      verify(() => mockBackground.startService()).called(1);
      verify(() => mockStorage.setActiveTripJson(any())).called(1);
    });

    test('cancelTrip stops services, updates status to cancelled, and clears storage', () async {
      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
          backgroundServiceProvider.overrideWithValue(mockBackground),
          locationServiceProvider.overrideWithValue(mockLocation),
        ],
      );
      addTearDown(container.dispose);

      const dest = Destination(
        name: 'Workplace',
        latitude: 12.345,
        longitude: 67.890,
        address: 'Tech Hub',
      );

      // Start the trip first
      await container.read(tripControllerProvider.notifier).startTrip(dest);

      // Cancel the trip
      await container.read(tripControllerProvider.notifier).cancelTrip();

      final state = container.read(tripControllerProvider);
      expect(state.status, equals(TripStatus.cancelled));
      expect(state.destination, isNull);

      verify(() => mockLocation.clearTargetDestination()).called(1);
      verify(() => mockBackground.stopService()).called(1);
      verify(() => mockStorage.setActiveTripJson(null)).called(1);
    });

    test('arrive stops services, updates status to arrived, and clears storage', () async {
      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
          backgroundServiceProvider.overrideWithValue(mockBackground),
          locationServiceProvider.overrideWithValue(mockLocation),
        ],
      );
      addTearDown(container.dispose);

      const dest = Destination(
        name: 'Workplace',
        latitude: 12.345,
        longitude: 67.890,
        address: 'Tech Hub',
      );

      // Start the trip first
      await container.read(tripControllerProvider.notifier).startTrip(dest);

      // Arrive
      await container.read(tripControllerProvider.notifier).arrive();

      final state = container.read(tripControllerProvider);
      expect(state.status, equals(TripStatus.arrived));

      verify(() => mockLocation.clearTargetDestination()).called(1);
      verify(() => mockBackground.stopService()).called(1);
      verify(() => mockStorage.setActiveTripJson(null)).called(1);
    });

    test('calculateDistance boundary checks close/far ranges', () {
      final service = LocationServiceImpl();
      
      // Points within 1km
      final distClose = service.calculateDistance(51.5074, -0.1278, 51.5080, -0.1270);
      expect(distClose, lessThan(1000));
      
      // Points outside 1km
      final distFar = service.calculateDistance(51.5074, -0.1278, 51.5200, -0.1200);
      expect(distFar, greaterThan(1000));
    });

    test('Location updates from background service update TripState metrics', () async {
      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
          backgroundServiceProvider.overrideWithValue(mockBackground),
          locationServiceProvider.overrideWithValue(mockLocation),
        ],
      );
      addTearDown(container.dispose);

      const dest = Destination(
        name: 'Workplace',
        latitude: 12.345,
        longitude: 67.890,
        address: 'Tech Hub',
      );

      // Start trip
      print("DEBUG: Starting trip in unit test");
      await container.read(tripControllerProvider.notifier).startTrip(dest);
      print("DEBUG: Trip started. Status: ${container.read(tripControllerProvider).status}");

      // Emit a mock tick from the background isolate update channel
      print("DEBUG: Adding mock background update event to updateController");
      updateController.add({
        'remainingDistance': 450.5,
        'etaMinutes': 4,
        'timestamp': DateTime(2026, 6, 20, 15, 0, 0).toIso8601String(),
      });

      // Allow the microtask queue to process the stream event
      print("DEBUG: Awaiting delay");
      await Future<void>.delayed(const Duration(milliseconds: 150));
      print("DEBUG: Delay complete. Status: ${container.read(tripControllerProvider).status}");
      print("DEBUG: Remaining distance: ${container.read(tripControllerProvider).remainingDistance}");

      final state = container.read(tripControllerProvider);
      expect(state.remainingDistance, equals(450.5));
      expect(state.etaMinutes, equals(4));
      expect(state.lastLocationUpdate, equals(DateTime(2026, 6, 20, 15, 0, 0)));
    });
  });

  group('TripTrackingSheet Widget Tests', () {
    testWidgets('renders nothing when trip status is idle', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(mockStorage),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  TripTrackingSheet(),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('ACTIVE TRIP'), findsNothing);
    });

    testWidgets('renders destination details and Cancel button when trip status is active', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const dest = Destination(
        name: 'Dream Land',
        latitude: 12.34,
        longitude: 56.78,
        address: '456 Dream Road',
      );
      final activeState = TripState(
        status: TripStatus.active,
        destination: dest,
        targetRadius: 800.0,
        remainingDistance: 1500.0,
        etaMinutes: 8,
        lastLocationUpdate: DateTime(2026, 6, 20, 12, 34, 56),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(mockStorage),
            tripControllerProvider.overrideWith(() => FakeTripController(activeState)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  TripTrackingSheet(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ACTIVE TRIP'), findsOneWidget);
      expect(find.text('Dream Land'), findsOneWidget);
      expect(find.text('456 Dream Road'), findsOneWidget);
      expect(find.text('1.5 km'), findsOneWidget);
      expect(find.text('8 mins'), findsOneWidget);
      expect(find.text('Cancel Trip'), findsOneWidget);
    });

    testWidgets('tapping Cancel Trip invokes cancelTrip and transitions state', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const dest = Destination(
        name: 'Dream Land',
        latitude: 12.34,
        longitude: 56.78,
        address: '456 Dream Road',
      );
      final activeState = TripState(
        status: TripStatus.active,
        destination: dest,
        targetRadius: 800.0,
        remainingDistance: 1500.0,
        etaMinutes: 8,
        lastLocationUpdate: DateTime(2026, 6, 20, 12, 34, 56),
      );

      final controller = FakeTripController(activeState);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(mockStorage),
            tripControllerProvider.overrideWith(() => controller),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  TripTrackingSheet(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel Trip'));
      await tester.pumpAndSettle();

      expect(controller.state.status, equals(TripStatus.cancelled));
    });
  });
}
