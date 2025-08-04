import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/tafsir/tafsir.dart';
import 'package:quran/providers/tafsir/tafsir_state.dart';
import 'package:quran/repositories/tafsir/tafsir_repository.dart';

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
      state = state.copyWith(
        selectedBookName: bookName,
        selectedBook: book,
        error: null,
      );
      logger.info('Selected tafsir book: $bookName');
    } else {
      state = state.copyWith(
        error: 'Tafsir book not found: $bookName',
      );
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
        currentTafsir: cached,
        currentSurah: surah,
        currentAyah: ayah,
        error: null,
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final tafsir = await TafsirRepository.getTafsirForAyah(
        state.selectedBookName!,
        surah,
        ayah,
      );

      // Update cache and current state
      state = state
          .withCachedTafsirForAyah(state.selectedBookName!, surah, ayah, tafsir)
          .copyWith(
            currentTafsir: tafsir,
            currentSurah: surah,
            currentAyah: ayah,
            isLoading: false,
          );

      logger.info('Loaded ${tafsir.length} tafsir entries for ayah $surah:$ayah');
    } catch (e, st) {
      logger.error('Failed to load tafsir for ayah $surah:$ayah: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tafsir: $e',
      );
    }
  }

  // Get tafsir for a range of ayahs
  Future<List<Tafsir>> getTafsirForAyahRange(int surah, int fromAyah, int toAyah) async {
    if (state.selectedBookName == null) {
      state = state.copyWith(error: 'No tafsir book selected');
      return [];
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final tafsir = await TafsirRepository.getTafsirForAyahRange(
        state.selectedBookName!,
        surah,
        fromAyah,
        toAyah,
      );

      state = state.copyWith(isLoading: false);
      logger.info('Loaded ${tafsir.length} tafsir entries for ayahs $surah:$fromAyah-$toAyah');
      
      return tafsir;
    } catch (e, st) {
      logger.error('Failed to load tafsir for ayah range $surah:$fromAyah-$toAyah: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tafsir: $e',
      );
      return [];
    }
  }

  // Get tafsir for complete surah
  Future<void> loadTafsirForSurah(int surah) async {
    if (state.selectedBookName == null) {
      state = state.copyWith(error: 'No tafsir book selected');
      return;
    }

    // Check cache first
    final cached = state.getCachedTafsirForSurah(state.selectedBookName!, surah);
    if (cached != null) {
      state = state.copyWith(
        currentTafsir: cached,
        currentSurah: surah,
        currentAyah: null,
        error: null,
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final tafsir = await TafsirRepository.getTafsirForSurah(
        state.selectedBookName!,
        surah,
      );

      // Update cache and current state
      state = state
          .withCachedTafsirForSurah(state.selectedBookName!, surah, tafsir)
          .copyWith(
            currentTafsir: tafsir,
            currentSurah: surah,
            currentAyah: null,
            isLoading: false,
          );

      logger.info('Loaded ${tafsir.length} tafsir entries for surah $surah');
    } catch (e, st) {
      logger.error('Failed to load tafsir for surah $surah: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tafsir: $e',
      );
    }
  }

  // Search tafsir by text
  Future<List<Tafsir>> searchTafsir(String query) async {
    if (state.selectedBookName == null) {
      state = state.copyWith(error: 'No tafsir book selected');
      return [];
    }

    if (query.trim().isEmpty) {
      return [];
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final results = await TafsirRepository.searchTafsir(
        state.selectedBookName!,
        query,
      );

      state = state.copyWith(isLoading: false);
      logger.info('Found ${results.length} tafsir entries for query: $query');
      
      return results;
    } catch (e, st) {
      logger.error('Failed to search tafsir: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to search tafsir: $e',
      );
      return [];
    }
  }

  // Get tafsir by group ayah key
  Future<Tafsir?> getTafsirByGroupAyahKey(String groupAyahKey) async {
    if (state.selectedBookName == null) {
      state = state.copyWith(error: 'No tafsir book selected');
      return null;
    }

    try {
      final tafsir = await TafsirRepository.getTafsirByGroupAyahKey(
        state.selectedBookName!,
        groupAyahKey,
      );

      return tafsir;
    } catch (e, st) {
      logger.error('Failed to get tafsir by group ayah key $groupAyahKey: $e\n$st');
      state = state.copyWith(error: 'Failed to load tafsir: $e');
      return null;
    }
  }

  // Clear current selection
  void clearCurrentSelection() {
    state = state.copyWith(
      currentTafsir: [],
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
    if (state.currentSurah != null) {
      if (state.currentAyah != null) {
        // Clear cache for this ayah and reload
        final key = '${state.selectedBookName}:${state.currentSurah}:${state.currentAyah}';
        final updatedCache = Map<String, List<Tafsir>>.from(state.tafsirCache);
        updatedCache.remove(key);
        state = state.copyWith(tafsirCache: updatedCache);
        
        await loadTafsirForAyah(state.currentSurah!, state.currentAyah!);
      } else {
        // Clear cache for this surah and reload
        final key = '${state.selectedBookName}:${state.currentSurah}';
        final updatedCache = Map<String, List<Tafsir>>.from(state.surahTafsirCache);
        updatedCache.remove(key);
        state = state.copyWith(surahTafsirCache: updatedCache);
        
        await loadTafsirForSurah(state.currentSurah!);
      }
    }
  }

  @override
  void dispose() {
    // Close all database connections when provider is disposed
    TafsirRepository.closeAllDatabases();
    super.dispose();
  }
}