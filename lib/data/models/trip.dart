/// Represents a user's trip to a location-based destination.
class Trip {
  const Trip({
    required this.id,
    required this.destinationName,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.status,
    required this.createdAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      destinationName: json['destinationName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String destinationName;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String status; // 'idle', 'active', 'arrived', 'cancelled'
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinationName': destinationName,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
