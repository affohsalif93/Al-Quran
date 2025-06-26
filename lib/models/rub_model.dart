class RubModel {
  final int rubNumber;
  final int versesCount;
  final String firstAyahKey;
  final String lastAyahKey;
  final Map<String, String> verseMapping;

  RubModel({
    required this.rubNumber,
    required this.versesCount,
    required this.firstAyahKey,
    required this.lastAyahKey,
    required this.verseMapping,
  });

  factory RubModel.fromJson(Map<String, dynamic> json) {
    return RubModel(
      rubNumber: json['rub_number'],
      versesCount: json['verses_count'],
      firstAyahKey: json['first_verse_key'],
      lastAyahKey: json['last_verse_key'],
      verseMapping: Map<String, String>.from(json['verse_mapping']),
    );
  }
}
