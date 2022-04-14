import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class PreprocessComplexListExample extends StatelessWidget {
  const PreprocessComplexListExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle style = const TextStyle(
      color: Colors.white,
    );

    List<Color> colors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.deepPurpleAccent,
      Colors.black,
      Colors.cyan,
      Colors.pink,
    ];

    ConstraintId background = ConstraintId('background');
    ConstraintId topLeft = ConstraintId('topLeft');
    ConstraintId topCenter = ConstraintId('topCenter');
    ConstraintId topRight = ConstraintId('topRight');
    ConstraintId centerLeft = ConstraintId('centerLeft');
    ConstraintId center = ConstraintId('center');
    ConstraintId centerRight = ConstraintId('centerRight');
    ConstraintId bottomLeft = ConstraintId('bottomLeft');
    ConstraintId bottomCenter = ConstraintId('bottomCenter');
    ConstraintId bottomRight = ConstraintId('bottomRight');
    ConstraintId leftImg = ConstraintId('leftImg');
    ConstraintId rightImg = ConstraintId('rightImg');

    List<Constraint> childConstraints = [
      Constraint(
        width: matchParent,
        height: matchParent,
        id: background,
      ),
      Constraint(
        width: 100,
        centerLeftTo: parent,
        id: leftImg,
      ),
      Constraint(
        width: 150,
        centerRightTo: parent,
        id: rightImg,
      ),
      Constraint(
        topLeftTo: parent,
        id: topLeft,
      ),
      Constraint(
        topCenterTo: parent,
        id: topCenter,
      ),
      Constraint(
        topRightTo: parent,
        id: topRight,
      ),
      Constraint(
        centerLeftTo: parent,
        id: centerLeft,
      ),
      Constraint(
        centerTo: parent,
        id: center,
      ),
      Constraint(
        centerRightTo: parent,
        id: centerRight,
      ),
      Constraint(
        bottomLeftTo: parent,
        id: bottomLeft,
      ),
      Constraint(
        bottomCenterTo: parent,
        id: bottomCenter,
      ),
      Constraint(
        bottomRightTo: parent,
        id: bottomRight,
      ),
    ];

    ChildConstraintsCache childConstraintsCache =
        ConstraintLayout.generateCache(childConstraints);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'PreprocessComplexList',
        codePath: 'example/preprocess_complex_list.dart',
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Text(
              """Constraints can also be calculated ahead of time so that they don't need to be calculated during layout""",
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
              ),
              textAlign: TextAlign.center,
            );
          }
          return ConstraintLayout(
            useCacheConstraints: true,
            childConstraints: childConstraints,
            childConstraintsCache: childConstraintsCache,
            children: [
              Container(
                color: colors[index % 6],
              ).applyConstraintId(
                id: background,
              ),
              Image.asset(
                'assets/test.webp',
                fit: BoxFit.fill,
              ).applyConstraintId(
                id: leftImg,
              ),
              Image.asset(
                'assets/test2.webp',
                fit: BoxFit.fill,
              ).applyConstraintId(
                id: rightImg,
              ),
              Text(
                'topLeft $index',
                style: style,
              ).applyConstraintId(
                id: topLeft,
              ),
              Text(
                'topCenter $index',
                style: style,
              ).applyConstraintId(
                id: topCenter,
              ),
              Text(
                'topRight $index',
                style: style,
              ).applyConstraintId(
                id: topRight,
              ),
              Text(
                'centerLeft $index',
                style: style,
              ).applyConstraintId(
                id: centerLeft,
              ),
              Text(
                'center $index',
                style: style,
              ).applyConstraintId(
                id: center,
              ),
              Text(
                'centerRight $index',
                style: style,
              ).applyConstraintId(
                id: centerRight,
              ),
              Text(
                'bottomLeft $index',
                style: style,
              ).applyConstraintId(
                id: bottomLeft,
              ),
              Text(
                'bottomCenter $index',
                style: style,
              ).applyConstraintId(
                id: bottomCenter,
              ),
              Text(
                'bottomRight $index',
                style: style,
              ).applyConstraintId(
                id: bottomRight,
              )
            ],
          );
        },
        itemCount: 10000,
        itemExtent: 80,
      ),
    );
  }
}
