import '../../domain/repositories/rate_coach_repository.dart';
import '../datasources/rate_coach_remote_datasource.dart';
import '../models/rate_coach_request_model.dart';

class RateCoachRepositoryImpl implements RateCoachRepository {
  final RateCoachRemoteDataSource remoteDataSource;

  RateCoachRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> rateCoach({
    required String coachId,
    required int rating,
    required String comment,
  }) async {
    final request = RateCoachRequestModel(rating: rating, comment: comment);
    await remoteDataSource.rateCoach(coachId, request);
  }
}
