import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class TranslateExample extends StatefulWidget {
  const TranslateExample({Key? key}) : super(key: key);

  @override
  State createState() => TranslateExampleState();
}

class TranslateExampleState extends State<TranslateExample> {
  late Timer timer;
  int angle = 0;
  int earthAngle = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        angle += 5;
        angle %= 360;
        earthAngle += 1;
        earthAngle %= 360;
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
          Container(
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.all(Radius.circular(1000)),
            ),
            child: const Text('Sun'),
            alignment: Alignment.center,
          ).applyConstraint(
            size: 200,
            pinnedInfo: PinnedInfo(
              parent,
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              Anchor(0.3, AnchorType.percent, 0.5, AnchorType.percent),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(1000)),
            ),
            child: const Text('Earth'),
            alignment: Alignment.center,
          ).applyConstraint(
            size: 100,
            pinnedInfo: PinnedInfo(
              sId(-1),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              angle: earthAngle,
            ),
            translate: circleTranslate(
              radius: 350,
              angle: earthAngle,
            ),
            translateConstraint: true,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(1000)),
            ),
            child: const Text('Moon'),
            alignment: Alignment.center,
          ).applyConstraint(
            size: 50,
            pinnedInfo: PinnedInfo(
              sId(-1),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              angle: angle,
            ),
            translate: circleTranslate(
              radius: 100,
              angle: angle,
            ),
          ),
          Container(
            color: Colors.yellow,
          ).applyConstraint(
            id: anchor,
            size: 150,
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
