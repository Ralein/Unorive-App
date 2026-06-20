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
}

/// Concrete implementation of [GeofenceService] with debounce logic.
class GeofenceServiceImpl implements GeofenceService {
  @override
  bool checkBoundary(double currentDistance, double targetRadius) {
    return currentDistance <= targetRadius;
  }

  @override
  bool shouldTrigger(double distance, double radius, bool wasInside) {
    // Simple logic for stub, will expand in Phase 5
    final isInside = checkBoundary(distance, radius);
    if (isInside && !wasInside) {
      return true;
    }
    return false;
  }
}
