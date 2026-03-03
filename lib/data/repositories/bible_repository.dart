import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/utils/scriptural_regex_engine.dart';

class BibleRepository {
  static const String _dbName = 'bible_ar_vd.db';
  Database? _database;

  /// Initializes the SQLite offline connection.
  /// Copies the pristine Van Dyck Arabic Bible from bundled assets to the
  /// device's local filesystem on first run. Zero internet requests occur here.
  Future<void> initDatabase() async {
    if (_database != null) return;

    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _dbName);

      // Check if DB already exists on device
      final exists = await databaseExists(path);

      if (!exists) {
        if (kDebugMode) {
          print(
            'Bible DB not found locally. Copying from assets/db/$_dbName...',
          );
        }

        try {
          // Make sure the parent directory exists
          try {
            await Directory(dirname(path)).create(recursive: true);
          } catch (_) {}

          // Copy from pure assets bundle
          ByteData data = await rootBundle.load('assets/db/$_dbName');
          List<int> bytes = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );

          await File(path).writeAsBytes(bytes, flush: true);
        } catch (e) {
          throw Exception(
            'The Holy Bible database file is missing or corrupted within the app bundle: $e',
          );
        }
      }

      // Open the strictly read-only database
      _database = await openDatabase(path, readOnly: true);
    } catch (e) {
      if (kDebugMode) {
        print('CRITICAL: Failed to initialize offline Bible DB: $e');
      }
      rethrow;
    }
  }

  /// Queries the local deterministic SQLite database to retrieve exactly the
  /// verse text cited. No AI approximation is used.
  Future<String?> getVerseText(BibleReference ref) async {
    if (_database == null) {
      await initDatabase();
    }

    if (_database == null) return null;

    try {
      // Assuming a standardized schema:
      // table `verses` with columns: book_name, chapter, verse, text
      // We will adjust the query later once we have the exact db schema populated.
      final List<Map<String, dynamic>> maps = await _database!.query(
        'verses',
        columns: ['text'],
        where: 'book_name = ? AND chapter = ? AND verse = ?',
        whereArgs: [ref.bookName, ref.chapter, ref.verse],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return maps.first['text'] as String?;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error querying verse from offline SQLite: $e');
      }
      return null;
    }

    return null;
  }
}
