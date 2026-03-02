import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../core/theme/vintage_theme.dart';

class PdfSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final PdfTextSearcher? textSearcher;
  final VoidCallback onClose;
  final ValueChanged<String> onSubmitted;

  const PdfSearchBar({
    super.key,
    required this.controller,
    required this.textSearcher,
    required this.onClose,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: VintageTheme.inkFaded,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'البحث في الكتاب...', // Search within PDF...
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onSubmitted: onSubmitted,
              ),
            ),
            if (textSearcher?.isSearching == true)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: VintageTheme.vintageGold,
                    strokeWidth: 2,
                  ),
                ),
              ),
            if (textSearcher != null && controller.text.isNotEmpty) ...[
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                onPressed: () => textSearcher?.goToPrevMatch(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                onPressed: () => textSearcher?.goToNextMatch(),
              ),
            ],
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
