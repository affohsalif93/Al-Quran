import 'package:quran/models/quran_part_mixin.dart';

class Hizb with QuranPartMixin {
  final int hizbNumber;
  final int versesCount;
  final String firstAyahKey;
  final String lastAyahKey;
  final Map<String, String> ayahMapping;

  Hizb({
    required this.hizbNumber,
    required this.versesCount,
    required this.firstAyahKey,
    required this.lastAyahKey,
    required this.ayahMapping,
  });

  factory Hizb.fromJson(Map<String, dynamic> json) {
    return Hizb(
      hizbNumber: json['hizb_number'],
      versesCount: json['verses_count'],
      firstAyahKey: json['first_verse_key'],
      lastAyahKey: json['last_verse_key'],
      ayahMapping: Map<String, String>.from(json['verse_mapping']),
    );
  }
}
