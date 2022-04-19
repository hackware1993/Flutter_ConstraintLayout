import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class WrapperConstraintsExample extends StatelessWidget {
  const WrapperConstraintsExample({Key? key}) : super(key: key);

  Widget item(String text) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.redAccent,
      alignment: Alignment.center,
      child: FittedBox(
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Wrapper Constraints',
        codePath: 'example/wrapper_constraints.dart',
      ),
      body: ConstraintLayout(
        children: [
          Container(
            color: Colors.yellow,
          ).applyConstraint(
            width: 500,
            height: 500,
            centerLeftTo: parent,
            margin: const EdgeInsets.only(
              left: 200,
            ),
          ),
          Container(
            color: Colors.yellow,
          ).applyConstraint(
            width: 500,
            height: 500,
            centerRightTo: parent,
            margin: const EdgeInsets.only(
              right: 200,
            ),
          ),
          item('centerTopLeftTo').applyConstraint(
            centerTopLeftTo: rId(0),
          ),
          item('centerTopCenterTo').applyConstraint(
            centerTopCenterTo: rId(0),
          ),
          item('centerTopRightTo').applyConstraint(
            centerTopRightTo: rId(0),
          ),
          item('centerCenterLeftTo').applyConstraint(
            centerCenterLeftTo: rId(0),
          ),
          item('centerCenterRightTo').applyConstraint(
            centerCenterRightTo: rId(0),
          ),
          item('centerBottomLeftTo').applyConstraint(
            centerBottomLeftTo: rId(0),
          ),
          item('centerBottomCenterTo').applyConstraint(
            centerBottomCenterTo: rId(0),
          ),
          item('centerBottomRightTo').applyConstraint(
            centerBottomRightTo: rId(0),
          ),
          item('outTopLeftTo').applyConstraint(
            outTopLeftTo: rId(1),
          ),
          item('outTopCenterTo').applyConstraint(
            outTopCenterTo: rId(1),
          ),
          item('outTopRightTo').applyConstraint(
            outTopRightTo: rId(1),
          ),
          item('outCenterLeftTo').applyConstraint(
            outCenterLeftTo: rId(1),
          ),
          item('outCenterRightTo').applyConstraint(
            outCenterRightTo: rId(1),
          ),
          item('outBottomLeftTo').applyConstraint(
            outBottomLeftTo: rId(1),
          ),
          item('outBottomCenterTo').applyConstraint(
            outBottomCenterTo: rId(1),
          ),
          item('outBottomRightTo').applyConstraint(
            outBottomRightTo: rId(1),
          ),
        ],
      ),
    );
  }
}
