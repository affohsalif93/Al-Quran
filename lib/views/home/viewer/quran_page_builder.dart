import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/models/quran/ayah_line.dart';
import 'package:quran/models/quran/basmallah_line.dart';
import 'package:quran/models/quran/page_data.dart';
import 'package:quran/models/quran/surah_name_line.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/quran_page_provider.dart';
import 'package:quran/repositories/quran/static_quran_data.dart';
import 'package:quran/views/home/viewer/quran_word_widget.dart';

class QuranPageBuilder {
  final WidgetRef ref;

  QuranPageBuilder(this.ref);

  Future<Widget> buildPageContent(int pageNumber, double width, double height) async {
    final state = ref.watch(quranPageControllerProvider(pageNumber));

    if (state.data.isEmpty) {
      ref.read(quranPageControllerProvider(pageNumber).notifier).loadPage();
      return Center(child: CircularProgressIndicator());
    }

    return _buildFromData(state.data, pageNumber, width, height);
  }

  Widget _buildFromData(QuranPageData pageData, int pageNumber, double width, double height) {

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
                transform: Matrix4.diagonal3Values(1.5, 1.0, 1.0),
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
                pageNumber: pageNumber,
                word: word,
                fontSize: 1.7 * scalingFactor,
                fontFamily: Word.fontFamilyForPage(1),
              );
            }).toList();

        lineWidgets.add(
          Container(
            padding: const EdgeInsets.symmetric(vertical: ayahVerticalSpacing / 2),
            child: Wrap(textDirection: TextDirection.rtl, children: basmallahWords),
          ),
        );
      } else if (line is AyahLine && line.words.isNotEmpty) {
        final wordWidgets =
            line.words.map((word) {
              return QuranWordWidget(
                pageNumber: pageNumber,
                word: word,
                fontSize: 1.5 * scalingFactor,
              );
            }).toList();

        lineWidgets.add(
          Container(
            padding: const EdgeInsets.symmetric(vertical: ayahVerticalSpacing / 2),
            // decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 0.5)),
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
      SizedBox(height: ayahVerticalSpacing * 1.5),
      Text("$pageNumber", style: TextStyle(fontSize: 1 * scalingFactor, color: Colors.black54)),
    ]);

    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.only(top: ayahVerticalSpacing * 7, bottom: ayahVerticalSpacing * 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: lineWidgets),
      ),
    );
  }
}
