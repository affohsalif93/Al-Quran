import 'dart:math';

import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/highlight/saved_highlight.dart';
import 'package:quran/models/quran/ayah_line.dart';
import 'package:quran/models/quran/basmallah_line.dart';
import 'package:quran/models/quran/page_data.dart';
import 'package:quran/models/quran/surah_name_line.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/services/quran_db_service.dart';
import 'package:riverpod/riverpod.dart';

import 'package:quran/models/quran/ayah.dart';
import 'package:quran/models/quran/page_line.dart';
import 'package:quran/repositories/quran/quran_data.dart';
import 'package:quran/repositories/highlights/highlights_repository.dart';
import 'package:sqflite/sqflite.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});

class QuranRepository {
  Database get ayahDb => QuranDBService.getAyahDb();
  Database get wordDb => QuranDBService.getWordGlyphDb();
  Database get linesDb => QuranDBService.getPageLinesDb();
  // Database get tafsirDb => QuranDBService.getTasfirDb();

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

  Future<List<Word>> _getWordsInRange(int firstWordId, int lastWordId) async {
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
        glyph: row['glyph'],
        text: row['word_text'],
        isAyahNrSymbol: (row['is_ayah_number'] as int) == 1,
      );
    }).toList();
  }


  Future<List<Word>> getWordsForPage(int pageNumber) async {
    try {
      final List<Map<String, dynamic>> lineRows = await linesDb.query(
        'pages',
        where: 'page_number = ?',
        whereArgs: [pageNumber],
        orderBy: 'line_number ASC',
      );

      final wordIdRanges = lineRows
          .where((row) => row['line_type'] == 'ayah')
          .map((row) => (row['first_word_id'] as int, row['last_word_id'] as int))
          .toList();

      final allWordIds = wordIdRanges.expand((pair) => [pair.$1, pair.$2]).toList();
      final minWordId = allWordIds.reduce(min);
      final maxWordId = allWordIds.reduce(max);

      final List<Map<String, dynamic>> wordRows = await wordDb.query(
        'words',
        where: 'id BETWEEN ? AND ?',
        whereArgs: [minWordId, maxWordId],
        orderBy: 'id ASC',
      );

      final words = wordRows.map((row) =>
        Word(
          id: row['id'] as int,
          location: row['location'],
          surah: row['surah'] as int,
          ayah: row['ayah'] as int,
          glyph: row['glyph'],
          text: row['word_text'],
          isAyahNrSymbol: (row['is_ayah_number'] as int) == 1,
        )).toList();

      return words;
    } catch (e, st) {
      logger.fine('Error loading words for page $pageNumber: $e');
      logger.fine(st);
      rethrow;
    }
  }

  Future<QuranPageData> getPageData(int pageNumber) async {
    try {
      final pageWords = await getWordsForPage(pageNumber);

      final Map<(int, int), List<Word>> ayahGroups = {};
      for (final word in pageWords) {
        final key = (word.surah, word.ayah);
        ayahGroups.putIfAbsent(key, () => []).add(word);
      }

      final List<Map<String, dynamic>> lineRows = await linesDb.query(
        'pages',
        where: 'page_number = ?',
        whereArgs: [pageNumber],
        orderBy: 'line_number ASC',
      );

      final Map<int, PageLine> lines = {};

      for (final row in lineRows) {
        final String typeStr = row['line_type'] as String;
        final LineType lineType = PageLine.parseLineType(typeStr);

        final int lineNumber = row['line_number'] as int;
        final int page = row['page_number'] as int;
        final bool isCentered = (row['is_centered'] as int) == 1;

        if (lineType == LineType.ayah) {
          final int firstWordId = row['first_word_id'] as int;
          final int lastWordId = row['last_word_id'] as int;

          final List<Word> words = pageWords.where((w) =>
          w.id >= firstWordId && w.id <= lastWordId).toList();

          final int surah = words.first.surah;

          lines[lineNumber] = AyahLine(
            pageNumber: page,
            lineNumber: lineNumber,
            surahNumber: surah,
            isCentered: isCentered,
            firstWordId: firstWordId,
            lastWordId: lastWordId,
            words: words,
          );

        } else if (lineType == LineType.basmallah) {
          final basmallahWords = await _getWordsInRange(1, 4);

          lines[lineNumber] = BasmallahLine(
            pageNumber: page,
            lineNumber: lineNumber,
            isCentered: isCentered,
            surahNumber: -1,
            words: basmallahWords,
          );

        } else if (lineType == LineType.surahName) {
          final int surahNumber = row['surah_number'] as int;

          lines[lineNumber] = SurahNameLine(
            pageNumber: page,
            lineNumber: lineNumber,
            isCentered: isCentered,
            surahNumber: surahNumber,
          );
        }
      }

      // Get ayahs for this page from static data
      final List<Ayah> pageAyahs = QuranData.pageAyahMap[pageNumber] ?? [];

      // Preload highlights for this page (fire-and-forget)
      _preloadHighlightsForPage(pageNumber);

      return QuranPageData(
        pageNumber: pageNumber,
        lines: lines,
        words: pageWords,
        ayahToWordsMap: ayahGroups,
        ayahs: pageAyahs,
      );
    } catch (e, st) {
      logger.fine('Error loading page data: $e');
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
        glyph: row['glyph'],
        text: row['word_text'],
        isAyahNrSymbol: (row['is_ayah_number'] as int) == 1,
      );
    }).toList();
  }

  // Preload highlights for a page (fire-and-forget)
  void _preloadHighlightsForPage(int pageNumber) {
    // This runs asynchronously and doesn't block page loading
    HighlightsRepository.getHighlightsForPage(pageNumber).catchError((e) {
      logger.fine('Failed to preload highlights for page $pageNumber: $e');
      return <SavedHighlight>[];
    });
  }
}
