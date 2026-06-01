class TimeSlotModel {
  final String id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final int duration;
  final String sessionType;
  final bool isRecurring;
  final bool isBooked;
  final bool isAvailable;
  final String? bookedClientId;
  final String? bookedSessionId;
  final String? coachId;
  final String? date;
  final DateTime createdAt;
  final DateTime updatedAt;

  TimeSlotModel({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.sessionType,
    required this.isRecurring,
    required this.isBooked,
    this.isAvailable = true,
    this.bookedClientId,
    this.bookedSessionId,
    this.coachId,
    this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 1,
      startTime: json['startTime']?.toString() ?? '09:00',
      endTime: json['endTime']?.toString() ?? '10:00',
      duration: (json['duration'] as num?)?.toInt() ?? 60,
      sessionType: json['sessionType']?.toString() ?? 'online',
      isRecurring: json['isRecurring'] == true,
      isBooked: json['isBooked'] == true,
      isAvailable: json['isAvailable'] ?? !(json['isBooked'] == true),
      bookedClientId: json['bookedClientId']?.toString(),
      bookedSessionId: json['bookedSessionId']?.toString() ?? json['sessionId']?.toString(),
      coachId: json['coachId']?.toString(),
      date: json['date']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'sessionType': sessionType,
      'isRecurring': isRecurring,
    };
  }
}
