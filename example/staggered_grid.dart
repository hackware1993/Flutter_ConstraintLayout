import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class StaggeredGridExample extends StatelessWidget {
  const StaggeredGridExample({Key? key}) : super(key: key);

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
    const double smallestSize = 40;
    const int columnCount = 8;
    Random random = Random();
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Staggered Grid',
        codePath: 'example/staggered_grid.dart',
      ),
      body: ConstraintLayout(
        children: [
          TextButton(
            onPressed: () {
              (context as Element).markNeedsBuild();
            },
            child: const Text(
              'Upset',
              style: TextStyle(
                fontSize: 32,
                height: 1.5,
              ),
            ),
          ).applyConstraint(
            left: ConstraintId('horizontalList').right,
            top: ConstraintId('horizontalList').top,
          ),
          ...constraintGrid(
              id: ConstraintId('horizontalList'),
              left: parent.left,
              top: parent.top,
              itemCount: 50,
              columnCount: columnCount,
              itemBuilder: (index, _, __) {
                return Container(
                  color: colors[index % colors.length],
                  alignment: Alignment.center,
                  child: Text('$index'),
                );
              },
              itemSizeBuilder: (index, _, __) {
                if (index == 0) {
                  return const Size(
                      smallestSize * columnCount + 35, smallestSize);
                }
                if (index == 6) {
                  return const Size(smallestSize * 2 + 5, smallestSize);
                }
                if (index == 7) {
                  return const Size(smallestSize * 6 + 25, smallestSize);
                }
                if (index == 19) {
                  return const Size(smallestSize * 2 + 5, smallestSize);
                }
                if (index == 29) {
                  return const Size(smallestSize * 3 + 10, smallestSize);
                }
                return Size(
                    smallestSize, (2 + random.nextInt(4)) * smallestSize);
              },
              itemSpanBuilder: (index) {
                if (index == 0) {
                  return columnCount;
                }
                if (index == 6) {
                  return 2;
                }
                if (index == 7) {
                  return 6;
                }
                if (index == 19) {
                  return 2;
                }
                if (index == 29) {
                  return 3;
                }
                return 1;
              },
              itemMarginBuilder: (index, _, __) {
                return const EdgeInsets.only(
                  left: 5,
                  top: 5,
                );
              })
        ],
      ),
    );
  }
}
