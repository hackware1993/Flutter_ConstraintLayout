import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

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
  late bool loading;

  @override
  void initState() {
    super.initState();
    loadCode();
  }

  void loadCode() async {
    setState(() {
      loading = true;
    });
    try {
      code = await rootBundle.loadString(widget.codePath);
    } catch (_) {}
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: ConstraintLayout(
        children: [
          if (loading)
            const CircularProgressIndicator().applyConstraint(
              size: 30,
              centerTo: parent,
            ),
          if (!loading && code == null)
            const Text('Code loading failed').applyConstraint(
              centerTo: parent,
            ),
          if (code != null)
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
