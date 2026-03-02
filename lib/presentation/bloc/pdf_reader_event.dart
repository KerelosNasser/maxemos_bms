abstract class PdfReaderEvent {}

class ToggleSearchEvent extends PdfReaderEvent {}

class SearchQueryChangedEvent extends PdfReaderEvent {
  final String query;
  SearchQueryChangedEvent(this.query);
}

class ToggleUIVisibilityEvent extends PdfReaderEvent {
  final bool isVisible;
  ToggleUIVisibilityEvent(this.isVisible);
}

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
