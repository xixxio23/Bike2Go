import 'package:flutter/material.dart';

import '../models/cycling_route_model.dart';

class RouteResultCard extends StatelessWidget {
  final CyclingRouteModel route;
  final bool recommended;

  const RouteResultCard({
    super.key,
    required this.route,
    this.recommended = false,
  });

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }

    return '${meters.round()} m';
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).round();

    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    return '${hours}h ${remainingMinutes}min';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  recommended ? Icons.star : Icons.route,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommended
                        ? 'Percorso consigliato'
                        : 'Percorso alternativo',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Score ${route.score.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.straighten,
                    label: 'Distanza',
                    value: _formatDistance(
                      route.distanceMeters,
                    ),
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.timer,
                    label: 'Durata',
                    value: _formatDuration(
                      route.durationSeconds,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoItem(
              icon: Icons.pedal_bike,
              label: 'Copertura ciclabile',
              value:
                  '${route.cyclingCoveragePercentage.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 8),
            _InfoItem(
              icon: Icons.route,
              label: 'Infrastruttura ciclabile',
              value: _formatDistance(
                route.cyclingCoverageMeters,
              ),
            ),
            const SizedBox(height: 8),
            _InfoItem(
              icon: Icons.construction,
              label: 'Lavori stradali',
              value: '${route.roadWorkCount}',
            ),
            if (recommended) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Percorso consigliato in base allo score '
                        'calcolato considerando il 60% della '
                        'copertura ciclabile, il 40% della distanza '
                        'e una penalità per i lavori stradali.',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}