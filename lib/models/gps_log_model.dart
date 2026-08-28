class GpsLog {
  final int? id;
  final int tripId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  GpsLog({
    this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId, // Use trip_id to match database schema
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GpsLog.fromMap(Map<String, dynamic> map) {
    return GpsLog(
      id: map['id']?.toInt(),
      tripId: map['trip_id']?.toInt() ?? 0, // Read from trip_id column
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  GpsLog copyWith({
    int? id,
    int? tripId,
    required double latitude,
    required double longitude,
    DateTime? timestamp,
  }) {
    return GpsLog(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      latitude: latitude,
      longitude: longitude ,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'GpsLog(id: $id, tripId: $tripId, latitude: $latitude, longitude: $longitude, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GpsLog &&
        other.id == id &&
        other.tripId == tripId &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tripId.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        timestamp.hashCode;
  }
}
