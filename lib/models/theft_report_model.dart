class TheftReportModel {
  final int? id;
  final String syncId;
  final String shelterId;
  final String? description;
  final DateTime createdAt;

  const TheftReportModel({
    this.id,
    required this.syncId,
    required this.shelterId,
    this.description,
    required this.createdAt,
  });

  factory TheftReportModel.fromMap(Map<String, dynamic> map) {
    return TheftReportModel(
      id: map['id'] as int?,
      syncId: map['sync_id'] as String,
      shelterId: map['shelter_id'] as String,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sync_id': syncId,
      'shelter_id': shelterId,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}