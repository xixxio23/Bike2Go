import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../database/geofence_repository.dart';
import '../database/gps_log_repository.dart';
import '../database/moment_repository.dart';
import '../database/route_point_repository.dart';
import '../database/trip_repository.dart';

import '../models/trip_model.dart';

import 'export/export_statistics_service.dart';
import 'export/trip_backup_service.dart';
import 'export/trip_csv_exporter.dart';
import 'export/trip_json_exporter.dart';

class DataExportService {
  final TripJsonExporter _jsonExporter;
  final TripCsvExporter _csvExporter;
  final TripBackupService _backupService;
  final ExportStatisticsService _statisticsService;

  DataExportService({
    required TripRepository tripRepository,
    required MomentRepository momentRepository,
    required RoutePointRepository routePointRepository,
    required GpsLogRepository gpsLogRepository,
    required GeofenceRepository geofenceRepository,
  })  : _jsonExporter = TripJsonExporter(
          tripRepository: tripRepository,
          momentRepository: momentRepository,
          routePointRepository: routePointRepository,
        ),
        _csvExporter = TripCsvExporter(
          tripRepository: tripRepository,
          momentRepository: momentRepository,
          routePointRepository: routePointRepository,
        ),
        _backupService = TripBackupService(
          tripRepository: tripRepository,
          momentRepository: momentRepository,
          routePointRepository: routePointRepository,
          gpsLogRepository: gpsLogRepository,
          geofenceRepository: geofenceRepository,
        ),
        _statisticsService = ExportStatisticsService(
          tripRepository: tripRepository,
          momentRepository: momentRepository,
          routePointRepository: routePointRepository,
          gpsLogRepository: gpsLogRepository,
          geofenceRepository: geofenceRepository,
        );

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<String?> exportTripsToJson({
    DateTime? startDate,
    DateTime? endDate,
    List<TripType>? tripTypes,
  }) {
    return _jsonExporter.exportTripsToJson(
      startDate: startDate,
      endDate: endDate,
      tripTypes: tripTypes,
    );
  }

  Future<String?> exportTripsToCsv({
    DateTime? startDate,
    DateTime? endDate,
    List<TripType>? tripTypes,
  }) {
    return _csvExporter.exportTripsToCsv(
      startDate: startDate,
      endDate: endDate,
      tripTypes: tripTypes,
    );
  }

  Future<String?> createFullBackup() {
    return _backupService.createFullBackup();
  }

  Future<Map<String, dynamic>> getExportStatistics() {
    return _statisticsService.getExportStatistics();
  }

  Future<bool> shareExportedFile(String filePath) async {
    try {
      await Share.shareXFiles([
        XFile(filePath),
      ]);

      return true;
    } catch (_) {
      return false;
    }
  }
}