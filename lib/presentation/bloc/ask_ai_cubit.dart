import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/gemini_service.dart';
import '../../data/models/ai_chat_session.dart';
import '../../data/services/ai_chat_service.dart';
import 'ask_ai_state.dart';

class AskAiCubit extends Cubit<AskAiState> {
  AskAiCubit() : super(const AskAiState());

  Future<void> loadSession(AiChatSession session) async {
    emit(
      state.copyWith(
        sessionId: session.id,
        bookTitle: session.bookTitle,
        selectedText: session.selectedText,
        messages: session.messages,
        isLoading: false,
      ),
    );
  }

  Future<void> askQuestion({
    required String selectedText,
    required String bookTitle,
    required String question,
  }) async {
    if (question.trim().isEmpty || state.isLoading) return;

    final sessionId = state.sessionId ?? const Uuid().v4();

    final userMsg = AskAiMessage(role: 'user', content: question);
    final updatedMessages = List<AskAiMessage>.from(state.messages)
      ..add(userMsg);

    emit(
      state.copyWith(
        sessionId: sessionId,
        bookTitle: bookTitle,
        selectedText: selectedText,
        messages: updatedMessages,
        isLoading: true,
      ),
    );

    try {
      final answer = await GeminiService.askQuestionAboutText(
        text: selectedText,
        bookTitle: bookTitle,
        question: question,
      );

      final aiMsg = AskAiMessage(role: 'ai', content: answer);
      final finalMessages = List<AskAiMessage>.from(state.messages)..add(aiMsg);

      emit(state.copyWith(messages: finalMessages, isLoading: false));

      // Save to local storage
      final session = AiChatSession(
        id: sessionId,
        bookTitle: bookTitle,
        selectedText: selectedText,
        messages: finalMessages,
      );
      await AiChatService.saveSession(session);
    } catch (e) {
      final errorMsg = AskAiMessage(
        role: 'ai',
        content: e.toString(),
        isError: true,
      );
      final finalMessages = List<AskAiMessage>.from(state.messages)
        ..add(errorMsg);
      emit(state.copyWith(messages: finalMessages, isLoading: false));

      // Save to local storage even with error
      final session = AiChatSession(
        id: sessionId,
        bookTitle: bookTitle,
        selectedText: selectedText,
        messages: finalMessages,
      );
      await AiChatService.saveSession(session);
    }
  }

  void reset() {
    emit(const AskAiState());
  }
}
