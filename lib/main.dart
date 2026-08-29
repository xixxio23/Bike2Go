import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'database/database_helper.dart';
import 'screens/home_screen.dart';
import 'screens/nearby_shelters_screen.dart';
import 'services/feedback_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bwarsdwxnysisipwlbve.supabase.co',
    publishableKey: 'sb_publishable_GTR7MeP5RuGWNpxW3CoNLw_950I4DOP',
  );

  final databaseHelper = DatabaseHelper();

  final feedbackSyncService = FeedbackSyncService(
    databaseHelper: databaseHelper,
  );

  feedbackSyncService.startAutoSync();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const MethodChannel _navigationChannel =
      MethodChannel('bike2go/navigation');

  final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    _navigationChannel.setMethodCallHandler((call) async {
      if (call.method == 'openNearbyShelters') {
        _openNearbyShelters();
      }
    });

    _checkNotificationNavigation();
  }

  Future<void> _checkNotificationNavigation() async {
    try {
      final shouldOpen =
          await _navigationChannel.invokeMethod<bool>(
        'checkOpenNearbyShelters',
      );

      if (shouldOpen == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _openNearbyShelters();
        });
      }
    } catch (_) {}
  }

  void _openNearbyShelters() {
    final navigator = _navigatorKey.currentState;

    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => const NearbySheltersScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bike2Go',
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color.fromARGB(
          255,
          4,
          71,
          68,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}