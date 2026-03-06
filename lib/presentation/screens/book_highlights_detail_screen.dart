import 'package:flutter/material.dart';
import '../../core/theme/vintage_theme.dart';
import '../../data/models/highlight.dart';
import '../../data/services/highlight_service.dart';

class BookHighlightsDetailScreen extends StatefulWidget {
  final String bookTitle;
  final List<Highlight> highlights;

  const BookHighlightsDetailScreen({
    super.key,
    required this.bookTitle,
    required this.highlights,
  });

  @override
  State<BookHighlightsDetailScreen> createState() =>
      _BookHighlightsDetailScreenState();
}

class _BookHighlightsDetailScreenState
    extends State<BookHighlightsDetailScreen> {
  late List<Highlight> _highlights;

  @override
  void initState() {
    super.initState();
    _highlights = List.from(widget.highlights);
  }

  Future<void> _editNote(Highlight highlight, int index) async {
    final noteController = TextEditingController(text: highlight.note ?? '');
    final newNote = await showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: VintageTheme.parchmentLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: VintageTheme.vintageGold.withOpacity(0.5)),
          ),
          title: const Text(
            'تعديل الملاحظة',
            style: TextStyle(
              fontFamily: 'Amiri',
              color: VintageTheme.inkDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: noteController,
            maxLines: 4,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              color: VintageTheme.inkDark,
            ),
            decoration: InputDecoration(
              hintText: 'اكتب ملاحظتك هنا...',
              hintStyle: TextStyle(
                fontFamily: 'Amiri',
                color: VintageTheme.inkDark.withOpacity(0.5),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: VintageTheme.vintageGold),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: VintageTheme.crimsonRed),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text(
                'إلغاء',
                style: TextStyle(fontFamily: 'Amiri', color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VintageTheme.crimsonRed,
                foregroundColor: VintageTheme.parchmentLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context, noteController.text),
              child: const Text(
                'حفظ',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (newNote != null && newNote != highlight.note) {
      final updatedHighlight = highlight.copyWith(
        note: newNote.trim().isEmpty ? null : newNote.trim(),
      );
      setState(() {
        _highlights[index] = updatedHighlight;
      });
      await HighlightService.updateHighlightGlobal(updatedHighlight);
    }
  }

  Future<void> _deleteHighlight(Highlight highlight, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: VintageTheme.parchmentLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: VintageTheme.vintageGold.withOpacity(0.5)),
          ),
          title: const Text(
            'حذف العلامة المررجعية',
            style: TextStyle(
              fontFamily: 'Amiri',
              color: VintageTheme.inkDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'هل أنت متأكد من حذف هذه العلامة المرجعية؟ لا يمكن التراجع عن هذا الإجراء.',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              color: VintageTheme.inkDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'إلغاء',
                style: TextStyle(fontFamily: 'Amiri', color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'حذف',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      setState(() {
        _highlights.removeAt(index);
      });
      await HighlightService.removeHighlightGlobal(highlight.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_highlights.isEmpty) {
      return Scaffold(
        backgroundColor: VintageTheme.inkDark,
        appBar: AppBar(
          title: Text(
            widget.bookTitle,
            style: const TextStyle(fontFamily: 'Amiri', fontSize: 20),
          ),
          backgroundColor: VintageTheme.inkDark,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'لا توجد علامات مرجعية في هذا الكتاب.',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              color: VintageTheme.parchmentLight,
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: VintageTheme.inkDark,
      appBar: AppBar(
        title: Text(
          widget.bookTitle,
          style: const TextStyle(fontFamily: 'Amiri', fontSize: 20),
        ),
        backgroundColor: VintageTheme.inkDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://www.transparenttextures.com/patterns/old-wall.png',
            ),
            repeat: ImageRepeat.repeat,
            colorFilter: ColorFilter.mode(Colors.white10, BlendMode.dstATop),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _highlights.length,
          itemBuilder: (context, index) {
            final h = _highlights[index];
            return Card(
              color: VintageTheme.parchmentLight,
              margin: const EdgeInsets.only(bottom: 16),
              surfaceTintColor: Colors.transparent,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: VintageTheme.vintageGold.withOpacity(0.4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Content
                    Text(
                      '"${h.text.trim()}"',
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 22,
                        height: 1.6,
                        color: VintageTheme.inkDark,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 16),
                    // Note (if any)
                    if (h.note != null && h.note!.trim().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: VintageTheme.vintageGold.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          h.note!.trim(),
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18,
                            color: VintageTheme.inkDark.withOpacity(0.8),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Action Buttons & Page Indicator Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: VintageTheme.inkDark,
                              ),
                              tooltip: 'تعديل الملاحظة',
                              onPressed: () => _editNote(h, index),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red.shade700,
                              ),
                              tooltip: 'حذف العلامة',
                              onPressed: () => _deleteHighlight(h, index),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: VintageTheme.crimsonRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'صفحة ${h.pageNumber}',
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 16,
                              color: VintageTheme.crimsonRed,
                              fontWeight: FontWeight.bold,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
