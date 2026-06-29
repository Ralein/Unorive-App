import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/features/auth/auth_provider.dart';
import 'package:unorive/features/home_map/home_screen.dart';
import 'package:unorive/features/home_map/map_provider.dart';

class FakeLocalStorageService implements LocalStorageService {
  @override
  Future<void> initialize() async {}
  @override
  bool getHasCompletedOnboarding() => true;
  @override
  Future<void> setHasCompletedOnboarding({required bool completed}) async {}
  @override
  bool getIsGuestMode() => false;
  @override
  Future<void> setIsGuestMode({required bool isGuest}) async {}
  @override
  String? getActiveTripJson() => null;
  @override
  Future<void> setActiveTripJson(String? json) async {}
  @override
  List<String> getSavedPlacesJson() => [];
  @override
  Future<void> saveSavedPlaceJson(String id, String json) async {}
  @override
  Future<void> deleteSavedPlace(String id) async {}
  @override
  List<String> getTripHistoryJson() => [];
  @override
  Future<void> saveTripHistoryJson(String id, String json) async {}
  @override
  Future<void> deleteTripHistory(String id) async {}
  @override
  Future<void> clear() async {}
}

void main() {
  group('MapProvider Unit Tests', () {
    test('destinationSearchQueryProvider updates query correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(destinationSearchQueryProvider), equals(''));

      container.read(destinationSearchQueryProvider.notifier).updateQuery('Paris');

      expect(container.read(destinationSearchQueryProvider), equals('Paris'));
    });

    test('selectedDestinationProvider selects and clears destinations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedDestinationProvider), isNull);

      const dest = Destination(
        name: 'Eiffel Tower',
        latitude: 48.8584,
        longitude: 2.2945,
        address: 'Champ de Mars, Paris',
      );

      container.read(selectedDestinationProvider.notifier).select(dest);
      expect(container.read(selectedDestinationProvider), equals(dest));

      container.read(selectedDestinationProvider.notifier).clear();
      expect(container.read(selectedDestinationProvider), isNull);
    });

    test('searchSuggestionsProvider returns mock suggestions in test environment', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(destinationSearchQueryProvider.notifier).updateQuery('London');

      // Wait for future provider to complete
      final suggestions = await container.read(searchSuggestionsProvider.future);

      expect(suggestions, isNotEmpty);
      expect(suggestions.first.name, contains('London'));
    });

    test('routeCoordinatesProvider generates coordinates array', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final route = await container.read(
        routeCoordinatesProvider(
          startLat: 51.5074,
          startLng: -0.1278,
          endLat: 48.8566,
          endLng: 2.3522,
        ).future,
      );

      expect(route.length, greaterThanOrEqualTo(2));
      expect(route.first, equals([-0.1278, 51.5074]));
      expect(route.last, equals([2.3522, 48.8566]));
    });
  });
  group('HomeScreen Widget Tests', () {
    final fakeStorage = FakeLocalStorageService();

    testWidgets('Renders search bar correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(fakeStorage),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify search input field exists
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search destination...'), findsOneWidget);
    });

    testWidgets('Long press drops a pin on simulated canvas', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(fakeStorage),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify no trip details card is shown initially
      expect(find.text('Start Trip'), findsNothing);

      // Trigger long press on the simulated map container
      await tester.longPress(find.byType(HomeScreen));
      await tester.pumpAndSettle();

      // Verify destination detail card and start trip button are now visible
      expect(find.text('Start Trip'), findsOneWidget);
      expect(find.text('Dropped Pin (Simulated)'), findsOneWidget);
    });
  });
}
