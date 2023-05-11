import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadTaskk {
  String? url;
  List<String>? urlss;
  File? filename;
  int? startByte;
  // int endByte;
  int downloadedBytes = 0;
  bool isPaused = false;
  // int? totalsize;
  bool isResumed = false;
  // bool isDownloadeing = false;
  int? downloadPercentage;
  // DownloadStatus status;

  DownloadTaskk({
    this.url,
    this.urlss,
    this.filename,
    this.startByte,
    // this.endByte,
    // this.totalsize,
  });
  // Future<void> save() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   prefs.setInt(
  //     'downloadedBytes',
  //     downloadedBytes,
  //   );
  //   prefs.setInt('totalsize', totalsize!);
  // }

  // Future<int?> getDataa(String name) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getInt(name);
  // }
}

class DownloadManager {
  final List<DownloadTaskk> _tasks;
  // String byteRange;

  DownloadManager(
    this._tasks,
  );

  Future<void> start() async {
    for (var task in _tasks) {
      _downloadFile(task);
    }
  }

  Future<void> startDownload(DownloadTaskk downloadModel) async {
    final List<Future<void>> futures = [];

    final dir = Platform.isAndroid
        ? '/sdcard/download'
        : (await getApplicationDocumentsDirectory()).path;

    for (int i = 0; i < downloadModel.urlss!.length; i++) {
      final url = downloadModel.urlss![i];
      final fileName = _getFileNameFromUrl(url);
      final file = File('$dir/$fileName');

      debugPrint(
          'content Length: ${_getContentLength(url).then((value) => debugPrint('value of content length of $i: $value'))}}');

      // Check if the file exists and is complete
      if (await file.exists() &&
          await _isFileComplete(file.path, _getContentLength(url))) {
        debugPrint('File $fileName already exists and is complete');
        continue;
      }

      // File doesn't exist or is not complete, download it
      DownloadTaskk task = DownloadTaskk(
        url: url,
        filename: file,
        startByte: await file.exists() ? await file.length() : 0,
        // endByte: await _getContentLength(url),
        // totalsize: await _getContentLength(url),
      );

      final future = _downloadFile(task);
      futures.add(future);
    }

    // Wait for all downloads to complete
    await Future.wait(futures);
    // await Future.wait(getLentgth);
    debugPrint('Future length: ${futures.length}');
    debugPrint('Future finish');
  }

  Future<void> _downloadFile(DownloadTaskk task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final completer = Completer<void>();
    final client = HttpClient();
    HttpClientRequest request;
    HttpClientResponse response;
    final dir = Platform.isAndroid
        ? '/sdcard/download'
        : (await getApplicationDocumentsDirectory()).path;
    debugPrint("dir: $dir");
    final file = task.filename;
    // final exists = await file.exists();

    while (task.isPaused) {
      // if (task.isPaused == true) {
      await Future.delayed(const Duration(milliseconds: 30));
      await completer.future;
      debugPrint('${task.filename} downloaded pasued.');
      //   continue;
    }

//NOTE - I have added this line to check if file exists or not and is it completed or not
    // if (exists && task.downloadedBytes == task.totalsize) {
    //   // File already exists, skip download
    //   debugPrint('${task.filename} already exists, skipping download.');
    //   return;
    // }

    // Set up HTTP client

    if (task.isResumed) {
      request = await client.getUrl(Uri.parse(task.url!));
      // response =await request.close();
      request.headers.set('Range', 'bytes=${task.downloadedBytes}-');
    } else {
      request = await client.getUrl(Uri.parse(task.url!));
    }
    // request.headers.set('range', 'bytes= ${request.contentLength}-');

    // Send HTTP request and handle response
    response = await request.close();

    task.downloadPercentage =
        (task.downloadedBytes / response.contentLength * 100).round();

    if (response.statusCode == HttpStatus.partialContent) {
      // Download is resuming from where it left off
    } else if (response.statusCode == HttpStatus.ok) {
      // New download
      await file!.create(recursive: true);
      task.downloadedBytes = file.lengthSync();
    } else {
      // Unsupported HTTP status code
      debugPrint(
          'Error downloading ${task.filename}. HTTP status code: ${response.statusCode}');
      return;
    }

    // Download file in chunks and write to disk
    final output = file!.openWrite(mode: FileMode.append);
    // final fileSize = await file.length();
    response.listen((data) async {
      if (!task.isPaused) {
        output.add(data);

        task.downloadedBytes = file.lengthSync();
      } else {
        task.downloadedBytes = file.lengthSync();
        prefs.setInt('downloadedBytes', task.downloadedBytes);
        // task.totalsize = response.contentLength;

        debugPrint('Download of ${task.filename} is paused.');
      }
    }, onDone: () {
      output.close();
      completer.complete();
      task.isPaused = true;
    }, onError: (error) {
      output.close();
      file.deleteSync();
      completer.completeError(error);
      task.isPaused = true;
    });

    await completer.future;
    // task.totalsize = int.parse(response.headers.value('content-length')!) +
    //     task.downloadedBytes;

    debugPrint('${task.filename} downloaded successfully.');
    debugPrint('responseee: ${response.headers}');
    // prefs.setInt('totalsize', task.totalsize!);

    // prefs.setInt('downloadedBytes', task.downloadedBytes);
  }

  void pauseDownload(DownloadTaskk task) {
    task.isPaused = true;
  }

  void reasumepauseDownload(DownloadTaskk task) {
    task.isPaused = false;
    task.isResumed = true;
    _downloadFile(task);
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
}
