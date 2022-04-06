import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/constrait_layout/constraint_layout.dart';

class BadgeExample extends StatelessWidget {
  const BadgeExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConstraintId anchor = ConstraintId();
    return MaterialApp(
      home: Scaffold(
        body: ConstraintLayout(
          children: [
            Container(
              color: Colors.yellow,
            ).applyConstraint(
              width: 200,
              height: 200,
              centerTo: parent,
              id: anchor,
            ),
            Container(
              color: Colors.green,
              child: const Text(
                'Indeterminate badge size',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ).applyConstraint(
              width: wrapContent,
              height: wrapContent,
              left: anchor.right,
              bottom: anchor.top,
              translate: const Offset(-0.5, 0.5),
              percentageTranslate: true,
            )
          ],
        ),
      ),
    );
  }
}
