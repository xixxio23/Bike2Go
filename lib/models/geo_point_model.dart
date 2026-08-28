class GeoPointModel {
  final double latitude;
  final double longitude;

  const GeoPointModel({
    required this.latitude,
    required this.longitude,
  });

  factory GeoPointModel.fromJson(List<dynamic> coordinates) {
    return GeoPointModel(
      longitude: (coordinates[0] as num).toDouble(),
      latitude: (coordinates[1] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
