import 'package:flutter_test/flutter_test.dart';
import 'package:unorive/core/services/geofence_service.dart';

void main() {
  late GeofenceService geofenceService;

  setUp(() {
    geofenceService = GeofenceServiceImpl();
  });

  group('GeofenceService Proximity and Boundary Math Tests', () {
    test('checkBoundary returns true when distance is less than or equal to radius', () {
      expect(geofenceService.checkBoundary(799.9, 800.0), isTrue);
      expect(geofenceService.checkBoundary(800.0, 800.0), isTrue);
      expect(geofenceService.checkBoundary(800.1, 800.0), isFalse);
    });

    test('shouldTrigger returns true only when transitioning from outside to inside', () {
      expect(geofenceService.shouldTrigger(500.0, 800.0, false), isTrue);
      expect(geofenceService.shouldTrigger(500.0, 800.0, true), isFalse);
      expect(geofenceService.shouldTrigger(900.0, 800.0, false), isFalse);
    });
  });

  group('GeofenceService Adaptive evaluate() Debounce & Filtering Tests', () {
    const double radius = 800.0;

    test('evaluate returns false when GPS accuracy is poor (> 80m)', () {
      final shouldTrigger = geofenceService.evaluate(
        distance: 400.0, // Well within radius
        radius: radius,
        accuracy: 95.0,  // Very poor accuracy
        recentDistances: [],
      );
      expect(shouldTrigger, isFalse);
    });

    test('evaluate returns true immediately when deep inside (<= 90% of radius) with high accuracy (<= 15m)', () {
      final shouldTrigger = geofenceService.evaluate(
        distance: 700.0, // 700 / 800 = 87.5% (<= 90%)
        radius: radius,
        accuracy: 10.0,  // High accuracy
        recentDistances: [],
      );
      expect(shouldTrigger, isTrue);
    });

    test('evaluate returns false on first marginal boundary update', () {
      final shouldTrigger = geofenceService.evaluate(
        distance: 780.0, // 780 / 800 = 97.5% (marginal, > 90%)
        radius: radius,
        accuracy: 25.0,  // Medium accuracy
        recentDistances: [],
      );
      expect(shouldTrigger, isFalse);
    });

    test('evaluate returns true when marginal boundary is crossed and second consecutive tick is also inside', () {
      final recentDistances = <double>[790.0]; // First reading was inside

      final shouldTrigger = geofenceService.evaluate(
        distance: 780.0, // Second reading is inside
        radius: radius,
        accuracy: 25.0,
        recentDistances: recentDistances,
      );
      expect(shouldTrigger, isTrue);
    });

    test('evaluate returns false when marginal boundary is inside but previous tick was outside', () {
      final recentDistances = <double>[950.0]; // Previous reading was outside

      final shouldTrigger = geofenceService.evaluate(
        distance: 780.0, // Current reading is inside
        radius: radius,
        accuracy: 25.0,
        recentDistances: recentDistances,
      );
      expect(shouldTrigger, isFalse);
    });
  });
}
