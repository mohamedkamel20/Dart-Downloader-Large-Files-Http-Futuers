import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/handle_network.dart';
import '../data/multi_requests.dart';
import '../data/new_handler.dart';
import '../data/pool_http.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  DownloadManager? _downloadManager;
  final List<DownloadTaskk> _tasks = [
    DownloadTaskk(
      'https://flutter-interivew-afasdfa.b-cdn.net/32_4.mp3',
      'My file 8.mp3',
      0,
      0,
      0,
    ),
    // DownloadTask('https://flutter-interivew-afasdfa.b-cdn.net/32_1.mp3',
    //     'file6.mp3', 0, 0),
    // DownloadTask('https://www.example.com/file3.mp3', 'file3.mp3', 0, 0),
  ];

  // DownloadModel? downloadModel;
  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    if (bytes == 0) return '0${suffixes[0]}';
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  DownloadTaskk? taskModel;
  int? totalsize;
  MultiRequestsHttp? handleRequests;

  @override
  void initState() {
    _downloadManager = DownloadManager(
      _tasks,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DownloadStatus? status;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Files'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_tasks[index].filename),
                    subtitle: Column(
                      children: [
                        Text(
                            '${getFileSizeString(bytes: _tasks[index].totalsize)} totalsize downloaded'),
                        Text(
                            '${getFileSizeString(bytes: _tasks[index].downloadedBytes)} bytes downloaded'),
                        Text(
                            '${taskModel?.getDataa('downloadedBytes')} bytes downloaded'),
                        Text(
                            '${getFileSizeString(bytes: _tasks[index].endByte)} end downloaded'),
                        Text(
                            '${getFileSizeString(bytes: _tasks[index].startByte)} start downloaded'),
                        Text(
                            'downloadPercentage: ${taskModel?.downloadPercentage}'),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Text('Start'),
                  onPressed: () async {
                    // final stopwatch = Stopwatch()..start();
                    // status = DownloadStatus.started;

                    // await _downloadManager!.start();

                    await MultiRequestsHttp().start();
                    ['https://flutter-interivew-afasdfa.b-cdn.net/32_1.mp3'];
                    // debugPrint('doSomething() executed in ${stopwatch.elapsed}');
                    // final stopwatchh = Stopwatch()..start();
                    // debugPrint('doSomething() executed in ${stopwatchh.elapsed}');
                  },
                ),
                ElevatedButton(
                  child: const Text('Pause'),
                  onPressed: () {
                    for (var task in _tasks) {
                      _downloadManager!.pauseDownload(task);
                      debugPrint('passssssuse');
                    }
                  },
                ),
                ElevatedButton(
                  child: const Text('Resume'),
                  onPressed: () async {
                    status = DownloadStatus.resume;

                    for (var task in _tasks) {
                      _downloadManager!.reasumepauseDownload(task);
                    }

                    // if (task.status == DownloadStatus.pause) {}
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

enum DownloadStatus {
  started,
  pause,
  resume,
  cancel,
  downloading,
  completed;
}
