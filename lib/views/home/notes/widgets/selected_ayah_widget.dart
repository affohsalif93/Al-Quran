import 'package:flutter/material.dart';
import 'package:quran/assets/fonts.gen.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/models/quran/ayah_model.dart';
import 'package:quran/repositories/quran/static_quran_data.dart';

class SelectedAyahWidget extends StatelessWidget {
  final Ayah ayah;

  const SelectedAyahWidget({super.key, required this.ayah});

  @override
  Widget build(BuildContext context) {
    final ayahReference =
        'Surah ${StaticQuranData.getSurah(ayah.surah).englishName}, Ayah ${ayah.ayah}';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        children: [
          Text(ayahReference, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          SizedBox(height: 10),
          Text(
            ayah.text,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 22,
              fontFamily: FontFamily.uthmanicHafs,
              color: Colors.black,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
