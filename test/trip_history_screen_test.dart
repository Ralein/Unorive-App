import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/data/models/trip.dart';
import 'package:unorive/data/repositories/trip_history_repository.dart';
import 'package:unorive/features/auth/auth_provider.dart';
import 'package:unorive/features/history/trip_history_screen.dart';
import 'package:unorive/features/history/trip_history_provider.dart';

class MockTripHistoryRepository extends Mock implements TripHistoryRepository {}
class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockTripHistoryRepository mockRepository;
  late MockLocalStorageService mockStorage;

  setUp(() {
    mockRepository = MockTripHistoryRepository();
    mockStorage = MockLocalStorageService();
    when(() => mockStorage.getAlarmSound()).thenReturn('assets/sounds/alarm.wav');
    when(() => mockStorage.getDefaultAlertRadius()).thenReturn(500.0);
    when(() => mockStorage.getDistanceUnit()).thenReturn('km');
    when(() => mockStorage.getThemeMode()).thenReturn('system');
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(mockStorage),
        tripHistoryRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MaterialApp(
        home: TripHistoryScreen(),
      ),
    );
  }

  testWidgets('renders empty state when history is empty', (tester) async {
    when(() => mockRepository.getTripHistory()).thenReturn([]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('No Commute Logs'), findsOneWidget);
    expect(find.text('Your completed or cancelled alarm runs will appear here.'), findsOneWidget);
  });

  testWidgets('renders trip history items list', (tester) async {
    final trips = [
      Trip(
        id: '1',
        destinationName: 'Office Complex',
        latitude: 51.5,
        longitude: -0.12,
        radiusMeters: 300,
        status: 'arrived',
        createdAt: DateTime.parse('2026-06-29T12:00:00.000Z'),
        durationMinutes: 15,
      ),
      Trip(
        id: '2',
        destinationName: 'Gym Center',
        latitude: 51.4,
        longitude: -0.11,
        radiusMeters: 200,
        status: 'cancelled',
        createdAt: DateTime.parse('2026-06-29T14:30:00.000Z'),
        durationMinutes: 5,
      ),
    ];
    when(() => mockRepository.getTripHistory()).thenReturn(trips);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Office Complex'), findsOneWidget);
    expect(find.text('Gym Center'), findsOneWidget);
    expect(find.text('ARRIVED'), findsOneWidget);
    expect(find.text('CANCELLED'), findsOneWidget);
    expect(find.text('15 mins'), findsOneWidget);
    expect(find.text('5 mins'), findsOneWidget);
  });
}
