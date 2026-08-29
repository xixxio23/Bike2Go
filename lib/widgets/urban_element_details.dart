import 'package:flutter/material.dart';

import '../models/cycling_path_model.dart';
import '../models/shelter_model.dart';
import '../models/road_work_model.dart';

class UrbanElementDetails extends StatelessWidget {
  final CyclingPathModel? cyclingPath;
  final ShelterModel? shelter;
  final RoadWorkModel? roadWork;

  const UrbanElementDetails({
    super.key,
    this.cyclingPath,
    this.shelter,
    this.roadWork,
  });

  @override
  Widget build(BuildContext context) {
    if (cyclingPath != null) {
      return _buildCyclingPathDetails();
    }

    if (shelter != null) {
      return _buildShelterDetails();
    }

    if (roadWork != null) {
      return _buildRoadWorkDetails();
    }

    return const SizedBox.shrink();
  }

  Widget _buildCyclingPathDetails() {
    final path = cyclingPath!;

    return _details(
      title: 'Pista ciclabile',
      children: [
        _row('Codice', path.codice.toString()),
        if (path.year != null) _row('Anno', path.year!),
        if (path.length != null)
          _row('Lunghezza', '${path.length} m'),
        if (path.use != null) _row('Uso', path.use!),
        if (path.type != null) _row('Tipologia', path.type!),
        if (path.fid != null) _row('FID', path.fid!),
      ],
    );
  }

  Widget _buildShelterDetails() {
    final shelter = this.shelter!;

    return _details(
      title: 'Rastrelliera',
      children: [
        _row('ID', shelter.id),
        if (shelter.streetName != null)
          _row('Via', shelter.streetName!),
        if (shelter.streetNumber != null)
          _row('Civico', shelter.streetNumber!),
        if (shelter.capacity != null)
          _row('Posti', shelter.capacity.toString()),
      ],
    );
  }

  Widget _buildRoadWorkDetails() {
    final work = roadWork!;

    return _details(
      title: 'Lavori pubblici',
      children: [
        _row('Indirizzo', work.address),
        _row('Quartiere', work.neighborhood),
        _row('Stato', work.status),
        _row(
          'Inizio',
          _formatDate(work.startDate),
        ),
        _row(
          'Fine',
          _formatDate(work.endDate),
        ),
        _row(
          'Modifica traffico',
          work.trafficChangesMeasure,
        ),
        _row('Descrizione', work.description),
        _row(
          'Note',
          work.visualizationNotes,
        ),
      ],
    );
  }

  Widget _details({
    required String title,
    required List<Widget> children,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
