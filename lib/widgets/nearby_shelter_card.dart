import 'package:flutter/material.dart';

import '../models/shelter_model.dart';
import '../services/location_service.dart';

class NearbyShelterCard extends StatelessWidget {
  final ShelterModel shelter;
  final double distance;
  final double? safetyScore;

  const NearbyShelterCard({
    super.key,
    required this.shelter,
    required this.distance,
    required this.safetyScore,
  });

  @override
  Widget build(BuildContext context) {
    final address = [
      shelter.streetName,
      shelter.streetNumber,
    ].where((value) => value != null && value.isNotEmpty).join(' ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.pedal_bike),
        ),
        title: Text(
          address.isEmpty ? 'Rastrelliera' : address,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'Distanza: ${LocationService.formatDistance(distance)}',
            ),
            if (shelter.capacity != null)
              Text(
                'Posti: ${shelter.capacity}',
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.shield,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  safetyScore == null
                      ? 'Sicurezza: ?'
                      : 'Sicurezza: '
                          '${safetyScore!.toStringAsFixed(0)}/100',
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}