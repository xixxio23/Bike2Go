import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cycling_path_model.dart';
import '../models/cycling_route_model.dart';
import '../models/geo_point_model.dart';
import '../models/road_work_model.dart';
import 'route_analysis_service.dart';

class RoutePlannerService {
  static const String _endpoint =
      'https://api.heigit.org/v2/directions/cycling-regular/geojson';

  final String apiKey;
  final RouteAnalysisService _analysisService;

  RoutePlannerService({
    required this.apiKey,
    RouteAnalysisService? analysisService,
  }) : _analysisService =
            analysisService ?? const RouteAnalysisService();

  Future<List<CyclingRouteModel>> getRoutes({
    required GeoPointModel origin,
    required GeoPointModel destination,
    required List<CyclingPathModel> cyclingPaths,
    required List<RoadWorkModel> roadWorks,
  }) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/geo+json',
        'Authorization': apiKey,
      },
      body: jsonEncode({
        'coordinates': [
          [
            origin.longitude,
            origin.latitude,
          ],
          [
            destination.longitude,
            destination.latitude,
          ],
        ],
        'instructions': false,
        'elevation': false,
        'alternative_routes': {
          'target_count': 3,
          'share_factor': 0.8,
          'weight_factor': 2,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Errore OpenRouteService '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final features =
        data['features'] as List<dynamic>? ?? [];

    final routes = <CyclingRouteModel>[];

    for (var i = 0; i < features.length; i++) {
      final feature = features[i];

      if (feature is! Map<String, dynamic>) {
        continue;
      }

      routes.add(
        _analyzeRoute(
          index: i,
          feature: feature,
          cyclingPaths: cyclingPaths,
          roadWorks: roadWorks,
        ),
      );
    }

    return routes;
  }

  CyclingRouteModel _analyzeRoute({
    required int index,
    required Map<String, dynamic> feature,
    required List<CyclingPathModel> cyclingPaths,
    required List<RoadWorkModel> roadWorks,
  }) {
    final geometryData =
        feature['geometry'] as Map<String, dynamic>?;

    final coordinates =
        geometryData?['coordinates'] as List<dynamic>?;

    if (coordinates == null || coordinates.isEmpty) {
      throw Exception(
        'OpenRouteService non ha restituito '
        'la geometria della route.',
      );
    }

    final geometry = coordinates
        .whereType<List<dynamic>>()
        .map(
          (point) => GeoPointModel(
            latitude: (point[1] as num).toDouble(),
            longitude: (point[0] as num).toDouble(),
          ),
        )
        .toList();

    if (geometry.length < 2) {
      throw Exception(
        'Geometria della route non valida.',
      );
    }

    final properties =
        feature['properties'] as Map<String, dynamic>?;

    final summary =
        properties?['summary'] as Map<String, dynamic>?;

    final distance =
        (summary?['distance'] as num?)?.toDouble() ?? 0;

    final duration =
        (summary?['duration'] as num?)?.toDouble() ?? 0;

    final candidate = RouteCandidate(
      distanceMeters: distance,
      durationSeconds: duration,
      geometry: geometry,
    );

    return _analysisService.analyzeRoute(
      id: 'route_$index',
      route: candidate,
      cyclingPaths: cyclingPaths,
      roadWorks: roadWorks,
    );
  }
}

class RouteCandidate {
  final double distanceMeters;
  final double durationSeconds;
  final List<GeoPointModel> geometry;

  const RouteCandidate({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.geometry,
  });
}