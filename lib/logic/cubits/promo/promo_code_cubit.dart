import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/promo_code_model.dart';
import '../../../services/promo_code_service.dart';

abstract class PromoCodeState extends Equatable {
  const PromoCodeState();
  @override
  List<Object?> get props => [];
}

class PromoCodeIdle extends PromoCodeState {}
class PromoCodeLoading extends PromoCodeState {}
class PromoCodeValid extends PromoCodeState {
  final PromoCodeModel promo;
  const PromoCodeValid(this.promo);
  @override
  List<Object?> get props => [promo];
}
class PromoCodeInvalid extends PromoCodeState {
  final String message;
  const PromoCodeInvalid(this.message);
  @override
  List<Object?> get props => [message];
}
class PromoCodeError extends PromoCodeState {
  final String message;
  const PromoCodeError(this.message);
  @override
  List<Object?> get props => [message];
}

class PromoCodeCubit extends Cubit<PromoCodeState> {
  final PromoCodeService _service;
  PromoCodeCubit(this._service) : super(PromoCodeIdle());

  Future<void> validateCode(String code) async {
    if (code.trim().isEmpty) {
      emit(const PromoCodeInvalid("Code cannot be empty"));
      return;
    }

    emit(PromoCodeLoading());
    try {
      final promo = await _service.validatePromoCode(code: code);
      if (promo.valid) {
        emit(PromoCodeValid(promo));
      } else {
        emit(PromoCodeInvalid(promo.message.isNotEmpty ? promo.message : "Invalid or expired promo code"));
      }
    } catch (e) {
      emit(PromoCodeError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void reset() {
    emit(PromoCodeIdle());
  }
}
