import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/constrait_layout/constraint_layout.dart';

class ConstraintLayoutDemo extends StatelessWidget {
  const ConstraintLayoutDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: ConstraintLayout(
          debugName: 'main_root',
          debugShowGuideline: true,
          debugShowPreview: true,
          debugShowClickArea: false,
          debugPrintDependencies: false,
          debugCheckDependencies: true,
          debugPrintLayoutTime: true,
          children: [
            Constrained(
              id: 'box1',
              width: 200,
              height: 200,
              topToTop: CL.parent,
              visibility: CL.visible,
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
              visibility: CL.visible,
              bottomToBottom: CL.parent,
              child: Container(
                color: Colors.blue,
                alignment: Alignment.center,
                child: const Text('box2'),
              ),
            ),
            Constrained(
              id: 'box4',
              width: 50,
              height: 50,
              rightToRight: CL.parent,
              visibility: CL.visible,
              bottomToBottom: CL.parent,
              margin: const EdgeInsets.only(bottom: 50, right: 10),
              child: Container(
                color: Colors.redAccent,
                alignment: Alignment.center,
                child: const Text('box4'),
              ),
            ),
            Constrained(
              id: 'box7',
              width: 120,
              height: 120,
              visibility: CL.visible,
              centerVertical: true,
              verticalBias: 0.85,
              leftToRight: 'box3',
              rightToRight: CL.parent,
              horizontalBias: 0.2,
              child: Container(
                color: Colors.lightGreen,
                alignment: Alignment.center,
                child: const Text('box7'),
              ),
            ),
            Constrained(
              id: 'box8',
              width: CL.matchConstraint,
              height: CL.matchConstraint,
              topToTop: 'box1',
              leftToLeft: CL.parent,
              rightToLeft: 'box3',
              visibility: CL.visible,
              bottomToBottom: CL.parent,
              margin: const EdgeInsets.only(top: 5),
              goneMargin: const EdgeInsets.only(top: 0),
              child: Container(
                color: Colors.lightGreen,
                alignment: Alignment.center,
                child: const Text('box8'),
              ),
            ),
            Constrained(
              id: 'box3',
              width: CL.wrapContent,
              height: CL.wrapContent,
              rightToLeft: 'box1',
              topToBottom: 'box1',
              visibility: CL.visible,
              margin: const EdgeInsets.only(right: 10),
              goneMargin: const EdgeInsets.only(right: 0),
              child: GestureDetector(
                child: Container(
                  color: Colors.orange,
                  width: 200,
                  height: 300,
                  alignment: Alignment.center,
                  child: const Text('box3'),
                ),
                onTap: () {
                  debugPrint('clicked');
                },
              ),
            ),
            Constrained(
              width: 100,
              height: 100,
              center: true,
              visibility: CL.visible,
              child: GestureDetector(
                child: Container(
                  color: Colors.pink,
                  alignment: Alignment.center,
                  child: const Text('child[1]'),
                ),
                onTap: () {
                  debugPrint('clicked');
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
