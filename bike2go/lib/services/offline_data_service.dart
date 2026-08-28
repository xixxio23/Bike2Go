import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../database/trip_repository.dart';

class OfflineDataService {
  static const String _cacheKey = 'offline_data_cache';

  final TripRepository _tripRepository;
  final DatabaseHelper _databaseHelper;

  OfflineDataService(
    this._tripRepository,
    this._databaseHelper,
  );

  Future<void> cacheDataForOfflineUse() async {
    try {
      final trips = await _tripRepository.getTrips();
      final stats = await _databaseHelper.getDatabaseStats();

      final offlineData = <String, dynamic>{
        'trips_count': trips.length,
        'last_sync': DateTime.now().toIso8601String(),
        'recent_trips': trips.take(10).map((trip) {
          return {
            'id': trip.id,
            'title': trip.title,
            'destination': trip.destination,
            'type': trip.type.name,
            'start_date': trip.startDate.toIso8601String(),
          };
        }).toList(),
        'database_stats': stats,
      };

      final preferences = await SharedPreferences.getInstance();

      await preferences.setString(
        _cacheKey,
        jsonEncode(offlineData),
      );
    } catch (e) {
      debugPrint('Error caching data for offline use: $e');
    }
  }

  Future<Map<String, dynamic>?> getOfflineData() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final cachedData = preferences.getString(_cacheKey);

      if (cachedData == null || cachedData.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(cachedData);

      if (decoded is! Map) {
        return null;
      }

      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      debugPrint('Error retrieving offline data: $e');
      return null;
    }
  }

  Future<bool> isOfflineDataAvailable() async {
    final data = await getOfflineData();

    return data != null;
  }

  Future<DateTime?> getLastSyncDate() async {
    final data = await getOfflineData();

    final value = data?['last_sync'];

    if (value is! String) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  Future<int> getCachedTripsCount() async {
    final data = await getOfflineData();

    final value = data?['trips_count'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  Future<void> clearOfflineData() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      await preferences.remove(_cacheKey);
    } catch (e) {
      debugPrint('Error clearing offline data: $e');
    }
  }
}