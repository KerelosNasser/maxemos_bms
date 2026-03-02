import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../data/models/book.dart';
import '../../data/models/highlight.dart';
import '../../core/theme/vintage_theme.dart';
import '../bloc/pdf_reader_bloc.dart';
import '../bloc/pdf_reader_event.dart';
import '../bloc/pdf_reader_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/pdf_search_bar.dart';
import '../widgets/pdf_zoom_controls.dart';
import '../widgets/highlight_panel.dart';

class PdfReaderScreen extends StatelessWidget {
  final Book book;

  const PdfReaderScreen({super.key, required this.book});

  void _showSummarizeDialog(BuildContext context, PdfReaderBloc bloc) {
    int startPage = bloc.pdfController.pageNumber ?? 1;
    int endPage = bloc.pdfController.pageNumber ?? 1;

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
                    if (startPage < 1) startPage = 1;
                    if (endPage < startPage) endPage = startPage;

                    Navigator.pop(ctx);
                    bloc.add(
                      SummarizePagesEvent(
                        startPage: startPage,
                        endPage: endPage,
                        bookTitle: book.title,
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PdfReaderBloc()..add(LoadHighlightsEvent(book.id)),
      child: Builder(
        builder: (context) {
          final bloc = context.read<PdfReaderBloc>();
          return BlocConsumer<PdfReaderBloc, PdfReaderState>(
            listener: (context, state) {
              if (state is PdfReaderSummarySuccess) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: VintageTheme.inkDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: VintageTheme.vintageGold,
                        width: 2,
                      ),
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
                        state.summary,
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
                          backgroundColor:
                              VintageTheme.deeperParchment.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: VintageTheme.vintageGold,
                            ),
                          ),
                        ),
                        child: const Text(
                          'إغلاق',
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
            },
            builder: (context, state) {
              return Scaffold(
                backgroundColor: Colors.black,
                resizeToAvoidBottomInset: false,
                body: NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    if (notification.direction == ScrollDirection.reverse) {
                      if (state.isUIVisible) {
                        bloc.add(ToggleUIVisibilityEvent(false));
                      }
                    } else if (notification.direction ==
                        ScrollDirection.forward) {
                      if (!state.isUIVisible) {
                        bloc.add(ToggleUIVisibilityEvent(true));
                      }
                    }
                    return false;
                  },
                  child: Stack(
                    children: [
                      // === PDF Viewer ===
                      Positioned.fill(
                        child: SafeArea(
                          bottom: false,
                          child: PdfViewer.uri(
                            Uri.parse(
                              'https://drive.google.com/uc?export=download&id=${book.id}',
                            ),
                            controller: bloc.pdfController,
                            params: PdfViewerParams(
                              backgroundColor: VintageTheme.inkDark,
                              onViewerReady: (document, controller) {
                                bloc.initSearcher(document, controller);
                              },
                              // Search match highlighting
                              pagePaintCallbacks: [
                                if (bloc.textSearcher != null)
                                  bloc.textSearcher!
                                      .pageTextMatchPaintCallback,
                              ],
                              // Text selection for highlighting
                              textSelectionParams: PdfTextSelectionParams(
                                enabled: true,
                                onTextSelectionChange: (selections) async {
                                  final selectedText =
                                      await selections.getSelectedText();
                                  if (selectedText.isNotEmpty) {
                                    final pageNum =
                                        bloc.pdfController.pageNumber ?? 1;
                                    bloc.add(SetSelectedTextEvent(
                                      text: selectedText,
                                      pageNumber: pageNum,
                                    ));
                                  } else {
                                    bloc.add(ClearSelectedTextEvent());
                                  }
                                },
                              ),
                              // Double-tap to zoom
                              viewerOverlayBuilder:
                                  (context, size, handleLinkTap) => [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onDoubleTap: () {
                                    bloc.pdfController.zoomUp(loop: true);
                                    bloc.add(UpdateZoomLevelEvent(
                                      bloc.pdfController.currentZoom,
                                    ));
                                  },
                                  onTapUp: (details) {
                                    handleLinkTap(details.localPosition);
                                  },
                                  child: IgnorePointer(
                                    child: SizedBox(
                                      width: size.width,
                                      height: size.height,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // === Search Bar ===
                      if (state.isSearching)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          left: 12,
                          right: 12,
                          child: const PdfSearchBar(),
                        ),

                      // === Animated App Bar ===
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: state.isUIVisible && !state.isSearching
                            ? 0
                            : -(kToolbarHeight +
                                MediaQuery.of(context).padding.top),
                        left: 0,
                        right: 0,
                        height:
                            kToolbarHeight + MediaQuery.of(context).padding.top,
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
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                Expanded(
                                  child: Hero(
                                    tag: 'book_title_${book.id}',
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: Text(
                                        book.title,
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
                                // Highlights button
                                IconButton(
                                  icon: Icon(
                                    Icons.bookmark_rounded,
                                    color: state.isHighlightPanelOpen
                                        ? VintageTheme.vintageGold
                                        : Colors.white,
                                  ),
                                  onPressed: () =>
                                      bloc.add(ToggleHighlightPanelEvent()),
                                  tooltip: 'العلامات',
                                ),
                                // Search button
                                IconButton(
                                  icon: Icon(
                                    state.isSearching
                                        ? Icons.search_off
                                        : Icons.search,
                                    color: Colors.white,
                                  ),
                                  onPressed: () =>
                                      bloc.add(ToggleSearchEvent()),
                                  tooltip: 'بحث',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // === Zoom Controls ===
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        left: state.isUIVisible ? 12 : -60,
                        bottom: MediaQuery.of(context).size.height * 0.35,
                        child: PdfZoomControls(
                          zoomLevel: state.zoomLevel,
                          onZoomIn: () => bloc.add(ZoomInEvent()),
                          onZoomOut: () => bloc.add(ZoomOutEvent()),
                          onZoomReset: () => bloc.add(ZoomResetEvent()),
                        ),
                      ),

                      // === Summarize Loading Overlay ===
                      if (state.isSummarizing)
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
                                  'جاري الرجوع لآباء الكنيسة...',
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

                      // === Highlight Action Button (when text is selected) ===
                      if (state.selectedText != null &&
                          state.selectedText!.isNotEmpty)
                        Positioned(
                          bottom: 80 +
                              MediaQuery.of(context).viewInsets.bottom,
                          left: 16,
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            color: VintageTheme.inkDark.withOpacity(0.95),
                            child: InkWell(
                              onTap: () {
                                bloc.add(AddHighlightEvent(
                                  bookId: book.id,
                                  highlight: Highlight(
                                    pageNumber:
                                        state.selectedPageNumber ?? 1,
                                    text: state.selectedText!,
                                  ),
                                ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'تم حفظ العلامة',
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: VintageTheme.inkFaded,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: VintageTheme.vintageGold
                                        .withOpacity(0.5),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.bookmark_add_rounded,
                                      color: VintageTheme.vintageGold,
                                      size: 22,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'حفظ علامة',
                                      style: TextStyle(
                                        color: VintageTheme.vintageGold,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      // === Animated Summarize FAB ===
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        bottom: state.isUIVisible
                            ? 16 + MediaQuery.of(context).viewInsets.bottom
                            : -80,
                        right: 16,
                        child: FloatingActionButton.extended(
                          backgroundColor: VintageTheme.inkFaded,
                          onPressed: () =>
                              _showSummarizeDialog(context, bloc),
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

                      // === Highlight Panel ===
                      if (state.isHighlightPanelOpen)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: HighlightPanel(
                            highlights: state.highlights,
                            onGoToHighlight: (highlight) =>
                                bloc.add(GoToHighlightEvent(highlight)),
                            onRemoveHighlight: (id) => bloc.add(
                              RemoveHighlightEvent(
                                highlightId: id,
                                bookId: book.id,
                              ),
                            ),
                            onClose: () =>
                                bloc.add(ToggleHighlightPanelEvent()),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
