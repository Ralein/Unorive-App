import 'package:alarm/alarm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unorive/features/settings/settings_provider.dart';

part 'alarm_service.g.dart';

@riverpod
AlarmService alarmService(Ref ref) {
  return AlarmServiceImpl(ref);
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

/// Concrete implementation of [AlarmService] using the `alarm` package.
class AlarmServiceImpl implements AlarmService {
  AlarmServiceImpl(this._ref);

  final Ref _ref;
  static const int _alarmId = 42;

  @override
  Future<bool> triggerAlarm({
    required double lat,
    required double lng,
    required String destinationName,
    String? soundPath,
  }) async {
    final chosenSound = soundPath ?? _ref.read(settingsNotifierProvider).alarmSound;

    final alarmSettings = AlarmSettings(
      id: _alarmId,
      dateTime: DateTime.now().add(const Duration(seconds: 1)),
      assetAudioPath: chosenSound,
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: true,
      volumeSettings: const VolumeSettings.fixed(
        volume: 1.0,
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: 'You have arrived!',
        body: 'You entered the warning radius of $destinationName.',
      ),
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
      final hasAlarm = await Alarm.hasAlarm();
      if (!hasAlarm) return;

      // Stop current alarm
      await stopAlarm();

      final chosenSound = _ref.read(settingsNotifierProvider).alarmSound;

      // Schedule new alarm in the future
      final snoozeSettings = AlarmSettings(
        id: _alarmId,
        dateTime: DateTime.now().add(Duration(minutes: minutes)),
        assetAudioPath: chosenSound,
        loopAudio: true,
        vibrate: true,
        warningNotificationOnKill: true,
        volumeSettings: const VolumeSettings.fixed(
          volume: 1.0,
          volumeEnforced: true,
        ),
        notificationSettings: const NotificationSettings(
          title: 'You have arrived! (Snoozed)',
          body: 'Snoozed alarm has triggered.',
        ),
      );
      await Alarm.set(alarmSettings: snoozeSettings);
    } catch (_) {
      // Silent recovery
    }
  }
}
