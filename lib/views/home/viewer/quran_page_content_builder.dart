import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/ayah_line.dart';
import 'package:quran/models/quran/basmallah_line.dart';
import 'package:quran/models/quran/page_data.dart';
import 'package:quran/models/quran/surah_name_line.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/quran/quran_page_provider.dart';
import 'package:quran/repositories/quran/static_quran_data.dart';
import 'package:quran/views/home/viewer/quran_word_widget.dart';

class QuranPageContentBuilder {
  final WidgetRef ref;

  QuranPageContentBuilder(this.ref);

  Future<Widget> buildPageContent({
    required int page,
    required double width,
    required double height,
  }) async {
    final dualPageState = ref.watch(quranDualPageProvider);
    final dualPageController = ref.read(quranDualPageProvider.notifier);

    final pageData = dualPageState.getPageData(page);
    
    if (pageData == null) {
      dualPageController.loadPage(page);
      return Center(child: CircularProgressIndicator());
    }

    return _buildFromData(pageData, page, width, height);
  }

  Widget _buildFromData(QuranPageData pageData, int page, double width, double height) {
    const avgLines = 16;
    final lineHeight = height / avgLines;
    final scalingFactor = lineHeight * 0.43;
    final ayahVerticalSpacing = lineHeight / 10;

    final List<Widget> lineWidgets = [];

    for (final line in pageData.lines.values) {
      if (line is SurahNameLine) {
        lineWidgets.add(
          Container(
            height: lineHeight,
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(1.35, 1.0, 1.0),
                child: Text(
                  StaticQuranData.namesLigatures.getHeaderSymbol(line.surahNumber),
                  style: TextStyle(
                    fontSize: scalingFactor * 4.7,
                    fontFamily: StaticQuranData.namesLigatures.headerFontFamily,
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
        final basmallahWords =
            line.words.map((word) {
              return QuranWordWidget.withFont(
                pageNumber: page,
                word: word,
                fontSize: 1.7 * scalingFactor,
                fontFamily: Word.fontFamilyForPage(1),
                paddingVertical: 0,
                lineHeight: lineHeight,
              );
            }).toList();

        lineWidgets.add(
          SizedBox(
            height: lineHeight,
            child: Wrap(textDirection: TextDirection.rtl, children: basmallahWords),
          ),
        );
      } else if (line is AyahLine && line.words.isNotEmpty) {
        final wordWidgets =
            line.words.map((word) {
              return QuranWordWidget(
                pageNumber: page,
                word: word,
                fontSize: 1.3 * scalingFactor,
                paddingVertical: ayahVerticalSpacing,
                lineHeight: lineHeight,
              );
            }).toList();

        lineWidgets.add(
          SizedBox(
            height: lineHeight,
            child: Wrap(
              textDirection: TextDirection.rtl,
              alignment: WrapAlignment.start,
              children: wordWidgets,
            ),
          ),
        );
      }
    }

    lineWidgets.addAll([
      SizedBox(height: ayahVerticalSpacing),
      Text("$page", style: TextStyle(fontSize: 0.9 * scalingFactor, color: Colors.black54)),
    ]);

    return Container(
      width: width,
      height: height,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: lineWidgets),
    );
  }
}
