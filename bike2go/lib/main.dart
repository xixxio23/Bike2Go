import 'package:flutter/material.dart';

import 'screens/trip_list_screen.dart';
import 'services/geofence_service.dart';

const MaterialColor kColor = Colors.teal;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // L'app deve partire indipendentemente dai servizi secondari.
  runApp(const MyApp());

  // Avvia il geofencing dopo l'avvio dell'interfaccia.
  try {
    final geofenceService = GeofenceService();

    await geofenceService.initialize();
    await geofenceService.startMonitoring();

    debugPrint('GeofenceService avviato correttamente.');
  } catch (e, stackTrace) {
    debugPrint('Errore avvio GeofenceService: $e');
    debugPrint('$stackTrace');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Tracker',

      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: kColor,

        scaffoldBackgroundColor: const Color.fromARGB(255, 4, 71, 68),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),

          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),

          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),

          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),

          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white70),
          helperStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),

        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.white,
          subtitleTextStyle: TextStyle(
            color: Colors.white70,
          ),
        ),

        drawerTheme: DrawerThemeData(
          backgroundColor: kColor.shade800,
        ),

        cardTheme: CardThemeData(
          color: kColor.shade800,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: kColor,
          foregroundColor: Colors.white,
          elevation: 4,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      home: const TripListScreen(),
    );
  }
}