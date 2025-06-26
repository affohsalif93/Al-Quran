import 'package:quran/models/quran/page_line.dart';
import 'package:quran/models/quran/word.dart';

class AyahLine extends PageLine {
  final int? firstWordId;
  final int? lastWordId;
  final int? surahNumber;
  final List<Word> words;

  AyahLine({
    required super.pageNumber,
    required super.lineNumber,
    required super.isCentered,
    this.firstWordId,
    this.lastWordId,
    this.surahNumber,
    this.words = const [],
  }) : super(lineType: LineType.ayah);

  factory AyahLine.fromJson(Map<String, dynamic> json) {
    return AyahLine(
      pageNumber: json['page_number'],
      lineNumber: json['line_number'],
      isCentered: json['is_centered'],
      firstWordId: json['first_word_id'],
      lastWordId: json['last_word_id'],
      surahNumber: json['surah_number'],
      words: (json['words'] as List<dynamic>?)
          ?.map((w) => Word.fromJson(w))
          .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'page_number': pageNumber,
    'line_number': lineNumber,
    'line_type': lineType.name,
    'is_centered': isCentered,
    'first_word_id': firstWordId,
    'last_word_id': lastWordId,
    'surah_number': surahNumber,
    'words': words.map((w) => w.toJson()).toList(),
  };

  @override
  List<Object?> get props => super.props + [firstWordId, lastWordId, surahNumber, words];
}
