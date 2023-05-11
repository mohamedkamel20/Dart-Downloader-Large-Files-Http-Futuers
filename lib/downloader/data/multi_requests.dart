import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:download_task/download_task.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadModel {
  String? url;
  final List<String> urlss;

  File? savePath;
  int downloadedBytes;
  double totalBytes;
  bool? isPaused;
  StreamSubscription<List<int>>? streamSubscription;
  bool? isReasumed;
  DownloadStatus status;

  DownloadModel({
    this.url,
    required this.urlss,
    this.savePath,
    this.streamSubscription,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.isReasumed = false,
    this.isPaused,
    this.status = DownloadStatus.started,
  });
}

enum DownloadStatus { started, pasue, resume, downloading, completed }

class MultiRequestsHttp extends GetxController {
  // DownloadStatus status = DownloadStatus.started;
  bool isPause;
  DownloadModel downloadModel;
  MultiRequestsHttp(
    this.downloadModel,
    this.isPause,
  );

  Future<void> start() async {
    DownloadModel task = downloadModel;
    _ddownloadFile(task);
  }

  Future<void> startDownload(DownloadModel downloadModel) async {
    final List<Future<void>> futures = [];

    final dir = Platform.isAndroid
        ? '/sdcard/download'
        : (await getApplicationDocumentsDirectory()).path;

    for (int i = 0; i < downloadModel.urlss.length; i++) {
      final url = downloadModel.urlss[i];
      debugPrint('url: $url');
      final fileName = _getFileNameFromUrl(url);
      final file = File('$dir/$fileName');

      debugPrint(
          'content Length: ${_getContentLength(url).then((value) => debugPrint('value of content length of $i: $value'))}}');

      // Check if the file exists and is complete
      if (await file.exists() &&
          await _isFileComplete(file.path, _getContentLength(url))) {
        debugPrint('File $fileName already exists and is complete');
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
    }

    // Wait for all downloads to complete
    await Future.wait(futures);
    // await Future.wait(getLentgth);
    debugPrint('Future length: ${futures.length}');
    debugPrint('Future started');
  }

  Future<File> _ddownloadFile(DownloadModel downloadModel) async {
    final httpClient = HttpClient();
    late final StreamSubscription subscription;

    // final completer = Completer<void>();

    // try {
    final request = await httpClient.getUrl(Uri.parse(downloadModel.url!));
    int startByte = await downloadModel.savePath!.exists()
        ? downloadModel.savePath!.lengthSync()
        : 0;
    if (startByte > 0) {
      request.headers.set('Range', 'bytes=$startByte-');
    }

    final response = await request.close();

    // final bytes = await consolidateHttpClientResponseBytes(response);

    // await downloadModel.savePath!.writeAsBytes(bytes, mode: FileMode.append);
    final output = downloadModel.savePath!.openWrite(mode: FileMode.append);

    debugPrint('downloaded file path = ${downloadModel.savePath!.path}');

    subscription = response.listen((data) async {
      if (!isPause) {
        output.add(data);
        // startByte = output.;
        debugPrint('Download in progress');
      } else {
        subscription.pause();
        debugPrint('Download paused');
        // await Future.delayed(const Duration(seconds: 10));
        httpClient.connectionTimeout = const Duration(minutes: 5);
        request.close();
      }
    }, onDone: () {
      debugPrint('Download success');

      output.close();

      request.close();
    }, onError: (error) {});
    // await subscription.cancel();
    return downloadModel.savePath!;
  }
  // catch (error) {
  //   debugPrint(' downloading error = $error');
  // return File('');
  // }
  // }

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
}
