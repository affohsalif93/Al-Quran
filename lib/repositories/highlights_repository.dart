import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:quran/core/utils/io.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/highlight/saved_highlight.dart';

class HighlightsRepository {
  static Database? _database;
  static const String _dbName = 'user_data.db';
  static const String _tableName = 'highlights';

  // Initialize the database
  static Future<void> init() async {
    if (_database != null) return;

    try {
      final dbPath = IO.fromDbsFolder(_dbName);
      
      // Ensure the directory exists
      final dbDir = Directory(dirname(dbPath));
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }

      _database = await openDatabase(
        dbPath,
        version: 2, // Increment version to trigger onUpgrade
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
      
      // Ensure highlights table exists after database initialization
      await _ensureHighlightsTableExists();
      
      logger.info('Highlights database initialized at: $dbPath');
    } catch (e, st) {
      logger.error('Failed to initialize highlights database: $e\n$st');
      rethrow;
    }
  }

  // Create database tables
  static Future<void> _createDatabase(Database db, int version) async {
    try {
      // Create ayah_notes table (for compatibility)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ayah_notes (
          id TEXT PRIMARY KEY,
          content TEXT NOT NULL,
          surah INTEGER NOT NULL,
          ayah INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_deleted INTEGER NOT NULL DEFAULT 0 CHECK (is_deleted IN (0, 1)),
          deleted_at TEXT
        )
      ''');

      // Create highlights table
      await _createHighlightsTable(db);
      
      logger.info('Database tables created successfully');
    } catch (e, st) {
      logger.error('Failed to create database tables: $e\n$st');
      rethrow;
    }
  }

  // Upgrade database
  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 2) {
        // Add highlights table in version 2
        await _createHighlightsTable(db);
        logger.info('Database upgraded from version $oldVersion to $newVersion');
      }
    } catch (e, st) {
      logger.error('Failed to upgrade database: $e\n$st');
      rethrow;
    }
  }

  // Create highlights table
  static Future<void> _createHighlightsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        page INTEGER NOT NULL,
        location TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        is_partial INTEGER NOT NULL DEFAULT 0 CHECK (is_partial IN (0, 1)),
        start_percentage REAL,
        end_percentage REAL,
        note TEXT
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX IF NOT EXISTS idx_highlights_page ON $_tableName(page)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_highlights_location ON $_tableName(location)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_highlights_page_location ON $_tableName(page, location)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_highlights_created_at ON $_tableName(created_at)');
    
    logger.info('Highlights table created successfully');
  }

  // Ensure highlights table exists (called after database initialization)
  static Future<void> _ensureHighlightsTableExists() async {
    if (_database == null) return;
    
    try {
      // Check if the table exists
      final result = await _database!.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$_tableName'"
      );
      
      if (result.isEmpty) {
        logger.info('Highlights table does not exist, creating it...');
        await _createHighlightsTable(_database!);
      } else {
        logger.info('Highlights table already exists');
      }
    } catch (e, st) {
      logger.error('Failed to ensure highlights table exists: $e\n$st');
      // Try to create the table anyway
      try {
        await _createHighlightsTable(_database!);
      } catch (createError, createSt) {
        logger.error('Failed to create highlights table: $createError\n$createSt');
        rethrow;
      }
    }
  }

  // Get database instance
  static Database get _db {
    if (_database == null) {
      throw Exception('Highlights database not initialized. Call init() first.');
    }
    return _database!;
  }

  // Create a new highlight
  static Future<SavedHighlight> createHighlight(SavedHighlight highlight) async {
    try {
      await _db.insert(_tableName, highlight.toJson());
      logger.info('Highlight created with ID: ${highlight.id}');
      return highlight;
    } catch (e, st) {
      logger.error('Failed to create highlight: $e\n$st');
      rethrow;
    }
  }

  // Update an existing highlight
  static Future<SavedHighlight> updateHighlight(SavedHighlight highlight) async {
    try {
      final updatedHighlight = highlight.copyWith(updatedAt: DateTime.now());
      final count = await _db.update(
        _tableName,
        updatedHighlight.toJson(),
        where: 'id = ?',
        whereArgs: [updatedHighlight.id],
      );
      
      if (count == 0) {
        throw Exception('Highlight not found: ${highlight.id}');
      }
      
      logger.info('Highlight updated with ID: ${updatedHighlight.id}');
      return updatedHighlight;
    } catch (e, st) {
      logger.error('Failed to update highlight: $e\n$st');
      rethrow;
    }
  }

  // Delete a highlight
  static Future<void> deleteHighlight(String highlightId) async {
    try {
      final count = await _db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [highlightId],
      );
      
      if (count == 0) {
        throw Exception('Highlight not found: $highlightId');
      }
      
      logger.info('Highlight deleted with ID: $highlightId');
    } catch (e, st) {
      logger.error('Failed to delete highlight: $e\n$st');
      rethrow;
    }
  }

  // Get a highlight by ID
  static Future<SavedHighlight?> getHighlightById(String highlightId) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [highlightId],
      );

      if (maps.isEmpty) return null;
      
      return SavedHighlight.fromJson(maps.first);
    } catch (e, st) {
      logger.error('Failed to get highlight by ID: $e\n$st');
      rethrow;
    }
  }

  // Get all highlights for a specific page
  static Future<List<SavedHighlight>> getHighlightsForPage(int page) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        _tableName,
        where: 'page = ?',
        whereArgs: [page],
        orderBy: 'created_at ASC',
      );

      return maps.map((map) => SavedHighlight.fromJson(map)).toList();
    } catch (e, st) {
      logger.error('Failed to get highlights for page $page: $e\n$st');
      rethrow;
    }
  }

  // Get all highlights for a specific location on a page
  static Future<List<SavedHighlight>> getHighlightsForLocation(int page, String location) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        _tableName,
        where: 'page = ? AND location = ?',
        whereArgs: [page, location],
        orderBy: 'created_at ASC',
      );

      return maps.map((map) => SavedHighlight.fromJson(map)).toList();
    } catch (e, st) {
      logger.error('Failed to get highlights for location $page:$location: $e\n$st');
      rethrow;
    }
  }

  // Get all highlights (for backup/export purposes)
  static Future<List<SavedHighlight>> getAllHighlights() async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        _tableName,
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => SavedHighlight.fromJson(map)).toList();
    } catch (e, st) {
      logger.error('Failed to get all highlights: $e\n$st');
      rethrow;
    }
  }

  // Get highlights for multiple pages (for range queries)
  static Future<List<SavedHighlight>> getHighlightsForPages(List<int> pages) async {
    if (pages.isEmpty) return [];
    
    try {
      final placeholders = pages.map((_) => '?').join(',');
      final List<Map<String, dynamic>> maps = await _db.query(
        _tableName,
        where: 'page IN ($placeholders)',
        whereArgs: pages,
        orderBy: 'page ASC, created_at ASC',
      );

      return maps.map((map) => SavedHighlight.fromJson(map)).toList();
    } catch (e, st) {
      logger.error('Failed to get highlights for pages ${pages.join(', ')}: $e\n$st');
      rethrow;
    }
  }

  // Delete all highlights for a specific page
  static Future<void> deleteHighlightsForPage(int page) async {
    try {
      final count = await _db.delete(
        _tableName,
        where: 'page = ?',
        whereArgs: [page],
      );
      
      logger.info('Deleted $count highlights for page $page');
    } catch (e, st) {
      logger.error('Failed to delete highlights for page $page: $e\n$st');
      rethrow;
    }
  }

  // Delete all highlights for a specific location
  static Future<void> deleteHighlightsForLocation(int page, String location) async {
    try {
      final count = await _db.delete(
        _tableName,
        where: 'page = ? AND location = ?',
        whereArgs: [page, location],
      );
      
      logger.info('Deleted $count highlights for location $page:$location');
    } catch (e, st) {
      logger.error('Failed to delete highlights for location $page:$location: $e\n$st');
      rethrow;
    }
  }

  // Get highlights count
  static Future<int> getHighlightsCount() async {
    try {
      final List<Map<String, dynamic>> result = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName',
      );
      
      return result.first['count'] as int;
    } catch (e, st) {
      logger.error('Failed to get highlights count: $e\n$st');
      rethrow;
    }
  }

  // Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      logger.info('Highlights database closed');
    }
  }

  // Delete all highlights (for testing/reset purposes)
  static Future<void> deleteAllHighlights() async {
    try {
      await _db.delete(_tableName);
      logger.info('All highlights deleted from database');
    } catch (e, st) {
      logger.error('Failed to delete all highlights: $e\n$st');
      rethrow;
    }
  }
}