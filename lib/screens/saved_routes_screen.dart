import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../database/repositories/saved_route_repository.dart';
import '../models/saved_route_model.dart';
import 'saved_route_map_screen.dart';
import '../widgets/saved_route_card.dart';

class SavedRoutesScreen extends StatefulWidget {
  const SavedRoutesScreen({
    super.key,
  });

  @override
  State<SavedRoutesScreen> createState() =>
      _SavedRoutesScreenState();
}

class _SavedRoutesScreenState
    extends State<SavedRoutesScreen> {
  late final SavedRouteRepository _repository;

  List<SavedRouteModel> _routes = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _repository = SavedRouteRepository(
      DatabaseHelper(),
    );

    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    try {
      final routes =
          await _repository.getAllSavedRoutes();

      if (!mounted) return;

      setState(() {
        _routes = routes;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            'Errore nel caricamento delle route:\n$e';
      });
    }
  }

  Future<void> _deleteRoute(
    SavedRouteModel route,
  ) async {
    try {
      await _repository.deleteSavedRoute(
        route.id,
      );

      if (!mounted) return;

      setState(() {
        _routes.removeWhere(
          (item) => item.id == route.id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Percorso eliminato'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Errore nell\'eliminazione: $e',
          ),
        ),
      );
    }
  }

  void _openRoute(
    SavedRouteModel route,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedRouteMapScreen(
          route: route,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Percorsi salvati'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
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

    if (_routes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.route_outlined,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Nessun percorso salvato',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Le route che salverai dal Route Planner '
                'appariranno qui.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRoutes,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        itemCount: _routes.length,
        itemBuilder: (context, index) {
          final route = _routes[index];

          return SavedRouteCard(
            route: route,
            onTap: () => _openRoute(route),
            onDelete: () => _deleteRoute(route),
          );
        },
      ),
    );
  }
}