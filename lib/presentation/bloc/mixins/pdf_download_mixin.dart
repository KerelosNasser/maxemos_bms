import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/pdf_cache_service.dart';
import '../pdf_reader_event.dart';
import '../pdf_reader_state.dart';

mixin PdfDownloadMixin on Bloc<PdfReaderEvent, PdfReaderState> {
  Future<void> onDownloadPdf(
    DownloadPdfEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    // ── Fast-path: serve from disk cache without any loading UI ──
    final cachedFile = await PdfCacheService.getCachedFileIfExists(
      event.bookId,
    );
    if (cachedFile != null) {
      emit(
        state.copyWith(
          isDownloading: false,
          downloadProgress: 1.0,
          pdfFilePath: cachedFile.path,
          clearDownloadError: true,
        ),
      );
      return; // Done — no network needed.
    }

    emit(
      state.copyWith(
        isDownloading: true,
        downloadProgress: 0.0,
        clearDownloadError: true,
      ),
    );
    try {
      final file = await PdfCacheService.getCachedPdf(
        bookId: event.bookId,
        downloadUrl: event.downloadUrl,
        onProgress: (received, total) {
          if (total > 0) {
            add(DownloadProgressEvent(received / total));
          }
        },
      );
      emit(
        state.copyWith(
          isDownloading: false,
          downloadProgress: 1.0,
          pdfFilePath: file.path,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isDownloading: false, downloadError: e.toString()));
    }
  }

  void onDownloadProgress(
    DownloadProgressEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    emit(state.copyWith(downloadProgress: event.progress));
  }
}
