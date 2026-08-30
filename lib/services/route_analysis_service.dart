import 'dart:math' as math;

import '../models/cycling_path_model.dart';
import '../models/cycling_route_model.dart';
import '../models/geo_point_model.dart';
import '../models/road_work_model.dart';
import 'route_planner_service.dart';

class RouteAnalysisService {
  final double coverageToleranceMeters;
  final double roadWorkToleranceMeters;

  const RouteAnalysisService({
    this.coverageToleranceMeters = 25,
    this.roadWorkToleranceMeters = 40,
  });

  CyclingRouteModel analyzeRoute({
    required String id,
    required RouteCandidate route,
    required List<CyclingPathModel> cyclingPaths,
    required List<RoadWorkModel> roadWorks,
  }) {
    final coverage = _calculateCyclingCoverage(
      route.geometry,
      cyclingPaths,
    );

    final roadWorkCount = _countRoadWorks(
      route.geometry,
      roadWorks,
    );

    final score = _calculateScore(
      distanceMeters: route.distanceMeters,
      coveragePercentage: coverage.percentage,
      roadWorkCount: roadWorkCount,
    );

    return CyclingRouteModel(
      id: id,
      geometry: route.geometry,
      distanceMeters: route.distanceMeters,
      durationSeconds: route.durationSeconds,
      cyclingCoveragePercentage: coverage.percentage,
      cyclingCoverageMeters: coverage.meters,
      score: score,
      roadWorkCount: roadWorkCount,
    );
  }

  _CoverageResult _calculateCyclingCoverage(
    List<GeoPointModel> route,
    List<CyclingPathModel> cyclingPaths,
  ) {
    if (route.length < 2 || cyclingPaths.isEmpty) {
      return const _CoverageResult(
        meters: 0,
        percentage: 0,
      );
    }

    var coveredMeters = 0.0;
    var totalMeters = 0.0;

    for (var i = 0; i < route.length - 1; i++) {
      final start = route[i];
      final end = route[i + 1];

      final segmentLength = _distanceBetween(start, end);

      if (segmentLength <= 0) {
        continue;
      }

      totalMeters += segmentLength;

      final midpoint = GeoPointModel(
        latitude: (start.latitude + end.latitude) / 2,
        longitude: (start.longitude + end.longitude) / 2,
      );

      if (_isCoveredByCyclingPath(
        midpoint,
        cyclingPaths,
      )) {
        coveredMeters += segmentLength;
      }
    }

    if (totalMeters == 0) {
      return const _CoverageResult(
        meters: 0,
        percentage: 0,
      );
    }

    final percentage =
        (coveredMeters / totalMeters * 100).clamp(0.0, 100.0);

    return _CoverageResult(
      meters: coveredMeters,
      percentage: percentage,
    );
  }

  bool _isCoveredByCyclingPath(
    GeoPointModel point,
    List<CyclingPathModel> cyclingPaths,
  ) {
    for (final path in cyclingPaths) {
      for (final line in path.geometry) {
        for (var i = 0; i < line.length - 1; i++) {
          final distance = _distancePointToSegment(
            point,
            line[i],
            line[i + 1],
          );

          if (distance <= coverageToleranceMeters) {
            return true;
          }
        }
      }
    }

    return false;
  }

  int _countRoadWorks(
    List<GeoPointModel> route,
    List<RoadWorkModel> roadWorks,
  ) {
    if (route.isEmpty || roadWorks.isEmpty) {
      return 0;
    }

    var count = 0;

    for (final roadWork in roadWorks) {
      final point = GeoPointModel(
        latitude: roadWork.latitude,
        longitude: roadWork.longitude,
      );

      if (_isPointNearRoute(point, route)) {
        count++;
      }
    }

    return count;
  }

  bool _isPointNearRoute(
    GeoPointModel point,
    List<GeoPointModel> route,
  ) {
    for (var i = 0; i < route.length - 1; i++) {
      final distance = _distancePointToSegment(
        point,
        route[i],
        route[i + 1],
      );

      if (distance <= roadWorkToleranceMeters) {
        return true;
      }
    }

    return false;
  }

  double _calculateScore({
    required double distanceMeters,
    required double coveragePercentage,
    required int roadWorkCount,
  }) {
    final coverageScore = coveragePercentage;

    final distanceScore =
        100 * math.exp(-distanceMeters / 5000);

    final roadWorkPenalty =
        roadWorkCount * 10.0;

    final score =
        (coverageScore * 0.6) +
        (distanceScore * 0.4) -
        roadWorkPenalty;

    return score.clamp(0.0, 100.0);
  }

  double _distanceBetween(
    GeoPointModel a,
    GeoPointModel b,
  ) {
    const earthRadius = 6371000.0;

    final lat1 = _toRadians(a.latitude);
    final lat2 = _toRadians(b.latitude);
    final deltaLat =
        _toRadians(b.latitude - a.latitude);
    final deltaLon =
        _toRadians(b.longitude - a.longitude);

    final h =
        math.sin(deltaLat / 2) *
            math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);

    return 2 *
        earthRadius *
        math.atan2(
          math.sqrt(h),
          math.sqrt(1 - h),
        );
  }

  double _distancePointToSegment(
    GeoPointModel point,
    GeoPointModel start,
    GeoPointModel end,
  ) {
    final latitude =
        _toRadians(point.latitude);

    final scale =
        math.cos(latitude);

    final pointX =
        _toRadians(point.longitude) *
        scale *
        6371000;

    final pointY =
        _toRadians(point.latitude) *
        6371000;

    final startX =
        _toRadians(start.longitude) *
        scale *
        6371000;

    final startY =
        _toRadians(start.latitude) *
        6371000;

    final endX =
        _toRadians(end.longitude) *
        scale *
        6371000;

    final endY =
        _toRadians(end.latitude) *
        6371000;

    final dx = endX - startX;
    final dy = endY - startY;

    if (dx == 0 && dy == 0) {
      return math.sqrt(
        math.pow(pointX - startX, 2) +
            math.pow(pointY - startY, 2),
      );
    }

    final t = ((pointX - startX) * dx +
            (pointY - startY) * dy) /
        (dx * dx + dy * dy);

    final clampedT = t.clamp(0.0, 1.0);

    final closestX =
        startX + clampedT * dx;
    final closestY =
        startY + clampedT * dy;

    return math.sqrt(
      math.pow(pointX - closestX, 2) +
          math.pow(pointY - closestY, 2),
    );
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}

class _CoverageResult {
  final double meters;
  final double percentage;

  const _CoverageResult({
    required this.meters,
    required this.percentage,
  });
}