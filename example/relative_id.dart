import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

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
            size: 200,
            centerTo: parent,
          ),
          Container(
            color: Colors.redAccent,
          ).applyConstraint(
            size: 100,
            left: rId(0).right,
            right: rId(0).right,
            top: rId(0).top,
            bottom: rId(0).top,
          ),
          Container(
            color: Colors.green,
          ).applyConstraint(
            size: 50,
            centerBottomRightTo: sId(-1),
          ),
          Container(
            color: Colors.blue,
          ).applyConstraint(
            size: 50,
            centerBottomRightTo: sId(-3),
          )
        ],
      ),
    );
  }
}
