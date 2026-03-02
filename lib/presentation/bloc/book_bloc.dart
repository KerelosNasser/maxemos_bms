import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/drive_api_service.dart';
import '../../data/services/pdf_cache_service.dart';
import '../../data/models/book.dart';
import 'book_event.dart';
import 'book_state.dart';
import '../../core/utils/logger.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final DriveApiService driveApiService;

  BookBloc({required this.driveApiService}) : super(BookInitial()) {
    on<LoadBooksEvent>(_onLoadBooks);
    on<UploadBookEvent>(_onUploadBook);
    on<DeleteBookEvent>(_onDeleteBook);
    on<UpdateBookEvent>(_onUpdateBook);
  }

  Future<void> _onLoadBooks(
    LoadBooksEvent event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final books = await driveApiService.getFiles();
      // Cache book list for offline use
      PdfCacheService.cacheBookList(books);
      // Check which PDFs are cached locally
      final cachedIds = await PdfCacheService.getCachedBookIds();
      emit(BookLoaded(books, cachedBookIds: cachedIds));
    } catch (e) {
      logger.e('Failed to load books: $e');
      // Attempt to load from cache for offline mode
      final cachedBooks = await PdfCacheService.getCachedBookList();
      if (cachedBooks.isNotEmpty) {
        final cachedIds = await PdfCacheService.getCachedBookIds();
        emit(
          BookLoaded(cachedBooks, cachedBookIds: cachedIds, isOffline: true),
        );
      } else {
        emit(BookError(e.toString()));
      }
    }
  }

  Future<void> _onUploadBook(
    UploadBookEvent event,
    Emitter<BookState> emit,
  ) async {
    final currentState = state;
    List<Book> currentBooks = [];
    if (currentState is BookLoaded) {
      currentBooks = currentState.books;
    }

    // Start upload with 0 progress
    emit(const BookUploading(0.0));

    try {
      // Create a simulated progress stream wrapper since http.post doesn't
      // easily expose upload progress for base64 encoded JSON bodies.
      // In a real production app with multipart forms, you would use an
      // HTTP client like Dio for robust onSendProgress.

      // Run the progress simulation concurrently so it does not block the actual upload
      bool isUploading = true;
      Future<void> simulateProgress() async {
        double progress = 0.1;
        while (isUploading && progress <= 0.9) {
          await Future.delayed(const Duration(milliseconds: 400));
          if (isUploading && !emit.isDone) {
            emit(BookUploading(progress));
            progress += 0.1;
          }
        }
      }

      // Start simulation without awaiting
      simulateProgress();

      final newBook = await driveApiService.uploadFile(
        event.base64File,
        event.fileName,
        event.mimeType,
      );

      // Stop the simulation loop
      isUploading = false;

      if (!emit.isDone) emit(const BookUploading(1.0));

      // Emit success state briefly for UI feedback
      emit(BookUploadSuccess());

      // Return to loaded state with the new book appended
      emit(BookLoaded([...currentBooks, newBook]));
    } catch (e) {
      logger.e('Failed to upload book: $e');
      emit(BookUploadFailure(e.toString()));
      // Revert to previous loaded state if available, or initial
      if (currentBooks.isNotEmpty) {
        emit(BookLoaded(currentBooks));
      } else {
        emit(BookInitial());
      }
    }
  }

  Future<void> _onDeleteBook(
    DeleteBookEvent event,
    Emitter<BookState> emit,
  ) async {
    if (state is BookLoaded) {
      final currentState = state as BookLoaded;
      try {
        await driveApiService.deleteFile(event.fileId);
        final updatedBooks = currentState.books
            .where((b) => b.id != event.fileId)
            .toList();
        emit(BookLoaded(updatedBooks));
      } catch (e) {
        logger.e('Failed to delete book: $e');
        emit(BookError(e.toString()));
        emit(BookLoaded(currentState.books)); // Revert
      }
    }
  }

  Future<void> _onUpdateBook(
    UpdateBookEvent event,
    Emitter<BookState> emit,
  ) async {
    if (state is BookLoaded) {
      final currentState = state as BookLoaded;
      try {
        await driveApiService.updateFile(
          event.fileId,
          event.categories,
          event.summary,
        );

        final updatedBooks = currentState.books.map((b) {
          if (b.id == event.fileId) {
            return b.copyWith(
              categories: event.categories,
              summary: event.summary,
            );
          }
          return b;
        }).toList();

        emit(BookLoaded(updatedBooks));
      } catch (e) {
        logger.e('Failed to update book: $e');
        emit(BookError(e.toString()));
        emit(BookLoaded(currentState.books)); // Revert
      }
    }
  }
}
