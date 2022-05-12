import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class PinnedPositionExample extends StatelessWidget {
  const PinnedPositionExample({Key? key}) : super(key: key);

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
            size: 40,
            pinnedInfo: PinnedInfo(
              anchor,
              PinnedPos(0, PinnedType.absolute, 0.5, PinnedType.percent),
              PinnedPos(0.5, PinnedType.percent, 0.5, PinnedType.percent),
              rotateDegree: 45,
            ),
          )
        ],
      ),
    );
  }
}
