class CoachStatsModel {
  final int totalClients;
  final int pendingRequests;
  final int activeClientsThisWeek;
  final double activityPercentage;
  final double averageProgress;

  CoachStatsModel({
    required this.totalClients,
    required this.pendingRequests,
    required this.activeClientsThisWeek,
    required this.activityPercentage,
    required this.averageProgress,
  });

  factory CoachStatsModel.fromJson(Map<String, dynamic> json) {
    return CoachStatsModel(
      totalClients: json['totalClients'] ?? 0,
      pendingRequests: json['pendingRequests'] ?? 0,
      activeClientsThisWeek: json['activeClientsThisWeek'] ?? 0,
      activityPercentage: (json['activityPercentage'] as num?)?.toDouble() ?? 0.0,
      averageProgress: (json['averageProgress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Factory for empty/error state
  factory CoachStatsModel.empty() {
    return CoachStatsModel(
      totalClients: 0,
      pendingRequests: 0,
      activeClientsThisWeek: 0,
      activityPercentage: 0.0,
      averageProgress: 0.0,
    );
  }
}
