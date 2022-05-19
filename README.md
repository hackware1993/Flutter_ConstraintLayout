# Star History

[![Star History Chart](https://api.star-history.com/svg?repos=hackware1993/Flutter_ConstraintLayout&type=Date)](https://star-history.com/#hackware1993/Flutter_ConstraintLayout)

# Flutter ConstraintLayout

[简体中文](https://github.com/hackware1993/flutter-constraintlayout/blob/master/README_CN.md)

A super powerful Stack, build flexible layouts with constraints. Similar to ConstraintLayout for
Android and AutoLayout for iOS. But the code implementation is much more efficient, it has O(n)
layout time complexity and no linear equation solving is required.

**It surpasses traditional nested writing in terms of performance, flexibility, development speed,
and maintainability. It pretty much negates the O(2n) layout algorithm of Intrinsic Measurement.**

**It is a layout and a more modern general layout framework.**

# Greatly improve Flutter development experience and efficiency. Improve application performance

No matter how complex the layout is and how deep the constraints are, it has almost the same
performance as a single Flex or Stack. When facing complex layouts, it provides better performance,
flexibility, and a very flat code hierarchy than Flex and Stack. Say no to 'nested hell'.

In short, once you use it, you can't go back.

Improving "nested hell" is one of my original intentions for developing Flutter ConstraintLayout,
but I don't advocate the ultimate pursuit of one level of nesting, which is unnecessary. So features
like chains are already well supported by Flex itself, so ConstraintLayout will not actively support
it.

View [Flutter Web Online Example](https://constraintlayout.flutterfirst.cn)

**Flutter ConstraintLayout has extremely high layout performance. It does not require linear
equations to solve.** At any time, each child element will only be laid out once. When its own width
or height is set to wrapContent, some child elements may calculate the offset twice. The layout
process of ConstraintLayout consists of the following three steps:

1. Constraint calculation
2. Layout
3. Draw

The performance of layout and drawing is almost equivalent to a single Flex or Stack, and the
performance of constraint calculation is roughly 0.01 milliseconds (layout of general complexity, 20
child elements). Constraints are only recalculated after they have changed.

ConstraintLayout itself can be arbitrarily nested without performance issues, each child element in
the render tree is only laid out once, and the time complexity is O(n) instead of O(2n) or worse.

A smaller Widget tree leads to less build time and a smaller Element tree. A very flat layout
structure results in a smaller RenderObject tree and less rendering time. One thing most people tend
to overlook is that complex nesting can cause build times to sometimes exceed render times.

It is recommended to use ConstraintLayout at the top level. For extremely complex layout(one
thousand child elements, two thousand constraints), layout and drawing total time within 5
milliseconds(debug mode on Windows 10，release mode take less time), the frame rate can be easily
reached 200 fps.

**If not necessary, try to be relative to the parent layout, so that you can define less id. Or use
relative id.**

**Warning**:
For layout performance considerations, constraints are always one-way, and there should be no two
child elements directly or indirectly restrain each other(for example, the right side of A is
constrained to the left side of B, and the left side of B is in turn constrained to A right). Each
constraint should describe exactly where the child elements are located. Although constraints can
only be one-way, you can still better handle things that were previously (Android ConstraintLayout)
two-way constraints, such as chains(not yet supported, please use with Flex).

# Feature

1. build flexible layouts with constraints
    1. left
        1. toLeft
        2. toCenter(with bias, the default value is 0.5)
        3. toRight
    2. right
        1. toLeft
        2. toCenter(with bias, the default value is 0.5)
        3. toRight
    3. top
        1. toTop
        2. toCenter(with bias, the default value is 0.5)
        3. toBottom
    4. bottom
        1. toTop
        2. toCenter(with bias, the default value is 0.5)
        3. toBottom
    5. baseline
        1. toTop
        2. toCenter(with bias, the default value is 0.5)
        3. toBaseline
        4. toBottom
2. margin and goneMargin(when the visibility of the dependent element is gone or the actual size of
   one side is 0, the goneMargin will take effect, otherwise the margin will take effect, even if
   its own visibility is gone)
3. clickPadding(quickly expand the click area of child elements without changing their actual size.
   This means that you can completely follow the layout of the UI prototype without having to think
   about the click area of the element. This also means that the click area can be shared between
   child elements without increasing nesting. Sometimes it may be necessary to combine with e-index)
4. visibility control
    1. visible
    2. invisible
    3. gone(sometimes it may be better to use a conditional expression to keep the element from
       being created)
5. constraint integrity hint
6. bias(when there are constraints left and right or top and bottom, horizontalBias and verticalBias
   can be used to adjust the offset. The default value is 0.5, which means centering)
7. z-index(drawing order, default is child index)
8. translate、rotate
9. percentage layout(when size is set to matchConstraint, the percentage layout will take effect,
   the default percentage is 1 (100%). The relevant properties are widthPercent, heightPercent,
   widthPercentageAnchor, heightPercentageAnchor)
10. guideline
11. constraints and widgets separation
12. barrier
13. dimension ratio
    1. widthHeightRatio: 1 / 3,
    2. ratioBaseOnWidth: true, (the default value is null, which means automatic inference. The size
       of the undetermined side will be calculated using the determined side based on the aspect
       ratio. The undetermined side must be matchConstraint, and the determined side can be
       matchParent, fixed size(>=0), matchConstraint)
14. relative id(if an id is defined for a child element, it cannot be referenced using a relative
    id)
    1. rId(3) represents the 3th child element, and so on
    2. sId(-1) represents the previous sibling element, and so on
    3. sId(1) represents the next sibling element, and so on
15. wrapper constraints
    1. topLeftTo
    2. topCenterTo
    3. topRightTo
    4. centerLeftTo
    5. centerTo
    6. centerRightTo
    7. bottomLeftTo
    8. bottomCenterTo
    9. bottomRightTo
    10. centerHorizontalTo
    11. centerVerticalTo
    12. outTopLeftTo
    13. outTopCenterTo
    14. outTopRightTo
    15. outCenterLeftTo
    16. outCenterRightTo
    17. outBottomLeftTo
    18. outBottomCenterTo
    19. outBottomRightTo
    20. centerTopLeftTo
    21. centerTopCenterTo
    22. centerTopRightTo
    23. centerCenterLeftTo
    24. centerCenterRightTo
    25. centerBottomLeftTo
    26. centerBottomCenterTo
    27. centerBottomRightTo
16. staggered grid、grid、list(list is a special staggered grid, grid is also a special staggered
    grid)
17. circle position
18. pinned position
19. arbitrary position
20. e-index(event dispatch order, default is z-index)
21. the size of child widgets can be set to:
    1. fixed size(>=0)
    2. matchParent
    3. wrapContent(default, minimum and maximum supported)
    4. matchConstraint
22. the size of itself can be set to:
    1. fixed size(>=0)
    2. matchParent(default)
    3. wrapContent(minimum and maximum are temporarily not supported)
23. layout debugging
    1. showHelperWidgets
    2. showClickArea
    3. showZIndex
    4. showChildDepth
    5. debugPrintConstraints
    6. showLayoutPerformanceOverlay

Follow-up development plan:

1. chain
2. constraints visualization
3. provides a visual editor to create layouts by dragging and dropping
4. automatically convert design drafts into code
5. more…

Subscribe to my WeChat official account to get the latest news of ConstraintLayout. Follow-up will
also share some high-quality, unique, and thoughtful Flutter technical articles.
![official_account.webp](https://github.com/hackware1993/flutter-constraintlayout/blob/master/official_account.webp?raw=true)

Currently, I am developing a new declarative UI framework weiV(pronounced the same as wave) for
Android based on the View system. It has the following advantages:

1. Declarative UI writing doubles the efficiency of native development
2. Meets or exceeds the performance of the View system
    1. I ported my Flutter ConstraintLayout to Android, relying on its advanced layout algorithm,
       without introducing Intrinsic Measurement, so that the child elements in the View tree will
       only be laid out once in any case, making arbitrary nesting does not cause performance
       issues. Even if each level in the View tree is a mix of wrap_content and match_parent
    2. xml will be discarded
3. All your existing View system experience will be retained
4. All existing UI components will be reused
5. It is written in Kotlin but supports Java friendly

**No one wants to overturn their past experience with the View system, Compose's design is too
bad.**

[weiV GitHub Home Page](https://github.com/hackware1993/weiV)

Subscribe to my WeChat official account to get the latest news of weiV.

Support platform:

1. Android
2. iOS
3. Mac
4. Windows
5. Linux
6. Web

# Import

Null-safety

```yaml
dependencies:
  flutter_constraintlayout:
    git:
      url: 'https://github.com/hackware1993/Flutter-ConstraintLayout.git'
      ref: 'v1.5.2-stable'
```

```yaml
dependencies:
  flutter_constraintlayout: ^1.5.2-stable
```

```dart
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
```

# Example [Flutter Web Online Example](https://constraintlayout.flutterfirst.cn)

![effect.gif](https://github.com/hackware1993/flutter-constraintlayout/blob/master/effect.gif?raw=true)

```dart
class SummaryExampleState extends State<SummaryExample> {
  double x = 0;
  double y = 0;

  ConstraintId box0 = ConstraintId('box0');
  ConstraintId box1 = ConstraintId('box1');
  ConstraintId box2 = ConstraintId('box2');
  ConstraintId box3 = ConstraintId('box3');
  ConstraintId box4 = ConstraintId('box4');
  ConstraintId box5 = ConstraintId('box5');
  ConstraintId box6 = ConstraintId('box6');
  ConstraintId box7 = ConstraintId('box7');
  ConstraintId box8 = ConstraintId('box8');
  ConstraintId box9 = ConstraintId('box9');
  ConstraintId box10 = ConstraintId('box10');
  ConstraintId box11 = ConstraintId('box11');
  ConstraintId barrier = ConstraintId('barrier');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Summary',
        codePath: 'example/summary.dart',
      ),
      backgroundColor: Colors.black,
      body: ConstraintLayout(
        // Constraints can be separated from widgets
        childConstraints: [
          Constraint(
            id: box0,
            size: 200,
            bottomLeftTo: parent,
            zIndex: 20,
          )
        ],
        children: [
          Container(
            color: Colors.redAccent,
            alignment: Alignment.center,
            child: const Text('box0'),
          ).applyConstraintId(
            id: box0, // Constraints can be separated from widgets
          ),
          Container(
            color: Colors.redAccent,
            alignment: Alignment.center,
            child: const Text('box1'),
          ).apply(
            constraint: Constraint(
              // Constraints set with widgets
              id: box1,
              width: 200,
              height: 100,
              topRightTo: parent,
            ),
          ),
          Container(
            color: Colors.blue,
            alignment: Alignment.center,
            child: const Text('box2'),
          ).applyConstraint(
            // Constraints set with widgets easy way
            id: box2,
            size: matchConstraint,
            centerHorizontalTo: box3,
            top: box3.bottom,
            bottom: parent.bottom,
          ),
          Container(
            color: Colors.orange,
            width: 200,
            height: 150,
            alignment: Alignment.center,
            child: const Text('box3'),
          ).applyConstraint(
            id: box3,
            right: box1.left,
            top: box1.bottom,
          ),
          Container(
            color: Colors.redAccent,
            alignment: Alignment.center,
            child: const Text('box4'),
          ).applyConstraint(
            id: box4,
            size: 50,
            bottomRightTo: parent,
          ),
          GestureDetector(
            child: Container(
              color: Colors.pink,
              alignment: Alignment.center,
              child: const Text('box5 draggable'),
            ),
            onPanUpdate: (details) {
              setState(() {
                x += details.delta.dx;
                y += details.delta.dy;
              });
            },
          ).applyConstraint(
            id: box5,
            width: 120,
            height: 100,
            centerTo: parent,
            zIndex: 100,
            translate: Offset(x, y),
            translateConstraint: true,
          ),
          Container(
            color: Colors.lightGreen,
            alignment: Alignment.center,
            child: const Text('box6'),
          ).applyConstraint(
            id: box6,
            size: 120,
            centerVerticalTo: box2,
            verticalBias: 0.8,
            left: box3.right,
            right: parent.right,
          ),
          Container(
            color: Colors.lightGreen,
            alignment: Alignment.center,
            child: const Text('box7'),
          ).applyConstraint(
            id: box7,
            size: matchConstraint,
            left: parent.left,
            right: box3.left,
            centerVerticalTo: parent,
            margin: const EdgeInsets.all(50),
          ),
          Container(
            color: Colors.cyan,
            alignment: Alignment.center,
            child: const Text('child[7] pinned to the top right'),
          ).applyConstraint(
            width: 200,
            height: 100,
            left: box5.right,
            bottom: box5.top,
          ),
          const Text(
            'box9 baseline to box7',
            style: TextStyle(
              color: Colors.white,
            ),
          ).applyConstraint(
            id: box9,
            baseline: box7.baseline,
            left: box7.left,
          ),
          Container(
            color: Colors.yellow,
            alignment: Alignment.bottomCenter,
            child: const Text(
                'percentage layout\nwidth: 50% of parent\nheight: 30% of parent'),
          ).applyConstraint(
            size: matchConstraint,
            widthPercent: 0.5,
            heightPercent: 0.3,
            horizontalBias: 0,
            verticalBias: 0,
            centerTo: parent,
          ),
          Barrier(
            id: barrier,
            direction: BarrierDirection.left,
            referencedIds: [box6, box5],
          ),
          Container(
            color: const Color(0xFFFFD500),
            alignment: Alignment.center,
            child: const Text('align to barrier'),
          ).applyConstraint(
            width: 100,
            height: 200,
            top: box5.top,
            right: barrier.left,
          )
        ],
      ),
    );
  }
}
```

# Advanced usage

1. guideline [Flutter Web Online Example](https://constraintlayout.flutterfirst.cn)

![guideline.webp](https://github.com/hackware1993/flutter-constraintlayout/blob/master/guideline.webp?raw=true)

```dart
class GuidelineExample extends StatelessWidget {
  const GuidelineExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConstraintId guideline = ConstraintId('guideline');
    return MaterialApp(
      home: Scaffold(
        body: ConstraintLayout(
          children: [
            Container(
              color: const Color(0xFF005BBB),
            ).applyConstraint(
              width: matchParent,
              height: matchConstraint,
              top: parent.top,
              bottom: guideline.top,
            ),
            Guideline(
              id: guideline,
              horizontal: true,
              guidelinePercent: 0.5,
            ),
            Container(
              color: const Color(0xFFFFD500),
            ).applyConstraint(
              width: matchParent,
              height: matchConstraint,
              top: guideline.bottom,
              bottom: parent.bottom,
            ),
            const Text(
              'Stand with the people of Ukraine',
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
              ),
            ).applyConstraint(
              width: wrapContent,
              height: wrapContent,
              centerHorizontalTo: parent,
              bottom: guideline.bottom,
            )
          ],
        ),
      ),
    );
  }
}
```

2. barrier [Flutter Web Online Example](https://constraintlayout.flutterfirst.cn)

![barrier.gif](https://github.com/hackware1993/flutter-constraintlayout/blob/master/barrier.gif?raw=true)

```dart
class BarrierExample extends StatelessWidget {
  const BarrierExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConstraintId leftChild = ConstraintId('leftChild');
    ConstraintId rightChild = ConstraintId('rightChild');
    ConstraintId barrier = ConstraintId('barrier');
    return MaterialApp(
      home: Scaffold(
        body: ConstraintLayout(
          debugShowGuideline: true,
          children: [
            Container(
              color: const Color(0xFF005BBB),
            ).applyConstraint(
              id: leftChild,
              width: 200,
              height: 200,
              top: parent.top,
              left: parent.left,
            ),
            Container(
              color: const Color(0xFFFFD500),
            ).applyConstraint(
              id: rightChild,
              width: 200,
              height: matchConstraint,
              right: parent.right,
              top: parent.top,
              bottom: parent.bottom,
              heightPercent: 0.5,
              verticalBias: 0,
            ),
            Barrier(
              id: barrier,
              direction: BarrierDirection.bottom,
              referencedIds: [leftChild, rightChild],
            ),
            const Text(
              'Align to barrier',
              style: TextStyle(
                fontSize: 40,
                color: Colors.blue,
              ),
            ).applyConstraint(
              width: wrapContent,
              height: wrapContent,
              centerHorizontalTo: parent,
              top: barrier.bottom,
              goneMargin: const EdgeInsets.only(top: 20),
            )
          ],
        ),
      ),
    );
  }
}
```

3. badge [Flutter Web Online Example](https://constraintlayout.flutterfirst.cn)

![badge.webp](https://github.com/hackware1993/flutter-constraintlayout/blob/master/badge.webp?raw=true)

```dart
class BadgeExample extends StatelessWidget {
  const BadgeExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConstraintId anchor = ConstraintId('anchor');
    return Scaffold(
      body: ConstraintLayout(
        children: [
          Container(
            color: Colors.yellow,
          ).applyConstraint(
            width: 200,
            height: 200,
            centerTo: parent,
            id: anchor,
          ),
          Container(
            color: Colors.green,
            child: const Text(
              'Indeterminate badge size',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ).applyConstraint(
            left: anchor.right,
            bottom: anchor.top,
            translate: const Offset(-0.5, 0.5),
            percentageTranslate: true,
          ),
          Container(
            color: Colors.green,
          ).applyConstraint(
            width: 100,
            height: 100,
            left: anchor.right,
            right: anchor.right,
            top: anchor.bottom,
            bottom: anchor.bottom,
          )
        ],
      ),
    );
  }
}
```

4. grid [Flutter Web Online Example](https://constraintlayout.flutterfirst.cn)

![grid.webp](https://github.com/hackware1993/flutter-constraintlayout/blob/master/grid.webp?raw=true)

```dart
class GridExample extends StatelessWidget {
  const GridExample({Key? key}) : super(key: key);

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
      body: ConstraintLayout(
        children: [
          ...constraintGrid(
              id: ConstraintId('grid'),
              left: parent.left,
              top: parent.top,
              itemCount: 50,
              columnCount: 8,
              itemWidth: 50,
              itemHeight: 50,
              itemBuilder: (index) {
                return Container(
                  color: colors[index % colors.length],
                );
              },
              itemMarginBuilder: (index) {
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
```

5. staggered grid [Flutter Web Online Example](https://constraintlayout.flutterfirst.cn)

![staggered_grid.gif](https://github.com/hackware1993/flutter-constraintlayout/blob/master/staggered_grid.gif?raw=true)

```dart
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
              margin: const EdgeInsets.only(
                left: 100,
              ),
              itemCount: 50,
              columnCount: columnCount,
              itemBuilder: (index) {
                return Container(
                  color: colors[index % colors.length],
                  alignment: Alignment.center,
                  child: Text('$index'),
                );
              },
              itemSizeBuilder: (index) {
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
              itemMarginBuilder: (index) {
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
```

6. circle position [Flutter Web Online Example](https://constraintlayout.flutterfirst.cn)

![circle_position.gif](https://github.com/hackware1993/flutter-constraintlayout/blob/master/circle_position.gif?raw=true)

```dart
class CirclePositionExampleState extends State<CirclePositionExample> {
  late Timer timer;
  late int hour;
  late int minute;
  late int second;

  double centerTranslateX = 0;
  double centerTranslateY = 0;

  @override
  void initState() {
    super.initState();
    calculateClockAngle();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      calculateClockAngle();
    });
  }

  void calculateClockAngle() {
    setState(() {
      DateTime now = DateTime.now();
      hour = now.hour;
      minute = now.minute;
      second = now.second;
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstraintLayout(
        children: [
          GestureDetector(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(
                  Radius.circular(1000),
                ),
              ),
            ),
            onPanUpdate: (details) {
              setState(() {
                centerTranslateX += details.delta.dx;
                centerTranslateY += details.delta.dy;
              });
            },
          ).applyConstraint(
            width: 20,
            height: 20,
            centerTo: parent,
            zIndex: 100,
            translate: Offset(centerTranslateX, centerTranslateY),
            translateConstraint: true,
          ),
          for (int i = 0; i < 12; i++)
            Text(
              '${i + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ).applyConstraint(
              centerTo: rId(0),
              translate: circleTranslate(
                radius: 205,
                angle: (i + 1) * 30,
              ),
            ),
          for (int i = 0; i < 60; i++)
            if (i % 5 != 0)
              Transform.rotate(
                angle: pi + pi * (i * 6 / 180),
                child: Container(
                  color: Colors.grey,
                  margin: const EdgeInsets.only(
                    top: 405,
                  ),
                ),
              ).applyConstraint(
                width: 1,
                height: 415,
                centerTo: rId(0),
              ),
          Transform.rotate(
            angle: pi + pi * (hour * 30 / 180),
            alignment: Alignment.topCenter,
            child: Container(
              color: Colors.green,
            ),
          ).applyConstraint(
            width: 5,
            height: 80,
            centerTo: rId(0),
            translate: const Offset(0, 0.5),
            percentageTranslate: true,
          ),
          Transform.rotate(
            angle: pi + pi * (minute * 6 / 180),
            alignment: Alignment.topCenter,
            child: Container(
              color: Colors.pink,
            ),
          ).applyConstraint(
            width: 5,
            height: 120,
            centerTo: rId(0),
            translate: const Offset(0, 0.5),
            percentageTranslate: true,
          ),
          Transform.rotate(
            angle: pi + pi * (second * 6 / 180),
            alignment: Alignment.topCenter,
            child: Container(
              color: Colors.blue,
            ),
          ).applyConstraint(
            width: 5,
            height: 180,
            centerTo: rId(0),
            translate: const Offset(0, 0.5),
            percentageTranslate: true,
          ),
          Text(
            '$hour:$minute:$second',
            style: const TextStyle(
              fontSize: 40,
            ),
          ).applyConstraint(
            outTopCenterTo: rId(0),
            margin: const EdgeInsets.only(
              bottom: 250,
            ),
          )
        ],
      ),
    );
  }
}
```

7. margin [Flutter Web Online Example](https://constraintlayout.flutterfirst.cn)

![margin.webp](https://github.com/hackware1993/flutter-constraintlayout/blob/master/margin.webp?raw=true)

```dart
class MarginExample extends StatelessWidget {
  const MarginExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstraintLayout(
        children: [
          Container(
            color: const Color(0xFF005BBB),
          ).applyConstraint(
            size: 50,
            topLeftTo: parent,
            margin: const EdgeInsets.only(
              left: 20,
              top: 100,
            ),
          ),
          Container(
            color: const Color(0xFFFFD500),
          ).applyConstraint(
            size: 100,
            top: sId(-1).bottom,
            right: parent.right.margin(100),
          ),
          Container(
            color: Colors.pink,
          ).applyConstraint(
            size: 50,
            topRightTo: parent.rightMargin(20).topMargin(50),
          ),
        ],
      ),
    );
  }
}
```

8. pinned position [Flutter Web Online Example](https://constraintlayout.flutterfirst.cn)

![pinned_position.gif](https://github.com/hackware1993/flutter-constraintlayout/blob/master/pinned_position.gif?raw=true)

```dart
class PinnedPositionExampleState extends State<PinnedPositionExample> {
  late Timer timer;
  double angle = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        angle++;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    ConstraintId anchor = ConstraintId('anchor');
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Pinned Position',
        codePath: 'example/pinned_position.dart',
      ),
      body: ConstraintLayout(
        children: [
          Container(
            color: Colors.yellow,
          ).applyConstraint(
            id: anchor,
            size: 200,
            centerTo: parent,
          ),
          Container(
            color: Colors.cyan,
          ).applyConstraint(
            size: 100,
            pinnedInfo: PinnedInfo(
              anchor,
              Anchor(0.2, AnchorType.percent, 0.2, AnchorType.percent),
              Anchor(1, AnchorType.percent, 1, AnchorType.percent),
              angle: angle,
            ),
          ),
          Container(
            color: Colors.orange,
          ).applyConstraint(
            size: 60,
            pinnedInfo: PinnedInfo(
              anchor,
              Anchor(1, AnchorType.percent, 1, AnchorType.percent),
              Anchor(0, AnchorType.percent, 0, AnchorType.percent),
              angle: 360 - angle,
            ),
          ),
          Container(
            color: Colors.black,
          ).applyConstraint(
            size: 60,
            pinnedInfo: PinnedInfo(
              anchor,
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              angle: angle,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ).applyConstraint(
            size: 10,
            centerBottomRightTo: anchor,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ).applyConstraint(
            size: 10,
            centerTopLeftTo: anchor,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ).applyConstraint(
            size: 10,
            centerTo: anchor,
          )
        ],
      ),
    );
  }
}
```

9. translate [Flutter Web Online Example](https://constraintlayout.flutterfirst.cn)

![translate.gif](https://github.com/hackware1993/flutter-constraintlayout/blob/master/translate.gif?raw=true)

```dart
class TrackPainter extends CustomPainter {
  Queue<Offset> points = Queue();
  Paint painter = Paint();

  TrackPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPoints(PointMode.polygon, points.toList(), painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class TranslateExampleState extends State<TranslateExample> {
  late Timer timer;
  double angle = 0;
  double earthRevolutionAngle = 0;
  Queue<Offset> points = Queue();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        angle += 1;
        earthRevolutionAngle += 0.1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    ConstraintId anchor = ConstraintId('anchor');
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Translate',
        codePath: 'example/translate.dart',
      ),
      body: ConstraintLayout(
        children: [
          CustomPaint(
            painter: TrackPainter(points),
          ).applyConstraint(
            width: matchParent,
            height: matchParent,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.all(Radius.circular(1000)),
            ),
            child: const Text('----'),
            alignment: Alignment.center,
          ).applyConstraint(
            id: cId('sun'),
            size: 200,
            pinnedInfo: PinnedInfo(
              parent,
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              Anchor(0.3, AnchorType.percent, 0.5, AnchorType.percent),
              angle: earthRevolutionAngle * 365 / 25.4,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(1000)),
            ),
            child: const Text('----'),
            alignment: Alignment.center,
          ).applyConstraint(
            id: cId('earth'),
            size: 100,
            pinnedInfo: PinnedInfo(
              cId('sun'),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              angle: earthRevolutionAngle * 365,
            ),
            translate: circleTranslate(
              radius: 250,
              angle: earthRevolutionAngle,
            ),
            translateConstraint: true,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(1000)),
            ),
            child: const Text('----'),
            alignment: Alignment.center,
          ).applyConstraint(
            id: cId('moon'),
            size: 50,
            pinnedInfo: PinnedInfo(
              cId('earth'),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
              angle: earthRevolutionAngle * 365 / 27.32,
            ),
            translate: circleTranslate(
              radius: 100,
              angle: earthRevolutionAngle * 365 / 27.32,
            ),
            translateConstraint: true,
            paintCallback: (_, __, ____, offset, ______) {
              points.add(offset!);
              if (points.length > 2000) {
                points.removeFirst();
              }
            },
          ),
          Text('Sun rotates ${(earthRevolutionAngle * 365 / 25.4) ~/ 360} times')
              .applyConstraint(
            outTopCenterTo: cId('sun'),
          ),
          Text('Earth rotates ${earthRevolutionAngle * 365 ~/ 360} times')
              .applyConstraint(
            outTopCenterTo: cId('earth'),
          ),
          Text('Moon rotates ${(earthRevolutionAngle * 365 / 27.32) ~/ 360} times')
              .applyConstraint(
            outTopCenterTo: cId('moon'),
          ),
          Container(
            color: Colors.yellow,
          ).applyConstraint(
            id: anchor,
            size: 250,
            centerRightTo: parent.rightMargin(300),
          ),
          Container(
            color: Colors.red,
            child: const Text('pinned translate'),
          ).applyConstraint(
            centerTo: anchor,
            translate: PinnedTranslate(
              PinnedInfo(
                null,
                Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
                null,
                angle: angle,
              ),
            ),
          ),
          Container(
            color: Colors.blue,
            child: const Text('circle translate'),
          ).applyConstraint(
            size: wrapContent,
            centerTo: anchor,
            translate: circleTranslate(
              radius: 100,
              angle: angle,
            ),
          ),
          Container(
            color: Colors.cyan,
            child: const Text('pinned & circle translate'),
          ).applyConstraint(
            centerTo: anchor,
            translate: PinnedTranslate(
              PinnedInfo(
                null,
                Anchor(0.5, AnchorType.percent, 0.5, AnchorType.percent),
                null,
                angle: angle,
              ),
            ) +
                circleTranslate(
                  radius: 150,
                  angle: angle,
                ),
          ),
          Container(
            color: Colors.orange,
            child: const Text('normal translate'),
          ).applyConstraint(
            size: wrapContent,
            outBottomCenterTo: anchor,
            translate: Offset(0, angle / 5),
          )
        ],
      ),
    );
  }
}
```

# Performance optimization

1. When the layout is complex, if the child elements need to be repainted frequently, it is
   recommended to use RepaintBoundary to improve performance.

```dart
class OffPaintExample extends StatelessWidget {
  const OffPaintExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ConstraintLayout(
          children: [
            Container(
              color: Colors.orangeAccent,
            ).offPaint().applyConstraint(
              width: 200,
              height: 200,
              topRightTo: parent,
            )
          ],
        ),
      ),
    );
  }
}
```

2. Try to use const Widget. If you can't declare a child element as const and it won't change, you
   can use OffBuildWidget to avoid the rebuilding of the child element.

```dart
class OffBuildExample extends StatelessWidget {
  const OffBuildExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ConstraintLayout(
          children: [

            /// subtrees that do not change
            Container(
              color: Colors.orangeAccent,
            ).offBuild(id: 'id').applyConstraint(
              width: 200,
              height: 200,
              topRightTo: parent,
            )
          ],
        ),
      ),
    );
  }
}
```

3. Child elements will automatically become RelayoutBoundary unless width or height is wrapContent.
   The use of wrapContent can be reasonably reduced, because after the size of ConstraintLayout
   changes (usually the size of the window changes), all child elements whose width or height is
   wrapContent will be re-layout. And since the constraints passed to other child elements won't
   change, no real re-layout will be triggered.

4. If you use Guideline or Barrier in the children list, Element and RenderObject will inevitably be
   generated for them, which will be laid out but not drawn. At this point you can use
   GuidelineDefine or BarrierDefine to optimize it, no Element and RenderObject will be generated
   anymore:

```dart
class BarrierExample extends StatelessWidget {
  const BarrierExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConstraintId leftChild = ConstraintId('leftChild');
    ConstraintId rightChild = ConstraintId('rightChild');
    ConstraintId barrier = ConstraintId('barrier');
    return Scaffold(
      body: ConstraintLayout(
        childConstraints: [
          BarrierDefine(
            id: barrier,
            direction: BarrierDirection.bottom,
            referencedIds: [leftChild, rightChild],
          ),
        ],
        children: [
          Container(
            color: const Color(0xFF005BBB),
          ).applyConstraint(
            id: leftChild,
            width: 200,
            height: 200,
            topLeftTo: parent,
          ),
          Container(
            color: const Color(0xFFFFD500),
          ).applyConstraint(
            id: rightChild,
            width: 200,
            height: matchConstraint,
            centerRightTo: parent,
            heightPercent: 0.5,
            verticalBias: 0,
          ),
          const Text(
            'Align to barrier',
            style: TextStyle(
              fontSize: 40,
              color: Colors.blue,
            ),
          ).applyConstraint(
            centerHorizontalTo: parent,
            top: barrier.bottom,
          )
        ],
      ),
    );
  }
}   
```

5. Every frame, ConstraintLayout compares the parameters and decides the following things:
    1. Does the constraint need to be recalculated?
    2. Does it need to be relayout?
    3. Does it need to be redrawn?
    4. Do you need to rearrange the drawing order?
    5. Do you need to rearrange the order of event distribution?

These comparisons will not be a performance bottleneck, but will increase CPU usage. If you know
enough about the internals of ConstraintLayout, you can use ConstraintLayoutController to manually
trigger these operations to stop parameter comparison.

```dart
class ConstraintControllerExampleState extends State<ConstraintControllerExample> {
  double x = 0;
  double y = 0;
  ConstraintLayoutController controller = ConstraintLayoutController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Constraint Controller',
        codePath: 'example/constraint_controller.dart',
      ),
      body: ConstraintLayout(
        controller: controller,
        children: [
          GestureDetector(
            child: Container(
              color: Colors.pink,
              alignment: Alignment.center,
              child: const Text('box draggable'),
            ),
            onPanUpdate: (details) {
              setState(() {
                x += details.delta.dx;
                y += details.delta.dy;
                controller.markNeedsPaint();
              });
            },
          ).applyConstraint(
            size: 200,
            centerTo: parent,
            translate: Offset(x, y),
          )
        ],
      ),
    );
  }
}
```

# Extension

ConstraintLayout's constraint-based layout algorithm is extremely powerful and flexible, and it
seems that it can become a general layout framework. You just need to generate constraints and hand
over the task of layout to ConstraintLayout. Some built-in features like circle position, staggered
grid, grid, and list are available in extended form.

The charts in the online example is a typical extension:
![charts.gif](https://github.com/hackware1993/flutter-constraintlayout/blob/master/charts.gif?raw=true)
Extensions for ConstraintLayout are welcome.

# Support me

If it helps you a lot, consider sponsoring me a cup of milk tea, or giving a star. Your support is
the driving force for me to continue to maintain.
[Paypal](https://www.paypal.com/paypalme/hackware1993)
![support.webp](https://github.com/hackware1993/flutter-constraintlayout/blob/master/support.webp?raw=true)

Thanks to the following netizens for their sponsorship, let's make Flutter better and better
together.

1. 栢陶 2022.05.15
2. CaiGo 2022.05.17

# Contact

hackware1993@gmail.com

Subscribe to my WeChat official account to get the latest news of ConstraintLayout. Follow-up will
also share some high-quality, unique, and thoughtful Flutter technical articles.
![official_account.webp](https://github.com/hackware1993/flutter-constraintlayout/blob/master/official_account.webp?raw=true)

# License

```
MIT License

Copyright (c) 2022 hackware1993

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
