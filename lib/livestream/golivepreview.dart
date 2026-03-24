import 'dart:async';
import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:fanbae/livestream/golivepreviewprovider.dart';
import 'package:fanbae/livestream/livestreamimage.dart';
import 'package:fanbae/provider/profileprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../model/successmodel.dart';
import '../webservice/apiservice.dart';

class GoLiveViewPreview extends StatefulWidget {
  const GoLiveViewPreview({super.key});

  @override
  State<GoLiveViewPreview> createState() => GoLiveViewPreviewState();
}

class GoLiveViewPreviewState extends State<GoLiveViewPreview> {
  late GoLivePreviewProvider goLivePreviewProvider;
  late ProfileProvider profileProvider;
  SuccessModel successModel = SuccessModel();

  @override
  void initState() {
    goLivePreviewProvider =
        Provider.of<GoLivePreviewProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    goLivePreviewProvider.onRequestPermissions();
    super.initState();
    getApi();
  }

  @override
  void dispose() {
    goLivePreviewProvider.onDisposeCamera();
    super.dispose();
  }

  Future<void> _navigateToLive() async {
    await Utils.jumpToLive(
      context: context,
      isHost: true,
      userId: Constant.userID,
      userImage: profileProvider.profileModel.result?[0].image.toString() ?? "",
      name:
          profileProvider.profileModel.result?[0].channelName.toString() ?? "",
      userName:
          profileProvider.profileModel.result?[0].channelName.toString() ?? "",
    );
  }

  getApi() async {
    await profileProvider.getprofile(context, Constant.userID);
  }

  @override
  Widget build(BuildContext context) {
    Timer(
      const Duration(milliseconds: 300),
      () {
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        );
      },
    );
    return Scaffold(
      backgroundColor: appbgcolor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Consumer<GoLivePreviewProvider>(
                builder: (context, contentdetailprovider, child) {
              if (contentdetailprovider.cameraController != null &&
                  (contentdetailprovider
                          .cameraController?.value.isInitialized ??
                      false)) {
                final mediaSize = MediaQuery.of(context).size;
                final scale = 1 /
                    (contentdetailprovider.cameraController!.value.aspectRatio *
                        mediaSize.aspectRatio);
                log("mediaSize.aspectRatio:::::::${mediaSize.aspectRatio}");
                log("controller.cameraController!.value.aspectRatio:::::::${contentdetailprovider.cameraController!.value.aspectRatio}");
                log("mediaSize:::::::$mediaSize");
                log("scale:::::::$scale");
                return ClipRect(
                  clipper: _MediaSizeClipper(mediaSize),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child:
                        CameraPreview(contentdetailprovider.cameraController!),
                  ),
                );
              } else {
                return Utils.pageLoader(context);
              }
            }),
            Positioned(
              bottom: 0,
              child: Container(
                height: 150,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(color: transparent),
              ),
            ),
            Positioned(
              top: 50,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      circleIconWithButton(
                          circleSize: 40,
                          iconSize: 20,
                          color: const Color(0xffF3CC44),
                          icon: "ic_close.webp",
                          iconColor: pureBlack,
                          callback: () => Navigator.pop(context)),
                      const SizedBox(height: 20),
                      /*  Consumer<GoLivePreviewProvider>(
                          builder: (context, golivepreviewprovider, child) {
                        return circleIconWithButton(
                          circleSize: 40,
                          iconSize: 20,
                          color: textColor,
                          icon: golivepreviewprovider.isFlashOn
                              ? "ic_flash_on.webp"
                              : "ic_flash_off.webp",
                          iconColor: black,
                          callback: golivepreviewprovider.onSwitchFlash,
                        );
                      }),
                      const SizedBox(height: 20),*/
                      Consumer<GoLivePreviewProvider>(
                          builder: (context, golivepreviewprovider, child) {
                        return circleIconWithButton(
                          circleSize: 40,
                          iconSize: 20,
                          color: const Color(0xffF3CC44),
                          icon: "ic_rotate_camera.webp",
                          iconColor: pureBlack,
                          callback: golivepreviewprovider.onSwitchCamera,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 5),
                  child: Consumer<GoLivePreviewProvider>(
                      builder: (context, golivepreviewprovider, child) {
                    return GestureDetector(
                      onTap: () {
                        Utils().conformDialog(
                          context,
                          () async {
                            successModel = await ApiService().saveLive(1);
                            if (successModel.status == 200) {
                              Utils().showSnackBar(
                                  context,
                                  successModel.message ??
                                      'Live recording has been enabled.',
                                  false);
                              await _navigateToLive();
                            } else {
                              Utils().showSnackBar(
                                  context,
                                  successModel.message ??
                                      'Error to enable the live record',
                                  false);
                            }
                          },
                          'save_live',
                          () async {
                            successModel = await ApiService().saveLive(0);
                            if (successModel.status == 200) {
                              Utils().showSnackBar(
                                  context,
                                  successModel.message ??
                                      'Live recording has been disabled.',
                                  false);
                              await _navigateToLive();
                            } else {
                              Utils().showSnackBar(
                                  context,
                                  successModel.message ??
                                      'Error to disable the live record',
                                  false);
                            }
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          gradient: Constant.gradientColor,
                        ),
                        height: 55,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyText(
                                  color: pureBlack,
                                  multilanguage: true,
                                  text: "go_live",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textBig,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget circleIconWithButton({
    String? icon,
    callback,
    double? circleSize,
    double? iconSize,
    Color? color,
    Color? iconColor,
    BoxBorder? border,
    EdgeInsetsGeometry? padding,
    Function(LongPressStartDetails)? onLongPressStart,
    Function(LongPressEndDetails)? onLongPressEnd,
  }) {
    return GestureDetector(
      onTap: callback,
      onLongPressStart: onLongPressStart,
      onLongPress: () {},
      onLongPressEnd: onLongPressEnd,
      child: Container(
        height: circleSize ?? 42,
        width: circleSize ?? 42,
        padding: padding,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: color, border: border),
        child: Center(
          child: LiveStreamImage(
            width: iconSize ?? 22,
            height: iconSize ?? 22,
            imagePath: icon ?? "",
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;

  const _MediaSizeClipper(this.mediaSize);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
