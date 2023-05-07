// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// class DownloadTask {
//   String url;
//   String fileName;
//   String? savePath;
//   int downloadedBytes;
//   int totalBytes;
//   bool isPaused;

//   DownloadTask({
//     required this.url,
//     required this.fileName,
//     this.savePath,
//     this.downloadedBytes = 0,
//     this.totalBytes = 0,
//     this.isPaused = false,
//   });
// }

// class DownloadManager {
//   final List<DownloadTask> _tasks = [
//     DownloadTask(
//       fileName: 'audio.mp3',
//       url: 'https://flutter-interivew-afasdfa.b-cdn.net/32_4.mp3',
//     ),
//   ];

//   Future<void> startDownload({
//     required String url,
//     required String fileName,
//     String? savePath,
//     int startBytes = 0,
//     int endBytes = 0,
//   }) async {
//     final task = DownloadTask(
//       url: url,
//       fileName: fileName,
//       savePath: savePath,
//       downloadedBytes: startBytes,
//     );
//     final dir = Platform.isAndroid
//         ? '/sdcard/download'
//         : (await getApplicationDocumentsDirectory()).path;
//     task.savePath = dir;

//     savePath = dir;
//     final request = http.Request('GET', Uri.parse(url));
//     request.headers['range'] = 'bytes=$startBytes-$endBytes';

//     final response = await request.send();

//     task.totalBytes = int.parse(response.headers['content-length'] ?? '0');

//     final completer = Completer<void>();
//     final output = File(savePath).openWrite(
//         mode: startBytes == 0 ? FileMode.writeOnly : FileMode.writeOnlyAppend);

//     response.stream.listen((data) {
//       if (!task.isPaused) {
//         output.add(data);
//         task.downloadedBytes += data.length;
//       } else {
//         // Cancel or pause request
//         // request.abort();
//         output.close();
//         File(task.savePath!).deleteSync();
//         completer.complete();
//       }
//     }, onDone: () {
//       output.close();
//       completer.complete();
//     }, onError: (error) {
//       output.close();
//       File(task.savePath!).deleteSync();
//       completer.completeError(error);
//     });

//     await completer.future;
//     _tasks.remove(task);
//   }

//   Future<void> pauseDownload(DownloadTask task) async {
//     task.isPaused = true;
//   }

//   Future<void> resumeDownload(DownloadTask task) async {
//     task.isPaused = false;
//     await startDownload(
//       url: task.url,
//       fileName: task.fileName,
//       // savePath: task.savePath!,
//       startBytes: task.downloadedBytes,
//       endBytes: task.totalBytes,
//     );
//   }

//   Future<void> cancelDownload(DownloadTask task) async {
//     task.isPaused = true;
//     _tasks.remove(task);
//     File(task.savePath!).deleteSync();
//   }

//   void addTask(DownloadTask task) {
//     _tasks.add(task);
//   }

//   List<DownloadTask> get tasks => _tasks;
// }
