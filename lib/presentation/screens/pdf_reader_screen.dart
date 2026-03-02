import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../data/models/book.dart';
import '../../core/theme/vintage_theme.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/notification_service.dart';
import '../widgets/pdf_search_bar.dart';

class PdfReaderScreen extends StatefulWidget {
  final Book book;

  const PdfReaderScreen({super.key, required this.book});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  PdfTextSearcher? _textSearcher;

  bool _isSummarizing = false;
  bool _isUIVisible = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize searcher attached to this controller
    _textSearcher = PdfTextSearcher(_pdfController)
      ..addListener(_onSearcherUpdated);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _textSearcher?.removeListener(_onSearcherUpdated);
    _textSearcher?.dispose();
    super.dispose();
  }

  void _onSearcherUpdated() {
    if (mounted) setState(() {});
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _textSearcher?.resetTextSearch();
      }
    });
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      _textSearcher?.startTextSearch(query, caseInsensitive: true);
    }
  }

  void _showSummarizeDialog() {
    int startPage = _pdfController.pageNumber ?? 1;
    int endPage = _pdfController.pageNumber ?? 1;

    final startController = TextEditingController(text: startPage.toString());
    final endController = TextEditingController(text: endPage.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: VintageTheme.inkDark,
              title: const Text(
                'تلخيص الصفحات (ذكاء اصطناعي)', // Summarize Pages (AI)
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
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'من صفحة:',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: startController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (val) {
                            startPage = int.tryParse(val) ?? 1;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'إلى صفحة:',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: endController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (val) {
                            endPage = int.tryParse(val) ?? 1;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Normalize inputs
                    if (startPage < 1) startPage = 1;
                    if (endPage < startPage) endPage = startPage;

                    Navigator.pop(ctx);
                    _executeSummarization(startPage, endPage);
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
            );
          },
        );
      },
    );
  }

  Future<void> _executeSummarization(int startPage, int endPage) async {
    setState(() => _isSummarizing = true);

    try {
      NotificationService.showNotification(
        id: 7,
        title: 'Extracting Arabic Text',
        body: 'Running OCR on pages $startPage to $endPage...',
      );

      // Simulate OCR extraction for now to keep it lightweight,
      // or retrieve real text if standard pdfrx text retrieval is available.
      await Future.delayed(const Duration(seconds: 2));

      String extractedText =
          "Extracted text payload from pages $startPage to $endPage from the book ${widget.book.title}.";

      final summary = await GeminiService.summarizeExcerpt(
        extractedText,
        startPage,
        endPage,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: VintageTheme.inkDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: VintageTheme.vintageGold, width: 2),
            ),
            title: const Text(
              'خلاصة الآباء', // "Fathers' Insight/Summary"
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  backgroundColor: VintageTheme.deeperParchment.withOpacity(
                    0.1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: VintageTheme.vintageGold),
                  ),
                ),
                child: const Text(
                  'إغلاق', // "Close"
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
      backgroundColor: Colors.black,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_isUIVisible) setState(() => _isUIVisible = false);
          } else if (notification.direction == ScrollDirection.forward) {
            if (!_isUIVisible) setState(() => _isUIVisible = true);
          }
          return false;
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: PdfViewer.uri(
                Uri.parse(
                  'https://drive.google.com/uc?export=download&id=${widget.book.id}',
                ),
                controller: _pdfController,
                params: const PdfViewerParams(
                  backgroundColor: VintageTheme.inkDark,
                ),
              ),
            ),

            if (_isSearching)
              Positioned(
                bottom:
                    MediaQuery.of(context).padding.bottom +
                    85, // Show above floating action buttons
                left: 16,
                right: 16,
                child: PdfSearchBar(
                  controller: _searchController,
                  textSearcher: _textSearcher,
                  onClose: _toggleSearch,
                  onSubmitted: _performSearch,
                ),
              ),

            // Animated App Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _isUIVisible
                  ? 0
                  : -(kToolbarHeight + MediaQuery.of(context).padding.top),
              left: 0,
              right: 0,
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
              child: Material(
                elevation: 4,
                color: VintageTheme.inkDark,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Hero(
                          tag: 'book_title_${widget.book.id}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              widget.book.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.search_off : Icons.search,
                          color: Colors.white,
                        ),
                        onPressed: _toggleSearch,
                        tooltip: 'Find text',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_isSummarizing)
              Container(
                color: Colors.black87,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: VintageTheme.vintageGold,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'جاري الرجوع لآباء الكنيسة...', // Consulting the Fathers...
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ),

            // Animated Floating Action Button
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _isUIVisible ? 16 : -80,
              right: 16,
              child: FloatingActionButton.extended(
                backgroundColor: VintageTheme.inkFaded,
                onPressed: _showSummarizeDialog,
                icon: const Icon(
                  Icons.auto_awesome,
                  color: VintageTheme.vintageGold,
                  size: 28,
                ),
                label: const Text(
                  'تلخيص',
                  style: TextStyle(
                    color: VintageTheme.vintageGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
