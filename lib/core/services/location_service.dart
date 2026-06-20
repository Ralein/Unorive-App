import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

@riverpod
LocationService locationService(Ref ref) {
  return LocationServiceImpl();
}

/// Abstract interface for live location tracking and distance calculations.
abstract class LocationService {
  /// Stream of current GPS positions.
  Stream<Position> get positionStream;

  /// Returns the last known cached position.
  Future<Position?> getLastKnownPosition();

  /// Calculates the distance (in meters) between two coordinates.
  double calculateDistance(double startLat, double startLng, double endLat, double endLng);

  /// Configures target destination for adaptive polling calculations.
  void setTargetDestination({required double latitude, required double longitude});

  /// Clears the target destination and resets polling to standard interval.
  void clearTargetDestination();
}

/// Concrete implementation of [LocationService] using the Geolocator package,
/// dynamically scaling update frequency based on proximity to the active geofence.
class LocationServiceImpl implements LocationService {
  LocationServiceImpl();

  double? _targetLat;
  double? _targetLng;
  int _currentIntervalSeconds = 30; // Default slow polling when far

  StreamController<Position>? _controller;
  StreamSubscription<Position>? _geolocatorSubscription;

  @override
  Stream<Position> get positionStream {
    _controller ??= StreamController<Position>.broadcast(
      onListen: _startTracking,
      onCancel: _stopTracking,
    );
    return _controller!.stream;
  }

  void _startTracking() {
    _restartGeolocatorStream();
  }

  void _stopTracking() {
    _geolocatorSubscription?.cancel();
    _geolocatorSubscription = null;
  }

  void _restartGeolocatorStream() {
    _geolocatorSubscription?.cancel();

    // Use adaptive location settings
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: _currentIntervalSeconds == 5 ? 5 : 20, // Sensitive if close
    );

    _geolocatorSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((pos) {
      if (_controller != null && !_controller!.isClosed) {
        _controller!.add(pos);
      }
      _evaluateAdaptiveInterval(pos);
    }, onError: (Object err) {
      if (_controller != null && !_controller!.isClosed) {
        _controller!.addError(err);
      }
    });
  }

  void _evaluateAdaptiveInterval(Position pos) {
    if (_targetLat == null || _targetLng == null) return;

    final distance = calculateDistance(
      pos.latitude,
      pos.longitude,
      _targetLat!,
      _targetLng!,
    );

    // If within 1 kilometer (1000 meters), tighten interval to 5 seconds
    final desiredInterval = distance <= 1000 ? 5 : 30;

    if (desiredInterval != _currentIntervalSeconds) {
      _currentIntervalSeconds = desiredInterval;
      _restartGeolocatorStream();
    }
  }

  @override
  void setTargetDestination({required double latitude, required double longitude}) {
    _targetLat = latitude;
    _targetLng = longitude;
    // Force a stream restart to evaluate position immediately
    _restartGeolocatorStream();
  }

  @override
  void clearTargetDestination() {
    _targetLat = null;
    _targetLng = null;
    _currentIntervalSeconds = 30;
    _restartGeolocatorStream();
  }

  @override
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  @override
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
