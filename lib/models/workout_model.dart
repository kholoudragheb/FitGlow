class ExerciseModel {
  final String? id;
  final String name;
  final String reps;
  final String sets;
  final String duration;
  final String? restTime;
  final String instructions;
  final String? image;
  final String? videoUrl;

  ExerciseModel({
    this.id,
    required this.name,
    required this.reps,
    required this.sets,
    required this.duration,
    this.restTime,
    required this.instructions,
    this.image,
    this.videoUrl,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      reps: json['reps']?.toString() ?? '',
      sets: json['sets']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      restTime: json['restTime']?.toString(),
      instructions: json['instructions'] ?? '',
      image: json['image'],
      videoUrl: json['videoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'reps': reps,
      'sets': sets,
      'duration': duration,
      'restTime': restTime,
      'instructions': instructions,
      'image': image,
      'videoUrl': videoUrl,
    };
  }
}

class WorkoutModel {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String duration;
  final int caloriesBurned;
  final List<String> tags;
  final String image;
  final String? videoUrl;
  final List<ExerciseModel> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.caloriesBurned,
    required this.tags,
    required this.image,
    this.videoUrl,
    required this.exercises,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? 'Beginner',
      duration: _parseDuration(json['duration']),
      caloriesBurned: json['calories'] ?? json['caloriesBurned'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      image: json['thumbnailUrl'] ?? json['image'] ?? '',
      videoUrl: json['videoUrl'],
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => ExerciseModel.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static String _parseDuration(dynamic duration) {
    if (duration == null) return '0 mins';
    if (duration is int) return '$duration mins';
    final s = duration.toString();
    if (s.contains('min')) return s;
    return '$s mins';
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'tags': tags,
      'image': image,
      'videoUrl': videoUrl,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
