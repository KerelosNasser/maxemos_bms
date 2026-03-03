import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/services/gemini_service.dart';
import '../../../core/services/notification_service.dart';
import '../pdf_reader_event.dart';
import '../pdf_reader_state.dart';
import '../pdf_reader_bloc.dart'; // For PdfReaderSummarySuccess/Failure states

mixin PdfSummarizeMixin on Bloc<PdfReaderEvent, PdfReaderState> {
  PdfViewerController get pdfController;

  Future<void> onSummarizePages(
    SummarizePagesEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    emit(state.copyWith(isSummarizing: true));

    try {
      NotificationService.showNotification(
        id: 7,
        title: 'استخراج النص',
        body:
            'جاري استخراج النص من صفحات ${event.startPage} إلى ${event.endPage}...',
      );

      final document = pdfController.document;

      final buffer = StringBuffer();
      final totalPages = document.pages.length;
      final start = event.startPage.clamp(1, totalPages);
      final end = event.endPage.clamp(start, totalPages);

      for (int i = start; i <= end; i++) {
        final page = document.pages[i - 1]; // 0-indexed
        final pageText = await page.loadText();
        final text = pageText?.fullText.trim() ?? '';
        if (text.isNotEmpty) {
          buffer.writeln('--- صفحة $i ---');
          buffer.writeln(text);
          buffer.writeln();
        }
      }

      String extractedText = buffer.toString().trim();
      if (extractedText.isEmpty) {
        extractedText =
            'لم يتم العثور على نص قابل للاستخراج في الصفحات $start إلى $end من كتاب ${event.bookTitle}. قد تكون الصفحات عبارة عن صور.';
      }

      // Safety: cap at ~30k chars to avoid oversized Gemini requests
      const maxChars = 30000;
      if (extractedText.length > maxChars) {
        extractedText =
            '${extractedText.substring(0, maxChars)}\n\n[... تم اقتطاع النص بسبب الطول]';
      }

      final summary = await GeminiService.summarizeExcerpt(
        extractedText,
        event.startPage,
        event.endPage,
      );

      emit(PdfReaderSummarySuccess(state, summary));
    } catch (e) {
      NotificationService.showNotification(
        id: 8,
        title: 'Summarization Failed',
        body: e.toString(),
      );
      emit(PdfReaderSummaryFailure(state, e.toString()));
    } finally {
      emit(state.copyWith(isSummarizing: false));
    }
  }
}
