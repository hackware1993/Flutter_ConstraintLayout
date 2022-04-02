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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: ConstraintLayout(
          children: [
            Constrained(
              id: 'box1',
              width: 200,
              height: 200,
              topToTop: CL.parent,
              rightToRight: CL.parent,
              child: Container(
                color: Colors.redAccent,
                alignment: Alignment.center,
                child: const Text('box1'),
              ),
            ),
            Constrained(
              id: 'box2',
              width: CL.matchConstraint,
              height: CL.matchConstraint,
              leftToLeft: 'box3',
              rightToRight: 'box3',
              topToBottom: 'box3',
              bottomToBottom: CL.parent,
              child: Container(
                color: Colors.blue,
                alignment: Alignment.center,
                child: const Text('box2'),
              ),
            ),
            Constrained(
              id: 'box3',
              width: CL.wrapContent,
              height: CL.wrapContent,
              rightToLeft: 'box1',
              topToBottom: 'box1',
              child: Container(
                color: Colors.orange,
                width: 200,
                height: 300,
                alignment: Alignment.center,
                child: const Text('box3'),
              ),
            ),
            Constrained(
              id: 'box4',
              width: 50,
              height: 50,
              rightToRight: CL.parent,
              bottomToBottom: CL.parent,
              child: Container(
                color: Colors.redAccent,
                alignment: Alignment.center,
                child: const Text('box4'),
              ),
            ),
            Constrained(
              id: 'box5',
              width: 120,
              height: 100,
              center: CL.parent,
              zIndex: 100,
              translate: Offset(x, y),
              clickPadding: const EdgeInsets.all(30),
              translateConstraint: true,
              child: GestureDetector(
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
              ),
            ),
            Constrained(
              id: 'box6',
              width: 120,
              height: 120,
              centerVertical: 'box2',
              verticalBias: 0.8,
              leftToRight: 'box3',
              rightToRight: CL.parent,
              child: Container(
                color: Colors.lightGreen,
                alignment: Alignment.center,
                child: const Text('box6'),
              ),
            ),
            Constrained(
              id: 'box7',
              width: CL.matchConstraint,
              height: CL.matchConstraint,
              topToTop: 'box1',
              leftToLeft: CL.parent,
              rightToLeft: 'box3',
              bottomToBottom: CL.parent,
              margin: const EdgeInsets.all(50),
              child: Container(
                color: Colors.lightGreen,
                alignment: Alignment.center,
                child: const Text('box7'),
              ),
            ),
            Constrained(
              width: 200,
              height: 100,
              leftToRight: 'box5',
              bottomToTop: 'box5',
              child: Container(
                color: Colors.cyan,
                alignment: Alignment.center,
                child: const Text('child[7] pinned to the top right'),
              ),
            ),
            const Constrained(
              id: 'box9',
              width: CL.wrapContent,
              height: CL.wrapContent,
              baselineToBaseline: 'box7',

              /// when setting baseline alignment, height must be wrap_content or fixed size
              /// other vertical constraints will be ignored
              /// Warning:
              /// Due to a bug in the flutter framework, baseline alignment may not take effect in debug mode
              /// See https://github.com/flutter/flutter/issues/101179

              leftToLeft: 'box7',
              child: Text(
                'box9 baseline to box7',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ...hChain(
              leftToLeft: CL.parent,
              rightToRight: CL.parent,
              hChainList: [
                Constrained(
                  id: 'box10',
                  width: CL.matchConstraint,
                  height: 200,
                  topToTop: CL.parent,
                  child: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.center,
                    child: const Text('chain item 1'),
                  ),
                ),
                Constrained(
                  id: 'box11',
                  width: CL.matchConstraint,
                  height: 200,
                  topToTop: CL.parent,
                  child: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.center,
                    child: const Text('chain item 2'),
                  ),
                ),
              ],
            ),
            Constrained(
              id: 'box12',
              width: CL.matchConstraint,
              height: CL.matchConstraint,
              leftToLeft: CL.parent,
              rightToRight: CL.parent,
              topToTop: CL.parent,
              bottomToBottom: CL.parent,
              widthPercent: 0.5,
              heightPercent: 0.3,
              translate: Offset(x, y),
              zIndex: 6,
              child: Container(
                color: Colors.yellow,
                alignment: Alignment.bottomCenter,
                child: const Text(
                    'percentage layout, width: 50% of parent, height: 30% of parent'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
