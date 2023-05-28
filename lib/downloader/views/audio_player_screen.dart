import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mp3downloader/downloader/data/progrees_audio.dart';
import '../data/multi_audio_player.dart.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final controller = Get.put(PageManager());
  bool isPaused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Obx(() => Text(
                  controller.currentAudioTitle[0],
                  style: const TextStyle(color: Colors.black),
                )),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            child: FlutterLogo(
              size: 200,
            ),
          ),
          const SizedBox(height: 20),
          ProgressBar(
            onSeek: (duration) {
              controller.seek(duration);
            },
            progress: controller.progress,
            buffered: controller.bufferedPosition,
            total: controller.totalDuration,
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: () {
                    controller.play();
                  },
                  icon: const Icon(Icons.repeat)),
              IconButton(
                  onPressed: () {
                    controller.playPrevious();
                  },
                  icon: const Icon(Icons.skip_previous)),
              isPaused
                  ? IconButton(
                      onPressed: () {
                        controller.pause();
                        setState(() {
                          isPaused = false;
                        });
                      },
                      icon: const Icon(Icons.pause))
                  : IconButton(
                      onPressed: () {
                        controller.play();
                        setState(() {
                          isPaused = true;
                        });
                      },
                      icon: const Icon(Icons.play_arrow)),
              IconButton(
                  onPressed: () {
                    controller.playNext();
                  },
                  icon: const Icon(Icons.skip_next)),
              IconButton(
                  onPressed: () {
                    controller.play();
                  },
                  icon: const Icon(Icons.shuffle)),
            ],
          ),
        ],
      ),
    );
  }
}
