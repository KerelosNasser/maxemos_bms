import 'package:equatable/equatable.dart';

class AskAiMessage extends Equatable {
  final String role; // 'user' or 'ai'
  final String content;
  final bool isError;

  const AskAiMessage({
    required this.role,
    required this.content,
    this.isError = false,
  });

  @override
  List<Object?> get props => [role, content, isError];
}

class AskAiState extends Equatable {
  final String? sessionId;
  final String? bookTitle;
  final String? selectedText;
  final List<AskAiMessage> messages;
  final bool isLoading;

  const AskAiState({
    this.sessionId,
    this.bookTitle,
    this.selectedText,
    this.messages = const [],
    this.isLoading = false,
  });

  AskAiState copyWith({
    String? sessionId,
    String? bookTitle,
    String? selectedText,
    List<AskAiMessage>? messages,
    bool? isLoading,
  }) {
    return AskAiState(
      sessionId: sessionId ?? this.sessionId,
      bookTitle: bookTitle ?? this.bookTitle,
      selectedText: selectedText ?? this.selectedText,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    sessionId,
    bookTitle,
    selectedText,
    messages,
    isLoading,
  ];
}
