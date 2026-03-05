class TermRegexEngine {
  /// Strips Arabic diacritics and common prefixes/suffixes to increase match probability
  /// against our strictly defined SQLite theological terms.
  static String extractCoreRoot(String rawTerm) {
    if (rawTerm.isEmpty) return rawTerm;

    // 1. Remove all Arabic diacritics (Tashkeel)
    String cleaned = rawTerm.replaceAll(RegExp(r'[\u064B-\u065F]'), '');

    // 2. Remove non-letter characters
    cleaned = cleaned.replaceAll(RegExp(r'[^\u0600-\u06FFا-ي]'), '').trim();

    if (cleaned.length < 3) {
      return cleaned; // Too short to effectively strip safely
    }

    // 3. Strip common conjunctions/prepositions (ف، و، ك، ب) if they accompany "ال"
    List<String> compoundPrefixes = ['فال', 'وال', 'كال', 'بال', 'لل'];
    for (String prefix in compoundPrefixes) {
      if (cleaned.startsWith(prefix) && cleaned.length > prefix.length + 2) {
        cleaned = cleaned.substring(
          prefix.length - 2,
        ); // preserve "ال" because our DB stores "الكاثوليكون"
        break; // Only strip one prefix
      }
    }

    // Strip standalone conjunctions followed directly by the word (e.g., "فبصخة", "وهوموسيوس")
    List<String> singleLetterPrefixes = ['ف', 'و', 'ك', 'ب'];
    for (String prefix in singleLetterPrefixes) {
      if (cleaned.startsWith(prefix) && cleaned.length > prefix.length + 3) {
        // Check if removing it helps (we will do a LIKE query anyway).
        // We just remove the standalone letter.
        if (!cleaned.startsWith('$prefixال')) {
          // If it had "ال", it was caught above
          cleaned = cleaned.substring(prefix.length);
        }
        break;
      }
    }

    // 4. Strip common suffixes
    List<String> suffixes = ['ها', 'هم', 'نا', 'كم', 'ه', 'ي'];
    for (String suffix in suffixes) {
      if (cleaned.endsWith(suffix) && cleaned.length > suffix.length + 3) {
        cleaned = cleaned.substring(0, cleaned.length - suffix.length);
        break;
      }
    }

    return cleaned;
  }
}
