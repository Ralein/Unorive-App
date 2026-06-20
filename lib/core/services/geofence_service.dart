import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'geofence_service.g.dart';

@riverpod
GeofenceService geofenceService(Ref ref) {
  return GeofenceServiceImpl();
}

/// Abstract interface for managing geofence checks and triggers.
abstract class GeofenceService {
  /// Checks whether [currentDistance] is within [targetRadius].
  bool checkBoundary(double currentDistance, double targetRadius);

  /// Evaluates hysteresis/debounce logic to prevent flickering near the boundary.
  bool shouldTrigger(double distance, double radius, bool wasInside);

  /// Evaluates location updates for geofencing with GPS accuracy filtering and debounce.
  /// Returns true if a valid transition into the geofence occurs.
  bool evaluate({
    required double distance,
    required double radius,
    required double accuracy,
    required List<double> recentDistances,
  });
}

/// Concrete implementation of [GeofenceService] with debounce logic.
class GeofenceServiceImpl implements GeofenceService {
  @override
  bool checkBoundary(double currentDistance, double targetRadius) {
    return currentDistance <= targetRadius;
  }

  @override
  bool shouldTrigger(double distance, double radius, bool wasInside) {
    final isInside = checkBoundary(distance, radius);
    if (isInside && !wasInside) {
      return true;
    }
    return false;
  }

  @override
  bool evaluate({
    required double distance,
    required double radius,
    required double accuracy,
    required List<double> recentDistances,
  }) {
    // 1. GPS Accuracy Filtering: Ignore updates with accuracy > 80m (poor quality/noisy)
    if (accuracy > 80.0) {
      return false;
    }

    final isInside = checkBoundary(distance, radius);
    if (!isInside) return false;

    // 2. Proximity Confidence-Based Debouncing:
    // If we are deep inside (<= 90% of radius) with high accuracy (<= 15m), trigger immediately
    if (distance <= radius * 0.9 && accuracy <= 15.0) {
      return true;
    }

    // Otherwise, require at least 2 consecutive readings inside the radius to prevent false positives from location spikes
    if (recentDistances.isNotEmpty) {
      final lastDistance = recentDistances.last;
      if (checkBoundary(lastDistance, radius)) {
        return true;
      }
    }

    return false;
  }
}
