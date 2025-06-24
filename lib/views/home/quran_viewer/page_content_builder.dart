import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/assets/fonts.gen.dart';
import 'package:quran/models/quran/ayah_line.dart';
import 'package:quran/models/quran/basmallah_line.dart';
import 'package:quran/models/quran/surah_name_line.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/repositories/quran/quran_repository.dart';

class PageContentBuilder {
  final WidgetRef ref;

  PageContentBuilder(this.ref);

  Future<Widget> buildPageContent(
      int pageIndex,
      double width,
      double height, {
        bool withColor = false,
      }) async {
    final repo = await ref.read(quranRepositoryProvider.future);
    final ligatures = repo.surahLigatures.ligatures;
    final lines = await repo.getPageLines(pageIndex);

    const avgLines = 15;
    final lineHeight = height / avgLines;
    final scalingFactor = lineHeight * 0.5;
    const ayahVerticalSpacing = 10.0;

    final List<Widget> lineWidgets = [];
    final fontFamily = Word.fontFamilyForPage(pageIndex);

    for (final line in lines.values) {
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
                  ligatures["surah-${line.surahNumber}"]!,
                  style: TextStyle(
                    fontSize: scalingFactor * 4.7,
                    fontFamily: FontFamily.qCFSurahHeaderCOLORRegular,
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
        final basmallahText =
        line.words.map((word) => word.glyphCode).join('');

        lineWidgets.add(
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: ayahVerticalSpacing * 1.8,
            ),
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
          return Text(
            word.glyphCode,
            style: TextStyle(
              fontSize: scalingFactor,
              fontFamily: fontFamily,
              color: Colors.black87,
            ),
            textDirection: TextDirection.rtl,
          );
        }).toList();

        lineWidgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: ayahVerticalSpacing),
            child: Wrap(
              textDirection: TextDirection.rtl,
              alignment: WrapAlignment.start,
              spacing: 1,
              children: wordWidgets,
            ),
          ),
        );
      }
    }

    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: lineWidgets,
      ),
    );
  }
}
