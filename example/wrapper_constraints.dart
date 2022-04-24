import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class WrapperConstraintsExample extends StatefulWidget {
  const WrapperConstraintsExample({Key? key}) : super(key: key);

  @override
  State createState() => WrapperConstraintsExampleState();
}

class WrapperConstraintsExampleState extends State<WrapperConstraintsExample> {
  double leftX = 0;
  double rightX = 0;

  Widget item(String text, [Color color = Colors.redAccent]) {
    return Container(
      width: 100,
      height: 100,
      color: color,
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
            callback: (_, rect) {
              leftX = rect.right;
            },
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
          item('centerHorizontalTo', Colors.green).applyConstraint(
            centerHorizontalTo: rId(0),
            top: rId(0).top,
            translate: const Offset(0, 50),
          ),
          item('centerVerticalTo', Colors.green).applyConstraint(
            centerVerticalTo: rId(0),
            left: rId(0).left,
            translate: const Offset(50, 0),
          ),
          item('outTopLeftTo').applyConstraint(
            outTopLeftTo: rId(1),
            callback: (_, rect) {
              rightX = rect.left;
              WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                setState(() {});
              });
            },
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
          item('topLeftTo', Colors.green).applyConstraint(
            topLeftTo: rId(1),
          ),
          item('topCenterTo', Colors.green).applyConstraint(
            topCenterTo: rId(1),
          ),
          item('topRightTo', Colors.green).applyConstraint(
            topRightTo: rId(1),
          ),
          item('centerLeftTo', Colors.green).applyConstraint(
            centerLeftTo: rId(1),
          ),
          item('centerTo', Colors.green).applyConstraint(
            centerTo: rId(1),
          ),
          item('centerRightTo', Colors.green).applyConstraint(
            centerRightTo: rId(1),
          ),
          item('bottomLeftTo', Colors.green).applyConstraint(
            bottomLeftTo: rId(1),
          ),
          item('bottomCenterTo', Colors.green).applyConstraint(
            bottomCenterTo: rId(1),
          ),
          item('bottomRightTo', Colors.green).applyConstraint(
            bottomRightTo: rId(1),
          ),
          const Text(
            'The display area is overlapping\nPlease view it in full screen on the computer',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ).applyConstraint(
            topCenterTo: parent,
            margin: const EdgeInsets.only(
              top: 5,
            ),
            visibility: rightX - 1 < leftX ? visible : gone,
          ),
        ],
      ),
    );
  }
}
