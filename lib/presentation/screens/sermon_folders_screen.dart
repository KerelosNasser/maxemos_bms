import 'package:flutter/material.dart';
import '../../core/theme/vintage_theme.dart';
import '../../data/models/highlight.dart';
import '../../data/services/highlight_service.dart';
import 'book_highlights_detail_screen.dart';

class SermonFoldersScreen extends StatefulWidget {
  final bool hideAppBar;

  const SermonFoldersScreen({super.key, this.hideAppBar = false});

  @override
  State<SermonFoldersScreen> createState() => _SermonFoldersScreenState();
}

class _SermonFoldersScreenState extends State<SermonFoldersScreen> {
  bool _isLoading = true;
  List<String> _books = [];
  Map<String, List<Highlight>> _bookHighlights = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allHighlights = await HighlightService.getAllHighlights();
    final Map<String, List<Highlight>> grouped = {};
    final Set<String> bookNames = {};

    for (var h in allHighlights) {
      final bookName = (h.bookTitle != null && h.bookTitle!.trim().isNotEmpty)
          ? h.bookTitle!.trim()
          : 'كتب أخرى';
      bookNames.add(bookName);
      if (!grouped.containsKey(bookName)) {
        grouped[bookName] = [];
      }
      grouped[bookName]!.add(h);
    }

    if (mounted) {
      setState(() {
        _books = bookNames.toList()..sort();
        _bookHighlights = grouped;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = Container(
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
                'لا توجد علامات مرجعية بعد.\nقم بتحديد نص في أي كتاب ثم اضغط على "حفظ العلامة".',
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
                  final count = _bookHighlights[bookName]?.length ?? 0;

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
                        Icons.menu_book,
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
                        '$count اقتباسات',
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
                            builder: (_) => BookHighlightsDetailScreen(
                              bookTitle: bookName,
                              highlights: _bookHighlights[bookName] ?? [],
                            ),
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

    if (widget.hideAppBar) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: VintageTheme.inkDark,
      appBar: AppBar(
        title: const Text(
          'العلامات المرجعية',
          style: TextStyle(fontFamily: 'Amiri'),
        ),
        backgroundColor: VintageTheme.inkDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: bodyContent,
    );
  }
}
