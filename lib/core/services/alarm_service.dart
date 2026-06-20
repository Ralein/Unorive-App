import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'alarm_service.g.dart';

@riverpod
AlarmService alarmService(Ref ref) {
  return AlarmServiceImpl();
}

/// Abstract interface for configuring, triggering, and dismissing alarms.
abstract class AlarmService {
  /// Schedules a full-volume, silent-mode-bypassing alarm.
  Future<bool> triggerAlarm({
    required double lat,
    required double lng,
    required String destinationName,
    String? soundPath,
  });

  /// Stops and clears all active alarms.
  Future<bool> stopAlarm();

  /// Snoozes the alarm for a duration (in minutes).
  Future<void> snoozeAlarm({required int minutes});
}

import 'package:alarm/alarm.dart';

/// Concrete implementation of [AlarmService] using the `alarm` package.
class AlarmServiceImpl implements AlarmService {
  static const int _alarmId = 42;

  @override
  Future<bool> triggerAlarm({
    required double lat,
    required double lng,
    required String destinationName,
    String? soundPath,
  }) async {
    final alarmSettings = AlarmSettings(
      id: _alarmId,
      dateTime: DateTime.now().add(const Duration(seconds: 1)),
      assetAudioPath: soundPath ?? 'assets/sounds/alarm.wav',
      loopAudio: true,
      vibrate: true,
      volume: 1.0,
      fadeDuration: const Duration(seconds: 3),
      notificationTitle: 'You have arrived!',
      notificationBody: 'You entered the warning radius of $destinationName.',
      enableNotificationOnKill: true,
    );

    try {
      return await Alarm.set(alarmSettings: alarmSettings);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> stopAlarm() async {
    try {
      return await Alarm.stop(_alarmId);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> snoozeAlarm({required int minutes}) async {
    try {
      // Find the existing alarm if active to copy destination/sound configurations
      final hasAlarm = Alarm.hasAlarm();
      if (!hasAlarm) return;

      // Stop current alarm
      await stopAlarm();

      // Schedule new alarm in the future
      final snoozeSettings = AlarmSettings(
        id: _alarmId,
        dateTime: DateTime.now().add(Duration(minutes: minutes)),
        assetAudioPath: 'assets/sounds/alarm.wav',
        loopAudio: true,
        vibrate: true,
        volume: 1.0,
        fadeDuration: const Duration(seconds: 3),
        notificationTitle: 'You have arrived! (Snoozed)',
        notificationBody: 'Snoozed alarm has triggered.',
        enableNotificationOnKill: true,
      );
      await Alarm.set(alarmSettings: snoozeSettings);
    } catch (_) {
      // Silent recovery
    }
  }
}
