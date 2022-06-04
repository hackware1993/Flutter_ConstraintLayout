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

int intMaxValue = 9223372036854775807;
int intMinValue = -9223372036854775808;

class ChenSortExampleState extends State<ChenSortExample> {
  int defaultNumberCount = 100000;
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
          'The time complexity is O(n) at best and O(nlog2n) at worst, the space complexity is O(n), and it is stable',
          style: TextStyle(
            fontSize: 30,
          ),
        ).applyConstraint(
          maxWidth: 800,
          topCenterTo: parent,
        );
        TextField(
          controller: numberCountController,
          decoration: const InputDecoration(
            hintText: 'Please enter the number of random numbers',
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ).applyConstraint(
          width: 800,
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
  List<int> arr = [];
  for (int i = 0; i < numbers; i++) {
    if (random.nextBool()) {
      arr.add(random.nextInt(1 << 32));
    } else {
      arr.add(-random.nextInt(1 << 32));
    }
  }
  List copy = List.of(arr);
  Stopwatch stopwatch = Stopwatch()..start();
  stopwatch.reset();
  chenSort(arr);
  int chenSortTimeUsage = stopwatch.elapsedMicroseconds;
  stopwatch.reset();
  copy.sort();
  int quickSortTimeUsage = stopwatch.elapsedMicroseconds;
  double percent =
      ((quickSortTimeUsage - chenSortTimeUsage) / quickSortTimeUsage) * 100;
  return 'Are the sorted results equal? ${listEquals(arr, copy)}, chen sort: $chenSortTimeUsage us, quick sort: $quickSortTimeUsage us, ${percent.toStringAsFixed(2)}%(${(quickSortTimeUsage / chenSortTimeUsage).toStringAsFixed(1)}x) faster';
}

/// The essence of Chen Sort is an improved bucket sort
void chenSort(List<int> list) {
  if (list.length < 2) {
    return;
  }

  int maxValue = list[0];
  int minValue = maxValue;
  for (final element in list.skip(1)) {
    if (element > maxValue) {
      maxValue = element;
    }
    if (element < minValue) {
      minValue = element;
    }
  }

  /// All elements are the same and do not need to be sorted.
  if (maxValue == minValue) {
    return;
  }

  /// Limit the maximum size of the bucket to ensure the performance of long list
  /// sorting, which can be adjusted according to the actual situation.
  ///
  /// The essential difference between this and bucket sorting is that the size of
  /// the bucket is only related to the length of the list, not the range of element values.
  int bucketSize = min(list.length, 50000);
  int maxBucketIndex = bucketSize - 1;

  List<List<int>?> buckets = List.filled(bucketSize, null);
  int slot;

  /// Calculate the bucket in which the element is located based on the value of the element
  /// and the maximum and minimum values.

  /// Overflow detection
  BigInt range = BigInt.from(maxValue) - BigInt.from(minValue);
  if (BigInt.from(range.toInt()) == range) {
    int range = maxValue - minValue;
    double factor = maxBucketIndex / range;
    for (final element in list) {
      // slot = (((element - minValue) / range) * maxBucketIndex).toInt();
      slot = ((element - minValue) * factor).toInt();
      if (buckets[slot] == null) {
        buckets[slot] = [];
      }
      buckets[slot]!.add(element);
    }
  } else {
    /// Overflowed(positive minus negative)
    int positiveRange = maxValue;
    int negativeRange = -1 - minValue;
    int positiveStartBucketIndex = maxBucketIndex ~/ 2 + 1;
    int positiveBucketLength = maxBucketIndex - positiveStartBucketIndex;
    int negativeBucketLength = positiveStartBucketIndex - 1;
    for (final element in list) {
      if (element < 0) {
        slot = (((element - minValue) / negativeRange) * negativeBucketLength)
            .toInt();
      } else {
        slot = positiveStartBucketIndex +
            ((element / positiveRange) * positiveBucketLength).toInt();
      }
      if (buckets[slot] == null) {
        buckets[slot] = [];
      }
      buckets[slot]!.add(element);
    }
  }

  int compare(int left, int right) {
    return left - right;
  }

  int index = 0;
  for (final bucket in buckets) {
    if (bucket != null) {
      if (bucket.length > 1) {
        if (bucket.length >= 1000) {
          chenSort(bucket);
        } else {
          /// The sort method here represents the fastest comparison-type algorithm (Quick sort, Tim sort, etc.)
          bucket.sort(compare);
        }
        for (final element in bucket) {
          list[index++] = element;
        }
      } else {
        list[index++] = bucket[0];
      }
    }
  }
}
