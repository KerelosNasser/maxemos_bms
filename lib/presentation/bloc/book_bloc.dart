import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/drive_api_service.dart';
import '../../data/services/pdf_cache_service.dart';
import '../../data/models/book.dart';
import 'book_event.dart';
import 'book_state.dart';
import '../../core/utils/logger.dart';

// ─── Internal events (private to this file) ────────────────────────────────

/// Fired by the background refresh to push a successful book list into the UI.
class _BookRefreshLoaded extends BookEvent {
  final List<Book> books;
  final Set<String> cachedIds;
  final bool isOffline;
  const _BookRefreshLoaded(
    this.books,
    this.cachedIds, {
    this.isOffline = false,
  });
}

/// Fired by the background refresh to surface a fatal error.
class _BookRefreshError extends BookEvent {
  final String message;
  const _BookRefreshError(this.message);
}

// ─── Bloc ───────────────────────────────────────────────────────────────────

class BookBloc extends Bloc<BookEvent, BookState> {
  final DriveApiService driveApiService;

  BookBloc({required this.driveApiService}) : super(BookInitial()) {
    on<LoadBooksEvent>(_onLoadBooks);
    // Internal events driven by the background refresh:
    on<_BookRefreshLoaded>(_onRefreshLoaded);
    on<_BookRefreshError>(_onRefreshError);
    on<UploadBookEvent>(_onUploadBook);
    on<DeleteBookEvent>(_onDeleteBook);
    on<UpdateBookEvent>(_onUpdateBook);
  }

  // ── Load (instant cache-first, then background refresh) ──────────────────

  /// Returns immediately after serving cached data.
  /// Background network refresh is fired concurrently via [_refreshInBackground].
  Future<void> _onLoadBooks(
    LoadBooksEvent event,
    Emitter<BookState> emit,
  ) async {
    final cachedBooks = await PdfCacheService.getCachedBookList();

    if (cachedBooks.isNotEmpty) {
      // Serve from cache instantly — no loading spinner shown.
      final cachedIds = await PdfCacheService.getCachedBookIds();
      emit(BookLoaded(cachedBooks, cachedBookIds: cachedIds));
    } else {
      // First-ever launch: nothing cached, display spinner during initial fetch.
      emit(BookLoading());
    }

    // Fire and forget — handler exits now, network runs independently.
    unawaited(_refreshInBackground(cachedBooks));
  }

  /// Fetches fresh data from the network without blocking the BLoC event queue.
  /// Results are fed back through internal events so they go through the
  /// normal [emit] mechanism inside a registered handler.
  Future<void> _refreshInBackground(List<Book> previousCache) async {
    try {
      final books = await driveApiService.getFiles();
      unawaited(PdfCacheService.cacheBookList(books));
      final cachedIds = await PdfCacheService.getCachedBookIds();
      if (!isClosed) add(_BookRefreshLoaded(books, cachedIds));
    } catch (e) {
      logger.e('Background refresh failed: $e');
      if (isClosed) return;
      if (previousCache.isNotEmpty) {
        // Network is down but we have cached data — show offline banner.
        final cachedIds = await PdfCacheService.getCachedBookIds();
        add(_BookRefreshLoaded(previousCache, cachedIds, isOffline: true));
      } else {
        // Truly nothing to show.
        add(_BookRefreshError(e.toString()));
      }
    }
  }

  void _onRefreshLoaded(_BookRefreshLoaded event, Emitter<BookState> emit) {
    emit(
      BookLoaded(
        event.books,
        cachedBookIds: event.cachedIds,
        isOffline: event.isOffline,
      ),
    );
  }

  void _onRefreshError(_BookRefreshError event, Emitter<BookState> emit) {
    emit(BookError(event.message));
  }

  // ── Upload ─────────────────────────────────────────────────────────────

  Future<void> _onUploadBook(
    UploadBookEvent event,
    Emitter<BookState> emit,
  ) async {
    final currentState = state;
    List<Book> currentBooks = [];
    if (currentState is BookLoaded) {
      currentBooks = currentState.books;
    }

    emit(const BookUploading(0.0));

    try {
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

      unawaited(simulateProgress());

      final newBook = await driveApiService.uploadFile(
        event.base64File,
        event.fileName,
        event.mimeType,
      );

      isUploading = false;

      if (!emit.isDone) emit(const BookUploading(1.0));
      emit(BookUploadSuccess());
      emit(BookLoaded([...currentBooks, newBook]));
    } catch (e) {
      logger.e('Failed to upload book: $e');
      emit(BookUploadFailure(e.toString()));
      if (currentBooks.isNotEmpty) {
        emit(BookLoaded(currentBooks));
      } else {
        emit(BookInitial());
      }
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────

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

  // ── Update ─────────────────────────────────────────────────────────────

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
