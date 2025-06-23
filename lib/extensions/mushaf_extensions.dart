import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/assets/assets.gen.dart';
import 'package:quran/assets/fonts.gen.dart';
import 'package:quran/debug/logger.dart';
import 'package:quran/models/mushaf.dart';
import 'package:quran/models/quran/ayah_line.dart';
import 'package:quran/models/quran/basmallah_line.dart';
import 'package:quran/models/quran/surah_name_line.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/quran/quran_repository.dart';

extension MushafHelpers on Mushaf {

  Future<Widget> getPageWidget(int pageIndex, WidgetRef ref, {bool withColor = false}) async {
    final repo = await ref.read(quranRepositoryProvider.future);
    final ligatures = repo.surahLigatures.ligatures;
    final lines = await repo.getPageLines(pageIndex);

    final List<Widget> lineWidgets = [];

    final fontFamily = Word.fontFamilyForPage(pageIndex);

    for (final line in lines.values) {
      if (line is BasmallahLine) {
        final basmallahText = line.words
            .map((word) => word.glyphCode)
            .join('');

        lineWidgets.add(
          Center(
            child: Text(
              basmallahText,
              style: TextStyle(
                fontSize: 30,
                fontFamily: Word.fontFamilyForPage(1),
                color: Colors.black,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      }

      else if (line is SurahNameLine) {
        lineWidgets.add(
          Center(
            child: Text(
              ligatures["surah-${line.surahNumber}"]!,
              style: TextStyle(
                fontSize: 140,
                fontFamily: FontFamily.qCFSurahHeaderCOLORRegular,
                color: Colors.black,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      }

      else if (line is AyahLine && line.words.isNotEmpty) {
        final wordWidgets = line.words.map((word) {
          return Text(
            word.glyphCode,
            style: TextStyle(
              fontSize: 30,
              fontFamily: fontFamily,
              color: Colors.black87,
            ),
            textDirection: TextDirection.rtl,
          );
        }).toList();

        lineWidgets.add(
          Wrap(
            textDirection: TextDirection.rtl,
            alignment: WrapAlignment.start,
            spacing: 3,
            children: wordWidgets,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 7,
      children: lineWidgets,
    );
  }


  String getVerseText(int chapter, int verse) {
    return "";
  }
}
