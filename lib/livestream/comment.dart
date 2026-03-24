import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  const Comment({
    super.key,
    required this.userName,
    required this.comment,
    required this.userImage,
  });

  final String userName;
  final String comment;
  final String userImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.85,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: MyNetworkImage(
                width: 38, height: 38, imagePath: userImage, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                    color: pureWhite,
                    multilanguage: false,
                    text: userName,
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textMedium,
                    inter: false,
                    maxline: 1,
                    fontwaight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
                MyText(
                    color: pureWhite,
                    multilanguage: false,
                    text: comment,
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textSmall,
                    inter: false,
                    maxline: 3,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
