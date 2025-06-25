import 'dart:convert';
import 'dart:io';

import 'package:quran/core/utils/io.dart';

class SurahNameLigatureService {

  static late final Map<String, String> headersLigature;
  static late final Map<String, String> shortNamesLigature;

  static Future<void> init() async {
    final String headerLigaturePath = IO.joinFromSupportFolder(
      "ligatures",
      "surah_header_name_ligatures.json",
    );

    final String shortNameLigaturePath = IO.joinFromSupportFolder(
      "ligatures",
      "surah_short_name_ligatures.json",
    );

    final headerFile = File(headerLigaturePath);
    final shortNameFile = File(shortNameLigaturePath);

    if (!await headerFile.exists()) {
      throw Exception("Surah ligatures file not found at $headerLigaturePath");
    }
    if (!await shortNameFile.exists()) {
      throw Exception("Surah short name ligatures file not found at $shortNameLigaturePath");
    }

    final headerContent = await headerFile.readAsString();
    final Map<String, dynamic> headerJsonMap = jsonDecode(headerContent);

    final shortNameContent = await shortNameFile.readAsString();
    final Map<String, dynamic> shortNameJsonMap = jsonDecode(shortNameContent);

    headersLigature = headerJsonMap.map((key, value) => MapEntry(key, value as String));
    shortNamesLigature = shortNameJsonMap.map((key, value) => MapEntry(key, value as String));
  }
}
