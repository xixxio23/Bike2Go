import 'geo_point_model.dart';

class CyclingRouteModel {
  final String id;
  final List<GeoPointModel> geometry;
  final double distanceMeters;
  final double durationSeconds;
  final double cyclingCoveragePercentage;
  final double cyclingCoverageMeters;
  final double score;
  final int roadWorkCount;
  final String? description;

  const CyclingRouteModel({
    required this.id,
    required this.geometry,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.cyclingCoveragePercentage,
    required this.cyclingCoverageMeters,
    required this.score,
    required this.roadWorkCount,
    this.description,
  });
}