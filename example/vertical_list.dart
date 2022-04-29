import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class VerticalListExample extends StatelessWidget {
  const VerticalListExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      Colors.redAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.yellow,
      Colors.pink,
      Colors.lightBlueAccent
    ];
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Vertical List',
        codePath: 'example/vertical_list.dart',
      ),
      body: ConstraintLayout(
        children: [
          ...constraintGrid(
              id: ConstraintId('verticalList'),
              left: parent.left,
              top: parent.top,
              margin: const EdgeInsets.only(
                left: 100,
                top: 100,
              ),
              itemCount: 20,
              columnCount: 1,
              itemBuilder: (index, _, __) {
                return Container(
                  color: colors[index % colors.length],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Text('child $index'),
                );
              },
              itemSizeBuilder: (index, _, __) {
                return const Size(100, wrapContent);
              },
              itemMarginBuilder: (index, _, __) {
                return const EdgeInsets.only(
                  left: 10,
                  top: 10,
                );
              })
        ],
      ),
    );
  }
}
