import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'code.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? height;
  final Color backgroundColor;
  final String title;
  final String? codePath;

  const CustomAppBar({
    Key? key,
    this.height,
    this.backgroundColor = Colors.white,
    this.title = '',
    this.codePath,
  }) : super(key: key);

  @override
  Size get preferredSize {
    return Size(double.infinity, height ?? 64);
  }

  void push(BuildContext context, Widget widget) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return widget;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 64,
      color: backgroundColor,
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).viewPadding.top,
      ),
      child: ConstraintLayout(
        children: [
          GestureDetector(
            child: Image.asset(
              'assets/icon_back.webp',
              fit: BoxFit.fill,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ).applyConstraint(
            width: 8,
            height: 16,
            centerVerticalTo: parent,
            left: parent.left,
            margin: const EdgeInsets.only(
              left: 20,
            ),
            clickPadding: const EdgeInsets.all(20),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF333756),
              fontWeight: FontWeight.bold,
            ),
          ).applyConstraint(
            centerTo: parent,
          ),
          if (codePath != null)
            GestureDetector(
              child: const Text(
                'View Code',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                push(
                  context,
                  CodeViewWidget(
                    codePath: codePath!,
                  ),
                );
              },
            ).applyConstraint(
              centerRightTo: parent,
              margin: const EdgeInsets.only(
                right: 20,
              ),
              clickPadding: const EdgeInsets.all(20),
            )
        ],
      ),
    );
  }
}
