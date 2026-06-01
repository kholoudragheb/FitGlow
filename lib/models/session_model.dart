class SessionModel {
  final String id;
  final String coachId;
  final String? coachName;
  final String clientId;
  final String? clientName;
  final String? clientEmail;
  final String scheduledDate;
  final String startTime;
  final String endTime;
  final String sessionType;
  final String? title;
  final String status;
  final String? meetingLink;
  final String? notes;
  final String? cancelReason;
  final DateTime? canceledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  SessionModel({
    required this.id,
    required this.coachId,
    this.coachName,
    required this.clientId,
    this.clientName,
    this.clientEmail,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.sessionType,
    this.title,
    required this.status,
    this.meetingLink,
    this.notes,
    this.cancelReason,
    this.canceledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    String parsedCoachId = '';
    String? parsedCoachName;
    
    // Handle coachId as object or ID
    if (json['coachId'] is Map) {
      parsedCoachId = json['coachId']['_id']?.toString() ?? json['coachId']['id']?.toString() ?? '';
      parsedCoachName = json['coachId']['name']?.toString() ?? 
                       json['coachId']['firstName']?.toString() ?? 
                       (json['coachId']['firstName'] != null ? "${json['coachId']['firstName']} ${json['coachId']['lastName'] ?? ''}" : null);
    } else {
      parsedCoachId = json['coachId']?.toString() ?? '';
    }

    String parsedClientId = '';
    String? parsedClientName;
    String? parsedClientEmail;

    // Handle clientId as object or ID
    if (json['clientId'] is Map) {
      parsedClientId = json['clientId']['_id']?.toString() ?? json['clientId']['id']?.toString() ?? '';
      parsedClientName = json['clientId']['name']?.toString() ?? 
                        (json['clientId']['firstName'] != null ? "${json['clientId']['firstName']} ${json['clientId']['lastName'] ?? ''}" : null);
      parsedClientEmail = json['clientId']['email']?.toString();
    } else {
      parsedClientId = json['clientId']?.toString() ?? '';
    }

    return SessionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      coachId: parsedCoachId,
      coachName: parsedCoachName,
      clientId: parsedClientId,
      clientName: parsedClientName,
      clientEmail: parsedClientEmail,
      scheduledDate: json['scheduledDate']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      sessionType: json['sessionType']?.toString() ?? 'online',
      title: json['title']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      meetingLink: json['meetingLink']?.toString(),
      notes: json['notes']?.toString(),
      cancelReason: json['cancelReason']?.toString(),
      canceledAt: json['canceledAt'] != null ? DateTime.parse(json['canceledAt'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coachId': coachId,
      'clientId': clientId,
      'scheduledDate': scheduledDate,
      'startTime': startTime,
      'endTime': endTime,
      'sessionType': sessionType,
      'title': title,
      'status': status,
      'meetingLink': meetingLink,
      'notes': notes,
      'cancelReason': cancelReason,
      'canceledAt': canceledAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
