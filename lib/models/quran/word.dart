import "package:equatable/equatable.dart";

class Word extends Equatable {
  final int id;
  final String location;
  final int surah;
  final int ayah;
  final String glyph;
  final String text;
  final bool isAyahNrSymbol;

  const Word({
    required this.id,
    required this.location,
    required this.surah,
    required this.ayah,
    required this.text,
    required this.glyph,
    this.isAyahNrSymbol = false,
  });

  static String fontFamilyForPage(int pageNumber) {
    return "QPCV1Font$pageNumber";
  }

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as int,
      location: json['location'],
      surah: json['surah'] as int,
      ayah: json['ayah'] as int,
      text: json['text'] as String,
      glyph: json['glyph'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'surah': surah,
      'ayah': ayah,
      'text': text,
      'glyph': glyph,
    };
  }

  @override
  List<Object> get props => [
    id,
    location,
    surah,
    ayah,
    text,
    glyph,
  ];
}
