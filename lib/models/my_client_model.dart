class MyClientModel {
  final String id;
  final String clientId;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? imageUrl;
  final String? gender;
  final int? age;
  final double? height;
  final double? weight;
  final String? fitnessGoal;
  final String? fitnessLevel;
  final String? subscriptionStatus;
  final String? joinedAt;
  final String status;

  MyClientModel({
    required this.id,
    required this.clientId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imageUrl,
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.fitnessGoal,
    this.fitnessLevel,
    this.subscriptionStatus,
    this.joinedAt,
    required this.status,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory MyClientModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> userData = json;
    String cId = '';
    if (json['clientId'] is Map) {
      final clientMap = json['clientId'] as Map;
      cId = clientMap['_id']?.toString() ?? clientMap['id']?.toString() ?? '';
      userData = Map<String, dynamic>.from(clientMap);
    } else if (json['clientId'] != null) {
      cId = json['clientId'].toString();
    }

    String subStatus = json['subscriptionStatus']?.toString() ?? 'inactive';

    if (json['client'] is Map) {
      final client = json['client'] as Map;
      cId = client['_id']?.toString() ?? cId;
      if (client['user'] is Map) {
        userData = Map<String, dynamic>.from(client['user'] as Map);
      } else {
        userData = Map<String, dynamic>.from(client);
      }
    } else if (json['user'] is Map) {
      userData = Map<String, dynamic>.from(json['user'] as Map);
    }

    String uId = '';
    if (userData['userId'] is Map) {
      uId = userData['userId']['_id']?.toString() ?? userData['userId']['id']?.toString() ?? '';
    } else if (userData['userId'] != null) {
      uId = userData['userId'].toString();
    } else if (json['userId'] is Map) {
      uId = json['userId']['_id']?.toString() ?? json['userId']['id']?.toString() ?? '';
    } else if (json['userId'] != null) {
      uId = json['userId'].toString();
    }
    
    if (uId.isEmpty) {
      uId = cId;
    }

    return MyClientModel(
      id: json['_id']?.toString() ?? '',
      clientId: cId,
      userId: uId,
      firstName: userData['firstName']?.toString() ?? 'Client',
      lastName: userData['lastName']?.toString() ?? '',
      email: userData['email']?.toString() ?? '',
      imageUrl: userData['image']?.toString() ?? userData['imageUrl']?.toString(),
      gender: userData['gender']?.toString(),
      age: userData['age'] is int ? userData['age'] : int.tryParse(userData['age']?.toString() ?? ''),
      height: userData['height'] != null ? double.tryParse(userData['height'].toString()) : null,
      weight: userData['weight'] != null ? double.tryParse(userData['weight'].toString()) : null,
      fitnessGoal: userData['fitnessGoal']?.toString() ?? json['fitnessGoal']?.toString(),
      fitnessLevel: userData['fitnessLevel']?.toString() ?? json['fitnessLevel']?.toString(),
      subscriptionStatus: subStatus,
      joinedAt: json['createdAt']?.toString() ?? json['joinedAt']?.toString(),
      status: json['status']?.toString() ?? 'active',
    );
  }
}
