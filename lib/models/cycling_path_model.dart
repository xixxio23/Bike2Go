import 'geo_point_model.dart';

class CyclingPathModel {
  final int codice;
  final String? year;
  final double? length;
  final String? use;
  final String? type;
  final List<List<GeoPointModel>> geometry;
  final String? fid;

  const CyclingPathModel({
    required this.codice,
    this.year,
    this.length,
    this.use,
    this.type,
    required this.geometry,
    this.fid,
  });

  factory CyclingPathModel.fromMap(Map<String, dynamic> map) {
    final geoShape = map['geo_shape'] as Map<String, dynamic>?;

    final rawCoordinates =
        geoShape?['geometry']?['coordinates'] ??
        geoShape?['coordinates'];

    final geometry = <List<GeoPointModel>>[];

    if (rawCoordinates is List) {
      for (final line in rawCoordinates) {
        if (line is List) {
          geometry.add(
            line
                .whereType<List>()
                .map(
                  (point) => GeoPointModel.fromJson(point),
                )
                .toList(),
          );
        }
      }
    }

    return CyclingPathModel(
      codice: (map['codice'] as num).toInt(),
      year: map['anno'] as String?,
      length: (map['lunghezza'] as num?)?.toDouble(),
      use: map['duso'] as String?,
      type: map['dtipologia2'] as String?,
      geometry: geometry,
      fid: map['fid']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codice': codice,
      'year': year,
      'length': length,
      'use': use,
      'type': type,
      'geometry': geometry
          .map(
            (line) => line
                .map((point) => point.toMap())
                .toList(),
          )
          .toList(),
      'fid': fid,
    };
  }
}
