import 'package:equatable/equatable.dart';

abstract class RateCoachState extends Equatable {
  const RateCoachState();

  @override
  List<Object> get props => [];
}

class RateCoachInitial extends RateCoachState {}

class RateCoachLoading extends RateCoachState {}

class RateCoachSuccess extends RateCoachState {}

class RateCoachError extends RateCoachState {
  final String message;

  const RateCoachError(this.message);

  @override
  List<Object> get props => [message];
}
