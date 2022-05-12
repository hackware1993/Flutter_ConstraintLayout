import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class PinnedPositionExample extends StatefulWidget {
  const PinnedPositionExample({Key? key}) : super(key: key);

  @override
  State createState() => PinnedPositionExampleState();
}

class PinnedPositionExampleState extends State<PinnedPositionExample> {
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
              PinnedPos(0.2, PinnedType.percent, 0.2, PinnedType.percent),
              PinnedPos(1, PinnedType.percent, 1, PinnedType.percent),
              angle: angle,
            ),
          ),
          Container(
            color: Colors.orange,
          ).applyConstraint(
            size: 60,
            pinnedInfo: PinnedInfo(
              anchor,
              PinnedPos(1, PinnedType.percent, 1, PinnedType.percent),
              PinnedPos(0, PinnedType.percent, 0, PinnedType.percent),
              angle: 360 - angle,
            ),
          ),
          Container(
            color: Colors.black,
          ).applyConstraint(
            size: 60,
            pinnedInfo: PinnedInfo(
              anchor,
              PinnedPos(0.5, PinnedType.percent, 0.5, PinnedType.percent),
              PinnedPos(0.5, PinnedType.percent, 0.5, PinnedType.percent),
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
          ),
        ],
      ),
    );
  }
}
