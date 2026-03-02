import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/book.dart';
import '../../core/theme/vintage_theme.dart';
import '../bloc/pdf_reader_bloc.dart';
import '../bloc/pdf_reader_event.dart';
import '../bloc/pdf_reader_state.dart';
import '../widgets/pdf_reader_app_bar.dart';
import '../widgets/pdf_search_bar.dart';
import '../widgets/pdf_zoom_controls.dart';
import '../widgets/pdf_summarize_dialogs.dart';
import '../widgets/highlight_panel.dart';
import '../widgets/highlight_action_button.dart';

class PdfReaderScreen extends StatefulWidget {
  final Book book;

  const PdfReaderScreen({super.key, required this.book});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  void Function(FlutterErrorDetails)? _originalOnError;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Suppress known pdfrx RenderFlex overflow (debug only, stripped in release).
    _originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.toString().contains('A RenderFlex overflowed')) return;
      _originalOnError?.call(details);
    };
  }

  @override
  void dispose() {
    FlutterError.onError = _originalOnError;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final downloadUrl =
        'https://drive.google.com/uc?export=download&id=${book.id}';

    return BlocProvider(
      create: (_) => PdfReaderBloc()
        ..add(LoadHighlightsEvent(book.id))
        ..add(DownloadPdfEvent(bookId: book.id, downloadUrl: downloadUrl)),
      child: Builder(
        builder: (context) {
          final bloc = context.read<PdfReaderBloc>();
          return BlocConsumer<PdfReaderBloc, PdfReaderState>(
            listener: (context, state) {
              if (state is PdfReaderSummarySuccess) {
                showSummaryResultDialog(context, state.summary);
              }
            },
            builder: (context, state) {
              final topPadding = MediaQuery.of(context).padding.top;

              return Scaffold(
                backgroundColor: Colors.black,
                resizeToAvoidBottomInset: false,
                body: state.isDownloading
                    ? _buildDownloadProgress(state)
                    : state.downloadError != null
                        ? _buildDownloadError(state, bloc, book)
                        : _buildReaderView(
                            context, state, bloc, book, topPadding),
              );
            },
          );
        },
      ),
    );
  }

  // === Download Progress ===
  Widget _buildDownloadProgress(PdfReaderState state) {
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
              widget.book.title,
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

  // === Download Error ===
  Widget _buildDownloadError(
    PdfReaderState state,
    PdfReaderBloc bloc,
    Book book,
  ) {
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
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('رجوع'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => bloc.add(DownloadPdfEvent(
                      bookId: book.id,
                      downloadUrl: downloadUrl,
                    )),
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

  // === Main Reader View ===
  Widget _buildReaderView(
    BuildContext context,
    PdfReaderState state,
    PdfReaderBloc bloc,
    Book book,
    double topPadding,
  ) {
    return Listener(
      onPointerMove: (event) {
        // Detect drag direction from raw pointer events.
        // PdfViewer uses InteractiveViewer internally, so
        // UserScrollNotification is never dispatched.
        if (event.delta.dy < -4 && state.isUIVisible) {
          bloc.add(ToggleUIVisibilityEvent(false));
        } else if (event.delta.dy > 4 && !state.isUIVisible) {
          bloc.add(ToggleUIVisibilityEvent(true));
        }
      },
      child: Stack(
        children: [
          // === PDF Viewer (from cached file) ===
          Positioned.fill(
            child: PdfViewer.file(
              state.pdfFilePath!,
              controller: bloc.pdfController,
              params: PdfViewerParams(
                backgroundColor: VintageTheme.inkDark,
                onViewerReady: (document, controller) {
                  bloc.initSearcher(document, controller);
                },
                pagePaintCallbacks: [
                  if (bloc.textSearcher != null)
                    bloc.textSearcher!.pageTextMatchPaintCallback,
                ],
                textSelectionParams: PdfTextSelectionParams(
                  enabled: true,
                  onTextSelectionChange: (selections) async {
                    final text = await selections.getSelectedText();
                    if (text.isNotEmpty) {
                      bloc.add(SetSelectedTextEvent(
                        text: text,
                        pageNumber: bloc.pdfController.pageNumber ?? 1,
                      ));
                    } else {
                      bloc.add(ClearSelectedTextEvent());
                    }
                  },
                ),
              ),
            ),
          ),

          // === Search Bar ===
          if (state.isSearching)
            Positioned(
              top: topPadding + 8,
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
                : -(kToolbarHeight + topPadding),
            left: 0,
            right: 0,
            child: PdfReaderAppBarContent(
              bookId: book.id,
              bookTitle: book.title,
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
            Positioned.fill(
              child: Container(
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
            ),

          // === Highlight Action Button ===
          if (state.selectedText != null && state.selectedText!.isNotEmpty)
            Positioned(
              bottom: 80 + MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              child: HighlightActionButton(bookId: book.id),
            ),

          // === Summarize FAB ===
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: state.isUIVisible
                ? 16 + MediaQuery.of(context).viewInsets.bottom
                : -80,
            right: 16,
            child: FloatingActionButton.extended(
              backgroundColor: VintageTheme.inkFaded,
              onPressed: () => showSummarizeInputDialog(
                context,
                bloc,
                book.title,
              ),
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
                onGoToHighlight: (h) => bloc.add(GoToHighlightEvent(h)),
                onRemoveHighlight: (id) => bloc.add(
                  RemoveHighlightEvent(
                    highlightId: id,
                    bookId: book.id,
                  ),
                ),
                onClose: () => bloc.add(ToggleHighlightPanelEvent()),
              ),
            ),
        ],
      ),
    );
  }
}
