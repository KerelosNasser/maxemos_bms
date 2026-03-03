import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:tesseract_ocr/ocr_engine_config.dart';

import 'arabic_text_normalizer.dart';

// ─────────────────────────────────────────────────────────────────
//  DATA CLASSES
// ─────────────────────────────────────────────────────────────────

/// A single OCR search hit.
/// [yPdf] is the Y-coordinate in **PDF page space** (accurate, derived from
/// the pdfrx fragment positions even though the extracted text is garbled).
class _OcrMatch {
  final int pageNumber;
  final double yPdf; // Y in PDF coords (0 = bottom of page)

  const _OcrMatch({required this.pageNumber, required this.yPdf});
}

/// Cached per-page OCR data: the recognized text **and** the vertical extent
/// of the text region on the page (from pdfrx fragment bounds).
class _PageOcrData {
  final String text;
  final String normalizedText;

  /// Vertical text region in PDF coords (Y=0 at bottom, increases up).
  /// [textTopY] is the highest Y (top of text area).
  /// [textBottomY] is the lowest Y (bottom of text area).
  final double textTopY;
  final double textBottomY;

  /// Number of lines in the OCR text (cached for reuse).
  final int lineCount;

  const _PageOcrData({
    required this.text,
    required this.normalizedText,
    required this.textTopY,
    required this.textBottomY,
    required this.lineCount,
  });
}

// ─────────────────────────────────────────────────────────────────
//  PdfSearchIndexer
// ─────────────────────────────────────────────────────────────────

/// PDF search with Arabic support.
///
/// Path 1 – well-encoded PDFs  → pdfrx [PdfTextSearcher] + Arabic regex.
/// Path 2 – garbled/image PDFs → Tesseract OCR (free, offline, zero quota)
///          with pdfrx fragment Y-positions for accurate highlighting.
class PdfSearchIndexer {
  final PdfViewerController controller;

  // -- Path 1 --
  late final PdfTextSearcher _pdfrxSearcher;

  // -- Path 2 --
  final Map<int, _PageOcrData> _ocrCache = {}; // pageNum → data
  final List<_OcrMatch> _ocrMatches = [];
  Map<int, List<_OcrMatch>> _ocrMatchesByPage = {}; // O(1) paint lookup
  int? _ocrIndex;

  bool _isSearching = false;
  bool? _needsOcr;
  int _searchSession = 0;

  final List<VoidCallback> _listeners = [];

  PdfSearchIndexer(this.controller) {
    _pdfrxSearcher = PdfTextSearcher(controller);
  }

  // ── Public getters ──────────────────────────────────────────────
  int get matchCount =>
      _needsOcr == true ? _ocrMatches.length : _pdfrxSearcher.matches.length;

  int get currentIndex => _needsOcr == true
      ? (_ocrIndex ?? -1)
      : (_pdfrxSearcher.currentIndex ?? -1);

  bool get isSearching => _isSearching;

  void addListener(VoidCallback l) {
    _listeners.add(l);
    _pdfrxSearcher.addListener(l);
  }

  void removeListener(VoidCallback l) {
    _listeners.remove(l);
    _pdfrxSearcher.removeListener(l);
  }

  void _notify() {
    controller.invalidate();
    for (final l in _listeners) {
      l();
    }
  }

  void dispose() {
    _pdfrxSearcher.dispose();
    _listeners.clear();
    _ocrCache.clear();
  }

  // ═══════════════════════════════════════════════════════════════
  //  SEARCH API
  // ═══════════════════════════════════════════════════════════════

  Future<void> startSearch(String query) async {
    if (query.trim().isEmpty) {
      resetSearch();
      return;
    }
    _isSearching = true;
    final session = ++_searchSession;
    _notify();

    // Detect once
    _needsOcr ??= await _detectNeedsOcr();
    if (session != _searchSession) return;

    if (_needsOcr!) {
      await _searchOcr(query, session);
    } else {
      _searchPdfrx(query);
    }
  }

  void resetSearch() {
    ++_searchSession;
    _isSearching = false;
    _ocrMatches.clear();
    _ocrMatchesByPage = {};
    _ocrIndex = null;
    _pdfrxSearcher.resetTextSearch();
    _notify();
  }

  Future<void> nextMatch() async {
    if (_needsOcr == true) {
      if (_ocrMatches.isEmpty) return;
      _ocrIndex = (_ocrIndex == null)
          ? 0
          : (_ocrIndex! + 1) % _ocrMatches.length;
      _goToOcrMatch();
    } else {
      await _pdfrxSearcher.goToNextMatch();
    }
  }

  Future<void> previousMatch() async {
    if (_needsOcr == true) {
      if (_ocrMatches.isEmpty) return;
      _ocrIndex = (_ocrIndex == null)
          ? _ocrMatches.length - 1
          : (_ocrIndex! - 1 < 0 ? _ocrMatches.length - 1 : _ocrIndex! - 1);
      _goToOcrMatch();
    } else {
      await _pdfrxSearcher.goToPrevMatch();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  DETECTION
  // ═══════════════════════════════════════════════════════════════

  static final _arabicRe = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  );

  Future<bool> _detectNeedsOcr() async {
    bool hasArabic = false;
    await controller.useDocument((doc) async {
      final limit = doc.pages.length < 5 ? doc.pages.length : 5;
      for (int i = 0; i < limit; i++) {
        final t = await doc.pages[i].loadStructuredText();
        if (_arabicRe.hasMatch(t.fullText)) {
          hasArabic = true;
          break;
        }
      }
    });
    return !hasArabic;
  }

  // ═══════════════════════════════════════════════════════════════
  //  PATH 1 – pdfrx (well-encoded)
  // ═══════════════════════════════════════════════════════════════

  void _searchPdfrx(String query) {
    _pdfrxSearcher.startTextSearch(
      _ArabicRegex.build(query),
      caseInsensitive: true,
      goToFirstMatch: true,
      searchImmediately: true,
    );
    _isSearching = false;
  }

  // ═══════════════════════════════════════════════════════════════
  //  PATH 2 – Tesseract OCR (garbled / image)
  // ═══════════════════════════════════════════════════════════════

  Future<void> _searchOcr(String query, int session) async {
    final nq = ArabicTextNormalizer.normalize(query);
    _ocrMatches.clear();
    _ocrMatchesByPage = {};
    _ocrIndex = null;
    _notify();

    await controller.useDocument((doc) async {
      for (final page in doc.pages) {
        if (session != _searchSession) return;

        // ── Get or build page data ──
        _PageOcrData? data = _ocrCache[page.pageNumber];
        if (data == null) {
          data = await _buildPageOcrData(page);
          if (data != null) {
            _ocrCache[page.pageNumber] = data;
          }
        }
        if (data == null || data.normalizedText.isEmpty) continue;

        // ── Find all occurrences – O(n·m) via indexOf ──
        final nt = data.normalizedText;
        int from = 0;
        while (true) {
          final idx = nt.indexOf(nq, from);
          if (idx == -1) break;

          _ocrMatches.add(
            _OcrMatch(
              pageNumber: page.pageNumber,
              yPdf: _yForCharIndex(data, idx, page),
            ),
          );
          from = idx + 1;
        }

        // Rebuild page-indexed map incrementally so paint sees matches
        _rebuildMatchesByPage();
        _notify();
      }
    });

    if (session != _searchSession) return;

    if (_ocrMatches.isNotEmpty) {
      _ocrIndex = 0;
      _goToOcrMatch();
    }
    _isSearching = false;
    _notify();
  }

  /// Build cached OCR data for one page:
  /// 1. Extract text **bounding box** Y-extent from pdfrx fragment bounds.
  /// 2. Run Tesseract OCR for the actual Arabic text.
  Future<_PageOcrData?> _buildPageOcrData(PdfPage page) async {
    // ── Step 1: text region bounding box from pdfrx ──
    final structured = await page.loadStructuredText();
    double? minY, maxY;

    for (final frag in structured.fragments) {
      final top = frag.bounds.top;
      final bot = frag.bounds.bottom;
      final hi = top > bot ? top : bot;
      final lo = top > bot ? bot : top;
      if (maxY == null || hi > maxY) maxY = hi;
      if (minY == null || lo < minY) minY = lo;
    }

    // Fallback if no fragments: assume text fills middle 70% of page
    maxY ??= page.height * 0.88;
    minY ??= page.height * 0.12;

    // ── Step 2: Tesseract OCR ──
    final ocrText = await _tesseractPage(page);
    if (ocrText.isEmpty) return null;

    return _PageOcrData(
      text: ocrText,
      normalizedText: ArabicTextNormalizer.normalize(ocrText),
      textTopY: maxY,
      textBottomY: minY,
      lineCount: '\n'.allMatches(ocrText).length + 1,
    );
  }

  /// Rebuild the page-indexed lookup map from the flat list.
  void _rebuildMatchesByPage() {
    _ocrMatchesByPage = {};
    for (final m in _ocrMatches) {
      (_ocrMatchesByPage[m.pageNumber] ??= []).add(m);
    }
  }

  /// Map a character index in the OCR text to a PDF Y-coordinate.
  ///
  /// Uses the text bounding box from pdfrx fragments and distributes
  /// OCR lines proportionally within that region.
  double _yForCharIndex(_PageOcrData data, int charIdx, PdfPage page) {
    // IMPORTANT: charIdx is an index into normalizedText (not original text).
    // Normalization removes diacritics so lengths differ — we must count
    // newlines in normalizedText to get the correct line number.
    final clamped = charIdx.clamp(0, data.normalizedText.length);
    int lineIdx = 0;
    for (int i = 0; i < clamped; i++) {
      if (data.normalizedText.codeUnitAt(i) == 10) lineIdx++;
    }

    // Place proportionally within the text bounding box
    final ratio = data.lineCount > 1
        ? (lineIdx / (data.lineCount - 1)).clamp(0.0, 1.0)
        : 0.5;

    // Interpolate: ratio=0 → textTopY (highest Y), ratio=1 → textBottomY
    return data.textTopY - ratio * (data.textTopY - data.textBottomY);
  }

  /// Render page → Tesseract OCR → return Arabic text.
  Future<String> _tesseractPage(PdfPage page) async {
    try {
      // 2x is enough for Tesseract and faster than 3x
      final rendered = await page.render(
        fullWidth: page.width * 2,
        fullHeight: page.height * 2,
      );
      if (rendered == null) return '';

      try {
        final img = await rendered.createImage();
        final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
        if (bytes == null) return '';

        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/_ocr_${page.pageNumber}.png');
        await file.writeAsBytes(Uint8List.view(bytes.buffer), flush: true);

        final text = await TesseractOcr.extractText(
          file.path,
          config: const OCRConfig(language: 'ara'),
        );

        file.delete().ignore();
        return text;
      } finally {
        rendered.dispose();
      }
    } catch (e) {
      debugPrint('⚠ Tesseract error p${page.pageNumber}: $e');
      return '';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  NAVIGATION
  // ═══════════════════════════════════════════════════════════════

  void _goToOcrMatch() {
    if (_ocrIndex == null ||
        _ocrIndex! < 0 ||
        _ocrIndex! >= _ocrMatches.length) {
      return;
    }
    final m = _ocrMatches[_ocrIndex!];
    controller.setCurrentPageNumber(m.pageNumber);

    try {
      final page = controller.document.pages[m.pageNumber - 1];
      // Build a thin horizontal strip at the match's Y in PDF coords
      final rect = PdfRect(0, m.yPdf + 15, page.width, m.yPdf - 15);
      controller.ensureVisible(
        controller.calcRectForRectInsidePage(
          pageNumber: m.pageNumber,
          rect: rect,
        ),
        margin: 80,
      );
    } catch (_) {}
    _notify();
  }

  // ═══════════════════════════════════════════════════════════════
  //  PAINT CALLBACK
  // ═══════════════════════════════════════════════════════════════

  void pageTextMatchPaintCallback(
    ui.Canvas canvas,
    Rect pageRect,
    PdfPage page,
  ) {
    if (_needsOcr == true) {
      _paintOcr(canvas, pageRect, page);
    } else {
      _pdfrxSearcher.pageTextMatchPaintCallback(canvas, pageRect, page);
    }
  }

  /// Paint highlight strips at **accurate** vertical positions.
  ///
  /// Uses pre-indexed `_ocrMatchesByPage` → O(1) page lookup,
  /// then O(pageMatches) to draw.
  void _paintOcr(ui.Canvas canvas, Rect pageRect, PdfPage page) {
    final pageMatches = _ocrMatchesByPage[page.pageNumber];
    if (pageMatches == null || pageMatches.isEmpty) return;

    final activeMatch = (_ocrIndex != null && _ocrIndex! < _ocrMatches.length)
        ? _ocrMatches[_ocrIndex!]
        : null;

    // Scale factor: PDF points → screen pixels
    final scale = pageRect.height / page.height;

    const stripH = 22.0;
    final inactiveColor = Colors.yellow.withAlpha(80);
    final activeColor = Colors.orange.withAlpha(120);
    final accentColor = Colors.orange;

    for (final m in pageMatches) {
      // Convert PDF Y to Flutter screen Y
      // PDF: Y=0 at bottom, increases upward
      // Flutter: Y=0 at top, increases downward
      final screenY = pageRect.top + (page.height - m.yPdf) * scale;

      final isActive =
          activeMatch != null &&
          m.pageNumber == activeMatch.pageNumber &&
          (m.yPdf - activeMatch.yPdf).abs() < 5;

      // Highlight strip
      final strip = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(pageRect.center.dx, screenY),
          width: pageRect.width * 0.94,
          height: stripH,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        strip,
        Paint()..color = isActive ? activeColor : inactiveColor,
      );

      // Left accent bar for active match
      if (isActive) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(pageRect.left + 3, screenY - stripH / 2, 4, stripH),
            const Radius.circular(2),
          ),
          Paint()..color = accentColor,
        );
      }
    }

    // Match count badge
    _paintBadge(
      canvas,
      pageRect,
      pageMatches.length,
      activeMatch?.pageNumber == page.pageNumber,
    );
  }

  void _paintBadge(ui.Canvas canvas, Rect pageRect, int count, bool isActive) {
    final tp = TextPainter(
      text: TextSpan(
        text: ' $count ',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        pageRect.right - tp.width - 10,
        pageRect.top + 8,
        tp.width + 6,
        tp.height + 4,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      r,
      Paint()..color = isActive ? Colors.orange : Colors.amber.shade700,
    );
    tp.paint(canvas, Offset(r.left + 3, r.top + 2));
  }
}

// ═══════════════════════════════════════════════════════════════
//  Arabic Regex (Path 1 only)
// ═══════════════════════════════════════════════════════════════

class _ArabicRegex {
  static const _d =
      r'[\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED\u0640\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]*';

  static const _eq = <String, String>{
    'ا': r'[اأإآٱ]',
    'أ': r'[اأإآٱ]',
    'إ': r'[اأإآٱ]',
    'آ': r'[اأإآٱ]',
    'ٱ': r'[اأإآٱ]',
    'ة': r'[ةه]',
    'ه': r'[ةه]',
    'ي': r'[يئى]',
    'ئ': r'[يئى]',
    'ى': r'[يئى]',
    'و': r'[وؤ]',
    'ؤ': r'[وؤ]',
    'ء': r'[ءأإؤئ]?',
  };

  static RegExp build(String query) {
    final n = ArabicTextNormalizer.normalize(query);
    if (n.isEmpty) return RegExp('');
    final b = StringBuffer();
    for (int i = 0; i < n.length; i++) {
      if (i > 0) b.write(_d);
      final c = n[i];
      if (_eq.containsKey(c)) {
        b.write(_eq[c]);
      } else if (r'\.^$*+?{}[]|()'.contains(c)) {
        b.write('\\$c');
      } else {
        b.write(c);
      }
    }
    return RegExp(b.toString(), unicode: true, caseSensitive: false);
  }
}
