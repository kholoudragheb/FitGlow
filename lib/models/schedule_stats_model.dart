class ScheduleStatsModel {
  final int totalSessions;
  final int completedSessions;
  final int canceledSessions;
  final int upcomingSessions;
  final int pendingSessions;
  final int totalClients;
  final int bookedSlots;
  final int availableSlots;
  final double completionRate;
  final double bookingRate;
  final Map<String, int> weeklyActivity; // e.g., {"Mon": 5, "Tue": 3, ...}
  final Map<String, int> sessionStatusBreakdown; // e.g., {"confirmed": 10, "pending": 5, ...}

  ScheduleStatsModel({
    required this.totalSessions,
    required this.completedSessions,
    required this.canceledSessions,
    required this.upcomingSessions,
    required this.pendingSessions,
    required this.totalClients,
    required this.bookedSlots,
    required this.availableSlots,
    required this.completionRate,
    required this.bookingRate,
    required this.weeklyActivity,
    required this.sessionStatusBreakdown,
  });

  factory ScheduleStatsModel.fromJson(Map<String, dynamic> json) {
    return ScheduleStatsModel(
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      completedSessions: (json['completedSessions'] as num?)?.toInt() ?? 0,
      canceledSessions: (json['canceledSessions'] as num?)?.toInt() ?? 0,
      upcomingSessions: (json['upcomingSessions'] as num?)?.toInt() ?? 0,
      pendingSessions: (json['pendingSessions'] as num?)?.toInt() ?? 0,
      totalClients: (json['totalClients'] as num?)?.toInt() ?? 0,
      bookedSlots: (json['bookedSlots'] as num?)?.toInt() ?? 0,
      availableSlots: (json['availableSlots'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      bookingRate: (json['bookingRate'] as num?)?.toDouble() ?? 0.0,
      weeklyActivity: Map<String, int>.from(json['weeklyActivity'] ?? {}),
      sessionStatusBreakdown: Map<String, int>.from(json['sessionStatusBreakdown'] ?? {}),
    );
  }

  factory ScheduleStatsModel.empty() {
    return ScheduleStatsModel(
      totalSessions: 0,
      completedSessions: 0,
      canceledSessions: 0,
      upcomingSessions: 0,
      pendingSessions: 0,
      totalClients: 0,
      bookedSlots: 0,
      availableSlots: 0,
      completionRate: 0.0,
      bookingRate: 0.0,
      weeklyActivity: {},
      sessionStatusBreakdown: {},
    );
  }
}
