import 'package:flutter_test/flutter_test.dart';
import 'package:unorive/core/services/location_service.dart';

void main() {
  group('LocationService Tests', () {
    late LocationService locationService;

    setUp(() {
      locationService = LocationServiceImpl();
    });

    test('calculateDistance returns correct distance between points', () {
      // Test coordinates (London and Paris)
      const londonLat = 51.5074;
      const londonLng = -0.1278;
      const parisLat = 48.8566;
      const parisLng = 2.3522;

      final distance = locationService.calculateDistance(
        londonLat,
        londonLng,
        parisLat,
        parisLng,
      );

      // Distance should be approximately 344 km (344,000 meters)
      expect(distance, greaterThan(340000));
      expect(distance, lessThan(350000));
    });
  });
}
