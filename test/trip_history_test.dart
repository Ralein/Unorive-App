import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/data/models/trip.dart';
import 'package:unorive/data/repositories/trip_history_repository.dart';
import 'package:unorive/features/auth/auth_provider.dart';
import 'package:unorive/features/history/trip_history_provider.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockStorage;

  setUp(() {
    mockStorage = MockLocalStorageService();
  });

  group('TripHistoryRepository & Notifier Tests', () {
    test('getTripHistory returns parsed trips with duration from localStorageService', () {
      final jsonList = [
        jsonEncode({
          'id': '1',
          'destinationName': 'Office',
          'latitude': 51.5,
          'longitude': -0.12,
          'radiusMeters': 500.0,
          'status': 'arrived',
          'createdAt': '2026-06-29T12:00:00.000Z',
          'durationMinutes': 45,
        }),
      ];

      when(() => mockStorage.getTripHistoryJson()).thenReturn(jsonList);

      final repository = TripHistoryRepositoryImpl(storage: mockStorage);
      final history = repository.getTripHistory();

      expect(history.length, 1);
      expect(history.first.id, '1');
      expect(history.first.destinationName, 'Office');
      expect(history.first.status, 'arrived');
      expect(history.first.durationMinutes, 45);
    });

    test('saveTripToHistory writes JSON with duration to localStorageService', () async {
      final trip = Trip(
        id: '1',
        destinationName: 'Office',
        latitude: 51.5,
        longitude: -0.12,
        radiusMeters: 500.0,
        status: 'arrived',
        createdAt: DateTime.parse('2026-06-29T12:00:00.000Z'),
        durationMinutes: 30,
      );

      when(() => mockStorage.saveTripHistoryJson(any(), any())).thenAnswer((_) async {});

      final repository = TripHistoryRepositoryImpl(storage: mockStorage);
      await repository.saveTripToHistory(trip);

      verify(() => mockStorage.saveTripHistoryJson('1', jsonEncode(trip.toJson()))).called(1);
    });

    test('TripHistoryNotifier manages state reactively', () async {
      final jsonList = [
        jsonEncode({
          'id': '1',
          'destinationName': 'Office',
          'latitude': 51.5,
          'longitude': -0.12,
          'radiusMeters': 500.0,
          'status': 'arrived',
          'createdAt': '2026-06-29T12:00:00.000Z',
          'durationMinutes': 25,
        }),
      ];

      when(() => mockStorage.getTripHistoryJson()).thenReturn(jsonList);
      when(() => mockStorage.saveTripHistoryJson(any(), any())).thenAnswer((_) async {});
      when(() => mockStorage.deleteTripHistory(any())).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      final history = container.read(tripHistoryProvider);
      expect(history.length, 1);
      expect(history.first.destinationName, 'Office');

      final newTrip = Trip(
        id: '2',
        destinationName: 'Home',
        latitude: 51.4,
        longitude: -0.11,
        radiusMeters: 200.0,
        status: 'cancelled',
        createdAt: DateTime.now(),
        durationMinutes: 12,
      );

      when(() => mockStorage.getTripHistoryJson()).thenReturn([
        ...jsonList,
        jsonEncode(newTrip.toJson()),
      ]);

      await container.read(tripHistoryProvider.notifier).addTrip(newTrip);

      final updated = container.read(tripHistoryProvider);
      expect(updated.length, 2);
      expect(updated[1].destinationName, 'Home');
      expect(updated[1].status, 'cancelled');
    });
  });
}
