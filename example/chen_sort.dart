import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'custom_app_bar.dart';

class ChenSortExample extends StatefulWidget {
  const ChenSortExample({Key? key}) : super(key: key);

  @override
  State createState() => ChenSortExampleState();
}

class ChenSortExampleState extends State<ChenSortExample> {
  int defaultNumberCount = 10000;
  late TextEditingController numberCountController =
      TextEditingController(text: '$defaultNumberCount');
  List<String> sortResult = [];
  bool isSorting = false;
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Chen sort',
        codePath: 'example/chen_sort.dart',
      ),
      body: ConstraintLayout().open(() {
        const Text(
          'The time complexity is O(n), the space complexity is O(n), and it is stable',
          style: TextStyle(
            fontSize: 30,
          ),
        ).applyConstraint(
          topCenterTo: parent,
        );
        TextField(
          controller: numberCountController,
          decoration: const InputDecoration(
            hintText: 'Please enter the number of random numbers',
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ).applyConstraint(
          width: 500,
          outBottomCenterTo: sId(-1).topMargin(20),
        );
        ElevatedButton(
          onPressed: () async {
            if (isSorting) {
              setState(() {
                isSorting = false;
              });
            } else {
              isSorting = true;
              sortResult.clear();
              String text = numberCountController.text;
              if (text.isEmpty) {
                text = '$defaultNumberCount';
              }
              int numberCount = int.parse(text);
              if (numberCount <= 0) {
                numberCount = defaultNumberCount;
              }
              while (isSorting) {
                sortResult.add(await compute(compareSort, numberCount));
                setState(() {
                  scrollController
                      .jumpTo(scrollController.position.maxScrollExtent);
                });
              }
            }
          },
          child: Text(isSorting ? 'Stop sort' : 'Begin sort'),
        ).applyConstraint(
          centerRightTo: sId(-1),
        );
        ListView.builder(
          controller: scrollController,
          itemBuilder: (_, index) {
            return Text(sortResult[index]);
          },
          itemCount: sortResult.length,
          itemExtent: 50,
        ).applyConstraint(
          width: matchConstraint,
          height: matchConstraint,
          outBottomCenterTo: rId(1),
          bottom: parent.bottom,
        );
      }),
    );
  }
}

String compareSort(int numbers) {
  Random random = Random();
  var arr = [for (int i = 0; i < numbers; i++) random.nextInt(4294967296)];
  List copy = List.of(arr);
  Stopwatch stopwatch = Stopwatch()..start();
  chenSort(arr);
  int chenSortTimeUsage = stopwatch.elapsedMicroseconds;
  stopwatch.reset();
  copy.sort();
  int quickSortTimeUsage = stopwatch.elapsedMicroseconds;
  double percent =
      ((quickSortTimeUsage - chenSortTimeUsage) / quickSortTimeUsage) * 100;
  return 'chen sort time usage = $chenSortTimeUsage us, quick sort time usage = $quickSortTimeUsage us, ${percent.toStringAsFixed(2)}% faster';
}

void chenSort(List<int> list) {
  int max = -2 ^ 63;
  for (final element in list) {
    if (element > max) {
      max = element;
    }
  }
  int slot;
  List<List<int>?> buckets = List.filled(list.length + 1, null);
  double factor = list.length / max;
  for (final element in list) {
    slot = (element * factor).toInt();
    if (buckets[slot] == null) {
      buckets[slot] = [];
    }
    buckets[slot]!.add(element);
  }
  int compare(int left, int right) {
    return left - right;
  }

  int index = 0;
  for (final bucket in buckets) {
    if (bucket != null) {
      if (bucket.length > 1) {
        bucket.sort(compare);
      }
      for (final element in bucket) {
        list[index++] = element;
      }
    }
  }
}
