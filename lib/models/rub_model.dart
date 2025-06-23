class RubModel {
  final int rubNumber;
  final int versesCount;
  final String firstVerseKey;
  final String lastVerseKey;
  final Map<String, String> verseMapping;

  RubModel({
    required this.rubNumber,
    required this.versesCount,
    required this.firstVerseKey,
    required this.lastVerseKey,
    required this.verseMapping,
  });

  factory RubModel.fromJson(Map<String, dynamic> json) {
    return RubModel(
      rubNumber: json['rub_number'],
      versesCount: json['verses_count'],
      firstVerseKey: json['first_verse_key'],
      lastVerseKey: json['last_verse_key'],
      verseMapping: Map<String, String>.from(json['verse_mapping']),
    );
  }
}
