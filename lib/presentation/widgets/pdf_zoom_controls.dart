import 'package:flutter/material.dart';
import '../../core/theme/vintage_theme.dart';

/// Floating zoom control strip — vertical layout on the left side.
class PdfZoomControls extends StatelessWidget {
  final double zoomLevel;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomReset;

  const PdfZoomControls({
    super.key,
    required this.zoomLevel,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onZoomReset,
  });

  @override
  Widget build(BuildContext context) {
    final zoomPercent = '${(zoomLevel * 100).toInt()}%';

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: VintageTheme.inkDark.withOpacity(0.92),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: VintageTheme.vintageGold.withOpacity(0.25),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zoom In
            _ZoomButton(
              icon: Icons.add_rounded,
              tooltip: 'تكبير',
              onTap: onZoomIn,
            ),

            // Percentage label
            GestureDetector(
              onTap: onZoomReset,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Text(
                  zoomPercent,
                  style: const TextStyle(
                    color: VintageTheme.vintageGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Zoom Out
            _ZoomButton(
              icon: Icons.remove_rounded,
              tooltip: 'تصغير',
              onTap: onZoomOut,
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ZoomButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
