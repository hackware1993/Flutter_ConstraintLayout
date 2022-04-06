import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

class BarrierExample extends StatelessWidget {
  const BarrierExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConstraintId leftChild = ConstraintId();
    ConstraintId rightChild = ConstraintId();
    ConstraintId barrier = ConstraintId();
    return MaterialApp(
      home: Scaffold(
        body: ConstraintLayout(
          debugShowGuideline: true,
          children: [
            Container(
              color: const Color(0xFF005BBB),
            ).applyConstraint(
              id: leftChild,
              width: 200,
              height: 200,
              top: parent.top,
              left: parent.left,
            ),
            Container(
              color: const Color(0xFFFFD500),
            ).applyConstraint(
              id: rightChild,
              width: 200,
              height: matchConstraint,
              right: parent.right,
              top: parent.top,
              bottom: parent.bottom,
              heightPercent: 0.5,
              verticalBias: 0,
            ),
            Barrier(
              id: barrier,
              direction: BarrierDirection.bottom,
              referencedIds: [leftChild, rightChild],
            ),
            const Text(
              'Align to barrier',
              style: TextStyle(
                fontSize: 40,
                color: Colors.blue,
              ),
            ).applyConstraint(
              width: wrapContent,
              height: wrapContent,
              centerHorizontalTo: parent,
              top: barrier.bottom,
              goneMargin: const EdgeInsets.only(top: 20),
            )
          ],
        ),
      ),
    );
  }
}
