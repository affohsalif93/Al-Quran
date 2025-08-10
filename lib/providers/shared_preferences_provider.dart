import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quran/core/utils/helper_functions.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/repositories/quran_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quran/i18n/strings.g.dart';
import 'package:quran/models/tafsir.dart';
import '../models/mushaf.dart';

enum PrefsEnum {
  isDarkMode,
  pageNumber,
  bookmark,
  locale,
  mushafScript,
  riwayah,
  tafsirList,
  zoomLevel,
  tafsirFontSize,
}

final sharedPreferencesProvider = Provider<SharedPreferencesService>((ref) {
  return SharedPreferencesService();
});

class SharedPreferencesService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // init locale
    final locale = _prefs.getString(PrefsEnum.locale.name) ?? 'ar';
    LocaleSettings.setLocaleRaw(locale);
  }

  // THEME MODE & DARK MODE
  ThemeMode getThemeMode() {
    return getIsDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }

  void setThemeMode(ThemeMode themeMode) {
    setIsDarkMode(themeMode == ThemeMode.dark);
  }

  bool getIsDarkMode() {
    return _prefs.getBool(PrefsEnum.isDarkMode.name) ?? false;
  }

  void setIsDarkMode(bool value) {
    _prefs.setBool(PrefsEnum.isDarkMode.name, value);
  }

  // CURRENT MUSHAF
  void setCurrentMushaf(String mushafName) {
    _prefs.setString(PrefsEnum.mushafScript.name, mushafName);
  }

  Mushaf getCurrentMushaf({String? defaultMushafName}) {
    final mushafName = _prefs.getString(PrefsEnum.mushafScript.name);
    if (mushafName == null) {
      return QuranData.defaultMushaf;
    }
    final mushaf = QuranData.mushafs.firstWhere(
      (element) => element.name == mushafName,
      orElse: () => QuranData.defaultMushaf,
    );
    return mushaf;
  }

  // PAGE NUMBER
  int getPageNumber() {
    return _prefs.getInt(PrefsEnum.pageNumber.name) ?? 1;
  }

  void setPageNumber(int value) {
    _prefs.setInt(PrefsEnum.pageNumber.name, value);
  }

  // ZOOM LEVEL
  double getZoomLevel() {
    return _prefs.getDouble(PrefsEnum.zoomLevel.name) ?? 1.0;
  }

  void setZoomLevel(double value) {
    _prefs.setDouble(PrefsEnum.zoomLevel.name, value);
  }

  // TAFSIR FONT SIZE
  double getTafsirFontSize() {
    return _prefs.getDouble(PrefsEnum.tafsirFontSize.name) ?? 20.0;
  }

  void setTafsirFontSize(double value) {
    _prefs.setDouble(PrefsEnum.tafsirFontSize.name, value);
  }

  // BOOKMARK
  int? getBookmark() {
    return _prefs.getInt(PrefsEnum.bookmark.name);
  }

  void setBookmark(int? value) {
    if (value == null) {
      _prefs.remove(PrefsEnum.bookmark.name);
      return;
    }
    _prefs.setInt(PrefsEnum.bookmark.name, value);
  }

  // LOCALE
  String getLocale() {
    return _prefs.getString(PrefsEnum.locale.name) ?? 'en';
  }

  void setLocale(String value) {
    LocaleSettings.setLocaleRaw(value);
    _prefs.setString(PrefsEnum.locale.name, value);
  }

  // RIWAYAH
  static String? getRiwayah() {
    return _prefs.getString(PrefsEnum.riwayah.name);
  }

  static void setRiwayah(String? value) {
    if (value == null) {
      _prefs.remove(PrefsEnum.riwayah.name);
      return;
    }
    _prefs.setString(PrefsEnum.riwayah.name, value);
  }

  // TAFSIR
  static List<Tafsir> getTafsirList() {
    final jsonList = _prefs.getStringList(PrefsEnum.tafsirList.name) ?? [];
    if (jsonList.isEmpty) return [];
    logger.fine('here');
    // Convert json to map, then to TafsirModel
    return jsonList
        .map(HelperFunctions.jsonDecodeSafe)
        .where((e) => e.isNotEmpty)
        .map((e) => Tafsir.fromJson(e))
        .toList();
  }

  static void setTafsirList(List<Tafsir> value) {
    _prefs.setStringList(
      PrefsEnum.tafsirList.name,
      value.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  static void addTafsir(Tafsir value) {
    final tafsirList = getTafsirList();
    if (tafsirList.any((element) => element.fileName == value.fileName)) return;
    tafsirList.add(value);
    setTafsirList(tafsirList);
  }

  static void removeTafsir(String value) {
    final tafsirList = getTafsirList();
    tafsirList.removeWhere((element) => element.fileName == value);
    setTafsirList(tafsirList);
  }
}
