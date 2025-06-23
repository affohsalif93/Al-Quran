import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/assets/fonts.gen.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/mushaf.dart';
import 'package:quran/models/quran/ayah_line.dart';
import 'package:quran/models/quran/basmallah_line.dart';
import 'package:quran/models/quran/surah_name_line.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/repositories/quran/quran_repository.dart';

extension MushafHelpers on Mushaf {
  Widget getPageWidget(int pageIndex, WidgetRef ref, {bool withColor = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;

        return FutureBuilder<Widget>(
          future: _getPageWidget(pageIndex, ref, maxWidth, maxHeight, withColor: withColor),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else {
              return snapshot.data!;
            }
          },
        );
      },
    );
  }

  Future<Widget> _getPageWidget(
    int pageIndex,
    WidgetRef ref,
    double width,
    double height, {
    bool withColor = false,
  }) async {
    final repo = await ref.read(quranRepositoryProvider.future);
    final ligatures = repo.surahLigatures.ligatures;
    final lines = await repo.getPageLines(pageIndex);

    final avgLines = 15;
    final lineHeight = height / avgLines;
    final fontSize = lineHeight * 0.6;

    logger.fine("fontsize $fontSize");

    final List<Widget> lineWidgets = [];

    final fontFamily = Word.fontFamilyForPage(pageIndex);

    for (final line in lines.values) {
      if (line is BasmallahLine) {
        final basmallahText = line.words.map((word) => word.glyphCode).join('');

        lineWidgets.add(
          Center(
            child: Text(
              basmallahText,
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: Word.fontFamilyForPage(1),
                color: Colors.black,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      } else if (line is SurahNameLine) {
        lineWidgets.add(
          Center(
            child: Text(
              ligatures["surah-${line.surahNumber}"]!,
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: FontFamily.qCFSurahHeaderCOLORRegular,
                color: Colors.black,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      } else if (line is AyahLine && line.words.isNotEmpty) {
        final wordWidgets =
            line.words.map((word) {
              return Text(
                word.glyphCode,
                style: TextStyle(
                  fontSize: fontSize,
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
