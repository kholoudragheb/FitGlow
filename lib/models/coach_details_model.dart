class CoachDetailsModel {
  final String id;
  final String userId;
  final String bio;
  final List<String> specialties;
  final int experienceYears;
  final List<String> certifications;
  final double averageRating;
  final int totalReviews;
  final bool isVerified;
  final bool isActive;
  final List<String> specializations;
  final String createdAt;
  final String updatedAt;
  
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;

  CoachDetailsModel({
    required this.id,
    required this.userId,
    required this.bio,
    required this.specialties,
    required this.experienceYears,
    required this.certifications,
    required this.averageRating,
    required this.totalReviews,
    required this.isVerified,
    required this.isActive,
    required this.specializations,
    required this.createdAt,
    required this.updatedAt,
    this.firstName,
    this.lastName,
    this.avatarUrl,
  });

  factory CoachDetailsModel.fromJson(Map<String, dynamic> json) {
    String uId = '';
    String? fName;
    String? lName;
    String? avatar;

    if (json['userId'] is Map) {
      uId = json['userId']['_id']?.toString() ?? '';
      fName = json['userId']['firstName']?.toString();
      lName = json['userId']['lastName']?.toString();
      avatar = json['userId']['avatar']?.toString();
    } else {
      uId = json['userId']?.toString() ?? '';
    }

    return CoachDetailsModel(
      id: json['_id']?.toString() ?? '',
      userId: uId,
      bio: json['bio']?.toString() ?? '',
      specialties: List<String>.from(json['specialties'] ?? []),
      experienceYears: json['experienceYears'] ?? 0,
      certifications: List<String>.from(json['certifications'] ?? []),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      specializations: List<String>.from(json['specializations'] ?? []),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      firstName: fName,
      lastName: lName,
      avatarUrl: _parseAvatarUrl(avatar),
    );
  }

  static String? _parseAvatarUrl(dynamic avatar) {
    if (avatar == null || avatar.toString().isEmpty) return null;
    String url = avatar.toString();
    if (!url.startsWith('http')) {
      const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
      if (url.startsWith('/')) {
        return '$baseUrl$url';
      }
      return '$baseUrl/$url';
    }
    return url;
  }
}
