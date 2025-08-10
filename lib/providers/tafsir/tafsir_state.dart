import 'package:equatable/equatable.dart';
import 'package:quran/models/tafsir/tafsir.dart';

class TafsirState extends Equatable {
  final Map<String, Tafsir> tafsirCache; // Cache by key: "bookName:surah:ayah"
  final String? selectedBookName;
  final TafsirBook? selectedBook;
  final bool isLoading;
  final String? error;
  final int? currentSurah;
  final int? currentAyah;
  final Tafsir? currentSelectedTafsir;

  const TafsirState({
    this.tafsirCache = const {},
    this.selectedBookName,
    this.selectedBook,
    this.isLoading = false,
    this.error,
    this.currentSurah,
    this.currentAyah,
    this.currentSelectedTafsir,
  });

  factory TafsirState.initial() {
    return const TafsirState();
  }

  TafsirState copyWith({
    Map<String, Tafsir>? tafsirCache,
    String? selectedBookName,
    TafsirBook? selectedBook,
    bool? isLoading,
    String? error,
    int? currentSurah,
    int? currentAyah,
    Tafsir? currentSelectedTafsir,
  }) {
    return TafsirState(
      tafsirCache: tafsirCache ?? this.tafsirCache,
      selectedBookName: selectedBookName ?? this.selectedBookName,
      selectedBook: selectedBook ?? this.selectedBook,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyah: currentAyah ?? this.currentAyah,
      currentSelectedTafsir: currentSelectedTafsir ?? this.currentSelectedTafsir,
    );
  }

  // Get cache key for ayah tafsir
  String _getAyahCacheKey(String bookName, int surah, int ayah) {
    return '$bookName:$surah:$ayah';
  }

  // Get cached tafsir for ayah
  Tafsir? getCachedTafsirForAyah(String bookName, int surah, int ayah) {
    final key = _getAyahCacheKey(bookName, surah, ayah);
    return tafsirCache[key];
  }

  // Check if ayah tafsir is cached
  bool isAyahTafsirCached(String bookName, int surah, int ayah) {
    final key = _getAyahCacheKey(bookName, surah, ayah);
    return tafsirCache.containsKey(key);
  }

  // Add tafsir to cache
  TafsirState withCachedTafsirForAyah(String bookName, int surah, int ayah, Tafsir? tafsir) {
    final key = _getAyahCacheKey(bookName, surah, ayah);
    final updatedCache = Map<String, Tafsir>.from(tafsirCache);
    if (tafsir != null) {
      updatedCache[key] = tafsir;
    } else {
      updatedCache.remove(key);
    }
    return copyWith(tafsirCache: updatedCache);
  }

  // Clear cache
  TafsirState withClearedCache() {
    return copyWith(tafsirCache: {});
  }

  // Check if current selection matches
  bool isCurrentSelection(int surah, int ayah) {
    return currentSurah == surah && currentAyah == ayah;
  }

  @override
  List<Object?> get props => [
    tafsirCache,
    selectedBookName,
    selectedBook,
    isLoading,
    error,
    currentSurah,
    currentAyah,
    currentSelectedTafsir,
  ];
}