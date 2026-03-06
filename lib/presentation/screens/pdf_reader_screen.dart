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
import '../widgets/pdf_page_scrubber.dart';
import '../widgets/pdf/pdf_download_progress_view.dart';
import '../widgets/pdf/pdf_download_error_view.dart';
import '../widgets/pdf/pdf_summarize_overlay.dart';
import '../../core/utils/scriptural_regex_engine.dart';
import '../widgets/verse_overlay_sheet.dart';
import '../widgets/lexicon_overlay_sheet.dart';
import '../widgets/ask_ai_overlay_sheet.dart';

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
        ..add(LoadPreferencesEvent())
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
                    ? PdfDownloadProgressView(state: state, book: book)
                    : state.downloadError != null
                    ? PdfDownloadErrorView(
                        state: state,
                        bloc: bloc,
                        book: book,
                        parentContext: context,
                      )
                    : state.pdfFilePath == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: VintageTheme.vintageGold,
                        ),
                      )
                    : _buildReaderView(context, state, bloc, book, topPadding),
              );
            },
          );
        },
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
            child: Builder(
              builder: (context) {
                final w = state.sepiaWeight;
                return ColorFiltered(
                  colorFilter: state.isSepiaModeEnabled
                      ? ColorFilter.matrix([
                          0.393 * w + 1.0 * (1 - w),
                          0.769 * w,
                          0.189 * w,
                          0,
                          0,
                          0.349 * w,
                          0.686 * w + 1.0 * (1 - w),
                          0.168 * w,
                          0,
                          0,
                          0.272 * w,
                          0.534 * w,
                          0.131 * w + 1.0 * (1 - w),
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ])
                      : const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.multiply,
                        ),
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
                            bloc.add(
                              SetSelectedTextEvent(
                                text: text,
                                pageNumber: bloc.pdfController.pageNumber ?? 1,
                              ),
                            );
                          } else {
                            bloc.add(ClearSelectedTextEvent());
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // === Edge Navigation Zones (Optional) ===
          if (state.isNavigationZonesEnabled) ...[
            Positioned(
              left: 0,
              top: kToolbarHeight + topPadding,
              bottom: 80,
              width:
                  MediaQuery.of(context).size.width *
                  state.navigationZonesWidth,
              child: GestureDetector(
                onTap: () {
                  final current = bloc.pdfController.pageNumber ?? 1;
                  if (current > 1) {
                    bloc.pdfController.goToPage(pageNumber: current - 1);
                  }
                },
                behavior: HitTestBehavior.translucent,
              ),
            ),
            Positioned(
              right: 0,
              top: kToolbarHeight + topPadding,
              bottom: 80,
              width:
                  MediaQuery.of(context).size.width *
                  state.navigationZonesWidth,
              child: GestureDetector(
                onTap: () {
                  final current = bloc.pdfController.pageNumber ?? 1;
                  final total = bloc.pdfController.pageCount;
                  if (current < total) {
                    bloc.pdfController.goToPage(pageNumber: current + 1);
                  }
                },
                behavior: HitTestBehavior.translucent,
              ),
            ),
          ],

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
          if (state.isSummarizing) const PdfSummarizeOverlay(),

          // === Highlight & Bible Action Buttons ===
          if (state.selectedText != null && state.selectedText!.isNotEmpty)
            Positioned(
              bottom: 80 + MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HighlightActionButton(bookId: book.id, bookTitle: book.title),
                  Builder(
                    builder: (btnContext) {
                      final text = state.selectedText!;
                      final refs = ScripturalRegexEngine.parse(text);
                      final isSingleWord =
                          !text.trim().contains(' ') && text.trim().length >= 3;

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (refs.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: FloatingActionButton.extended(
                                heroTag: 'bible_verse_btn',
                                backgroundColor: VintageTheme.parchmentLight,
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => VerseOverlaySheet(
                                      reference: refs.first,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.menu_book_rounded,
                                  color: VintageTheme.inkDark,
                                ),
                                label: Text(
                                  'عرض ${refs.first.toString()}',
                                  style: const TextStyle(
                                    fontFamily: 'Amiri',
                                    color: VintageTheme.inkDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          if (isSingleWord && state.isDefinitionAvailable)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: FloatingActionButton.extended(
                                heroTag: 'lexicon_btn',
                                backgroundColor: VintageTheme.parchmentLight,
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => LexiconOverlaySheet(
                                      selectedText: text.trim(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.import_contacts_rounded,
                                  color: VintageTheme.inkDark,
                                ),
                                label: const Text(
                                  'القاموس',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    color: VintageTheme.inkDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: FloatingActionButton.extended(
                              heroTag: 'ask_ai_btn',
                              backgroundColor: VintageTheme.parchmentLight,
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => AskAiOverlaySheet(
                                    selectedText: text.trim(),
                                    bookTitle: widget.book.title,
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.auto_awesome,
                                color: VintageTheme.inkDark,
                              ),
                              label: const Text(
                                'اسأل الذكاء الاصطناعي',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  color: VintageTheme.inkDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          if (refs.isEmpty &&
                              !(isSingleWord && state.isDefinitionAvailable))
                            const SizedBox.shrink(),
                        ],
                      );
                    },
                  ),
                ],
              ),
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
              onPressed: () =>
                  showSummarizeInputDialog(context, bloc, book.title),
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
                  RemoveHighlightEvent(highlightId: id, bookId: book.id),
                ),
                onClose: () => bloc.add(ToggleHighlightPanelEvent()),
              ),
            ),

          // === Page Indicator / Scrubber (Google Drive Style) ===
          Positioned(
            right: 0,
            top: topPadding + kToolbarHeight + 16,
            bottom: 80 + MediaQuery.of(context).viewInsets.bottom,
            width:
                150, // width just to constrain the scrubber's drag area + pill
            child: PdfPageScrubber(
              currentPage: state.currentPage,
              totalPages: state.totalPages,
              controller: bloc.pdfController,
              isUIVisible: state.isUIVisible,
            ),
          ),
        ],
      ),
    );
  }
}
