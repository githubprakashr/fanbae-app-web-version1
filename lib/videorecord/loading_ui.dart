import 'package:fanbae/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingUi extends StatelessWidget {
  const LoadingUi({super.key, this.color, this.size});

  final Color? color;

  final double? size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitCircle(
        color: color ?? colorPrimary,
        size: size ?? 60,
      ),
    );
  }
}
