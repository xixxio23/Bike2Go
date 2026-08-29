class TheftReportModel {
  final int? id;
  final String shelterId;
  final String? description;
  final DateTime createdAt;

  const TheftReportModel({
    this.id,
    required this.shelterId,
    this.description,
    required this.createdAt,
  });

  factory TheftReportModel.fromMap(Map<String, dynamic> map) {
    return TheftReportModel(
      id: map['id'] as int?,
      shelterId: map['shelter_id'] as String,
      description: map['description'] as String?,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shelter_id': shelterId,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
