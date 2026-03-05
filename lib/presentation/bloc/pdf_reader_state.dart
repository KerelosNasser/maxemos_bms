import 'package:equatable/equatable.dart';
import '../../../data/models/highlight.dart';

class PdfReaderState extends Equatable {
  // Download
  final String? pdfFilePath;
  final bool isDownloading;
  final double downloadProgress;
  final String? downloadError;

  // UI
  final bool isUIVisible;

  // Page tracking
  final int currentPage;
  final int totalPages;

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
  final bool isDefinitionAvailable;

  // Accessibility Preferences
  final bool isSepiaModeEnabled;
  final double sepiaWeight;
  final bool isNavigationZonesEnabled;
  final double navigationZonesWidth;

  const PdfReaderState({
    this.pdfFilePath,
    required this.isDownloading,
    required this.downloadProgress,
    this.downloadError,
    required this.isUIVisible,
    required this.currentPage,
    required this.totalPages,
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
    required this.isDefinitionAvailable,
    required this.isSepiaModeEnabled,
    required this.sepiaWeight,
    required this.isNavigationZonesEnabled,
    required this.navigationZonesWidth,
  });

  factory PdfReaderState.initial() {
    return const PdfReaderState(
      pdfFilePath: null,
      isDownloading: false,
      downloadProgress: 0.0,
      downloadError: null,
      isUIVisible: true,
      currentPage: 1,
      totalPages: 0,
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
      isDefinitionAvailable: false,
      isSepiaModeEnabled: false,
      sepiaWeight: 1.0,
      isNavigationZonesEnabled: false,
      navigationZonesWidth: 0.15,
    );
  }

  PdfReaderState copyWith({
    String? pdfFilePath,
    bool? isDownloading,
    double? downloadProgress,
    String? downloadError,
    bool clearDownloadError = false,
    bool? isUIVisible,
    int? currentPage,
    int? totalPages,
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
    bool? isDefinitionAvailable,
    bool? isSepiaModeEnabled,
    double? sepiaWeight,
    bool? isNavigationZonesEnabled,
    double? navigationZonesWidth,
  }) {
    return PdfReaderState(
      pdfFilePath: pdfFilePath ?? this.pdfFilePath,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadError: clearDownloadError
          ? null
          : (downloadError ?? this.downloadError),
      isUIVisible: isUIVisible ?? this.isUIVisible,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
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
      isDefinitionAvailable: clearSelectedText
          ? false
          : (isDefinitionAvailable ?? this.isDefinitionAvailable),
      isSepiaModeEnabled: isSepiaModeEnabled ?? this.isSepiaModeEnabled,
      sepiaWeight: sepiaWeight ?? this.sepiaWeight,
      isNavigationZonesEnabled:
          isNavigationZonesEnabled ?? this.isNavigationZonesEnabled,
      navigationZonesWidth: navigationZonesWidth ?? this.navigationZonesWidth,
    );
  }

  @override
  List<Object?> get props => [
    pdfFilePath,
    isDownloading,
    downloadProgress,
    downloadError,
    isUIVisible,
    currentPage,
    totalPages,
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
    isDefinitionAvailable,
    isSepiaModeEnabled,
    sepiaWeight,
    isNavigationZonesEnabled,
    navigationZonesWidth,
  ];
}
