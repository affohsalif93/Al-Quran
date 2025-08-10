import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/ayah.dart';
import 'package:quran/models/surah.dart';
import 'package:quran/models/tafsir/tafsir.dart';
import 'package:quran/providers/tafsir/tafsir_state.dart';
import 'package:quran/repositories/quran_data.dart';
import 'package:quran/repositories/tafsir_repository.dart';

final tafsirProvider = StateNotifierProvider<TafsirController, TafsirState>((ref) {
  return TafsirController();
});

class TafsirController extends StateNotifier<TafsirState> {
  TafsirController() : super(TafsirState.initial()) {
    _initializeWithDefaultBook();
  }

  // Initialize with default tafsir book
  void _initializeWithDefaultBook() {
    final availableBooks = TafsirRepository.getAvailableBooks();
    if (availableBooks.isNotEmpty) {
      setSelectedBook(availableBooks.first.name);
    }
  }

  // Set selected tafsir book
  void setSelectedBook(String bookName) {
    final book = TafsirRepository.getTafsirBook(bookName);
    if (book != null) {
      state = state.copyWith(selectedBookName: bookName, selectedBook: book, error: null);
      logger.info('Selected tafsir book: $bookName');
    } else {
      state = state.copyWith(error: 'Tafsir book not found: $bookName');
    }
  }

  // Get tafsir for a specific ayah
  Future<void> loadTafsirForAyah(int surah, int ayah) async {
    if (state.selectedBookName == null) {
      state = state.copyWith(error: 'No tafsir book selected');
      return;
    }

    // Check cache first
    final cached = state.getCachedTafsirForAyah(state.selectedBookName!, surah, ayah);
    if (cached != null && state.isCurrentSelection(surah, ayah)) {
      state = state.copyWith(
        currentSelectedTafsir: cached,
        currentSurah: surah,
        currentAyah: ayah,
        error: null,
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);
      Tafsir? selectedTafsir;

      selectedTafsir = await TafsirRepository.getTafsirForAyah(
        state.selectedBookName!,
        surah,
        ayah,
      );

      if (selectedTafsir != null && selectedTafsir.text.trim().isNotEmpty) {
        logger.info('Found range tafsir covering $surah:$ayah: ${selectedTafsir.groupAyahKey}');
      } else if (selectedTafsir != null && selectedTafsir.text.trim().isEmpty) {
        // Range tafsir found but text is empty, treat as no tafsir found
        selectedTafsir = null;
        logger.info('Range tafsir found for $surah:$ayah but text is empty');
      }

      // Update cache and current state
      state = state
          .withCachedTafsirForAyah(state.selectedBookName!, surah, ayah, selectedTafsir)
          .copyWith(
            currentSelectedTafsir: selectedTafsir,
            currentSurah: surah,
            currentAyah: ayah,
            isLoading: false,
          );

      if (selectedTafsir != null) {
        logger.info('Loaded tafsir for ayah $surah:$ayah');
      } else {
        logger.warning('No tafsir found for ayah $surah:$ayah');
      }
    } catch (e, st) {
      logger.error('Failed to load tafsir for ayah $surah:$ayah: $e\n$st');
      state = state.copyWith(isLoading: false, error: 'Failed to load tafsir: $e');
    }
  }

  // Find previous ayah with tafsir content
  Future<Tafsir?> findNextTafsirRange() async {
    if (state.selectedBookName == null || state.currentSelectedTafsir == null) return null;

    int searchSurah = state.currentSelectedTafsir!.surah;
    int searchAyah = state.currentSelectedTafsir!.toAyah + 1;

    Ayah? ayah = _findNextValidAyah(searchSurah, searchAyah);

    if (ayah == null) {
      logger.debug("No valid surah found for next tafsir search");
      return null;
    }

    try {
      final tafsir = await TafsirRepository.getTafsirForAyah(
        state.selectedBookName!,
        ayah.surah,
        ayah.ayah,
      );

      if (tafsir != null) {
        state = state.copyWith(currentSelectedTafsir: tafsir);
        return tafsir;
      }

      return null;
    } catch (e, st) {
      logger.error('Failed to find previous ayah with tafsir:$e\n$st');
      return null;
    }
  }

  // Find previous ayah with tafsir content
  Future<Tafsir?> findPreviousTafsirRange() async {
    if (state.selectedBookName == null || state.currentSelectedTafsir == null) return null;

    int searchSurah = state.currentSelectedTafsir!.surah;
    int searchAyah = state.currentSelectedTafsir!.fromAyah - 1;

    if (searchAyah == 0) {
      logger.debug("Ayah greater than number of ayahs in surah");
      return null;
    }

    try {
      final tafsir = await TafsirRepository.getTafsirForAyah(
        state.selectedBookName!,
        searchSurah,
        searchAyah,
      );

      if (tafsir != null) {
        state = state.copyWith(currentSelectedTafsir: tafsir);
        return tafsir;
      }

      return null;
    } catch (e, st) {
      logger.error('Failed to find previous ayah with tafsir:$e\n$st');
      return null;
    }
  }

  // Find next valid ayah starting from given surah and ayah
  Ayah? _findNextValidAyah(int startSurah, int startAyah) {
    try {
      // If the starting ayah is valid within the current surah, return that ayah
      final currentSurah = QuranData.surahs.firstWhere((s) => s.surahNumber == startSurah);
      if (startAyah <= currentSurah.numberOfAyahs) {
        final ayahKey = '$startSurah:$startAyah';
        return QuranData.ayahMap[ayahKey];
      }
    } catch (e) {
      // Current surah not found, continue to search next surahs
    }
    
    // If startAyah exceeds the current surah, move to next surah
    for (int surahNumber = startSurah + 1; surahNumber <= 114; surahNumber++) {
      try {
        final surah = QuranData.surahs.firstWhere((s) => s.surahNumber == surahNumber);
        // Return first ayah of the next surah
        final ayahKey = '$surahNumber:1';
        return QuranData.ayahMap[ayahKey];
      } catch (e) {
        // Surah not found, continue to next
        continue;
      }
    }
    
    // No valid ayah found
    return null;
  }

  // Find next valid surah starting from given surah and ayah
  Surah? _findNextValidSurah(int startSurah, int startAyah) {
    try {
      // If the starting ayah is valid within the current surah, return that surah
      final currentSurah = QuranData.surahs.firstWhere((s) => s.surahNumber == startSurah);
      if (startAyah <= currentSurah.numberOfAyahs) {
        return currentSurah;
      }
    } catch (e) {
      // Current surah not found, continue to search next surahs
    }
    
    // If startAyah exceeds the current surah, move to next surah
    for (int surahNumber = startSurah + 1; surahNumber <= 114; surahNumber++) {
      try {
        final surah = QuranData.surahs.firstWhere((s) => s.surahNumber == surahNumber);
        return surah;
      } catch (e) {
        // Surah not found, continue to next
        continue;
      }
    }
    
    // No valid surah found
    return null;
  }

  // Clear current selection
  void clearCurrentSelection() {
    state = state.copyWith(
      currentSelectedTafsir: null,
      currentSurah: null,
      currentAyah: null,
      error: null,
    );
  }

  // Clear cache
  void clearCache() {
    state = state.withClearedCache();
    logger.info('Tafsir cache cleared');
  }

  // Get available books
  List<TafsirBook> get availableBooks => TafsirRepository.getAvailableBooks();

  // Check if database is available for current book
  Future<bool> isCurrentBookAvailable() async {
    if (state.selectedBookName == null) return false;
    return await TafsirRepository.isDatabaseAvailable(state.selectedBookName!);
  }

  // Refresh current selection
  Future<void> refreshCurrentSelection() async {
    if (state.currentSurah != null && state.currentAyah != null) {
      // Clear cache for this ayah and reload
      final key = '${state.selectedBookName}:${state.currentSurah}:${state.currentAyah}';
      final updatedCache = Map<String, Tafsir>.from(state.tafsirCache);
      updatedCache.remove(key);
      state = state.copyWith(tafsirCache: updatedCache);

      await loadTafsirForAyah(state.currentSurah!, state.currentAyah!);
    }
  }

  @override
  void dispose() {
    // Close all database connections when provider is disposed
    TafsirRepository.closeAllDatabases();
    super.dispose();
  }
}
