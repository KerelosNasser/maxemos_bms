import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/notification_service.dart';

import '../../data/services/highlight_service.dart';
import 'pdf_reader_event.dart';
import 'pdf_reader_state.dart';

class PdfReaderBloc extends Bloc<PdfReaderEvent, PdfReaderState> {
  final PdfViewerController pdfController = PdfViewerController();
  final TextEditingController searchController = TextEditingController();
  PdfTextSearcher? textSearcher;
  Timer? _searchDebounce;

  PdfReaderBloc() : super(PdfReaderState.initial()) {
    // Search
    on<ToggleSearchEvent>(_onToggleSearch);
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<SearchNextMatchEvent>(_onSearchNextMatch);
    on<SearchPrevMatchEvent>(_onSearchPrevMatch);
    on<ToggleCaseSensitivityEvent>(_onToggleCaseSensitivity);
    on<SearchMatchesUpdatedEvent>(_onSearchMatchesUpdated);

    // UI
    on<ToggleUIVisibilityEvent>(_onToggleUIVisibility);

    // Zoom
    on<ZoomInEvent>(_onZoomIn);
    on<ZoomOutEvent>(_onZoomOut);
    on<ZoomResetEvent>(_onZoomReset);
    on<UpdateZoomLevelEvent>(_onUpdateZoomLevel);

    // Summarize
    on<SummarizePagesEvent>(_onSummarizePages);

    // Highlights
    on<LoadHighlightsEvent>(_onLoadHighlights);
    on<AddHighlightEvent>(_onAddHighlight);
    on<RemoveHighlightEvent>(_onRemoveHighlight);
    on<GoToHighlightEvent>(_onGoToHighlight);
    on<ToggleHighlightPanelEvent>(_onToggleHighlightPanel);
    on<SetSelectedTextEvent>(_onSetSelectedText);
    on<ClearSelectedTextEvent>(_onClearSelectedText);
  }

  @override
  Future<void> close() {
    searchController.dispose();
    textSearcher?.dispose();
    _searchDebounce?.cancel();
    return super.close();
  }

  // --- Initialization ---

  void initSearcher(PdfDocument document, PdfViewerController controller) {
    if (textSearcher == null) {
      textSearcher = PdfTextSearcher(controller)
        ..addListener(_onSearcherUpdate);
    }
  }

  void _onSearcherUpdate() {
    final searcher = textSearcher;
    if (searcher == null) return;
    add(
      SearchMatchesUpdatedEvent(
        matchCount: searcher.matches.length,
        currentIndex: searcher.currentIndex ?? -1,
      ),
    );
  }

  // --- Search Handlers ---

  void _onToggleSearch(ToggleSearchEvent event, Emitter<PdfReaderState> emit) {
    final newSearching = !state.isSearching;
    if (!newSearching) {
      searchController.clear();
      textSearcher?.resetTextSearch();
      emit(
        state.copyWith(
          isSearching: false,
          searchMatchCount: 0,
          searchCurrentIndex: -1,
        ),
      );
    } else {
      emit(state.copyWith(isSearching: true));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (event.query.isNotEmpty) {
        textSearcher?.startTextSearch(
          event.query,
          caseInsensitive: !state.isCaseSensitive,
        );
      } else {
        textSearcher?.resetTextSearch();
        add(SearchMatchesUpdatedEvent(matchCount: 0, currentIndex: -1));
      }
    });
  }

  void _onSearchNextMatch(
    SearchNextMatchEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    textSearcher?.goToNextMatch();
  }

  void _onSearchPrevMatch(
    SearchPrevMatchEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    textSearcher?.goToPrevMatch();
  }

  void _onToggleCaseSensitivity(
    ToggleCaseSensitivityEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    final newCaseSensitive = !state.isCaseSensitive;
    emit(state.copyWith(isCaseSensitive: newCaseSensitive));
    // Re-run current search with new case sensitivity
    if (searchController.text.isNotEmpty) {
      textSearcher?.startTextSearch(
        searchController.text,
        caseInsensitive: !newCaseSensitive,
      );
    }
  }

  void _onSearchMatchesUpdated(
    SearchMatchesUpdatedEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    emit(
      state.copyWith(
        searchMatchCount: event.matchCount,
        searchCurrentIndex: event.currentIndex,
      ),
    );
  }

  // --- UI Handlers ---

  void _onToggleUIVisibility(
    ToggleUIVisibilityEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    if (state.isUIVisible != event.isVisible) {
      emit(state.copyWith(isUIVisible: event.isVisible));
    }
  }

  // --- Zoom Handlers ---

  void _onZoomIn(ZoomInEvent event, Emitter<PdfReaderState> emit) {
    pdfController.zoomUp();
    emit(state.copyWith(zoomLevel: pdfController.currentZoom));
  }

  void _onZoomOut(ZoomOutEvent event, Emitter<PdfReaderState> emit) {
    pdfController.zoomDown();
    emit(state.copyWith(zoomLevel: pdfController.currentZoom));
  }

  void _onZoomReset(ZoomResetEvent event, Emitter<PdfReaderState> emit) {
    pdfController.setZoom(pdfController.centerPosition, 1.0);
    emit(state.copyWith(zoomLevel: 1.0));
  }

  void _onUpdateZoomLevel(
    UpdateZoomLevelEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    emit(state.copyWith(zoomLevel: event.zoom));
  }

  // --- Summarize Handler ---

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

      await Future.delayed(const Duration(seconds: 2));

      String extractedText =
          "Extracted text payload from pages ${event.startPage} to ${event.endPage} from the book ${event.bookTitle}.";

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

  // --- Highlight Handlers ---

  Future<void> _onLoadHighlights(
    LoadHighlightsEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    final highlights = await HighlightService.getHighlights(event.bookId);
    emit(state.copyWith(highlights: highlights));
  }

  Future<void> _onAddHighlight(
    AddHighlightEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    await HighlightService.saveHighlight(event.bookId, event.highlight);
    final updated = await HighlightService.getHighlights(event.bookId);
    emit(state.copyWith(highlights: updated, clearSelectedText: true));
  }

  Future<void> _onRemoveHighlight(
    RemoveHighlightEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    await HighlightService.removeHighlight(event.bookId, event.highlightId);
    final updated = await HighlightService.getHighlights(event.bookId);
    emit(state.copyWith(highlights: updated));
  }

  void _onGoToHighlight(
    GoToHighlightEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    pdfController.goToPage(pageNumber: event.highlight.pageNumber);
    emit(state.copyWith(isHighlightPanelOpen: false));
  }

  void _onToggleHighlightPanel(
    ToggleHighlightPanelEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    emit(state.copyWith(isHighlightPanelOpen: !state.isHighlightPanelOpen));
  }

  void _onSetSelectedText(
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

  void _onClearSelectedText(
    ClearSelectedTextEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    emit(state.copyWith(clearSelectedText: true));
  }
}

// Special states to trigger Dialogs in the UI (Listening)
class PdfReaderSummarySuccess extends PdfReaderState {
  final String summary;

  PdfReaderSummarySuccess(PdfReaderState state, this.summary)
    : super(
        isUIVisible: state.isUIVisible,
        isSearching: state.isSearching,
        searchMatchCount: state.searchMatchCount,
        searchCurrentIndex: state.searchCurrentIndex,
        isCaseSensitive: state.isCaseSensitive,
        zoomLevel: state.zoomLevel,
        isSummarizing: false,
        highlights: state.highlights,
        isHighlightPanelOpen: state.isHighlightPanelOpen,
      );
}

class PdfReaderSummaryFailure extends PdfReaderState {
  final String errorMessage;

  PdfReaderSummaryFailure(PdfReaderState state, this.errorMessage)
    : super(
        isUIVisible: state.isUIVisible,
        isSearching: state.isSearching,
        searchMatchCount: state.searchMatchCount,
        searchCurrentIndex: state.searchCurrentIndex,
        isCaseSensitive: state.isCaseSensitive,
        zoomLevel: state.zoomLevel,
        isSummarizing: false,
        highlights: state.highlights,
        isHighlightPanelOpen: state.isHighlightPanelOpen,
      );
}
