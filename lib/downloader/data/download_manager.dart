import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:path_provider/path_provider.dart';

//
enum DownloadStatus { notStarted, started, downloading, completed, pause }

class DownloadManager extends GetxController {
  final List<String> _listOfUrls = [];

  RxBool isPause = false.obs;
  RxInt downloadPercentage = 0.obs;
  RxDouble totalcontentLength = 0.0.obs;
  RxString statuss = 'Start Download Now'.obs;
  List<String> get listOfUrls => _listOfUrls;
  RxBool checIfdownloadCompelete = false.obs;
  double contentLength = 0.0;

  @override
  void onInit() {
    super.onInit();

    getUrls();
  }

  void getUrls() async {
    for (int i = 1; i < 4; i++) {
      _listOfUrls.add('https://flutter-interivew-afasdfa.b-cdn.net/32_$i.mp3');
    }

    debugPrint('urlsss :: ${_listOfUrls.toString()}');
  }

  Future<void> startDownload() async {
    final List<Future<void>> futures = [];

    final dir = Platform.isAndroid
        ? '/storage/emulated/0/Download'
        : (await getApplicationDocumentsDirectory()).path;

    for (int i = 0; i < _listOfUrls.length; i++) {
      final url = _listOfUrls[i];
      debugPrint('url: $url');
      final fileName = _getFileNameFromUrl(url);
      final file = File('$dir/$fileName');
      contentLength += await _getContentLength(url);
      debugPrint('total content length: $contentLength');

      debugPrint(
          'content Length: ${_getContentLength(url).then((value) => debugPrint('value of content length of $i: $value'))}}');

      // Check if the file exists and is complete
      if (await file.exists() &&
          await _isFileComplete(file.path, _getContentLength(url))) {
        debugPrint('File $fileName already exists and is complete');
        debugPrint('File ${file.path} already exists and is complete');

        checIfdownloadCompelete.value = true;
        continue;
      }

      final future = downloadFiles(url, file);

      futures.add(future);
      debugPrint('Future length: ${futures.length}');
      debugPrint('Future started');
    }
    // progressBarByFutures(futures, (completed, total) {});

    // Wait for all downloads to complete
    await Future.wait(futures);
    debugPrint('Future completed');
    checIfdownloadCompelete.value = true;

    debugPrint(checIfdownloadCompelete.value.toString());
  }

  Future<void> downloadFiles(String url, File savePath) async {
    final httpClient = HttpClient();
    late final StreamSubscription subscription;
    final completer = Completer<void>();

    try {
      final request = await httpClient.getUrl(
        Uri.parse(url),
      );
      int startByte = await savePath.exists() ? savePath.lengthSync() : 0;
      if (startByte > 0) {
        request.headers.set('Range', 'bytes=$startByte-');
      }

      final response = await request.close();
      final output = savePath.openWrite(mode: FileMode.writeOnlyAppend);

      totalcontentLength.value = contentLength;
      int totladownloaded = 0;
      debugPrint('total download is ::: = ${totalcontentLength.value}');

      subscription = response.listen((data) async {
        if (!isPause.value) {
          output.add(data);

          totladownloaded += data.length;

          // Download Percentage
          downloadPercentage.value =
              ((totladownloaded / totalcontentLength.value) * 100).round();
          startByte += data.length;

          statuss.value = 'Downloading...';

          debugPrint('Download in progress');
        } else {
          subscription.pause();

          debugPrint('Download paused');

          statuss.value = 'Paused';

          request.close();
        }
      }, onDone: () {
        completer.complete();
        debugPrint('Download success');

        statuss.value = 'Download Completed';

        output.close();

        request.close();
      }, onError: (error) {
        completer.completeError(error);

        subscription.cancel();
        statuss.value = 'Download Canceld';
      });
      // await subscription.cancel();
      return await completer.future;
    } catch (error) {
      debugPrint(' downloading error = $error');
      return await completer.future;
    }
  }

  Future<bool> pauseDownload() async {
    return isPause.value = true;
  }

  Future<bool> reasumeDownload() async {
    return isPause.value = false;
  }

  Future<double> _getContentLength(String url) async {
    int contentLength = 0;
    // for (var url in urls) {
    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();
    contentLength = response.contentLength + contentLength;
    try {
      if (response.statusCode != 200) {
        throw Exception('Failed to get content length for $url');
      }

      if (contentLength == 0) {
        throw Exception('Failed to get content length for $url');
      }

      return double.parse(contentLength.toString());
    } catch (e) {
      debugPrint('error: $e');
      return 0;
    }
  }

  String _getFileNameFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String path = uri.path;
    return path.substring(path.lastIndexOf('/') + 1);
  }

  Future<bool> _isFileComplete(String path, Future<double> expectedSize) async {
    final file = File(path);

    if (!file.existsSync() || file.lengthSync() != await expectedSize) {
      return false;
    }

    return true;
  }

  Future<void> deleteAudioFiles(String folderPath) async {
    try {
      final directory = Directory(folderPath);
      if (await directory.exists()) {
        final files = directory.listSync(recursive: false);
        for (final file in files) {
          if (file is File && file.path.endsWith('.mp3')) {
            await file.delete();
          }
        }
        debugPrint('Audio files deleted successfully');
      } else {
        debugPrint('Folder does not exist');
      }
    } catch (e) {
      debugPrint('Error deleting audio files: $e');
    }
  }

  Future<List<T>> progressBarByFutures<T>(List<Future<T>> futures,
      void Function(int completed, int total) progress) {
    int total = futures.length;
    int completed = 0;
    void complete() {
      completed++;
      progress(completed, total);
      // downloadPercentage.value = ((completed / total) * 100).round();
    }

    return Future.wait<T>(
        [for (var future in futures) future.whenComplete(complete)]);
  }
}
