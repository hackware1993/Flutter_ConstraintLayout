import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

class OffBuildExample extends StatelessWidget {
  const OffBuildExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ConstraintLayout(
          children: [
            /// subtrees that do not change
            Container(
              color: Colors.orangeAccent,
            ).offBuild(id: 'id').applyConstraint(
                  size: 200,
                  topRightTo: parent,
                )
          ],
        ),
      ),
    );
  }
}
