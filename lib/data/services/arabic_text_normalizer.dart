/// Comprehensive Arabic text normalizer for high-accuracy search.
///
/// Handles:
/// - All diacritics/tashkeel removal (Fathah, Dammah, Kasrah, Shadda, Sukun, Tanween, etc.)
/// - Hamza variations (أ إ آ ء ؤ ئ)
/// - Taa Marbuta / Haa equivalence
/// - Alif Maqsura / Yaa equivalence
/// - Tatweel/Kashida removal (ـ)
/// - Zero-width characters (ZWJ, ZWNJ, etc.)
/// - Arabic-Indic numeral normalization (٠-٩ → 0-9)
/// - Eastern Arabic-Indic numeral normalization (۰-۹ → 0-9)
/// - Whitespace collapsing
class ArabicTextNormalizer {
  // --- Diacritics / Tashkeel Unicode Ranges ---
  // \u064B Fathatan   \u064C Dammatan   \u064D Kasratan
  // \u064E Fathah     \u064F Dammah     \u0650 Kasrah
  // \u0651 Shadda     \u0652 Sukun
  // \u0653 Maddah Above  \u0654 Hamza Above  \u0655 Hamza Below
  // \u0656-\u065F Extended Arabic diacritics
  // \u0670 Superscript Alef (dagger alef)
  // \u06D6-\u06DC Quranic annotation signs
  // \u06DF-\u06E4 Quranic marks
  // \u06E7-\u06E8 Quranic marks
  // \u06EA-\u06ED Quranic marks
  static final RegExp _diacriticsPattern = RegExp(
    r'[\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED]',
  );

  // Tatweel / Kashida (elongation character used in typesetting)
  static const String _tatweel = '\u0640';

  // Zero-width characters that can appear in Arabic text
  static final RegExp _zeroWidthChars = RegExp(
    r'[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]',
  );

  // Arabic-Indic numerals ٠١٢٣٤٥٦٧٨٩
  static const String _arabicIndicNumerals = '٠١٢٣٤٥٦٧٨٩';

  // Eastern Arabic-Indic numerals ۰۱۲۳۴۵۶۷۸۹
  static const String _easternArabicIndicNumerals = '۰۱۲۳۴۵۶۷۸۹';

  // Western numerals
  static const String _westernNumerals = '0123456789';

  /// Main normalization entry point.
  /// Produces a canonical form suitable for fuzzy Arabic searching.
  static String normalize(String text) {
    if (text.isEmpty) return text;

    var normalized = text;

    // 1. Remove zero-width / bidi control characters
    normalized = normalized.replaceAll(_zeroWidthChars, '');

    // 2. Remove Tatweel / Kashida
    normalized = normalized.replaceAll(_tatweel, '');

    // 3. Remove all diacritics (tashkeel + Quranic marks)
    normalized = normalized.replaceAll(_diacriticsPattern, '');

    // 4. Normalize Hamza-on-carrier forms → base letter
    //    أ إ آ → ا   (Alif variations with/without Hamza)
    normalized = normalized.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // 5. Normalize standalone Hamza variations
    //    ء (standalone hamza) stays as-is for now since removing it
    //    can merge unrelated words. But for broader search we remove it.
    normalized = normalized.replaceAll('ء', '');

    // 6. Normalize Waw with Hamza → bare Waw
    normalized = normalized.replaceAll('ؤ', 'و');

    // 7. Normalize Yaa with Hamza → bare Yaa
    normalized = normalized.replaceAll('ئ', 'ي');

    // 8. Normalize Taa Marbuta → Haa
    normalized = normalized.replaceAll('ة', 'ه');

    // 9. Normalize Alif Maqsura → Yaa
    normalized = normalized.replaceAll('ى', 'ي');

    // 10. Normalize Arabic-Indic numerals → Western
    for (int i = 0; i < 10; i++) {
      normalized = normalized.replaceAll(
        _arabicIndicNumerals[i],
        _westernNumerals[i],
      );
      normalized = normalized.replaceAll(
        _easternArabicIndicNumerals[i],
        _westernNumerals[i],
      );
    }

    // 11. Collapse multiple whitespace into single space
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 12. Lowercase for mixed Arabic/English search
    return normalized.toLowerCase();
  }

  /// Builds a character-index mapping from original text to normalized text.
  /// Returns a list where `mapping[normalizedIndex] = originalIndex`.
  /// This allows us to trace a match in normalized text back to the
  /// original text positions for accurate highlighting.
  static List<int> buildIndexMapping(String original) {
    final mapping = <int>[];
    final runes = original.runes.toList();

    for (int i = 0; i < runes.length; i++) {
      final char = String.fromCharCode(runes[i]);

      // Check if character is removed by normalization
      if (_diacriticsPattern.hasMatch(char)) continue;
      if (char == _tatweel) continue;
      if (_zeroWidthChars.hasMatch(char)) continue;
      if (char == 'ء') continue; // standalone hamza removed

      // Whitespace collapsing: skip consecutive whitespace after first
      if (RegExp(r'\s').hasMatch(char)) {
        if (mapping.isNotEmpty && i > 0) {
          final prevChar = String.fromCharCode(runes[i - 1]);
          if (RegExp(r'\s').hasMatch(prevChar)) continue;
        }
      }

      mapping.add(i);
    }

    return mapping;
  }
}
