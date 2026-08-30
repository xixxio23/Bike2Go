import 'package:flutter/material.dart';

import '../models/cycling_route_model.dart';
import '../models/saved_route_model.dart';
import '../widgets/route_map.dart';

class SavedRouteMapScreen extends StatelessWidget {
  final SavedRouteModel route;

  const SavedRouteMapScreen({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final cyclingRoute = CyclingRouteModel(
      id: route.id,
      geometry: route.geometry,
      distanceMeters: route.distanceMeters,
      durationSeconds: route.durationSeconds,
      cyclingCoveragePercentage:
          route.cyclingCoveragePercentage,
      cyclingCoverageMeters:
          route.cyclingCoverageMeters,
      score: route.score,
      roadWorkCount: route.roadWorkCount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Percorso salvato'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RouteMap(
              origin: route.origin,
              destination: route.destination,
              routes: [cyclingRoute],
              recommendedRoute: cyclingRoute,
            ),
          ),
          _RouteInfo(route: route),
        ],
      ),
    );
  }
}

class _RouteInfo extends StatelessWidget {
  final SavedRouteModel route;

  const _RouteInfo({
    required this.route,
  });

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }

    return '${meters.round()} m';
  }

  String _formatDuration(double seconds) {
    final duration = Duration(
      seconds: seconds.round(),
    );

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }

    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: [
            _Info(
              icon: Icons.straighten,
              value: _formatDistance(
                route.distanceMeters,
              ),
            ),
            _Info(
              icon: Icons.timer_outlined,
              value: _formatDuration(
                route.durationSeconds,
              ),
            ),
            _Info(
              icon: Icons.star_outline,
              value: route.score.toStringAsFixed(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String value;

  const _Info({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}