import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

class ComplexListExample extends StatelessWidget {
  const ComplexListExample({Key? key}) : super(key: key);

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
    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          itemBuilder: (context, index) {
            return Container(
              child: ConstraintLayout(
                children: [
                  Image.asset(
                    'assets/test.png',
                    fit: BoxFit.fill,
                  ).applyConstraint(
                    width: 100,
                    height: wrapContent,
                    centerLeftTo: parent,
                  ),
                  Image.asset(
                    'assets/test2.png',
                    fit: BoxFit.fill,
                  ).applyConstraint(
                    width: 150,
                    height: wrapContent,
                    centerRightTo: parent,
                  ),
                  Text(
                    'topLeft $index',
                    style: style,
                  ).applyConstraint(
                    topLeftTo: parent,
                  ),
                  Text(
                    'topCenter $index',
                    style: style,
                  ).applyConstraint(
                    topCenterTo: parent,
                  ),
                  Text(
                    'topRight $index',
                    style: style,
                  ).applyConstraint(
                    topRightTo: parent,
                  ),
                  Text(
                    'centerLeft $index',
                    style: style,
                  ).applyConstraint(
                    centerLeftTo: parent,
                  ),
                  Text(
                    'center $index',
                    style: style,
                  ).applyConstraint(
                    centerTo: parent,
                  ),
                  Text(
                    'centerRight $index',
                    style: style,
                  ).applyConstraint(
                    centerRightTo: parent,
                  ),
                  Text(
                    'bottomLeft $index',
                    style: style,
                  ).applyConstraint(
                    bottomLeftTo: parent,
                  ),
                  Text(
                    'bottomCenter $index',
                    style: style,
                  ).applyConstraint(
                    bottomCenterTo: parent,
                  ),
                  Text(
                    'bottomRight $index',
                    style: style,
                  ).applyConstraint(
                    bottomRightTo: parent,
                  )
                ],
              ),
              color: colors[index % 6],
              margin: const EdgeInsets.only(
                top: 10,
              ),
            );
          },
          itemCount: 10000,
          itemExtent: 80,
        ),
      ),
    );
  }
}
