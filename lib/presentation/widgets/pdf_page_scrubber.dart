import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../core/theme/vintage_theme.dart';

class PdfPageScrubber extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final PdfViewerController controller;
  final bool isUIVisible;

  const PdfPageScrubber({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.controller,
    required this.isUIVisible,
  });

  @override
  State<PdfPageScrubber> createState() => _PdfPageScrubberState();
}

class _PdfPageScrubberState extends State<PdfPageScrubber> {
  bool _isDragging = false;
  Timer? _hideTimer;
  bool _showPill = false;

  void _onInteractionStart() {
    setState(() {
      _isDragging = true;
      _showPill = true;
    });
    _hideTimer?.cancel();
  }

  void _onInteractionEnd() {
    setState(() {
      _isDragging = false;
    });
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && !_isDragging) {
        setState(() {
          _showPill = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(PdfPageScrubber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage != oldWidget.currentPage && !_isDragging) {
      // Whenever the page changes naturally (via scrolling), show the pill temporarily.
      setState(() => _showPill = true);
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _handleDrag(double localDy, double trackHeight) {
    if (widget.totalPages <= 1) return;

    // Clamp to track bounds
    final clampedDy = localDy.clamp(0.0, trackHeight);

    // Calculate percentage and page
    final percentage = clampedDy / trackHeight;
    final int targetPage = (percentage * (widget.totalPages - 1)).round() + 1;

    if (targetPage != widget.currentPage) {
      widget.controller.goToPage(pageNumber: targetPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalPages <= 1) return const SizedBox.shrink();

    // Determine visibility:
    // If UI is visible, we show the thumb (faded track).
    // If the page just changed or is being dragged, we show the pill strongly.
    final bool isVisible = widget.isUIVisible || _showPill;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isVisible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final trackHeight = constraints.maxHeight;
            // Provide a sensible default if somehow height is 0
            if (trackHeight <= 0) return const SizedBox.shrink();

            // Calculate current thumb position
            final percentage =
                (widget.currentPage - 1) / (widget.totalPages - 1);
            final thumbTop =
                percentage * (trackHeight - 40); // 40 is thumb height

            return Stack(
              children: [
                // ── The Invisible Drag Track ──
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 40, // Wide enough to grab easily
                  child: GestureDetector(
                    onVerticalDragDown: (details) {
                      _onInteractionStart();
                      _handleDrag(details.localPosition.dy, trackHeight);
                    },
                    onVerticalDragUpdate: (details) {
                      _handleDrag(details.localPosition.dy, trackHeight);
                    },
                    onVerticalDragEnd: (_) => _onInteractionEnd(),
                    onVerticalDragCancel: () => _onInteractionEnd(),
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // ── The Thumb ──
                Positioned(
                  right: 4,
                  top: thumbTop,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: _isDragging ? 6 : 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isDragging || _showPill
                          ? VintageTheme.vintageGold
                          : Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                // ── The Page Indicator Pill (Like Google Drive) ──
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  right: (_showPill || _isDragging) ? 20 : -100, // Slide in/out
                  top: thumbTop - 10, // Center relative to thumb
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: (_showPill || _isDragging) ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: VintageTheme.inkDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: VintageTheme.vintageGold.withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${widget.currentPage} / ${widget.totalPages}',
                        style: const TextStyle(
                          color: VintageTheme.vintageGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
