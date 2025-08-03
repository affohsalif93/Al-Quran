import 'package:equatable/equatable.dart';
import 'package:quran/models/note.dart';

class NotesState extends Equatable {
  final List<Note> notes;
  final bool isLoading;
  final String? error;
  final int? currentSurah;
  final int? currentAyah;

  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
    this.currentSurah,
    this.currentAyah,
  });

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? error,
    int? currentSurah,
    int? currentAyah,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyah: currentAyah ?? this.currentAyah,
    );
  }

  bool get hasNotes => notes.isNotEmpty;

  bool get hasError => error != null;

  @override
  List<Object?> get props => [
        notes,
        isLoading,
        error,
        currentSurah,
        currentAyah,
      ];

  @override
  bool get stringify => true;
}