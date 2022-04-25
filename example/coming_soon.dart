import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class ComingSoonWidget extends StatelessWidget {
  const ComingSoonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Chain',
      ),
      body: ConstraintLayout(
        children: [
          const Text('Coming soon, stay tuned').applyConstraint(
            centerTo: parent,
          )
        ],
      ),
    );
  }
}
