import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/ayah_line.dart';
import 'package:quran/models/quran/basmallah_line.dart';
import 'package:quran/models/quran/surah_name_line.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/surah_name_ligature_provider.dart';
import 'package:quran/repositories/quran/quran_repository.dart';
import 'package:quran/views/home/viewer/quran_word_widget.dart';

class QuranPageBuilder {
  final WidgetRef ref;

  QuranPageBuilder(this.ref);

  Future<Widget> buildPageContent(
      int pageNumber,
      double width,
      double height, {
        bool withColor = false,
      }) async {
    final ligature = ref.read(surahNameLigatureProvider);
    final pageData = await ref.read(quranRepositoryProvider).getPageData(pageNumber);

    const avgLines = 15;
    final lineHeight = height / avgLines;
    final scalingFactor = lineHeight * 0.5;
    const ayahVerticalSpacing = 10.0;

    final List<Widget> lineWidgets = [];

    for (final line in pageData.lines.values) {
      if (line is SurahNameLine) {
        lineWidgets.add(
          SizedBox(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(1.0, 0.8, 1.0),
                child: Text(
                  ligature.getHeaderSymbol(line.surahNumber),
                  style: TextStyle(
                    fontSize: scalingFactor * 4.7,
                    fontFamily: ligature.headerFontFamily,
                    color: Colors.black,
                    height: 0.33,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ),
        );
      } else if (line is BasmallahLine) {
        final basmallahText = line.words.map((word) => word.glyphCode).join('');
        lineWidgets.add(
          Container(
            padding: const EdgeInsets.symmetric(vertical: ayahVerticalSpacing * 1.8),
            child: Center(
              child: Text(
                basmallahText,
                style: TextStyle(
                  fontSize: scalingFactor * 1.3,
                  fontFamily: Word.fontFamilyForPage(1),
                  color: Colors.black87,
                  height: 1.0,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        );
      } else if (line is AyahLine && line.words.isNotEmpty) {
        final wordWidgets = line.words.map((word) {
          final ayahKey = (word.surah, word.ayah);
          final ayahWords = pageData.ayahMap[ayahKey] ?? [];

          return QuranWordWidget(
            pageNumber: pageNumber,
            word: word,
            fontSize: 1.5 * scalingFactor,
            ayahWordLocations: ayahWords.map((w) => w.location).toList(),
          );
        }).toList();

        lineWidgets.add(
          Container(
            padding: const EdgeInsets.only(bottom: ayahVerticalSpacing),
            child: Wrap(
              textDirection: TextDirection.rtl,
              alignment: WrapAlignment.start,
              children: wordWidgets,
            ),
          ),
        );
      }
    }

    lineWidgets.add(
      SizedBox(height: ayahVerticalSpacing * 1.5),
    );

    lineWidgets.add(
      Text(
        "$pageNumber",
        style: TextStyle(
          fontSize: 1 * scalingFactor,
          color: Colors.black54,
        ),
      ),
    );

    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: ayahVerticalSpacing * 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: lineWidgets,
        ),
      ),
    );
  }
}

