import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? height;
  final Color backgroundColor;
  final String title;
  final String leftImg;
  final GestureTapCallback? onLeftTap;
  final GestureTapCallback? onRightTap;
  final String? rightButtonText;

  static const double DEFAULT_HEIGHT = 64;

  const CustomAppBar({
    Key? key,
    this.height,
    this.backgroundColor = Colors.white,
    this.title = '',
    this.leftImg = 'assets/icon_back.webp',
    this.onLeftTap,
    this.rightButtonText,
    this.onRightTap,
  }) : super(key: key);

  @override
  Size get preferredSize {
    return Size(double.infinity, height ?? DEFAULT_HEIGHT);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? DEFAULT_HEIGHT,
      color: backgroundColor,
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).viewPadding.top,
      ),
      child: ConstraintLayout(
        children: [
          GestureDetector(
            child: Image.asset(
              leftImg,
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
          )
        ],
      ),
    );
  }
}
