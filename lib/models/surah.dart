import 'package:flutter/material.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/i18n/strings.g.dart';

class Surah {
  final int id;
  final String englishName;
  final String arabicName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationPlace;
  final List<int> pages;
  final int revelationOrder;
  final int surahNumber;

  Surah({
    required this.id,
    required this.englishName,
    required this.arabicName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationPlace,
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

  String dataFormatted(BuildContext context) {
    return '${context.t.page} $firstPage - $revelationPlace - Ayah $numberOfAyahs';
  }

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'],
      englishName: json['name_complex'],
      arabicName: json['name_arabic'],
      englishNameTranslation: json['translated_name']['name'],
      numberOfAyahs: json['verses_count'],
      revelationPlace: json['revelation_place'],
      pages: List<int>.from(json['pages'] as List),
      revelationOrder: json['revelation_order'],
      surahNumber: json['surah_number'],
    );
  }
}
