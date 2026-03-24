import 'package:flutter_svg/svg.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyImage extends StatelessWidget {
  double height;
  double width;
  String imagePath;
  Color? color;
  // ignore: prefer_typing_uninitialized_variables
  var fit;
  // var alignment;

  MyImage(
      {Key? key,
      required this.width,
      required this.height,
      required this.imagePath,
      this.color,
      this.fit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imagePath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        "${Constant.imageFolderPath}$imagePath",
        width: width,
        height: height,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    } else {
      return Image.asset(
        "${Constant.imageFolderPath}$imagePath",
        height: height,
        color: color,
        width: width,
        fit: fit,
      );
    }
  }
}
