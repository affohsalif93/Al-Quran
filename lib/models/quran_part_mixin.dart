mixin QuranPartMixin {
  String get firstAyahKey;
  String get lastAyahKey;
  Map<String, String> get verseMapping;

  int get firstSurah => int.parse(firstAyahKey.split(':')[0]);
  int get firstAyah => int.parse(firstAyahKey.split(':')[1]);
  int get lastAyahSurah => int.parse(lastAyahKey.split(':')[0]);
  int get lastAyah => int.parse(lastAyahKey.split(':')[1]);
}
