import 'package:equatable/equatable.dart';

class Ayah extends Equatable {
  final int pageNumber;
  final int surah;
  final int ayah;
  final String text;

  const Ayah({required this.pageNumber, required this.surah, required this.ayah, required this.text});

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      pageNumber: json['page'] as int,
      surah: json['sura'] as int,
      ayah: json['ayah'] as int,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': pageNumber,
      'sura': surah,
      'ayah': ayah,
      'text': text,
    };
  }

  @override
  List<Object?> get props => [pageNumber, surah, ayah, text];

  @override
  bool get stringify => true;
}
