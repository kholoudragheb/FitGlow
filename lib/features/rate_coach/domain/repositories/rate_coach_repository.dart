abstract class RateCoachRepository {
  Future<void> rateCoach({
    required String coachId,
    required int rating,
    required String comment,
  });
}
