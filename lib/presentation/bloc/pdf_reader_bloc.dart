import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';

import 'pdf_reader_event.dart';
import 'pdf_reader_state.dart';
import '../../../data/repositories/lexicon_repository.dart';
import '../../../core/utils/term_regex_engine.dart';

import 'mixins/pdf_search_mixin.dart';
import 'mixins/pdf_zoom_mixin.dart';
import 'mixins/pdf_highlight_mixin.dart';
import 'mixins/pdf_summarize_mixin.dart';
import 'mixins/pdf_download_mixin.dart';
import 'mixins/pdf_preferences_mixin.dart';

class PdfReaderBloc extends Bloc<PdfReaderEvent, PdfReaderState>
    with
        PdfSearchMixin,
        PdfZoomMixin,
        PdfHighlightMixin,
        PdfSummarizeMixin,
        PdfDownloadMixin,
        PdfPreferencesMixin {
  @override
  final PdfViewerController pdfController = PdfViewerController();
  final LexiconRepository _lexiconRepository = LexiconRepository();

  PdfReaderBloc() : super(PdfReaderState.initial()) {
    // Preferences Handling
    on<LoadPreferencesEvent>(onLoadPreferences);
    on<ToggleSepiaModeEvent>(onToggleSepiaMode);
    on<UpdateSepiaWeightEvent>(onUpdateSepiaWeight);
    on<ToggleNavigationZonesEvent>(onToggleNavigationZones);
    on<UpdateNavigationZonesWidthEvent>(onUpdateNavigationZonesWidth);

    // Download
    on<DownloadPdfEvent>(onDownloadPdf);
    on<DownloadProgressEvent>(onDownloadProgress);

    // Search
    on<ToggleSearchEvent>(onToggleSearch);
    on<SearchQueryChangedEvent>(onSearchQueryChanged);
    on<SearchNextMatchEvent>(onSearchNextMatch);
    on<SearchPrevMatchEvent>(onSearchPrevMatch);
    on<ToggleCaseSensitivityEvent>(onToggleCaseSensitivity);
    on<SearchMatchesUpdatedEvent>(onSearchMatchesUpdated);

    // UI
    on<ToggleUIVisibilityEvent>(_onToggleUIVisibility);
    on<PageChangedEvent>(_onPageChanged);

    // Zoom
    on<ZoomInEvent>(onZoomIn);
    on<ZoomOutEvent>(onZoomOut);
    on<ZoomResetEvent>(onZoomReset);
    on<UpdateZoomLevelEvent>(onUpdateZoomLevel);

    // Summarize
    on<SummarizePagesEvent>(onSummarizePages);

    // Highlights
    on<LoadHighlightsEvent>(onLoadHighlights);
    on<AddHighlightEvent>(onAddHighlight);
    on<RemoveHighlightEvent>(onRemoveHighlight);
    on<GoToHighlightEvent>(onGoToHighlight);
    on<ToggleHighlightPanelEvent>(onToggleHighlightPanel);
    on<SetSelectedTextEvent>(onSetSelectedText);
    on<ClearSelectedTextEvent>(onClearSelectedText);
    on<CheckDefinitionEvent>(_onCheckDefinition);
  }

  Future<void> _onCheckDefinition(
    CheckDefinitionEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    final cleanedTerm = TermRegexEngine.extractCoreRoot(event.selectedText);
    if (cleanedTerm.length < 3) {
      emit(state.copyWith(isDefinitionAvailable: false));
      return;
    }

    final definitionData = await _lexiconRepository.getDefinition(cleanedTerm);
    emit(state.copyWith(isDefinitionAvailable: definitionData != null));
  }

  @override
  Future<void> close() {
    disposeSearchMixin();
    return super.close();
  }

  // --- UI Handlers (The only ones kept in the main BLoC) ---

  void _onToggleUIVisibility(
    ToggleUIVisibilityEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    if (state.isUIVisible != event.isVisible) {
      emit(state.copyWith(isUIVisible: event.isVisible));
    }
  }

  void _onPageChanged(PageChangedEvent event, Emitter<PdfReaderState> emit) {
    emit(
      state.copyWith(
        currentPage: event.currentPage,
        totalPages: event.totalPages,
      ),
    );
  }
}

// Special states to trigger Dialogs in the UI (Listening)
class PdfReaderSummarySuccess extends PdfReaderState {
  final String summary;

  PdfReaderSummarySuccess(PdfReaderState state, this.summary)
    : super(
        pdfFilePath: state.pdfFilePath,
        isDownloading: state.isDownloading,
        downloadProgress: state.downloadProgress,
        downloadError: state.downloadError,
        isUIVisible: state.isUIVisible,
        currentPage: state.currentPage,
        totalPages: state.totalPages,
        isSearching: state.isSearching,
        searchMatchCount: state.searchMatchCount,
        searchCurrentIndex: state.searchCurrentIndex,
        isCaseSensitive: state.isCaseSensitive,
        zoomLevel: state.zoomLevel,
        isSummarizing: false,
        highlights: state.highlights,
        isHighlightPanelOpen: state.isHighlightPanelOpen,
        isDefinitionAvailable: state.isDefinitionAvailable,
        isSepiaModeEnabled: state.isSepiaModeEnabled,
        sepiaWeight: state.sepiaWeight,
        isNavigationZonesEnabled: state.isNavigationZonesEnabled,
        navigationZonesWidth: state.navigationZonesWidth,
      );
}

class PdfReaderSummaryFailure extends PdfReaderState {
  final String errorMessage;

  PdfReaderSummaryFailure(PdfReaderState state, this.errorMessage)
    : super(
        pdfFilePath: state.pdfFilePath,
        isDownloading: state.isDownloading,
        downloadProgress: state.downloadProgress,
        downloadError: state.downloadError,
        isUIVisible: state.isUIVisible,
        currentPage: state.currentPage,
        totalPages: state.totalPages,
        isSearching: state.isSearching,
        searchMatchCount: state.searchMatchCount,
        searchCurrentIndex: state.searchCurrentIndex,
        isCaseSensitive: state.isCaseSensitive,
        zoomLevel: state.zoomLevel,
        isSummarizing: false,
        highlights: state.highlights,
        isHighlightPanelOpen: state.isHighlightPanelOpen,
        isDefinitionAvailable: state.isDefinitionAvailable,
        isSepiaModeEnabled: state.isSepiaModeEnabled,
        sepiaWeight: state.sepiaWeight,
        isNavigationZonesEnabled: state.isNavigationZonesEnabled,
        navigationZonesWidth: state.navigationZonesWidth,
      );
}
