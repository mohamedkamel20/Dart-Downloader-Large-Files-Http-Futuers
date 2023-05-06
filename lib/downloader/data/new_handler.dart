import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

enum DownloadStatus { NotStarted, Started, Downloading, Completed }

class FileDownloaderProvider with ChangeNotifier {
  StreamSubscription? _downloadSubscription;
  DownloadStatus _downloadStatus = DownloadStatus.NotStarted;
  int _downloadPercentage = 0;
  String _downloadedFile = "";

  int get downloadPercentage => _downloadPercentage;
  DownloadStatus get downloadStatus => _downloadStatus;
  String get downloadedFile => _downloadedFile;

  Future downloadFile(String url, String filename) async {
    final Completer<void> completer = Completer<void>();
// debugPrint('downloadFileTimmmmmme:' '${)}');

    var httpClient = http.Client();
    var request = http.Request(
      'GET',
      Uri.parse(url),
    );
    // request.headers['Accept-Encoding'] = 'gzip';
    var response = httpClient.send(request);

    final dir = Platform.isAndroid
        ? '/sdcard/download'
        : (await getApplicationDocumentsDirectory()).path;

    List<List<int>> chunks = [];
    int downloaded = 0;

    updateDownloadStatus(DownloadStatus.Started);

    _downloadSubscription =
        response.asStream().listen((http.StreamedResponse r) {
      updateDownloadStatus(DownloadStatus.Downloading);
      r.stream.listen((List<int> chunk) async {
        // Display percentage of completion

        debugPrint('downloadPercentage onListen : $_downloadPercentage');

        chunks.add(chunk);

        downloaded += chunk.length;
        _downloadPercentage = (downloaded / r.contentLength! * 100).round();
        notifyListeners();
      }, onDone: () async {
        // Display percentage of completion
        _downloadPercentage = (downloaded / r.contentLength! * 100).round();
        notifyListeners();
        debugPrint('downloadPercentage onDone: $_downloadPercentage');

        // Save the file
        File file = File('$dir/$filename');

        _downloadedFile = '$dir/$filename';
        debugPrint(_downloadedFile);

        final Uint8List bytes = Uint8List(r.contentLength!);
        int offset = 0;
        for (List<int> chunk in chunks) {
          bytes.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
        await file.writeAsBytes(bytes);

        updateDownloadStatus(DownloadStatus.Completed);
        _downloadSubscription?.cancel();
        _downloadPercentage = 0;

        notifyListeners();
        debugPrint('DownloadFile: Completed');
        completer.complete();

        return;
      });
    });
    // }

    await completer.future;
    // _downloadSubscription!.isPaused;
  }

  void updateDownloadStatus(DownloadStatus status) {
    _downloadStatus = status;
    debugPrint('updateDownloadStatus: $status');
    notifyListeners();
  }
}
