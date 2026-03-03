import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'ocr_match.dart';

class PdfSearchPainter {
  /// Paint highlight strips at **accurate** vertical positions.
  static void paintOcr(
    ui.Canvas canvas,
    Rect pageRect,
    PdfPage page,
    List<OcrMatch>? pageMatches,
    OcrMatch? activeMatch,
  ) {
    if (pageMatches == null || pageMatches.isEmpty) return;

    // Scale factor: PDF points → screen pixels
    final scale = pageRect.height / page.height;

    const stripH = 22.0;
    final inactiveColor = Colors.yellow.withAlpha(80);
    final activeColor = Colors.orange.withAlpha(120);
    final accentColor = Colors.orange;

    for (final m in pageMatches) {
      // Convert PDF Y to Flutter screen Y
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
    paintBadge(
      canvas,
      pageRect,
      pageMatches.length,
      activeMatch?.pageNumber == page.pageNumber,
    );
  }

  static void paintBadge(
    ui.Canvas canvas,
    Rect pageRect,
    int count,
    bool isActive,
  ) {
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
