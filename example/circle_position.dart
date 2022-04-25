import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class CirclePositionExample extends StatefulWidget {
  const CirclePositionExample({Key? key}) : super(key: key);

  @override
  State createState() => CirclePositionExampleState();
}

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
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
      appBar: const CustomAppBar(
        title: 'Circle Position',
        codePath: 'example/circle_position.dart',
      ),
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
            Container(
              alignment: Alignment.center,
              child: Text(
                '${i + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ).applyConstraint(
              width: 50,
              height: 50,
              centerTo: rId(0),
              translate: circleTranslate(
                radius: 200,
                angle: (i + 1) * 30,
              ),
            ),
          for (int i = 0; i < 60; i++)
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
              visibility: i % 5 == 0 ? gone : visible,
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
