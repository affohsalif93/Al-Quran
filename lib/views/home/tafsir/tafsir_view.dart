import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:quran/assets/fonts.gen.dart';
import 'package:quran/models/tafsir/tafsir.dart';
import 'package:quran/providers/tafsir/tafsir_provider.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/providers/shared_preferences_provider.dart';
import 'package:quran/repositories/quran_data.dart';

class TafsirView extends ConsumerStatefulWidget {
  const TafsirView({super.key});

  @override
  ConsumerState<TafsirView> createState() => _TafsirViewState();
}

class _TafsirViewState extends ConsumerState<TafsirView> {
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    // Load font size from shared preferences
    final prefs = SharedPreferencesService();
    _fontSize = prefs.getTafsirFontSize();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTafsirForCurrentSelection();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadTafsirForCurrentSelection() {
    final globalState = ref.read(globalControllerProvider);
    final selectedAyah = globalState.selectedAyah;

    ref.read(tafsirProvider.notifier).loadTafsirForAyah(selectedAyah.surah, selectedAyah.ayah);
  }

  void _navigateToAyah(int surah, int ayah) {
    // Update the global selected ayah which will trigger tafsir loading
    final ayahKey = '$surah:$ayah';
    final ayahObject = QuranData.ayahMap[ayahKey];
    if (ayahObject != null) {
      ref.read(globalControllerProvider.notifier).setSelectedAyah(ayahObject);
      ref.read(globalControllerProvider.notifier).goToAyah(surah, ayah);
    }
  }

  Future<void> _navigateToNextRange() async {
    final result = await ref.read(tafsirProvider.notifier).findNextTafsirRange();

    if (result != null) {
      _navigateToAyah(result.surah, result.fromAyah);
    }
  }

  Future<void> _navigateToPreviousRange() async {
    final result = await ref.read(tafsirProvider.notifier).findPreviousTafsirRange();

    if (result != null) {
      _navigateToAyah(result.surah, result.fromAyah);
    }
  }

  //
  // void _navigateToPreviousAyah(int currentSurah, int currentAyah) {
  //   if (currentAyah > 1) {
  //     // Navigate to previous ayah in same surah
  //     _navigateToAyah(currentSurah, currentAyah - 1);
  //   } else if (currentSurah > 1) {
  //     // Navigate to last ayah of previous surah
  //     try {
  //       final previousSurah = QuranData.surahs.firstWhere((s) => s.surahNumber == currentSurah - 1);
  //       _navigateToAyah(currentSurah - 1, previousSurah.numberOfAyahs);
  //     } catch (e) {
  //       // Handle error
  //     }
  //   }
  // }
  //
  // void _navigateToNextAyah(int currentSurah, int currentAyah) {
  //   try {
  //     final surah = QuranData.surahs.firstWhere((s) => s.surahNumber == currentSurah);
  //
  //     if (currentAyah < surah.numberOfAyahs) {
  //       // Navigate to next ayah in same surah
  //       _navigateToAyah(currentSurah, currentAyah + 1);
  //     } else if (currentSurah < 114) {
  //       // Navigate to first ayah of next surah
  //       _navigateToAyah(currentSurah + 1, 1);
  //     }
  //   } catch (e) {
  //     // Handle error
  //   }
  // }
  //

  bool _canNavigateToPreviousAyah(int surah, int ayah) {
    if (ayah > 1) return true;
    if (surah > 1) {
      // Can navigate to previous surah's last ayah
      final previousSurah = QuranData.surahs.firstWhere(
        (s) => s.surahNumber == surah - 1,
        orElse: () => throw Exception('Previous surah not found'),
      );
      return true;
    }
    return false;
  }

  bool _canNavigateToNextAyah(int surah, int ayah) {
    try {
      final currentSurah = QuranData.surahs.firstWhere((s) => s.surahNumber == surah);
      if (ayah < currentSurah.numberOfAyahs) return true;
      if (surah < 114) return true; // Can navigate to next surah's first ayah
    } catch (e) {
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final tafsirState = ref.watch(tafsirProvider);
    final globalState = ref.watch(globalControllerProvider);

    // Listen to selected ayah changes
    ref.listen(globalControllerProvider.select((state) => state.selectedAyah), (previous, next) {
      if ((previous == null || previous.surah != next.surah || previous.ayah != next.ayah)) {
        ref.read(tafsirProvider.notifier).loadTafsirForAyah(next.surah, next.ayah);
      }
    });

    return Scaffold(
      body: Column(
        children: [
          // Header with book selector and current selection
          _buildHeader(context, tafsirState, globalState),

          // Tafsir content
          Expanded(
            child:
                tafsirState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : tafsirState.error != null
                    ? _buildErrorWidget(tafsirState.error!)
                    : tafsirState.currentSelectedTafsir == null
                    ? _buildEmptyWidget()
                    : _buildTafsirContent(tafsirState.currentSelectedTafsir!),
          ),

          // Font size controls at bottom
          _buildFontSizeControls(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, tafsirState, globalState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book selector
          Row(
            children: [
              const Icon(Icons.book),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: tafsirState.selectedBookName,
                  isExpanded: true,
                  items:
                      ref
                          .read(tafsirProvider.notifier)
                          .availableBooks
                          .map(
                            (book) => DropdownMenuItem(
                              value: book.name,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                // textDirection: TextDirection.rtl,
                                spacing: 10,
                                children: [
                                  Text(
                                    book.displayName,
                                    style: const TextStyle(
                                      fontFamily: FontFamily.uthmanTN,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  Text(
                                    "(" + book.author + ")",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontFamily: FontFamily.uthmanTN,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (bookName) {
                    if (bookName != null) {
                      ref.read(tafsirProvider.notifier).setSelectedBook(bookName);
                      _loadTafsirForCurrentSelection();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTafsirContent(Tafsir tafsir) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildTafsirCard(tafsir),
    );
  }

  Widget _buildTafsirCard(Tafsir tafsir) {
    final tafsirState = ref.watch(tafsirProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with surah name in middle and range on far right
            Row(
              children: [
                // Current surah and ayah in center
                Expanded(
                  flex: 2,
                  child: Text(
                    tafsirState.currentSurah != null && tafsirState.currentAyah != null
                        ? '${_getSurahName(tafsirState.currentSurah!)} ${tafsirState.currentAyah!}'
                        : '${_getSurahName(tafsir.parsedAyahKey.$1)} ${tafsir.parsedAyahKey.$2}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Range info on far right
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    tafsir.isRangeEntry
                        ? '${tafsir.fromAyah} - ${tafsir.toAyah}'
                        : '${tafsir.fromAyah}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            if (tafsir.isRangeEntry) const SizedBox(height: 6),

            // Tafsir content (HTML)
            
            Html(
              data: _preprocessHtml(tafsir.text),
              style: {
                "body": Style(
                  fontSize: FontSize(_fontSize),
                  lineHeight: const LineHeight(1.6),
                  textAlign: TextAlign.justify,
                  fontFamily: FontFamily.uthmanTN,
                  // fontWeight: FontWeight.bold,
                ),
                "[lang=ar]": Style(
                  textAlign: TextAlign.right,
                  direction: TextDirection.rtl,
                  fontFamily: FontFamily.uthmanTN,
                  // fontWeight: FontWeight.normal,
                ),
                "h3": Style(
                  fontSize: FontSize(_fontSize + 2),
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  margin: Margins.only(bottom: 8, top: 16),
                ),
                "p": Style(margin: Margins.only(bottom: 12), fontFamily: FontFamily.uthmanTN),
                ".qpc-hafs": Style(
                  fontSize: FontSize(_fontSize - 1.5),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontFamily: FontFamily.uthmanicHafs,
                ),
                ".ar": Style(
                  textAlign: TextAlign.right,
                  direction: TextDirection.rtl,
                  fontFamily: FontFamily.uthmanTN,
                  // fontWeight: FontWeight.normal,
                ),
              },
              onAnchorTap: (url, attributes, element) {
                // Handle links if needed
                debugPrint('Tapped link: $url');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error loading tafsir',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(error, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(tafsirProvider.notifier).refreshCurrentSelection();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No tafsir available',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a verse from the Quran to display its tafsir',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous navigation (range and ayah)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _navigateToPreviousRange,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous Ayah',
              ),
            ],
          ),

          // Current surah and ayah in the center
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.format_size, size: 18),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _fontSize > 18 ? () => _decreaseFontSize() : null,
                      icon: const Icon(Icons.remove, size: 18),
                      tooltip: 'Decrease font size',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_fontSize.toInt()}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                    IconButton(
                      onPressed: _fontSize < 32 ? () => _increaseFontSize() : null,
                      icon: const Icon(Icons.add, size: 18),
                      tooltip: 'Increase font size',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Next navigation (ayah and range)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Next ayah
              IconButton(
                onPressed: _navigateToNextRange,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next Ayah',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _increaseFontSize() {
    if (_fontSize < 32) {
      setState(() {
        _fontSize += 1;
      });
      final prefs = SharedPreferencesService();
      prefs.setTafsirFontSize(_fontSize);
    }
  }

  void _decreaseFontSize() {
    if (_fontSize > 18) {
      setState(() {
        _fontSize -= 1;
      });
      final prefs = SharedPreferencesService();
      prefs.setTafsirFontSize(_fontSize);
    }
  }

  String _getSurahName(int surahNumber) {
    try {
      final surah = QuranData.surahs.firstWhere((surah) => surah.surahNumber == surahNumber);
      return surah.englishName;
    } catch (e) {
      return 'Surah $surahNumber';
    }
  }

  // Preprocess HTML to fix malformed attributes
  String _preprocessHtml(String html) {
    // Fix unquoted class attributes
    String processedHtml = html
        .replaceAll('class=ar', 'class="ar"')
        .replaceAll('lang=ar', 'lang="ar"')
        .replaceAll('class=qpc-hafs', 'class="qpc-hafs"');

    return processedHtml;
  }
}
