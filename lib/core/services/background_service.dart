import 'dart:async';
import 'dart:convert';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unorive/core/services/alarm_service.dart';
import 'package:unorive/core/services/geofence_service.dart';

part 'background_service.g.dart';

@riverpod
BackgroundService backgroundService(Ref ref) {
  return BackgroundServiceImpl();
}

/// Abstract interface for controlling the background execution service.
abstract class BackgroundService {
  /// Start the background service.
  Future<bool> startService();

  /// Stop the background service.
  Future<void> stopService();

  /// Check if the service is currently running.
  Future<bool> isServiceRunning();

  /// Update the status message in the persistent notification.
  void updateNotificationData(String title, String body);

  /// Stream of status updates from the background isolate.
  Stream<Map<String, dynamic>> get onSerializedUpdate;
}

/// Concrete implementation of [BackgroundService] using `flutter_background_service`.
class BackgroundServiceImpl implements BackgroundService {
  BackgroundServiceImpl();

  @override
  Future<bool> startService() async {
    final service = FlutterBackgroundService();
    return await service.startService();
  }

  @override
  Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }

  @override
  Future<bool> isServiceRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }

  @override
  void updateNotificationData(String title, String body) {
    final service = FlutterBackgroundService();
    service.invoke('updateNotification', {'title': title, 'body': body});
  }

  @override
  Stream<Map<String, dynamic>> get onSerializedUpdate {
    return FlutterBackgroundService()
        .on('update')
        .map((event) => event != null ? Map<String, dynamic>.from(event) : const <String, dynamic>{});
  }
}

/// Top-level background isolate initialization for flutter_background_service.
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'unorive_tracking_channel',
    'Unorive Active Tracking',
    description: 'Displays active trip tracking alerts and distance to destination.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'unorive_tracking_channel',
      initialNotificationTitle: 'Unorive Active Trip',
      initialNotificationContent: 'Initializing location tracking...',
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

/// Isolate entry point executed in the background.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive in background isolate
  await Hive.initFlutter();
  final settingsBox = await Hive.openBox<dynamic>('settings_box');

  // Initialize Alarm in background isolate
  try {
    await Alarm.init();
  } catch (_) {}

  StreamSubscription<Position>? positionSubscription;
  Timer? backupTimer;
  final List<double> recentDistances = [];
  final geofenceService = GeofenceServiceImpl();
  final alarmService = AlarmServiceImpl();

  // Helper function to trigger arrival
  Future<void> triggerArrival(double distance, double lat, double lng, String destName, Map<String, dynamic> tripMap) async {
    positionSubscription?.cancel();
    backupTimer?.cancel();

    // Sound alarm
    await alarmService.triggerAlarm(
      lat: lat,
      lng: lng,
      destinationName: destName,
    );

    // Update persistent state to arrived
    tripMap['status'] = 'arrived';
    tripMap['remainingDistance'] = distance;
    tripMap['etaMinutes'] = 0;
    tripMap['lastLocationUpdate'] = DateTime.now().toIso8601String();
    await settingsBox.put('active_trip_json', jsonEncode(tripMap));

    // Send update to main UI isolate
    service.invoke('update', {
      'status': 'arrived',
      'latitude': lat,
      'longitude': lng,
      'remainingDistance': distance,
      'etaMinutes': 0,
      'timestamp': DateTime.now().toIso8601String(),
    });

    service.stopSelf();
  }

  // Listen to UI cancellation commands
  service.on('stopService').listen((event) {
    positionSubscription?.cancel();
    backupTimer?.cancel();
    service.stopSelf();
  });

  // Track position updates
  positionSubscription = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  ).listen((Position pos) async {
    // Read current active trip from Hive
    final tripJson = settingsBox.get('active_trip_json') as String?;
    if (tripJson == null) {
      positionSubscription?.cancel();
      backupTimer?.cancel();
      service.stopSelf();
      return;
    }

    try {
      final tripMap = jsonDecode(tripJson) as Map<String, dynamic>;
      if (tripMap['status'] != 'active') return;

      final destMap = tripMap['destination'] as Map<String, dynamic>;
      final destName = destMap['name'] as String;
      final destLat = destMap['latitude'] as double;
      final destLng = destMap['longitude'] as double;
      final targetRadius = (tripMap['targetRadius'] as num? ?? 800.0).toDouble();

      final distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        destLat,
        destLng,
      );

      final shouldTrigger = geofenceService.evaluate(
        distance: distance,
        radius: targetRadius,
        accuracy: pos.accuracy,
        recentDistances: recentDistances,
      );

      // Keep rolling history of last 5 distances
      recentDistances.add(distance);
      if (recentDistances.length > 5) {
        recentDistances.removeAt(0);
      }

      if (shouldTrigger) {
        await triggerArrival(distance, pos.latitude, pos.longitude, destName, tripMap);
        return;
      }

      // Average commuting speed approximation: 11 m/s (40 km/h)
      final etaSeconds = distance / 11.0;
      final etaMinutes = (etaSeconds / 60).round();

      final distanceStr = distance >= 1000
          ? '${(distance / 1000).toStringAsFixed(1)} km'
          : '${distance.round()} m';

      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: 'Tracking trip to $destName',
            content: '$distanceStr remaining • ETA: $etaMinutes mins',
          );
        }
      }

      // Propagate geolocated updates to main isolate UI via background channel
      service.invoke('update', {
        'status': 'active',
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'remainingDistance': distance,
        'etaMinutes': etaMinutes,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Graceful error recovery
    }
  }, onError: (Object err) {
    // Graceful stream error recovery
  });

  // Redundant Backup check timer (runs every 15s)
  backupTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
    final tripJson = settingsBox.get('active_trip_json') as String?;
    if (tripJson == null) {
      timer.cancel();
      return;
    }

    try {
      final tripMap = jsonDecode(tripJson) as Map<String, dynamic>;
      if (tripMap['status'] != 'active') return;

      final destMap = tripMap['destination'] as Map<String, dynamic>;
      final destName = destMap['name'] as String;
      final destLat = destMap['latitude'] as double;
      final destLng = destMap['longitude'] as double;
      final targetRadius = (tripMap['targetRadius'] as num? ?? 800.0).toDouble();

      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        // Check if the last known position is fresh (less than 60 seconds old)
        final timeDiff = DateTime.now().difference(pos.timestamp);
        if (timeDiff.inSeconds < 60) {
          final distance = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            destLat,
            destLng,
          );

          final shouldTrigger = geofenceService.evaluate(
            distance: distance,
            radius: targetRadius,
            accuracy: pos.accuracy,
            recentDistances: recentDistances,
          );

          if (shouldTrigger) {
            await triggerArrival(distance, pos.latitude, pos.longitude, destName, tripMap);
          }
        }
      }
    } catch (_) {}
  });
}

/// iOS background task handler.
@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}
