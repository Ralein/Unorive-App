import 'package:hive_flutter/hive_flutter.dart';

/// Abstract interface for local persistent key-value storage.
abstract class LocalStorageService {
  /// Initializes the local database and opens required boxes.
  Future<void> initialize();

  /// Gets the onboarding completion status.
  bool getHasCompletedOnboarding();

  /// Sets the onboarding completion status.
  Future<void> setHasCompletedOnboarding({required bool completed});

  /// Gets whether guest mode is active.
  bool getIsGuestMode();

  /// Sets whether guest mode is active.
  Future<void> setIsGuestMode({required bool isGuest});

  /// Gets the active trip serialized JSON string.
  String? getActiveTripJson();

  /// Sets the active trip serialized JSON string.
  Future<void> setActiveTripJson(String? json);

  /// Clears all local settings.
  Future<void> clear();
}

/// Concrete implementation of [LocalStorageService] using Hive.
class LocalStorageServiceImpl implements LocalStorageService {
  LocalStorageServiceImpl();

  static const String _settingsBoxName = 'settings_box';
  static const String _keyOnboarding = 'has_completed_onboarding';
  static const String _keyGuestMode = 'is_guest_mode';

  late Box<dynamic> _settingsBox;

  @override
  Future<void> initialize() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
  }

  @override
  bool getHasCompletedOnboarding() {
    return _settingsBox.get(_keyOnboarding, defaultValue: false) as bool;
  }

  @override
  Future<void> setHasCompletedOnboarding({required bool completed}) async {
    await _settingsBox.put(_keyOnboarding, completed);
  }

  @override
  bool getIsGuestMode() {
    return _settingsBox.get(_keyGuestMode, defaultValue: false) as bool;
  }

  @override
  Future<void> setIsGuestMode({required bool isGuest}) async {
    await _settingsBox.put(_keyGuestMode, isGuest);
  }

  @override
  String? getActiveTripJson() {
    return _settingsBox.get('active_trip_json') as String?;
  }

  @override
  Future<void> setActiveTripJson(String? json) async {
    if (json == null) {
      await _settingsBox.delete('active_trip_json');
    } else {
      await _settingsBox.put('active_trip_json', json);
    }
  }

  @override
  Future<void> clear() async {
    await _settingsBox.clear();
  }
}
