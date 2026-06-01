class ProgressStatsModel {
  final int totalLogs;
  final int workoutsCompleted;
  final int totalMinutes;
  final int streakDays;
  final double completionRate;
  final double averageDuration;
  final List<double> weeklyActivity; // Assuming 7 days of activity levels

  ProgressStatsModel({
    required this.totalLogs,
    required this.workoutsCompleted,
    required this.totalMinutes,
    required this.streakDays,
    required this.completionRate,
    required this.averageDuration,
    required this.weeklyActivity,
  });

  factory ProgressStatsModel.fromJson(Map<String, dynamic> json) {
    return ProgressStatsModel(
      totalLogs: json['totalLogs'] ?? 0,
      workoutsCompleted: json['workoutsCompleted'] ?? 0,
      totalMinutes: json['totalMinutes'] ?? json['totalDuration'] ?? 0,
      streakDays: json['streakDays'] ?? json['streak'] ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      averageDuration: (json['averageDuration'] as num?)?.toDouble() ?? 0.0,
      weeklyActivity: (json['weeklyActivity'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    );
  }

  factory ProgressStatsModel.empty() {
    return ProgressStatsModel(
      totalLogs: 0,
      workoutsCompleted: 0,
      totalMinutes: 0,
      streakDays: 0,
      completionRate: 0.0,
      averageDuration: 0.0,
      weeklyActivity: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    );
  }
}
