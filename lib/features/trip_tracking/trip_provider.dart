import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unorive/core/services/background_service.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/core/services/location_service.dart';
import 'package:unorive/core/services/alarm_service.dart';
import 'package:unorive/data/models/trip.dart';
import 'package:unorive/features/auth/auth_provider.dart';
import 'package:unorive/features/home_map/map_provider.dart';
import 'package:unorive/features/history/trip_history_provider.dart';

part 'trip_provider.g.dart';

/// Representation of the current trip status.
enum TripStatus {
  idle,
  active,
  arrived,
  cancelled,
}

/// Holds all state values for the active or last trip.
class TripState {
  const TripState({
    required this.status,
    this.destination,
    this.targetRadius = 800.0,
    this.remainingDistance,
    this.etaMinutes,
    this.lastLocationUpdate,
    this.startTime,
  });

  final TripStatus status;
  final Destination? destination;
  final double targetRadius;
  final double? remainingDistance;
  final int? etaMinutes;
  final DateTime? lastLocationUpdate;
  final DateTime? startTime;

  TripState copyWith({
    TripStatus? status,
    Destination? destination,
    double? targetRadius,
    double? remainingDistance,
    int? etaMinutes,
    DateTime? lastLocationUpdate,
    DateTime? startTime,
  }) {
    return TripState(
      status: status ?? this.status,
      destination: destination ?? this.destination,
      targetRadius: targetRadius ?? this.targetRadius,
      remainingDistance: remainingDistance ?? this.remainingDistance,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      startTime: startTime ?? this.startTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'destination': destination?.toJson(),
        'targetRadius': targetRadius,
        'remainingDistance': remainingDistance,
        'etaMinutes': etaMinutes,
        'lastLocationUpdate': lastLocationUpdate?.toIso8601String(),
        'startTime': startTime?.toIso8601String(),
      };

  factory TripState.fromJson(Map<String, dynamic> json) {
    final destJson = json['destination'] as Map<String, dynamic>?;
    return TripState(
      status: TripStatus.values.firstWhere((e) => e.name == json['status']),
      destination: destJson != null
          ? Destination(
              name: destJson['name'] as String? ?? '',
              latitude: destJson['latitude'] as double? ?? 0.0,
              longitude: destJson['longitude'] as double? ?? 0.0,
              address: destJson['address'] as String? ?? '',
            )
          : null,
      targetRadius: (json['targetRadius'] as num? ?? 800.0).toDouble(),
      remainingDistance: (json['remainingDistance'] as num?)?.toDouble(),
      etaMinutes: json['etaMinutes'] as int?,
      lastLocationUpdate: json['lastLocationUpdate'] != null
          ? DateTime.parse(json['lastLocationUpdate'] as String)
          : null,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
    );
  }
}

/// State notifier managing active trip transitions, coordinates updates,
/// and coordinating OS background service lifecycle.
@riverpod
class TripController extends _$TripController {
  StreamSubscription<Map<String, dynamic>?>? _backgroundSubscription;

  @override
  TripState build() {
    // Clean up subscription on dispose
    ref.onDispose(() {
      _backgroundSubscription?.cancel();
    });

    final storage = ref.read(localStorageServiceProvider);
    final savedTripJson = storage.getActiveTripJson();

    if (savedTripJson != null) {
      try {
        final state = TripState.fromJson(
          jsonDecode(savedTripJson) as Map<String, dynamic>,
        );
        
        // If state is active, resume listening to background updates
        if (state.status == TripStatus.active) {
          _resumeBackgroundTracking(state.destination!);
        }
        return state;
      } catch (_) {
        // Fallback to idle if parse fails
      }
    }

    return const TripState(status: TripStatus.idle);
  }

  /// Starts a new location tracking trip.
  Future<void> startTrip(Destination destination, {double radius = 800.0}) async {
    final activeState = TripState(
      status: TripStatus.active,
      destination: destination,
      targetRadius: radius,
      remainingDistance: null,
      etaMinutes: null,
      lastLocationUpdate: DateTime.now(),
      startTime: DateTime.now(),
    );

    // Save active state to Hive
    final storage = ref.read(localStorageServiceProvider);
    await storage.setActiveTripJson(jsonEncode(activeState.toJson()));
    state = activeState;

    // Configure main location service target for adaptive polling
    ref.read(locationServiceProvider).setTargetDestination(
          latitude: destination.latitude,
          longitude: destination.longitude,
        );

    // Start background tracking service
    await ref.read(backgroundServiceProvider).startService();

    // Start listening to background updates
    _resumeBackgroundTracking(destination);
  }

  /// Cancels and terminates the active trip.
  Future<void> cancelTrip() async {
    _backgroundSubscription?.cancel();
    _backgroundSubscription = null;

    // Stop background service
    await ref.read(backgroundServiceProvider).stopService();

    // Clear location service targets
    ref.read(locationServiceProvider).clearTargetDestination();

    final destination = state.destination;
    final startTime = state.startTime;
    if (destination != null) {
      final tripRecord = Trip(
        id: 'cancelled_${DateTime.now().millisecondsSinceEpoch}',
        destinationName: destination.name,
        latitude: destination.latitude,
        longitude: destination.longitude,
        radiusMeters: state.targetRadius,
        status: 'cancelled',
        createdAt: startTime ?? DateTime.now(),
        durationMinutes: startTime != null ? DateTime.now().difference(startTime).inMinutes : 0,
      );
      await ref.read(tripHistoryProvider.notifier).addTrip(tripRecord);
    }

    // Remove active state from Hive
    final storage = ref.read(localStorageServiceProvider);
    await storage.setActiveTripJson(null);

    state = const TripState(status: TripStatus.cancelled);
  }

  /// Triggered when the user arrives at the destination geofence.
  Future<void> arrive() async {
    _backgroundSubscription?.cancel();
    _backgroundSubscription = null;

    // Stop background service
    await ref.read(backgroundServiceProvider).stopService();

    // Clear location service targets
    ref.read(locationServiceProvider).clearTargetDestination();

    final destination = state.destination;
    final startTime = state.startTime;
    if (destination != null) {
      final tripRecord = Trip(
        id: 'arrived_${DateTime.now().millisecondsSinceEpoch}',
        destinationName: destination.name,
        latitude: destination.latitude,
        longitude: destination.longitude,
        radiusMeters: state.targetRadius,
        status: 'arrived',
        createdAt: startTime ?? DateTime.now(),
        durationMinutes: startTime != null ? DateTime.now().difference(startTime).inMinutes : 0,
      );
      await ref.read(tripHistoryProvider.notifier).addTrip(tripRecord);
    }

    // Update status to arrived
    state = state.copyWith(status: TripStatus.arrived);

    // Save arrived state to Hive (so it persists on restart)
    final storage = ref.read(localStorageServiceProvider);
    await storage.setActiveTripJson(jsonEncode(state.toJson()));
  }

  /// Dismisses the alarm, stops sound playback, and resets state to idle.
  Future<void> dismissAlarm() async {
    await ref.read(alarmServiceProvider).stopAlarm();

    // Clear saved trip
    final storage = ref.read(localStorageServiceProvider);
    await storage.setActiveTripJson(null);

    state = const TripState(status: TripStatus.idle);
  }

  /// Snoozes the alarm: stops sound, contracts warning radius by 50% (min 100m),
  /// restarts background tracking, and schedules a time-based fallback alarm.
  Future<void> snooze({required int minutes}) async {
    // 1. Stop current alarm sound
    await ref.read(alarmServiceProvider).stopAlarm();

    final destination = state.destination;
    if (destination == null) return;

    // 2. Contract the radius by 50% (clamped to a minimum of 100m)
    final newRadius = (state.targetRadius * 0.5).clamp(100.0, double.infinity);

    // 3. Update the state to active with the new radius and reset distance metrics
    final updatedState = state.copyWith(
      status: TripStatus.active,
      targetRadius: newRadius,
      remainingDistance: null,
      etaMinutes: null,
      lastLocationUpdate: DateTime.now(),
    );

    state = updatedState;

    // 4. Update persisted Hive state
    final storage = ref.read(localStorageServiceProvider);
    await storage.setActiveTripJson(jsonEncode(state.toJson()));

    // 5. Configure main location service target for adaptive polling
    ref.read(locationServiceProvider).setTargetDestination(
          latitude: destination.latitude,
          longitude: destination.longitude,
        );

    // 6. Start background tracking service
    await ref.read(backgroundServiceProvider).startService();

    // 7. Start listening to background updates
    _resumeBackgroundTracking(destination);

    // 8. Schedule the fallback alarm via AlarmService
    await ref.read(alarmServiceProvider).snoozeAlarm(minutes: minutes);
  }

  void _resumeBackgroundTracking(Destination destination) {
    _backgroundSubscription?.cancel();

    // Listen to updates broadcasted by background isolate
    _backgroundSubscription = ref
        .read(backgroundServiceProvider)
        .onSerializedUpdate
        .listen((event) {
      print("DEBUG: _resumeBackgroundTracking event received: $event");
      if (event.isNotEmpty) {
        final eventStatusStr = event['status'] as String?;
        if (eventStatusStr == 'arrived') {
          print("DEBUG: event status is arrived, calling arrive()");
          arrive();
          return;
        }

        if (state.status == TripStatus.active) {
          final remainingDist = (event['remainingDistance'] as num).toDouble();
          final eta = event['etaMinutes'] as int;
          final timestampStr = event['timestamp'] as String;

          print("DEBUG: updating state with remainingDistance: $remainingDist");
          state = state.copyWith(
            remainingDistance: remainingDist,
            etaMinutes: eta,
            lastLocationUpdate: DateTime.parse(timestampStr),
          );

          // Keep Hive persistent state updated
          final storage = ref.read(localStorageServiceProvider);
          storage.setActiveTripJson(jsonEncode(state.toJson()));
        }
      }
    });
  }
}
