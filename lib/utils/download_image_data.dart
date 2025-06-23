import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:quran/debug/logger.dart';
import 'package:quran/utils/io.dart';
import 'package:sqflite/sqflite.dart';

final dio = Dio();
final String _imagesBasePath = p.join(IO.supportFolderPath, 'images');

final Directory _commonDir = Directory(p.join(_imagesBasePath, 'common'));
final Directory _blackDir = Directory(p.join(_imagesBasePath, 'black'));
final Directory _colorDir = Directory(p.join(_imagesBasePath, 'color'));

Future<void> initImageDirectories() async {
  for (final dir in [_commonDir, _blackDir, _colorDir]) {
    if (!await dir.exists()) await dir.create(recursive: true);
  }
}

Future<void> runInBatches<T>(
    List<T> items,
    int batchSize,
    Future<void> Function(T item) handler,
    ) async {
  for (var i = 0; i < items.length; i += batchSize) {
    final batch = items.skip(i).take(batchSize);
    await Future.wait(batch.map(handler));
  }
}

Future<void> downloadMissingImages(Database db, {int batchSize = 2000, int concurrency = 16}) async {
  final rows = await db.query(
    'word_images',
    where: 'downloaded = ?',
    whereArgs: [0],
    limit: batchSize,
  );

  logger.fine('Found ${rows.length} images to download.');

  await runInBatches<Map<String, dynamic>>(rows, concurrency, (row) async {
    final String url = row['url'];
    final Uri uri = Uri.parse(url);

    final isCommon = url.contains('/w/common/');
    final fileName = uri.pathSegments.last;

    try {
      if (isCommon) {
        final File commonFile = File(p.join(_commonDir.path, 'verse_number$fileName'));
        if (!await commonFile.exists()) {
          await _downloadAndSave(uri, commonFile);

          final data = await commonFile.readAsBytes();
          await Future.wait([
            File(p.join(_blackDir.path, 'verse_number$fileName')).writeAsBytes(data),
            File(p.join(_colorDir.path, 'verse_number$fileName')).writeAsBytes(data),
          ]);

          logger.fine('📁 Duplicated to black and color: $fileName');
        }
      } else {
        final blackName = uri.pathSegments.skip(4).join('_');
        final blackFile = File(p.join(_blackDir.path, blackName));
        if (!await blackFile.exists()) {
          await _downloadAndSave(uri, blackFile);
        }

        final colorUrl = url.replaceFirst('/qa-black/', '/qa-color/');
        final colorUri = Uri.parse(colorUrl);
        final colorName = colorUri.pathSegments.skip(4).join('_');
        final colorFile = File(p.join(_colorDir.path, colorName));
        if (!await colorFile.exists()) {
          await _downloadAndSave(colorUri, colorFile);
        }
      }

      await db.update(
        'word_images',
        {'downloaded': 1},
        where: 'url = ?',
        whereArgs: [url],
      );
    } catch (e) {
      logger.warning('❌ Error handling image: $url: $e');
    }
  });

  logger.fine('✅ All images downloaded and organized.');
}

Future<void> _downloadAndSave(Uri url, File file) async {
  try {
    final response = await dio.get<List<int>>(
      url.toString(),
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200) {
      await file.writeAsBytes(response.data!);
      logger.fine('📥 Saved: ${file.path}');
    } else {
      logger.fine('❌ Failed to download ${url.toString()} [${response.statusCode}]');
    }
  } catch (e) {
    logger.fine('❌ Exception downloading ${url.toString()}: $e');
  }
}