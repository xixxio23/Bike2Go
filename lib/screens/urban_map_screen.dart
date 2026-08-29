import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../database/database_helper.dart';
import '../models/cycling_path_model.dart';
import '../models/shelter_model.dart';
import '../models/road_work_model.dart';
import '../services/urban_data_service.dart';
import '../services/location_service.dart';
import '../widgets/urban_map.dart';
import 'nearby_shelters_screen.dart';

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

  Map<String, double> _cyclingPathRatings = {};
  Map<String, double> _shelterRatings = {};

  LatLng? _userLocation;

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

      final cyclingPathRatings =
          await _urbanDataService.getAverageRatings(
        targetType: 'cycling_path',
      );

      final shelterRatings =
          await _urbanDataService.getAverageRatings(
        targetType: 'shelter',
      );

      final position =
          await LocationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _cyclingPaths = cyclingPaths;
        _shelters = shelters;
        _roadWorks = roadWorks;

        _cyclingPathRatings = cyclingPathRatings;
        _shelterRatings = shelterRatings;

        if (position != null) {
          _userLocation = LatLng(
            position.latitude,
            position.longitude,
          );
        }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.near_me),
            tooltip: 'Rastrelliere vicine',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NearbySheltersScreen(),
                ),
              );
            },
          ),
        ],
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

    return UrbanMap(
      cyclingPaths: _cyclingPaths,
      shelters: _shelters,
      roadWorks: _roadWorks,
      userLocation: _userLocation,
      cyclingPathRatings: _cyclingPathRatings,
      shelterRatings: _shelterRatings,
    );
  }
}