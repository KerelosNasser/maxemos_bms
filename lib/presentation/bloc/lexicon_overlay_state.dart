import 'package:equatable/equatable.dart';

abstract class LexiconOverlayState extends Equatable {
  const LexiconOverlayState();

  @override
  List<Object?> get props => [];
}

class LexiconOverlayInitial extends LexiconOverlayState {}

class LexiconOverlayLoading extends LexiconOverlayState {}

class LexiconOverlayLoaded extends LexiconOverlayState {
  final Map<String, dynamic> definitionData;

  const LexiconOverlayLoaded(this.definitionData);

  @override
  List<Object?> get props => [definitionData];
}

class LexiconOverlayError extends LexiconOverlayState {
  final String message;

  const LexiconOverlayError(this.message);

  @override
  List<Object?> get props => [message];
}
