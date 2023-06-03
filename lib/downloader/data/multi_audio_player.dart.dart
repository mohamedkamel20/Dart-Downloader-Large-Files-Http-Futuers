import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'progrees_audio.dart';

class PageManager extends GetxController {
  late AudioPlayer audioPlayer;
  late AudioPlayer specificAudioPlayer;
  late ConcatenatingAudioSource _playlist;
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
  RxInt indexPlay = 0.obs;
  List<AudioSource> list = [];

  // final Rx<SequenceState> _sequenceState = SequenceState.obs;

  // PlayerState get playerState => playerState.value;
  // Duration get progress => progress.value;
  // Duration get totalDuration => totalDuration.value;
  // Duration get bufferedPosition => bufferedPosition.value;
  // RepeatMode get repeatMode => repeatMode.value;
  // bool get isFirstaudio => isFirstaudio.value;
  // bool get isLastaudio => isLastaudio.value;
  // bool get isShuffleModeEnabled => isShuffleModeEnabled.value;
  // String get currentAudioTitle => currentAudioTitle.value;
  // List<String> get playListTitle => playListTitle;
  // int get indexPlay => _indexPlay.value;

  @override
  void onInit() {
    super.onInit();
    audioPlayer = AudioPlayer();
    specificAudioPlayer = AudioPlayer();
    // getFileUrl();
    _setInitialPlaylist();
    _initAudioPlayerState();
    _listenForChangesInPlayerState();
    _listenForChangesInPlayerPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInTotalDuration();
    _listenForChangesInSequenceState();
    // addSong();
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
        final appDirectory = await getApplicationDocumentsDirectory();
        final filePath = '${appDirectory.path}/32_$i.mp3';
        final file = File(filePath);
        final fileUri = file.uri;

        list.add(AudioSource.uri(
          fileUri,
          tag: _getFileNameFromUrl(fileUri.toString()),
        ));
        playListTitle.add(_getFileNameFromUrl(fileUri.toString()));
        debugPrint(file.path);

        _playlist = ConcatenatingAudioSource(children: list);
        await audioPlayer.setAudioSource(
          _playlist,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void play() async {
    if (playerState.value == PlayerState.loading) return;
    await audioPlayer.play();
  }

  void playAudio(int index) async {
    // final audioFile = list[index];
    await audioPlayer.setAudioSource(
      list[index],
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
    if (_playlist == null) return;
    await audioPlayer.seekToPrevious();
  }

  void playNext() async {
    if (_playlist == null) return;
    await audioPlayer.seekToNext();
  }

  void seek(Duration position) async {
    if (playerState.value == PlayerState.stopped) return;
    await audioPlayer.seek(position, index: indexPlay.value);
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

  // void onRepeatButtonPressed() {
  //   repeatButton.nextState();
  //   switch (repeatButton.value) {
  //     case RepeatMode.off:
  //       audioPlayer.setLoopMode(LoopMode.off);
  //       break;
  //     case RepeatState.repeatSong:
  //       audioPlayer.setLoopMode(LoopMode.one);
  //       break;
  //     case RepeatState.repeatPlaylist:
  //       audioPlayer.setLoopMode(LoopMode.all);
  //   }
  // }

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
