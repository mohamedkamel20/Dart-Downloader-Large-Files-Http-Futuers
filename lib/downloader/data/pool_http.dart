import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadTaskk {
  String url;
  String filename;
  int startByte;
  int endByte;
  int downloadedBytes = 0;
  bool isPaused = false;
  int totalsize;
  bool isResumed = false;
  bool isDownloadeing = false;
  int? downloadPercentage;
  // DownloadStatus status;

  DownloadTaskk(
    this.url,
    this.filename,
    this.startByte,
    this.endByte,
    this.totalsize,
  );
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt(
      'downloadedBytes',
      downloadedBytes,
    );
    prefs.setInt('totalsize', totalsize);
  }

  Future<int?> getDataa(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(name);
  }
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
    final file = File('$dir/${task.filename}');
    final exists = await file.exists();

    while (task.isPaused) {
      // if (task.isPaused == true) {
      await Future.delayed(const Duration(milliseconds: 30));
      await completer.future;
      debugPrint('${task.filename} downloaded pasued.');
      //   continue;
    }

//NOTE - I have added this line to check if file exists or not and is it completed or not
    if (exists && task.downloadedBytes == task.totalsize) {
      // File already exists, skip download
      debugPrint('${task.filename} already exists, skipping download.');
      return;
    }

    // Set up HTTP client

    if (task.isResumed) {
      request = await client.getUrl(Uri.parse(task.url));
      // response =await request.close();
      request.headers.set('Range', 'bytes=${task.downloadedBytes}-');
    } else {
      request = await client.getUrl(Uri.parse(task.url));
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
      await file.create(recursive: true);
      task.downloadedBytes = file.lengthSync();
    } else {
      // Unsupported HTTP status code
      debugPrint(
          'Error downloading ${task.filename}. HTTP status code: ${response.statusCode}');
      return;
    }

    // Download file in chunks and write to disk
    final output = file.openWrite(mode: FileMode.append);
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
    task.totalsize = int.parse(response.headers.value('content-length')!) +
        task.downloadedBytes;

    debugPrint('${task.filename} downloaded successfully.');
    debugPrint('responseee: ${response.headers}');
    prefs.setInt('totalsize', task.totalsize);

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
}
