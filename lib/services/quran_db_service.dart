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
    await addWordIsAyahNrColumn(getWordGlyphDb(), "words");
    await addWordIsAyahNrColumn(getWordTextDb(), "words");
  }

  static String _getDbPath(String fileName) => IO.joinFromSupportFolder("data", "dbs", fileName);

  static Future<void> addWordIsAyahNrColumn(Database db, String table) async {
    try {
      final List<Map<String, dynamic>> columns = await db.rawQuery("PRAGMA table_info($table)");
      if (columns.any((column) => column['name'] == 'is_ayah_number')) {
        logger.info("Column 'is_ayah_number' already exists in table '$table'.");
        return;
      }

      logger.info("Adding is_ayah_number column to table $table...");
      await db.execute("ALTER TABLE $table ADD COLUMN is_ayah_number INTEGER DEFAULT 0");
      logger.info("Column 'is_ayah_number' added to table '$table'.");

      // Fetch all distinct (surah, ayah) pairs
      final List<Map<String, dynamic>> verses = await db.rawQuery('''
        SELECT surah, ayah, MAX(id) as max_id
        FROM $table
        WHERE surah IS NOT NULL AND ayah IS NOT NULL
        GROUP BY surah, ayah
      ''');

      int updatedCount = 0;

      // Set is_ayah_number = 1 for the max_id word in each verse
      for (final verse in verses) {
        final int maxId = verse['max_id'] as int;
        await db.update(table, {'is_ayah_number': 1}, where: 'id = ?', whereArgs: [maxId]);
        updatedCount++;
      }

      logger.info("Done! Marked $updatedCount words as ayah number symbols.");
    } catch (e, st) {
      logger.error("Failed to add or populate is_ayah_number column: $e\n$st");
    }
  }

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
      final db = await openDatabase(dbPath, readOnly: false);
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
