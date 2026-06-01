class MetricLogModel {
  final String? id;
  final double weight;
  final double? bodyFat;
  final double? bmi;
  final double? waist;
  final double? chest;
  final double? hips;
  final double? muscleMass;
  final DateTime date;

  MetricLogModel({
    this.id,
    required this.weight,
    this.bodyFat,
    this.bmi,
    this.waist,
    this.chest,
    this.hips,
    this.muscleMass,
    required this.date,
  });

  factory MetricLogModel.fromJson(Map<String, dynamic> json) {
    return MetricLogModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      weight: (json['weight'] as num).toDouble(),
      bodyFat: (json['bodyFat'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      chest: (json['chest'] as num?)?.toDouble(),
      hips: (json['hips'] as num?)?.toDouble(),
      muscleMass: (json['muscleMass'] as num?)?.toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'bodyFat': bodyFat,
      'bmi': bmi,
      'waist': waist,
      'chest': chest,
      'hips': hips,
      'muscleMass': muscleMass,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
    };
  }
}
