import 'package:equatable/equatable.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object> get props => [];
}

class LoadBooksEvent extends BookEvent {}

class UploadBookEvent extends BookEvent {
  final String base64File;
  final String fileName;
  final String mimeType;

  const UploadBookEvent({
    required this.base64File,
    required this.fileName,
    required this.mimeType,
  });

  @override
  List<Object> get props => [base64File, fileName, mimeType];
}

class DeleteBookEvent extends BookEvent {
  final String fileId;

  const DeleteBookEvent(this.fileId);

  @override
  List<Object> get props => [fileId];
}

class UpdateBookEvent extends BookEvent {
  final String fileId;
  final List<String> categories;
  final String summary;

  const UpdateBookEvent({
    required this.fileId,
    required this.categories,
    required this.summary,
  });

  @override
  List<Object> get props => [fileId, categories, summary];
}
