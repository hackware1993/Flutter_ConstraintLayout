import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

class OffPaintExample extends StatelessWidget {
  const OffPaintExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ConstraintLayout(
          children: [
            Container(
              color: Colors.orangeAccent,
            ).offPaint().applyConstraint(
                  width: 200,
                  height: 200,
                  topRightTo: parent,
                )
          ],
        ),
      ),
    );
  }
}
