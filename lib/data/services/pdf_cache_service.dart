import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

/// Downloads and caches PDFs locally with configurable timeout.
/// Also caches the book list metadata for full offline support.
class PdfCacheService {
  static const _bookListKey = 'cached_book_list';

  // ─── PDF Download & Cache ───

  /// Returns the local [File] for a cached PDF.
  /// Downloads if not already cached.
  static Future<File> getCachedPdf({
    required String bookId,
    required String downloadUrl,
    void Function(int received, int total)? onProgress,
  }) async {
    final cacheDir = await getApplicationCacheDirectory();
    final pdfDir = Directory('${cacheDir.path}/pdfs');
    if (!pdfDir.existsSync()) {
      pdfDir.createSync(recursive: true);
    }
    final file = File('${pdfDir.path}/$bookId.pdf');

    // Return cached file if it exists and is non-empty
    if (file.existsSync() && file.lengthSync() > 0) {
      return file;
    }

    // Download with generous timeout for large PDFs
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 30);

    try {
      final request = await client.getUrl(Uri.parse(downloadUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to download PDF: HTTP ${response.statusCode}',
        );
      }

      final totalBytes = response.contentLength;
      int receivedBytes = 0;
      final sink = file.openWrite();

      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        onProgress?.call(receivedBytes, totalBytes);
      }

      await sink.flush();
      await sink.close();

      return file;
    } catch (e) {
      if (file.existsSync()) {
        file.deleteSync();
      }
      rethrow;
    } finally {
      client.close();
    }
  }

  // ─── Cache Status ───

  /// Check if a PDF is cached locally (synchronous).
  static Future<bool> isCached(String bookId) async {
    final cacheDir = await getApplicationCacheDirectory();
    final file = File('${cacheDir.path}/pdfs/$bookId.pdf');
    return file.existsSync() && file.lengthSync() > 0;
  }

  /// Returns a Set of all cached book IDs.
  static Future<Set<String>> getCachedBookIds() async {
    final cacheDir = await getApplicationCacheDirectory();
    final pdfDir = Directory('${cacheDir.path}/pdfs');
    if (!pdfDir.existsSync()) return {};

    return pdfDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.pdf') && f.lengthSync() > 0)
        .map((f) => f.uri.pathSegments.last.replaceAll('.pdf', ''))
        .toSet();
  }

  // ─── Book List Cache (for offline) ───

  /// Saves the book list metadata to SharedPreferences.
  static Future<void> cacheBookList(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = books.map((b) => b.toJson()).toList();
    await prefs.setString(_bookListKey, jsonEncode(jsonList));
  }

  /// Retrieves the cached book list. Returns empty list if no cache.
  static Future<List<Book>> getCachedBookList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_bookListKey);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => Book.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ─── Cache Management ───

  static Future<void> clearCache(String bookId) async {
    final cacheDir = await getApplicationCacheDirectory();
    final file = File('${cacheDir.path}/pdfs/$bookId.pdf');
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  static Future<void> clearAllCache() async {
    final cacheDir = await getApplicationCacheDirectory();
    final pdfDir = Directory('${cacheDir.path}/pdfs');
    if (pdfDir.existsSync()) {
      pdfDir.deleteSync(recursive: true);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookListKey);
  }
}
