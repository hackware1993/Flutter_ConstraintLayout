import 'package:flutter/material.dart';

import 'badge.dart';
import 'barrier.dart';
import 'complex_list.dart';
import 'guideline.dart';
import 'preprocess_complex_list.dart';
import 'summary.dart';

class ExampleHome extends StatelessWidget {
  const ExampleHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(
            'Flutter ConstraintLayout Example\nby hackeware',
            style: TextStyle(
              fontSize: 32,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          button('Summary', () {
            push(context, const SummaryExample());
          }),
          button('Guideline', () {
            push(context, const GuidelineExample());
          }),
          button('Barrier', () {
            push(context, const BarrierExample());
          }),
          button('ComplexList', () {
            push(context, const ComplexListExample());
          }),
          button('PreprocessComplexList', () {
            push(context, const PreprocessComplexListExample());
          }),
          button('Badge', () {
            push(context, const BadgeExample());
          }),
          const Spacer(),
          const Text(
            'Powered by Flutter Web & ConstraintLayout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  void push(BuildContext context, Widget widget) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return widget;
    }));
  }

  Widget button(String title, GestureTapCallback callback) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: TextButton(
        onPressed: callback,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
