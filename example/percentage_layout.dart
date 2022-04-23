import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class PercentageLayoutExample extends StatelessWidget {
  const PercentageLayoutExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Percentage Layout',
        codePath: 'example/percentage_layout.dart',
      ),
      body: ConstraintLayout(
        children: [
          Container(
            color: Colors.redAccent,
            alignment: Alignment.center,
            child: const Text('width: 50% of parent\nheight: 200'),
          ).applyConstraint(
            width: matchConstraint,
            height: 200,
            widthPercent: 0.5,
            topCenterTo: parent,
          ),
          Container(
            color: Colors.blue,
            alignment: Alignment.center,
            child: const Text('width: 300\nheight: 30% of parent'),
          ).applyConstraint(
            width: 300,
            height: matchConstraint,
            heightPercent: 0.3,
            verticalBias: 1,
            centerLeftTo: parent,
          )
        ],
      ),
    );
  }
}
