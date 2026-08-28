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
}
