import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:unorive/features/trip_tracking/trip_summary_screen.dart';

void main() {
  group('TripSummaryScreen Widget Tests', () {
    testWidgets('renders destination details and duration correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TripSummaryScreen(
            destinationName: 'Times Square',
            durationMinutes: 18,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Trip Completed!'), findsOneWidget);
      expect(find.text('Times Square'), findsOneWidget);
      expect(find.text('18 mins'), findsOneWidget);
      expect(find.text('Back to Home Map'), findsOneWidget);
    });

    testWidgets('tapping Back to Home Map navigates to /home', (tester) async {
      final router = GoRouter(
        initialLocation: '/trip-summary',
        routes: [
          GoRoute(
            path: '/trip-summary',
            builder: (context, state) => const TripSummaryScreen(
              destinationName: 'Times Square',
              durationMinutes: 18,
            ),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Text('Home Map Screen'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Verify we start on trip summary
      expect(find.text('Times Square'), findsOneWidget);
      expect(find.text('Home Map Screen'), findsNothing);

      // Tap the button
      await tester.tap(find.text('Back to Home Map'));
      await tester.pumpAndSettle();

      // Verify we navigated to /home
      expect(find.text('Home Map Screen'), findsOneWidget);
    });
  });
}
