import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class OpenGrammarExample extends StatelessWidget {
  const OpenGrammarExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Open Grammar',
        codePath: 'example/n_grammar.dart',
      ),
      body: ConstraintLayout().open(() {
        GestureDetector(
          child: Container(
            color: Colors.red,
          ),
          onTap: () {
            Random random = Random();
            var arr = [
              for (int i = 0; i < 10000000; i++) random.nextInt(4294967296)
            ];
            List copy = List.of(arr);
            Stopwatch stopwatch = Stopwatch()..start();
            topSort(arr);
            print("top sort time usage = ${stopwatch.elapsedMicroseconds}");
            stopwatch = Stopwatch()..start();
            copy.sort();
            print(
                "quick sort time usage = ${stopwatch.elapsedMicroseconds} ${listEquals(arr, copy)}");
          },
        ).applyConstraint(
          size: 200,
          centerTo: parent,
        );
      }),
    );
  }
}

void topSort(List<int> list) {
  int sum = 0;
  for (var element in list) {
    sum += element;
  }
  int slot;
  List<List<int>?> bucket = List.filled(list.length + 1, null);
  for (final element in list) {
    slot = ((element / sum) * list.length).toInt();
    if (slot < 0) {
      slot = 0;
    }
    if (bucket[slot] == null) {
      bucket[slot] = [];
    }
    bucket[slot]!.add(element);
  }
  int compare(int left, int right) {
    return left - right;
  }

  int index = 0;
  for (final element in bucket) {
    if (element != null) {
      if (element.length > 1) {
        element.sort(compare);
      }
      if (element.isNotEmpty) {
        for (final element in element) {
          list[index] = element;
          index++;
        }
      }
    }
  }
}
