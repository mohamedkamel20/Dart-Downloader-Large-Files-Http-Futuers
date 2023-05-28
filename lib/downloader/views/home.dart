import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

Color greenTouch = Vx.hexToColor('#788154');

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
        child: ListView(children: [
          const CalenderView().p24(),
        ]),
      ),
      bottomNavigationBar: const BottomBar(),
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

class CalenderView extends StatelessWidget {
  const CalenderView({super.key});

  @override
  Widget build(BuildContext context) {
    return RoundedBox(
        child: Row(
      children: [
        VStack(
          [
            const Text('May').text.xl4.thin.tighter.make(),
            const Text('28')
                .text
                .xl6
                .size(19)
                .tightest
                .bold
                .color(Vx.hexToColor('#595236'))
                .fontFamily(GoogleFonts.poppins().fontFamily!)
                .make(),
          ],
        ),
      ],
    ));
  }
}
