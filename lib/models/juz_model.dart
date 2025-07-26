import 'package:quran/models/quran_part_mixin.dart';

class JuzModel with QuranPartMixin {
  final int juzNumber;
  final int versesCount;
  final String firstAyahKey;
  final String lastAyahKey;
  final Map<String, String> verseMapping;

  JuzModel({
    required this.juzNumber,
    required this.versesCount,
    required this.firstAyahKey,
    required this.lastAyahKey,
    required this.verseMapping,
  });

  factory JuzModel.fromJson(Map<String, dynamic> json) {
    return JuzModel(
      juzNumber: json['juz_number'],
      versesCount: json['verses_count'],
      firstAyahKey: json['first_verse_key'],
      lastAyahKey: json['last_verse_key'],
      verseMapping: Map<String, String>.from(json['verse_mapping']),
    );
  }
}
