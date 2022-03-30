import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/constrait_layout/constraint_layout.dart';

class Example extends StatelessWidget {
  const Example({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstraintLayout(
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
          id: 'box7',
          width: 120,
          height: 120,
          centerVertical: true,
          verticalBias: 0.5,
          leftToRight: 'box3',
          rightToRight: CL.parent,
          horizontalBias: 0.5,
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
          bottomToBottom: CL.parent,
          margin: const EdgeInsets.all(50),
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
          child: Container(
            color: Colors.orange,
            width: 200,
            height: 300,
            alignment: Alignment.center,
            child: const Text('box3'),
          ),
        ),
        Constrained(
          width: 100,
          height: 100,
          center: true,
          child: Container(
            color: Colors.pink,
            alignment: Alignment.center,
            child: const Text('child[6]'),
          ),
        )
      ],
    );
  }
}
