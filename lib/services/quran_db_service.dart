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

    await addIsAyahNrColumn(db: getWordGlyphDb(), table: "words");
    await addWordTextColumnToGlyphDb(db: getWordGlyphDb(), table: "words");
  }

  static Future<void> addIsAyahNrColumn({required Database db, required String table}) async {
    try {
      final List<Map<String, dynamic>> columns = await db.rawQuery("PRAGMA table_info($table)");
      if (columns.any((column) => column['name'] == 'is_ayah_number')) {
        logger.info("Column 'is_ayah_number' already exists in table '$table'.");
        return;
      }

      logger.info("Adding is_ayah_number column to table $table...");
      await db.execute("ALTER TABLE $table ADD COLUMN is_ayah_number INTEGER DEFAULT 0");
      logger.info("Column 'is_ayah_number' added to table '$table'.");

      logger.info("Fetching ayah numbers...");
      final List<Map<String, dynamic>> verses = await db.rawQuery('''
        SELECT surah, ayah, MAX(id) as max_id
        FROM $table
        WHERE surah IS NOT NULL AND ayah IS NOT NULL
        GROUP BY surah, ayah
      ''');

      int updatedCount = 0;

      logger.info("Marking max_id words as ayah number symbols...");
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

  static Future<void> addWordTextColumnToGlyphDb({
    required Database db,
    required String table,
  }) async {
    try {
      await db.transaction((txn) async {
        // Check if columns already exist
        final List<Map<String, dynamic>> columns = await txn.rawQuery("PRAGMA table_info($table)");
        final hasWordText = columns.any((column) => column['name'] == 'word_text');
        final hasGlyph = columns.any((column) => column['name'] == 'glyph');
        final hasTextColumn = columns.any((column) => column['name'] == 'text');

        // Rename 'text' column to 'glyph' if it exists and 'glyph' doesn't exist
        if (hasTextColumn && !hasGlyph) {
          logger.info("Renaming 'text' column to 'glyph' in table $table...");
          await txn.execute("ALTER TABLE $table RENAME COLUMN text TO glyph");
          logger.info("Column 'text' renamed to 'glyph' in table '$table'.");
        } else if (hasGlyph) {
          logger.info("Column 'glyph' already exists in table '$table'.");
        }

        // Add word_text column if it doesn't exist
        if (!hasWordText) {
          logger.info("Adding word_text column to table $table...");
          await txn.execute("ALTER TABLE $table ADD COLUMN word_text TEXT");
          logger.info("Column 'word_text' added to table '$table'.");

          // Populate word_text from the wordText database
          final wordTextDb = getWordTextDb();
          logger.info("Fetching word_text from wordText database...");
          final words = await wordTextDb.query(table, columns: ['id', 'text']);
          final totalWords = words.length;

          logger.info("Populating word_text column in $table with $totalWords records...");

          // Prepare batch update statement
          final batch = txn.batch();
          int updatedCount = 0;
          int progressThreshold = (totalWords / 10).ceil(); // 10% increments

          for (final word in words) {
            final id = word['id'] as int;
            final text = word['text'] as String?;
            if (text != null) {
              batch.update(table, {'word_text': text}, where: 'id = ?', whereArgs: [id]);
              updatedCount++;

              // Log progress every 10%
              if (updatedCount % progressThreshold == 0 || updatedCount == totalWords) {
                final percentage = ((updatedCount / totalWords) * 100).round();
                logger.info("Progress: $percentage% ($updatedCount/$totalWords) - Updated word_text for record ID $id");
              }
            }
          }

          // Execute all updates in batch
          await batch.commit(noResult: true);
          logger.info("Done! Populated word_text column with $updatedCount records.");
        } else {
          logger.info("Column 'word_text' already exists in table '$table'.");
        }
      });
    } catch (e, st) {
      logger.error("Failed to add or populate columns: $e\n$st");
    }
  }

  static Future<Database> _openDbFromFile(String fileName) async {
    if (_databases.containsKey(fileName)) {
      return _databases[fileName]!;
    }
    final dbPath = IO.fromDbsFolder(fileName);
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
