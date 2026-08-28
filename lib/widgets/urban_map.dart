import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/cycling_path_model.dart';
import '../models/shelter_model.dart';
import '../models/road_work_model.dart';

class UrbanMap extends StatelessWidget {
  final List<CyclingPathModel> cyclingPaths;
  final List<ShelterModel> shelters;
  final List<RoadWorkModel> roadWorks;

  const UrbanMap({
    super.key,
    required this.cyclingPaths,
    required this.shelters,
    required this.roadWorks,
  });

  static const LatLng bolognaCenter = LatLng(
    44.4949,
    11.3426,
  );

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: bolognaCenter,
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.bike2go.app',
        ),

        PolylineLayer(
          polylines: _buildCyclingPathPolylines(),
        ),

        MarkerLayer(
          markers: [
            ..._buildShelterMarkers(),
            ..._buildRoadWorkMarkers(),
          ],
        ),
      ],
    );
  }

  List<Polyline> _buildCyclingPathPolylines() {
    return cyclingPaths
        .expand(
          (path) => path.geometry.map(
            (line) => Polyline(
              points: line
                  .map(
                    (point) => LatLng(
                      point.latitude,
                      point.longitude,
                    ),
                  )
                  .toList(),
              strokeWidth: 4,
              color: Colors.blue,
            ),
          ),
        )
        .toList();
  }

  List<Marker> _buildShelterMarkers() {
    return shelters.map(
      (shelter) {
        return Marker(
          point: LatLng(
            shelter.latitude,
            shelter.longitude,
          ),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.pedal_bike,
            color: Colors.green,
            size: 30,
          ),
        );
      },
    ).toList();
  }

  List<Marker> _buildRoadWorkMarkers() {
    return roadWorks.map(
      (roadWork) {
        return Marker(
          point: LatLng(
            roadWork.latitude,
            roadWork.longitude,
          ),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.construction,
            color: Colors.orange,
            size: 30,
          ),
        );
      },
    ).toList();
  }
}
