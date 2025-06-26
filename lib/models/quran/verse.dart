import 'package:equatable/equatable.dart';

class Ayah extends Equatable {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String verseKey;
  final String text;

  Ayah({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.verseKey,
    required this.text,
  });

  factory Ayah.fromJson(dynamic json) {
    return Ayah(
      id: json['id'],
      surahNumber: json['surah_number'],
      ayahNumber: json['ayah_number'],
      verseKey: json['verse_key'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'verse_key': verseKey,
      'text': text,
    };
  }

  @override
  List<Object?> get props => [id, surahNumber, ayahNumber, verseKey, text];

  @override
  bool get stringify => true;
}
