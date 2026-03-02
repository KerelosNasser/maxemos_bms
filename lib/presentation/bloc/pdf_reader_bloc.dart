import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/notification_service.dart';
import 'pdf_reader_event.dart';
import 'pdf_reader_state.dart';

class PdfReaderBloc extends Bloc<PdfReaderEvent, PdfReaderState> {
  PdfReaderBloc() : super(PdfReaderState.initial()) {
    on<ToggleSearchEvent>(_onToggleSearch);
    on<ToggleUIVisibilityEvent>(_onToggleUIVisibility);
    on<SummarizePagesEvent>(_onSummarizePages);
  }

  void _onToggleSearch(ToggleSearchEvent event, Emitter<PdfReaderState> emit) {
    emit(state.copyWith(isSearching: !state.isSearching));
  }

  void _onToggleUIVisibility(
    ToggleUIVisibilityEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    if (state.isUIVisible != event.isVisible) {
      emit(state.copyWith(isUIVisible: event.isVisible));
    }
  }

  Future<void> _onSummarizePages(
    SummarizePagesEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    emit(state.copyWith(isSummarizing: true));

    try {
      NotificationService.showNotification(
        id: 7,
        title: 'Extracting Arabic Text',
        body: 'Running OCR on pages ${event.startPage} to ${event.endPage}...',
      );

      // Simulate OCR extraction for now to keep it lightweight,
      // or retrieve real text if standard pdfrx text retrieval is available.
      await Future.delayed(const Duration(seconds: 2));

      String extractedText =
          "Extracted text payload from pages ${event.startPage} to ${event.endPage} from the book ${event.bookTitle}.";

      final summary = await GeminiService.summarizeExcerpt(
        extractedText,
        event.startPage,
        event.endPage,
      );

      // Show dialog requires context, so we'll pass the result back
      // via a callback or handle it in BlocListener in the UI.
      // For now, we just turn off summarizing state.
      // We will handle showing the Dialog directly from the BlocListener.
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

// Special states to trigger Dialogs in the UI (Listening)
class PdfReaderSummarySuccess extends PdfReaderState {
  final String summary;

  PdfReaderSummarySuccess(PdfReaderState state, this.summary)
    : super(
        isUIVisible: state.isUIVisible,
        isSearching: state.isSearching,
        isSummarizing: false,
      );
}

class PdfReaderSummaryFailure extends PdfReaderState {
  final String errorMessage;

  PdfReaderSummaryFailure(PdfReaderState state, this.errorMessage)
    : super(
        isUIVisible: state.isUIVisible,
        isSearching: state.isSearching,
        isSummarizing: false,
      );
}
