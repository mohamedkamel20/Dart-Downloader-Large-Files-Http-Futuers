// import 'dart:convert';
// import 'dart:io';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:uuid/uuid.dart';

// class DownloadManager {
//   List<DownloadTask> _tasks = [];
//   int _totalSize = 0;

//   Future<void> download(List<String> urls) async {
//     // Calculate total size of all urls
//     await Future.forEach(urls, (url) async {
//       var response = await http.head(Uri.parse(url));
//       _totalSize += int.parse(response.headers['content-length'] ?? '0');
//     });

//     // Request to download all urls
//     await Future.forEach(urls, (url) async {
//       var task = DownloadTask(url, _totalSize);
//       _tasks.add(task);
//       await task.download();
//     });

//     // Save downloaded urls with ids
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/urls.json');
//     var jsonList =
//         _tasks.map((task) => {'id': task.id, 'url': task.url}).toList();
//     await file.writeAsString(jsonEncode(jsonList));
//   }
// }

// class DownloadTask {
//   String? id;
//   String url;
//   int totalSize;
//   int downloadedBytes = 0;
//   bool isPaused = false;

//   DownloadTask(this.url, this.totalSize) {
//     id = Uuid().v1();
//   }

//   Future<void> download() async {
//     final response = await http.get(Uri.parse(url),
//         headers: {'Range': 'bytes=$downloadedBytes-$totalSize'});
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/$id.mp3');
//     final output = file.openWrite(mode: FileMode.append);

//     await response.stream.forEach((data) {
//       if (!isPaused) {
//         output.add(data);
//         downloadedBytes += data.length;
//       } else {
//         // Cancel or pause request
//         output.close();
//         file.deleteSync();
//         throw Exception('Request has been paused or cancelled');
//       }
//     });

//     await output.close();
//   }

//   void pause() {
//     isPaused = true;
//   }

//   void resume() async {
//     isPaused = false;
//     await download();
//   }
// }
