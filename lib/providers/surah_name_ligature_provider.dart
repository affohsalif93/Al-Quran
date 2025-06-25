import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/models/quran/surah_name_ligature.dart';
import 'package:quran/services/surah_name_ligature_service.dart';

final surahNameLigatureProvider = Provider<SurahNameLigature>((ref) {
  return SurahNameLigature(
    names: SurahNameLigatureService.shortNamesLigature,
    headers: SurahNameLigatureService.headersLigature,
  );
});
