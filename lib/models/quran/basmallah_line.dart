import 'package:quran/models/quran/page_line.dart';
import 'package:quran/models/quran/word.dart';

class BasmallahLine extends PageLine {
  final int surahNumber;
  final int ayahNumber;
  final List<Word> words;

  const BasmallahLine({
    required super.pageNumber,
    required super.lineNumber,
    required super.isCentered,
    required this.surahNumber,
    required this.words,
    this.ayahNumber = 1,
  }) : super(lineType: LineType.basmallah);

  factory BasmallahLine.fromJson(Map<String, dynamic> json) {
    return BasmallahLine(
      pageNumber: json['page_number'],
      lineNumber: json['line_number'],
      isCentered: json['is_centered'],
      surahNumber: json['surah_number'],
      ayahNumber: json['ayah_number'] ?? 1,
      words: (json['words'] as List<dynamic>)
          .map((wordJson) => Word.fromJson(wordJson as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'page_number': pageNumber,
    'line_number': lineNumber,
    'line_type': lineType.name,
    'is_centered': isCentered,
    'surah_number': surahNumber,
    'ayah_number': ayahNumber,
    'words': words.map((word) => word.toJson()).toList(),
  };

  @override
  List<Object?> get props => super.props + [surahNumber, ayahNumber];
}
