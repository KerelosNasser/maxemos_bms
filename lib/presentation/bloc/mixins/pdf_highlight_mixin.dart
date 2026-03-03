import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../data/services/highlight_service.dart';
import '../pdf_reader_event.dart';
import '../pdf_reader_state.dart';

mixin PdfHighlightMixin on Bloc<PdfReaderEvent, PdfReaderState> {
  PdfViewerController get pdfController;

  Future<void> onLoadHighlights(
    LoadHighlightsEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    final highlights = await HighlightService.getHighlights(event.bookId);
    emit(state.copyWith(highlights: highlights));
  }

  Future<void> onAddHighlight(
    AddHighlightEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    await HighlightService.saveHighlight(event.bookId, event.highlight);
    final updated = await HighlightService.getHighlights(event.bookId);
    emit(state.copyWith(highlights: updated, clearSelectedText: true));
  }

  Future<void> onRemoveHighlight(
    RemoveHighlightEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    await HighlightService.removeHighlight(event.bookId, event.highlightId);
    final updated = await HighlightService.getHighlights(event.bookId);
    emit(state.copyWith(highlights: updated));
  }

  void onGoToHighlight(GoToHighlightEvent event, Emitter<PdfReaderState> emit) {
    pdfController.goToPage(pageNumber: event.highlight.pageNumber);
    emit(state.copyWith(isHighlightPanelOpen: false));
  }

  void onToggleHighlightPanel(
    ToggleHighlightPanelEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    emit(state.copyWith(isHighlightPanelOpen: !state.isHighlightPanelOpen));
  }

  void onSetSelectedText(
    SetSelectedTextEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    emit(
      state.copyWith(
        selectedText: event.text,
        selectedPageNumber: event.pageNumber,
      ),
    );
  }

  void onClearSelectedText(
    ClearSelectedTextEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    emit(state.copyWith(clearSelectedText: true));
  }
}
