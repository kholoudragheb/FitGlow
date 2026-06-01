class Coach {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String bio;
  final List<String> specialties;
  final int experienceYears;
  final List<String> certifications;
  final double averageRating;
  final int totalReviews;
  final bool isVerified;
  final bool isActive;
  final String? avatarUrl;

  Coach({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.specialties,
    required this.experienceYears,
    required this.certifications,
    required this.averageRating,
    required this.totalReviews,
    required this.isVerified,
    required this.isActive,
    this.avatarUrl,
  });

  factory Coach.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] ?? {};
    String uId = '';
    if (user is Map) {
      uId = user['_id']?.toString() ?? user['id']?.toString() ?? '';
    } else if (json['userId'] != null) {
      uId = json['userId'].toString();
    }
    return Coach(
      id: json['_id'] ?? '',
      userId: uId,
      firstName: user is Map ? (user['firstName'] ?? 'Unknown') : 'Unknown',
      lastName: user is Map ? (user['lastName'] ?? '') : '',
      bio: json['bio'] ?? '',
      specialties: List<String>.from(json['specialties'] ?? []),
      experienceYears: json['experienceYears'] ?? 0,
      certifications: List<String>.from(json['certifications'] ?? []),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      avatarUrl: _parseAvatarUrl(user is Map ? user['avatar'] : null),
    );
  }

  static String? _parseAvatarUrl(dynamic avatar) {
    if (avatar == null || avatar.toString().isEmpty) return null;
    String url = avatar.toString();
    if (!url.startsWith('http')) {
      // Prepend base URL if it's a relative path
      const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
      if (url.startsWith('/')) {
        return '$baseUrl$url';
      }
      return '$baseUrl/$url';
    }
    return url;
  }
}
