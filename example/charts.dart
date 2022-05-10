import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class ChartsExample extends StatefulWidget {
  const ChartsExample({Key? key}) : super(key: key);

  @override
  State createState() => ChartsState();
}

class DotPainter extends CustomPainter {
  const DotPainter();

  @override
  bool shouldRepaint(DotPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5;
    double dashSpace = 2;
    Paint paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.red;
    double offset = 0;
    while (offset < size.width) {
      canvas.drawLine(Offset(offset, 0), Offset(offset + dashWidth, 0), paint);
      offset += dashWidth + dashSpace;
    }
  }
}

class PolylinePainter extends CustomPainter {
  Map<int, Rect> polylineData;

  PolylinePainter(this.polylineData);

  @override
  bool shouldRepaint(PolylinePainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.green;
    List<Rect> rectList = polylineData.values.toList();
    Rect last = rectList[0];
    Rect current;
    for (int i = 1; i < rectList.length; i++) {
      current = rectList[i];
      canvas.drawLine(
          Offset(last.left + last.width / 2, last.top + last.height),
          Offset(
              current.left + current.width / 2, current.top + current.height),
          paint);
      last = current;
    }
  }
}

class ChartsState extends State<ChartsExample> {
  late List<String> xTitles;
  late List<int> data;
  late List<int> compareData;
  late int maxValue;
  int current = 6;
  Map<int, Rect> polylineData = HashMap();

  @override
  void initState() {
    super.initState();
    xTitles = [for (int i = 0; i < 60; i++) '$i'.padLeft(2, '0') + ':00'];
    Random random = Random();
    data = [for (int i = 0; i < xTitles.length; i++) 10 + random.nextInt(91)];
    compareData = data.toList()..shuffle();
    maxValue = data.reduce(max);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Charts',
        codePath: 'example/charts.dart',
      ),
      body: SingleChildScrollView(
        child: ConstraintLayout(
          width: wrapContent,
          children: [
            Container(
              color: Colors.black,
              child: const Text(
                'Only shows the flexibility of Flutter ConstraintLayout\nplease use as appropriate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ).applyConstraint(
              topLeftTo: parent,
            ),
            Container(
              color: Colors.black,
            ).applyConstraint(
              height: 1,
              width: matchParent,
              bottom: parent.bottom.margin(32),
            ),
            for (int i = 0; i < 8; i++)
              const CustomPaint(
                painter: DotPainter(),
              ).applyConstraint(
                height: 1,
                width: matchParent,
                bottom: parent.bottom.margin(100 * (i + 1).toDouble()),
              ),
            for (int i = 0; i < data.length; i++)
              GestureDetector(
                onTap: () {
                  setState(() {
                    current = i;
                  });
                },
                child: Container(
                  color: i == current ? Colors.deepOrange : Colors.orangeAccent,
                ),
              ).applyConstraint(
                id: cId('data$i'),
                width: 18,
                height: (data[i] / maxValue) * 400,
                left: (i == 0 ? parent.left : cId('data${i - 1}').right)
                    .margin(44),
                bottom: parent.bottom.margin(33),
              ),
            const SizedBox().applyConstraint(
              width: 0,
              left: cId('data${data.length - 1}').right.margin(44),
              bottom: parent.bottom,
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
                bottom: parent.bottom.margin(15),
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
            ).applyConstraint(
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
                callback: (_, rect) {
                  polylineData[i] = rect;
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
            ),
          ],
        ),
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
