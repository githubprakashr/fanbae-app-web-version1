import 'package:fanbae/utils/color.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:flutter/material.dart';

import '../utils/constant.dart';

class NoData extends StatelessWidget {
  final String? title, subTitle;

  const NoData({
    Key? key,
    this.title,
    this.subTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 15),
      decoration: BoxDecoration(
        color: transparent,
        borderRadius: BorderRadius.circular(12),
        shape: BoxShape.rectangle,
      ),
      constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.43, minWidth: 0),
      child: Center(
        child: MyImage(
          width: MediaQuery.of(context).size.width > 1200 ? 325 : 250,
          height: MediaQuery.of(context).size.width > 1200 ? 325 : 250,
          fit: BoxFit.contain,
          imagePath: Constant.darkMode == 'true'
              ? "nodata.png"
              : "noDataWhiteTheme.png",
        ),
      ),
    );
  }
}
