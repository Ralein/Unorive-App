import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/data/models/saved_place.dart';
import 'package:unorive/data/repositories/saved_places_repository.dart';
import 'package:unorive/features/saved_places/saved_places_provider.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockStorage;

  setUp(() {
    mockStorage = MockLocalStorageService();
  });

  group('SavedPlacesRepository & Notifier Tests', () {
    test('getSavedPlaces returns parsed places from localStorageService', () {
      final jsonList = [
        jsonEncode({
          'id': '1',
          'name': 'Home',
          'latitude': 51.5,
          'longitude': -0.12,
          'iconName': 'home',
          'createdAt': '2026-06-29T12:00:00.000Z',
        }),
      ];

      when(() => mockStorage.getSavedPlacesJson()).thenReturn(jsonList);

      final repository = SavedPlacesRepositoryImpl(storage: mockStorage);
      final places = repository.getSavedPlaces();

      expect(places.length, 1);
      expect(places.first.id, '1');
      expect(places.first.name, 'Home');
      expect(places.first.latitude, 51.5);
      expect(places.first.iconName, 'home');
    });

    test('saveSavedPlace writes JSON to localStorageService', () async {
      final place = SavedPlace(
        id: '1',
        name: 'Work',
        latitude: 51.6,
        longitude: -0.13,
        iconName: 'work',
        createdAt: DateTime.parse('2026-06-29T12:00:00.000Z'),
      );

      when(() => mockStorage.saveSavedPlaceJson(any(), any())).thenAnswer((_) async {});

      final repository = SavedPlacesRepositoryImpl(storage: mockStorage);
      await repository.saveSavedPlace(place);

      verify(() => mockStorage.saveSavedPlaceJson('1', jsonEncode(place.toJson()))).called(1);
    });

    test('deleteSavedPlace deletes key from localStorageService', () async {
      when(() => mockStorage.deleteSavedPlace(any())).thenAnswer((_) async {});

      final repository = SavedPlacesRepositoryImpl(storage: mockStorage);
      await repository.deleteSavedPlace('1');

      verify(() => mockStorage.deleteSavedPlace('1')).called(1);
    });

    test('SavedPlacesNotifier manages state reactively', () async {
      final jsonList = [
        jsonEncode({
          'id': '1',
          'name': 'Home',
          'latitude': 51.5,
          'longitude': -0.12,
          'iconName': 'home',
          'createdAt': '2026-06-29T12:00:00.000Z',
        }),
      ];

      when(() => mockStorage.getSavedPlacesJson()).thenReturn(jsonList);
      when(() => mockStorage.saveSavedPlaceJson(any(), any())).thenAnswer((_) async {});
      when(() => mockStorage.deleteSavedPlace(any())).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      // Verify initial state
      final places = container.read(savedPlacesProvider);
      expect(places.length, 1);
      expect(places.first.name, 'Home');

      // Add a place
      final newPlace = SavedPlace(
        id: '2',
        name: 'Gym',
        latitude: 51.7,
        longitude: -0.14,
        iconName: 'star',
        createdAt: DateTime.now(),
      );

      // We need to return the updated list when read again
      when(() => mockStorage.getSavedPlacesJson()).thenReturn([
        ...jsonList,
        jsonEncode(newPlace.toJson()),
      ]);

      await container.read(savedPlacesProvider.notifier).addPlace(newPlace);

      final updatedPlaces = container.read(savedPlacesProvider);
      expect(updatedPlaces.length, 2);
      expect(updatedPlaces[1].name, 'Gym');

      // Remove a place
      when(() => mockStorage.getSavedPlacesJson()).thenReturn([jsonList[0]]);
      await container.read(savedPlacesProvider.notifier).removePlace('2');

      final finalPlaces = container.read(savedPlacesProvider);
      expect(finalPlaces.length, 1);
      expect(finalPlaces.first.name, 'Home');
    });
  });
}
