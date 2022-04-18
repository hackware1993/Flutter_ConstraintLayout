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
            color: Colors.redAccent,
          ).applyConstraint(
            width: 100,
            height: 100,
            left: rId(0).right,
            right: rId(0).right,
            top: rId(0).top,
            bottom: rId(0).top,
          )
        ],
      ),
    );
  }
}
