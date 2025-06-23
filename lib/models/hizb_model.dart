class HizbModel {
  final int hizbNumber;
  final int versesCount;
  final String firstVerseKey;
  final String lastVerseKey;
  final Map<String, String> verseMapping;

  HizbModel({
    required this.hizbNumber,
    required this.versesCount,
    required this.firstVerseKey,
    required this.lastVerseKey,
    required this.verseMapping,
  });

  factory HizbModel.fromJson(Map<String, dynamic> json) {
    return HizbModel(
      hizbNumber: json['hizb_number'],
      versesCount: json['verses_count'],
      firstVerseKey: json['first_verse_key'],
      lastVerseKey: json['last_verse_key'],
      verseMapping: Map<String, String>.from(json['verse_mapping']),
    );
  }
}
