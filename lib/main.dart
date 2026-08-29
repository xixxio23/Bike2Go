import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'database/database_helper.dart';
import 'screens/home_screen.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bike2Go',
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