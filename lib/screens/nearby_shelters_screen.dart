import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../database/repositories/rating_repository.dart';
import '../database/repositories/shelter_repository.dart';
import '../database/repositories/theft_report_repository.dart';
import '../models/shelter_model.dart';
import '../services/location_service.dart';
import '../services/shelter_safety_service.dart';
import '../widgets/nearby_shelter_card.dart';

class NearbySheltersScreen extends StatefulWidget {
  const NearbySheltersScreen({super.key});

  @override
  State<NearbySheltersScreen> createState() =>
      _NearbySheltersScreenState();
}

class _NearbySheltersScreenState
    extends State<NearbySheltersScreen> {
  late final ShelterRepository _shelterRepository;
  late final ShelterSafetyService _safetyService;

  List<ShelterModel> _shelters = [];
  Map<String, double> _distances = {};
  Map<String, double?> _safetyScores = {};

  bool _loading = true;
  bool _sortBySafety = false;
  String? _errorMessage;

  static const double _searchRadiusMeters = 5000;

  @override
  void initState() {
    super.initState();

    final db = DatabaseHelper();

    _shelterRepository = ShelterRepository(db);

    _safetyService = ShelterSafetyService(
      RatingRepository(db),
      TheftReportRepository(db),
    );

    _loadShelters();
  }

  Future<void> _loadShelters() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final position =
          await LocationService.getCurrentLocation();

      if (position == null) {
        throw Exception(
          'Impossibile ottenere la posizione GPS.',
        );
      }

      final shelters =
          await _shelterRepository.getShelters();

      final distances = {
        for (final shelter in shelters)
          shelter.id: LocationService.calculateDistance(
            position.latitude,
            position.longitude,
            shelter.latitude,
            shelter.longitude,
          ),
      };

      final nearby = shelters
          .where(
            (shelter) =>
                distances[shelter.id]! <=
                _searchRadiusMeters,
          )
          .toList();

      final safetyScores =
          await _safetyService.calculateSafetyScores(
        nearby,
      );

      _sortShelters(
        nearby,
        distances,
        safetyScores,
      );

      if (!mounted) return;

      setState(() {
        _shelters = nearby;
        _distances = distances;
        _safetyScores = safetyScores;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  void _sortShelters(
    List<ShelterModel> shelters,
    Map<String, double> distances,
    Map<String, double?> safetyScores,
  ) {
    shelters.sort(
      (a, b) {
        if (_sortBySafety) {
          final safetyA = safetyScores[a.id];
          final safetyB = safetyScores[b.id];

          if (safetyA == null && safetyB == null) {
            return 0;
          }

          if (safetyA == null) {
            return 1;
          }

          if (safetyB == null) {
            return -1;
          }

          return safetyB.compareTo(safetyA);
        }

        return (distances[a.id] ?? double.infinity)
            .compareTo(
          distances[b.id] ?? double.infinity,
        );
      },
    );
  }

  void _changeSort(bool bySafety) {
    setState(() {
      _sortBySafety = bySafety;

      _sortShelters(
        _shelters,
        _distances,
        _safetyScores,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rifugi vicini'),
        ),
        body: Center(
          child: Text(_errorMessage!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rifugi vicini'),
        actions: [
          PopupMenuButton<bool>(
            initialValue: _sortBySafety,
            onSelected: _changeSort,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: false,
                child: Text('Ordina per distanza'),
              ),
              PopupMenuItem(
                value: true,
                child: Text('Ordina per sicurezza'),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: _shelters.isEmpty
          ? const Center(
              child: Text(
                'Nessun rifugio trovato nelle vicinanze.',
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadShelters,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _shelters.length,
                itemBuilder: (context, index) {
                  final shelter = _shelters[index];

                  return NearbyShelterCard(
                    shelter: shelter,
                    distance:
                        _distances[shelter.id] ?? 0,
                    safetyScore:
                        _safetyScores[shelter.id],
                  );
                },
              ),
            ),
    );
  }
}