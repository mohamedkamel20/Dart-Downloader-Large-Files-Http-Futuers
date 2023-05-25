// import 'dart:io';
// import 'package:download_task/download_task.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class DownloadTaskScreen extends StatefulWidget {
//   const DownloadTaskScreen({
//     super.key,
//   });

//   @override
//   _DownloadTaskScreenState createState() => _DownloadTaskScreenState();
// }

// class _DownloadTaskScreenState extends State<DownloadTaskScreen> {
//   bool _isDownloading = false;
//   bool _isPaused = false;
//   bool _isCanceled = false;
//   int _bytesReceived = 0;
//   int _contentLength = 0;
//   final task = DownloadTask.download(
//     Uri.parse(
//       'https://flutter-interivew-afasdfa.b-cdn.net/32_4.mp3',
//     ),
//     file: File("image.mp3"),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Download File'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             TextButton(
//               child: const Text('Download'),
//               onPressed: () {
//                 setState(() {
//                   _isDownloading = true;
//                 });
//                 downloadFile();
//                 setState(() {
//                   _isDownloading = false;
//                   _isPaused = false;
//                   _isCanceled = false;
//                 });
//               },
//             ),
//             const SizedBox(height: 20.0),
//             _isDownloading
//                 ? Column(
//                     children: <Widget>[
//                       Text(
//                         'Downloaded ${((_bytesReceived / _contentLength) * 100).toStringAsFixed(0)}%',
//                         style: const TextStyle(fontSize: 20.0),
//                       ),
//                       const SizedBox(height: 10.0),
//                       LinearProgressIndicator(
//                         value: _contentLength > 0
//                             ? _bytesReceived / _contentLength
//                             : 0,
//                       ),
//                       const SizedBox(height: 10.0),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: <Widget>[
//                           TextButton(
//                             child: Text(_isPaused ? 'Resume' : 'Pause'),
//                             onPressed: () {
//                               setState(() {
//                                 _isPaused = !_isPaused;
//                               });
//                             },
//                           ),
//                           TextButton(
//                             child: const Text('Cancel'),
//                             onPressed: () {
//                               setState(() {
//                                 _isCanceled = true;
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   )
//                 : Container(),
//           ],
//         ),
//       ),
//     );
//   }

//   Future downloadFile() async {
//     var request = http.Request('GET',
//         Uri.parse('https://flutter-interivew-afasdfa.b-cdn.net/32_1.mp3'));
//     var response = await http.Client().send(request);
//     _contentLength = response.contentLength ?? 0;
//     response.stream.listen((value) {
//       setState(() {
//         _bytesReceived += value.length;
//       });
//     });
//     var file = File('Myfile.mp3');
//     var bytesDownloaded = 0;
//     var buffer = List.filled(1024 * 1024, null, growable: true);

//     var fileStream = file.openWrite(mode: FileMode.append);

//     await for (var chunk in response.stream) {
//       if (_isCanceled) {
//         fileStream.close();
//         file.deleteSync();
//         return;
//       }

//       if (_isPaused) {
//         await Future.delayed(const Duration(seconds: 1));

//         continue;
//       }

//       bytesDownloaded += chunk.length;
//       _bytesReceived = bytesDownloaded;
//       var progress = bytesDownloaded / _contentLength;
//       fileStream.add(chunk);
//     }

//     await fileStream.flush();
//     await fileStream.close();
//   }
// }
