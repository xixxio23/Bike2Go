import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/cycling_path_model.dart';
import '../models/shelter_model.dart';
import '../models/road_work_model.dart';
import '../services/urban_data_service.dart';

class UrbanMapScreen extends StatefulWidget {
  const UrbanMapScreen({super.key});

  @override
  State<UrbanMapScreen> createState() => _UrbanMapScreenState();
}

class _UrbanMapScreenState extends State<UrbanMapScreen> {
  late final UrbanDataService _urbanDataService;

  List<CyclingPathModel> _cyclingPaths = [];
  List<ShelterModel> _shelters = [];
  List<RoadWorkModel> _roadWorks = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _urbanDataService = UrbanDataService(
      DatabaseHelper(),
    );

    _loadUrbanData();
  }

  Future<void> _loadUrbanData() async {
    try {
      final cyclingPaths =
          await _urbanDataService.getCyclingPaths();

      final shelters =
          await _urbanDataService.getShelters();

      final roadWorks =
          await _urbanDataService.getRoadWorks();

      if (!mounted) return;

      setState(() {
        _cyclingPaths = cyclingPaths;
        _shelters = shelters;
        _roadWorks = roadWorks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urban Cycling Map'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Errore nel caricamento dei dati:\n$_error',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Center(
      child: Text(
        'Dati caricati\n'
        'Piste: ${_cyclingPaths.length}\n'
        'Rastrelliere: ${_shelters.length}\n'
        'Lavori: ${_roadWorks.length}',
        textAlign: TextAlign.center,
      ),
    );
  }
}
