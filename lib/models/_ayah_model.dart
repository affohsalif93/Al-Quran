import 'package:equatable/equatable.dart';

class AyahModel extends Equatable {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String ayahKey;
  final String text;

  const AyahModel({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahKey,
    required this.text,
  });

  factory AyahModel.fromJson(dynamic json) {
    return AyahModel(
      id: json['id'],
      surahNumber: json['surah_number'],
      ayahNumber: json['ayah_number'],
      ayahKey: json['ayah_key'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'ayah_key': ayahKey,
      'text': text,
    };
  }

  @override
  List<Object?> get props => [id, surahNumber, ayahNumber, ayahKey, text];

  @override
  bool get stringify => true;
}
