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
  @override
  Future<bool> triggerAlarm({
    required double lat,
    required double lng,
    required String destinationName,
    String? soundPath,
  }) async {
    // Stub implementation, will integrate the `alarm` package in Phase 6
    return true;
  }

  @override
  Future<bool> stopAlarm() async {
    return true;
  }

  @override
  Future<void> snoozeAlarm({required int minutes}) async {
    // Stub implementation
  }
}
