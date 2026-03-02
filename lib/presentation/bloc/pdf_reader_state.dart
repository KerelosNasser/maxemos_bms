import 'package:equatable/equatable.dart';

class PdfReaderState extends Equatable {
  final bool isUIVisible;
  final bool isSearching;
  final bool isSummarizing;

  const PdfReaderState({
    required this.isUIVisible,
    required this.isSearching,
    required this.isSummarizing,
  });

  factory PdfReaderState.initial() {
    return const PdfReaderState(
      isUIVisible: true,
      isSearching: false,
      isSummarizing: false,
    );
  }

  PdfReaderState copyWith({
    bool? isUIVisible,
    bool? isSearching,
    bool? isSummarizing,
  }) {
    return PdfReaderState(
      isUIVisible: isUIVisible ?? this.isUIVisible,
      isSearching: isSearching ?? this.isSearching,
      isSummarizing: isSummarizing ?? this.isSummarizing,
    );
  }

  @override
  List<Object?> get props => [isUIVisible, isSearching, isSummarizing];
}
