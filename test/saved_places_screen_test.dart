import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/data/models/saved_place.dart';
import 'package:unorive/data/repositories/saved_places_repository.dart';
import 'package:unorive/features/auth/auth_provider.dart';
import 'package:unorive/features/saved_places/saved_places_screen.dart';
import 'package:unorive/features/saved_places/saved_places_provider.dart';

class MockSavedPlacesRepository extends Mock implements SavedPlacesRepository {}
class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockSavedPlacesRepository mockRepository;
  late MockLocalStorageService mockStorage;

  setUpAll(() {
    registerFallbackValue(
      SavedPlace(
        id: '1',
        name: 'Home',
        latitude: 0,
        longitude: 0,
        iconName: 'home',
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockRepository = MockSavedPlacesRepository();
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
        savedPlacesRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MaterialApp(
        home: SavedPlacesScreen(),
      ),
    );
  }

  testWidgets('renders empty state when no saved places', (tester) async {
    when(() => mockRepository.getSavedPlaces()).thenReturn([]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('No Saved Places'), findsOneWidget);
    expect(find.text('Add your favorite destinations to start trips quickly.'), findsOneWidget);
  });

  testWidgets('renders saved places in list', (tester) async {
    final places = [
      SavedPlace(
        id: '1',
        name: 'Office',
        latitude: 51.5000,
        longitude: -0.1200,
        iconName: 'work',
        createdAt: DateTime.now(),
      ),
    ];
    when(() => mockRepository.getSavedPlaces()).thenReturn(places);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Office'), findsOneWidget);
    expect(find.text('Coordinates: 51.5000, -0.1200'), findsOneWidget);
    expect(find.byIcon(Icons.work_rounded), findsOneWidget);
  });

  testWidgets('opens Add Saved Place dialog when add button tapped', (tester) async {
    when(() => mockRepository.getSavedPlaces()).thenReturn([]);
    when(() => mockRepository.saveSavedPlace(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Tap floating add button
    final addButton = find.byKey(const ValueKey('add_place_button'));
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Verify dialog is open
    expect(find.text('Add Saved Place'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
