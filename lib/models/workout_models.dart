// Workout Data Models

class WorkoutCategory {
  final String id;
  final String name;
  final String image;
  final int workoutCount;

  const WorkoutCategory({
    required this.id,
    required this.name,
    required this.image,
    this.workoutCount = 0,
  });
}

class Workout {
  final String id;
  final String title;
  final String categoryId;
  final String level; // Beginner, Intermediate, Advanced
  final int durationMinutes;
  final String thumbnailImage;
  final List<Exercise> exercises;
  final List<String> subcategories; // Full Body, Upper Body, etc.

  const Workout({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.level,
    required this.durationMinutes,
    required this.thumbnailImage,
    this.exercises = const [],
    this.subcategories = const [],
  });
}

class Exercise {
  final String id;
  final String name;
  final String subtitle;
  final int durationSeconds;
  final String thumbnailImage;
  final String? videoUrl;
  final List<String> howToSteps;
  final List<String> keyTips;

  const Exercise({
    required this.id,
    required this.name,
    this.subtitle = '',
    required this.durationSeconds,
    required this.thumbnailImage,
    this.videoUrl,
    this.howToSteps = const [],
    this.keyTips = const [],
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// Filter Options
class WorkoutFilter {
  final Set<String> categories;
  final Set<String> subcategories;
  final String? level;
  final String? duration;

  const WorkoutFilter({
    this.categories = const {},
    this.subcategories = const {},
    this.level,
    this.duration,
  });

  WorkoutFilter copyWith({
    Set<String>? categories,
    Set<String>? subcategories,
    String? level,
    String? duration,
  }) {
    return WorkoutFilter(
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      level: level ?? this.level,
      duration: duration ?? this.duration,
    );
  }
}

// Search History Item
class SearchHistoryItem {
  final String query;
  final DateTime searchedAt;

  const SearchHistoryItem({
    required this.query,
    required this.searchedAt,
  });
}
