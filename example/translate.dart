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

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        angle++;
        angle %= 360;
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
            color: Colors.yellow,
          ).applyConstraint(
            id: anchor,
            size: 150,
            centerTo: parent,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.red,
            ),
            child: const Text('pinned translate'),
          ).applyConstraint(
            size: wrapContent,
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
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: const Text('circle translate'),
          ).applyConstraint(
            size: wrapContent,
            centerTo: anchor,
            translate: circleTranslate(
              radius: 150,
              angle: angle,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.orange,
            ),
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
