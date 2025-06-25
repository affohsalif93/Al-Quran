import "package:quran/core/utils/io.dart";
import "package:quran/core/utils/logger.dart";
import "package:sqflite/sqflite.dart";
import "dart:io";

enum QuranDB { ayah, wordText, wordGlyph, pageLines }

const Map<QuranDB, String> quranDbFileNames = {
  QuranDB.ayah: "qpc-hafs.db",
  QuranDB.wordText: "qpc-hafs-word-by-word.db",
  QuranDB.wordGlyph: "qpc-v1-glyph-codes-wbw.db",
  QuranDB.pageLines: "qpc-15-lines.db",
};

class QuranDBService {
  static final Map<String, Database> _databases = {};

  static Future<void> init() async {
    for (final fileName in quranDbFileNames.values) {
      await _openDbFromFile(fileName);
    }
  }

  static String _getDbPath(String fileName) => IO.joinFromSupportFolder("data", "dbs", fileName);

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

    return _databases[fileName]!;
  }

  static Database getAyahDb() => _databases[quranDbFileNames[QuranDB.ayah]]!;

  static Database getWordTextDb() => _databases[quranDbFileNames[QuranDB.wordText]]!;

  static Database getWordGlyphDb() => _databases[quranDbFileNames[QuranDB.wordGlyph]]!;

  static Database getPageLinesDb() => _databases[quranDbFileNames[QuranDB.pageLines]]!;

  static Database getTasfirDb() => _databases[quranDbFileNames[QuranDB.ayah]]!;

  static Future<void> closeAllDatabases() async {
    for (final db in _databases.values) {
      await db.close();
    }
    _databases.clear();
  }
}
