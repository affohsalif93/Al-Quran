import 'package:quran/models/quran/page_line.dart';

class SurahNameLine extends PageLine {
  final int surahNumber;

  const SurahNameLine({
    required super.pageNumber,
    required super.lineNumber,
    required super.isCentered,
    required this.surahNumber,
  }) : super(lineType: LineType.surahName);

  factory SurahNameLine.fromJson(Map<String, dynamic> json) {
    return SurahNameLine(
      pageNumber: json['page_number'],
      lineNumber: json['line_number'],
      isCentered: json['is_centered'],
      surahNumber: json['surah_number'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'page_number': pageNumber,
    'line_number': lineNumber,
    'line_type': lineType.name,
    'is_centered': isCentered,
    'surah_number': surahNumber,
  };

  @override
  List<Object?> get props => super.props + [surahNumber];
}
