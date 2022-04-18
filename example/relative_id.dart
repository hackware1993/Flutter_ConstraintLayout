import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class RelativeIdExample extends StatelessWidget {
  const RelativeIdExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Relative Id',
        codePath: 'example/relative_id.dart',
      ),
      body: ConstraintLayout(
        children: [
          Container(
            color: Colors.yellow,
          ).applyConstraint(
            width: 200,
            height: 200,
            centerTo: parent,
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
            left: rId(0).right,
            bottom: rId(0).top,
            translate: const Offset(-0.5, 0.5),
            percentageTranslate: true,
          ),
          Container(
            color: Colors.green,
          ).applyConstraint(
            width: 100,
            height: 100,
            left: rId(0).right,
            right: rId(0).right,
            top: rId(0).bottom,
            bottom: rId(0).bottom,
          )
        ],
      ),
    );
  }
}
