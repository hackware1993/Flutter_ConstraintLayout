import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class ChartsExample extends StatefulWidget {
  const ChartsExample({Key? key}) : super(key: key);

  @override
  State createState() => ChartsState();
}

class PolylinePainter extends CustomPainter {
  List<Offset> polylineData;

  PolylinePainter(this.polylineData);

  @override
  bool shouldRepaint(PolylinePainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.green;
    canvas.drawPoints(PointMode.polygon, polylineData, paint);
  }
}

class ChartsState extends State<ChartsExample> {
  late List<String> xTitles;
  late List<int> data;
  late List<int> compareData;
  late int maxValue;
  int current = 6;
  late List<Offset> polylineData;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    xTitles = [for (int i = 0; i < 60; i++) '$i'.padLeft(2, '0') + ':00'];
    Random random = Random();
    data = [for (int i = 0; i < xTitles.length; i++) 10 + random.nextInt(91)];
    compareData = data.toList()..shuffle();
    maxValue = data.reduce(max);
    polylineData = List.filled(data.length, Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Charts',
        codePath: 'example/charts.dart',
      ),
      body: Scrollbar(
        isAlwaysShown: true,
        controller: controller,
        child: SingleChildScrollView(
          controller: controller,
          child: ConstraintLayout(
            width: wrapContent,
            children: [
              Container(
                color: Colors.black,
                child: const Text(
                  'Only shows the flexibility of Flutter ConstraintLayout\nplease use as appropriate\nswipe right to see all chart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ).applyConstraint(
                topCenterTo: parent,
              ),
              Container(
                color: Colors.black,
              ).applyConstraint(
                id: cId('yAxis'),
                height: 1,
                width: matchParent,
                bottom: parent.bottom.margin(40),
              ),
              for (int i = 0; i < 8; i++)
                Container(
                  color: Colors.grey.withAlpha(80),
                ).applyConstraint(
                  height: 1,
                  width: matchParent,
                  bottom: cId('yAxis').bottom.margin(100 * (i + 1).toDouble()),
                ),
              for (int i = 0; i < data.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      current = i;
                    });
                  },
                  child: MouseRegion(
                    child: Container(
                      color: i == current
                          ? Colors.deepOrange
                          : Colors.orangeAccent,
                    ),
                    cursor: SystemMouseCursors.click,
                  ),
                ).applyConstraint(
                  id: cId('data$i'),
                  width: 18,
                  height: (data[i] / maxValue) * 400,
                  left: parent.left.margin((i + 1) * 44),
                  bottom: parent.bottom.margin(41),
                ),
              const SizedBox().applyConstraint(
                width: 0,
                left: cId('data${data.length - 1}').right.margin(44),
                bottom: parent.bottom.margin(41),
              ),
              for (int i = 0; i < xTitles.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      current = i;
                    });
                  },
                  child: Text(
                    xTitles[i],
                    style: TextStyle(
                      color: i == current ? Colors.black : Colors.grey,
                    ),
                  ),
                ).applyConstraint(
                  top: cId('yAxis').bottom,
                  centerHorizontalTo: cId('data$i'),
                ),
              Container(
                color: Colors.blue,
              ).applyConstraint(
                outTopCenterTo: cId('data$current'),
                top: parent.top,
                width: 1,
                height: matchConstraint,
              ),
              CustomPaint(
                painter: PolylinePainter(polylineData),
              ).offPaint().applyConstraint(
                    width: matchParent,
                    height: matchParent,
                    eIndex: 0,
                  ),
              for (int i = 0; i < compareData.length; i++)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      width: 1,
                      color: Colors.green,
                    ),
                  ),
                ).applyConstraint(
                  size: 10,
                  bottomCenterTo: cId('data$i')
                      .bottomMargin((compareData[i] / maxValue) * 400),
                  translate: const Offset(0, 0.5),
                  percentageTranslate: true,
                  layoutCallback: (_, rect) {
                    polylineData[i] = rect.bottomCenter;
                  },
                ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Text(
                  '${data[current]}',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                padding: const EdgeInsets.all(5),
              ).applyConstraint(
                outTopCenterTo: cId('data$current').bottomMargin(33),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Text(
                  '${compareData[current]}',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                padding: const EdgeInsets.all(5),
              ).applyConstraint(
                outTopCenterTo: cId('data$current').bottomMargin(65),
              )
            ],
          ),
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}
