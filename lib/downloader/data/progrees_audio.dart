import 'package:get/get.dart';

// class ProgressController extends GetxController {
//   ProgressController(): super();
//   final current = Duration.zero.obs;
//   final buffered = Duration.zero.obs;
//   final total = Duration.zero.obs;

//   void updateProgress({
//     required Duration current,
//     required Duration buffered,
//     required Duration total,
//   }) {
//     this.current.value = current;
//     this.buffered.value = buffered;
//     this.total.value = total;
//   }
// }
class ProgressController extends GetxController {
  // ProgressController() : super();
  static const initalValue = ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  );
}

class ProgressBarState  {
 
  const ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}
