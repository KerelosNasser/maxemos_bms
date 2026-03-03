/// A single OCR search hit.
/// [yPdf] is the Y-coordinate in **PDF page space** (accurate, derived from
/// the pdfrx fragment positions even though the extracted text is garbled).
class OcrMatch {
  final int pageNumber;
  final double yPdf; // Y in PDF coords (0 = bottom of page)

  const OcrMatch({required this.pageNumber, required this.yPdf});
}

/// Cached per-page OCR data: the recognized text **and** the vertical extent
/// of the text region on the page (from pdfrx fragment bounds).
class PageOcrData {
  final String text;
  final String normalizedText;

  /// Vertical text region in PDF coords (Y=0 at bottom, increases up).
  /// [textTopY] is the highest Y (top of text area).
  /// [textBottomY] is the lowest Y (bottom of text area).
  final double textTopY;
  final double textBottomY;

  /// Number of lines in the OCR text (cached for reuse).
  final int lineCount;

  const PageOcrData({
    required this.text,
    required this.normalizedText,
    required this.textTopY,
    required this.textBottomY,
    required this.lineCount,
  });
}
