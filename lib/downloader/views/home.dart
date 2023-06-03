import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mp3downloader/downloader/data/cache.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

import '../data/multi_audio_player.dart.dart';
import '../data/multi_requests.dart';

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
          // const DonwloaderView().p16().h(context.percentHeight * 27),
          downloadController.checIfdownloadCompelete.value
              ? const PlayList().p16().h(context.percentHeight * 35)
              : const DonwloaderView().p16().h(context.percentHeight * 27),
          const AudioPlayerView().p16().h(context.percentHeight * 35),
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
        .color(Vx.hexToColor('#fff6db '))
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
            Obx(
              () => LinearPercentIndicator(
                width: MediaQuery.of(context).size.width - 100,
                animation: true,
                lineHeight: 15.0,
                animationDuration: 2500,
                percent: downloadController.downloadPercentage.value / 100,
                center: Text('${downloadController.downloadPercentage}%'),
                // linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: Colors.green,
              ),
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
                      downloadController.reasumeDownload();
                    },
                    icon: const Icon(Icons.cancel))
              ],
            ).pSymmetric(h: 16, v: 12),
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
              Column(
                children: [
                  Obx(
                    () => Text(playController.currentAudioTitle.value)
                        .text
                        .semiBold
                        .make(),
                  ),
                ],
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
          HStack(
            [
              IconButton(
                  onPressed: () {
                    playController.play();
                  },
                  iconSize: 24,
                  icon: const Icon(Icons.repeat)),
              IconButton(
                  onPressed: () {
                    playController.playPrevious();
                  },
                  iconSize: 24,
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
                        iconSize: 24,
                        icon: const Icon(Icons.pause))
                    : IconButton(
                        onPressed: () {
                          playController.play();
                          setState(() {
                            isPaused.value = true;
                          });
                        },
                        iconSize: 24,
                        icon: const Icon(Icons.play_arrow)),
              ),
              IconButton(
                  onPressed: () {
                    playController.playNext();
                  },
                  iconSize: 24,
                  icon: const Icon(Icons.skip_next)),
              IconButton(
                  onPressed: () {
                    playController.seek(const Duration(seconds: 10));
                  },
                  iconSize: 24,
                  icon: const Icon(Icons.forward_10)),
              IconButton(
                  onPressed: () {
                    playController.play();
                  },
                  iconSize: 24,
                  icon: const Icon(Icons.shuffle)),
            ],
          ).p24(),
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
      child: ListView.builder(
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
          }),
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
