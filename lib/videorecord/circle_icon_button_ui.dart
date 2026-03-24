import 'package:fanbae/utils/constant.dart';
import 'package:flutter/material.dart';

class CircleIconButtonUi extends StatelessWidget {
  const CircleIconButtonUi({
    super.key,
    required this.icon,
    required this.callback,
    this.circleSize,
    this.iconSize,
    this.color,
    this.gradient,
    this.iconColor,
    this.padding,
    this.border,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  final String icon;
  final Function()? callback;

  final double? circleSize;
  final double? iconSize;

  final Color? color;
  final Color? iconColor;
  final Gradient? gradient;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;

  final Function(LongPressStartDetails)? onLongPressStart;
  final Function(LongPressEndDetails)? onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      onLongPressStart: onLongPressStart,
      onLongPress: () {},
      onLongPressEnd: onLongPressEnd,
      child: Container(
        height: circleSize ?? 42,
        width: circleSize ?? 42,
        padding: padding,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            gradient: gradient,
            border: border),
        child: Center(
          child: Image.asset(
            "${Constant.videoImagePath}$icon",
            height: iconSize ?? 22,
            width: iconSize ?? 22,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
