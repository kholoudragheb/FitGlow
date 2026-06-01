class ClientInfoModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;

  ClientInfoModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName'.trim().isEmpty ? 'Unknown Client' : '$firstName $lastName';

  factory ClientInfoModel.fromJson(Map<String, dynamic> json) {
    return ClientInfoModel(
      id: json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
    );
  }
}

class PendingRequestModel {
  final String id;
  final ClientInfoModel client;
  final String coachId;
  final String status;
  final String message;
  final String trainingType;
  final String createdAt;
  final String updatedAt;

  PendingRequestModel({
    required this.id,
    required this.client,
    required this.coachId,
    required this.status,
    required this.message,
    required this.trainingType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PendingRequestModel.fromJson(Map<String, dynamic> json) {
    // Handle clientId being either a nested object or a string
    ClientInfoModel clientInfo;
    if (json['clientId'] is Map<String, dynamic>) {
      clientInfo = ClientInfoModel.fromJson(json['clientId']);
    } else {
      // Fallback for plain string ID
      clientInfo = ClientInfoModel(
        id: json['clientId']?.toString() ?? '',
        email: '',
        firstName: '',
        lastName: '',
      );
    }

    return PendingRequestModel(
      id: json['_id']?.toString() ?? '',
      client: clientInfo,
      coachId: json['coachId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      message: json['message']?.toString() ?? '',
      trainingType: json['trainingType']?.toString() ?? 'online',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}
