import "package:quran/core/utils/io.dart";
import "package:quran/core/utils/logger.dart";
import "package:sqflite/sqflite.dart";
import "dart:io";

// dbs enums
enum QuranDB {
  ayah,
  wordText,
  wordGlyph,
  pageLines,
}

const Map<QuranDB, String> quranDbFileNames = {
  QuranDB.ayah: "qpc-hafs.db",
  QuranDB.wordText: "qpc-hafs-word-by-word.db",
  QuranDB.wordGlyph: "qpc-v1-glyph-codes-wbw.db",
  QuranDB.pageLines: "qpc-15-lines.db",
};

class QuranDBService {
  static final Map<String, Database> _databases = {};

  static String _getDbPath(String fileName) =>
      IO.joinFromSupportFolder("data", "dbs", fileName);

  static Future<Database> _openDbFromFile(String fileName) async {
    if (_databases.containsKey(fileName)) {
      return _databases[fileName]!;
    }
    final dbPath = _getDbPath(fileName);
    final file = File(dbPath);

    try {
      if (!await file.exists()) {
        logger.error("missing db $fileName at $dbPath");
      }
      final db = await openDatabase(dbPath, readOnly: true);
      _databases[fileName] = db;
    } catch (e) {
      logger.error("Failed to open database $dbPath");
      rethrow;
    }

    // return db;
    return _databases[fileName]!;
  }

  static Future<Database> getAyahDb() =>
      _openDbFromFile(quranDbFileNames[QuranDB.ayah]!);

  static Future<Database> getWordTextDb() =>
      _openDbFromFile(quranDbFileNames[QuranDB.wordText]!);

  static Future<Database> getWordGlyphDb() =>
      _openDbFromFile(quranDbFileNames[QuranDB.wordGlyph]!);

  static Future<Database> getPageLinesDb() =>
      _openDbFromFile(quranDbFileNames[QuranDB.pageLines]!);

  static Future<Database> getTasfirDb() =>
      _openDbFromFile(quranDbFileNames[QuranDB.wordText]!);

  static Future<void> closeAllDatabases() async {
    for (final db in _databases.values) {
      await db.close();
    }
    _databases.clear();
  }
}
