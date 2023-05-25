import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerScreen extends StatefulWidget {
  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _audioPlayer.setFilePath(
        '/Users/mohamedkamel/Library/Developer/CoreSimulator/Devices/E50EDC85-9070-4C2C-B339-D8628B93D825/data/Containers/Data/Application/38A70003-A6F4-4315-96EA-3528D3D44A2F/Documents/32_2.mp3');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _audioPlayer.setFilePath(
                    '/Users/mohamedkamel/Library/Developer/CoreSimulator/Devices/E50EDC85-9070-4C2C-B339-D8628B93D825/data/Containers/Data/Application/38A70003-A6F4-4315-96EA-3528D3D44A2F/Documents/32_2.mp3');
                await _audioPlayer.play();
              },
              child: const Text('Play'),
            ),
            ElevatedButton(
              onPressed: () {
                _audioPlayer.pause();
              },
              child: const Text('Pause'),
            ),
            ElevatedButton(
              onPressed: () {
                _audioPlayer.seek(const Duration(seconds: 10));
              },
              child: const Text('Jump to 10s'),
            ),
            ElevatedButton(
              onPressed: () {
                _audioPlayer.setSpeed(2.0);
              },
              child: const Text('Double Speed'),
            ),
            ElevatedButton(
              onPressed: () {
                _audioPlayer.setVolume(0.5);
              },
              child: const Text('Half Volume'),
            ),
            ElevatedButton(
              onPressed: () {
                _audioPlayer.stop();
              },
              child: const Text('Stop'),
            ),
          ],
        ),
      ),
    );
  }
}
