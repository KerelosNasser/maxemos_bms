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
  final List<AskAiMessage> messages;
  final bool isLoading;

  const AskAiState({this.messages = const [], this.isLoading = false});

  AskAiState copyWith({List<AskAiMessage>? messages, bool? isLoading}) {
    return AskAiState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading];
}
