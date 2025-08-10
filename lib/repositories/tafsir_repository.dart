import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:quran/core/utils/io.dart';
import 'package:sqflite/sqflite.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/tafsir/tafsir.dart';

class TafsirRepository {
  static final Map<String, Database> _databases = {};
  
  // Available tafsir books
  static const List<TafsirBook> availableBooks = [
    TafsirBook(
      name: 'tadabbur-wa-amal',
      dbFileName: 'tadabbur-wa-amal.db', 
      displayName: 'تدبر وعمل',
      author: 'مركز تدبر',
      description: 'تفسير تدبري عملي للقرآن الكريم',
      lang: 'ar',
    ),
    TafsirBook(
      name: 'abu-bakr-jabir-al-jazairi',
      dbFileName: 'abu-bakr-jabir-al-jazairi.db',
      displayName: 'أيسر التفاسير',
      author: 'أبو بكر جابر الجزائري',
      description: 'تفسير مبسط وميسر للقرآن الكريم',
      lang: 'ar',
    ),
  ];

  // Get database for a specific tafsir book
  static Future<Database> _getDatabase(String bookName) async {
    if (_databases.containsKey(bookName)) {
      return _databases[bookName]!;
    }

    try {
      final tafsirBook = availableBooks.firstWhere(
        (book) => book.name == bookName,
        orElse: () => throw Exception('Tafsir book not found: $bookName'),
      );
      
      final path = IO.fromDbsFolder('tafsir', tafsirBook.dbFileName);
      
      final database = await openDatabase(
        path,
        readOnly: true,
      );
      
      _databases[bookName] = database;
      logger.info('Opened tafsir database: $bookName');
      
      return database;
    } catch (e, st) {
      logger.error('Failed to open tafsir database $bookName: $e\n$st');
      rethrow;
    }
  }

  // Find tafsir range entry that covers a specific ayah
  static Future<Tafsir?> getTafsirForAyah(String bookName, int surah, int ayah) async {
    try {
      final db = await _getDatabase(bookName);
      final ayahKey = '$surah:$ayah';
      
      logger.info('Looking for range entry covering ayah $ayahKey');
      
      // Get all range entries for this surah that might cover this ayah
      final results = await db.query(
        'tafsir',
        where: 'ayah_keys LIKE ? AND ayah_keys LIKE ?',
        whereArgs: ['$surah:%', '%$ayahKey%'],
      );
      
      logger.info('Found ${results.length} potential range entries');
      
      // Check each result to see if it actually covers this ayah and has non-empty text
      for (final result in results) {
        final tafsir = Tafsir.fromMap(result);
        if (tafsir.coversAyah(surah, ayah) && tafsir.text.trim().isNotEmpty) {
          logger.info('Found covering range entry: ${tafsir.groupAyahKey} (${tafsir.fromAyah} to ${tafsir.toAyah})');
          return tafsir;
        }
      }
      
      logger.info('No range entry found covering ayah $ayahKey');
      return null;
    } catch (e, st) {
      logger.error('Failed to find range entry for ayah $surah:$ayah from $bookName: $e\n$st');
      return null;
    }
  }

  // Get previous range based on current range - finds range for the ayah before the first ayah in current range
  static Future<Tafsir?> getPreviousTafsirRange(String bookName, Tafsir currentRange) async {
    try {
      // Get the first ayah in the current range
      final (firstSurah, firstAyah) = currentRange.parsedFromAyah;
      
      // Calculate the previous ayah
      int previousSurah = firstSurah;
      int previousAyah = firstAyah - 1;
      
      // If ayah-1 < 1, we need to go to previous surah
      if (previousAyah < 1) {
        if (firstSurah > 1) {
          // Move to previous surah - we'll need to get the last ayah of that surah
          // For now, return null as we'd need QuranData to get surah info
          return null;
        } else {
          // Already at first surah, first ayah - no previous range
          return null;
        }
      }
      
      // Find the range entry that covers this previous ayah
      return await getTafsirForAyah(bookName, previousSurah, previousAyah);
    } catch (e, st) {
      logger.error('Failed to get previous range from current range: $e\n$st');
      return null;
    }
  }

  // Close database
  static Future<void> closeDatabase(String bookName) async {
    if (_databases.containsKey(bookName)) {
      await _databases[bookName]?.close();
      _databases.remove(bookName);
      logger.info('Closed tafsir database: $bookName');
    }
  }

  // Close all databases
  static Future<void> closeAllDatabases() async {
    for (final entry in _databases.entries) {
      await entry.value.close();
    }
    _databases.clear();
    logger.info('Closed all tafsir databases');
  }

  // Check if database exists for a book
  static Future<bool> isDatabaseAvailable(String bookName) async {
    try {
      final dbPath = await getDatabasesPath();
      final tafsirBook = availableBooks.firstWhere(
        (book) => book.name == bookName,
        orElse: () => throw Exception('Tafsir book not found: $bookName'),
      );
      
      final path = join(dbPath, 'tafsir', tafsirBook.dbFileName);
      return await File(path).exists();
    } catch (e) {
      return false;
    }
  }

  // Get available tafsir books
  static List<TafsirBook> getAvailableBooks() {
    return availableBooks;
  }

  // Get tafsir book by name
  static TafsirBook? getTafsirBook(String bookName) {
    try {
      return availableBooks.firstWhere((book) => book.name == bookName);
    } catch (e) {
      return null;
    }
  }
}