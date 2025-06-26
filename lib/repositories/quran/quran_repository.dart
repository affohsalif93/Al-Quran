import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/ayah_line.dart';
import 'package:quran/models/quran/basmallah_line.dart';
import 'package:quran/models/quran/surah_name_ligature.dart';
import 'package:quran/models/quran/surah_name_line.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/services/quran_db_service.dart';
import 'package:riverpod/riverpod.dart';

import 'package:quran/models/ayah_model.dart';
import 'package:quran/models/quran/page_line.dart';
import 'package:sqflite/sqflite.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});

class QuranRepository {
  final Database ayahDb = QuranDBService.getAyahDb();
  final Database wordDb = QuranDBService.getWordGlyphDb();
  final Database linesDb = QuranDBService.getPageLinesDb();
  // final Database tafsirDb = QuranDBService.getTasfirDb();

  QuranRepository();

  Future<Ayah> getAyah(int surah, int verse) async {
    final List<Map<String, dynamic>> results = await ayahDb.query(
      'text',
      where: 'verse_key = ?',
      whereArgs: ["$surah:$verse"],
      limit: 1,
    );
    return Ayah.fromJson(results.first);
  }

  Future<List<Word>> _getWordsInRange(int pageNumber, int firstWordId, int lastWordId) async {
    final List<Map<String, dynamic>> results = await wordDb.query(
      'words',
      where: 'id BETWEEN ? AND ?',
      whereArgs: [firstWordId, lastWordId],
      orderBy: 'id ASC',
    );

    return results.map((row) {
      return Word(
        id: row['id'] as int,
        location: row['location'],
        surah: row['surah'] as int,
        ayah: row['ayah'] as int,
        glyphCode: row['text'],
        isAyahNrSymbol: (row['is_ayah_number'] as int) == 1,
      );
    }).toList();
  }

  Future<Map<int, PageLine>> getPageLines(int pageNumber) async {
    try {
      final List<Map<String, dynamic>> results = await linesDb.query(
        'pages',
        where: 'page_number = ?',
        whereArgs: [pageNumber],
        orderBy: 'line_number ASC',
      );

      final Map<int, PageLine> lines = {};

      for (final row in results) {
        final String typeStr = row['line_type'] as String;
        final LineType lineType = PageLine.parseLineType(typeStr);

        final int lineNumber = row['line_number'] as int;
        final int page = row['page_number'] as int;
        final bool isCentered = (row['is_centered'] as int) == 1;

        if (lineType == LineType.ayah) {
          final int firstWordId = row['first_word_id'] as int;
          final int lastWordId = row['last_word_id'] as int;

          final List<Word> words = await _getWordsInRange(
            page,
            firstWordId,
            lastWordId,
          );

          final int surah = words.first.surah;

          final line = AyahLine(
            pageNumber: page,
            lineNumber: lineNumber,
            surahNumber: surah,
            isCentered: isCentered,
            firstWordId: firstWordId,
            lastWordId: lastWordId,
            words: words,
          );

          lines[lineNumber] = line;

        } else if (lineType == LineType.basmallah) {

          final basmallahWords = await _getWordsInRange(page, 1, 4);

          final line = BasmallahLine(
            pageNumber: page,
            lineNumber: lineNumber,
            isCentered: isCentered,
            surahNumber: -1,
            words: basmallahWords,
          );

          lines[lineNumber] = line;

        } else if (lineType == LineType.surahName) {
          final int surahNumber = row['surah_number'] as int;

          final line = SurahNameLine(
            pageNumber: page,
            lineNumber: lineNumber,
            isCentered: isCentered,
            surahNumber: surahNumber,
          );

          lines[lineNumber] = line;
        }
      }

      return lines;
    } catch (e, st) {
      logger.fine('Error loading page lines: $e');
      logger.fine(st);
      rethrow;
    }
  }

  Future<List<Word>> getWordsInAyah(int surah, int verse) async {
    final List<Map<String, dynamic>> results = await wordDb.query(
      'words',
      where: 'surah = ? AND ayah = ?',
      whereArgs: [surah, verse],
      orderBy: 'id ASC',
    );

    return results.map((row) {
      return Word(
        id: row['id'] as int,
        location: row['location'],
        surah: row['surah'] as int,
        ayah: row['ayah'] as int,
        glyphCode: row['text'],
        isAyahNrSymbol: (row['is_ayah_number'] as int) == 1,
      );
    }).toList();
  }
}
