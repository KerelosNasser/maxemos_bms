import 'package:flutter/material.dart';
import '../../../data/models/book.dart';
import '../../../core/theme/vintage_theme.dart';
import '../../bloc/pdf_reader_bloc.dart';
import '../../bloc/pdf_reader_event.dart';
import '../../bloc/pdf_reader_state.dart';

class PdfDownloadErrorView extends StatelessWidget {
  final PdfReaderState state;
  final PdfReaderBloc bloc;
  final Book book;
  final BuildContext parentContext;

  const PdfDownloadErrorView({
    super.key,
    required this.state,
    required this.bloc,
    required this.book,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final downloadUrl =
        'https://drive.google.com/uc?export=download&id=${book.id}';
    return Container(
      color: VintageTheme.inkDark,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'فشل تحميل الكتاب',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              Text(
                state.downloadError ?? '',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(parentContext),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('رجوع'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => bloc.add(
                      DownloadPdfEvent(
                        bookId: book.id,
                        downloadUrl: downloadUrl,
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VintageTheme.inkFaded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
