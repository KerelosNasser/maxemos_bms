import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LexiconRepository {
  static final LexiconRepository _instance = LexiconRepository._internal();
  factory LexiconRepository() => _instance;
  LexiconRepository._internal();

  Database? _database;
  bool _isInitializing = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_isInitializing) {
      // Wait for initialization to finish if already in progress
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    _isInitializing = true;
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocDir.path, 'coptic_lexicon.db');
      final file = File(dbPath);

      // Always overwrite for now during development, to assure updates are caught.
      if (!file.existsSync() || true) {
        // Load database from asset
        try {
          ByteData data = await rootBundle.load('assets/db/coptic_lexicon.db');
          List<int> bytes = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );

          // Write the copied bytes to the local file
          await file.writeAsBytes(bytes, flush: true);
        } catch (e) {
          // If asset is totally missing (e.g. running emulator without copying DB yet)
          throw Exception(
            'Failed to load coptic_lexicon.db from assets. Make sure it exists.',
          );
        }
      }

      // Open the local local SQLite DB using sqflite
      final db = await openDatabase(dbPath);
      _isInitializing = false;
      return db;
    } catch (e) {
      _isInitializing = false;
      rethrow;
    }
  }

  /// Looks up a theological term identically via SQLite
  Future<Map<String, dynamic>?> getDefinition(String term) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        'terms',
        where: 'term LIKE ?',
        whereArgs: ['%${term.trim()}%'],
      );

      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
