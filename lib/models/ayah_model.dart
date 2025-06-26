import 'package:equatable/equatable.dart';
import 'package:quran/models/quran/word.dart';

class AyahLineSpan {
  final int lineNumber;
  final List<Word> words;

  AyahLineSpan({required this.lineNumber, required this.words});
}

class Ayah extends Equatable {
  final int surah;
  final int ayah;
  final String text;
  final List<AyahLineSpan> spans;

  const Ayah({required this.surah, required this.ayah, required this.text, required this.spans});

  List<Word> get allWords => spans.expand((s) => s.words).toList();

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      surah: json['sura'] as int,
      ayah: json['ayah'] as int,
      text: json['text'] as String,
      spans:
          (json['spans'] as List<dynamic>).map((span) {
            return AyahLineSpan(
              lineNumber: span['lineNumber'] as int,
              words:
                  (span['words'] as List<dynamic>).map((word) {
                    return Word.fromJson(word as Map<String, dynamic>);
                  }).toList(),
            );
          }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sura': surah,
      'ayah': ayah,
      'text': text,
      'spans':
          spans.map((span) {
            return {
              'lineNumber': span.lineNumber,
              'words': span.words.map((word) => word.toJson()).toList(),
            };
          }).toList(),
    };
  }

  @override
  List<Object?> get props => [surah, ayah, text, spans];

  @override
  bool get stringify => true;
}
