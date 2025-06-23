import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/models/quran/line.dart';
import 'package:quran/providers/quran/quran_db_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:quran/models/tafsir_model.dart';
import 'package:quran/providers/shared_preferences_provider.dart';

final quranDataSourceProvider = Provider<QuranDataSource>((ref) {
  return const QuranDataSource();
});

class QuranDataSource {
  const QuranDataSource();


  Future<List<TafsirModel>> getTafsir(int chapter, int verse) async {
    List<TafsirModel> result = [];

    final tafsirList = SharedPreferencesService.getTafsirList();
    final tafsirDBs = [
      for (final tafsir in tafsirList)
        await QuranDBService.getTasfirDb(),
    ];

    for (var i = 0; i < tafsirList.length; i++) {
      final tafsir = tafsirList[i];
      final tafsirDB = tafsirDBs[i];
      final List<Map<String, dynamic>> results = await tafsirDB.query(
        'verses',
        where: 'sura = ? AND ayah = ?',
        whereArgs: [chapter, verse],
        limit: 1,
      );

      final tafsirData = results.firstOrNull ?? {};
      final String tafsirText =
          tafsirData.containsKey('text') ? tafsirData['text'] : '';

      result.add(tafsir.copyWith(tafsir: tafsirText));
    }

    return result;
  }
}
