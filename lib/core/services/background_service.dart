import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  StreamSubscription<Position>? positionSubscription;

  // Listen to UI cancellation commands
  service.on('stopService').listen((event) {
    positionSubscription?.cancel();
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
      service.stopSelf();
      return;
    }

    try {
      final tripMap = jsonDecode(tripJson) as Map<String, dynamic>;
      final destMap = tripMap['destination'] as Map<String, dynamic>;
      final destName = destMap['name'] as String;
      final destLat = destMap['latitude'] as double;
      final destLng = destMap['longitude'] as double;

      final distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        destLat,
        destLng,
      );

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
}

/// iOS background task handler.
@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}
