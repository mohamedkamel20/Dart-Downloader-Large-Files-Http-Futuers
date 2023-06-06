import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3downloader/audio/repeate_button.dart';
import 'package:path_provider/path_provider.dart';
import 'progrees_audio.dart';

class PageManager extends GetxController {
  late AudioPlayer audioPlayer;
  late AudioPlayer specificAudioPlayer;
  late ConcatenatingAudioSource playlist;
  Rx<PlayerState> playerState = PlayerState.stopped.obs;
  RxString currentAudioTitle = ''.obs;
  List<String> playListTitle = [''];
  Rx<Duration> progress = Duration.zero.obs;
  Rx<Duration> bufferedPosition = Duration.zero.obs;
  Rx<RepeatMode> repeatMode = RepeatMode.none.obs;
  Rx<Duration> totalDuration = Duration.zero.obs;
  RxBool isFirstaudio = true.obs;
  RxBool isLastaudio = false.obs;
  RxBool isShuffleModeEnabled = false.obs;
  final progressBar = ProgressController();
  // RxInt indexPlay = 0.obs;
  List<AudioSource> list = [];
  final repeatbutton = RepeatButtonController();

  @override
  void onInit() {
    super.onInit();
    audioPlayer = AudioPlayer();
    specificAudioPlayer = AudioPlayer();

    _setInitialPlaylist();
    _initAudioPlayerState();
    _listenForChangesInPlayerState();
    _listenForChangesInPlayerPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInTotalDuration();
    _listenForChangesInSequenceState();
  }

  void _initAudioPlayerState() {
    audioPlayer.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          playerState.value = PlayerState.stopped;
          break;
        case ProcessingState.loading:
          playerState.value = PlayerState.loading;
          break;
        case ProcessingState.buffering:
          playerState.value = PlayerState.buffering;
          break;
        case ProcessingState.ready:
          playerState.value = PlayerState.ready;
          break;
        case ProcessingState.completed:
          playerState.value = PlayerState.completed;
          break;
      }
    });

    audioPlayer.positionStream.listen((position) {
      progress.value = position;
    });

    audioPlayer.bufferedPositionStream.listen((position) {
      bufferedPosition.value = position;
    });
  }

  String _getFileNameFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String path = uri.path;
    return path.substring(path.lastIndexOf('/') + 1).replaceAll('.mp3', '');
  }

  Future<void> _setInitialPlaylist() async {
    try {
      for (int i = 1; i < 3; i++) {
        final appDirectory = Platform.isAndroid
            ? '/storage/emulated/0/Download'
            : (await getApplicationDocumentsDirectory()).path;
        // final filePath = '${appDirectory.path}/32_$i.mp3';
        File file = File('$appDirectory/32_$i.mp3');

        // final fileUri = file.uri;

        list.add(AudioSource.uri(
          file.uri,
          tag: _getFileNameFromUrl(file.uri.toString()),
        ));
        playListTitle.add(_getFileNameFromUrl(file.uri.toString()));
        debugPrint(file.path);

        playlist = ConcatenatingAudioSource(children: list);
        await audioPlayer.setAudioSource(
          playlist,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteAudioFiles() async {
    final appDirectory = Platform.isAndroid
        ? '/storage/emulated/0/Download'
        : (await getApplicationDocumentsDirectory()).path;
    try {
      final directory = Directory(appDirectory);
      if (await directory.exists()) {
        final files = directory.listSync(recursive: false);
        for (final file in files) {
          if (file is File && file.path.endsWith('.mp3')) {
            await file.delete();
          }
        }
        debugPrint('Audio files deleted successfully');
      } else {
        debugPrint('Folder does not exist');
      }
    } catch (e) {
      debugPrint('Error deleting audio files: $e');
    }
  }

  void play() async {
    if (playerState.value == PlayerState.loading) return;
    await audioPlayer.play();
  }

  void playAudio(int index) async {
    if (playlist == null) return;
    
    await audioPlayer.setAudioSource(
      playlist,
      initialIndex: index,
    );
    stop();
    await audioPlayer.play();
  }

  void pause() async {
    // if (playerState.value = PlayerState.playing) return;
    await audioPlayer.pause();
  }

  void stop() async {
    if (playerState.value == PlayerState.stopped) return;
    await audioPlayer.stop();
  }

  void playPrevious() async {
    if (playlist == null) return;
    await audioPlayer.seekToPrevious();
  }

  void playNext() async {
    if (playlist == null) return;
    await audioPlayer.seekToNext();
  }

  void seek(Duration position) async {
    if (playerState.value == PlayerState.stopped) return;
    await audioPlayer.seek(
      position,
    );
  }

  void backseek(Duration position) async {
    if (playerState.value == PlayerState.stopped) return;
    await audioPlayer.seek(
      position,
    );
  }

  void playBack() {
    audioPlayer.setSpeed(1.5);
  }

  void setRepeatMode(RepeatMode mode) {
    repeatMode.value = mode;
    audioPlayer
        .setLoopMode(mode == RepeatMode.all ? LoopMode.all : LoopMode.off);
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }

  void onRepeatButtonPressed() {
    repeatbutton.nextState();
    switch (repeatbutton.repeatState.value) {
      case RepeatState.off:
        audioPlayer.setLoopMode(LoopMode.off);
        break;
      case RepeatState.repeatSong:
        audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatState.repeatPlaylist:
        audioPlayer.setLoopMode(LoopMode.all);
    }
  }

  void _listenForChangesInPlayerState() {
    audioPlayer.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          playerState.value = PlayerState.stopped;
          break;
        case ProcessingState.loading:
          playerState.value = PlayerState.loading;
          break;
        case ProcessingState.buffering:
          playerState.value = PlayerState.buffering;
          break;
        case ProcessingState.ready:
          playerState.value = PlayerState.ready;
          break;
        case ProcessingState.completed:
          playerState.value = PlayerState.completed;
          break;
      }
    });
  }

  void _listenForChangesInPlayerPosition() {
    audioPlayer.positionStream.listen((position) {
      progress.value = position;
    });
  }

  void _listenForChangesInBufferedPosition() {
    audioPlayer.bufferedPositionStream.listen((position) {
      bufferedPosition.value = position;
    });
  }

  void _listenForChangesInTotalDuration() {
    audioPlayer.durationStream.listen((duration) {
      totalDuration.value = duration ?? Duration.zero;
    });
  }

  // void _listenForChangesInSequenceState() {
  //   audioPlayer.sequenceStateStream.listen((sequenceState) {
  //     _sequenceState.value = sequenceState;
  //   });
  // }
  void _listenForChangesInSequenceState() {
    audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;

      // update current song title
      final currentItem = sequenceState.currentSource;
      final title = currentItem?.tag as String?;
      currentAudioTitle.value = title ?? 'Unknown';

      // update playlist
      final playlist = sequenceState.effectiveSequence;
      final titles = playlist.map((item) => item.tag as String).toList();
      // playListTitle = titles;
      // currentAudioTitle.value = titles.toString();
      // playlistNotifier.value = titles;
      // currentAudioTitle.add(titles.toString());

      // update shuffle mode
      isShuffleModeEnabled.value = sequenceState.shuffleModeEnabled;

      // update previous and next buttons
      if (playlist.isEmpty || currentItem == null) {
        isFirstaudio.value = true;
        isLastaudio.value = true;
      } else {
        isFirstaudio.value = playlist.first == currentItem;
        isLastaudio.value = playlist.last == currentItem;
      }
    });
  }
}

enum PlayerState {
  stopped,
  loading,
  buffering,
  ready,
  completed,
}

enum RepeatMode {
  none,
  one,
  all,
}
