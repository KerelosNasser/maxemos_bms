import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/highlight.dart';

/// Persists text highlights per book using shared_preferences.
/// Storage key pattern: `highlights_<bookId>`
class HighlightService {
  static const String _keyPrefix = 'highlights_';

  static Future<List<Highlight>> getHighlights(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_keyPrefix$bookId');
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => Highlight.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveHighlight(String bookId, Highlight highlight) async {
    final highlights = await getHighlights(bookId);
    // Avoid duplicates by ID
    highlights.removeWhere((h) => h.id == highlight.id);
    highlights.insert(0, highlight);
    await _persist(bookId, highlights);
  }

  static Future<void> removeHighlight(String bookId, String highlightId) async {
    final highlights = await getHighlights(bookId);
    highlights.removeWhere((h) => h.id == highlightId);
    await _persist(bookId, highlights);
  }

  static Future<void> _persist(
    String bookId,
    List<Highlight> highlights,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(highlights.map((h) => h.toJson()).toList());
    await prefs.setString('$_keyPrefix$bookId', jsonString);
  }

  /// Retrieves all highlights across all scattered books.
  static Future<List<Highlight>> getAllHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith(_keyPrefix))
        .toList();

    List<Highlight> allHighlights = [];
    for (String key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final List<dynamic> jsonList =
              json.decode(jsonString) as List<dynamic>;
          allHighlights.addAll(
            jsonList.map((e) => Highlight.fromJson(e as Map<String, dynamic>)),
          );
        } catch (_) {
          // Ignore corrupted book highlights
        }
      }
    }

    allHighlights.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allHighlights;
  }

  /// Updates a specific highlight globally by replacing it in its corresponding book's list.
  static Future<void> updateHighlightGlobal(Highlight updatedHighlight) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith(_keyPrefix))
        .toList();

    for (String key in keys) {
      final bookId = key.replaceFirst(_keyPrefix, '');
      final highlights = await getHighlights(bookId);
      final index = highlights.indexWhere((h) => h.id == updatedHighlight.id);
      if (index != -1) {
        highlights[index] = updatedHighlight;
        await _persist(bookId, highlights);
        return; // found and replaced
      }
    }
  }

  static Future<void> removeHighlightGlobal(String highlightId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith(_keyPrefix))
        .toList();

    for (String key in keys) {
      final bookId = key.replaceFirst(_keyPrefix, '');
      final highlights = await getHighlights(bookId);
      final index = highlights.indexWhere((h) => h.id == highlightId);
      if (index != -1) {
        highlights.removeAt(index);
        await _persist(bookId, highlights);
        return;
      }
    }
  }

  static Future<List<String>> getSermonFolders() async {
    final allHighlights = await getAllHighlights();
    final Set<String> folders = {};
    for (var highlight in allHighlights) {
      if (highlight.folderId != null && highlight.folderId!.trim().isNotEmpty) {
        folders.add(highlight.folderId!.trim());
      }
    }
    return folders.toList()..sort();
  }
}
