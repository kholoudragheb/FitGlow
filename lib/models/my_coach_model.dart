class MyCoachModel {
  final String id;
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? imageUrl;
  final List<String> specialties;
  final int experienceYears;
  final List<String> certifications;
  final double averageRating;
  final int totalReviews;
  final bool isVerified;
  final bool isActive;

  MyCoachModel({
    required this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.bio,
    this.imageUrl,
    required this.specialties,
    required this.experienceYears,
    required this.certifications,
    required this.averageRating,
    required this.totalReviews,
    required this.isVerified,
    required this.isActive,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory MyCoachModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> userData = json;
    String cId = '';
    
    if (json['coachId'] is Map) {
      final coachMap = json['coachId'] as Map;
      cId = coachMap['_id']?.toString() ?? coachMap['id']?.toString() ?? '';
      userData = Map<String, dynamic>.from(coachMap);
    } else if (json['coachId'] != null) {
      cId = json['coachId'].toString();
    } else if (json['coach'] is Map) {
      final coachMap = json['coach'] as Map;
      cId = coachMap['_id']?.toString() ?? coachMap['id']?.toString() ?? '';
      userData = Map<String, dynamic>.from(coachMap);
    } else {
      cId = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    }

    String fName = userData['firstName']?.toString() ?? '';
    String lName = userData['lastName']?.toString() ?? '';
    String uId = '';
    
    if (userData['userId'] is Map) {
      final user = userData['userId'] as Map;
      uId = user['_id']?.toString() ?? user['id']?.toString() ?? '';
      if (fName.isEmpty) fName = user['firstName']?.toString() ?? '';
      if (lName.isEmpty) lName = user['lastName']?.toString() ?? '';
    } else if (userData['userId'] != null) {
      uId = userData['userId'].toString();
    } else if (json['userId'] is Map) {
      final user = json['userId'] as Map;
      uId = user['_id']?.toString() ?? user['id']?.toString() ?? '';
      if (fName.isEmpty) fName = user['firstName']?.toString() ?? '';
      if (lName.isEmpty) lName = user['lastName']?.toString() ?? '';
    } else if (json['userId'] != null) {
      uId = json['userId'].toString();
    }
    
    if (uId.isEmpty) {
      uId = cId;
    }

    return MyCoachModel(
      id: cId.isNotEmpty ? cId : (json['_id']?.toString() ?? json['id']?.toString() ?? ''),
      userId: uId,
      firstName: fName.isNotEmpty ? fName : null,
      lastName: lName.isNotEmpty ? lName : null,
      bio: json['bio']?.toString() ?? userData['bio']?.toString(),
      imageUrl: parseImageUrl(json, userData),
      specialties: List<String>.from(json['specialties'] ?? userData['specialties'] ?? []),
      experienceYears: json['experienceYears'] ?? userData['experienceYears'] ?? 0,
      certifications: List<String>.from(json['certifications'] ?? userData['certifications'] ?? []),
      averageRating: (json['averageRating'] ?? json['rating'] ?? userData['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? userData['totalReviews'] ?? 0,
      isVerified: json['isVerified'] ?? json['verified'] ?? userData['isVerified'] ?? false,
      isActive: json['isActive'] ?? userData['isActive'] ?? true,
    );
  }

  MyCoachModel copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? bio,
    String? imageUrl,
    List<String>? specialties,
    int? experienceYears,
    List<String>? certifications,
    double? averageRating,
    int? totalReviews,
    bool? isVerified,
    bool? isActive,
  }) {
    return MyCoachModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      specialties: specialties ?? this.specialties,
      experienceYears: experienceYears ?? this.experienceYears,
      certifications: certifications ?? this.certifications,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
    );
  }

  static String? parseImageUrl(Map<String, dynamic> json, Map<String, dynamic> userData) {
    String? url = json['image']?.toString() ?? json['imageUrl']?.toString() ?? json['profileImage']?.toString() ?? userData['image']?.toString() ?? userData['imageUrl']?.toString() ?? userData['profileImage']?.toString();
    if (url == null && json['userId'] is Map) {
      url = json['userId']['avatar']?.toString() ?? json['userId']['profileImage']?.toString();
    }
    if (url == null && userData['userId'] is Map) {
      url = userData['userId']['avatar']?.toString() ?? userData['userId']['profileImage']?.toString();
    }
    if (url == null || url.isEmpty) return null;
    if (!url.startsWith('http')) {
      const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
      if (url.startsWith('/')) return '$baseUrl$url';
      return '$baseUrl/$url';
    }
    return url;
  }
}
