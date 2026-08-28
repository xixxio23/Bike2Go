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

  factory RoadWorkModel.fromMap(Map<String, dynamic> map) {
    final pinpoint = map['pinpoint'] as Map<String, dynamic>?;

    return RoadWorkModel(
      id: (map['id'] as num).toInt(),

      latitude: (pinpoint?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (pinpoint?['lon'] as num?)?.toDouble() ?? 0.0,

      address: map['address'] as String?,
      neighborhood: map['neighborhood1'] as String?,
      status: map['status'] as String?,

      startDate: _parseDate(map['effectivestartdate']),
      endDate: _parseDate(map['effectiveenddate']),

      trafficChangesMeasure:
          map['trafficchangesmeasure'] as String?,

      description: map['description'] as String?,

      visualizationNotes:
          map['visualizationnotes'] as String?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'neighborhood': neighborhood,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'traffic_changes_measure': trafficChangesMeasure,
      'description': description,
      'visualization_notes': visualizationNotes,
    };
  }
}
