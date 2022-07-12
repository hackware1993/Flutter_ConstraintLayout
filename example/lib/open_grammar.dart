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
        codePath: 'example/open_grammar.dart',
      ),
      body: ConstraintLayout().open(() {
        if (DateTime.now().millisecond % 2 == 0) {
          Container(
            color: Colors.red,
          ).applyConstraint(
            size: 200,
            centerTo: parent,
          );
        } else {
          Container(
            color: Colors.yellow,
          ).applyConstraint(
            size: 200,
            centerTo: parent,
          );
        }

        for (int i = 0; i < 5; i++) {
          Row().open(() {
            for (int j = 0; j < 10; j++) {
              Text("$i x $j").enter();
              const SizedBox(
                width: 20,
              ).enter();
            }
          }).applyConstraint(
            height: 100,
            left: parent.left.margin(100),
            top: i == 0 ? parent.top : sId(-1).bottom,
          );
        }

        int i = 0;
        while (i < 100) {
          Text("$i").applyConstraint(
            left: parent.left,
            top: i == 0 ? parent.top : sId(-1).bottom,
          );
          i++;
        }
      }),
    );
  }
}
