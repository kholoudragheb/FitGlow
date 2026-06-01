class CoachRequestModel {
  final String id;
  final String clientId;
  final String? clientFirstName;
  final String? clientLastName;
  final String? clientImage;
  final String coachId;
  final String status;
  final String message;
  final String trainingType;
  final String createdAt;
  final String updatedAt;

  CoachRequestModel({
    required this.id,
    required this.clientId,
    this.clientFirstName,
    this.clientLastName,
    this.clientImage,
    required this.coachId,
    required this.status,
    required this.message,
    required this.trainingType,
    required this.createdAt,
    required this.updatedAt,
  });

  String get clientFullName => '${clientFirstName ?? ''} ${clientLastName ?? 'Client'}'.trim();

  factory CoachRequestModel.fromJson(Map<String, dynamic> json) {
    String cId = '';
    String? fName;
    String? lName;
    String? img;

    if (json['clientId'] is Map<String, dynamic>) {
      final client = json['clientId'] as Map<String, dynamic>;
      cId = client['_id']?.toString() ?? '';
      fName = client['firstName']?.toString();
      lName = client['lastName']?.toString();
      img = client['image']?.toString();
    } else {
      cId = json['clientId']?.toString() ?? '';
    }

    return CoachRequestModel(
      id: json['_id']?.toString() ?? '',
      clientId: cId,
      clientFirstName: fName,
      clientLastName: lName,
      clientImage: img,
      coachId: json['coachId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      message: json['message']?.toString() ?? '',
      trainingType: json['trainingType']?.toString() ?? 'online',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}
