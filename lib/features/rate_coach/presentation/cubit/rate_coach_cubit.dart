import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/rate_coach_usecase.dart';
import 'rate_coach_state.dart';

class RateCoachCubit extends Cubit<RateCoachState> {
  final RateCoachUseCase rateCoachUseCase;

  RateCoachCubit({required this.rateCoachUseCase}) : super(RateCoachInitial());

  Future<void> submitRating({
    required String coachId,
    required int rating,
    required String comment,
  }) async {
    if (rating < 1 || rating > 5) {
      emit(const RateCoachError("Please select a rating from 1 to 5 stars."));
      return;
    }

    emit(RateCoachLoading());

    try {
      await rateCoachUseCase.call(
        coachId: coachId,
        rating: rating,
        comment: comment,
      );
      emit(RateCoachSuccess());
    } catch (e) {
      emit(RateCoachError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
