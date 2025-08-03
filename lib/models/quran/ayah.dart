import 'package:equatable/equatable.dart';

class Ayah extends Equatable {
  final int id;
  final int page;
  final int surah;
  final int ayah;
  final int juz;
  final int rub;
  final int wordsCount;
  final String text;

  const Ayah({
    required this.id,
    required this.page,
    required this.surah,
    required this.ayah,
    required this.juz,
    required this.rub,
    required this.wordsCount,
    required this.text,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      id: json['id'] as int,
      page: json['page'] as int,
      surah: json['surah'] as int,
      ayah: json['ayah'] as int,
      juz: json['juz'] as int,
      rub: json['rub'] as int,
      wordsCount: json['words_count'] as int,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page': page,
      'surah': surah,
      'ayah': ayah,
      'juz': juz,
      'rub': rub,
      'words_count': wordsCount,
      'text': text,
    };
  }

  get ayahKey => "$surah:$ayah";

  @override
  List<Object?> get props => [id, page, surah, ayah, juz, rub, wordsCount, text];

  @override
  bool get stringify => true;
}
