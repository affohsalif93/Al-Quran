import 'package:flutter/material.dart';

import 'package:quran/extensions/context_extensions.dart';
import 'package:quran/models/quran/line.dart';
import 'package:quran/providers/quran/quran_repository.dart';

enum MushafScript {
  hafsMadinahV1,
  hafsMadinahV2,
  hafsTajweed,
}

class Mushaf {
  final MushafScript id;
  final String englishName;
  final String arabicName;
  final int numberOfPages;
  final String version;
  final int? yearHijri;
  final int? yearGregorian;
  final String coverImage;

  Mushaf({
    required this.id,
    required this.englishName,
    required this.arabicName,
    required this.version,
    this.numberOfPages = 604,
    this.yearHijri,
    this.yearGregorian,
    required this.coverImage,
  });

  String name(BuildContext context) {
    if (context.isArabic) {
      return arabicName;
    } else {
      return englishName;
    }
  }

  String description() {
    String description = "$version $yearGregorian";
    return description.trim();
  }



}
