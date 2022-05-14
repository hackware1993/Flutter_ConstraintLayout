import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class MarginExample extends StatelessWidget {
  const MarginExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Margin',
        codePath: 'example/margin.dart',
      ),
      body: ConstraintLayout(
        children: [
          Container(
            color: const Color(0xFF005BBB),
          ).applyConstraint(
            size: 50,
            topLeftTo: parent,
            margin: const EdgeInsets.only(
              left: 20,
              top: 100,
            ),
          ),
          Container(
            color: const Color(0xFFFFD500),
          ).applyConstraint(
            size: 100,
            top: sId(-1).bottom,
            right: parent.right.margin(100),
          ),
          Container(
            color: Colors.pink,
          ).applyConstraint(
            size: 50,
            topRightTo: parent.rightMargin(20).topMargin(50),
          ),
          Container(
            color: Colors.pink,
          ).applyConstraint(
            size: 50,
            outBottomCenterTo: sId(-2).topMargin(20),
          )
        ],
      ),
    );
  }
}
