import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/pages/shorts.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'bottombar.dart';

class SuccessPage extends StatefulWidget {
  final bool? isRequestCreator;

  const SuccessPage({super.key, this.isRequestCreator});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appbgcolor,
        body: Stack(
          children: [
            MyImage(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
                imagePath: kIsWeb ? "successBgWeb.png" : "successBg.png"),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.13,
                    left: 22,
                    right: 22),
                child: Column(
                  children: [
                    MyText(
                        text: "updatesuccess",
                        color: white,
                        fontsizeNormal: Dimens.textlargeBig,
                        fontwaight: FontWeight.bold,
                        textalign: TextAlign.center),
                    const SizedBox(
                      height: 10,
                    ),
                    MyText(
                        text: widget.isRequestCreator == true
                            ? "waitforadminapproval"
                            : "subscriptionconfirmed",
                        color: white,
                        maxline: 2,
                        textalign: TextAlign.center),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  if (kIsWeb) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Shorts(initialIndex: 0),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Bottombar(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.103,
                      left: 20,
                      right: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 11, horizontal: 33),
                  decoration: BoxDecoration(
                      gradient: Constant.gradientColor,
                      borderRadius: BorderRadius.circular(30)),
                  child: MyText(
                      text: "gotohome",
                      fontwaight: FontWeight.w700,
                      color: pureBlack),
                ),
              ),
            ),
          ],
        ));
  }
}
