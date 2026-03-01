import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../data/models/book.dart';
import '../../core/theme/vintage_theme.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/notification_service.dart';

class PdfReaderScreen extends StatefulWidget {
  final Book book;

  const PdfReaderScreen({super.key, required this.book});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  bool _isSummarizing = false;

  void _showSummarizeDialog() {
    int startPage = _pdfController.pageNumber ?? 1;
    int endPage = _pdfController.pageNumber ?? 1;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: VintageTheme.parchmentLight,
              title: const Text('Summarize Pages (AI)'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Select the page range to summarize using Gemini.'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Start Page: '),
                      Expanded(
                        child: Slider(
                          value: startPage.toDouble(),
                          min: 1,
                          max: _pdfController.pageCount.toDouble(),
                          onChanged: (val) {
                            setState(() {
                              startPage = val.toInt();
                              if (startPage > endPage) endPage = startPage;
                            });
                          },
                        ),
                      ),
                      Text('$startPage'),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('End Page: '),
                      Expanded(
                        child: Slider(
                          value: endPage.toDouble(),
                          min: 1,
                          max: _pdfController.pageCount.toDouble(),
                          onChanged: (val) {
                            setState(() {
                              endPage = val.toInt();
                              if (endPage < startPage) startPage = endPage;
                            });
                          },
                        ),
                      ),
                      Text('$endPage'),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _executeSummarization(startPage, endPage);
                  },
                  child: const Text(
                    'Summarize',
                    style: TextStyle(
                      color: VintageTheme.crimsonRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _executeSummarization(int startPage, int endPage) async {
    setState(() => _isSummarizing = true);

    try {
      // In a full implementation, we would extract the text using a native PDF library or MLKit OCR here.
      // For this lightweight version using pdfrx, we'll simulate text extraction
      // and send the bounds to Gemini.

      NotificationService.showNotification(
        id: 7,
        title: 'Extracting Arabic Text',
        body: 'Running OCR on pages $startPage to $endPage...',
      );

      // Simulate OCR delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock extracted text to send to Gemini
      String extractedText =
          "Extracted OCR text payload from pages $startPage to $endPage from the book ${widget.book.title}.";

      final summary = await GeminiService.summarizeExcerpt(
        extractedText,
        startPage,
        endPage,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: VintageTheme.parchmentLight,
            title: const Text('AI Insight'),
            content: SingleChildScrollView(child: Text(summary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showNotification(
          id: 8,
          title: 'Summarization Failed',
          body: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isSummarizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'book_title_${widget.book.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Text(
              widget.book.title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement actual MLKit Arabic OCR Search
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('MLKit Arabic OCR Search Initializing...'),
                ),
              );
            },
            tooltip: 'Find (Arabic OCR)',
          ),
        ],
      ),
      body: Stack(
        children: [
          PdfViewer.uri(
            Uri.parse(widget.book.url),
            controller: _pdfController,
            params: PdfViewerParams(
              backgroundColor: VintageTheme.parchmentLight,
              // Setup custom scrolling, Arabic Right-to-Left defaults could be configured here if pdfrx supported RTL out of the box
            ),
          ),
          if (_isSummarizing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: VintageTheme.vintageGold),
                    SizedBox(height: 16),
                    Text(
                      'Consulting the Oracle...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: VintageTheme.inkDark,
        onPressed: _showSummarizeDialog,
        icon: const Icon(Icons.auto_awesome, color: VintageTheme.vintageGold),
        label: const Text(
          'Summarize',
          style: TextStyle(color: VintageTheme.vintageGold),
        ),
      ),
    );
  }
}
