import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class ArbitraryPositionExample extends StatefulWidget {
  const ArbitraryPositionExample({Key? key}) : super(key: key);

  @override
  State createState() => ArbitraryPositionExampleState();
}

class ArbitraryPositionExampleState extends State<ArbitraryPositionExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Arbitrary Position',
        codePath: 'example/arbitrary_position.dart',
      ),
      body: ConstraintLayout(
        children: [
          Container(
            color: Colors.black,
            child: const Text(
              'Arbitrary position gives you more freedom\nadjust the window size to see the effect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ).applyConstraint(
            width: matchParent,
            height: 50,
            top: parent.top,
          ),
          Container(
            color: Colors.orange,
          ).applyConstraint(
            size: matchConstraint,
            anchors: [sId(-1)],
            calcSizeCallback: (parent, anchors) {
              return const BoxConstraints.tightFor(
                width: 100,
                height: 100,
              );
            },
            calcOffsetCallback: (parent, self, anchors) {
              return Offset(
                  min(
                      max(
                          300,
                          anchors[0].getRight() -
                              anchors[0].getMeasuredWidth() / 2),
                      700),
                  max(400, parent.size.height - self.getMeasuredHeight()));
            },
          )
        ],
      ),
    );
  }
}
