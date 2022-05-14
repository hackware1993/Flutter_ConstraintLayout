import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class PinnedPositionExample extends StatefulWidget {
  const PinnedPositionExample({Key? key}) : super(key: key);

  @override
  State createState() => PinnedPositionExampleState();
}

class PinnedPositionExampleState extends State<PinnedPositionExample> {
  late Timer timer;
  double angle = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        angle++;
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
        title: 'Pinned Position',
        codePath: 'example/pinned_position.dart',
      ),
      body: ConstraintLayout(
        children: [
          Container(
            color: Colors.yellow,
          ).applyConstraint(
            id: anchor,
            size: 200,
            centerTo: parent,
          ),
          Container(
            color: Colors.cyan,
          ).applyConstraint(
            size: 100,
            pinnedInfo: PinnedInfo(
              anchor,
              Anchor(0.2, AnchorType.percent, 0.2, AnchorType.percent),
              Anchor(1, AnchorType.percent, 1, AnchorType.percent),
              angle: angle,
            ),
          ),
          Container(
            color: Colors.orange,
          ).applyConstraint(
            size: 60,
            pinnedInfo: PinnedInfo(
              anchor,
              Anchor(1, AnchorType.percent, 1, AnchorType.percent),
              Anchor(0, AnchorType.percent, 0, AnchorType.percent),
              angle: 360 - angle,
            ),
          ),
          Container(
            color: Colors.black,
          ).applyConstraint(
            size: 60,
            pinnedInfo: PinnedInfo(
              anchor,
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              angle: angle,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ).applyConstraint(
            size: 10,
            centerBottomRightTo: anchor,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ).applyConstraint(
            size: 10,
            centerTopLeftTo: anchor,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ).applyConstraint(
            size: 10,
            centerTo: anchor,
          )
        ],
      ),
    );
  }
}
