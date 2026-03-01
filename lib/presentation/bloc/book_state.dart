import 'package:equatable/equatable.dart';
import '../../data/models/book.dart';

abstract class BookState extends Equatable {
  const BookState();

  @override
  List<Object> get props => [];
}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BookLoaded extends BookState {
  final List<Book> books;

  const BookLoaded(this.books);

  @override
  List<Object> get props => [books];
}

class BookError extends BookState {
  final String message;

  const BookError(this.message);

  @override
  List<Object> get props => [message];
}

// Additional states for specific actions (feedback)
class BookUploading extends BookState {
  final double progress;
  const BookUploading(this.progress);

  @override
  List<Object> get props => [progress];
}

class BookUploadSuccess extends BookState {}

class BookUploadFailure extends BookState {
  final String message;
  const BookUploadFailure(this.message);
  @override
  List<Object> get props => [message];
}
