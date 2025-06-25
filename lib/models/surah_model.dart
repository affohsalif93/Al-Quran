import 'package:flutter/material.dart';
import 'package:quran/core/enums/revelation_enum.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/i18n/strings.g.dart';

class SurahModel {
  final int id;
  final String englishName;
  final String arabicName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  final List<int> pages;
  final int revelationOrder;
  final int surahNumber;

  SurahModel({
    required this.id,
    required this.englishName,
    required this.arabicName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    required this.pages,
    required this.revelationOrder,
    required this.surahNumber,
  });

  int get firstPage => pages.first;

  String name(BuildContext context) {
    if (context.isArabic) {
      return arabicName;
    } else {
      return englishName;
    }
  }

  RevelationEnum get revelationEnum {
    return RevelationEnum.fromArabicString(revelationType);
  }

  String dataFormatted(BuildContext context) {
    return '${context.t.page} $firstPage - ${revelationEnum.text(context)} - ${context.t.verseCount(n: numberOfAyahs)}';
  }

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      id: json['id'],
      englishName: json['name_complex'],
      arabicName: json['name_arabic'],
      englishNameTranslation: json['translated_name']['name'],
      numberOfAyahs: json['verses_count'],
      revelationType: json['revelation_place'],
      pages: json['pages'],
      revelationOrder: json['revelation_order'],
      surahNumber: json['surah_number'],
    );
  }
}