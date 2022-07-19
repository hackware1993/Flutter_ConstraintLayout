import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

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
      appBar: const CustomAppBar(
        title: 'Circle Position',
        codePath: 'lib/circle_position.dart',
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
            size: 20,
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
            top: rId(0).center,
            centerHorizontalTo: rId(0),
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
            top: rId(0).center,
            centerHorizontalTo: rId(0),
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
            top: rId(0).center,
            centerHorizontalTo: rId(0),
          ),
          Text(
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}',
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
