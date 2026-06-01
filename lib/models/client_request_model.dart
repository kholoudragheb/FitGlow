class ClientRequestModel {
  final String id;
  final String clientId;
  final String? coachId; // Can be null
  final String status;
  final String message;
  final String trainingType;
  final String createdAt;
  final String updatedAt;

  ClientRequestModel({
    required this.id,
    required this.clientId,
    this.coachId,
    required this.status,
    required this.message,
    required this.trainingType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientRequestModel.fromJson(Map<String, dynamic> json) {
    return ClientRequestModel(
      id: json['_id']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      coachId: json['coachId']?.toString(), // Safely handles null
      status: json['status']?.toString() ?? 'pending',
      message: json['message']?.toString() ?? '',
      trainingType: json['trainingType']?.toString() ?? 'online',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}
