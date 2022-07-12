import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class DimensionRatioExample extends StatelessWidget {
  const DimensionRatioExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dimension Ratio',
        codePath: 'example/dimension_ratio.dart',
      ),
      body: ConstraintLayout(
        children: [
          Container(
            color: Colors.redAccent,
            alignment: Alignment.center,
            child: const Text('width: parent width\nheight: 1 / 5 of width'),
          ).applyConstraint(
            width: matchParent,
            height: matchConstraint,
            widthHeightRatio: 5 / 1,
            top: parent.top,
          ),
          Container(
            color: Colors.blue,
            alignment: Alignment.center,
            child: const Text('width: 200\nheight: 200% of width'),
          ).applyConstraint(
            width: 200,
            height: matchConstraint,
            widthHeightRatio: 1 / 2,
            bottomCenterTo: parent,
          )
        ],
      ),
    );
  }
}
