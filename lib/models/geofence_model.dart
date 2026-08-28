class GeofenceRegion {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isActive;

  const GeofenceRegion({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isActive = true,
  });
}

class GeofenceEvent {
  final String id;
  final String type; // enter / exit
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String description;

  const GeofenceEvent({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  factory GeofenceEvent.fromMap(Map<String, dynamic> map) {
    return GeofenceEvent(
      id: map['id'] as String,
      type: map['type'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      description: map['description'] as String,
    );
  }
}