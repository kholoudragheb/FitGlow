class ProgressLogModel {
  final String id;
  final String type; // 'workout', 'meal', 'weight', 'cardio', 'progress'
  final String? notes;
  final int? duration; // minutes
  final double? value; // for weight or other metrics
  final String status;
  final String? planId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProgressLogModel({
    required this.id,
    required this.type,
    this.notes,
    this.duration,
    this.value,
    required this.status,
    this.planId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProgressLogModel.fromJson(Map<String, dynamic> json) {
    return ProgressLogModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'progress',
      notes: json['notes']?.toString(),
      duration: (json['duration'] as num?)?.toInt(),
      value: (json['value'] as num?)?.toDouble(),
      status: json['status']?.toString() ?? 'completed',
      planId: json['planId']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'notes': notes,
      'duration': duration,
      'value': value,
      'status': status,
      'planId': planId,
    };
  }
}
