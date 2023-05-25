import 'dart:io';

import 'package:download_task/download_task.dart';
import 'package:flutter/material.dart';

class DownloadPackage {
  Future<void> _downloadPackage(
    String url,
    File file,
    TaskEvent eventos,
  ) async {
    final task = await DownloadTask.download(Uri.parse(url), file: file);

    double previousProgress = 0.0;
    task.events.listen((eventos) {
      switch (eventos.state) {
        case TaskState.downloading:
          final bytesReceived = eventos.bytesReceived!;
          final totalBytes = eventos.totalBytes!;
          if (totalBytes == -1) return;

          final progress = (bytesReceived / totalBytes * 100).floorToDouble();
          if (progress != previousProgress && progress % 10 == 0) {
            debugPrint("progress $progress%");
            previousProgress = progress;
          }
          break;
        case TaskState.paused:
          debugPrint("paused");
          break;
        case TaskState.success:
          debugPrint("downloaded");
          break;
        case TaskState.canceled:
          debugPrint("canceled");
          break;
        case TaskState.error:
          debugPrint("error: ${eventos.error!}");
          break;
      }
    });
  }
  //   Future<void> _olddownloadFile(DownloadModel downloadModel) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final completer = Completer<void>();
  //   final client = HttpClient();
  //   HttpClientRequest request;
  //   HttpClientResponse response;

  //   while (!downloadModel.isPaused!) {
  //     // if (downloadModel.isPaused == true) {
  //     await Future.delayed(const Duration(milliseconds: 30));
  //     await completer.future;
  //     debugPrint('${downloadModel.savePath} downloaded pasued.');
  //     //   continue;
  //   }

  //   if (downloadModel.isReasumed!) {
  //     request = await client.getUrl(Uri.parse(downloadModel.url!));
  //     // response =await request.close();
  //     request.headers.set('Range', 'bytes=${downloadModel.downloadedBytes}-');
  //   } else {
  //     request = await client.getUrl(Uri.parse(downloadModel.url!));
  //   }

  //   // Send HTTP request and handle response
  //   response = await request.close();

  //   // downloadModel.downloadPercentage =
  //   //     (downloadModel.downloadedBytes / response.contentLength * 100).round();

  //   if (response.statusCode == HttpStatus.partialContent) {
  //     // Download is resuming from where it left off
  //   } else if (response.statusCode == HttpStatus.ok) {
  //     // New download
  //     // await downloadModel.savePath!.create(recursive: true);
  //     // downloadModel.downloadedBytes = file.lengthSync();
  //   } else {
  //     // Unsupported HTTP status code
  //     debugPrint(
  //         'Error downloading ${downloadModel.savePath}. HTTP status code: ${response.statusCode}');
  //     return;
  //   }

  //   // Download file in chunks and write to disk
  //   final output = downloadModel.savePath!.openWrite(mode: FileMode.append);
  //   // final fileSize = await file.length();
  //   response.listen((data) async {
  //     if (downloadModel.isPaused == false) {
  //       output.add(data);

  //       downloadModel.downloadedBytes = downloadModel.savePath!.lengthSync();
  //     } else {
  //       downloadModel.downloadedBytes = downloadModel.savePath!.lengthSync();
  //       prefs.setInt('downloadedBytes', downloadModel.downloadedBytes);
  //       // downloadModel.totalsize = response.contentLength;

  //       debugPrint('Download of ${downloadModel.savePath} is paused.');
  //     }
  //   }, onDone: () {
  //     output.close();
  //     completer.complete();
  //     downloadModel.isPaused = true;
  //   }, onError: (error) {
  //     output.close();

  //     downloadModel.savePath!.deleteSync();
  //     completer.completeError(error);
  //     downloadModel.isPaused = true;
  //   });

  //   await completer.future;
  //   // downloadModel.totalsize = int.parse(response.headers.value('content-length')!) +
  //   //     downloadModel.downloadedBytes;

  //   // debugPrint('${downloadModel.filename} downloaded successfully.');
  //   // debugPrint('responseee: ${response.headers}');
  //   // prefs.setInt('totalsize', downloadModel.totalsize);

  //   // prefs.setInt('downloadedBytes', task.downloadedBytes);
  // }

  // Future<void> _downloadFiles(
  //   String url,
  //   File file,
  //   int index,
  //   double totalFileSize,
  // ) async {
  //   final startByte = await file.exists() ? file.lengthSync() : 0;
  //   final request = await HttpClient().getUrl(Uri.parse(url));

  //   // request.headers
  //   //     .set('range', 'bytes=$startByte-${totalFileSize.toInt() - 1}');

  //   if (startByte > 0) {
  //     request.headers.set('range', 'bytes=$startByte-');
  //   }
  //   final response = await request.close();
  //   final completer = Completer<void>();
  //   final output = file.openWrite(mode: FileMode.writeOnlyAppend);

  //   // Set startByte and endByte for resuming download
  //   debugPrint("pathh: ${file.path}");
  //   if (response.statusCode == HttpStatus.partialContent) {
  //     // Download is resuming from where it left off
  //     request.headers
  //         .set('range', 'bytes=$startByte-${totalFileSize.toInt() - 1}');
  //   } else if (response.statusCode == HttpStatus.ok) {
  //     // New download
  //     await file.create(recursive: true);
  //     // task.downloadedBytes = file.lengthSync();
  //   } else {
  //     // Unsupported HTTP status code
  //     debugPrint(
  //         'Error downloading ${file.path}. HTTP status code: ${response.statusCode}');
  //     return;
  //   }

  //   response.listen((data) {
  //     if (!downloadModel!.isPaused!) {
  //       output.add(data);
  //       // task.downloadedBytes += data.length;
  //     } else {
  //       // Cancel or pause request
  //       request.abort();
  //       output.close();
  //       file.deleteSync();
  //       completer.complete();
  //     }
  //   }, onDone: () {
  //     output.close();
  //     completer.complete();
  //   }, onError: (error) {
  //     output.close();
  //     file.deleteSync();
  //     completer.completeError(error);
  //   });
  //   debugPrint('File $index downloaded successfully');

  //   completer.future;
  // }
}
