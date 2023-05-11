import 'dart:io';
import 'dart:math';

import 'package:download_task/download_task.dart';
import 'package:flutter/material.dart';

import '../data/multi_requests.dart';
// import '../data/pool_http.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  // DownloadManager? _downloadManager;
  // final List<DownloadTaskk> _tasks = [
  //   DownloadTaskk(
  //     'https://flutter-interivew-afasdfa.b-cdn.net/32_4.mp3',
  //     'My file 8.mp3',
  //     0,
  //     0,
  //     0,
  //   ),
  // DownloadTask('https://flutter-interivew-afasdfa.b-cdn.net/32_1.mp3',
  //     'file6.mp3', 0, 0),
  // DownloadTask('https://www.example.com/file3.mp3', 'file3.mp3', 0, 0),
  // ];
  MultiRequestsHttp? handleRequests;
  bool pauseOrNot = false;

  final DownloadModel downloadmodel = DownloadModel(
    //  url : 'https://flutter-interivew-afasdfa.b-cdn.net/32_4.mp3',
    urlss: [
      'https://flutter-interivew-afasdfa.b-cdn.net/32_4.mp3',
      'https://flutter-interivew-afasdfa.b-cdn.net/32_1.mp3',
      'https://flutter-interivew-afasdfa.b-cdn.net/32_1.mp3',
      'https://flutter-interivew-afasdfa.b-cdn.net/32_5.mp3'
    ],
    // isPaused: false,
  );
  // DownloadModel? downloadModel;
  // static String getFileSizeString({required int bytes, int decimals = 0}) {
  //   const suffixes = ["b", "kb", "mb", "gb", "tb"];
  //   if (bytes == 0) return '0${suffixes[0]}';
  //   var i = (log(bytes) / log(1024)).floor();
  //   return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  // }

  // DownloadTaskk? taskModel;
  // int? totalsize;

  @override
  void initState() {
    // _downloadManager = DownloadManager(
    //   _tasks,
    // );
    handleRequests = MultiRequestsHttp(
      downloadmodel,
      pauseOrNot,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // DownloadStatus? status;
    // MultiRequestsHttp multiRequestsHttp = MultiRequestsHttp();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Files'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Text('Start'),
                  onPressed: () async {
                    // final stopwatch = Stopwatch()..start();
                    // status = DownloadStatus.started;

                    // await _downloadManager!.start();

                    // await handleRequests!.startDownload(downloadmodel);
                    await handleRequests!.startDownload(downloadmodel);

                    // ['https://flutter-interivew-afasdfa.b-cdn.net/32_1.mp3'];
                    // debugPrint('doSomething() executed in ${stopwatch.elapsed}');
                    // final stopwatchh = Stopwatch()..start();
                    // debugPrint('doSomething() executed in ${stopwatchh.elapsed}');
                  },
                ),
                ElevatedButton(
                  child: const Text('Pause'),
                  onPressed: () async {
                    // await handleRequests!.startDownload(downloadmodel);

                    // MultiRequestsHttp(
                    //     downloadModel: downloadmodel, isPause: true);
                    // setState(() {
                    //   pauseOrNot = true;
                    // });

                    await handleRequests!.pauseDownload();

                    // .pauseDownload();
                  },
                ),
                ElevatedButton(
                  child: const Text('Resume'),
                  onPressed: () async {
                    // multiRequestsHttp.status = DownloadStatus.resume;
                    await handleRequests!.reasumeDownload();

                    await handleRequests!.startDownload(downloadmodel);
                  },
                ),
                ElevatedButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    // setState(() {
                    //   _downloadManager!.cancel();
                    //   _tasks.forEach((task) => task.downloadedBytes = 0);
                    // });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// enum DownloadStatus {
//   started,
//   pause,
//   resume,
//   cancel,
//   downloading,
//   completed;
// }
