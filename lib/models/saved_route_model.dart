import 'dart:convert';

import 'geo_point_model.dart';

class SavedRouteModel {
  final String id;
  final GeoPointModel origin;
  final GeoPointModel destination;
  final List<GeoPointModel> geometry;
  final double distanceMeters;
  final double durationSeconds;
  final double cyclingCoveragePercentage;
  final double cyclingCoverageMeters;
  final double score;
  final int roadWorkCount;
  final DateTime savedAt;

  const SavedRouteModel({
    required this.id,
    required this.origin,
    required this.destination,
    required this.geometry,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.cyclingCoveragePercentage,
    required this.cyclingCoverageMeters,
    required this.score,
    required this.roadWorkCount,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'origin_latitude': origin.latitude,
      'origin_longitude': origin.longitude,
      'destination_latitude': destination.latitude,
      'destination_longitude': destination.longitude,
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'cycling_coverage_percentage':
          cyclingCoveragePercentage,
      'cycling_coverage_meters':
          cyclingCoverageMeters,
      'score': score,
      'road_work_count': roadWorkCount,
      'geometry': jsonEncode(
        geometry
            .map(
              (point) => {
                'latitude': point.latitude,
                'longitude': point.longitude,
              },
            )
            .toList(),
      ),
      'saved_at': savedAt.toIso8601String(),
    };
  }

  factory SavedRouteModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final geometryData =
        jsonDecode(map['geometry'] as String) as List<dynamic>;

    return SavedRouteModel(
      id: map['id'] as String,
      origin: GeoPointModel(
        latitude:
            (map['origin_latitude'] as num).toDouble(),
        longitude:
            (map['origin_longitude'] as num).toDouble(),
      ),
      destination: GeoPointModel(
        latitude:
            (map['destination_latitude'] as num).toDouble(),
        longitude:
            (map['destination_longitude'] as num).toDouble(),
      ),
      geometry: geometryData
          .whereType<Map<String, dynamic>>()
          .map(
            (point) => GeoPointModel(
              latitude:
                  (point['latitude'] as num).toDouble(),
              longitude:
                  (point['longitude'] as num).toDouble(),
            ),
          )
          .toList(),
      distanceMeters:
          (map['distance_meters'] as num).toDouble(),
      durationSeconds:
          (map['duration_seconds'] as num).toDouble(),
      cyclingCoveragePercentage:
          (map['cycling_coverage_percentage'] as num)
              .toDouble(),
      cyclingCoverageMeters:
          (map['cycling_coverage_meters'] as num)
              .toDouble(),
      score:
          (map['score'] as num).toDouble(),
      roadWorkCount:
          (map['road_work_count'] as num).toInt(),
      savedAt: DateTime.parse(
        map['saved_at'] as String,
      ),
    );
  }
}