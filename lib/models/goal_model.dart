class GoalModel {
  final String id;
  final String title;
  final double targetValue;
  final double currentValue;
  final String unit;
  final DateTime deadline;
  final double progressPercentage;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoalModel({
    required this.id,
    required this.title,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.deadline,
    required this.progressPercentage,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final deadline = json['deadline'] != null 
          ? DateTime.parse(json['deadline'].toString()) 
          : DateTime.now();
    final progress = (json['progressPercentage'] as num?)?.toDouble() ?? 0.0;
    
    // Determine status if backend doesn't provide a reliable one
    String status = json['status']?.toString() ?? 'active';
    if (status == 'active' && deadline.isBefore(DateTime.now()) && progress < 100) {
      status = 'expired';
    }

    return GoalModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      targetValue: (json['targetValue'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? '',
      deadline: deadline,
      progressPercentage: progress,
      status: status,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString()) 
          : DateTime.now(),
    );
  }

  bool get isExpired => status == 'expired' || (deadline.isBefore(DateTime.now()) && progressPercentage < 100);
  bool get isCompleted => status == 'completed' || progressPercentage >= 100;
  bool get isActive => status == 'active' && !isExpired && !isCompleted;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'deadline': deadline.toIso8601String().split('T')[0], // YYYY-MM-DD
    };
  }
}
