class ShelterModel {
  final String id;
  final double latitude;
  final double longitude;
  final String? streetName;
  final String? streetNumber;
  final int? capacity;

  const ShelterModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.streetName,
    this.streetNumber,
    this.capacity,
  });

  factory ShelterModel.fromMap(Map<String, dynamic> map) {
    final geoPoint = map['geo_point_2d'] as Map<String, dynamic>?;

    return ShelterModel(
      id: map['id'].toString(),

      latitude: (geoPoint?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (geoPoint?['lon'] as num?)?.toDouble() ?? 0.0,

      streetName: map['nomevia'] as String?,
      streetNumber: map['civico']?.toString(),
      capacity: (map['numposti'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'street_name': streetName,
      'street_number': streetNumber,
      'capacity': capacity,
    };
  }
}
