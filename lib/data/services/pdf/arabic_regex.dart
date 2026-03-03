import '../arabic_text_normalizer.dart';

class ArabicRegex {
  static const _d =
      r'[\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED\u0640\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]*';

  static const _eq = <String, String>{
    'ا': r'[اأإآٱ]',
    'أ': r'[اأإآٱ]',
    'إ': r'[اأإآٱ]',
    'آ': r'[اأإآٱ]',
    'ٱ': r'[اأإآٱ]',
    'ة': r'[ةه]',
    'ه': r'[ةه]',
    'ي': r'[يئى]',
    'ئ': r'[يئى]',
    'ى': r'[يئى]',
    'و': r'[وؤ]',
    'ؤ': r'[وؤ]',
    'ء': r'[ءأإؤئ]?',
  };

  static RegExp build(String query) {
    final n = ArabicTextNormalizer.normalize(query);
    if (n.isEmpty) return RegExp('');
    final b = StringBuffer();
    for (int i = 0; i < n.length; i++) {
      if (i > 0) b.write(_d);
      final c = n[i];
      if (_eq.containsKey(c)) {
        b.write(_eq[c]);
      } else if (r'\.^$*+?{}[]|()'.contains(c)) {
        b.write('\\$c');
      } else {
        b.write(c);
      }
    }
    return RegExp(b.toString(), unicode: true, caseSensitive: false);
  }
}
