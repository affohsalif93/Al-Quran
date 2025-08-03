import 'package:quran/models/quran_part_mixin.dart';

class Juz with QuranPartMixin {
  final int juzNumber;
  final int versesCount;
  final String firstAyahKey;
  final String lastAyahKey;
  final Map<String, String> ayahMapping;

  Juz({
    required this.juzNumber,
    required this.versesCount,
    required this.firstAyahKey,
    required this.lastAyahKey,
    required this.ayahMapping,
  });

  factory Juz.fromJson(Map<String, dynamic> json) {
    return Juz(
      juzNumber: json['juz_number'],
      versesCount: json['verses_count'],
      firstAyahKey: json['first_verse_key'],
      lastAyahKey: json['last_verse_key'],
      ayahMapping: Map<String, String>.from(json['verse_mapping']),
    );
  }
}
