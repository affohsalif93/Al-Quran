import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:quran/models/tafsir/tafsir.dart';
import 'package:quran/providers/tafsir/tafsir_provider.dart';
import 'package:quran/providers/global/global_controller.dart';

class TafsirView extends ConsumerStatefulWidget {
  const TafsirView({super.key});

  @override
  ConsumerState<TafsirView> createState() => _TafsirViewState();
}

class _TafsirViewState extends ConsumerState<TafsirView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTafsirForCurrentSelection();
    });
  }

  void _loadTafsirForCurrentSelection() {
    final globalState = ref.read(globalControllerProvider);
    final selectedAyah = globalState.selectedAyah;
    
    if (selectedAyah != null) {
      ref.read(tafsirProvider.notifier).loadTafsirForAyah(
        selectedAyah.surah,
        selectedAyah.ayah,
      );
    } else {
      // Load tafsir for current page's first ayah or surah
      final currentPage = globalState.currentPage;
      // You might want to get the first ayah of the current page
      // For now, let's load surah 1 as default
      ref.read(tafsirProvider.notifier).loadTafsirForSurah(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tafsirState = ref.watch(tafsirProvider);
    final globalState = ref.watch(globalControllerProvider);

    // Listen to selected ayah changes
    ref.listen(globalControllerProvider.select((state) => state.selectedAyah), (previous, next) {
      if (next != null && (previous == null || previous.surah != next.surah || previous.ayah != next.ayah)) {
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
            child: tafsirState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : tafsirState.error != null
                    ? _buildErrorWidget(tafsirState.error!)
                    : tafsirState.currentTafsir.isEmpty
                        ? _buildEmptyWidget()
                        : _buildTafsirContent(tafsirState.currentTafsir),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, tafsirState, globalState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
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
                  items: ref.read(tafsirProvider.notifier).availableBooks
                      .map((book) => DropdownMenuItem(
                            value: book.name,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  book.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  book.author,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ))
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
          
          const SizedBox(height: 8),
          
          // Current selection info
          if (tafsirState.currentSurah != null)
            Text(
              tafsirState.currentAyah != null
                  ? 'الآية ${tafsirState.currentAyah} من سورة ${_getSurahName(tafsirState.currentSurah!)}'
                  : 'سورة ${_getSurahName(tafsirState.currentSurah!)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTafsirContent(List<Tafsir> tafsirList) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tafsirList.length,
      itemBuilder: (context, index) {
        final tafsir = tafsirList[index];
        return _buildTafsirCard(tafsir);
      },
    );
  }

  Widget _buildTafsirCard(Tafsir tafsir) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ayah range info
            if (tafsir.isRangeEntry)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'الآيات ${tafsir.fromAyah} - ${tafsir.toAyah}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            if (tafsir.isRangeEntry) const SizedBox(height: 12),
            
            // Tafsir content (HTML)
            Html(
              data: tafsir.text,
              style: {
                "body": Style(
                  fontSize: FontSize(16),
                  lineHeight: const LineHeight(1.6),
                  textAlign: TextAlign.justify,
                ),
                "h3": Style(
                  fontSize: FontSize(18),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  margin: Margins.only(bottom: 12, top: 16),
                ),
                "p": Style(
                  margin: Margins.only(bottom: 12),
                ),
                ".qpc-hafs": Style(
                  fontSize: FontSize(18),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                ".ar": Style(
                  textAlign: TextAlign.right,
                  direction: TextDirection.rtl,
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'خطأ في تحميل التفسير',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(tafsirProvider.notifier).refreshCurrentSelection();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
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
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد تفسير متاح',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'اختر آية من المصحف لعرض تفسيرها',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getSurahName(int surahNumber) {
    // This should be replaced with actual surah names
    // You might want to create a surah names utility
    final surahNames = [
      'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة', 'الأنعام', 'الأعراف', 'الأنفال', 'التوبة', 'يونس',
      // Add all 114 surah names...
    ];
    
    if (surahNumber > 0 && surahNumber <= surahNames.length) {
      return surahNames[surahNumber - 1];
    }
    
    return 'سورة $surahNumber';
  }
}
