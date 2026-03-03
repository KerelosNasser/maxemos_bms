import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Run and compile this via Dart:
// dart pub add http sqflite_common_ffi sqlite3_flutter_libs
// dart run tools/build_bible_db.dart

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;

  final dbFile = File('assets/db/bible_ar_vd.db');
  if (dbFile.existsSync()) {
    dbFile.deleteSync();
  }

  print('Creating SQLite database...');
  final db = await databaseFactory.openDatabase(dbFile.path);

  await db.execute('''
    CREATE TABLE verses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book TEXT,
      chapter INTEGER,
      verse INTEGER,
      text TEXT
    )
  ''');

  print('Downloading ar_svd.json...');
  final response = await http.get(
    Uri.parse(
      'https://raw.githubusercontent.com/thiagobodruk/bible/master/json/ar_svd.json',
    ),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    print('Inserting verses...');
    final batch = db.batch();

    for (var bookData in data) {
      final bookName = bookData['name'] as String;
      final chapters = bookData['chapters'] as List<dynamic>;

      for (int c = 0; c < chapters.length; c++) {
        final chapterNum = c + 1;
        final verses = chapters[c] as List<dynamic>;

        for (int v = 0; v < verses.length; v++) {
          final verseNum = v + 1;
          final verseText = verses[v] as String;

          batch.insert('verses', {
            'book': bookName,
            'chapter': chapterNum,
            'verse': verseNum,
            'text': verseText,
          });
        }
      }
    }

    await batch.commit(noResult: true);
    print('Database successfully created with ${data.length} books!');
  } else {
    print('Failed to download JSON! Status: \${response.statusCode}');
  }

  await db.close();
}
