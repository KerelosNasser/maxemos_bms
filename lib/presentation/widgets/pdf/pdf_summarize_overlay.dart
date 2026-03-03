import 'package:flutter/material.dart';
import '../../../core/theme/vintage_theme.dart';

class PdfSummarizeOverlay extends StatelessWidget {
  const PdfSummarizeOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: VintageTheme.vintageGold),
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
    );
  }
}
