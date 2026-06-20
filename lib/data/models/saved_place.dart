/// Represents a user's saved favorite location (e.g. Home, Work).
class SavedPlace {
  const SavedPlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.iconName,
    required this.createdAt,
  });

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      iconName: json['iconName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String iconName;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'iconName': iconName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
