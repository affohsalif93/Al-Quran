import 'package:equatable/equatable.dart';
import 'package:quran/models/tafsir/tafsir.dart';

class TafsirState extends Equatable {
  final Map<String, List<Tafsir>> tafsirCache; // Cache by key: "bookName:surah:ayah"
  final Map<String, List<Tafsir>> surahTafsirCache; // Cache by key: "bookName:surah"
  final String? selectedBookName;
  final TafsirBook? selectedBook;
  final bool isLoading;
  final String? error;
  final int? currentSurah;
  final int? currentAyah;
  final List<Tafsir> currentTafsir;

  const TafsirState({
    this.tafsirCache = const {},
    this.surahTafsirCache = const {},
    this.selectedBookName,
    this.selectedBook,
    this.isLoading = false,
    this.error,
    this.currentSurah,
    this.currentAyah,
    this.currentTafsir = const [],
  });

  factory TafsirState.initial() {
    return const TafsirState();
  }

  TafsirState copyWith({
    Map<String, List<Tafsir>>? tafsirCache,
    Map<String, List<Tafsir>>? surahTafsirCache,
    String? selectedBookName,
    TafsirBook? selectedBook,
    bool? isLoading,
    String? error,
    int? currentSurah,
    int? currentAyah,
    List<Tafsir>? currentTafsir,
  }) {
    return TafsirState(
      tafsirCache: tafsirCache ?? this.tafsirCache,
      surahTafsirCache: surahTafsirCache ?? this.surahTafsirCache,
      selectedBookName: selectedBookName ?? this.selectedBookName,
      selectedBook: selectedBook ?? this.selectedBook,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyah: currentAyah ?? this.currentAyah,
      currentTafsir: currentTafsir ?? this.currentTafsir,
    );
  }

  // Get cache key for ayah tafsir
  String _getAyahCacheKey(String bookName, int surah, int ayah) {
    return '$bookName:$surah:$ayah';
  }

  // Get cache key for surah tafsir
  String _getSurahCacheKey(String bookName, int surah) {
    return '$bookName:$surah';
  }

  // Get cached tafsir for ayah
  List<Tafsir>? getCachedTafsirForAyah(String bookName, int surah, int ayah) {
    final key = _getAyahCacheKey(bookName, surah, ayah);
    return tafsirCache[key];
  }

  // Get cached tafsir for surah
  List<Tafsir>? getCachedTafsirForSurah(String bookName, int surah) {
    final key = _getSurahCacheKey(bookName, surah);
    return surahTafsirCache[key];
  }

  // Check if ayah tafsir is cached
  bool isAyahTafsirCached(String bookName, int surah, int ayah) {
    final key = _getAyahCacheKey(bookName, surah, ayah);
    return tafsirCache.containsKey(key);
  }

  // Check if surah tafsir is cached
  bool isSurahTafsirCached(String bookName, int surah) {
    final key = _getSurahCacheKey(bookName, surah);
    return surahTafsirCache.containsKey(key);
  }

  // Add tafsir to cache
  TafsirState withCachedTafsirForAyah(String bookName, int surah, int ayah, List<Tafsir> tafsir) {
    final key = _getAyahCacheKey(bookName, surah, ayah);
    final updatedCache = Map<String, List<Tafsir>>.from(tafsirCache);
    updatedCache[key] = tafsir;
    return copyWith(tafsirCache: updatedCache);
  }

  // Add surah tafsir to cache
  TafsirState withCachedTafsirForSurah(String bookName, int surah, List<Tafsir> tafsir) {
    final key = _getSurahCacheKey(bookName, surah);
    final updatedCache = Map<String, List<Tafsir>>.from(surahTafsirCache);
    updatedCache[key] = tafsir;
    return copyWith(surahTafsirCache: updatedCache);
  }

  // Clear cache
  TafsirState withClearedCache() {
    return copyWith(
      tafsirCache: {},
      surahTafsirCache: {},
    );
  }

  // Check if current selection matches
  bool isCurrentSelection(int surah, int ayah) {
    return currentSurah == surah && currentAyah == ayah;
  }

  @override
  List<Object?> get props => [
    tafsirCache,
    surahTafsirCache,
    selectedBookName,
    selectedBook,
    isLoading,
    error,
    currentSurah,
    currentAyah,
    currentTafsir,
  ];
}