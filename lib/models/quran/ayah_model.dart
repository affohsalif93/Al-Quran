import 'package:equatable/equatable.dart';

class Ayah extends Equatable {
  final int page;
  final int surah;
  final int ayah;
  final String text;

  const Ayah({required this.page, required this.surah, required this.ayah, required this.text});

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      page: json['page'] as int,
      surah: json['surah'] as int,
      ayah: json['ayah'] as int,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'surah': surah,
      'ayah': ayah,
      'text': text,
    };
  }

  @override
  List<Object?> get props => [page, surah, ayah, text];

  @override
  bool get stringify => true;
}
