import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'badge.dart';
import 'barrier.dart';
import 'circle_position.dart';
import 'coming_soon.dart';
import 'complex_list.dart';
import 'dimension_ratio.dart';
import 'grid.dart';
import 'guideline.dart';
import 'horizontal_list.dart';
import 'percentage_layout.dart';
import 'relative_id.dart';
import 'self_wrap_content.dart';
import 'staggered_grid.dart';
import 'summary.dart';
import 'vertical_list.dart';
import 'wrapper_constraints.dart';

class ExampleHome extends StatelessWidget {
  ExampleHome({Key? key}) : super(key: key);

  final Map<String, Widget?> exampleMap = {
    'Summary': const SummaryExample(),
    'Guideline': const GuidelineExample(),
    'Barrier': const BarrierExample(),
    'Complex List': const ComplexListExample(),
    'Badge': const BadgeExample(),
    'Percentage Layout': const PercentageLayoutExample(),
    'Dimension Ratio': const DimensionRatioExample(),
    'Relative Id': const RelativeIdExample(),
    'Wrapper Constraints': const WrapperConstraintsExample(),
    'Grid': const GridExample(),
    'Horizontal List': const HorizontalListExample(),
    'Vertical List': const VerticalListExample(),
    'Staggered Grid': const StaggeredGridExample(),
    'Circle Position': const CirclePositionExample(),
    'Self wrapContent': const SelfWrapContentExample(),
    'Chain (Coming soon)': const ComingSoonWidget(),
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
          ListView.builder(
            itemBuilder: (_, index) {
              return TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return exampleMap[keyList[index]]!;
                  }));
                },
                child: Text(
                  keyList[index],
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              );
            },
            itemCount: keyList.length,
            itemExtent: 40,
          ).applyConstraint(
            width: matchParent,
            height: matchConstraint,
            top: sId(-1).bottom,
            bottom: sId(1).top,
          ),
          const Text(
            'Powered by Flutter Web & ConstraintLayout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
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
}
