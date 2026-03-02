import 'package:equatable/equatable.dart';
import '../../../data/models/highlight.dart';

class PdfReaderState extends Equatable {
  // UI
  final bool isUIVisible;

  // Search
  final bool isSearching;
  final int searchMatchCount;
  final int searchCurrentIndex;
  final bool isCaseSensitive;

  // Zoom
  final double zoomLevel;

  // Summarize
  final bool isSummarizing;

  // Highlights
  final List<Highlight> highlights;
  final bool isHighlightPanelOpen;
  final String? selectedText;
  final int? selectedPageNumber;

  const PdfReaderState({
    required this.isUIVisible,
    required this.isSearching,
    required this.searchMatchCount,
    required this.searchCurrentIndex,
    required this.isCaseSensitive,
    required this.zoomLevel,
    required this.isSummarizing,
    required this.highlights,
    required this.isHighlightPanelOpen,
    this.selectedText,
    this.selectedPageNumber,
  });

  factory PdfReaderState.initial() {
    return const PdfReaderState(
      isUIVisible: true,
      isSearching: false,
      searchMatchCount: 0,
      searchCurrentIndex: -1,
      isCaseSensitive: false,
      zoomLevel: 1.0,
      isSummarizing: false,
      highlights: [],
      isHighlightPanelOpen: false,
      selectedText: null,
      selectedPageNumber: null,
    );
  }

  PdfReaderState copyWith({
    bool? isUIVisible,
    bool? isSearching,
    int? searchMatchCount,
    int? searchCurrentIndex,
    bool? isCaseSensitive,
    double? zoomLevel,
    bool? isSummarizing,
    List<Highlight>? highlights,
    bool? isHighlightPanelOpen,
    String? selectedText,
    int? selectedPageNumber,
    bool clearSelectedText = false,
  }) {
    return PdfReaderState(
      isUIVisible: isUIVisible ?? this.isUIVisible,
      isSearching: isSearching ?? this.isSearching,
      searchMatchCount: searchMatchCount ?? this.searchMatchCount,
      searchCurrentIndex: searchCurrentIndex ?? this.searchCurrentIndex,
      isCaseSensitive: isCaseSensitive ?? this.isCaseSensitive,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      isSummarizing: isSummarizing ?? this.isSummarizing,
      highlights: highlights ?? this.highlights,
      isHighlightPanelOpen: isHighlightPanelOpen ?? this.isHighlightPanelOpen,
      selectedText: clearSelectedText
          ? null
          : (selectedText ?? this.selectedText),
      selectedPageNumber: clearSelectedText
          ? null
          : (selectedPageNumber ?? this.selectedPageNumber),
    );
  }

  @override
  List<Object?> get props => [
    isUIVisible,
    isSearching,
    searchMatchCount,
    searchCurrentIndex,
    isCaseSensitive,
    zoomLevel,
    isSummarizing,
    highlights,
    isHighlightPanelOpen,
    selectedText,
    selectedPageNumber,
  ];
}
