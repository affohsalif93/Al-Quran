class JuzModel {
  final int juzNumber;
  final int versesCount;
  final String firstVerseKey;
  final String lastVerseKey;
  final Map<String, String> verseMapping;

  JuzModel({
    required this.juzNumber,
    required this.versesCount,
    required this.firstVerseKey,
    required this.lastVerseKey,
    required this.verseMapping,
  });

  factory JuzModel.fromJson(Map<String, dynamic> json) {
    return JuzModel(
      juzNumber: json['juz_number'],
      versesCount: json['verses_count'],
      firstVerseKey: json['first_verse_key'],
      lastVerseKey: json['last_verse_key'],
      verseMapping: Map<String, String>.from(json['verse_mapping']),
    );
  }
}
