// import 'package:flutter/material.dart';
// import 'package:quran/models/ayah_model.dart';
// import 'package:quran/views/home/viewer/quran_word.dart';
//
// class AyahWidget extends StatelessWidget {
//   final Ayah verse;
//   final double fontSize;
//   final int pageNumber;
//
//   const AyahWidget({
//     super.key,
//     required this.verse,
//     required this.fontSize,
//     required this.pageNumber,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final words = verse.spans;
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Wrap(
//         textDirection: TextDirection.rtl,
//         children: words.map((word) {
//           return WordWidget(
//             pageNumber: pageNumber,
//             word: word,
//             fontSize: fontSize,
//             onTap: () {
//               // Provide context: verse, word location
//               debugPrint("Tapped word in ${verse.surah}:${verse.ayah} ");
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
// }