import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/gemini_service.dart';
import 'ask_ai_state.dart';

class AskAiCubit extends Cubit<AskAiState> {
  AskAiCubit() : super(const AskAiState());

  Future<void> askQuestion({
    required String selectedText,
    required String bookTitle,
    required String question,
  }) async {
    if (question.trim().isEmpty || state.isLoading) return;

    final userMsg = AskAiMessage(role: 'user', content: question);
    final updatedMessages = List<AskAiMessage>.from(state.messages)
      ..add(userMsg);

    emit(state.copyWith(messages: updatedMessages, isLoading: true));

    try {
      final answer = await GeminiService.askQuestionAboutText(
        text: selectedText,
        bookTitle: bookTitle,
        question: question,
      );

      final aiMsg = AskAiMessage(role: 'ai', content: answer);
      emit(
        state.copyWith(
          messages: List.from(state.messages)..add(aiMsg),
          isLoading: false,
        ),
      );
    } catch (e) {
      final errorMsg = AskAiMessage(
        role: 'ai',
        content: e.toString(),
        isError: true,
      );
      emit(
        state.copyWith(
          messages: List.from(state.messages)..add(errorMsg),
          isLoading: false,
        ),
      );
    }
  }

  void reset() {
    emit(const AskAiState());
  }
}
