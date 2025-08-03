import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/note.dart';
import 'package:quran/providers/notes/notes_state.dart';
import 'package:quran/repositories/notes/notes_repository.dart';

class NotesController extends StateNotifier<NotesState> {
  final Ref ref;

  NotesController(this.ref) : super(const NotesState()) {
    _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    try {
      await NotesRepository.init();
      logger.info('Notes repository initialized successfully');
    } catch (e, st) {
      logger.error('Failed to initialize notes repository: $e\n$st');
      state = state.copyWith(error: 'Failed to initialize notes: $e');
    }
  }

  // Load notes for a specific ayah
  Future<void> loadNotesForAyah(int surah, int ayah) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentSurah: surah,
      currentAyah: ayah,
    );

    try {
      final notes = await NotesRepository.getNotesForAyah(surah, ayah);

      state = state.copyWith(
        notes: notes,
        isLoading: false,
      );

      logger.info('Loaded ${notes.length} notes for ayah $surah:$ayah');
    } catch (e, st) {
      logger.error('Failed to load notes for ayah $surah:$ayah: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load notes: $e',
      );
    }
  }

  // Create a new note
  Future<Note?> createNote({
    required int surah,
    required int ayah,
    required String content,
  }) async {
    if (content.trim().isEmpty) {
      state = state.copyWith(error: 'Note content cannot be empty');
      return null;
    }

    try {
      final note = Note.create(
        surah: surah,
        ayah: ayah,
        content: content.trim(),
      );

      final createdNote = await NotesRepository.createNote(note);
      
      // Refresh notes for current ayah
      if (state.currentSurah == surah && state.currentAyah == ayah) {
        await loadNotesForAyah(surah, ayah);
      }

      logger.info('Created note: ${createdNote.id}');
      return createdNote;
    } catch (e, st) {
      logger.error('Failed to create note: $e\n$st');
      state = state.copyWith(error: 'Failed to create note: $e');
      return null;
    }
  }


  // Update an existing note
  Future<Note?> updateNote({
    required String noteId,
    required String content,
  }) async {
    if (content.trim().isEmpty) {
      state = state.copyWith(error: 'Note content cannot be empty');
      return null;
    }

    try {
      // Find the note in current state
      final noteToUpdate = state.notes.where((n) => n.id == noteId).firstOrNull;

      if (noteToUpdate == null) {
        state = state.copyWith(error: 'Note not found');
        return null;
      }

      final updatedNote = noteToUpdate.updateContent(content.trim());
      final savedNote = await NotesRepository.updateNote(updatedNote);
      
      // Refresh notes for current ayah
      if (state.currentSurah != null && state.currentAyah != null) {
        await loadNotesForAyah(state.currentSurah!, state.currentAyah!);
      }

      logger.info('Updated note: ${savedNote.id}');
      return savedNote;
    } catch (e, st) {
      logger.error('Failed to update note: $e\n$st');
      state = state.copyWith(error: 'Failed to update note: $e');
      return null;
    }
  }

  // Delete a note (soft delete)
  Future<bool> deleteNote(String noteId) async {
    try {
      await NotesRepository.deleteNote(noteId);
      
      // Refresh notes for current ayah
      if (state.currentSurah != null && state.currentAyah != null) {
        await loadNotesForAyah(state.currentSurah!, state.currentAyah!);
      }

      logger.info('Deleted note: $noteId');
      return true;
    } catch (e, st) {
      logger.error('Failed to delete note: $e\n$st');
      state = state.copyWith(error: 'Failed to delete note: $e');
      return false;
    }
  }

  // Search notes
  Future<List<Note>> searchNotes(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final results = await NotesRepository.searchNotes(query.trim());
      logger.info('Found ${results.length} notes for query: "$query"');
      return results;
    } catch (e, st) {
      logger.error('Failed to search notes: $e\n$st');
      state = state.copyWith(error: 'Failed to search notes: $e');
      return [];
    }
  }

  // Get a specific note by ID
  Future<Note?> getNoteById(String noteId) async {
    try {
      final note = await NotesRepository.getNoteById(noteId);
      logger.info('Retrieved note: $noteId');
      return note;
    } catch (e, st) {
      logger.error('Failed to get note by ID: $e\n$st');
      state = state.copyWith(error: 'Failed to get note: $e');
      return null;
    }
  }

  // Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear all notes from state (useful when navigating away)
  void clearNotes() {
    state = state.copyWith(
      notes: [],
      currentSurah: null,
      currentAyah: null,
      error: null,
    );
  }

  // Get notes count
  Future<int> getNotesCount() async {
    try {
      return await NotesRepository.getNotesCount();
    } catch (e, st) {
      logger.error('Failed to get notes count: $e\n$st');
      return 0;
    }
  }
}