import 'package:flutter/material.dart';
import '../../core/theme/vintage_theme.dart';
import '../../data/models/ai_chat_session.dart';
import '../../data/services/ai_chat_service.dart';
import '../widgets/book_ask_ai_overlay_sheet.dart';

class BookAiChatsDetailScreen extends StatefulWidget {
  final String bookTitle;

  const BookAiChatsDetailScreen({super.key, required this.bookTitle});

  @override
  State<BookAiChatsDetailScreen> createState() =>
      _BookAiChatsDetailScreenState();
}

class _BookAiChatsDetailScreenState extends State<BookAiChatsDetailScreen> {
  bool _isSidebarOpen = true;
  List<AiChatSession> _sessions = [];
  AiChatSession? _selectedSession;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final allSessions = await AiChatService.getAllSessions();
    final bookSessions = allSessions
        .where((s) => s.bookTitle == widget.bookTitle)
        .toList();

    if (mounted) {
      setState(() {
        _sessions = bookSessions;
        if (bookSessions.isNotEmpty) {
          _selectedSession =
              (_selectedSession != null &&
                  bookSessions.any((s) => s.id == _selectedSession!.id))
              ? bookSessions.firstWhere((s) => s.id == _selectedSession!.id)
              : bookSessions.first;
        } else {
          _selectedSession = null;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSession(String id) async {
    await AiChatService.removeSession(id);
    await _loadSessions();
  }

  void _startNewChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookAskAiOverlaySheet(bookTitle: widget.bookTitle),
    ).then((_) {
      // Reload sessions after the overlay is closed
      _loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VintageTheme.inkDark,
      appBar: AppBar(
        title: Text(
          widget.bookTitle,
          style: const TextStyle(fontFamily: 'Amiri', fontSize: 18),
        ),
        backgroundColor: VintageTheme.inkDark,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewChat,
        backgroundColor: VintageTheme.vintageGold,
        icon: const Icon(Icons.chat, color: VintageTheme.inkDark),
        label: const Text(
          'محادثة جديدة',
          style: TextStyle(
            fontFamily: 'Amiri',
            color: VintageTheme.inkDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: VintageTheme.vintageGold),
            )
          : _sessions.isEmpty
          ? Center(
              child: Text(
                'لا توجد محادثات سابقة لهذا الكتاب.\\nاضغط على "محادثة جديدة" للبدء.',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  color: VintageTheme.parchmentLight,
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;
                return Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    // Sidebar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: _isSidebarOpen
                          ? (isSmallScreen ? constraints.maxWidth : 300)
                          : 0,
                      decoration: BoxDecoration(
                        color: VintageTheme.inkDark.withOpacity(0.9),
                        border: Border(
                          left: BorderSide(
                            color: VintageTheme.vintageGold.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: ClipRect(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                textDirection: TextDirection.rtl,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'المحادثات السابقة',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 18,
                                      color: VintageTheme.vintageGold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isSmallScreen)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => setState(
                                        () => _isSidebarOpen = false,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: VintageTheme.vintageGold,
                              height: 1,
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _sessions.length,
                                itemBuilder: (context, index) {
                                  final session = _sessions[index];
                                  final isSelected =
                                      _selectedSession?.id == session.id;
                                  return ListTile(
                                    selected: isSelected,
                                    selectedTileColor: VintageTheme.crimsonRed
                                        .withOpacity(0.2),
                                    title: Text(
                                      session.messages
                                          .firstWhere(
                                            (m) => m.role == 'user',
                                            orElse: () =>
                                                session.messages.first,
                                          )
                                          .content,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        color: isSelected
                                            ? VintageTheme.vintageGold
                                            : Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      session.selectedText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white24,
                                        size: 18,
                                      ),
                                      onPressed: () =>
                                          _deleteSession(session.id),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedSession = session;
                                        if (isSmallScreen) {
                                          _isSidebarOpen = false;
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Main Content Area
                    Expanded(
                      child: Stack(
                        children: [
                          if (_selectedSession == null)
                            const Center(
                              child: Text(
                                'اختر محادثة لعرضها',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 18,
                                  color: Colors.white54,
                                ),
                              ),
                            )
                          else
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  color: VintageTheme.inkDark.withOpacity(0.5),
                                  child: Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      if (!_isSidebarOpen)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.menu,
                                            color: VintageTheme.vintageGold,
                                          ),
                                          onPressed: () => setState(
                                            () => _isSidebarOpen = true,
                                          ),
                                        ),
                                      Expanded(
                                        child: Text(
                                          'السياق: "${_selectedSession!.selectedText}"',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textDirection: TextDirection.rtl,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                            fontFamily: 'Amiri',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Chat Messages
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount:
                                        _selectedSession!.messages.length,
                                    itemBuilder: (context, index) {
                                      final msg =
                                          _selectedSession!.messages[index];
                                      final isUser = msg.role == 'user';
                                      return Align(
                                        alignment: isUser
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                constraints.maxWidth * 0.75,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isUser
                                                ? VintageTheme.vintageGold
                                                      .withOpacity(0.15)
                                                : VintageTheme.parchmentLight
                                                      .withOpacity(0.9),
                                            borderRadius:
                                                BorderRadius.circular(
                                                  16,
                                                ).copyWith(
                                                  bottomRight: isUser
                                                      ? const Radius.circular(0)
                                                      : const Radius.circular(
                                                          16,
                                                        ),
                                                  bottomLeft: isUser
                                                      ? const Radius.circular(
                                                          16,
                                                        )
                                                      : const Radius.circular(
                                                          0,
                                                        ),
                                                ),
                                            border: Border.all(
                                              color: isUser
                                                  ? VintageTheme.vintageGold
                                                        .withOpacity(0.3)
                                                  : VintageTheme.crimsonRed
                                                        .withOpacity(0.2),
                                            ),
                                          ),
                                          child: Text(
                                            msg.content,
                                            textDirection: TextDirection.rtl,
                                            style: TextStyle(
                                              fontFamily: 'Amiri',
                                              fontSize: 16,
                                              color: isUser
                                                  ? Colors.white
                                                  : VintageTheme.inkDark,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
