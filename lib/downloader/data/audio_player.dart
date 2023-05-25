import 'package:get/state_manager.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerData extends GetxController {
   AudioPlayer audioPlayer = AudioPlayer();
   ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: []);

  String fileUrl = '';
  int? index;
  Future<void> setFileurl() async {
    await audioPlayer.setFilePath(fileUrl);
  }

  Future<void> play() async {
    await audioPlayer.play();
  }

  Future<void> pause() async {
    await audioPlayer.pause();
  }

  Future<void> seek() async {
    await audioPlayer.seek(const Duration(seconds: 10));
  }

  Future<void> setSpeed() async {
    await audioPlayer.setSpeed(2.5);
  }

  Future<void> getPostions() async {
    await audioPlayer.position;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
  }
  void _setInitialPlaylist() async {
  const prefix = 'https://www.soundhelix.com/examples/mp3';
  final song1 = Uri.parse('$prefix/SoundHelix-Song-1.mp3');
  final song2 = Uri.parse('$prefix/SoundHelix-Song-2.mp3');
  final song3 = Uri.parse('$prefix/SoundHelix-Song-3.mp3');
  _playlist = ConcatenatingAudioSource(children: [
    AudioSource.uri(song1, tag: 'Song 1'),
    AudioSource.uri(song2, tag: 'Song 2'),
    AudioSource.uri(song3, tag: 'Song 3'),
  ]);
  await audioPlayer.setAudioSource(_playlist);
}
}
