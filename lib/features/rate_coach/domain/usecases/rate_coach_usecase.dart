import '../repositories/rate_coach_repository.dart';

class RateCoachUseCase {
  final RateCoachRepository repository;

  RateCoachUseCase(this.repository);

  Future<void> call({
    required String coachId,
    required int rating,
    required String comment,
  }) async {
    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating must be between 1 and 5');
    }
    return repository.rateCoach(
      coachId: coachId,
      rating: rating,
      comment: comment,
    );
  }
}
