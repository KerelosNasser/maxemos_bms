import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/pdf_search_indexer.dart';
import '../pdf_reader_event.dart';
import '../pdf_reader_state.dart';

mixin PdfSearchMixin on Bloc<PdfReaderEvent, PdfReaderState> {
  final TextEditingController searchController = TextEditingController();
  PdfSearchIndexer? textSearcher;
  Timer? searchDebounce;
  PdfViewerController? _trackedController;

  PdfViewerController get pdfController;

  void initSearcher(PdfDocument document, PdfViewerController controller) {
    textSearcher ??= PdfSearchIndexer(controller)
        ..addListener(_onSearcherUpdate)
        ..startBackgroundPreloading();
    if (_trackedController == null) {
      _trackedController = controller;
      controller.addListener(_onControllerUpdate);
      _onControllerUpdate();
    }
  }

  void _onControllerUpdate() {
    final ctrl = _trackedController;
    if (ctrl == null || !ctrl.isReady) return;

    final page = ctrl.pageNumber ?? 1;
    final total = ctrl.pageCount;

    // Slidng window OCR update (invisible if caching isn't needed)
    textSearcher?.updateCacheWindow(page, total);

    if (page != state.currentPage || total != state.totalPages) {
      add(PageChangedEvent(currentPage: page, totalPages: total));
    }
  }

  void _onSearcherUpdate() {
    final searcher = textSearcher;
    if (searcher == null) return;
    add(
      SearchMatchesUpdatedEvent(
        matchCount: searcher.matchCount,
        currentIndex: searcher.currentIndex,
      ),
    );
  }

  void onToggleSearch(ToggleSearchEvent event, Emitter<PdfReaderState> emit) {
    final newSearching = !state.isSearching;
    if (!newSearching) {
      searchController.clear();
      textSearcher?.resetSearch();
      emit(
        state.copyWith(
          isSearching: false,
          searchMatchCount: 0,
          searchCurrentIndex: -1,
        ),
      );
    } else {
      emit(state.copyWith(isSearching: true));
    }
  }

  void onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    searchDebounce?.cancel();
    searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (event.query.isNotEmpty) {
        textSearcher?.startSearch(event.query);
      } else {
        textSearcher?.resetSearch();
        add(SearchMatchesUpdatedEvent(matchCount: 0, currentIndex: -1));
      }
    });
  }

  void onSearchNextMatch(
    SearchNextMatchEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    textSearcher?.nextMatch();
  }

  void onSearchPrevMatch(
    SearchPrevMatchEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    textSearcher?.previousMatch();
  }

  void onToggleCaseSensitivity(
    ToggleCaseSensitivityEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    final newCaseSensitive = !state.isCaseSensitive;
    emit(state.copyWith(isCaseSensitive: newCaseSensitive));

    if (searchController.text.isNotEmpty) {
      textSearcher?.startSearch(searchController.text);
    }
  }

  void onSearchMatchesUpdated(
    SearchMatchesUpdatedEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    emit(
      state.copyWith(
        searchMatchCount: event.matchCount,
        searchCurrentIndex: event.currentIndex,
      ),
    );
  }

  void disposeSearchMixin() {
    _trackedController?.removeListener(_onControllerUpdate);
    searchController.dispose();
    textSearcher?.dispose();
    searchDebounce?.cancel();
  }
}
