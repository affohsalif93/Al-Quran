import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/ayah_line.dart';
import 'package:quran/models/quran/basmallah_line.dart';
import 'package:quran/models/quran/surah_name_ligature.dart';
import 'package:quran/models/quran/surah_name_line.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/services/quran_db_service.dart';
import 'package:riverpod/riverpod.dart';

import 'package:quran/models/verse_model.dart';
import 'package:quran/models/quran/line.dart';
import 'package:sqflite/sqflite.dart';

final quranRepositoryProvider = FutureProvider<QuranRepository>((ref) async {
  final repo = QuranRepository();
  await repo.init();
  return repo;
});

class QuranRepository {
  late final Database ayahDb;
  late final Database wordDb;
  late final Database linesDb;

  late final SurahLigatures surahLigatures;

  QuranRepository();

  Future<void> init() async {
    surahLigatures = await loadSurahLigatures();

    ayahDb = await QuranDBService.getAyahDb();
    wordDb = await QuranDBService.getWordGlyphDb();
    linesDb = await QuranDBService.getPageLinesDb();
  }

  Future<Verse> getVerse(int chapter, int verse) async {
    final List<Map<String, dynamic>> results = await ayahDb.query(
      'text',
      where: 'verse_key = ?',
      whereArgs: ["$chapter:$verse"],
      limit: 1,
    );
    return Verse.fromJson(results.first);
  }

  Future<List<Word>> getWordsInRange(int pageNumber, int firstWordId, int lastWordId) async {
    final List<Map<String, dynamic>> results = await wordDb.query(
      'words',
      where: 'id BETWEEN ? AND ?',
      whereArgs: [firstWordId, lastWordId],
      orderBy: 'id ASC',
    );

    return results.map((row) {
      return Word(
        id: row['id'] as int,
        location: row['word'] as int,
        surah: row['surah'] as int,
        ayah: row['ayah'] as int,
        glyphCode: row['text'],
      );
    }).toList();
  }

  Future<Map<int, Line>> getPageLines(int pageNumber) async {
    try {
      final List<Map<String, dynamic>> results = await linesDb.query(
        'pages',
        where: 'page_number = ?',
        whereArgs: [pageNumber],
        orderBy: 'line_number ASC',
      );

      final Map<int, Line> lines = {};

      for (final row in results) {
        final String typeStr = row['line_type'] as String;
        final LineType lineType = Line.parseLineType(typeStr);

        final int lineNumber = row['line_number'] as int;
        final int page = row['page_number'] as int;
        final bool isCentered = (row['is_centered'] as int) == 1;

        if (lineType == LineType.ayah) {
          final int firstWordId = row['first_word_id'] as int;
          final int lastWordId = row['last_word_id'] as int;

          final List<Word> words = await getWordsInRange(
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

          final basmallahWords = await getWordsInRange(page, 1, 4);

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

  // Future<List<TafsirModel>> getTafsir(int chapter, int verse) async {
  //   try {
  //     final tafsirData = await _dataSource.getTafsir(chapter, verse);
  //     return tafsirData;
  //   } catch (e, st) {
  //     logger.fine('error: $e');
  //     logger.fine(st);
  //     rethrow;
  //   }
  // }
  //
  // Future<Verse> getVerseFromIndex(int index) async {
  //   try {
  //     final (chapter, verse) = QuranUtils.indexToChapterVerse(index + 1);
  //     final verseData = await _dataSource.getVerse(chapter, verse);
  //     return Verse.fromJson(verseData);
  //   } catch (e, st) {
  //     logger.fine('error: $e');
  //     logger.fine(st);
  //     rethrow;
  //   }
  // }
  //
  // Future<List<TafsirModel>> getTafsirFromIndex(int index) async {
  //   try {
  //     final (chapter, verse) = QuranUtils.indexToChapterVerse(index + 1);
  //     final tafsirData = await _dataSource.getTafsir(chapter, verse);
  //     return tafsirData;
  //   } catch (e, st) {
  //     logger.fine('error55: $e');
  //     logger.fine(st);
  //     rethrow;
  //   }
  // }
}
