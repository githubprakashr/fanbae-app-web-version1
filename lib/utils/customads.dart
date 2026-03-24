import 'dart:io';
import 'package:fanbae/provider/generalprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/utils/pusher_beams_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CustomAds extends StatefulWidget {
  final String? adType, contentId, rewardVideoUrl;
  const CustomAds(
      {super.key, required this.adType, this.contentId, this.rewardVideoUrl});

  @override
  State<CustomAds> createState() => _CustomAdsState();
}

class _CustomAdsState extends State<CustomAds> {
  late GeneralProvider generalProvider;
  String? diviceToken;
  String? diviceType;
  static bool? isPremiumBuy;

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    getCustomAds();
    super.initState();
    _getDeviceToken();
  }

  _getDeviceToken() async {
    try {
      if (kIsWeb) {
        diviceType = "3";
        diviceToken = Constant.webToken;
      } else {
        if (Platform.isAndroid) {
          diviceType = "1";
          // Use Pusher Beams device token
          diviceToken = await PusherBeamsService().getDeviceToken();
        } else {
          diviceType = "2";
          // Use Pusher Beams device token for iOS
          diviceToken = await PusherBeamsService().getDeviceToken();
        }
      }
    } catch (e) {
      printLog("_getDeviceToken Exception ===> $e");
    }
    printLog("===>diviceType $diviceType");
    printLog("===>diviceToken $diviceToken");
    printLog("===>diviceType $diviceType");
    printLog("===>diviceToken $diviceToken");
    printLog("===>diviceType $diviceType");
    printLog("===>diviceToken $diviceToken");
  }

  getCustomAds() async {
    if (widget.adType == Constant.bannerAdType) {
      await generalProvider.getAds(1);
    }
    getViewApi();
  }

  getViewApi() async {
    await Utils.getCustomAdsStatus();
    if (widget.adType == Constant.bannerAdType) {
      await _getViewClickCount(adType: Constant.bannerAdType, type: "1");
    } else {
      await _getViewClickCount(
          adType: Constant.rewardAdType,
          type: "1",
          contentId: widget.contentId);
    }
  }

  _getViewClickCount({adType, contentId, type}) async {
    /* Device Token Generate and Store */
    if (adType == Constant.bannerAdType) {
      if (Constant.banneradStatus == "1") {
        await generalProvider.getAdsViewClickCount(
            "1",
            generalProvider.getBannerAdsModel.result?.id.toString() ?? "",
            diviceType,
            diviceToken,
            type /* "1" CPV & 2 CPC */,
            "");
      }
    } else {
      if (Constant.rewardadStatus == "1") {
        await generalProvider.getAdsViewClickCount(
            "3",
            generalProvider.getRewardAdsModel.result?.id.toString() ?? "",
            diviceType,
            diviceToken,
            type /* "1" CPV & 2 CPC */,
            contentId);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printLog("===>IsAdsFree $isPremiumBuy");
    return Consumer<GeneralProvider>(
        builder: (context, generalprovider, child) {
      if (widget.adType == Constant.bannerAdType) {
        return bannerAds();
      } else {
        return rewardAds();
      }
    });
  }

  Widget bannerAds() {
    if (Constant.banneradStatus == "1") {
      if (((Constant.isAdsFree != "1") ||
          (Constant.isAdsFree == null) ||
          (Constant.isAdsFree == ""))) {
        if (generalProvider.loading) {
          return const SizedBox.shrink();
        } else {
          if (generalProvider.getBannerAdsModel.status == 200) {
            return InkWell(
              hoverColor: transparent,
              highlightColor: transparent,
              focusColor: transparent,
              splashColor: transparent,
              onTap: () async {
                if (kIsWeb) {
                  Utils.lanchAdsLink(generalProvider
                          .getBannerAdsModel.result?.redirectUri
                          .toString() ??
                      "");
                } else {
                  Utils.lanchAdsUrl(generalProvider
                          .getBannerAdsModel.result?.redirectUri
                          .toString() ??
                      "");
                }

                _getViewClickCount(
                  adType: Constant.bannerAdType,
                  type: "2",
                );
              },
              child: kIsWeb
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: 175,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: colorPrimaryDark),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: MyNetworkImage(
                                    width: MediaQuery.of(context).size.width *
                                        0.50,
                                    height: MediaQuery.of(context).size.height,
                                    imagePath: generalProvider
                                            .getBannerAdsModel.result?.image
                                            .toString() ??
                                        "",
                                    fit: BoxFit.cover),
                              ),
                              Positioned.fill(
                                right: 15,
                                bottom: 15,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 4, 10, 4),
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: MyText(
                                        color: black,
                                        text: "Ads",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: Dimens.textMedium,
                                        fontsizeWeb: Dimens.textMedium,
                                        inter: false,
                                        multilanguage: false,
                                        maxline: 1,
                                        fontwaight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: MusicTitle(
                                color: white,
                                text: generalProvider
                                        .getBannerAdsModel.result?.title
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textExtraBig,
                                fontsizeWeb:
                                    MediaQuery.of(context).size.width > 800
                                        ? Dimens.textExtraBig
                                        : Dimens.textTitle,
                                maxline: 5,
                                multilanguage: false,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: MyText(
                                color: black,
                                text: "explorebtn",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textMedium,
                                fontsizeWeb: Dimens.textMedium,
                                inter: false,
                                multilanguage: true,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      color: colorPrimaryDark,
                      child: Stack(
                        children: [
                          MyNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              imagePath: generalProvider
                                      .getBannerAdsModel.result?.image
                                      .toString() ??
                                  "",
                              fit: BoxFit.cover),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(5, 4, 5, 4),
                                decoration: BoxDecoration(
                                  color: transparent.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: MyText(
                                    color: white,
                                    text: "Ads",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
                                    fontsizeWeb: Dimens.textSmall,
                                    inter: false,
                                    multilanguage: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget rewardAds() {
    return InkWell(
      onTap: () {
        Utils.lanchAdsLink(
            generalProvider.getRewardAdsModel.result?.redirectUri.toString() ??
                "");

        _getViewClickCount(
          adType: Constant.rewardAdType,
          type: "2",
        );
      },
      child: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: kIsWeb ? 500 : 300,
          ),
          // child: AdsPlayer(videoUrl: widget.rewardVideoUrl.toString())),
        ],
      ),
    );
  }
}

class AdsPlayer extends StatefulWidget {
  final String? videoUrl, contentId;
  const AdsPlayer({super.key, required this.videoUrl, required this.contentId});

  @override
  AdsPlayerState createState() => AdsPlayerState();
}

class AdsPlayerState extends State<AdsPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late GeneralProvider generalProvider;
  int? playerCPosition, videoDuration;
  String? diviceToken;
  String? diviceType;

  @override
  void initState() {
    printLog("Ads Video Url ==>${widget.videoUrl.toString()} ");
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl.toString()));
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.play();
    getAdsViewClickAPi("1", widget.contentId);
    _controller.addListener(() {
      playerCPosition = (_controller.value.position).inMilliseconds;
      videoDuration = (_controller.value.duration).inMilliseconds;
      printLog("playerCPosition :===> $playerCPosition");
      printLog("videoDuration :=====> $videoDuration");
      if ((playerCPosition ?? 0) > 0 &&
          (playerCPosition == videoDuration ||
              (playerCPosition ?? 0) > (videoDuration ?? 0))) {
        generalProvider.getSetRewardAds(close: true, skip: false);
      }
    });
    super.initState();
  }

  getAdsViewClickAPi(type, contentId) async {
    try {
      if (kIsWeb) {
        diviceType = "3";
        diviceToken = Constant.webToken;
      } else {
        if (Platform.isAndroid) {
          diviceType = "1";
          diviceToken = await PusherBeamsService().getDeviceToken();
        } else {
          diviceType = "2";
          diviceToken = await PusherBeamsService().getDeviceToken();
        }
      }
    } catch (e) {
      printLog("_getDeviceToken Exception ===> $e");
    }
    await generalProvider.getAdsViewClickCount(
        "3",
        generalProvider.getRewardAdsModel.result?.id.toString() ?? "",
        diviceType,
        diviceToken,
        type /* "1" CPV & 2 CPC */,
        contentId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimaryDark,
      body: Stack(
        children: [
          InkWell(
            onTap: () async {
              if (kIsWeb) {
                Utils.lanchAdsLink(generalProvider
                        .getRewardAdsModel.result?.redirectUri
                        .toString() ??
                    "");
              } else {
                Utils.lanchAdsUrl(generalProvider
                        .getRewardAdsModel.result?.redirectUri
                        .toString() ??
                    "");
              }
              getAdsViewClickAPi("2", widget.contentId);
            },
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: kIsWeb ? 500 : 300,
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: SizedBox(
                              width: _controller.value.size.width,
                              height: _controller.value.size.height,
                              child: AspectRatio(
                                aspectRatio: _controller.value.size.aspectRatio,
                                child: VideoPlayer(_controller),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (kIsWeb) {
                              Utils.lanchAdsLink(generalProvider
                                      .getRewardAdsModel.result?.redirectUri
                                      .toString() ??
                                  "");
                            } else {
                              Utils.lanchAdsUrl(generalProvider
                                      .getRewardAdsModel.result?.redirectUri
                                      .toString() ??
                                  "");
                            }
                            getAdsViewClickAPi("2", widget.contentId);
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Utils.pageLoader(context);
                  }
                },
              ),
            ),
          ),
          Positioned.fill(
            top: 60,
            left: 20,
            right: 20,
            bottom: 20,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Consumer<GeneralProvider>(
                  builder: (context, generalprovider, child) {
                return InkWell(
                  onTap: () {
                    generalprovider.getSetRewardAds(close: true, skip: false);
                  },
                  child: Container(
                    width: 45,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: white,
                    ),
                    child: MyText(
                        color: black,
                        text: "skip",
                        fontsizeNormal: Dimens.textSmall,
                        fontsizeWeb: Dimens.textSmall,
                        fontwaight: FontWeight.w400,
                        multilanguage: true,
                        inter: false,
                        maxline: 2,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.left,
                        fontstyle: FontStyle.normal),
                  ),
                );
              }),
            ),
          ),
          Positioned.fill(
            right: 15,
            top: 30,
            left: 15,
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: MusicTitle(
                    color: black,
                    text: "Ads",
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textMedium,
                    fontsizeWeb: Dimens.textMedium,
                    multilanguage: false,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
