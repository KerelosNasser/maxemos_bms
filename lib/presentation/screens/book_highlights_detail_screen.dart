import 'package:flutter/material.dart';
import '../../core/theme/vintage_theme.dart';
import '../../data/models/highlight.dart';

class BookHighlightsDetailScreen extends StatelessWidget {
  final String bookTitle;
  final List<Highlight> highlights;

  const BookHighlightsDetailScreen({
    super.key,
    required this.bookTitle,
    required this.highlights,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VintageTheme.inkDark,
      appBar: AppBar(
        title: Text(
          bookTitle,
          style: const TextStyle(fontFamily: 'Amiri', fontSize: 20),
        ),
        backgroundColor: VintageTheme.inkDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://www.transparenttextures.com/patterns/old-wall.png',
            ),
            repeat: ImageRepeat.repeat,
            colorFilter: ColorFilter.mode(Colors.white10, BlendMode.dstATop),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: highlights.length,
          itemBuilder: (context, index) {
            final h = highlights[index];
            return Card(
              color: VintageTheme.parchmentLight,
              margin: const EdgeInsets.only(bottom: 16),
              surfaceTintColor: Colors.transparent,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: VintageTheme.vintageGold.withOpacity(0.4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Content
                    Text(
                      '"${h.text.trim()}"',
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 22,
                        height: 1.6,
                        color: VintageTheme.inkDark,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 16),
                    // Note (if any)
                    if (h.note != null && h.note!.trim().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: VintageTheme.vintageGold.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          h.note!.trim(),
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18,
                            color: VintageTheme.inkDark.withOpacity(0.8),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Page indicator Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: VintageTheme.crimsonRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'صفحة ${h.pageNumber}',
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 16,
                              color: VintageTheme.crimsonRed,
                              fontWeight: FontWeight.bold,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
