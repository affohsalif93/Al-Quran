import 'package:quran/assets/fonts.gen.dart';

class SurahNameLigature {
  final Map<String, String> _names;
  final Map<String, String> _headers;

  SurahNameLigature({
    required Map<String, String> names,
    required Map<String, String> headers,
  }) : _names = names,
       _headers = headers;

  String getShortName(int surahNumber) {
    return _names["surah-$surahNumber"]!;
  }

  String getHeaderSymbol(int surahNumber) {
    return _headers["surah-$surahNumber"]!;
  }

  get headerFontFamily => FontFamily.qCFSurahHeaderCOLORRegular;
  get shortNameFontFamily => FontFamily.surahNameV2;
}
