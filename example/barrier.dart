import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class BarrierExample extends StatelessWidget {
  const BarrierExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConstraintId leftChild = ConstraintId('leftChild');
    ConstraintId rightChild = ConstraintId('rightChild');
    ConstraintId barrier = ConstraintId('barrier');
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Barrier',
        codePath: 'example/barrier.dart',
      ),
      body: ConstraintLayout(
        children: [
          Container(
            color: const Color(0xFF005BBB),
          ).applyConstraint(
            id: leftChild,
            size: 200,
            topLeftTo: parent,
          ),
          Container(
            color: const Color(0xFFFFD500),
          ).applyConstraint(
            id: rightChild,
            width: 200,
            height: matchConstraint,
            centerRightTo: parent,
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
            centerHorizontalTo: parent,
            top: barrier.bottom,
          )
        ],
      ),
    );
  }
}
