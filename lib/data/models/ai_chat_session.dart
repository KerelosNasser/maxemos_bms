import 'package:uuid/uuid.dart';
import '../../presentation/bloc/ask_ai_state.dart' show AskAiMessage;

class AiChatSession {
  final String id;
  final String bookTitle;
  final String selectedText;
  final List<AskAiMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  AiChatSession({
    String? id,
    required this.bookTitle,
    required this.selectedText,
    required this.messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory AiChatSession.fromJson(Map<String, dynamic> json) {
    return AiChatSession(
      id: json['id'] as String,
      bookTitle: json['bookTitle'] as String,
      selectedText: json['selectedText'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map(
            (e) => AskAiMessage(
              role: e['role'] as String,
              content: e['content'] as String,
              isError: e['isError'] as bool? ?? false,
            ),
          )
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookTitle': bookTitle,
      'selectedText': selectedText,
      'messages': messages
          .map(
            (m) => {'role': m.role, 'content': m.content, 'isError': m.isError},
          )
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AiChatSession copyWith({
    String? id,
    String? bookTitle,
    String? selectedText,
    List<AskAiMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiChatSession(
      id: id ?? this.id,
      bookTitle: bookTitle ?? this.bookTitle,
      selectedText: selectedText ?? this.selectedText,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
