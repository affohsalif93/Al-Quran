// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:equatable/equatable.dart';
// import 'package:sqflite/sqflite.dart';
//
// import 'package:quran/debug/logger.dart';
// import 'package:quran/utils/io.dart';
//
// class DatabaseModel extends Equatable {
//   final String fileName;
//   final Database database;
//
//   const DatabaseModel(this.fileName, this.database);
//
//   String get fullPath => getFullPath(fileName);
//
//   static String getFullPath(String fileName) {
//     return IO.joinFromSupportFolder(
//       'dbs',
//       '$fileName.db',
//     );
//   }
//
//   static Future<DatabaseModel> fromAsset(String fileName, String assetPath) async {
//     final fullPath = getFullPath(fileName);
//     final file = File(fullPath);
//     if (!file.existsSync()) {
//       final data = await rootBundle.load(assetPath);
//       final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//       await file.create(recursive: true);
//       await file.writeAsBytes(bytes, flush: true);
//     }
//
//     final db = await openDatabase(fullPath, readOnly: true);
//     return DatabaseModel(fileName, db);
//   }
//
//   @override
//   List<Object?> get props => [fileName];
// }
//
// enum DB {
//   quranAyahByAyah,
//   quranWordByWord,
//   quranDigital15Lines,
// }
//
// Map<DB, String> databaseFilenamesMap = {
//   DB.quranAyahByAyah: 'QPC_V1_aba',
//   DB.quranWordByWord: 'QPC_V1_wbw',
//   DB.quranDigital15Lines: 'digital-khatt-15-lines',
// };
//
// class QuranDBService {
//   static final Map<DB, String> _assetPaths = {
//     DB.quranAyahByAyah: 'assets/quran/db/QPC_V1_aba.db',
//     DB.quranWordByWord: 'assets/quran/db/QPC_V1_wbw.db',
//     DB.quranDigital15Lines: 'assets/quran/db/digital-khatt-15-lines.db',
//   };
//
//   static final Map<DB, DatabaseModel> _databases = {};
//
//   static Future<void> init() async {
//     for (var entry in _assetPaths.entries) {
//       final model = await DatabaseModel.fromAsset(databaseFilenamesMap[entry.key]!, entry.value);
//       _databases[entry.key] = model;
//       logger.fine('Loaded database: ${entry.key}');
//     }
//   }
//
//   static Database getDB(DB key) => _databases[key]!.database;
// }
