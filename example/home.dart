import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'badge.dart';
import 'barrier.dart';
import 'complex_list.dart';
import 'dimension_ratio.dart';
import 'grid.dart';
import 'guideline.dart';
import 'horizontal_list.dart';
import 'percentage_layout.dart';
import 'relative_id.dart';
import 'summary.dart';
import 'vertical_list.dart';
import 'wrapper_constraints.dart';

class ExampleHome extends StatelessWidget {
  ExampleHome({Key? key}) : super(key: key);

  final Map<String, Widget?> exampleMap = {
    'Summary': const SummaryExample(),
    'Guideline': const GuidelineExample(),
    'Barrier': const BarrierExample(),
    'ComplexList': const ComplexListExample(),
    'Badge': const BadgeExample(),
    'PercentageLayout': const PercentageLayoutExample(),
    'DimensionRatio': const DimensionRatioExample(),
    'Relative Id': const RelativeIdExample(),
    'Wrapper Constraints': const WrapperConstraintsExample(),
    'Grid': const GridExample(),
    'Horizontal List': const HorizontalListExample(),
    'Vertical List': const VerticalListExample(),
    'Chain (Coming soon)': null,
  };

  @override
  Widget build(BuildContext context) {
    List<String> keyList = exampleMap.keys.toList();
    return Scaffold(
      body: ConstraintLayout(
        children: [
          const Text(
            'Flutter ConstraintLayout Example\nby hackeware',
            style: TextStyle(
              fontSize: 32,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).applyConstraint(
            topCenterTo: parent,
          ),
          ...constraintGrid(
            id: ConstraintId('example_list'),
            margin: const EdgeInsets.only(
              top: 20,
            ),
            left: parent.left,
            top: rId(0).bottom,
            itemCount: 13,
            columnCount: 1,
            itemWidth: matchParent,
            itemHeight: 40,
            itemBuilder: (index) {
              Widget? example = exampleMap[keyList[index]];
              return TextButton(
                onPressed: example == null
                    ? null
                    : () {
                        push(context, example);
                      },
                child: Text(
                  keyList[index],
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              );
            },
          ),
          const Text(
            'Powered by Flutter Web & ConstraintLayout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).applyConstraint(
            bottomCenterTo: parent,
            margin: const EdgeInsets.only(
              bottom: 20,
            ),
          ),
        ],
      ),
    );
  }

  void push(BuildContext context, Widget widget) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return widget;
    }));
  }
}
