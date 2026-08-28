import '../database/gps_log_repository.dart';
import '../database/route_point_repository.dart';

class GpsToRouteService {
  final GpsLogRepository _gpsLogRepository;
  final RoutePointRepository _routePointRepository;

  GpsToRouteService({
    required GpsLogRepository gpsLogRepository,
    required RoutePointRepository routePointRepository,
  })  : _gpsLogRepository = gpsLogRepository,
        _routePointRepository = routePointRepository;

  Future<void> syncTrip(int tripId) async {
    final gpsLogs =
        await _gpsLogRepository.getGpsLogsForTrip(tripId);

    // Ricostruisce i route points del viaggio.
    await _routePointRepository.deleteRoutePointsForTrip(tripId);

    for (final log in gpsLogs) {
      await _routePointRepository.insertRoutePoint(
        tripId,
        log.latitude,
        log.longitude,
        log.timestamp,
      );
    }
  }
}