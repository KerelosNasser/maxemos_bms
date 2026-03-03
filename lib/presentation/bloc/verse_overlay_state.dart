import 'package:equatable/equatable.dart';
import '../../core/utils/scriptural_regex_engine.dart';

abstract class VerseOverlayState extends Equatable {
  const VerseOverlayState();

  @override
  List<Object?> get props => [];
}

class VerseOverlayInitial extends VerseOverlayState {}

class VerseOverlayLoading extends VerseOverlayState {
  final BibleReference reference;
  const VerseOverlayLoading(this.reference);

  @override
  List<Object?> get props => [reference];
}

class VerseOverlayLoaded extends VerseOverlayState {
  final BibleReference reference;
  final String text;

  const VerseOverlayLoaded(this.reference, this.text);

  @override
  List<Object?> get props => [reference, text];
}

class VerseOverlayError extends VerseOverlayState {
  final BibleReference reference;
  final String message;

  const VerseOverlayError(this.reference, this.message);

  @override
  List<Object?> get props => [reference, message];
}
