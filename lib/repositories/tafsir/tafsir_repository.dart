import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/tafsir/tafsir.dart';

class TafsirRepository {
  static final Map<String, Database> _databases = {};
  
  // Available tafsir books
  static const List<TafsirBook> availableBooks = [
    TafsirBook(
      name: 'abu-bakr-jabir-al-jazairi',
      dbFileName: 'abu-bakr-jabir-al-jazairi.db',
      displayName: 'أيسر التفاسير',
      author: 'أبو بكر جابر الجزائري',
      description: 'تفسير مبسط وميسر للقرآن الكريم',
    ),
    TafsirBook(
      name: 'tadabbur-wa-amal',
      dbFileName: 'tadabbur-wa-amal.db', 
      displayName: 'تدبر وعمل',
      author: 'مركز تدبر',
      description: 'تفسير تدبري عملي للقرآن الكريم',
    ),
  ];

  // Get database for a specific tafsir book
  static Future<Database> _getDatabase(String bookName) async {
    if (_databases.containsKey(bookName)) {
      return _databases[bookName]!;
    }

    try {
      final dbPath = await getDatabasesPath();
      final tafsirBook = availableBooks.firstWhere(
        (book) => book.name == bookName,
        orElse: () => throw Exception('Tafsir book not found: $bookName'),
      );
      
      final path = join(dbPath, 'tafsir', tafsirBook.dbFileName);
      
      // Check if database file exists
      if (!await File(path).exists()) {
        // Copy from assets if not exists
        await _copyDatabaseFromAssets(tafsirBook.dbFileName, path);
      }

      final database = await openDatabase(
        path,
        version: 1,
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

  // Copy database from assets to app directory
  static Future<void> _copyDatabaseFromAssets(String dbFileName, String targetPath) async {
    try {
      // Create directories if they don't exist
      await Directory(dirname(targetPath)).create(recursive: true);
      
      // Copy from assets
      final data = await rootBundle.load('assets/databases/tafsir/$dbFileName');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(targetPath).writeAsBytes(bytes);
      
      logger.info('Copied tafsir database from assets: $dbFileName');
    } catch (e, st) {
      logger.error('Failed to copy tafsir database from assets: $e\n$st');
      rethrow;
    }
  }

  // Get tafsir for a specific ayah
  static Future<List<Tafsir>> getTafsirForAyah(String bookName, int surah, int ayah) async {
    try {
      final db = await _getDatabase(bookName);
      final ayahKey = '$surah:$ayah';
      
      // First try to get exact match
      List<Map<String, dynamic>> results = await db.query(
        'tafsir',
        where: 'ayah_key = ?',
        whereArgs: [ayahKey],
      );
      
      // If no exact match, look for range entries that cover this ayah
      if (results.isEmpty) {
        results = await db.query(
          'tafsir',
          where: 'ayah_keys LIKE ?',
          whereArgs: ['%$ayahKey%'],
        );
      }
      
      return results.map((map) => Tafsir.fromMap(map)).toList();
    } catch (e, st) {
      logger.error('Failed to get tafsir for ayah $surah:$ayah from $bookName: $e\n$st');
      return [];
    }
  }

  // Get tafsir for a range of ayahs  
  static Future<List<Tafsir>> getTafsirForAyahRange(String bookName, int surah, int fromAyah, int toAyah) async {
    try {
      final db = await _getDatabase(bookName);
      final List<Tafsir> allTafsir = [];
      
      // Get tafsir for each ayah in the range
      for (int ayah = fromAyah; ayah <= toAyah; ayah++) {
        final tafsirList = await getTafsirForAyah(bookName, surah, ayah);
        allTafsir.addAll(tafsirList);
      }
      
      // Remove duplicates based on group_ayah_key
      final Map<String, Tafsir> uniqueTafsir = {};
      for (final tafsir in allTafsir) {
        uniqueTafsir[tafsir.groupAyahKey] = tafsir;
      }
      
      return uniqueTafsir.values.toList();
    } catch (e, st) {
      logger.error('Failed to get tafsir for ayah range $surah:$fromAyah-$toAyah from $bookName: $e\n$st');
      return [];
    }
  }

  // Get tafsir for a complete surah
  static Future<List<Tafsir>> getTafsirForSurah(String bookName, int surah) async {
    try {
      final db = await _getDatabase(bookName);
      
      final results = await db.query(
        'tafsir',
        where: 'ayah_key LIKE ?',
        whereArgs: ['$surah:%'],
        orderBy: 'CAST(SUBSTR(ayah_key, INSTR(ayah_key, ":") + 1) AS INTEGER)',
      );
      
      return results.map((map) => Tafsir.fromMap(map)).toList();
    } catch (e, st) {
      logger.error('Failed to get tafsir for surah $surah from $bookName: $e\n$st');
      return [];
    }
  }

  // Search tafsir by text content
  static Future<List<Tafsir>> searchTafsir(String bookName, String searchQuery) async {
    try {
      if (searchQuery.trim().isEmpty) return [];
      
      final db = await _getDatabase(bookName);
      
      final results = await db.query(
        'tafsir',
        where: 'text LIKE ?',
        whereArgs: ['%$searchQuery%'],
        limit: 50, // Limit results for performance
      );
      
      return results.map((map) => Tafsir.fromMap(map)).toList();
    } catch (e, st) {
      logger.error('Failed to search tafsir in $bookName: $e\n$st');
      return [];
    }
  }

  // Get all unique group ayah keys (for getting range entries)
  static Future<List<String>> getGroupAyahKeys(String bookName, int surah) async {
    try {
      final db = await _getDatabase(bookName);
      
      final results = await db.query(
        'tafsir',
        columns: ['DISTINCT group_ayah_key'],
        where: 'group_ayah_key LIKE ?',
        whereArgs: ['$surah:%'],
        orderBy: 'CAST(SUBSTR(group_ayah_key, INSTR(group_ayah_key, ":") + 1) AS INTEGER)',
      );
      
      return results.map((map) => map['group_ayah_key'] as String).toList();
    } catch (e, st) {
      logger.error('Failed to get group ayah keys for surah $surah from $bookName: $e\n$st');
      return [];
    }
  }

  // Get tafsir by group ayah key (for range entries)
  static Future<Tafsir?> getTafsirByGroupAyahKey(String bookName, String groupAyahKey) async {
    try {
      final db = await _getDatabase(bookName);
      
      final results = await db.query(
        'tafsir',
        where: 'group_ayah_key = ?',
        whereArgs: [groupAyahKey],
        limit: 1,
      );
      
      if (results.isNotEmpty) {
        return Tafsir.fromMap(results.first);
      }
      
      return null;
    } catch (e, st) {
      logger.error('Failed to get tafsir by group ayah key $groupAyahKey from $bookName: $e\n$st');
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