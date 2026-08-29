import 'dart:async';

import 'package:flutter/material.dart';

import '../services/activity_recognition_service.dart';
import 'nearby_shelters_screen.dart';
import 'urban_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ActivityRecognitionService _activityService =
      ActivityRecognitionService();

  StreamSubscription<String>? _activitySubscription;

  String? _currentActivity;

  @override
  void initState() {
    super.initState();
    _startActivityRecognition();
  }

  Future<void> _startActivityRecognition() async {
    try {
      final available = await _activityService.isAvailable();

      if (!available) return;

      final permission = await _activityService.requestPermission();

      if (!permission) return;

      _activitySubscription =
          _activityService.activityStream.listen((activity) {
        if (!mounted) return;

        setState(() {
          _currentActivity = activity;
        });
      });

      await _activityService.start();
    } catch (_) {}
  }

  @override
  void dispose() {
    _activitySubscription?.cancel();
    super.dispose();
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

              const SizedBox(height: 24),

              Text(
                'Bike2Go',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 40),

              Card(
                child: ListTile(
                  leading: Icon(
                    activityIcon,
                    size: 36,
                  ),
                  title: const Text('Stato'),
                  subtitle: Text(
                    activityText,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UrbanMapScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text(
                    'Apri la mappa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NearbySheltersScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.pedal_bike),
                  label: const Text(
                    'Rastrelliere vicine',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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