import 'package:flutter/material.dart';
import '../../../data/models/book.dart';
import '../../../core/theme/vintage_theme.dart';
import '../../bloc/pdf_reader_state.dart';

class PdfDownloadProgressView extends StatelessWidget {
  final PdfReaderState state;
  final Book book;

  const PdfDownloadProgressView({
    super.key,
    required this.state,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (state.downloadProgress * 100).toStringAsFixed(0);
    return Container(
      color: VintageTheme.inkDark,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: state.downloadProgress > 0
                        ? state.downloadProgress
                        : null,
                    color: VintageTheme.vintageGold,
                    strokeWidth: 4,
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: VintageTheme.vintageGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'جاري تحميل الكتاب...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
