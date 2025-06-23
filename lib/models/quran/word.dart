import "package:equatable/equatable.dart";

class Word extends Equatable {
  final int id;
  final int location;
  final int surah;
  final int ayah;
  final String glyphCode;

  const Word({
    required this.id,
    required this.location,
    required this.surah,
    required this.ayah,
    required this.glyphCode,
  });

  static String fontFamilyForPage(int pageNumber) {
    return "QPCV1Font$pageNumber";
  }

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as int,
      location: json['location'] as int,
      surah: json['surah'] as int,
      ayah: json['ayah'] as int,
      glyphCode: json['glyphCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'surah': surah,
      'ayah': ayah,
      'glyphCode': glyphCode,
    };
  }

  @override
  List<Object> get props => [
    id,
    location,
    surah,
    ayah,
    glyphCode,
  ];
}
