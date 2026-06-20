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
}

/// Concrete implementation of [BackgroundService] using `flutter_background_service`.
class BackgroundServiceImpl implements BackgroundService {
  @override
  Future<bool> startService() async {
    // Stub implementation
    return false;
  }

  @override
  Future<void> stopService() async {
    // Stub implementation
  }

  @override
  Future<bool> isServiceRunning() async {
    return false;
  }

  @override
  void updateNotificationData(String title, String body) {
    // Stub implementation
  }
}
