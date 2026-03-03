import '../../../data/models/highlight.dart';

abstract class PdfReaderEvent {}

// --- Download Events ---
class DownloadPdfEvent extends PdfReaderEvent {
  final String bookId;
  final String downloadUrl;
  DownloadPdfEvent({required this.bookId, required this.downloadUrl});
}

class DownloadProgressEvent extends PdfReaderEvent {
  final double progress;
  DownloadProgressEvent(this.progress);
}

// --- Search Events ---
class ToggleSearchEvent extends PdfReaderEvent {}

class SearchQueryChangedEvent extends PdfReaderEvent {
  final String query;
  SearchQueryChangedEvent(this.query);
}

class SearchNextMatchEvent extends PdfReaderEvent {}

class SearchPrevMatchEvent extends PdfReaderEvent {}

class ToggleCaseSensitivityEvent extends PdfReaderEvent {}

class SearchMatchesUpdatedEvent extends PdfReaderEvent {
  final int matchCount;
  final int currentIndex;
  SearchMatchesUpdatedEvent({
    required this.matchCount,
    required this.currentIndex,
  });
}

// --- UI Events ---
class ToggleUIVisibilityEvent extends PdfReaderEvent {
  final bool isVisible;
  ToggleUIVisibilityEvent(this.isVisible);
}

class PageChangedEvent extends PdfReaderEvent {
  final int currentPage;
  final int totalPages;
  PageChangedEvent({required this.currentPage, required this.totalPages});
}

// --- Zoom Events ---
class ZoomInEvent extends PdfReaderEvent {}

class ZoomOutEvent extends PdfReaderEvent {}

class ZoomResetEvent extends PdfReaderEvent {}

class UpdateZoomLevelEvent extends PdfReaderEvent {
  final double zoom;
  UpdateZoomLevelEvent(this.zoom);
}

// --- Summarize Events ---
class SummarizePagesEvent extends PdfReaderEvent {
  final int startPage;
  final int endPage;
  final String bookTitle;

  SummarizePagesEvent({
    required this.startPage,
    required this.endPage,
    required this.bookTitle,
  });
}

// --- Highlight Events ---
class LoadHighlightsEvent extends PdfReaderEvent {
  final String bookId;
  LoadHighlightsEvent(this.bookId);
}

class AddHighlightEvent extends PdfReaderEvent {
  final Highlight highlight;
  final String bookId;
  AddHighlightEvent({required this.highlight, required this.bookId});
}

class RemoveHighlightEvent extends PdfReaderEvent {
  final String highlightId;
  final String bookId;
  RemoveHighlightEvent({required this.highlightId, required this.bookId});
}

class GoToHighlightEvent extends PdfReaderEvent {
  final Highlight highlight;
  GoToHighlightEvent(this.highlight);
}

class ToggleHighlightPanelEvent extends PdfReaderEvent {}

class SetSelectedTextEvent extends PdfReaderEvent {
  final String text;
  final int pageNumber;
  SetSelectedTextEvent({required this.text, required this.pageNumber});
}

class ClearSelectedTextEvent extends PdfReaderEvent {}

// --- Accessibility/Ergonomics Events ---
class LoadPreferencesEvent extends PdfReaderEvent {}

class ToggleSepiaModeEvent extends PdfReaderEvent {}

class ToggleNavigationZonesEvent extends PdfReaderEvent {}
