import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class GuidelineExample extends StatelessWidget {
  const GuidelineExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConstraintId guideline = ConstraintId('guideline');
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Guideline',
        codePath: 'lib/guideline.dart',
      ),
      body: ConstraintLayout(
        children: [
          Container(
            color: const Color(0xFF005BBB),
          ).applyConstraint(
            width: matchParent,
            height: matchConstraint,
            top: parent.top,
            bottom: guideline.top,
          ),
          Guideline(
            id: guideline,
            horizontal: true,
            guidelinePercent: 0.5,
          ),
          Container(
            color: const Color(0xFFFFD500),
          ).applyConstraint(
            width: matchParent,
            height: matchConstraint,
            top: guideline.bottom,
            bottom: parent.bottom,
          ),
          const Text(
            'Stand with the people of Ukraine',
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ).applyConstraint(
            centerHorizontalTo: parent,
            bottom: guideline.bottom,
          )
        ],
      ),
    );
  }
}
