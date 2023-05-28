import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'progrees_audio.dart';

class PageManager extends GetxController {
  late AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource _playlist;
  final _playerState = PlayerState.stopped.obs;
  final _currentAudioTitle = [''].obs;
  final _progress = Duration.zero.obs;
  final _bufferedPosition = Duration.zero.obs;
  final _repeatMode = RepeatMode.none.obs;
  final _totalDuration = Duration.zero.obs;
  final _isFirstaudio = true.obs;
  final _isLastaudio = false.obs;
  final _isShuffleModeEnabled = false.obs;
  final progressBar = ProgressController();
  // final Rx<SequenceState> _sequenceState = SequenceState.obs;

  PlayerState get playerState => _playerState.value;
  Duration get progress => _progress.value;
  Duration get totalDuration => _totalDuration.value;
  Duration get bufferedPosition => _bufferedPosition.value;
  RepeatMode get repeatMode => _repeatMode.value;
  bool get isFirstaudio => _isFirstaudio.value;
  bool get isLastaudio => _isLastaudio.value;
  bool get isShuffleModeEnabled => _isShuffleModeEnabled.value;
  List<String> get currentAudioTitle => _currentAudioTitle;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();
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
    _audioPlayer.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          _playerState.value = PlayerState.stopped;
          break;
        case ProcessingState.loading:
          _playerState.value = PlayerState.loading;
          break;
        case ProcessingState.buffering:
          _playerState.value = PlayerState.buffering;
          break;
        case ProcessingState.ready:
          _playerState.value = PlayerState.ready;
          break;
        case ProcessingState.completed:
          _playerState.value = PlayerState.completed;
          break;
      }
    });

    _audioPlayer.positionStream.listen((position) {
      _progress.value = position;
    });

    _audioPlayer.bufferedPositionStream.listen((position) {
      _bufferedPosition.value = position;
    });
  }

  // Future<void> getFileUrl() async {
  //   // final List<Future<void>> futures = [];

  //   // return fileUri;
  //   // await Future.wait(futures);
  // }

  String _getFileNameFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String path = uri.path;
    return path.substring(path.lastIndexOf('/') + 1);
  }

  Future<void> _setInitialPlaylist() async {
    List<AudioSource> list = [];

    for (int i = 1; i < 3; i++) {
      // futures.add(future);
      final appDirectory = await getApplicationDocumentsDirectory();
      final filePath = '${appDirectory.path}/32_$i.mp3';
      final file = File(filePath);
      final fileUri = file.uri;
      // _setInitialPlaylist(fileUri);
      list.add(AudioSource.uri(fileUri,
          tag: _getFileNameFromUrl(fileUri.toString())));
      // futures.add(fut);

      // for (int i = 1; i < 3; i++) {
      //   Uri prefix = await getFileUrl('32_$i.mp3');
      //   final song1 = Uri.parse(prefix.toString());
      //   _playlist = ConcatenatingAudioSource(children: [
      //     AudioSource.uri(song1, tag: _getFileNameFromUrl(prefix.toString())),
      //   ]);
      // }

      // Uri prefix = await getFileUrl('32_1.mp3');
      // debugPrint(prefix.toString());

      // final song1 = Uri.parse(prefix.toString());
      debugPrint(file.path);
      // final song2 = Uri.parse('$prefix/SoundHelix-Song-2.mp3');
      // final song3 = Uri.parse('$prefix/SoundHelix-Song-3.mp3');
      _playlist = ConcatenatingAudioSource(children: list);
      await _audioPlayer.setAudioSource(_playlist);
    }
  }

  void play() async {
    if (_playerState.value == PlayerState.loading) return;
    await _audioPlayer.play();
  }

  void pause() async {
    // if (_playerState.value = PlayerState.playing) return;
    await _audioPlayer.pause();
  }

  void stop() async {
    if (_playerState.value == PlayerState.stopped) return;
    await _audioPlayer.stop();
  }

  void playPrevious() async {
    // if (_playlist == null) return;
    await _audioPlayer.seekToPrevious();
  }

  void playNext() async {
    // if (_playlist == null) return;
    await _audioPlayer.seekToNext();
  }

  void seek(Duration position) async {
    if (_playerState.value == PlayerState.stopped) return;
    await _audioPlayer.seek(position);
  }

  void setRepeatMode(RepeatMode mode) {
    _repeatMode.value = mode;
    _audioPlayer
        .setLoopMode(mode == RepeatMode.all ? LoopMode.all : LoopMode.off);
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  // void onRepeatButtonPressed() {
  //   repeatButton.nextState();
  //   switch (repeatButton.value) {
  //     case RepeatMode.off:
  //       _audioPlayer.setLoopMode(LoopMode.off);
  //       break;
  //     case RepeatState.repeatSong:
  //       _audioPlayer.setLoopMode(LoopMode.one);
  //       break;
  //     case RepeatState.repeatPlaylist:
  //       _audioPlayer.setLoopMode(LoopMode.all);
  //   }
  // }

  void _listenForChangesInPlayerState() {
    _audioPlayer.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          _playerState.value = PlayerState.stopped;
          break;
        case ProcessingState.loading:
          _playerState.value = PlayerState.loading;
          break;
        case ProcessingState.buffering:
          _playerState.value = PlayerState.buffering;
          break;
        case ProcessingState.ready:
          _playerState.value = PlayerState.ready;
          break;
        case ProcessingState.completed:
          _playerState.value = PlayerState.completed;
          break;
      }
    });
  }

  void _listenForChangesInPlayerPosition() {
    _audioPlayer.positionStream.listen((position) {
      _progress.value = position;
    });
  }

  void _listenForChangesInBufferedPosition() {
    _audioPlayer.bufferedPositionStream.listen((position) {
      _bufferedPosition.value = position;
    });
  }

  void _listenForChangesInTotalDuration() {
    _audioPlayer.durationStream.listen((duration) {
      _totalDuration.value = duration!;
    });
  }

  // void _listenForChangesInSequenceState() {
  //   _audioPlayer.sequenceStateStream.listen((sequenceState) {
  //     _sequenceState.value = sequenceState;
  //   });
  // }
  void _listenForChangesInSequenceState() {
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;

      // update current song title
      final currentItem = sequenceState.currentSource;
      final title = currentItem?.tag as String?;
      _currentAudioTitle.value = [title ?? ''];

      // update playlist
      final playlist = sequenceState.effectiveSequence;
      final titles = playlist.map((item) => item.tag as String).toList();
      // playlistNotifier.value = titles;
      _currentAudioTitle.add(titles.toString());

      // update shuffle mode
      _isShuffleModeEnabled.value = sequenceState.shuffleModeEnabled;

      // update previous and next buttons
      if (playlist.isEmpty || currentItem == null) {
        _isFirstaudio.value = true;
        _isLastaudio.value = true;
      } else {
        _isFirstaudio.value = playlist.first == currentItem;
        _isLastaudio.value = playlist.last == currentItem;
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
