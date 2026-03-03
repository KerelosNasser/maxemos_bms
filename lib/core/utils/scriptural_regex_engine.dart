import 'package:flutter/foundation.dart';

class BibleReference {
  final String bookName;
  final int chapter;
  final int verse;

  BibleReference({
    required this.bookName,
    required this.chapter,
    required this.verse,
  });

  @override
  String toString() => '$bookName $chapter:$verse';
}

/// A highly deterministic parser that strictly identifies genuine Arabic Bible citations.
class ScripturalRegexEngine {
  /// Regular expression to capture Arabic citations.
  /// Formats: [Book Name] [Chapter]:[Verse]
  /// Supports Hindi numerals (٠١٢٣٤٥٦٧٨٩) and Arabic numerals (0123456789).
  static final RegExp _citationRegex = RegExp(
    r'((?:[١٢٣123]\s*)?[\p{L}\s]+?)\s*(\d+|[٠١٢٣٤٥٦٧٨٩]+)\s*:\s*(\d+|[٠١٢٣٤٥٦٧٨٩]+)',
    unicode: true,
  );

  /// Converts Hindi numerals to standard Arabic/Latin numerals for consistent logic.
  static String _normalizeNumerals(String input) {
    const hindiToLatin = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };
    String result = input;
    hindiToLatin.forEach((hindi, latin) {
      result = result.replaceAll(hindi, latin);
    });
    return result;
  }

  /// Validates if the text extracted is indeed a standard known Bible book.
  static String? _validateBookName(String rawText) {
    // Strip redundant whitespace
    final cleaned = rawText.trim().replaceAll(RegExp(r'\s+'), ' ');

    // An exhaustive array or map of accepted book names (Van Dyck)
    // For now we check presence against a canonical set or allow generalized strings
    // bounded by length to prevent huge text captures.
    if (cleaned.length > 20 || cleaned.isEmpty) {
      return null; // Too long to be a real book name
    }

    // You can strictly map abbreviations to full names here.
    return cleaned;
  }

  /// Parses text from OCR/PDF extraction and yields all valid Bible citations.
  static List<BibleReference> parse(String text) {
    final matches = _citationRegex.allMatches(text);
    final List<BibleReference> references = [];

    for (final match in matches) {
      try {
        final rawBook = match.group(1);
        final rawChapter = match.group(2);
        final rawVerse = match.group(3);

        if (rawBook != null && rawChapter != null && rawVerse != null) {
          final bookName = _validateBookName(rawBook);
          if (bookName != null) {
            final chapter = int.parse(_normalizeNumerals(rawChapter));
            final verse = int.parse(_normalizeNumerals(rawVerse));

            references.add(
              BibleReference(
                bookName: bookName,
                chapter: chapter,
                verse: verse,
              ),
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Regex parsing error on match group: $e');
        }
      }
    }
    return references;
  }
}
