import 'session_model.dart';
import 'time_slot_model.dart';

class CoachCalendarModel {
  final int month;
  final int year;
  final List<SessionModel> sessions;
  final List<TimeSlotModel> availableSlots;
  final List<TimeSlotModel> bookedSlots;
  final int totalSessions;
  final int completedSessions;

  CoachCalendarModel({
    required this.month,
    required this.year,
    required this.sessions,
    required this.availableSlots,
    required this.bookedSlots,
    required this.totalSessions,
    required this.completedSessions,
  });

  factory CoachCalendarModel.fromJson(Map<String, dynamic> json) {
    return CoachCalendarModel(
      month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      sessions: (json['sessions'] as List? ?? [])
          .map((i) => SessionModel.fromJson(i))
          .toList(),
      availableSlots: (json['availableSlots'] as List? ?? [])
          .map((i) => TimeSlotModel.fromJson(i))
          .toList(),
      bookedSlots: (json['bookedSlots'] as List? ?? [])
          .map((i) => TimeSlotModel.fromJson(i))
          .toList(),
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      completedSessions: (json['completedSessions'] as num?)?.toInt() ?? 0,
    );
  }

  factory CoachCalendarModel.empty(int month, int year) {
    return CoachCalendarModel(
      month: month,
      year: year,
      sessions: [],
      availableSlots: [],
      bookedSlots: [],
      totalSessions: 0,
      completedSessions: 0,
    );
  }
}
