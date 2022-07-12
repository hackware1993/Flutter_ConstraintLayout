import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class BadgeExample extends StatelessWidget {
  const BadgeExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConstraintId anchor = ConstraintId('anchor');
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Badge',
        codePath: 'example/badge.dart',
      ),
      body: ConstraintLayout(
        children: [
          Container(
            color: Colors.yellow,
          ).applyConstraint(
            size: 200,
            centerTo: parent,
            id: anchor,
          ),
          Container(
            color: Colors.green,
            child: const Text(
              'Indeterminate badge size',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ).applyConstraint(
            left: anchor.right,
            bottom: anchor.top,
            translate: const Offset(-0.5, 0.5),
            percentageTranslate: true,
          ),
          Container(
            color: Colors.green,
          ).applyConstraint(
            size: 100,
            left: anchor.right,
            right: anchor.right,
            top: anchor.bottom,
            bottom: anchor.bottom,
          )
        ],
      ),
    );
  }
}
