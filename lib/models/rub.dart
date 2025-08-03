import 'package:quran/models/quran_part_mixin.dart';

class Rub with QuranPartMixin {
  final int rubNumber;
  final int versesCount;
  final String firstAyahKey;
  final String lastAyahKey;
  final Map<String, String> ayahMapping;

  Rub({
    required this.rubNumber,
    required this.versesCount,
    required this.firstAyahKey,
    required this.lastAyahKey,
    required this.ayahMapping,
  });

  factory Rub.fromJson(Map<String, dynamic> json) {
    return Rub(
      rubNumber: json['rub_number'],
      versesCount: json['verses_count'],
      firstAyahKey: json['first_verse_key'],
      lastAyahKey: json['last_verse_key'],
      ayahMapping: Map<String, String>.from(json['verse_mapping']),
    );
  }
}
