import 'package:fanbae/utils/constant.dart';
import 'package:flutter/material.dart';

class LiveStreamImage extends StatelessWidget {
  final double height, width;
  final String imagePath;
  final Color? color;
  final BoxFit? fit;

  const LiveStreamImage(
      {Key? key,
      required this.width,
      required this.height,
      required this.imagePath,
      this.color,
      this.fit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "${Constant.videoImagePath}$imagePath",
      height: height,
      color: color,
      width: width,
      fit: fit,
    );
  }
}
