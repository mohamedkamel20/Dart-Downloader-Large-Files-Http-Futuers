import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class PageManager extends GetxController {
  late AudioPlayer _audioPlayer;
 late ConcatenatingAudioSource _playlist;
  final _playerState = PlayerState.stopped.obs;
  final _currentAudioTitle = ''.obs;
  final _progress = Duration.zero.obs;
  final _bufferedPosition = Duration.zero.obs;
  final _repeatMode = RepeatMode.none.obs;
  final _totalDuration = Duration.zero.obs;
  final _isFirstaudio = true.obs;
  final _isLastaudio = false.obs;
  final _isShuffleModeEnabled = false.obs;
  // final Rx<SequenceState> _sequenceState = SequenceState.obs;

  PlayerState get playerState => _playerState.value;
  Duration get progress => _progress.value;
  Duration get totalDuration => _totalDuration.value;
  Duration get bufferedPosition => _bufferedPosition.value;
  RepeatMode get repeatMode => _repeatMode.value;
  bool get isFirstaudio => _isFirstaudio.value;
  bool get isLastaudio => _isLastaudio.value;
  bool get isShuffleModeEnabled => _isShuffleModeEnabled.value;
  String get currentAudioTitle => _currentAudioTitle.value;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
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
   void addSong() {
    final songNumber = _playlist!.length + 1;
    const prefix = 'https://www.soundhelix.com/examples/mp3';
    final song = Uri.parse('$prefix/SoundHelix-Song-$songNumber.mp3');
    _playlist!.add(AudioSource.uri(song, tag: 'Song $songNumber'));
  }

  // void removeSong() {
  //   final index = _playlist.length - 1;
  //   if (index < 0) return;
  //   _playlist.removeAt(index);
  // }

  void setPlaylist(ConcatenatingAudioSource playlist) async {
    _playlist = playlist;
    // await _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: playlist.audios));
    play();
  }

  void play() async {
    if (_playlist == null || _playerState.value == PlayerState.loading) return;
    await _audioPlayer.play();
  }

  void pause() async {
    // if (_playerState.value != PlayerState.playing) return;
    await _audioPlayer.pause();
  }

  void stop() async {
    if (_playerState.value == PlayerState.stopped) return;
    await _audioPlayer.stop();
  }

  void playPrevious() async {
    if (_playlist == null) return;
    await _audioPlayer.seekToPrevious();
  }

  void playNext() async {
    if (_playlist == null) return;
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
  //     _sequenceState.value = sequenceState!;
  //   });
  // }
  void _listenForChangesInSequenceState() {
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;

      // update current song title
      final currentItem = sequenceState.currentSource;
      final title = currentItem?.tag as String?;
      _currentAudioTitle.value = title ?? '';

      // update playlist
      final playlist = sequenceState.effectiveSequence;
      final titles = playlist.map((item) => item.tag as String).toList();
      // playlistNotifier.value = titles;

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
