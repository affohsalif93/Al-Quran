import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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

  static String fromSupportFolder(String a, [String? b, String? c, ]) {
    return join(supportFolderPath, a, b, c);
  }

  static String fromDbsFolder(String a, [String? b, String? c, ]) {
    return join(supportFolderPath, "data", "dbs", a, b, c);
  }

  static String fromMetadataFolder(String a, [String? b, String? c, ]) {
    return join(supportFolderPath, "data", "metadata", a, b, c);
  }

  static String joinPath(String a, [String? b, String? c]) {
    return join(a, b, c);
  }
}
