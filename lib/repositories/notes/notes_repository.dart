import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:quran/core/utils/io.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/note_model.dart';

class NotesRepository {
  static Database? _database;
  static const String _dbName = 'user_data.db';
  static const String _tableName = 'ayah_notes';

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
        version: 1,
        onCreate: _createDatabase,
      );
      
      logger.info('Notes database initialized at: $dbPath');
    } catch (e, st) {
      logger.error('Failed to initialize notes database: $e\n$st');
      rethrow;
    }
  }

  // Create database tables
  static Future<void> _createDatabase(Database db, int version) async {
    try {
      // Create ayah_notes table
      await db.execute('''
        CREATE TABLE $_tableName (
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

      // Create indexes
      await db.execute('CREATE INDEX idx_ayah_notes_surah_ayah ON $_tableName(surah, ayah)');
      await db.execute('CREATE INDEX idx_ayah_notes_is_deleted ON $_tableName(is_deleted)');
      await db.execute('CREATE INDEX idx_ayah_notes_created_at ON $_tableName(created_at)');
      await db.execute('CREATE INDEX idx_ayah_notes_updated_at ON $_tableName(updated_at)');
      await db.execute('CREATE INDEX idx_ayah_notes_active ON $_tableName(is_deleted, surah, ayah)');

      logger.info('Notes database tables created successfully');
    } catch (e, st) {
      logger.error('Failed to create notes database tables: $e\n$st');
      rethrow;
    }
  }

  // Get database instance
  static Database get _db {
    if (_database == null) {
      throw Exception('Notes database not initialized. Call init() first.');
    }
    return _database!;
  }

  // Create a new note
  static Future<Note> createNote(Note note) async {
    try {
      await _db.insert(_tableName, note.toJson());
      logger.info('Note created with ID: ${note.id}');
      return note;
    } catch (e, st) {
      logger.error('Failed to create note: $e\n$st');
      rethrow;
    }
  }

  // Update an existing note
  static Future<Note> updateNote(Note note) async {
    try {
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      final count = await _db.update(
        _tableName,
        updatedNote.toJson(),
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [updatedNote.id],
      );
      
      if (count == 0) {
        throw Exception('Note not found or already deleted: ${note.id}');
      }
      
      logger.info('Note updated with ID: ${updatedNote.id}');
      return updatedNote;
    } catch (e, st) {
      logger.error('Failed to update note: $e\n$st');
      rethrow;
    }
  }

  // Soft delete a note
  static Future<void> deleteNote(String noteId) async {
    try {
      final count = await _db.update(
        _tableName,
        {
          'is_deleted': 1,
          'deleted_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [noteId],
      );
      
      if (count == 0) {
        throw Exception('Note not found or already deleted: $noteId');
      }
      
      logger.info('Note soft deleted with ID: $noteId');
    } catch (e, st) {
      logger.error('Failed to delete note: $e\n$st');
      rethrow;
    }
  }

  // Get a note by ID
  static Future<Note?> getNoteById(String noteId) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        _tableName,
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [noteId],
      );

      if (maps.isEmpty) return null;
      
      return Note.fromJson(maps.first);
    } catch (e, st) {
      logger.error('Failed to get note by ID: $e\n$st');
      rethrow;
    }
  }

  // Get all notes for a specific ayah
  static Future<List<Note>> getNotesForAyah(int surah, int ayah) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        _tableName,
        where: 'is_deleted = 0 AND surah = ? AND ayah = ?',
        whereArgs: [surah, ayah],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => Note.fromJson(map)).toList();
    } catch (e, st) {
      logger.error('Failed to get notes for ayah $surah:$ayah: $e\n$st');
      rethrow;
    }
  }

  // Get all notes (for debugging/admin purposes)
  static Future<List<Note>> getAllNotes({bool includeDeleted = false}) async {
    try {
      final String whereClause = includeDeleted ? '' : 'is_deleted = 0';
      
      final List<Map<String, dynamic>> maps = await _db.query(
        _tableName,
        where: whereClause.isEmpty ? null : whereClause,
        orderBy: 'updated_at DESC',
      );

      return maps.map((map) => Note.fromJson(map)).toList();
    } catch (e, st) {
      logger.error('Failed to get all notes: $e\n$st');
      rethrow;
    }
  }

  // Search notes by content
  static Future<List<Note>> searchNotes(String query) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        _tableName,
        where: 'is_deleted = 0 AND content LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'updated_at DESC',
      );

      return maps.map((map) => Note.fromJson(map)).toList();
    } catch (e, st) {
      logger.error('Failed to search notes: $e\n$st');
      rethrow;
    }
  }

  // Generate unique ID for notes
  static String generateNoteId(int surah, int ayah) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${surah}_${ayah}_$timestamp';
  }

  // Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      logger.info('Notes database closed');
    }
  }

  // Delete all notes (for testing/reset purposes)
  static Future<void> deleteAllNotes() async {
    try {
      await _db.delete(_tableName);
      logger.info('All notes deleted from database');
    } catch (e, st) {
      logger.error('Failed to delete all notes: $e\n$st');
      rethrow;
    }
  }

  // Get notes count
  static Future<int> getNotesCount({bool includeDeleted = false}) async {
    try {
      final String whereClause = includeDeleted ? '' : 'is_deleted = 0';
      
      final List<Map<String, dynamic>> result = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName ${whereClause.isEmpty ? '' : 'WHERE $whereClause'}',
      );
      
      return result.first['count'] as int;
    } catch (e, st) {
      logger.error('Failed to get notes count: $e\n$st');
      rethrow;
    }
  }
}