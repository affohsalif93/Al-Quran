import 'dart:convert';
import 'dart:io';
import 'package:quran/utils/io.dart';

Future<SurahLigatures> loadSurahLigatures() async {
  final String ligatureFilePath = IO.joinFromSupportFolder("surah_name_ligatures.json");
  final ligatureFile = File(ligatureFilePath);

  if (!await ligatureFile.exists()) {
    throw Exception("Surah ligatures file not found at $ligatureFilePath");
  }

  final fileContent = await ligatureFile.readAsString();

  final Map<String, dynamic> jsonMap = jsonDecode(fileContent);
  return SurahLigatures.fromJson(jsonMap);
}

class SurahLigatures {
  final Map<String, String> ligatures;

  SurahLigatures(this.ligatures);

  factory SurahLigatures.fromJson(Map<String, dynamic> json) {
    return SurahLigatures(
      json.map((key, value) => MapEntry(key, value as String)),
    );
  }
}
