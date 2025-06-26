import "package:equatable/equatable.dart";
import "package:quran/models/quran/ayah_line.dart";
import "package:quran/models/quran/basmallah_line.dart";
import "package:quran/models/quran/surah_name_line.dart";

enum LineType { ayah, surahName, basmallah }

abstract class PageLine extends Equatable {
  final int pageNumber;
  final int lineNumber;
  final LineType lineType;
  final bool isCentered;

  const PageLine({
    required this.pageNumber,
    required this.lineNumber,
    required this.lineType,
    required this.isCentered,
  });

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [
    pageNumber,
    lineNumber,
    lineType,
    isCentered,
  ];

  static PageLine fromJson(Map<String, dynamic> json) {
    final lineType = parseLineType(json['line_type']);

    switch (lineType) {
      case LineType.ayah:
        return AyahLine.fromJson(json);
      case LineType.surahName:
        return SurahNameLine.fromJson(json);
      case LineType.basmallah:
        return BasmallahLine.fromJson(json);
    }
  }

  static LineType parseLineType(String value) {
    switch (value) {
      case 'ayah':
        return LineType.ayah;
      case 'surah_name':
        return LineType.surahName;
      case 'basmallah':
        return LineType.basmallah;
      default:
        throw ArgumentError('Unknown line type: $value');
    }
  }
}
