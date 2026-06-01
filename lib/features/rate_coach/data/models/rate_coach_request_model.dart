class RateCoachRequestModel {
  final int rating;
  final String comment;

  RateCoachRequestModel({
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}
