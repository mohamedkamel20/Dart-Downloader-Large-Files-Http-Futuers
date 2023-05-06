import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class DownloadModel {
//   String url;
//   String filename;
//   String filePath;
//   List<String> urls;
//   int startByte;
//   int endByte;
//   int downloadedBytes = 0;
//   bool isPaused = false;
//   int totalsize;
//   bool isResumed = false;
//   bool isDownloadeing = false;
//   int? downloadPercentage;
//   // DownloadStatus status;

//   DownloadModel(
//     this.url,
//     this.filename,
//     this.urls,
//     this.filePath,
//     this.startByte,
//     this.endByte,
//     this.totalsize,
//   );
//   Future<void> save() async {
//     final prefs = await SharedPreferences.getInstance();

//     prefs.setInt(
//       'downloadedBytes',
//       downloadedBytes,
//     );
//     prefs.setInt('totalsize', totalsize);
//   }

//   Future<int?> getDataa(String name) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getInt(name);
//   }
// }

class MultiRequestsHttp {
  // final List<DownloadModel> _tasks;

  // MultiRequestsHttp(this._tasks);

  Future<void> start() async {
    // List<String>? listUrls;
    // for (int i = 1; i < 4; i++) {
    List<String> listUrls = [
      'https://flutter-interivew-afasdfa.b-cdn.net/32_4.mp3'
          'https://flutter-interivew-afasdfa.b-cdn.net/32_2.mp3'
    ];

    // for (var task in _tasks) {
    // task.urls.add(listUrls);
    // }
    // }
    // Future.wait(
    downloadFiles(listUrls);

    // );
  }

  Future<void> downloadFiles(List<String> urls) async {
    final List<Future<void>> futures = [];
    final List<Future<void>> getLentgth = [];
    final dir = Platform.isAndroid
        ? '/sdcard/download'
        : (await getApplicationDocumentsDirectory()).path;

    for (int i = 0; i < urls.length; i++) {
      final url = urls[i];
      final fileName = _getFileNameFromUrl(url);
      final file = File('$dir/$fileName');
      debugPrint(
          'content Length: ${_getContentLength(url).then((value) => debugPrint('value of content length: $value'))}}');
      // double totlaSize = await _getContentLength(urls);
      // Check if the file exists and is complete
      if (await file.exists() &&
          await _isFileComplete(file.path, _getContentLength(url))) {
        debugPrint('File $fileName already exists and is complete');
        continue;
      }

      // File doesn't exist or is not complete, download it
      final getFuturesLentgth = _getContentLength(url);
      final future = _downloadFiles(url, file, i, false);
      futures.add(future);
      getLentgth.add(getFuturesLentgth);
    }

    // Wait for all downloads to complete
    await Future.wait(futures);
    await Future.wait(getLentgth);
    debugPrint('Future length: ${futures.length}');
    debugPrint('Future finish');
  }

  Future<void> _downloadFiles(
      String url, File file, int index, bool isDownloadPasued) async {
    final startByte = await file.exists() ? file.lengthSync() : 0;
    final request = await HttpClient().getUrl(Uri.parse(url));

    if (startByte > 0) {
      request.headers.set('range', 'bytes=$startByte-');
    }
    final response = await request.close();
    final completer = Completer<void>();
    final output = file.openWrite(mode: FileMode.writeOnlyAppend);

    // Set startByte and endByte for resuming download
    debugPrint("pathh: ${file.path}");
    if (response.statusCode == HttpStatus.partialContent) {
      // Download is resuming from where it left off
    } else if (response.statusCode == HttpStatus.ok) {
      // New download
      await file.create(recursive: true);
      // task.downloadedBytes = file.lengthSync();
    } else {
      // Unsupported HTTP status code
      debugPrint(
          'Error downloading ${file.path}. HTTP status code: ${response.statusCode}');
      return;
    }

    response.listen((data) {
      if (!isDownloadPasued) {
        output.add(data);
        // task.downloadedBytes += data.length;
      } else {
        // Cancel or pause request
        request.abort();
        output.close();
        file.deleteSync();
        completer.complete();
      }
    }, onDone: () {
      output.close();
      completer.complete();
    }, onError: (error) {
      output.close();
      file.deleteSync();
      completer.completeError(error);
    });

    await completer.future;

    debugPrint('File $index downloaded successfully');
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
      // }
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
}
// Future<void> start(List<String> urls) async {
//     double totalSize = await _getContentLength(urls);
//     print('Total size: $totalSize');

//     List<Future<File>> downloadFutures = [];
//     for (String url in urls) {
//       downloadFutures.add(downloadFiles(urls));
//     }

//     List<File> downloadedFiles = await Future.wait(downloadFutures);

//     // Check that all files have been downloaded completely
//     bool allComplete = false;
//     while (!allComplete) {
//       allComplete = true;
//       for (File file in downloadedFiles) {
//         int fileSize = await file.length();
//         if (fileSize < totalSize) {
//           allComplete = false;
//           await Future.delayed(Duration(seconds: 1));
//           break;
//         }
//       }
//     }

//     print('All files downloaded completely!');
//   }