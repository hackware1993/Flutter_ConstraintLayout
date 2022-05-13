import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class ConstraintVersionExample extends StatefulWidget {
  const ConstraintVersionExample({Key? key}) : super(key: key);

  @override
  State createState() => ConstraintVersionExampleState();
}

class ConstraintVersionExampleState extends State<ConstraintVersionExample> {
  double x = 0;
  double y = 0;
  ConstraintVersion constraintVersion = ConstraintVersion();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Constraint Version',
        codePath: 'example/constraint_version.dart',
      ),
      body: ConstraintLayout(
        constraintVersion: constraintVersion,
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
                constraintVersion.incPaintVersion();
              });
            },
          ).applyConstraint(
            size: 200,
            centerTo: parent,
            translate: Offset(x, y),
          ),
        ],
      ),
    );
  }
}
