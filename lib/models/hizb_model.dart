import 'package:quran/models/quran_part_mixin.dart';

class HizbModel with QuranPartMixin {
  final int hizbNumber;
  final int versesCount;
  final String firstAyahKey;
  final String lastAyahKey;
  final Map<String, String> verseMapping;

  HizbModel({
    required this.hizbNumber,
    required this.versesCount,
    required this.firstAyahKey,
    required this.lastAyahKey,
    required this.verseMapping,
  });

  factory HizbModel.fromJson(Map<String, dynamic> json) {
    return HizbModel(
      hizbNumber: json['hizb_number'],
      versesCount: json['verses_count'],
      firstAyahKey: json['first_verse_key'],
      lastAyahKey: json['last_verse_key'],
      verseMapping: Map<String, String>.from(json['verse_mapping']),
    );
  }
}
