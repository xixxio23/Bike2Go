class RoadWorkModel {
  final int id;
  final double latitude;
  final double longitude;
  final String? address;
  final String? neighborhood;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? trafficChangesMeasure;
  final String? description;
  final String? visualizationNotes;

  const RoadWorkModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.address,
    this.neighborhood,
    this.status,
    this.startDate,
    this.endDate,
    this.trafficChangesMeasure,
    this.description,
    this.visualizationNotes,
  });
}