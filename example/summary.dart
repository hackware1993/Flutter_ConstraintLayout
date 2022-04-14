import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class SummaryExample extends StatefulWidget {
  const SummaryExample({Key? key}) : super(key: key);

  @override
  State createState() => SummaryExampleState();
}

class SummaryExampleState extends State<SummaryExample> {
  double x = 0;
  double y = 0;

  ConstraintId box0 = ConstraintId('box0');
  ConstraintId box1 = ConstraintId('box1');
  ConstraintId box2 = ConstraintId('box2');
  ConstraintId box3 = ConstraintId('box3');
  ConstraintId box4 = ConstraintId('box4');
  ConstraintId box5 = ConstraintId('box5');
  ConstraintId box6 = ConstraintId('box6');
  ConstraintId box7 = ConstraintId('box7');
  ConstraintId box8 = ConstraintId('box8');
  ConstraintId box9 = ConstraintId('box9');
  ConstraintId box10 = ConstraintId('box10');
  ConstraintId box11 = ConstraintId('box11');
  ConstraintId barrier = ConstraintId('barrier');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Summary',
        codePath: 'example/summary.dart',
      ),
      backgroundColor: Colors.black,
      body: ConstraintLayout(
        // Constraints can be separated from widgets
        childConstraints: [
          Constraint(
            id: box0,
            width: 200,
            height: 200,
            bottomLeftTo: parent,
            zIndex: 20,
          )
        ],
        children: [
          Container(
            color: Colors.redAccent,
            alignment: Alignment.center,
            child: const Text('box0'),
          ).applyConstraintId(
            id: box0, // Constraints can be separated from widgets
          ),
          Container(
            color: Colors.redAccent,
            alignment: Alignment.center,
            child: const Text('box1'),
          ).apply(
            constraint: Constraint(
              // Constraints set with widgets
              id: box1,
              width: 200,
              height: 100,
              topRightTo: parent,
            ),
          ),
          Container(
            color: Colors.blue,
            alignment: Alignment.center,
            child: const Text('box2'),
          ).applyConstraint(
            // Constraints set with widgets easy way
            id: box2,
            width: matchConstraint,
            height: matchConstraint,
            centerHorizontalTo: box3,
            top: box3.bottom,
            bottom: parent.bottom,
          ),
          Container(
            color: Colors.orange,
            width: 200,
            height: 150,
            alignment: Alignment.center,
            child: const Text('box3'),
          ).applyConstraint(
            id: box3,
            right: box1.left,
            top: box1.bottom,
          ),
          Container(
            color: Colors.redAccent,
            alignment: Alignment.center,
            child: const Text('box4'),
          ).applyConstraint(
            id: box4,
            width: 50,
            height: 50,
            bottomRightTo: parent,
          ),
          GestureDetector(
            child: Container(
              color: Colors.pink,
              alignment: Alignment.center,
              child: const Text('box5 draggable'),
            ),
            onPanUpdate: (details) {
              setState(() {
                x += details.delta.dx;
                y += details.delta.dy;
              });
            },
          ).applyConstraint(
            id: box5,
            width: 120,
            height: 100,
            centerTo: parent,
            zIndex: 100,
            translate: Offset(x, y),
            translateConstraint: true,
          ),
          Container(
            color: Colors.lightGreen,
            alignment: Alignment.center,
            child: const Text('box6'),
          ).applyConstraint(
            id: box6,
            width: 120,
            height: 120,
            centerVerticalTo: box2,
            verticalBias: 0.8,
            left: box3.right,
            right: parent.right,
          ),
          Container(
            color: Colors.lightGreen,
            alignment: Alignment.center,
            child: const Text('box7'),
          ).applyConstraint(
            id: box7,
            width: matchConstraint,
            height: matchConstraint,
            left: parent.left,
            right: box3.left,
            centerVerticalTo: parent,
            margin: const EdgeInsets.all(50),
          ),
          Container(
            color: Colors.cyan,
            alignment: Alignment.center,
            child: const Text('child[7] pinned to the top right'),
          ).applyConstraint(
            width: 200,
            height: 100,
            left: box5.right,
            bottom: box5.top,
          ),
          const Text(
            'box9 baseline to box7',
            style: TextStyle(
              color: Colors.white,
            ),
          ).applyConstraint(
            id: box9,
            baseline: box7.baseline,
            left: box7.left,
          ),
          Container(
            color: Colors.yellow,
            alignment: Alignment.bottomCenter,
            child: const Text(
                'percentage layout\nwidth: 50% of parent\nheight: 30% of parent'),
          ).applyConstraint(
            width: matchConstraint,
            height: matchConstraint,
            widthPercent: 0.5,
            heightPercent: 0.3,
            horizontalBias: 0,
            verticalBias: 0,
            centerTo: parent,
          ),
          Barrier(
            id: barrier,
            direction: BarrierDirection.left,
            referencedIds: [box6, box5],
          ),
          Container(
            color: const Color(0xFFFFD500),
            alignment: Alignment.center,
            child: const Text('align to barrier'),
          ).applyConstraint(
            width: 100,
            height: 200,
            top: box5.top,
            right: barrier.left,
          )
        ],
      ),
    );
  }
}
