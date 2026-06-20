import 'package:geolocator/geolocator.dart';

/// Abstract interface for live location tracking and distance calculations.
abstract class LocationService {
  /// Stream of current GPS positions.
  Stream<Position> get positionStream;

  /// Returns the last known cached position.
  Future<Position?> getLastKnownPosition();

  /// Calculates the distance (in meters) between two coordinates.
  double calculateDistance(double startLat, double startLng, double endLat, double endLng);
}

/// Concrete implementation of [LocationService] using the Geolocator package.
class LocationServiceImpl implements LocationService {
  @override
  Stream<Position> get positionStream {
    // Placeholder stream
    return const Stream.empty();
  }

  @override
  Future<Position?> getLastKnownPosition() async {
    return null;
  }

  @override
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
