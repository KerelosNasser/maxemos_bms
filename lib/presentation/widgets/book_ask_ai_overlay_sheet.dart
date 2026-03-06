import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/vintage_theme.dart';
import '../bloc/ask_ai_cubit.dart';
import '../bloc/ask_ai_state.dart';
import 'typewriter_text.dart';

class BookAskAiOverlaySheet extends StatefulWidget {
  final String bookTitle;

  const BookAskAiOverlaySheet({super.key, required this.bookTitle});

  @override
  State<BookAskAiOverlaySheet> createState() => _BookAskAiOverlaySheetState();
}

class _BookAskAiOverlaySheetState extends State<BookAskAiOverlaySheet> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AskAiCubit(),
      child: BlocConsumer<AskAiCubit, AskAiState>(
        listener: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        },
        builder: (context, state) {
          return PopScope(
            canPop: !state.isLoading,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: VintageTheme.parchmentLight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: VintageTheme.inkFaded.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book,
                                color: VintageTheme.vintageGold,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'محادثة حول الكتاب',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: VintageTheme.inkDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Display Context
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              border: Border.all(
                                color: VintageTheme.inkFaded.withOpacity(0.2),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'موضوع النقاش:',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: VintageTheme.inkFaded,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.bookTitle,
                                        textDirection: TextDirection.rtl,
                                        style: const TextStyle(
                                          fontFamily: 'Amiri',
                                          fontSize: 18,
                                          color: VintageTheme.vintageGold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.book,
                                      color: VintageTheme.vintageGold,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Messages List
                          Expanded(child: _buildMessagesList(state)),

                          // Loading Indicator
                          if (state.isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: VintageTheme.vintageGold,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'جاري استشارة الآباء...',
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      color: VintageTheme.inkFaded,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Input Row
                          _buildInputRow(context, state),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(AskAiState state) {
    if (state.messages.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: VintageTheme.inkFaded.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'اسأل الذكاء الاصطناعي أي سؤال عام عن هذا الكتاب وسيتم الاستعانة بعلاماتك المرجعية للإجابة.',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              color: VintageTheme.inkDark,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.messages.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final msg = state.messages[index];
        final isUser = msg.role == 'user';

        return Align(
          alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? VintageTheme.vintageGold.withOpacity(0.15)
                  : Colors.white.withOpacity(0.7),
              border: Border.all(
                color: isUser
                    ? VintageTheme.vintageGold.withOpacity(0.5)
                    : VintageTheme.inkFaded.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 0 : 16),
                bottomRight: Radius.circular(isUser ? 16 : 0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isUser ? 'أنت' : 'الآباء',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: msg.isError ? Colors.red : VintageTheme.inkFaded,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isUser ? Icons.person : Icons.auto_awesome,
                      size: 14,
                      color: msg.isError ? Colors.red : VintageTheme.inkFaded,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                isUser
                    ? SelectableText(
                        msg.content,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          color: msg.isError
                              ? Colors.red
                              : VintageTheme.inkDark,
                          height: 1.6,
                        ),
                      )
                    : TypewriterText(
                        text: msg.content,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          color: msg.isError
                              ? Colors.red
                              : VintageTheme.inkDark,
                          height: 1.6,
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitQuestion(BuildContext context) {
    final text = _questionController.text;
    if (text.trim().isEmpty) return;
    context.read<AskAiCubit>().askGeneralQuestion(
      bookTitle: widget.bookTitle,
      question: text,
    );
    _questionController.clear();
  }

  Widget _buildInputRow(BuildContext context, AskAiState state) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 8.0,
        top: 8,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: TextField(
              controller: _questionController,
              textDirection: TextDirection.rtl,
              enabled: !state.isLoading,
              style: const TextStyle(color: VintageTheme.inkDark),
              cursorColor: VintageTheme.inkDark,
              decoration: InputDecoration(
                hintText: 'اكتب سؤالك هنا...',
                hintTextDirection: TextDirection.rtl,
                hintStyle: TextStyle(
                  color: VintageTheme.inkFaded.withOpacity(0.5),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: VintageTheme.inkFaded.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: VintageTheme.vintageGold,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: state.isLoading
                  ? null
                  : (_) => _submitQuestion(context),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: state.isLoading
                  ? VintageTheme.inkFaded
                  : VintageTheme.inkDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: VintageTheme.vintageGold),
              onPressed: state.isLoading
                  ? null
                  : () => _submitQuestion(context),
            ),
          ),
        ],
      ),
    );
  }
}
