import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../data/new_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var fileDownloaderProvider =
        Provider.of<FileDownloaderProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text("File Downloading")),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                dowloadButton(fileDownloaderProvider),
                downloadProgress(),
                ElevatedButton(
                  child: const Text('Pause'),
                  onPressed: () {
                    setState(() {
                      // for (var task in _tasks) {
                      //   task.isPaused = true;
                      // }
                    });
                  },
                ),
                ElevatedButton(
                  child: const Text('Resume'),
                  onPressed: () {
                    setState(() {
                      // for (var task in _tasks) {
                      //   task.isPaused = false;
                      // }
                    });
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
              ]),
        ));
  }

  Widget dowloadButton(FileDownloaderProvider downloaderProvider) {
    return ElevatedButton(
      onPressed: () async {
        final stopwatch = Stopwatch()..start();

        // await NetworkHandler().downloadFile();
        // Handlerequests().resumeDownload();
        // FlutterDownloader.pause(taskId: 'taskId');

        // for (var i = 1; i < 101; i++) {
// iWonderHowLongThisTakes();
        await downloaderProvider
            .downloadFile(
                "https://flutter-interivew-afasdfa.b-cdn.net/32_1.mp3",
                "My File.mp3")
            .then((onValue) {});
        print('doSomething() executed in ${stopwatch.elapsed}');
        // }
      },
      child: const Text(
        "Download File",
      ),
    );
  }

  Widget downloadProgress() {
    var fileDownloaderProvider =
        Provider.of<FileDownloaderProvider>(context, listen: true);

    return Text(
      downloadStatus(fileDownloaderProvider),
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  downloadStatus(FileDownloaderProvider fileDownloaderProvider) {
    var retStatus = "";

    switch (fileDownloaderProvider.downloadStatus) {
      case DownloadStatus.Downloading:
        {
          retStatus =
              "Download Progress : ${fileDownloaderProvider.downloadPercentage}%";
        }
        break;
      case DownloadStatus.Completed:
        {
          retStatus = "Download Completed";
        }
        break;
      case DownloadStatus.NotStarted:
        {
          retStatus = "Click Download Button";
        }
        break;
      case DownloadStatus.Started:
        {
          retStatus = "Download Started";
        }
        break;
    }

    return retStatus;
  }
}
