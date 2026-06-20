import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationServiceImpl();
}

/// Abstract interface for managing local notifications and deep-link routing intents.
abstract class NotificationService {
  /// Initializes the notification service and sets up handlers for taps.
  Future<void> initialize();

  /// Shows an instant high-priority alert notification.
  Future<void> showAlarmNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  /// Shows or updates a persistent service tracking notification.
  Future<void> showPersistentTrackingNotification({
    required String title,
    required String body,
  });

  /// Clears notifications.
  Future<void> cancelNotification(int id);
}

/// Concrete implementation of [NotificationService] using flutter_local_notifications.
class NotificationServiceImpl implements NotificationService {
  @override
  Future<void> initialize() async {
    // Stub implementation
  }

  @override
  Future<void> showAlarmNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Stub implementation
  }

  @override
  Future<void> showPersistentTrackingNotification({
    required String title,
    required String body,
  }) async {
    // Stub implementation
  }

  @override
  Future<void> cancelNotification(int id) async {
    // Stub implementation
  }
}
