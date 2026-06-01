class CoachProfileModel {
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
  final String createdAt;
  final String updatedAt;

  CoachProfileModel({
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory CoachProfileModel.fromJson(Map<String, dynamic> json) {
    return CoachProfileModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      specialties: List<String>.from(json['specialties'] ?? []),
      experienceYears: json['experienceYears'] ?? 0,
      certifications: List<String>.from(json['certifications'] ?? []),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}
