import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class ConstraintControllerExample extends StatefulWidget {
  const ConstraintControllerExample({Key? key}) : super(key: key);

  @override
  State createState() => ConstraintControllerExampleState();
}

class ConstraintControllerExampleState
    extends State<ConstraintControllerExample> {
  double x = 0;
  double y = 0;
  ConstraintLayoutController controller = ConstraintLayoutController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Constraint Controller',
        codePath: 'lib/constraint_controller.dart',
      ),
      body: ConstraintLayout(
        controller: controller,
        children: [
          GestureDetector(
            child: Container(
              color: Colors.pink,
              alignment: Alignment.center,
              child: const Text('box draggable'),
            ),
            onPanUpdate: (details) {
              setState(() {
                x += details.delta.dx;
                y += details.delta.dy;
                controller.markNeedsPaint();
              });
            },
          ).applyConstraint(
            size: 200,
            centerTo: parent,
            translate: Offset(x, y),
          )
        ],
      ),
    );
  }
}
