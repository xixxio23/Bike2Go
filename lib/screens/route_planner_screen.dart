import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../database/repositories/cycling_path_repository.dart';
import '../database/repositories/road_work_repository.dart';
import '../database/repositories/saved_route_repository.dart';
import '../models/cycling_path_model.dart';
import '../models/cycling_route_model.dart';
import '../models/geo_point_model.dart';
import '../models/road_work_model.dart';
import '../models/saved_route_model.dart';
import '../services/route_planner_service.dart';
import '../widgets/route_map.dart';
import '../widgets/route_result_card.dart';
import '../widgets/route_search_form.dart';
import 'saved_routes_screen.dart';

class RoutePlannerScreen extends StatefulWidget {
  final String apiKey;

  const RoutePlannerScreen({
    super.key,
    required this.apiKey,
  });

  @override
  State<RoutePlannerScreen> createState() =>
      _RoutePlannerScreenState();
}

class _RoutePlannerScreenState
    extends State<RoutePlannerScreen> {
  late final CyclingPathRepository _cyclingPathRepository;
  late final RoadWorkRepository _roadWorkRepository;
  late final SavedRouteRepository _savedRouteRepository;
  late final RoutePlannerService _routePlannerService;

  List<CyclingPathModel> _cyclingPaths = [];
  List<RoadWorkModel> _roadWorks = [];
  List<CyclingRouteModel> _routes = [];

  CyclingRouteModel? _recommendedRoute;

  GeoPointModel? _origin;
  GeoPointModel? _destination;

  bool _loading = false;
  bool _dataLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    final database = DatabaseHelper();

    _cyclingPathRepository =
        CyclingPathRepository(database);

    _roadWorkRepository =
        RoadWorkRepository(database);

    _savedRouteRepository =
        SavedRouteRepository(database);

    _routePlannerService = RoutePlannerService(
      apiKey: widget.apiKey,
    );

    _loadAnalysisData();
  }

  Future<void> _loadAnalysisData() async {
    try {
      final results = await Future.wait([
        _cyclingPathRepository.getCyclingPaths(),
        _roadWorkRepository.getRoadWorks(),
      ]);

      if (!mounted) return;

      setState(() {
        _cyclingPaths =
            results[0] as List<CyclingPathModel>;
        _roadWorks =
            results[1] as List<RoadWorkModel>;
        _dataLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _dataLoading = false;
        _error =
            'Errore nel caricamento dei dati:\n$e';
      });
    }
  }

  Future<void> _calculateRoutes(
    GeoPointModel origin,
    GeoPointModel destination,
  ) async {
    if (_dataLoading) return;

    setState(() {
      _loading = true;
      _error = null;
      _routes = [];
      _recommendedRoute = null;
      _origin = origin;
      _destination = destination;
    });

    try {
      final routes =
          await _routePlannerService.getRoutes(
        origin: origin,
        destination: destination,
        cyclingPaths: _cyclingPaths,
        roadWorks: _roadWorks,
      );

      if (routes.isEmpty) {
        throw Exception(
          'OpenRouteService non ha restituito '
          'alcun percorso.',
        );
      }

      routes.sort(
        (a, b) => b.score.compareTo(a.score),
      );

      final recommended = routes.first;

      if (!mounted) return;

      setState(() {
        _routes = routes;
        _recommendedRoute = recommended;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _saveRoute(
    CyclingRouteModel route,
  ) async {
    if (_origin == null || _destination == null) {
      return;
    }

    final savedRoute = SavedRouteModel(
      id: '${DateTime.now().millisecondsSinceEpoch}_${route.id}',
      origin: _origin!,
      destination: _destination!,
      geometry: route.geometry,
      distanceMeters: route.distanceMeters,
      durationSeconds: route.durationSeconds,
      cyclingCoveragePercentage:
          route.cyclingCoveragePercentage,
      cyclingCoverageMeters:
          route.cyclingCoverageMeters,
      score: route.score,
      roadWorkCount: route.roadWorkCount,
      savedAt: DateTime.now(),
    );

    try {
      await _savedRouteRepository.insertSavedRoute(
        savedRoute,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Percorso salvato'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Errore nel salvataggio del percorso: $e',
          ),
        ),
      );
    }
  }

  void _openSavedRoutes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SavedRoutesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Cronologia percorsi',
            onPressed: _openSavedRoutes,
          ),
        ],
      ),
      body: Column(
        children: [
          RouteSearchForm(
            onSearch: _calculateRoutes,
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_dataLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Calcolo dei percorsi...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_origin == null ||
        _destination == null ||
        _routes.isEmpty) {
      return const Center(
        child: Text(
          'Inserisci partenza e destinazione '
          'per calcolare un percorso.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: RouteMap(
            origin: _origin!,
            destination: _destination!,
            routes: _routes,
            recommendedRoute: _recommendedRoute,
          ),
        ),
        Expanded(
          flex: 2,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4),
            itemCount: _routes.length,
            itemBuilder: (context, index) {
              final route = _routes[index];

              return Column(
                children: [
                  RouteResultCard(
                    route: route,
                    recommended:
                        route.id == _recommendedRoute?.id,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _saveRoute(route),
                        icon: const Icon(Icons.bookmark_border),
                        label: const Text('Salva percorso'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}