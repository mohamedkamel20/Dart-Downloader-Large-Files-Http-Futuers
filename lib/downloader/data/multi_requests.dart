import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:path_provider/path_provider.dart';

class DownloadModel extends GetxController {
  String? url;
  List<String> urlss;

  File? savePath;
  int downloadedBytes;
  double totalBytes;
  bool? isPaused;
  StreamSubscription<List<int>>? streamSubscription;
  bool? isReasumed;
  int? downloadPercentage;
  DownloadStatus? status;

  DownloadModel({
    this.url,
    required this.urlss,
    this.savePath,
    this.streamSubscription,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.isReasumed = false,
    this.isPaused,
    this.status,
  });
}

enum DownloadStatus { notStarted, started, downloading, completed, pause }

class MultiRequestsHttp extends GetxController {
  // final status = DownloadStatus.notStarted.obs;
  // Rx<DownloadStatus> status = DownloadStatus.notStarted.obs;
  RxString statuss = 'Start Download Now'.obs;
  bool isPause;
  DownloadModel downloadModel;
  RxInt downloadPercntage = 0.obs;
  double totalcontentLength = 0;
  MultiRequestsHttp(
    this.downloadModel,
    this.isPause,
  );

  // Future<void> start() async {
  //   DownloadModel task = downloadModel;
  //   _ddownloadFile(task);
  // }

  Future<void> startDownload(DownloadModel downloadModel) async {
    final List<Future<void>> futures = [];

    final dir = Platform.isAndroid
        ? '/storage/emulated/0/Download'
        : (await getApplicationDocumentsDirectory()).path;

    // ? StorageDirectory.documents
    for (int i = 0; i < downloadModel.urlss.length; i++) {
      final url = downloadModel.urlss[i];
      debugPrint('url: $url');
      final fileName = _getFileNameFromUrl(url);
      final file = File('$dir/$fileName');
      totalcontentLength += await _getContentLength(url);
      debugPrint('total content length: $totalcontentLength');

      debugPrint(
          'content Length: ${_getContentLength(url).then((value) => debugPrint('value of content length of $i: $value'))}}');

      // Check if the file exists and is complete
      if (await file.exists() &&
          await _isFileComplete(file.path, _getContentLength(url))) {
        debugPrint('File $fileName already exists and is complete');
        debugPrint('File ${file.path} already exists and is complete');
        continue;
      }

      // File doesn't exist or is not complete, download it
      DownloadModel task = DownloadModel(
        url: url,
        urlss: downloadModel.urlss,
        savePath: file,
      );

      // final future = _downloadPackage(url, file, TaskEvent(state: event));
      final future = _ddownloadFile(task);

      futures.add(future);
      debugPrint('Future length: ${futures.length}');
      debugPrint('Future started');
      // progressWait(futures, (completed, total) {});

      // debugPrint('future length : ${futures.length}');
    }

    // Wait for all downloads to complete
    await Future.wait(futures);
  }

  // Future<List<T>> progressWait<T>(List<Future<T>> futures,
  //     void Function(int completed, int total) progress) {
  //   int total = futures.length;
  //   int completed = 0;
  //   void complete() {
  //     completed++;
  //     progress(completed, total);
  //     debugPrint('completed: $completed');
  //     downloadPercntage = (completed.obs / total * 100).round().obs;
  //   }

  //   return Future.wait<T>(
  //       [for (var future in futures) future.whenComplete(complete)]);
  // }

  Future<void> _ddownloadFile(DownloadModel downloadModel) async {
    final httpClient = HttpClient();
    late final StreamSubscription subscription;
    final completer = Completer<void>();

    // final completer = Completer<void>();
    // List<String> urlId = ['1', '2', '3'];
    // Future.wait(urlId.map((itemId) => _getContentLength(downloadModel.urlss[itemId]))).then((value) => debugPrint('value of content length of $itemId: $value'));
    // final request = await Future.wait(urlId.map((e) => httpClient.getUrl(
    //       Uri.parse(downloadModel.url!),
    //     )));
    // HttpClientResponse? responseee;
    // final responsee =
    //     request.map((e) async => responseee = e.close() as HttpClientResponse);
    try {
      final request = await httpClient.getUrl(
        Uri.parse(downloadModel.url!),
      );
      int startByte = await downloadModel.savePath!.exists()
          ? downloadModel.savePath!.lengthSync()
          : 0;
      if (startByte > 0) {
        request.headers.set('Range', 'bytes=$startByte-');
        // request.map((e) => e.headers.set('Range', 'bytes=$startByte-'));
      }

      // final response = request.map((e) async => await e.close());
      final response = await request.close();

      // final bytes = await consolidateHttpClientResponseBytes(response);

      // await downloadModel.savePath!.writeAsBytes(bytes, mode: FileMode.append);
      final output =
          downloadModel.savePath!.openWrite(mode: FileMode.writeOnlyAppend);

      debugPrint('downloaded file path = ${downloadModel.savePath!.path}');
      int totladownloaded = 0;

      subscription = response.listen((data) async {
        if (!isPause) {
          output.add(data);
          // startByte += data.length;
          totladownloaded += data.length;
          // totalcontentLength += response.contentLength;
          // totalcontentLength++;
          downloadPercntage.value =
              (totladownloaded / totalcontentLength * 100).round();
          debugPrint(' download Perentage: $downloadPercntage ');
          debugPrint(' total Downloaded: $totladownloaded ');
          // downloadPercntage.listen((p0) {});

          // status.value = DownloadStatus.downloading;
          statuss.value = 'Downloading...';

          // debugPrint(
          //     'download percentage = ${downloadModel.downloadPercentage}');
          // startByte = output.;
          debugPrint('Download in progress');
        } else {
          subscription.pause();
          debugPrint('Download paused');
          // status.value = DownloadStatus.pause;
          statuss.value = 'Paused';

          // await Future.delayed(const Duration(seconds: 10));
          // httpClient.connectionTimeout = const Duration(minutes: 5);
          request.close();
        }
      }, onDone: () {
        completer.complete();
        debugPrint('Download success');
        // status.value = DownloadStatus.completed;
        statuss.value = 'Download Completed';

        output.close();

        request.close();
      }, onError: (error) {
        completer.completeError(error);

        subscription.cancel();
        statuss.value = 'Download Canceld';
      });
      // await subscription.cancel();
      return await completer.future;
    } catch (error) {
      debugPrint(' downloading error = $error');
      return await completer.future;
    }
  }

  Future<bool> pauseDownload() async {
    return isPause = true;
  }

  Future<bool> reasumeDownload() async {
    return isPause = false;
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

  // Future<int> getAllcontentSize(
  //   List<String> urls,
  // ) async {
  //   int contentLength = 0;
  //   for (var url in urls) {
  //     final request = await HttpClient().getUrl(Uri.parse(url));
  //     final response = await request.close();
  //     contentLength = response.contentLength + contentLength;
  //   }
  //   debugPrint('totla content length: $contentLength');
  //   return contentLength;
  // }

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
  // void oninit(){
  // bool pauseOrNot = false;

  //   final DownloadModel downloadmodel = DownloadModel(
  //   //  url : 'https://flutter-interivew-afasdfa.b-cdn.net/32_4.mp3',
  //   urlss: [
  //     'https://flutter-interivew-afasdfa.b-cdn.net/32_4.mp3',
  //     'https://flutter-interivew-afasdfa.b-cdn.net/32_1.mp3',
  //     'https://flutter-interivew-afasdfa.b-cdn.net/32_2.mp3',
  //     'https://flutter-interivew-afasdfa.b-cdn.net/32_5.mp3'
  //   ],
  //   // status: DownloadStatus.notStarted
  //   // isPaused: false,
  // );
  // MultiRequestsHttp(
  //     status,
  //     downloadmodel,
  //     pauseOrNot,
  //   );
  //   start();
  //   super .onInit();
  // }
}
