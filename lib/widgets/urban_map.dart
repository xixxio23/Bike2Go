import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/cycling_path_model.dart';
import '../models/shelter_model.dart';
import '../models/road_work_model.dart';
import 'map_visual_style.dart';
import 'urban_element_details.dart';

class UrbanMap extends StatefulWidget {
  final List<CyclingPathModel> cyclingPaths;
  final List<ShelterModel> shelters;
  final List<RoadWorkModel> roadWorks;
  final LatLng? userLocation;
  final Map<String, double> cyclingPathRatings;
  final Map<String, double?> shelterRatings;

  const UrbanMap({
    super.key,
    required this.cyclingPaths,
    required this.shelters,
    required this.roadWorks,
    this.userLocation,
    this.cyclingPathRatings = const {},
    this.shelterRatings = const {},
  });

  static const LatLng bolognaCenter = LatLng(44.4949, 11.3426);

  @override
  State<UrbanMap> createState() => _UrbanMapState();
}

class _UrbanMapState extends State<UrbanMap> {
  final LayerHitNotifier<CyclingPathModel> _cyclingPathHitNotifier =
      ValueNotifier(null);

  @override
  void dispose() {
    _cyclingPathHitNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: UrbanMap.bolognaCenter,
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.bike2go.app',
        ),
        TranslucentPointer(
          child: GestureDetector(
            onTap: _onCyclingPathTap,
            child: PolylineLayer<CyclingPathModel>(
              hitNotifier: _cyclingPathHitNotifier,
              minimumHitbox: 20,
              polylines: _buildCyclingPathPolylines(),
            ),
          ),
        ),
        MarkerLayer(
          markers: [
            ..._buildShelterMarkers(),
            ..._buildRoadWorkMarkers(),
            ..._buildUserLocationMarker(),
          ],
        ),
      ],
    );
  }

  List<Polyline<CyclingPathModel>> _buildCyclingPathPolylines() {
    return widget.cyclingPaths
        .expand(
          (path) => path.geometry.map(
            (line) => Polyline<CyclingPathModel>(
              points: line
                  .map(
                    (point) => LatLng(
                      point.latitude,
                      point.longitude,
                    ),
                  )
                  .toList(),
              strokeWidth: 4,
              color: MapVisualStyle.cyclingPathColor(
                widget.cyclingPathRatings[path.codice.toString()],
              ),
              hitValue: path,
            ),
          ),
        )
        .toList();
  }

  void _onCyclingPathTap() {
    final hitResult = _cyclingPathHitNotifier.value;

    if (hitResult == null || hitResult.hitValues.isEmpty) return;

    _showDetails(
      cyclingPath: hitResult.hitValues.first,
    );
  }

  List<Marker> _buildShelterMarkers() {
    return widget.shelters.map(
      (shelter) {
        final safetyScore = widget.shelterRatings[shelter.id];

        return Marker(
          point: LatLng(
            shelter.latitude,
            shelter.longitude,
          ),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showDetails(shelter: shelter),
            child: Icon(
              Icons.pedal_bike,
              color: MapVisualStyle.shelterSafetyColor(safetyScore),
              size: 30,
            ),
          ),
        );
      },
    ).toList();
  }

  List<Marker> _buildRoadWorkMarkers() {
    return widget.roadWorks.map(
      (roadWork) {
        return Marker(
          point: LatLng(
            roadWork.latitude,
            roadWork.longitude,
          ),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showDetails(roadWork: roadWork),
            child: const Icon(
              Icons.construction,
              color: MapVisualStyle.roadWorkColor,
              size: 30,
            ),
          ),
        );
      },
    ).toList();
  }

  List<Marker> _buildUserLocationMarker() {
    if (widget.userLocation == null) return [];

    return [
      Marker(
        point: widget.userLocation!,
        width: 40,
        height: 40,
        child: const Icon(
          Icons.my_location,
          color: MapVisualStyle.userLocationColor,
          size: 30,
        ),
      ),
    ];
  }

  void _showDetails({
    CyclingPathModel? cyclingPath,
    ShelterModel? shelter,
    RoadWorkModel? roadWork,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => UrbanElementDetails(
        cyclingPath: cyclingPath,
        shelter: shelter,
        roadWork: roadWork,
      ),
    );
  }
}