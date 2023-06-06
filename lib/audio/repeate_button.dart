import 'package:get/get.dart';

enum RepeatState {
  off,
  repeatSong,
  repeatPlaylist,
}

class RepeatButtonController extends GetxController {
  final repeatState = RepeatState.off.obs;

  void nextState() {
    final next = (repeatState.value.index + 1) % RepeatState.values.length;
    repeatState.value = RepeatState.values[next];
  }
}
