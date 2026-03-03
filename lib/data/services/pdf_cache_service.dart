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

  /// Returns the cached [File] immediately if it exists on disk, or [null].
  /// Use this for the fast-path check before deciding to show a loading UI.
  static Future<File?> getCachedFileIfExists(String bookId) async {
    final cacheDir = await getApplicationCacheDirectory();
    final file = File('${cacheDir.path}/pdfs/$bookId.pdf');
    if (file.existsSync() && file.lengthSync() > 0) {
      if (_isValidPdfSync(file)) return file;
      // It's a corrupted cache (likely an HTML error), clear it
      file.deleteSync();
    }
    return null;
  }

  /// Verifies the first few bytes start with '%PDF-' to prevent saving HTML/Captive portal pages
  static bool _isValidPdfSync(File file) {
    if (!file.existsSync() || file.lengthSync() < 5) return false;
    try {
      final fileAccess = file.openSync(mode: FileMode.read);
      final bytes = fileAccess.readSync(1024);
      fileAccess.closeSync();
      // Check for '%PDF-' (Hex: 25 50 44 46 2D)
      for (int i = 0; i <= bytes.length - 5; i++) {
        if (bytes[i] == 37 &&
            bytes[i + 1] == 80 &&
            bytes[i + 2] == 68 &&
            bytes[i + 3] == 70 &&
            bytes[i + 4] == 45) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Returns the local [File] for a cached PDF.
  /// Downloads if not already cached. Handles Google Drive warning links.
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

    // Return cached file if it exists and is valid
    if (file.existsSync() && file.lengthSync() > 0) {
      if (_isValidPdfSync(file)) return file;
      file.deleteSync();
    }

    // Download with generous timeout for large PDFs
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 45);

    try {
      final request = await client.getUrl(Uri.parse(downloadUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to download PDF: HTTP ${response.statusCode}',
        );
      }

      // Google Drive handles large files by showing an HTML virus scan warning.
      // E.g. contentType = "text/html; charset=utf-8"
      final contentType = response.headers.contentType?.mimeType ?? '';
      if (contentType == 'text/html') {
        final htmlContent = await utf8.decodeStream(response);
        // Look for the confirmation token the download button uses
        final confirmMatch = RegExp(
          r'confirm=([a-zA-Z0-9_\-]+)',
        ).firstMatch(htmlContent);
        if (confirmMatch != null) {
          final confirmToken = confirmMatch.group(1);
          final newUrl = '$downloadUrl&confirm=$confirmToken';
          client.close();
          // Retry gracefully with the acquired confirm token
          return getCachedPdf(
            bookId: bookId,
            downloadUrl: newUrl,
            onProgress: onProgress,
          );
        } else {
          throw HttpException(
            'Encountered an HTML block page instead of PDF (e.g., captive portal or rate limit).',
          );
        }
      }

      // If it's not HTML, stream the actual bytes to the file
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

      if (!_isValidPdfSync(file)) {
        file.deleteSync();
        throw HttpException('The downloaded file is not a valid PDF document.');
      }

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

    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList
          .map((json) => Book.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If the cache is corrupted or from an older schema, clear it.
      await prefs.remove(_bookListKey);
      return [];
    }
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
