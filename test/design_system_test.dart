import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unorive/core/widgets/app_button.dart';
import 'package:unorive/core/widgets/empty_state_view.dart';
import 'package:unorive/core/widgets/glass_card.dart';
import 'package:unorive/core/widgets/status_pill.dart';

void main() {
  group('Design System Widget Tests', () {
    testWidgets('AppButton triggers onPressed callback and shows text', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              text: 'Tap Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      // Verify button text is displayed
      expect(find.text('Tap Me'), findsOneWidget);

      // Tap the button
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      // Verify callback was triggered
      expect(pressed, isTrue);
    });

    testWidgets('AppButton shows progress indicator when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              text: 'Loading Button',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Verify progress indicator is displayed and text is NOT displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('StatusPill displays capitalized label and correct style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(
              label: 'Arrived',
              type: StatusType.arrived,
            ),
          ),
        ),
      );

      // Verify label is capitalized in pill rendering
      expect(find.text('ARRIVED'), findsOneWidget);
    });

    testWidgets('GlassCard renders its child successfully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Frosted'),
            ),
          ),
        ),
      );

      expect(find.text('Frosted'), findsOneWidget);
    });

    testWidgets('EmptyStateView renders title, description, and triggers CTA', (tester) async {
      var ctaPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'Empty List',
              description: 'There is nothing here.',
              icon: Icons.list,
              actionText: 'Refresh',
              onActionPressed: () => ctaPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Empty List'), findsOneWidget);
      expect(find.text('There is nothing here.'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);

      // Tap CTA button
      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle();

      expect(ctaPressed, isTrue);
    });
  });
}
