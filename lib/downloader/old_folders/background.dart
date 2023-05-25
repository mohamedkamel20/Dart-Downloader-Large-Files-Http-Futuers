// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// class DownloadUI extends StatefulWidget {
//   final String url;
//   final String fileName;

//   const DownloadUI({super.key, required this.url, required this.fileName});

//   @override
//   _DownloadUIState createState() => _DownloadUIState();
// }

// class _DownloadUIState extends State<DownloadUI> {
//   late File _file;
//   late bool _isDownloading;
//   late bool _isPaused;
//   late int _receivedBytes;
//   late int _totalBytes;

//   late http.StreamedResponse _response;
//   late http.Client _httpClient;
//   late StreamSubscription<List<int>> _streamSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _file = File(widget.fileName);
//     _isDownloading = false;
//     _isPaused = false;
//     _receivedBytes = 0;
//     _totalBytes = 0;
//     _httpClient = http.Client();
//   }

//   @override
//   void dispose() {
//     _httpClient.close();
//     super.dispose();
//   }

//   Future<void> _startDownload() async {
//     setState(() {
//       _isDownloading = true;
//       _isPaused = false;
//     });
//     final dir = Platform.isAndroid
//         ? '/sdcard/download'
//         : (await getApplicationDocumentsDirectory()).path;
//     setState(() {
//       final file = File('$dir/${widget.fileName}');
//     });

//     _response =
//         await _httpClient.send(http.Request('GET', Uri.parse(widget.url)));
//     _totalBytes = int.parse(_response.headers['content-length']!);

//     _streamSubscription = _response.stream.listen((data) {
//       setState(() {
//         if (_isPaused) {
//           _streamSubscription.pause();
//         } else {
//           _receivedBytes += data.length;
//           _file.writeAsBytesSync(data, mode: FileMode.append);
//         }
//       });
//     }, onError: (error) {
//       setState(() {
//         _isDownloading = false;
//         _isPaused = false;
//       });
//     }, onDone: () {
//       setState(() {
//         _isDownloading = false;
//         _isPaused = false;
//       });
//     });
//   }

//   void _pauseDownload() {
//     setState(() {
//       _isPaused = true;
//     });
//   }

//   void _resumeDownload() {
//     setState(() {
//       _isPaused = false;
//     });
//     _streamSubscription.resume();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Download Example'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(_isDownloading ? 'Downloading...' : 'Downloaded'),
//             const SizedBox(height: 16.0),
//             LinearProgressIndicator(
//               value: _totalBytes > 0 ? _receivedBytes / _totalBytes : null,
//             ),
//             const SizedBox(height: 16.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _isDownloading
//                     ? ElevatedButton(
//                         onPressed: _pauseDownload,
//                         child: const Text('Pause'),
//                       )
//                     : const SizedBox.shrink(),
//                 const SizedBox(width: 16.0),
//                 _isPaused
//                     ? ElevatedButton(
//                         onPressed: _resumeDownload,
//                         child: const Text('Resume'),
//                       )
//                     : const SizedBox.shrink(),
//                 const SizedBox(width: 16.0),
//                 ElevatedButton(
//                   onPressed: !_isDownloading ? _startDownload : null,
//                   child: const Text('Download'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
