import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/constrait_layout/constraint_layout.dart';

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  State createState() => ExampleState();
}

class ExampleState extends State<Example> {
  double x = 0;
  double y = 0;

  ConstraintId box1 = ConstraintId();
  ConstraintId box2 = ConstraintId();
  ConstraintId box3 = ConstraintId();
  ConstraintId box4 = ConstraintId();
  ConstraintId box5 = ConstraintId();
  ConstraintId box6 = ConstraintId();
  ConstraintId box7 = ConstraintId();
  ConstraintId box8 = ConstraintId();
  ConstraintId box9 = ConstraintId();
  ConstraintId box10 = ConstraintId();
  ConstraintId box11 = ConstraintId();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: ConstraintLayout(
          children: [
            Container(
              color: Colors.redAccent,
              alignment: Alignment.center,
              child: const Text('box1'),
            ).applyConstraint(
              id: box1,
              width: 200,
              height: 200,
              topRightTo: parent,
            ),
            Container(
              color: Colors.blue,
              alignment: Alignment.center,
              child: const Text('box2'),
            ).applyConstraint(
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
              height: 300,
              alignment: Alignment.center,
              child: const Text('box3'),
            ).applyConstraint(
              id: box3,
              width: wrapContent,
              height: wrapContent,
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
              width: wrapContent,
              height: wrapContent,
              baseline: box7.baseline,
              left: box7.left,
            ),
            ...hChain(
              centerHorizontalTo: parent,
              hChainList: [
                Container(
                  color: Colors.redAccent,
                  alignment: Alignment.center,
                  child: const Text('chain item 1'),
                ).applyConstraint(
                  id: box10,
                  width: matchConstraint,
                  height: 200,
                  top: parent.top,
                ),
                Container(
                  color: Colors.redAccent,
                  alignment: Alignment.center,
                  child: const Text('chain item 2'),
                ).applyConstraint(
                  id: box11,
                  width: matchConstraint,
                  height: 200,
                  top: parent.top,
                ),
              ],
            ),
            Container(
              color: Colors.yellow,
              alignment: Alignment.bottomCenter,
              child: const Text(
                  'percentage layout, width: 50% of parent, height: 30% of parent'),
            ).applyConstraint(
              width: matchConstraint,
              height: matchConstraint,
              widthPercent: 0.5,
              heightPercent: 0.3,
              horizontalBias: 0,
              verticalBias: 0,
              centerTo: parent,
              zIndex: 6,
            ),
          ],
        ),
      ),
    );
  }
}
