class PlanModel {
  final String id;
  final String clientId;
  final String coachId;
  final String title;
  final String description;
  final String type; // 'workout', 'nutrition', 'custom'
  final int durationWeeks;
  final int daysPerWeek;
  final String difficulty;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlanModel({
    required this.id,
    required this.clientId,
    required this.coachId,
    required this.title,
    required this.description,
    required this.type,
    required this.durationWeeks,
    required this.daysPerWeek,
    required this.difficulty,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      coachId: json['coachId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'workout',
      durationWeeks: (json['durationWeeks'] as num?)?.toInt() ?? 4,
      daysPerWeek: (json['daysPerWeek'] as num?)?.toInt() ?? 3,
      difficulty: json['difficulty']?.toString() ?? 'beginner',
      status: json['status']?.toString() ?? 'active',
      notes: json['notes']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'title': title,
      'description': description,
      'type': type,
      'durationWeeks': durationWeeks,
      'daysPerWeek': daysPerWeek,
      'difficulty': difficulty,
      'status': status,
      'notes': notes,
    };
  }
}

class PlanCreateRequest {
  final String clientId;
  final String title;
  final String description;
  final String type;
  final int durationWeeks;
  final int daysPerWeek;
  final String difficulty;
  final String? notes;
  final String status;

  PlanCreateRequest({
    required this.clientId,
    required this.title,
    required this.description,
    required this.type,
    required this.durationWeeks,
    required this.daysPerWeek,
    required this.difficulty,
    this.notes,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'title': title,
      'description': description,
      'type': type,
      'durationWeeks': durationWeeks,
      'daysPerWeek': daysPerWeek,
      'difficulty': difficulty,
      'notes': notes,
      'status': status,
    };
  }
}
