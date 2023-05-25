import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mp3downloader/downloader/data/audio_player.dart';

import '../data/multi_requests.dart';
import 'audio_player_screen.dart';
// import '../data/pool_http.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  MultiRequestsHttp? handleRequests;
  bool pauseOrNot = false;

  // Future<List<DownloadModel>> getAllItems() async {
  //    DownloadModel? downloadModel;
  //   var client = Client();
  //   List<String> itemsIds = ['1', '2', '3']; //different ids

  //   List<Response> list = await Future.wait(
  //       itemsIds.map((itemId) => client.get('sampleapi/$itemId/next')));

  //   return list.map((response) {
  //     // do processing here and return items
  //     return downloadModel!;
  //   }).toList();
  // }

  DownloadModel? downloadmodel;
  // DownloadModel? downloadModel;
  // static String getFileSizeString({required int bytes, int decimals = 0}) {
  //   const suffixes = ["b", "kb", "mb", "gb", "tb"];
  //   if (bytes == 0) return '0${suffixes[0]}';
  //   var i = (log(bytes) / log(1024)).floor();
  //   return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  // }

  // DownloadTaskk? taskModel;
  // int? totalsize;
  DownloadStatus status = DownloadStatus.started;
  List<String> urlss = [];

  @override
  void initState() {
    // _downloadManager = DownloadManager(
    //   _tasks,
    // );
    // handleRequests = MultiRequestsHttp(
    //   status,
    //   downloadmodel,
    //   pauseOrNot,
    // );
    // controller = Get.put(MultiRequestsHttp(

    // ));
    for (int i = 1; i < 3; i++) {
      urlss.add('https://flutter-interivew-afasdfa.b-cdn.net/32_$i.mp3');
      downloadmodel = DownloadModel(
        urlss: urlss,
        // status: DownloadStatus.notStarted
        // isPaused: false,
      );
      continue;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // MultiRequestsHttp multiRequestsHttp = MultiRequestsHttp();
    final controller = Get.put(MultiRequestsHttp(downloadmodel!, false));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Files'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // downloadProgressWidget(handleRequests!),
            const SizedBox(height: 20),

            Obx(() => Text(controller.statuss.value)),

            const SizedBox(height: 20),

            Obx(() => Text("${controller.downloadPercntage.value}")),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Text('Start'),
                  onPressed: () async {
                    await controller.reasumeDownload();

                    await controller.startDownload(downloadmodel!);
                  },
                ),
                ElevatedButton(
                  child: const Text('Pause'),
                  onPressed: () async {
                    await controller.pauseDownload();
                  },
                ),
                ElevatedButton(
                  child: const Text('Resume'),
                  onPressed: () async {
                    await controller.reasumeDownload();

                    await controller.startDownload(downloadmodel!);
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
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Get.to(AudioPlayerScreen());
                },
                child: const Text('Play Screen'))
          ],
        ),
      ),
    );
  }

  // Widget downloadProgressWidget(MultiRequestsHttp requeststatues) {
  //   return Text(
  //     progressStatus(requeststatues),
  //     // downloadStatus(downloadModel),
  //     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //   );
  // }

  // String progressStatus(MultiRequestsHttp requeststatues) {
  //   String? status;
  //   downloadStatus(requeststatues).listen((event) {
  //     status = event;
  //   });
  //   // .then((value) => status = value);
  //   return status ?? "nulll";
  // }

  // String downloadStatus(MultiRequestsHttp requeststatues) {
  //   RxString retStatus = "".obs;

  //   switch (requeststatues.status.value) {
  //     case DownloadStatus.downloading:
  //       {
  //         retStatus.value =
  //             "Download Progress : ${requeststatues.downloadPercntage.value}%";
  //       }
  //       break;
  //     case DownloadStatus.completed:
  //       {
  //         retStatus.value = "Download Completed";
  //       }
  //       break;
  //     case DownloadStatus.notStarted:
  //       {
  //         retStatus.value = "Click Download Button";
  //       }
  //       break;
  //     case DownloadStatus.started:
  //       {
  //         retStatus.value = "Download Started";
  //       }
  //       break;
  //     case DownloadStatus.pause:
  //       {
  //         retStatus.value = 'Download Pause';
  //       }
  //       break;
  //     default:
  //       break;
  //   }

  //   return requeststatues.statuss.value = retStatus.value;
  // }
}

// enum DownloadStatus {
//   started,
//   pause,
//   resume,
//   cancel,
//   downloading,
//   completed;
// }

