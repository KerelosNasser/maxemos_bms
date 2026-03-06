import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/vintage_theme.dart';
import '../../data/models/highlight.dart';
import '../bloc/pdf_reader_bloc.dart';
import '../bloc/pdf_reader_event.dart';

class SermonFolderSelectionSheet extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final int pageNumber;
  final String selectedText;

  const SermonFolderSelectionSheet({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.pageNumber,
    required this.selectedText,
  });

  @override
  State<SermonFolderSelectionSheet> createState() =>
      _SermonFolderSelectionSheetState();
}

class _SermonFolderSelectionSheetState
    extends State<SermonFolderSelectionSheet> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveHighlight() {
    final note = _noteController.text.trim();

    final highlight = Highlight(
      pageNumber: widget.pageNumber,
      text: widget.selectedText,
      bookTitle: widget.bookTitle,
      note: note.isNotEmpty ? note : null,
    );

    context.read<PdfReaderBloc>().add(
      AddHighlightEvent(bookId: widget.bookId, highlight: highlight),
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم حفظ العلامة',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: VintageTheme.inkFaded,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VintageTheme.parchmentLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: VintageTheme.vintageGold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'حفظ في مجلد العظات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: VintageTheme.inkDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.bookTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              color: VintageTheme.inkDark.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Optional Note
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: VintageTheme.inkDark,
              ),
              decoration: InputDecoration(
                labelText: 'ملاحظة شخصية (اختياري)',
                labelStyle: TextStyle(
                  fontFamily: 'Amiri',
                  color: VintageTheme.inkDark.withOpacity(0.6),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: VintageTheme.vintageGold),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: VintageTheme.crimsonRed,
                    width: 2,
                  ),
                ),
                alignLabelWithHint: true,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          ElevatedButton(
            onPressed: () => _saveHighlight(),
            style: ElevatedButton.styleFrom(
              backgroundColor: VintageTheme.crimsonRed,
              foregroundColor: VintageTheme.parchmentLight,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: const Text(
              'حفظ العلامة',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
