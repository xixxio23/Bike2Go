import 'dart:async';

import 'package:flutter/material.dart';

import '../services/activity_recognition_service.dart';
import 'nearby_shelters_screen.dart';
import 'route_planner_screen.dart';
import 'urban_map_screen.dart';

class HomeScreen extends StatefulWidget {
  final String apiKey;

  const HomeScreen({
    super.key,
    required this.apiKey,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _activityService = ActivityRecognitionService();

  StreamSubscription<String>? _activitySubscription;
  String? _currentActivity;

  @override
  void initState() {
    super.initState();
    _startActivityRecognition();
  }

  Future<void> _startActivityRecognition() async {
    try {
      if (!await _activityService.isAvailable()) return;
      if (!await _activityService.requestPermission()) return;

      _activitySubscription =
          _activityService.activityStream.listen((activity) {
        if (mounted) {
          setState(() => _currentActivity = activity);
        }
      });

      await _activityService.start();
    } catch (_) {}
  }

  @override
  void dispose() {
    _activitySubscription?.cancel();
    super.dispose();
  }

  void _open(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCycling =
        _currentActivity == ActivityRecognitionService.cycling;

    final isWalking =
        _currentActivity == ActivityRecognitionService.walking;

    final activityText = isCycling
        ? 'Cycling'
        : isWalking
            ? 'Walking'
            : 'Stato non rilevato';

    final activityIcon = isCycling
        ? Icons.directions_bike
        : isWalking
            ? Icons.directions_walk
            : Icons.help_outline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bike2Go'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              const Icon(
                Icons.directions_bike,
                size: 80,
              ),

              const SizedBox(height: 16),

              Text(
                'Bike2Go',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 32),

              Card(
                child: ListTile(
                  leading: Icon(activityIcon, size: 36),
                  title: const Text('Stato'),
                  subtitle: Text(
                    activityText,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _HomeButton(
                icon: Icons.map,
                label: 'Apri la mappa',
                onPressed: () => _open(
                  const UrbanMapScreen(),
                ),
              ),

              const SizedBox(height: 10),

              _HomeButton(
                icon: Icons.pedal_bike,
                label: 'Rastrelliere vicine',
                outlined: true,
                onPressed: () => _open(
                  const NearbySheltersScreen(),
                ),
              ),

              const SizedBox(height: 10),

              _HomeButton(
                icon: Icons.directions_bike,
                label: 'Route Planner',
                outlined: true,
                onPressed: () => _open(
                  RoutePlannerScreen(
                    apiKey: widget.apiKey,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool outlined;

  const _HomeButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}