import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/models/note.dart';
import 'package:quran/providers/notes/notes_controller.dart';
import 'package:quran/providers/notes/notes_state.dart';

// Main notes controller provider
final notesControllerProvider = StateNotifierProvider<NotesController, NotesState>((ref) {
  return NotesController(ref);
});

// Convenient providers for accessing notes data
final notesProvider = Provider<List<Note>>((ref) {
  return ref.watch(notesControllerProvider).notes;
});

final notesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(notesControllerProvider).isLoading;
});

final notesErrorProvider = Provider<String?>((ref) {
  return ref.watch(notesControllerProvider).error;
});

final hasNotesProvider = Provider<bool>((ref) {
  return ref.watch(notesControllerProvider).hasNotes;
});

final currentAyahHasNotesProvider = Provider<bool>((ref) {
  final state = ref.watch(notesControllerProvider);
  return state.hasNotes && state.currentSurah != null && state.currentAyah != null;
});

// Provider to get notes for a specific ayah (family provider)
final notesForAyahProvider = FutureProvider.family<List<Note>, String>((ref, ayahRef) async {
  final parts = ayahRef.split('_');
  if (parts.length != 2) return [];
  
  final surah = int.tryParse(parts[0]);
  final ayah = int.tryParse(parts[1]);
  
  if (surah == null || ayah == null) return [];
  
  final controller = ref.read(notesControllerProvider.notifier);
  await controller.loadNotesForAyah(surah, ayah);
  
  return ref.read(notesControllerProvider).notes;
});

// Provider for searching notes (family provider)
final searchNotesProvider = FutureProvider.family<List<Note>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  
  final controller = ref.read(notesControllerProvider.notifier);
  return await controller.searchNotes(query);
});

// Provider to get a specific note by ID (family provider)
final noteByIdProvider = FutureProvider.family<Note?, String>((ref, noteId) async {
  final controller = ref.read(notesControllerProvider.notifier);
  return await controller.getNoteById(noteId);
});

// Provider for total notes count
final notesCountProvider = FutureProvider<int>((ref) async {
  final controller = ref.read(notesControllerProvider.notifier);
  return await controller.getNotesCount();
});