/// Configurations for location-alarm trigger profiles.
class AlarmConfig {
  const AlarmConfig({
    required this.defaultRadiusMeters,
    required this.soundName,
    required this.vibrate,
    required this.volume,
  });

  factory AlarmConfig.fromJson(Map<String, dynamic> json) {
    return AlarmConfig(
      defaultRadiusMeters: (json['defaultRadiusMeters'] as num).toDouble(),
      soundName: json['soundName'] as String,
      vibrate: json['vibrate'] as bool,
      volume: (json['volume'] as num).toDouble(),
    );
  }

  final double defaultRadiusMeters;
  final String soundName;
  final bool vibrate;
  final double volume; // Range: 0.0 to 1.0

  Map<String, dynamic> toJson() {
    return {
      'defaultRadiusMeters': defaultRadiusMeters,
      'soundName': soundName,
      'vibrate': vibrate,
      'volume': volume,
    };
  }
}
