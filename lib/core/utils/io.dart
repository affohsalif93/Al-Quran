import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/core/enums/riwaya_enum.dart';
import 'package:quran/core/utils/logger.dart';


abstract class IO {
  static late String supportFolderPath;
  static late String colorImagesPath;
  static late String blackImagesPath;

  static Future<void> init() async {
    supportFolderPath = (await getApplicationSupportDirectory()).path;
    colorImagesPath = join(supportFolderPath, 'images', 'color');
    blackImagesPath = join(supportFolderPath, 'images', 'black');

      final dataFolderPath = join(supportFolderPath, 'data');
      final dataFolder = Directory(dataFolderPath);
      if (await dataFolder.exists()) {
        logger.fine("data folder found skipp extraction");
      } else {
        logger.fine("data folder not found, extracting...");
        await prepareAndExtractZip();
      }
  }

  static Future<void> prepareAndExtractZip() async {
    ByteData data = await rootBundle.load("assets/data.zip");

    final supportDir = await getApplicationSupportDirectory();
    final zipPath = join(supportDir.path, "data.zip");
    final extractedPath = join(supportDir.path);

    final file = File(zipPath);
    await file.writeAsBytes(data.buffer.asUint8List());
    logger.fine("Zip copied to supportDir");

    extractFileToDisk(zipPath, extractedPath);
    logger.fine("data.zip extracted to $supportDir/data/");

    await file.delete();
    logger.fine("data.zip deleted from $supportDir");
  }

  static String joinFromSupportFolder(String a, [String? b, String? c, ]) {
    return join(supportFolderPath, a, b, c);
  }

  static String joinPath(String a, [String? b, String? c]) {
    return join(a, b, c);
  }

  static String getPageName(int pageNumber) {
    return '$pageNumber.jpg';
  }

  static String getPageLocalPath(int pageNumber, String riwayah) {
    // final String? riwayahName = SharedPreferencesService.getRiwayah();
    // logger.error("Riwayah name: $riwayahName");
    return join(supportFolderPath, 'riwayah', "quran.$riwayah.low", getPageName(pageNumber));
  }

  static String getQuranDBPath(RiwayaEnum riwaya) {
    return join(
        supportFolderPath, 'quran_text', 'quran_${riwaya.quranTextDBName}.db');
  }

  // static String _pad(int number) {
  //   if (number < 10) {
  //     return '00$number';
  //   } else if (number < 100) {
  //     return '0$number';
  //   } else {
  //     return number.toString();
  //   }
  // }

  static Future<void> unzipRiwayah(String fileName) async {
    final inputFilePath = join(supportFolderPath, 'riwayah', '$fileName.zip');
    final outputDirectoryPath = join(supportFolderPath, 'riwayah');
    await extractFileToDisk(inputFilePath, outputDirectoryPath);

    // remove the zip file after extraction
    await File(inputFilePath).delete();
  }

  static Future<void> unzipTafsir(String fileName) async {
    final inputFilePath = join(supportFolderPath, 'tafsir', '$fileName.zip');
    final outputDirectoryPath = join(supportFolderPath, 'tafsir');
    await extractFileToDisk(inputFilePath, outputDirectoryPath);

    // remove the zip file after extraction
    await File(inputFilePath).delete();
  }

  static Future<void> removeTafsir(String fileName) async {
    final inputFilePath = join(supportFolderPath, 'tafsir', '$fileName.db');
    final file = File(inputFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
