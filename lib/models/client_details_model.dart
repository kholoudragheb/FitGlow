class ClientUserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> healthConditions;

  ClientUserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.healthConditions,
  });

  String get fullName => '$firstName $lastName'.trim().isEmpty ? 'Unknown Client' : '$firstName $lastName';

  factory ClientUserModel.fromJson(Map<String, dynamic> json) {
    return ClientUserModel(
      id: json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      healthConditions: (json['healthConditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
  
  // Static helper to handle either ID string or nested object
  static ClientUserModel fromJsonPolymorphic(dynamic clientIdData) {
    if (clientIdData is Map<String, dynamic>) {
      return ClientUserModel.fromJson(clientIdData);
    } else {
      // It's just a string ID
      return ClientUserModel(
        id: clientIdData?.toString() ?? '',
        email: '',
        firstName: 'Client',
        lastName: '',
        healthConditions: [],
      );
    }
  }
}

class ClientDetailsModel {
  final String relationId;
  final ClientUserModel client;
  final String coachId;
  final bool isActive;
  final String trainingType;
  final double progressPercentage;
  final String startDate;
  final String createdAt;
  final String updatedAt;
  final String? notes;
  final String? lastActivityAt;

  ClientDetailsModel({
    required this.relationId,
    required this.client,
    required this.coachId,
    required this.isActive,
    required this.trainingType,
    required this.progressPercentage,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.lastActivityAt,
  });

  factory ClientDetailsModel.fromJson(Map<String, dynamic> json) {
    return ClientDetailsModel(
      relationId: json['_id']?.toString() ?? '',
      client: ClientUserModel.fromJsonPolymorphic(json['clientId']),
      coachId: json['coachId']?.toString() ?? '',
      isActive: json['isActive'] ?? false,
      trainingType: json['trainingType']?.toString() ?? 'online',
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startDate']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      notes: json['notes']?.toString(),
      lastActivityAt: json['lastActivityAt']?.toString(),
    );
  }
}
