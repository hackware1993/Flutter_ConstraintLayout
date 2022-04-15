import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

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

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'ComplexList',
        codePath: 'example/complex_list.dart',
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Text(
              'Very complex item view can also achieve full fps',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
              ),
              textAlign: TextAlign.center,
            );
          }
          return ConstraintLayout(
            children: [
              Container(
                color: colors[index % 6],
              ).applyConstraint(
                width: matchParent,
                height: matchParent,
              ),
              Image.asset(
                'assets/test.webp',
                fit: BoxFit.fill,
              ).applyConstraint(
                width: 100,
                centerLeftTo: parent,
              ),
              Image.asset(
                'assets/test2.webp',
                fit: BoxFit.fill,
              ).applyConstraint(
                width: 150,
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
          );
        },
        itemCount: 10000,
        itemExtent: 80,
      ),
    );
  }
}
