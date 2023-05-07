import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mp3downloader/downloader/views/download_screen.dart';
import 'package:provider/provider.dart';

import 'downloader/data/new_handler.dart';
import 'downloader/views/download.dart';
import 'downloader/views/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'File Downloader',
        debugShowCheckedModeBanner: false,
        home: SafeArea(
            bottom: false,
            child: Scaffold(primary: false, body: DownloadScreen())));
  }
}
