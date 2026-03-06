import 'package:flutter/material.dart';
import '../../core/theme/vintage_theme.dart';
import '../../data/models/ai_chat_session.dart';
import '../../data/services/ai_chat_service.dart';
import '../screens/book_ai_chats_detail_screen.dart';

class AiChatsLibraryView extends StatefulWidget {
  const AiChatsLibraryView({super.key});

  @override
  State<AiChatsLibraryView> createState() => _AiChatsLibraryViewState();
}

class _AiChatsLibraryViewState extends State<AiChatsLibraryView> {
  bool _isLoading = true;
  List<String> _books = [];
  Map<String, List<AiChatSession>> _bookSessions = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allSessions = await AiChatService.getAllSessions();
    final Map<String, List<AiChatSession>> grouped = {};
    final Set<String> bookNames = {};

    for (var s in allSessions) {
      final bookName = (s.bookTitle.trim().isNotEmpty)
          ? s.bookTitle.trim()
          : 'كتب أخرى';
      bookNames.add(bookName);
      if (!grouped.containsKey(bookName)) {
        grouped[bookName] = [];
      }
      grouped[bookName]!.add(s);
    }

    if (mounted) {
      setState(() {
        _books = bookNames.toList()..sort();
        _bookSessions = grouped;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://www.transparenttextures.com/patterns/old-wall.png',
          ),
          repeat: ImageRepeat.repeat,
          colorFilter: ColorFilter.mode(Colors.white10, BlendMode.dstATop),
        ),
      ),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: VintageTheme.vintageGold),
            )
          : _books.isEmpty
          ? const Center(
              child: Text(
                'لا توجد محادثات سابقة.\\nقم بتحديد نص في أي كتاب واسأل الذكاء الاصطناعي.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  color: VintageTheme.parchmentLight,
                ),
                textDirection: TextDirection.rtl,
              ),
            )
          : RefreshIndicator(
              color: VintageTheme.crimsonRed,
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final bookName = _books[index];
                  final count = _bookSessions[bookName]?.length ?? 0;

                  return Card(
                    color: VintageTheme.parchmentLight,
                    margin: const EdgeInsets.only(bottom: 16),
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: VintageTheme.vintageGold.withOpacity(0.5),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(
                        Icons.chat,
                        color: VintageTheme.vintageGold,
                        size: 40,
                      ),
                      title: Text(
                        bookName,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: VintageTheme.inkDark,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      subtitle: Text(
                        '$count محادثات',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          color: VintageTheme.inkDark.withOpacity(0.7),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: VintageTheme.inkDark,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookAiChatsDetailScreen(bookTitle: bookName),
                          ),
                        ).then((_) {
                          // Refresh when coming back in case data changed
                          _loadData();
                        });
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
