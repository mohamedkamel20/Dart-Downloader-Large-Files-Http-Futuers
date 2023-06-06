import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mp3downloader/downloader/cache.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

import '../audio/audio_player_manager.dart';
import '../downloader/download_manager.dart';

Color greenTouch = Vx.hexToColor('#788154');
RxBool isDownloadPaused = false.obs;
RxBool isPaused = false.obs;

final playController = Get.put(PageManager());
final downloadController = Get.put(DownloadManager());
final cachecController = Get.put(SharedCahche());

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.hexToColor('#e8eddb'),
      body: SafeArea(
        child: ListView(shrinkWrap: true, children: [
          Obx(
            () => downloadController.checIfdownloadCompelete.value
                ? const PlayList().p16().h(context.percentHeight * 35)
                : const DonwloaderView().p16().h(context.percentHeight * 35),
          ),

          const AudioPlayerView().p16().h(context.percentHeight * 50),
          // const PlayList().p16().h(context.percentHeight * 35),
        ]),
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}

class RoundedBox extends StatelessWidget {
  const RoundedBox({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return VxBox(child: child)
        .color(Vx.hexToColor('#fff6db'))
        .roundedLg
        .p24
        .make();
  }
}

class DonwloaderView extends StatefulWidget {
  const DonwloaderView({super.key});

  @override
  State<DonwloaderView> createState() => _DonwloaderViewState();
}

class _DonwloaderViewState extends State<DonwloaderView> {
  bool isPause = false;
  @override
  Widget build(BuildContext context) {
    return RoundedBox(
        child: Row(
      children: [
        VStack(
          [
            Obx(
              () => Text(downloadController.statuss.value)
                  .text
                  .xl2
                  .size(16)
                  .bold
                  .color(Vx.hexToColor('#595236'))
                  .fontFamily(GoogleFonts.poppins().fontFamily!)
                  .make()
                  .p12(),
            ),

            // Text(downloadController.statuss).text.xl2.thin.tighter.make(),
            LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 100,
              animation: true,
              lineHeight: 15.0,
              animationDuration: 2500,
              percent: downloadController.downloadPercentage.value / 100,
              center: Obx(() =>
                  Text('${downloadController.downloadPercentage.value}%')),
              // linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: Colors.green,
            ),

            Row(
              children: [
                isDownloadPaused.value
                    ? IconButton(
                        onPressed: () {
                          downloadController.pauseDownload();
                          setState(() {
                            isDownloadPaused.value = false;
                          });
                        },
                        icon: const Icon(Icons.pause))
                    : IconButton(
                        onPressed: () {
                          downloadController.startDownload();
                          setState(() {
                            isDownloadPaused.value = true;
                            downloadController.isPause.value = false;
                          });
                        },
                        icon: const Icon(Icons.play_arrow)),
                IconButton(
                    onPressed: () {
                      downloadController.cancelDownload();
                    },
                    icon: const Icon(Icons.cancel))
              ],
            )
          ],
          crossAlignment: CrossAxisAlignment.center,
        ),
      ],
    ));
  }
}

class AudioPlayerView extends StatefulWidget {
  const AudioPlayerView({super.key});

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView> {
  @override
  Widget build(BuildContext context) {
    return RoundedBox(
      child: ListView(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VxBox()
                  .square(90)
                  .bgImage(const DecorationImage(
                      image: NetworkImage(
                          'https://ia800400.us.archive.org/BookReader/BookReaderImages.php?zip=/3/items/FP158170/158170_jp2.zip&file=158170_jp2/158170_0000.jp2&id=FP158170&scale=4&rotate=0'),
                      fit: BoxFit.cover))
                  .rounded
                  .make(),
              Obx(
                () => Text(playController.currentAudioTitle.value)
                    .text
                    .semiBold
                    .make(),
              ).pSymmetric(h: 16, v: 12),
            ],
          ),
          Obx(
            () => ProgressBar(
              progress: playController.progress.value,
              total: playController.totalDuration.value,
              buffered: playController.bufferedPosition.value,
              barHeight: 8,
              baseBarColor: Colors.black,
              thumbColor: greenTouch,
              progressBarColor: greenTouch,
              onSeek: (value) => playController.seek(value),
            ).p16(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    playController.backseek(Duration(
                        seconds: playController.progress.value.inSeconds - 10));
                  },
                  iconSize: 26,
                  icon: const Icon(Icons.replay_10)),
              IconButton(
                  onPressed: () {
                    playController.playPrevious();
                  },
                  iconSize: 26,
                  icon: const Icon(Icons.skip_previous)),
              Obx(
                () => isPaused.value
                    ? IconButton(
                        onPressed: () {
                          playController.pause();
                          setState(() {
                            isPaused.value = false;
                          });
                        },
                        iconSize: 26,
                        icon: const Icon(Icons.pause))
                    : IconButton(
                        onPressed: () {
                          playController.play();
                          setState(() {
                            isPaused.value = true;
                          });
                        },
                        iconSize: 26,
                        icon: const Icon(Icons.play_arrow)),
              ),
              IconButton(
                  onPressed: () {
                    playController.playNext();
                  },
                  iconSize: 26,
                  icon: const Icon(Icons.skip_next)),
              IconButton(
                  onPressed: () {
                    playController.seek(Duration(
                        seconds:
                            (playController.progress.value.inSeconds + 10)));
                  },
                  iconSize: 26,
                  icon: const Icon(Icons.forward_10)),
              IconButton(
                  onPressed: () {
                    playController.playBack();
                  },
                  iconSize: 24,
                  icon: const Icon(Icons.speed_sharp)),
            ],
          )
        ],
      ),
    ).wFull(context);
  }
}

class PlayList extends StatefulWidget {
  const PlayList({super.key});

  @override
  State<PlayList> createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  @override
  Widget build(BuildContext context) {
    return RoundedBox(
      child: Stack(alignment: Alignment.topRight, children: [
        ListView.builder(
          itemCount: playController.playListTitle.length - 1,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, index) {
            return ListTile(
              title: InkWell(
                  onTap: () {
                    // playController.indexPlay.value = index;
                    setState(() {
                      isPaused.value = true;
                    });
                    // isPaused = true;
                    playController.playAudio(index);
                    // playController.playAudio(index);
                  },
                  child: Text(playController.playListTitle[index].toString())),
              leading: const FlutterLogo(),
            );
          },
        ),
        IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('Delete All'),
                        content: const Text(
                            'Are you sure you want to delete all files?'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                playController.deleteAudioFiles();
                                Navigator.pop(context);
                              },
                              child: const Text('Yes')),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('No'))
                        ],
                      ));
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            )),
      ]),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RoundedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: greenTouch,
              child: const Icon(
                Icons.home,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.download_sharp),
              color: greenTouch,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.mic),
              color: greenTouch,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border),
              color: greenTouch,
            ),
          ],
        ),
      ).p24(),
    );
  }
}
