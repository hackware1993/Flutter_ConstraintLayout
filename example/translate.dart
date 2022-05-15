import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class TranslateExample extends StatefulWidget {
  const TranslateExample({Key? key}) : super(key: key);

  @override
  State createState() => TranslateExampleState();
}

class TrackPainter extends CustomPainter {
  Queue<Offset> points = Queue();
  Paint painter = Paint();

  TrackPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPoints(PointMode.polygon, points.toList(), painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class TranslateExampleState extends State<TranslateExample> {
  late Timer timer;
  double angle = 0;
  double earthRevolutionAngle = 0;
  Queue<Offset> points = Queue();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        angle += 1;
        earthRevolutionAngle += 0.1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    ConstraintId anchor = ConstraintId('anchor');
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Translate',
        codePath: 'example/translate.dart',
      ),
      body: ConstraintLayout(
        children: [
          CustomPaint(
            painter: TrackPainter(points),
          ).applyConstraint(
            width: matchParent,
            height: matchParent,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.all(Radius.circular(1000)),
            ),
            child: const Text('----'),
            alignment: Alignment.center,
          ).applyConstraint(
            id: cId('sun'),
            size: 200,
            pinnedInfo: PinnedInfo(
              parent,
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              Anchor(0.3, AnchorType.percent, 0.5, AnchorType.percent),
              angle: earthRevolutionAngle * 365 / 25.4,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(1000)),
            ),
            child: const Text('----'),
            alignment: Alignment.center,
          ).applyConstraint(
            id: cId('earth'),
            size: 100,
            pinnedInfo: PinnedInfo(
              cId('sun'),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              angle: earthRevolutionAngle * 365,
            ),
            translate: circleTranslate(
              radius: 250,
              angle: earthRevolutionAngle,
            ),
            translateConstraint: true,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(1000)),
            ),
            child: const Text('----'),
            alignment: Alignment.center,
          ).applyConstraint(
            id: cId('moon'),
            size: 50,
            pinnedInfo: PinnedInfo(
              cId('earth'),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              angle: earthRevolutionAngle * 365 / 27.32,
            ),
            translate: circleTranslate(
              radius: 100,
              angle: earthRevolutionAngle * 365 / 27.32,
            ),
            translateConstraint: true,
            paintCallback: (_, __, ____, offset, ______) {
              points.add(offset!);
              if (points.length > 2000) {
                points.removeFirst();
              }
            },
          ),
          Text('Sun rotates ${(earthRevolutionAngle * 365 / 25.4) ~/ 360} times')
              .applyConstraint(
            outTopCenterTo: cId('sun'),
          ),
          Text('Earth rotates ${earthRevolutionAngle * 365 ~/ 360} times')
              .applyConstraint(
            outTopCenterTo: cId('earth'),
          ),
          Text('Moon rotates ${(earthRevolutionAngle * 365 / 27.32) ~/ 360} times')
              .applyConstraint(
            outTopCenterTo: cId('moon'),
          ),
          Container(
            color: Colors.yellow,
          ).applyConstraint(
            id: anchor,
            size: 250,
            centerRightTo: parent.rightMargin(300),
          ),
          Container(
            color: Colors.red,
            child: const Text('pinned translate'),
          ).applyConstraint(
            centerTo: anchor,
            translate: PinnedTranslate(
              PinnedInfo(
                null,
                Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
                null,
                angle: angle,
              ),
            ),
          ),
          Container(
            color: Colors.blue,
            child: const Text('circle translate'),
          ).applyConstraint(
            size: wrapContent,
            centerTo: anchor,
            translate: circleTranslate(
              radius: 100,
              angle: angle,
            ),
          ),
          Container(
            color: Colors.cyan,
            child: const Text('pinned & circle translate'),
          ).applyConstraint(
            centerTo: anchor,
            translate: PinnedTranslate(
                  PinnedInfo(
                    null,
                    Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
                    null,
                    angle: angle,
                  ),
                ) +
                circleTranslate(
                  radius: 150,
                  angle: angle,
                ),
          ),
          Container(
            color: Colors.orange,
            child: const Text('normal translate'),
          ).applyConstraint(
            size: wrapContent,
            outBottomCenterTo: anchor,
            translate: Offset(0, angle / 5),
          )
        ],
      ),
    );
  }
}
