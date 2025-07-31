import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quran/providers/download_remote_data_source.dart';

final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  return DownloadRepository(ref.watch(downloadRemoteDataSourceProvider));
});

class DownloadRepository {
  const DownloadRepository(this.remoteDataSource);
  final DownloadRemoteDataSource remoteDataSource;

  // Download a list of images, each image is downloaded separately
  Future<void> downloadQuranPages({
    required String folderName,
    required void Function(int number) onProgress,
  }) async {

  }
}
