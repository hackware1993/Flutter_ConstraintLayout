import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class SelfWrapContentExample extends StatelessWidget {
  const SelfWrapContentExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Self wrapContent',
        codePath: 'example/self_wrap_content.dart',
      ),
      body: Center(
        child: ConstraintLayout(
          width: wrapContent,
          height: wrapContent,
          children: [
            Container(
              color: Colors.blue,
            ).applyConstraint(
              width: matchParent,
              height: matchParent,
            ),
            Container(
              color: Colors.yellow,
            ).applyConstraint(
              width: 300,
              height: 150,
              topLeftTo: parent,
              margin: const EdgeInsets.only(
                top: 10,
                left: 10,
              ),
            ),
            Container(
              color: Colors.orange,
            ).applyConstraint(
              width: 50,
              height: 50,
              topRightTo: parent,
            ),
            const Text(
              'Self wrapContent',
            ).applyConstraint(
              outBottomRightTo: rId(1),
              margin: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
            ),
            Container(
              color: Colors.cyan,
            ).applyConstraint(
              width: 50,
              height: 50,
              centerVerticalTo: parent,
              left: rId(1).right,
              right: rId(2).left,
            )
          ],
        ),
      ),
    );
  }
}
