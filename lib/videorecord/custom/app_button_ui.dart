import 'package:fanbae/utils/color.dart';
import 'package:flutter/material.dart';

class AppButtonUi extends StatelessWidget {
  const AppButtonUi({
    super.key,
    this.height,
    required this.title,
    this.color,
    this.icon,
    this.gradient,
    required this.callback,
    this.iconSize,
    this.fontSize,
    this.fontColor,
    this.fontWeight,
    this.iconColor,
  });

  final double? height;
  final double? iconSize;
  final double? fontSize;
  final String title;
  final Color? color;
  final Color? fontColor;
  final Color? iconColor;
  final String? icon;
  final Gradient? gradient;
  final FontWeight? fontWeight;
  final Function()? callback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: color,
          gradient: gradient,
        ),
        height: height ?? 56,
        width: MediaQuery.sizeOf(context).width,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon != null
                  ? Container(
                      padding: const EdgeInsets.only(left: 15),
                      child: Image.asset(
                        icon!,
                        width: iconSize ?? 30,
                        color: iconColor,
                      ),
                    )
                  : const Offstage(),
              Text(
                title,
                style: TextStyle(
                  color: fontColor ?? white,
                  fontSize: fontSize ?? 18,
                  letterSpacing: 0.3,
                  fontWeight: fontWeight ?? FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
