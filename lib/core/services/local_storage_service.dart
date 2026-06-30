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

  /// Gets all saved places as serialized JSON strings.
  List<String> getSavedPlacesJson();

  /// Saves a saved place serialized JSON string.
  Future<void> saveSavedPlaceJson(String id, String json);

  /// Deletes a saved place by ID.
  Future<void> deleteSavedPlace(String id);

  /// Gets all trip history records as serialized JSON strings.
  List<String> getTripHistoryJson();

  /// Saves a trip history record serialized JSON string.
  Future<void> saveTripHistoryJson(String id, String json);

  /// Deletes a trip history record by ID.
  Future<void> deleteTripHistory(String id);

  /// Gets preferred alarm sound asset path.
  String getAlarmSound();
  /// Sets preferred alarm sound asset path.
  Future<void> setAlarmSound(String sound);

  /// Gets default alert radius in meters.
  double getDefaultAlertRadius();
  /// Sets default alert radius in meters.
  Future<void> setDefaultAlertRadius(double radius);

  /// Gets preferred distance unit ('km' or 'mi').
  String getDistanceUnit();
  /// Sets preferred distance unit ('km' or 'mi').
  Future<void> setDistanceUnit(String unit);

  /// Gets preferred theme mode ('light', 'dark', 'system').
  String getThemeMode();
  /// Sets preferred theme mode ('light', 'dark', 'system').
  Future<void> setThemeMode(String mode);

  /// Clears all local settings.
  Future<void> clear();
}

/// Concrete implementation of [LocalStorageService] using Hive.
class LocalStorageServiceImpl implements LocalStorageService {
  LocalStorageServiceImpl();

  static const String _settingsBoxName = 'settings_box';
  static const String _savedPlacesBoxName = 'saved_places_box';
  static const String _tripHistoryBoxName = 'trip_history_box';

  static const String _keyOnboarding = 'has_completed_onboarding';
  static const String _keyGuestMode = 'is_guest_mode';
  
  static const String _keyAlarmSound = 'alarm_sound';
  static const String _keyDefaultRadius = 'default_alert_radius';
  static const String _keyDistanceUnit = 'distance_unit';
  static const String _keyThemeMode = 'theme_mode';

  late Box<dynamic> _settingsBox;
  late Box<dynamic> _savedPlacesBox;
  late Box<dynamic> _tripHistoryBox;

  @override
  Future<void> initialize() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
    _savedPlacesBox = await Hive.openBox<dynamic>(_savedPlacesBoxName);
    _tripHistoryBox = await Hive.openBox<dynamic>(_tripHistoryBoxName);
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
  List<String> getSavedPlacesJson() {
    return _savedPlacesBox.values.cast<String>().toList();
  }

  @override
  Future<void> saveSavedPlaceJson(String id, String json) async {
    await _savedPlacesBox.put(id, json);
  }

  @override
  Future<void> deleteSavedPlace(String id) async {
    await _savedPlacesBox.delete(id);
  }

  @override
  List<String> getTripHistoryJson() {
    return _tripHistoryBox.values.cast<String>().toList();
  }

  @override
  Future<void> saveTripHistoryJson(String id, String json) async {
    await _tripHistoryBox.put(id, json);
  }

  @override
  Future<void> deleteTripHistory(String id) async {
    await _tripHistoryBox.delete(id);
  }

  @override
  String getAlarmSound() {
    return _settingsBox.get(_keyAlarmSound, defaultValue: 'assets/sounds/alarm.wav') as String;
  }

  @override
  Future<void> setAlarmSound(String sound) async {
    await _settingsBox.put(_keyAlarmSound, sound);
  }

  @override
  double getDefaultAlertRadius() {
    return _settingsBox.get(_keyDefaultRadius, defaultValue: 500.0) as double;
  }

  @override
  Future<void> setDefaultAlertRadius(double radius) async {
    await _settingsBox.put(_keyDefaultRadius, radius);
  }

  @override
  String getDistanceUnit() {
    return _settingsBox.get(_keyDistanceUnit, defaultValue: 'km') as String;
  }

  @override
  Future<void> setDistanceUnit(String unit) async {
    await _settingsBox.put(_keyDistanceUnit, unit);
  }

  @override
  String getThemeMode() {
    return _settingsBox.get(_keyThemeMode, defaultValue: 'system') as String;
  }

  @override
  Future<void> setThemeMode(String mode) async {
    await _settingsBox.put(_keyThemeMode, mode);
  }

  @override
  Future<void> clear() async {
    await _settingsBox.clear();
    await _savedPlacesBox.clear();
    await _tripHistoryBox.clear();
  }
}
