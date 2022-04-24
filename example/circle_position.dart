import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class CirclePositionExample extends StatelessWidget {
  const CirclePositionExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Circle Position',
        codePath: 'example/circle_position.dart',
      ),
      body: ConstraintLayout(
        children: [
          Container(
            color: Colors.redAccent,
          ).applyConstraint(
            width: 100,
            height: 100,
            centerTo: parent,
          ),
          for (int angle = 0; angle <= 360; angle += 30)
            Container(
              color: Colors.yellow,
            ).applyConstraint(
              width: 50,
              height: 50,
              centerTo: rId(0),
              translate: circleTranslate(
                radius: 200,
                angle: angle,
              ),
            ),
        ],
      ),
    );
  }
}
