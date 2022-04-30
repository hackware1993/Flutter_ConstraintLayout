import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_constraintlayout/src/constraint_layout.dart';

import 'custom_app_bar.dart';

class CodeViewWidget extends StatefulWidget {
  final String codePath;

  const CodeViewWidget({
    Key? key,
    required this.codePath,
  }) : super(key: key);

  @override
  State createState() => CodeViewState();
}

class CodeViewState extends State<CodeViewWidget> {
  String? code;

  @override
  void initState() {
    super.initState();
    loadCode();
  }

  void loadCode() async {
    code = await rootBundle.loadString(widget.codePath);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: ConstraintLayout(
        children: [
          SingleChildScrollView(
            child: Padding(
              child: Text(
                code ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              padding: const EdgeInsets.only(
                left: 20,
                top: 20,
              ),
            ),
          ).applyConstraint(
            size: matchParent,
          )
        ],
      ),
    );
  }
}
