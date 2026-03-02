import 'package:flutter/material.dart';
import '../../core/theme/vintage_theme.dart';
import '../bloc/pdf_reader_bloc.dart';
import '../bloc/pdf_reader_event.dart';

/// Shows the page-range input dialog and triggers summarization.
void showSummarizeInputDialog(
  BuildContext context,
  PdfReaderBloc bloc,
  String bookTitle,
) {
  int startPage = bloc.pdfController.pageNumber ?? 1;
  int endPage = startPage;

  final startCtrl = TextEditingController(text: startPage.toString());
  final endCtrl = TextEditingController(text: endPage.toString());

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: VintageTheme.inkDark,
      title: const Text(
        'تلخيص الصفحات (ذكاء اصطناعي)',
        textDirection: TextDirection.rtl,
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'أدخل نطاق الصفحات المراد تلخيصها باستخدام Gemini.',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          _PageRangeRow(
            label: 'من صفحة:',
            controller: startCtrl,
            onChanged: (val) => startPage = int.tryParse(val) ?? 1,
          ),
          const SizedBox(height: 12),
          _PageRangeRow(
            label: 'إلى صفحة:',
            controller: endCtrl,
            onChanged: (val) => endPage = int.tryParse(val) ?? 1,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
        ),
        TextButton(
          onPressed: () {
            if (startPage < 1) startPage = 1;
            if (endPage < startPage) endPage = startPage;
            Navigator.pop(ctx);
            bloc.add(
              SummarizePagesEvent(
                startPage: startPage,
                endPage: endPage,
                bookTitle: bookTitle,
              ),
            );
          },
          child: const Text(
            'تلخيص',
            style: TextStyle(
              color: VintageTheme.vintageGold,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Shows the AI summary result in a styled dialog.
void showSummaryResultDialog(BuildContext context, String summary) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: VintageTheme.inkDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: VintageTheme.vintageGold, width: 2),
      ),
      title: const Text(
        'خلاصة الآباء',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: VintageTheme.vintageGold,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      content: SingleChildScrollView(
        child: Text(
          summary,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: VintageTheme.deeperParchment.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: VintageTheme.vintageGold),
            ),
          ),
          child: const Text(
            'إغلاق',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

/// Reusable row for page range input.
class _PageRangeRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _PageRangeRow({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
