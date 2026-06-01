import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/review_model.dart';
import '../../../services/store_service.dart';

abstract class AddReviewState extends Equatable {
  const AddReviewState();
  @override
  List<Object?> get props => [];
}

class AddReviewInitial extends AddReviewState {}

class AddReviewSubmitting extends AddReviewState {}

class AddReviewSuccess extends AddReviewState {
  final ReviewModel review;
  const AddReviewSuccess(this.review);
  @override
  List<Object?> get props => [review];
}

class AddReviewError extends AddReviewState {
  final String message;
  const AddReviewError(this.message);
  @override
  List<Object?> get props => [message];
}

class AddReviewCubit extends Cubit<AddReviewState> {
  final StoreService _service;

  AddReviewCubit(this._service) : super(AddReviewInitial());

  Future<void> submitReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    if (rating < 1 || rating > 5) {
      emit(const AddReviewError("Please select a rating between 1 and 5."));
      return;
    }
    if (comment.isEmpty) {
      emit(const AddReviewError("Please write a comment."));
      return;
    }

    emit(AddReviewSubmitting());
    try {
      final review = await _service.addProductReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );
      emit(AddReviewSuccess(review));
    } catch (e) {
      emit(AddReviewError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
