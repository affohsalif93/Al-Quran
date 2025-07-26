import 'dart:convert';
import 'dart:io';

import 'package:quran/core/utils/io.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/_ayah_model.dart';
import 'package:quran/models/hizb_model.dart';
import 'package:quran/models/juz_model.dart';
import 'package:quran/models/rub_model.dart';
import 'package:quran/models/surah_model.dart';

class StaticQuranDataLoader {
  static late final Map<String, String> headersLigature;
  static late final Map<String, String> shortNamesLigature;
  static late final List<SurahModel> surahList;
  static late final List<JuzModel> juzList;
  static late final List<HizbModel> hizbList;
  static late final List<RubModel> rubList;
  static late final List<AyahModel> ayahList;

  static Future<void> loadLigatures() async {
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

  static Future<void> loadSurahList() async {
    final String surahListPath = IO.joinFromMetadataFolder("quran-metadata-surah.json");
    final File surahFile = File(surahListPath);

    if (!await surahFile.exists()) {
      throw Exception("Surah list file not found at $surahListPath");
    }

    final String content = await surahFile.readAsString();

    final List<dynamic> jsonList = jsonDecode(content);
    surahList = jsonList.map((json) => SurahModel.fromJson(json)).toList();
  }

  static Future<void> loadJuzList() async {
    final String juzListPath = IO.joinFromMetadataFolder("quran-metadata-juz.json");
    final File juzFile = File(juzListPath);

    if (!await juzFile.exists()) {
      throw Exception("Juz list file not found at $juzListPath");
    }

    final String content = await juzFile.readAsString();
    final Map<String, dynamic> jsonMap = jsonDecode(content);

    juzList =
        jsonMap.entries.map((entry) {
          final int juzNumber = int.parse(entry.key);
          final Map<String, dynamic> juzData = entry.value as Map<String, dynamic>;

          return JuzModel(
            juzNumber: juzNumber,
            versesCount: juzData['verses_count'] as int,
            firstAyahKey: juzData['first_verse_key'] as String,
            lastAyahKey: juzData['last_verse_key'] as String,
            verseMapping: Map<String, String>.from(juzData['verse_mapping'] as Map),
          );
        }).toList();
  }

  static Future<void> loadHizbList() async {
    final String hizbListPath = IO.joinFromMetadataFolder("quran-metadata-hizb.json");
    final File hizbFile = File(hizbListPath);

    if (!await hizbFile.exists()) {
      throw Exception("Hizb list file not found at $hizbFile");
    }

    final String content = await hizbFile.readAsString();
    final Map<String, dynamic> jsonMap = jsonDecode(content);

    hizbList =
        jsonMap.entries.map((entry) {
          final int rubNumber = int.parse(entry.key);
          final Map<String, dynamic> hizbData = entry.value as Map<String, dynamic>;

          return HizbModel(
            hizbNumber: rubNumber,
            versesCount: hizbData['verses_count'] as int,
            firstAyahKey: hizbData['first_verse_key'] as String,
            lastAyahKey: hizbData['last_verse_key'] as String,
            verseMapping: Map<String, String>.from(hizbData['verse_mapping'] as Map),
          );
        }).toList();
  }

  static Future<void> loadRubList() async {
    final String rubListPath = IO.joinFromMetadataFolder("quran-metadata-rub.json");
    final File rubFile = File(rubListPath);

    if (!await rubFile.exists()) {
      throw Exception("Rub list file not found at $rubListPath");
    }

    final String content = await rubFile.readAsString();
    final Map<String, dynamic> jsonMap = jsonDecode(content);

    logger.fine("Before assign");

    rubList =
        jsonMap.entries.map((entry) {
          final int rubNumber = int.parse(entry.key);
          final Map<String, dynamic> rubData = entry.value as Map<String, dynamic>;
          return RubModel(
            rubNumber: rubNumber,
            versesCount: rubData['verses_count'] as int,
            firstAyahKey: rubData['first_verse_key'] as String,

            lastAyahKey: rubData['last_verse_key'] as String,
            verseMapping: Map<String, String>.from(rubData['verse_mapping'] as Map),
          );
        }).toList();

    logger.fine("After assign");
  }

  static Future<void> loadAyahList() async {
    final String ayahListPath = IO.joinFromMetadataFolder("quran-metadata-ayah.json");
    final File ayahFile = File(ayahListPath);

    if (!await ayahFile.exists()) {
      throw Exception("Ayah list file not found at $ayahListPath");
    }

    final String content = await ayahFile.readAsString();
    final Map<String, dynamic> jsonMap = jsonDecode(content);

    ayahList =
        jsonMap.entries.map((entry) {
          final int id = int.parse(entry.key);
          final Map<String, dynamic> ayahData = entry.value as Map<String, dynamic>;

          return AyahModel(
            id: id,
            surahNumber: ayahData['surah_number'] as int,
            ayahNumber: ayahData['ayah_number'] as int,
            ayahKey: ayahData['verse_key'] as String,
            text: ayahData['text'] as String,
          );
        }).toList();
  }

  static Future<void> load() async {
    await loadLigatures();
    await loadSurahList();
    await loadJuzList();
    await loadHizbList();
    await loadRubList();
    await loadAyahList();
  }
}
