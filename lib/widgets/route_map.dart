import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/cycling_route_model.dart';
import '../models/geo_point_model.dart';

class RouteMap extends StatelessWidget {
  final GeoPointModel origin;
  final GeoPointModel destination;
  final List<CyclingRouteModel> routes;
  final CyclingRouteModel? recommendedRoute;

  const RouteMap({
    super.key,
    required this.origin,
    required this.destination,
    required this.routes,
    this.recommendedRoute,
  });

  @override
  Widget build(BuildContext context) {
    final center = LatLng(
      (origin.latitude + destination.latitude) / 2,
      (origin.longitude + destination.longitude) / 2,
    );

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.bike2go.app',
        ),
        PolylineLayer<CyclingRouteModel>(
          polylines: routes.map((route) {
            final isRecommended =
                route.id == recommendedRoute?.id;

            return Polyline<CyclingRouteModel>(
              points: route.geometry
                  .map(
                    (point) => LatLng(
                      point.latitude,
                      point.longitude,
                    ),
                  )
                  .toList(),
              strokeWidth: isRecommended ? 6 : 4,
              color: isRecommended
                  ? Colors.green
                  : Colors.blueGrey,
              hitValue: route,
            );
          }).toList(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(
                origin.latitude,
                origin.longitude,
              ),
              width: 40,
              height: 40,
              child: const Icon(
                Icons.trip_origin,
                color: Colors.green,
                size: 30,
              ),
            ),
            Marker(
              point: LatLng(
                destination.latitude,
                destination.longitude,
              ),
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 30,
              ),
            ),
          ],
        ),
      ],
    );
  }
}