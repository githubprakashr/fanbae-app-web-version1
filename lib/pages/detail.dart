import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/gestures.dart';
import 'package:fanbae/model/download_item.dart';
import 'package:fanbae/pages/login.dart';
import 'package:fanbae/music/musicdetails.dart';
import 'package:fanbae/pages/mydownloads.dart';
import 'package:fanbae/pages/profile.dart';
import 'package:fanbae/pages/viewmembershipplan.dart';
import 'package:fanbae/provider/generalprovider.dart';
import 'package:fanbae/provider/playerprovider.dart';
import 'package:fanbae/provider/videodownloadprovider.dart';
import 'package:fanbae/utils/customads.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/provider/detailsprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bx.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../main.dart';
import '../model/membership_plan_model.dart';
import '../model/successmodel.dart';
import '../provider/profileprovider.dart';
import '../utils/responsive_helper.dart';
import '../webpages/weblogin.dart';

class Detail extends StatefulWidget {
  final String videoid;
  final String contentType;
  final int isComment;
  final int? stoptime;
  final bool iscontinueWatching;

  const Detail(
      {super.key,
      required this.videoid,
      required this.contentType,
      required this.isComment,
      required this.iscontinueWatching,
      required this.stoptime});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> with RouteAware {
  late Box<DownloadItem> downloadBox;

  late DetailsProvider detailsProvider;
  late ProfileProvider profileProvider;
  late GeneralProvider generalProvider;
  late PlayerProvider playerProvider;
  MembershipPlanModel? membershipPlanModel;

  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;
  YoutubePlayerController? controller;

  int? playerCPosition, videoDuration;
  double? youtubecurrentTime, youtubeTotalDuration;
  String savePath = "";
  bool showAll = false;

  /* Controller */
  late ScrollController _scrollController;
  late ScrollController _commentScrollController;
  late ScrollController replaycommentController;
  final commentController = TextEditingController();
  final FocusNode commentFocusNode = FocusNode();
  final GlobalKey textFieldKey = GlobalKey();

  bool isDispose = true;

  @override
  void initState() {
    detailsProvider = Provider.of<DetailsProvider>(context, listen: false);
    playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    _scrollController = ScrollController();
    _commentScrollController = ScrollController();
    replaycommentController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _commentScrollController.addListener(_commentScrollListener);
    replaycommentController.addListener(_replayCommentscrollListener);
    stopAudio();
    if (!kIsWeb) {
      if (Constant.userID != null) {
        downloadBox = Hive.box<DownloadItem>(
            '${Constant.hiveDownloadBox}_${Constant.userID}');
      } else {
        downloadBox = Hive.box<DownloadItem>(Constant.hiveDownloadBox);
      }
    }
    getApi();
    super.initState();
    playerInitialize();
  }

  stopAudio() async {
    await audioPlayer.pause();
    await audioPlayer.stop();
  }

  disposeController() {
    detailsProvider.clearProvider();
    generalProvider.clearProvider();
    profileProvider.clearProvider();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    controller?.dispose();
    if (!(kIsWeb)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  getVideoDetails() async {
    await detailsProvider.getvideodetails(
        widget.videoid.toString(), widget.contentType,
        isLoad: false);
  }

  playerInitialize() async {
    await detailsProvider.getvideodetails(
        widget.videoid.toString(), widget.contentType);
    await _fetchRelatedVideo(0);
    if (detailsProvider.detailsModel.status == 200 &&
        (detailsProvider.detailsModel.result?.length ?? 0) > 0) {
      if (detailsProvider.detailsModel.result?[0].payContent == false ||
          Constant.userID ==
              detailsProvider.detailsModel.result?[0].userId.toString()) {
        if (detailsProvider.detailsModel.result?[0].contentUploadType
                .toString() ==
            "youtube") {
          _initYoutubePlayer(
              detailsProvider.detailsModel.result?[0].content.toString() ?? "");
        } else {
          _playerInit(
              detailsProvider.detailsModel.result?[0].content.toString() ?? "");
        }
      }
      _loadMembershipForIndex();
    }
  }

  Future<void> _loadMembershipForIndex() async {
    final userId =
        detailsProvider.detailsModel.result?[0].userId?.toString() ?? "";
    if (userId.isEmpty) return;

    await profileProvider.getprofile(context, userId);

    final creatorId =
        profileProvider.profileModel.result?[0].id.toString() ?? "0";

    membershipPlanModel = await ApiService().getMembershipPlans(
      creatorId,
      Constant.userID,
    );

    if (membershipPlanModel != null) {
      print('membershipPlanModel${membershipPlanModel!.result.length}');
    }

    setState(() {});
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (detailsProvider.relatedVideocurrentPage ?? 0) <
            (detailsProvider.relatedVideototalPage ?? 0)) {
      await detailsProvider.setRelatedLoadMore(true);
      _fetchRelatedVideo(detailsProvider.relatedVideocurrentPage ?? 0);
    }
  }

  _commentScrollListener() async {
    if (!_commentScrollController.hasClients) return;
    if (_commentScrollController.offset >=
            _commentScrollController.position.maxScrollExtent &&
        !_commentScrollController.position.outOfRange &&
        (detailsProvider.currentPageComment ?? 0) <
            (detailsProvider.totalPageComment ?? 0)) {
      detailsProvider.setCommentLoadMore(true);
      _fetchCommentData(detailsProvider.currentPageComment ?? 0);
    }
  }

  _replayCommentscrollListener() async {
    if (!replaycommentController.hasClients) return;
    if (replaycommentController.offset >=
            replaycommentController.position.maxScrollExtent &&
        !replaycommentController.position.outOfRange &&
        (detailsProvider.currentPageReplayComment ?? 0) <
            (detailsProvider.totalPageReplayComment ?? 0)) {
      await detailsProvider.setReplayCommentLoadMore(true);
      _fetchReplayCommentData(detailsProvider.commentId,
          detailsProvider.currentPageReplayComment ?? 0);
    }
  }

  Future<void> _fetchCommentData(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await detailsProvider.getComment(
        Constant.videoType, widget.videoid, (nextPage ?? 0) + 1);
    await detailsProvider.setCommentLoading(false);
  }

  Future<void> _fetchReplayCommentData(commentId, int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await detailsProvider.getReplayComment(commentId, (nextPage ?? 0) + 1);
    await detailsProvider.setReplayCommentLoadMore(false);
  }

  Future<void> _fetchRelatedVideo(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await detailsProvider.getRelatedVideo(widget.videoid, (nextPage ?? 0) + 1);
    await detailsProvider.setRelatedLoadMore(false);
  }

  _initYoutubePlayer(String videoUrl) async {
    controller = YoutubePlayerController(
      initialVideoId: Utils.convertUrlToId(videoUrl) ?? "",
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        startAt: widget.stoptime ?? 0,
      ),
    );

    await playerProvider.addVideoView(widget.contentType, widget.videoid);
    await playerProvider.addContentHistory(
        widget.contentType, widget.videoid, "$playerCPosition", "0");
  }

  _playerInit(String videoUrl) async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    );
    await Future.wait([_videoPlayerController!.initialize()]);

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      autoInitialize: true,
      looping: false,
      fullScreenByDefault: false,
      allowFullScreen: true,
      hideControlsTimer: const Duration(seconds: 1),
      showControls: true,
      allowedScreenSleep: false,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      cupertinoProgressColors: ChewieProgressColors(
        playedColor: colorPrimary,
        handleColor: colorPrimary,
        backgroundColor: gray,
        bufferedColor: white,
      ),
      materialProgressColors: ChewieProgressColors(
        playedColor: colorPrimary,
        handleColor: colorPrimary,
        backgroundColor: gray,
        bufferedColor: white,
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: MyText(
            color: white,
            text: errorMessage,
            textalign: TextAlign.center,
            fontsizeNormal: Dimens.textMedium,
            fontwaight: FontWeight.w600,
            multilanguage: false,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        );
      },
    );

    _videoPlayerController?.addListener(() {
      playerCPosition =
          (_chewieController?.videoPlayerController.value.position)
                  ?.inMilliseconds ??
              0;
      videoDuration = (_chewieController?.videoPlayerController.value.duration)
              ?.inMilliseconds ??
          0;
      printLog("playerCPosition :===> $playerCPosition");
      printLog("videoDuration :=====> $videoDuration");
    });

    await playerProvider.addVideoView(widget.contentType, widget.videoid);
    await playerProvider.addContentHistory(
        widget.contentType, widget.videoid, "$playerCPosition", "0");

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  getApi() async {
    await generalProvider.getAds(3);
  }

  @override
  void dispose() {
    if (isDispose == true) {
      detailsProvider.clearProvider();
      generalProvider.clearProvider();
      _chewieController?.dispose();
      commentFocusNode.dispose();
      _videoPlayerController?.dispose();
      controller?.dispose();
      if (!(kIsWeb)) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      body: SafeArea(
          child: Utils().pageBg(context,
              child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ads()))),
    );
  }

  Widget ads() {
    if (Constant.rewardadStatus == "1" &&
        (((Constant.isAdsFree != "1") ||
            (Constant.isAdsFree == null) ||
            (Constant.isAdsFree == "")))) {
      return Consumer<GeneralProvider>(
          builder: (context, generalprovider, child) {
        if (generalprovider.loading) {
          return shimmer();
        } else {
          if (generalprovider.getRewardAdsModel.status == 200 &&
              generalprovider.getRewardAdsModel.result != null &&
              (generalprovider.isCloseRewardAds == false) &&
              (generalprovider.showSkip == false) &&
              ((generalprovider.getRewardAdsModel.result?.isHide ?? 0) == 0)) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Constant.userID !=
                            detailsProvider.detailsModel.result![0].userId
                                .toString() &&
                        detailsProvider.detailsModel.result![0].payContent ==
                            true
                    ? payVideoApi()
                    : SizedBox(
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        child: AdsPlayer(
                          contentId: widget.videoid,
                          videoUrl: generalprovider
                                  .getRewardAdsModel.result?.video
                                  .toString() ??
                              "",
                        ),
                      ),
                buildOtherDetail(),
              ],
            );
          } else {
            return player();
          }
        }
      });
    } else {
      return player();
    }
  }

  payVideoApi() {
    return Stack(
      children: [
        Center(
          child: GestureDetector(
            onTap: () {
              if (Constant.userID == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ResponsiveHelper.isWeb(context)
                          ? const WebLogin()
                          : const Login();
                    },
                  ),
                );
              } else {
                Utils().conformDialog(
                    context,
                    () async {
                      Utils.showProgress(context);
                      SuccessModel video = await ApiService().payVideoPost(
                          Constant.userID ?? '',
                          'video',
                          detailsProvider.detailsModel.result![0].id ?? 0);
                      if (!mounted) return;
                      Utils().hideProgress(context);
                      if (video.status == 200) {
                        setState(() {
                          Utils().showSnackBar(
                              context, video.message ?? '', false);
                          playerInitialize();
                        });
                      } else {
                        Utils()
                            .showSnackBar(context, video.message ?? '', false);
                      }
                    },
                    'wantpayvideo',
                    () {
                      Navigator.pop(context);
                    });
              }
            },
            child: SizedBox(
              height: 250,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyImage(width: 90, height: 90, imagePath: "appicon.png"),
                    const SizedBox(
                      height: 18,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                            multilanguage: false,
                            color: white,
                            fontwaight: FontWeight.w600,
                            text: "Pay  "),
                        MyImage(
                            width: 18, height: 18, imagePath: "ic_coin.png"),
                        MyText(
                            multilanguage: false,
                            color: white,
                            fontwaight: FontWeight.w600,
                            text:
                                " ${detailsProvider.detailsModel.result![0].payCoin} to watch video"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 15,
          left: 15,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            focusColor: gray.withOpacity(0.5),
            onTap: () {
              onBackPressed(false);
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Utils.backIcon(),
            ),
          ),
        ),
      ],
    );
  }

  Widget player() {
    return Consumer<DetailsProvider>(
        builder: (context, detailsprovider, child) {
      if (detailsProvider.loading) {
        return shimmer();
      }
      if (detailsProvider.detailsModel.status == 200 &&
          detailsProvider.detailsModel.result != null &&
          (detailsProvider.detailsModel.result?.length ?? 0) > 0) {
        print(
            'etfeh5rfyjhtyjgjngJYGU: ${detailsProvider.detailsModel.result?[0].content.toString() != ""}');
        print(
            'etfeh5rfyjhtyjgjngJYGUedryhrfhbf b: ${detailsProvider.detailsModel.result?[0].content.toString()}');
        if (detailsProvider.detailsModel.result?[0].content.toString() != "") {
          if (detailsProvider.detailsModel.result?[0].contentUploadType
                  .toString() ==
              "youtube") {
            if (Constant.userID !=
                    detailsProvider.detailsModel.result![0].userId.toString() &&
                detailsProvider.detailsModel.result![0].payContent == true) {
              return Column(
                children: [
                  payVideoApi(),
                  buildOtherDetail(),
                ],
              );
            } else if (controller == null) {
              return shimmer();
            } else {
              return YoutubePlayerBuilder(
                player: YoutubePlayer(
                  aspectRatio: 16 / 9,
                  controller: controller!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: colorAccent,
                  onReady: () {},
                ),
                builder: (context, player) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Player
                      Stack(
                        children: [
                          player,
                          if (!kIsWeb)
                            Positioned(
                              top: 15,
                              left: 15,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                focusColor: gray.withOpacity(0.5),
                                onTap: () {
                                  onBackPressed(false);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Utils.backIcon(),
                                ),
                              ),
                            ),
                        ],
                      ),
                      buildOtherDetail(),
                    ],
                  );
                },
              );
            }
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (_chewieController != null &&
                    _chewieController?.videoPlayerController.value != null &&
                    _chewieController!
                        .videoPlayerController.value.isInitialized)
                  Builder(
                    builder: (context) {
                      final aspect = _chewieController!
                          .videoPlayerController.value.aspectRatio;

                      final maxHeight =
                          MediaQuery.of(context).size.height * 0.7;

                      const landscapeHeight = 300.0;

                      return Stack(
                        children: [
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              constraints: BoxConstraints(
                                maxHeight:
                                    aspect < 1 ? maxHeight : landscapeHeight,
                              ),
                              child: AspectRatio(
                                aspectRatio:
                                    _chewieController?.aspectRatio ?? aspect,
                                child: Chewie(
                                  controller: _chewieController!,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 15,
                            left: 15,
                            child: InkWell(
                              onTap: () => onBackPressed(false),
                              child: Utils.buildBackBtnDesign(context),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                else
                  (Constant.userID !=
                              detailsProvider.detailsModel.result![0].userId
                                  .toString() &&
                          detailsProvider.detailsModel.result![0].payContent ==
                              true)
                      ? payVideoApi()
                      : buildImageShimmer(),
                buildOtherDetail(),
              ],
            );
          }
        } else {
          return buildImage();
        }
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget buildImage() {
    if (detailsProvider.loading) {
      return buildImageShimmer();
    } else {
      return Stack(
        children: [
          MyNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: 300,
            fit: BoxFit.fill,
            imagePath: detailsProvider.detailsModel.result?[0].portraitImg
                    .toString() ??
                "",
          ),
          Positioned.fill(
            top: 35,
            left: 15,
            child: Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Utils.backIcon(),
                ),
              ),
            ),
          ),
          /* Play Button */
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  Utils().showInterstitalAds(context, Constant.rewardAdType,
                      () {
                    if (Constant.userID == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ResponsiveHelper.isWeb(context)
                                ? const WebLogin()
                                : const Login();
                          },
                        ),
                      );
                    } else {
                      printLog("StopTime====>${widget.stoptime}");
                      /* StopTime Converted Milisecond To Second */
                      double stopTime = 0.0;
                      if (widget.stoptime == 0) {
                        stopTime = 0.0;
                      } else {
                        double convertTime = (widget.stoptime ?? 0.0) / 1000;
                        stopTime = convertTime;
                      }
                      printLog("StopTime====>${widget.stoptime}");

                      audioPlayer.pause();
                      Utils.openPlayer(
                        isDownloadVideo: false,
                        iscontinueWatching: widget.iscontinueWatching,
                        stoptime: stopTime,
                        context: context,
                        videoId: detailsProvider.detailsModel.result?[0].id
                                .toString() ??
                            "",
                        videoUrl: detailsProvider
                                .detailsModel.result?[0].content
                                .toString() ??
                            "",
                        vUploadType: detailsProvider
                                .detailsModel.result?[0].contentUploadType
                                .toString() ??
                            "",
                        videoThumb: detailsProvider
                                .detailsModel.result?[0].landscapeImg
                                .toString() ??
                            "",
                      );
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: MyImage(width: 50, height: 50, imagePath: "pause.png"),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget buildImageShimmer() {
    return CustomWidget.rectangular(
      width: MediaQuery.of(context).size.width,
      height: 200,
    );
  }

  Widget buildOtherDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              buildDiscription(),
              const SizedBox(height: 15),
              channelItem(),
              const SizedBox(height: 15),
              functionList(),
              const SizedBox(height: 20),
              widget.isComment == 0 ? const SizedBox() : addComment(),
            ],
          ),
        ),
        const SizedBox(height: 20),
        buildRelatedVideo(),
      ],
    );
  }

// Video Image End

/* =====================Video Player================ */

// build Title Discription With view Count

  Widget buildDiscription() {
    if (detailsProvider.loading) {
      return buildDiscriptionShimmer();
    } else {
      if (detailsProvider.detailsModel.result != null &&
          (detailsProvider.detailsModel.result?.length ?? 0) > 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MyText(
                      color: white,
                      text: detailsProvider.detailsModel.result?[0].title
                              .toString() ??
                          "",
                      multilanguage: false,
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textDesc,
                      maxline: 2,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ),
                const SizedBox(
                  width: 10,
                ),
                Constant.userID !=
                            detailsProvider.detailsModel.result![0].userId
                                .toString() &&
                        detailsProvider.detailsModel.result![0].payContent ==
                            true
                    ? Container(
                        padding: const EdgeInsets.fromLTRB(5, 4, 5, 4),
                        decoration: BoxDecoration(
                          color: transparent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            MyImage(
                                width: 18,
                                height: 18,
                                imagePath: "ic_coin.png"),
                            const SizedBox(
                              width: 5,
                            ),
                            MyText(
                              text: detailsProvider
                                  .detailsModel.result![0].payCoin
                                  .toString(),
                              fontsizeNormal: 14,
                              color: white,
                              multilanguage: false,
                            )
                          ],
                        ),
                      )
                    : const SizedBox()
              ],
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: colorPrimaryDark,
                  borderRadius: BorderRadius.circular(15)),
              width: MediaQuery.of(context).size.width,
              constraints: const BoxConstraints(minHeight: 0),
              alignment: Alignment.centerLeft,
              child: ExpandableText(
                detailsProvider.detailsModel.result?[0].description
                        .toString() ??
                    "",
                expandText: "Read More",
                collapseText: "Read less",
                maxLines: 2,
                expandOnTextTap: true,
                collapseOnTextTap: true,
                linkStyle: TextStyle(
                  fontSize: Dimens.textSmall,
                  fontStyle: FontStyle.normal,
                  color: colorPrimary,
                  fontWeight: FontWeight.w600,
                ),
                style: TextStyle(
                  fontSize: Dimens.textSmall,
                  fontStyle: FontStyle.normal,
                  color: gray,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                MyText(
                    color: gray,
                    text: Utils.kmbGenerator(
                        detailsProvider.detailsModel.result?[0].totalView ?? 0),
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textSmall,
                    inter: false,
                    multilanguage: false,
                    maxline: 1,
                    fontwaight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
                const SizedBox(width: 2),
                MyText(
                    color: gray,
                    text: "views",
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textExtraSmalls,
                    inter: false,
                    multilanguage: false,
                    maxline: 1,
                    fontwaight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
                const SizedBox(width: 8),
                MyText(
                    color: gray,
                    text: Utils.timeAgoCustom(DateTime.parse(
                        detailsProvider.detailsModel.result?[0].createdAt ??
                            '0')),
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textExtraSmalls,
                    inter: false,
                    multilanguage: false,
                    maxline: 1,
                    fontwaight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
              ],
            ),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget buildDiscriptionShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomWidget.roundrectborder(
          height: 12,
          width: MediaQuery.of(context).size.width,
        ),
        CustomWidget.roundrectborder(
          height: 12,
          width: MediaQuery.of(context).size.width * 0.75,
        ),
        CustomWidget.roundrectborder(
          height: 12,
          width: MediaQuery.of(context).size.width * 0.30,
        ),
        const SizedBox(height: 5),
        CustomWidget.roundrectborder(
          height: 5,
          width: MediaQuery.of(context).size.width,
        ),
        CustomWidget.roundrectborder(
          height: 5,
          width: MediaQuery.of(context).size.width * 0.50,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget addComment() {
    if (Constant.userID !=
            detailsProvider.detailsModel.result![0].userId.toString() &&
        detailsProvider.detailsModel.result![0].payContent == true) {
      return const SizedBox();
    } else if (detailsProvider.loading) {
      return addCommentShimmer();
    } else {
      return InkWell(
        onTap: () async {
          showComment(context: context);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: colorPrimaryDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyText(
                            color: white,
                            text: "comments",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            inter: false,
                            maxline: 1,
                            multilanguage: true,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 8),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(detailsProvider
                                    .detailsModel.result?[0].totalComment ??
                                0),
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            inter: false,
                            maxline: 1,
                            multilanguage: false,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: white,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Constant.userID == null
                      ? MyImage(
                          width: 25,
                          height: 25,
                          imagePath: "ic_user.png",
                          color: colorPrimary,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyNetworkImage(
                            width: 25,
                            height: 25,
                            imagePath: Constant.userImage ?? "",
                            fit: BoxFit.cover,
                          ),
                        ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 30,
                      decoration: BoxDecoration(
                        color: appbgcolor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: TextFormField(
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        controller: commentController,
                        textInputAction: TextInputAction.done,
                        cursorColor: lightgray,
                        style: Utils.googleFontStyle(4, Dimens.textSmall,
                            FontStyle.normal, white, FontWeight.w400),
                        decoration: InputDecoration(
                          hintStyle: Utils.googleFontStyle(4, Dimens.textSmall,
                              FontStyle.normal, white, FontWeight.w400),
                          hintText: "Add Your comment here...",
                          filled: true,
                          fillColor: colorPrimaryDark.withOpacity(0.50),
                          contentPadding:
                              const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            borderSide:
                                BorderSide(width: 1, color: colorPrimaryDark),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            borderSide:
                                BorderSide(width: 1, color: colorPrimaryDark),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            borderSide:
                                BorderSide(width: 1, color: colorPrimaryDark),
                          ),
                          border: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                              borderSide: BorderSide(
                                  width: 1, color: colorPrimaryDark)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () async {
                      await sendCommentApi('0', true);
                      setState(() {
                        getVideoDetails();
                      });
                    },
                    child: Consumer<DetailsProvider>(
                        builder: (context, detailprovider, child) {
                      if (detailprovider.addcommentloading) {
                        return const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: colorPrimary,
                            strokeWidth: 1,
                          ),
                        );
                      } else {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: colorPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: MyImage(
                            width: 15,
                            height: 15,
                            imagePath: "ic_send.png",
                            color: colorAccent,
                          ),
                        );
                      }
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget addCommentShimmer() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomWidget.roundrectborder(
          height: 5,
          width: 60,
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomWidget.circular(
              width: 35,
              height: 35,
            ),
            SizedBox(width: 10),
            Expanded(
              child: CustomWidget.roundcorner(
                height: 35,
              ),
            ),
            SizedBox(width: 10),
            CustomWidget.circular(
              width: 35,
              height: 35,
            ),
          ],
        ),
      ],
    );
  }

  Widget channelItem() {
    if (detailsProvider.loading) {
      return channelItemShimmer();
    } else {
      return Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _videoPlayerController?.pause();
              });
              if (Constant.userID == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ResponsiveHelper.isWeb(context)
                          ? const WebLogin()
                          : const Login();
                    },
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Profile(
                        isProfile: false,
                        channelUserid: detailsProvider
                                .detailsModel.result?[0].userId
                                .toString() ??
                            "",
                        channelid: detailsProvider
                                .detailsModel.result?[0].channelId
                                .toString() ??
                            "",
                      );
                    },
                  ),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: MyNetworkImage(
                    width: 33,
                    height: 33,
                    imagePath: detailsProvider
                            .detailsModel.result?[0].channelImage
                            .toString() ??
                        "",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MyText(
                      color: white,
                      text: detailsProvider.detailsModel.result?[0].channelName
                              .toString() ??
                          "",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textSmall,
                      multilanguage: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ),
                const SizedBox(
                  width: 5,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: EdgeInsets.all(7),
                color: buttonDisable,
                child: MyText(
                    color: white,
                    text:
                        "${Utils.kmbGenerator(detailsProvider.detailsModel.result?[0].totalSubscriber ?? 0)} Followers",
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textSmall,
                    inter: false,
                    maxline: 1,
                    multilanguage: false,
                    fontwaight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            detailsProvider.detailsModel.result?[0].userId.toString() ==
                    Constant.userID
                ? const SizedBox.shrink()
                : InkWell(
                    onTap: () async {
                      if (Constant.userID == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ResponsiveHelper.isWeb(context)
                                  ? const WebLogin()
                                  : const Login();
                            },
                          ),
                        );
                      } else {
                        await detailsProvider.addremoveSubscribe(
                            detailsProvider.detailsModel.result?[0].userId
                                    .toString() ??
                                "",
                            "1");
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: detailsProvider
                                    .detailsModel.result?[0].isSubscribe ==
                                0
                            ? colorPrimary
                            : appbgcolor,
                        border: Border.all(width: 1, color: colorPrimary),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: MyText(
                          color: detailsProvider
                                      .detailsModel.result?[0].isSubscribe ==
                                  0
                              ? black
                              : white,
                          text: detailsProvider
                                      .detailsModel.result?[0].isSubscribe ==
                                  0
                              ? "subscribe"
                              : "subscribed",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textSmall,
                          inter: false,
                          maxline: 2,
                          multilanguage: true,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                  ),
            const SizedBox(width: 10),
            detailsProvider.detailsModel.result?[0].userId.toString() ==
                        Constant.userID &&
                    (membershipPlanModel?.result.isNotEmpty ?? false)
                ? const SizedBox.shrink()
                : InkWell(
                    onTap: () async {
                      if (Constant.userID == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ResponsiveHelper.isWeb(context)
                                  ? const WebLogin()
                                  : const Login();
                            },
                          ),
                        );
                      } else {
                        if (profileProvider.profileModel.result?[0].id
                                .toString() ==
                            Constant.userID) {
                          await profileProvider.getprofile(
                            context,
                            detailsProvider.detailsModel.result?[0].userId
                                    .toString() ??
                                "",
                          );
                        }

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ViewMembershipPlan(
                                isUser: false,
                                creatorId: profileProvider
                                        .profileModel.result?[0].id
                                        .toString() ??
                                    '0',
                              );
                            },
                          ),
                        );

                        setState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: profileProvider
                                    .profileModel.result?[0].purchasePackage ==
                                0
                            ? colorPrimary
                            : appbgcolor,
                        border: Border.all(width: 1, color: colorPrimary),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: MyText(
                          color: profileProvider.profileModel.result?[0]
                                      .purchasePackage ==
                                  0
                              ? black
                              : white,
                          text: profileProvider.profileModel.result?[0]
                                      .purchasePackage ==
                                  0
                              ? "subscribing"
                              : 'subscriber',
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textSmall,
                          inter: false,
                          maxline: 2,
                          multilanguage: true,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                  ),
          ]),
        ],
      );
    }
  }

  Widget channelItemShimmer() {
    return const Row(
      children: [
        CustomWidget.circular(
          width: 35,
          height: 35,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget.roundrectborder(height: 8),
              SizedBox(height: 5),
              CustomWidget.roundrectborder(
                height: 8,
                width: 100,
              ),
            ],
          ),
        ),
        SizedBox(width: 15),
        CustomWidget.roundcorner(
          height: 18,
          width: 65,
        ),
      ],
    );
  }

  Widget functionList() {
    if (Constant.userID !=
            detailsProvider.detailsModel.result![0].userId.toString() &&
        detailsProvider.detailsModel.result![0].payContent == true) {
      return const SizedBox();
    } else if (detailsProvider.loading) {
      return functionListShimmer();
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            detailsProvider.detailsModel.result?[0].isLike == 1
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: colorPrimaryDark,
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          hoverColor: transparent,
                          splashColor: transparent,
                          highlightColor: transparent,
                          focusColor: transparent,
                          onTap: () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ResponsiveHelper.isWeb(context)
                                        ? const WebLogin()
                                        : const Login();
                                  },
                                ),
                              );
                            } else {
                              if (detailsProvider
                                      .detailsModel.result?[0].isLike ==
                                  0) {
                                Utils().showSnackBar(
                                    context, "youcannotlikethiscontent", true);
                              } else {
                                if ((detailsProvider.detailsModel.result?[0]
                                            .isUserLikeDislike ??
                                        0) ==
                                    1) {
                                  printLog("Remove Api");
                                  await detailsProvider.like(
                                      widget.contentType,
                                      detailsProvider.detailsModel.result?[0].id
                                              .toString() ??
                                          "",
                                      "0",
                                      "0");
                                } else {
                                  await detailsProvider.like(
                                      widget.contentType,
                                      detailsProvider.detailsModel.result?[0].id
                                              .toString() ??
                                          "",
                                      "1",
                                      "0");
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 3, 10, 3),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return ScaleTransition(
                                          scale: animation, child: child);
                                    },
                                    child: (detailsProvider
                                                    .detailsModel
                                                    .result?[0]
                                                    .isUserLikeDislike ??
                                                0) ==
                                            1
                                        ? const Iconify(
                                            Bx.bxs_like,
                                            size: 18,
                                            color: Colors.redAccent,
                                            key: ValueKey<int>(1),
                                          )
                                        : Iconify(
                                            Bx.like,
                                            size: 18,
                                            key: ValueKey<int>(2),
                                            color: white,
                                          ),
                                  ),
                                ),
                                MyText(
                                    color: white,
                                    text: Utils.kmbGenerator(int.parse(
                                        detailsProvider.detailsModel.result?[0]
                                                .totalLike
                                                .toString() ??
                                            "")),
                                    multilanguage: false,
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 7,
                        )
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(width: 8),
            if (!ResponsiveHelper.isWeb(context))
              InkWell(
                hoverColor: transparent,
                splashColor: transparent,
                highlightColor: transparent,
                focusColor: transparent,
                onTap: () {
                  final liveUrl = widget.contentType == '1'
                      ? "Hey! I'm watching ${detailsProvider.detailsModel.result?[0].title ?? ""} "
                          "on ${Constant.appName}! 🎬\n"
                          "Watch here 👉 https://fanbae.tv/video?v=${widget.videoid}/${widget.isComment}/${detailsProvider.detailsModel.result?[0].content?.split('/')[3]}\n"
                      : "Hey! I'm watching ${detailsProvider.detailsModel.result?[0].title ?? ""} "
                          "on ${Constant.appName}! 🎬\n"
                          "Watch here 👉 https://fanbae.tv/live?l=${widget.videoid}/${widget.isComment}/${detailsProvider.detailsModel.result?[0].content?.split('/')[3]}\n";
                  Utils.shareApp(liveUrl);
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: colorPrimaryDark,
                  ),
                  child: Row(
                    children: [
                      MyImage(
                        width: 18,
                        height: 18,
                        imagePath: "ic_share.png",
                        color: white,
                      ),
                      const SizedBox(width: 8),
                      MyText(
                          color: white,
                          text: "share",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textSmall,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                ),
              ),
            const SizedBox(width: 8),
            if (!(kIsWeb))
              (detailsProvider.detailsModel.result?[0].isUserDownload ?? 0) == 1
                  ? _buildDownloadBtn()
                  : const SizedBox.shrink(),
          ],
        ),
      );
    }
  }

  Widget functionListShimmer() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomWidget.roundcorner(
          height: 25,
          width: 90,
        ),
        SizedBox(width: 10),
        CustomWidget.roundcorner(
          height: 25,
          width: 90,
        ),
        SizedBox(width: 10),
        CustomWidget.roundcorner(
          height: 25,
          width: 90,
        ),
      ],
    );
  }

  Widget _buildDownloadBtn() {
    if (detailsProvider.detailsModel.result?[0].contentUploadType ==
            "server_video" ||
        detailsProvider.detailsModel.result?[0].contentUploadType ==
            "external") {
      return Consumer2<DetailsProvider, VideoDownloadProvider>(
        builder: (context, videoDetailsProvider, downloadProvider, child) {
          bool isInDownload = false;
          final itemId = videoDetailsProvider.detailsModel.result?[0].id ?? 0;
          final dProgress = downloadProvider.getProgress(itemId);
          final eProgress = downloadProvider.getEncryptProgress(itemId);
          final isConverting = downloadProvider.isConverting;
          final convertProgress = downloadProvider.convertProgress;

          if (!kIsWeb) {
            if (downloadBox.isOpen &&
                downloadBox.values.toList().isNotEmpty &&
                (downloadBox.values.toList().indexWhere((downloadItem) {
                      return (downloadItem.id ==
                          videoDetailsProvider.detailsModel.result?[0].id);
                    })) !=
                    -1) {
              List<DownloadItem> myDownloadList =
                  downloadBox.values.where((downloadItem) {
                return (downloadItem.id ==
                    videoDetailsProvider.detailsModel.result?[0].id);
              }).toList();
              if (myDownloadList.isNotEmpty) {
                isInDownload = (myDownloadList[0].isDownload == 1);
              }
            }
          }

          return Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(minWidth: 80),
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () async {
                if (Constant.userID != null) {
                  if (!isInDownload && !isConverting) {
                    if (((dProgress == 0 ||
                                dProgress == -1 ||
                                dProgress >= 100) &&
                            (downloadProvider.getEncryptProgress(itemId) ==
                                    0.0 ||
                                downloadProvider.getEncryptProgress(itemId) >=
                                    1.0)) &&
                        !downloadProvider.loading &&
                        (downloadProvider.currentItemId == null ||
                            downloadProvider.currentItemId == 0)) {
                      _checkAndDownload();
                    } else {
                      Utils().showSnackBar(context, "please_wait", false);
                    }
                  } else if (isConverting) {
                    Utils()
                        .showSnackBar(context, "Video is converting...", false);
                  } else {
                    buildDownloadCompleteDialog();
                  }
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ResponsiveHelper.isWeb(context)
                          ? const WebLogin()
                          : const Login()));
                }
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorPrimaryDark,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (context) {
                        // 🔹 Conversion progress indicator
                        if (isConverting && convertProgress < 1.0) {
                          return Container(
                            alignment: Alignment.center,
                            child: CircularPercentIndicator(
                              radius: 10,
                              lineWidth: 3.0,
                              percent: convertProgress,
                              progressColor: colorPrimary,
                              backgroundColor: white,
                            ),
                          );
                        }

                        // 🔹 Download progress
                        else if (dProgress > 0 && dProgress < 100) {
                          return Container(
                            alignment: Alignment.center,
                            child: CircularPercentIndicator(
                              radius: 10,
                              lineWidth: 3.0,
                              percent: dProgress / 100,
                              progressColor: colorPrimary,
                              backgroundColor: white,
                            ),
                          );
                        } else if (eProgress > 0 && eProgress < 1.0) {
                          return Container(
                            alignment: Alignment.center,
                            child: CircularPercentIndicator(
                              radius: 10,
                              lineWidth: 3.0,
                              percent: eProgress,
                              progressColor: colorPrimary,
                              backgroundColor: white,
                            ),
                          );
                        }
                        // 🔹 Default icon
                        else {
                          return Icon(
                            size: 18,
                            isInDownload
                                ? Icons.download_done_rounded
                                : Icons.download,
                            color: white,
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    Builder(
                      builder: (context) {
                        if (isConverting && convertProgress < 1.0) {
                          return MyText(
                            color: white,
                            text:
                                "Processing ${(convertProgress * 100).toStringAsFixed(1)}%",
                            multilanguage: false,
                            fontsizeNormal: Dimens.textSmall,
                            fontwaight: FontWeight.w500,
                            fontsizeWeb: Dimens.textSmall,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          );
                        } else if (dProgress > 0 && dProgress < 100) {
                          return MyText(
                            color: white,
                            text: "$dProgress%",
                            multilanguage: false,
                            fontsizeNormal: Dimens.textSmall,
                            fontwaight: FontWeight.w500,
                            fontsizeWeb: Dimens.textSmall,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          );
                        } else if (eProgress > 0 && eProgress < 1.0) {
                          return MyText(
                            color: white,
                            text:
                                "Saved ${(eProgress * 100).toStringAsFixed(2)}%",
                            multilanguage: false,
                            fontsizeNormal: Dimens.textSmall,
                            fontwaight: FontWeight.w500,
                            fontsizeWeb: Dimens.textSmall,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          );
                        } else {
                          return MyText(
                            color: white,
                            text: isInDownload ? "Downloaded" : "Download",
                            multilanguage: false,
                            fontsizeNormal: Dimens.textSmall,
                            fontwaight: FontWeight.w500,
                            fontsizeWeb: Dimens.textSmall,
                            maxline: 2,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<void> _checkAndDownload() async {
    final result = detailsProvider.detailsModel.result?[0];
    if (result == null || (result.content ?? "").isEmpty) {
      Utils().showSnackBar(context, "Invalid video URL", false);
      return;
    }

    String originalUrl = result.content!;
    String? finalDownloadUrl = originalUrl;

    // If it's an m3u8 stream, convert first
    if (originalUrl.endsWith(".m3u8")) {
      Utils().showSnackBar(context, "Converting video...", false);

      finalDownloadUrl = await ApiService().convertM3U8ToMP4(
        originalUrl,
        (progress) {
          debugPrint(
              "Conversion progress: ${(progress * 100).toStringAsFixed(2)}%");
        },
        context,
      );

      if (finalDownloadUrl == null) {
        Utils().showSnackBar(context, "Conversion failed. Try again.", false);
        return;
      }

      result.content = finalDownloadUrl;
    }

    try {
      await prepareVideoDownload(context, result);
    } catch (e) {
      printLog("Downloading... Exception ======> $e");
    }
  }

  buildDownloadCompleteDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MyText(
                    text: "download_options",
                    multilanguage: true,
                    fontsizeNormal: 16,
                    color: white,
                    fontstyle: FontStyle.normal,
                    fontwaight: FontWeight.w700,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                  ),
                  const SizedBox(height: 5),
                  MyText(
                    text: "download_options_note",
                    multilanguage: true,
                    fontsizeNormal: 10,
                    color: white,
                    fontstyle: FontStyle.normal,
                    fontwaight: FontWeight.w500,
                    maxline: 5,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    focusColor: white,
                    onTap: () async {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      if (Constant.userID != null) {
                        await navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (context) => const MyDownloads(),
                          ),
                        );
                        setState(() {});
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ResponsiveHelper.isWeb(context)
                                  ? const WebLogin()
                                  : const Login();
                            },
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: Dimens.minHtDialogContent,
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyImage(
                            width: Dimens.dialogIconSize,
                            height: Dimens.dialogIconSize,
                            imagePath: "ic_setting.png",
                            fit: BoxFit.fill,
                            color: white,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: MyText(
                              text: "take_me_to_the_downloads_page",
                              multilanguage: true,
                              fontsizeNormal: 14,
                              color: white,
                              fontstyle: FontStyle.normal,
                              fontwaight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    focusColor: white,
                    onTap: () async {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }

                      final itemId =
                          detailsProvider.detailsModel.result?[0].id ?? 0;

                      final downloadBox = Hive.box<DownloadItem>(
                          '${Constant.hiveDownloadBox}_${Constant.userID}');
                      DownloadItem? targetItem;

                      for (int i = 0; i < downloadBox.length; i++) {
                        final item = downloadBox.getAt(i);
                        if (item?.id == itemId) {
                          targetItem = item;
                          await downloadBox.deleteAt(i);
                          break;
                        }
                      }

                      if (targetItem != null) {
                        try {
                          if (File(targetItem.savedFile ?? '').existsSync()) {
                            await File(targetItem.savedFile ?? '').delete();
                          }
                          if (File(targetItem.portraitImg ?? '').existsSync()) {
                            await File(targetItem.portraitImg ?? '').delete();
                          }
                          if (File(targetItem.landscapeImg ?? '')
                              .existsSync()) {
                            await File(targetItem.landscapeImg ?? '').delete();
                          }
                        } catch (e) {
                          printLog("File delete error: $e");
                        }
                      }

                      final downloadProvider =
                          Provider.of<VideoDownloadProvider>(context,
                              listen: false);
                      downloadProvider.clearItem(itemId);
                      downloadProvider.setDownloadProgress(itemId, 0);
                      downloadProvider.setEncryptProgress(itemId, 0.0);
                      downloadProvider.setCurrentDownload(null);
                      downloadProvider.setLoading(false);

                      await detailsProvider.addRemoveDownload(context, itemId);

                      if (context.mounted) {
                        setState(() {});
                        Utils().showSnackBar(
                            context, "Video deleted successfully!", true);
                      }
                    },
                    child: Container(
                      height: Dimens.minHtDialogContent,
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyImage(
                            width: Dimens.dialogIconSize,
                            height: Dimens.dialogIconSize,
                            imagePath: "ic_delete.png",
                            fit: BoxFit.fill,
                            color: white,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: MyText(
                              text: "delete_download",
                              multilanguage: true,
                              fontsizeNormal: 14,
                              color: white,
                              fontstyle: FontStyle.normal,
                              fontwaight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget shimmer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildImageShimmer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 190),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDiscriptionShimmer(),
                      channelItemShimmer(),
                      const SizedBox(height: 10),
                      CustomWidget.roundrectborder(
                        height: 70,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ],
                  ),
                ),
                relatedVideoShimmer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRelatedVideo() {
    if (detailsProvider.loading && !detailsProvider.relatedVideoLoadMore) {
      return shimmer();
    } else {
      if ((Constant.userID !=
                  detailsProvider.detailsModel.result![0].userId.toString() &&
              detailsProvider.detailsModel.result![0].payContent == true) ||
          (_chewieController != null &&
              _chewieController?.videoPlayerController.value != null &&
              _chewieController!.videoPlayerController.value.isInitialized)) {
        if (detailsProvider.relatedVideoModel.status == 200 &&
            detailsProvider.relatedVideoList != null) {
          if ((detailsProvider.relatedVideoList?.length ?? 0) > 0) {
            return Column(
              children: [
                relatedVideoItem(),
                if (detailsProvider.relatedVideoLoadMore)
                  SizedBox(
                    height: 50,
                    child: Utils.pageLoader(context),
                  )
                else
                  const SizedBox.shrink(),
              ],
            );
          } else {
            return const NoData();
          }
        } else {
          return const NoData();
        }
      } else {
        return shimmer();
      }
    }
  }

  Widget relatedVideoItem() {
    final relatedVideos = detailsProvider.relatedVideoList ?? [];

    final displayList =
        showAll ? relatedVideos : relatedVideos.take(2).toList();
    return Column(children: [
      ListView.builder(
        itemCount: displayList.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            highlightColor: transparent,
            focusColor: transparent,
            hoverColor: transparent,
            splashColor: transparent,
            onTap: () async {
              setState(() {
                isDispose = false;
              });
              await Future.delayed(const Duration(milliseconds: 750));
              if (Constant.userID == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ResponsiveHelper.isWeb(context)
                          ? const WebLogin()
                          : const Login();
                    },
                  ),
                );
              } else {
                Utils.moveToDetail(
                    context,
                    0,
                    false,
                    detailsProvider.relatedVideoList?[index].id.toString() ??
                        "",
                    true,
                    widget.contentType,
                    widget.isComment);
              }
            },
            child: detailsProvider.detailsModel.result?[0].videoType ==
                    "episode"
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MyNetworkImage(
                                width: 85,
                                height: 70,
                                imagePath: detailsProvider
                                        .relatedVideoList?[index].portraitImg
                                        .toString() ??
                                    "",
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                      color: white,
                                      text: detailsProvider
                                              .relatedVideoList?[index].title
                                              .toString() ??
                                          "",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textMedium,
                                      maxline: 2,
                                      multilanguage: false,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(height: 8),
                                  RichText(
                                    text: TextSpan(
                                      text: detailsProvider
                                                  .relatedVideoList?[index]
                                                  .isAdminAdded ==
                                              0
                                          ? ""
                                          : "${detailsProvider.relatedVideoList?[index].channelName.toString() ?? ""}  ",
                                      style: Utils.googleFontStyle(
                                          4,
                                          Dimens.textSmall,
                                          FontStyle.normal,
                                          gray,
                                          FontWeight.w400),
                                      children: [
                                        TextSpan(
                                          text:
                                              "${Utils.kmbGenerator(detailsProvider.relatedVideoList?[index].totalView ?? 0)} ",
                                          style: Utils.googleFontStyle(
                                              4,
                                              Dimens.textSmall,
                                              FontStyle.normal,
                                              gray,
                                              FontWeight.w400),
                                        ),
                                        TextSpan(
                                          text: 'views ',
                                          style: Utils.googleFontStyle(
                                              4,
                                              Dimens.textSmall,
                                              FontStyle.normal,
                                              gray,
                                              FontWeight.w400),
                                        ),
                                        TextSpan(
                                          text: Utils.timeAgoCustom(
                                            DateTime.parse(
                                              detailsProvider
                                                      .relatedVideoList?[index]
                                                      .createdAt ??
                                                  "",
                                            ),
                                          ),
                                          style: Utils.googleFontStyle(
                                              4,
                                              Dimens.textSmall,
                                              FontStyle.normal,
                                              gray,
                                              FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Stack(
                        children: [
                          MyNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                              height: 220,
                              imagePath: detailsProvider
                                      .relatedVideoList?[index].landscapeImg
                                      .toString() ??
                                  ""),
                          Positioned.fill(
                            right: 15,
                            bottom: 15,
                            left: 15,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(5, 4, 5, 4),
                                decoration: BoxDecoration(
                                  color: transparent.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: MusicTitle(
                                    color: white,
                                    text: Utils.formatTime(double.parse(
                                        detailsProvider.relatedVideoList?[index]
                                                .contentDuration
                                                .toString() ??
                                            "")),
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: MyNetworkImage(
                                width: 35,
                                height: 35,
                                imagePath: detailsProvider
                                        .relatedVideoList?[index].portraitImg
                                        .toString() ??
                                    "",
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                      color: white,
                                      text: detailsProvider
                                              .relatedVideoList?[index].title
                                              .toString() ??
                                          "",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textMedium,
                                      maxline: 2,
                                      multilanguage: false,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(height: 8),
                                  RichText(
                                    text: TextSpan(
                                      text: detailsProvider
                                                  .relatedVideoList?[index]
                                                  .isAdminAdded ==
                                              0
                                          ? ""
                                          : "${detailsProvider.relatedVideoList?[index].channelName.toString() ?? ""}  ",
                                      style: Utils.googleFontStyle(
                                          4,
                                          Dimens.textSmall,
                                          FontStyle.normal,
                                          gray,
                                          FontWeight.w400),
                                      children: [
                                        TextSpan(
                                          text:
                                              "${Utils.kmbGenerator(detailsProvider.relatedVideoList?[index].totalView ?? 0)} ",
                                          style: Utils.googleFontStyle(
                                              4,
                                              Dimens.textSmall,
                                              FontStyle.normal,
                                              gray,
                                              FontWeight.w400),
                                        ),
                                        TextSpan(
                                          text: 'views ',
                                          style: Utils.googleFontStyle(
                                              4,
                                              Dimens.textSmall,
                                              FontStyle.normal,
                                              gray,
                                              FontWeight.w400),
                                        ),
                                        TextSpan(
                                          text: Utils.timeAgoCustom(
                                            DateTime.parse(
                                              detailsProvider
                                                      .relatedVideoList?[index]
                                                      .createdAt ??
                                                  "",
                                            ),
                                          ),
                                          style: Utils.googleFontStyle(
                                              4,
                                              Dimens.textSmall,
                                              FontStyle.normal,
                                              gray,
                                              FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
      if (!showAll && relatedVideos.length > 2)
        TextButton(
          onPressed: () {
            setState(() {
              showAll = true;
            });
          },
          child: const Text("Load More"),
        ),
    ]);
  }

  Widget relatedVideoShimmer() {
    return ListView.builder(
      itemCount: 2,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            CustomWidget.rectangular(
              width: MediaQuery.of(context).size.width,
              height: 260,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomWidget.circular(
                    width: 35,
                    height: 35,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidget.roundrectborder(
                          width: 250,
                          height: 9,
                        ),
                        CustomWidget.roundrectborder(
                          width: 250,
                          height: 7,
                        ),
                        CustomWidget.roundrectborder(
                          width: 250,
                          height: 7,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  CustomWidget.roundrectborder(
                    width: 5,
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void showComment({required BuildContext context}) async {
    _fetchCommentData(0);
    await showModalBottomSheet(
        isScrollControlled: true,
        scrollControlDisabledMaxHeightRatio: MediaQuery.of(context).size.height,
        context: context,
        backgroundColor: transparent,
        builder: (context) => Consumer<DetailsProvider>(
                builder: (context, detailprovider, child) {
              final isReplying = detailprovider.replyingToCommentId != null;

              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: colorPrimaryDark,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      AppBar(
                        centerTitle: true,
                        backgroundColor: transparent,
                        automaticallyImplyLeading: false,
                        title: MyText(
                            color: white,
                            text: "comments",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textBig,
                            inter: false,
                            maxline: 1,
                            multilanguage: true,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: InkWell(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                                commentController.clear();
                                detailprovider.clearComment();
                              },
                              child: Icon(
                                Icons.close_rounded,
                                size: 25,
                                color: white,
                              ),
                            ),
                          )
                        ],
                      ),
                      Utils.buildGradLine(),
                      Expanded(
                        child: buildComment(),
                      ),
                      Utils.buildGradLine(),
                      addCommentTextField(
                        isReplying ? detailprovider.replyingToCommentId! : '0',
                        !isReplying, // true if comment, false if reply
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  Widget buildComment() {
    if (detailsProvider.commentloading && !detailsProvider.commentloadmore) {
      return commentShimmer();
    } else {
      if (detailsProvider.commentList != null &&
          (detailsProvider.commentList?.length ?? 0) > 0) {
        return RefreshIndicator(
          backgroundColor: colorPrimaryDark,
          color: colorAccent,
          displacement: 70,
          edgeOffset: 1.0,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          strokeWidth: 3,
          onRefresh: () async {
            await detailsProvider.clearComment();
            _fetchCommentData(0);
          },
          child: SingleChildScrollView(
            controller: _commentScrollController,
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                buildCommentItem(),
                if (detailsProvider.commentloadmore)
                  SizedBox(
                    height: 50,
                    child: Utils.pageLoader(context),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget buildCommentItem() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: 1,
      maxItemsPerRow: 1,
      horizontalGridSpacing: 15,
      verticalGridSpacing: 15,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children:
          List.generate(detailsProvider.commentList?.length ?? 0, (index) {
        final comment = detailsProvider.commentList![index];
        final commentId = comment.id.toString();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------- Main Comment Row -----------------
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(comment.image ?? ""),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.47,
                            child: MyText(
                              color: white,
                              text: comment.fullName?.isEmpty ?? true
                                  ? comment.channelName ?? ""
                                  : comment.fullName ?? "",
                              textalign: TextAlign.start,
                              multilanguage: false,
                              fontsizeNormal: Dimens.textMedium,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          MyText(
                            color: white,
                            text: Utils.timeAgoCustom(
                                DateTime.parse(comment.createdAt ?? "")),
                            textalign: TextAlign.left,
                            multilanguage: false,
                            fontsizeNormal: 10,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                      // 🔵 Show mentions inside comment
                      MyText(
                        color: white,
                        text: comment.comment ?? "",
                        multilanguage: false,
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        inter: false,
                        maxline: 5,
                        fontwaight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      InkWell(
                        onTap: () {
                          detailsProvider.storeReplayCommentId(commentId);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (textFieldKey.currentContext != null) {
                              FocusScope.of(textFieldKey.currentContext!)
                                  .requestFocus(commentFocusNode);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: MyText(
                            color: colorAccent,
                            multilanguage: false,
                            text: "Reply",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textSmall,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (comment.userId.toString() == Constant.userID)
                  InkWell(
                    onTap: () async {
                      await detailsProvider.getDeleteComment(commentId);
                      detailsProvider.clearComment();
                      _fetchCommentData(0);
                      getVideoDetails();
                    },
                    child:
                        const Icon(Icons.delete, color: Colors.white, size: 22),
                  ),
              ],
            ),

            const SizedBox(height: 5),

            if ((comment.isReply ?? 0) > 0)
              InkWell(
                onTap: () => detailsProvider.toggleReplies(commentId),
                child: Padding(
                  padding: const EdgeInsets.only(left: 55, top: 5),
                  child: MyText(
                    color: colorAccent,
                    text: detailsProvider.isRepliesExpanded(commentId)
                        ? "Hide replies"
                        : "View replies",
                    fontsizeNormal: Dimens.textSmall,
                    multilanguage: false,
                    textalign: TextAlign.left,
                    inter: false,
                    maxline: 5,
                    fontwaight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),

            // ----------------- Replies Section -----------------
            if (detailsProvider.isRepliesExpanded(commentId))
              Padding(
                padding: const EdgeInsets.only(left: 55, top: 5),
                child: Column(
                  children: [
                    detailsProvider.getReplies(commentId).isNotEmpty
                        ? Column(
                            children: List.generate(
                              detailsProvider.getReplies(commentId).length,
                              (replyIndex) {
                                final reply = detailsProvider
                                    .getReplies(commentId)[replyIndex];
                                return Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundImage:
                                              NetworkImage(reply.image ?? ""),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  MyText(
                                                    color: white,
                                                    text: reply.fullName ?? "",
                                                    fontsizeNormal:
                                                        Dimens.textSmall,
                                                    multilanguage: false,
                                                    textalign: TextAlign.left,
                                                    inter: false,
                                                    maxline: 5,
                                                    fontwaight: FontWeight.w400,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontstyle: FontStyle.normal,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  MyText(
                                                    color: white,
                                                    text: Utils.timeAgoCustom(
                                                        DateTime.parse(
                                                            comment.createdAt ??
                                                                "")),
                                                    textalign: TextAlign.left,
                                                    multilanguage: false,
                                                    fontsizeNormal: 10,
                                                    inter: false,
                                                    maxline: 1,
                                                    fontwaight: FontWeight.w400,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontstyle: FontStyle.normal,
                                                  ),
                                                ],
                                              ),
                                              MyText(
                                                color: white,
                                                text: reply.comment ?? "",
                                                fontsizeNormal:
                                                    Dimens.textSmall,
                                                multilanguage: false,
                                                textalign: TextAlign.left,
                                                inter: false,
                                                maxline: 5,
                                                fontwaight: FontWeight.w400,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (reply.userId.toString() ==
                                            Constant.userID)
                                          InkWell(
                                            onTap: () async {
                                              await detailsProvider
                                                  .getDeleteComment(
                                                      reply.id.toString());
                                              detailsProvider.deleteReply(
                                                  commentId, reply.id ?? 0);
                                            },
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                  ],
                                );
                              },
                            ),
                          )
                        : const NoData(),
                    const Divider(color: gray),
                  ],
                ),
              ),

            const SizedBox(height: 10),
          ],
        );
      }),
    );
  }

  Widget buildCommentItem1() {
    return ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 1,
        maxItemsPerRow: 1,
        horizontalGridSpacing: 15,
        verticalGridSpacing: 15,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children:
            List.generate(detailsProvider.commentList?.length ?? 0, (index) {
          return Container(
            width: MediaQuery.of(context).size.width,
            color: colorPrimaryDark,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(width: 1, color: gray),
                      color: colorPrimary),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: MyNetworkImage(
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                        imagePath: detailsProvider.commentList?[index].image
                                .toString() ??
                            ""),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      detailsProvider.commentList?[index].fullName == ""
                          ? MyText(
                              color: white,
                              multilanguage: false,
                              text: detailsProvider
                                      .commentList?[index].channelName
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textMedium,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal)
                          : MyText(
                              color: white,
                              multilanguage: false,
                              text: detailsProvider.commentList?[index].fullName
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textMedium,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                      MyText(
                          color: white,
                          multilanguage: false,
                          text: detailsProvider.commentList?[index].comment
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textMedium,
                          inter: false,
                          maxline: 5,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      InkWell(
                        onTap: () async {
                          commentController.clear();
                          detailsProvider.storeReplayCommentId(detailsProvider
                                  .commentList?[index].id
                                  .toString() ??
                              "");
                          showReplayComment(
                            context: context,
                            commentId: detailsProvider.commentList?[index].id
                                    .toString() ??
                                "",
                          );
                        },
                        child: MyText(
                            color: colorAccent,
                            multilanguage: true,
                            text: "replay",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textSmall,
                            inter: false,
                            maxline: 5,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),

                /* Delete Comment */
                detailsProvider.commentList?[index].userId.toString() ==
                        Constant.userID
                    ? InkWell(
                        onTap: () async {
                          if (Constant.userID == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ResponsiveHelper.isWeb(context)
                                      ? const WebLogin()
                                      : const Login();
                                },
                              ),
                            );
                          } else {
                            await detailsProvider.getDeleteComment(
                              detailsProvider.commentList?[index].id
                                      .toString() ??
                                  "",
                            );
                            detailsProvider.clearComment();
                            _fetchCommentData(0);
                            getVideoDetails();
                          }
                        },
                        child: Icon(
                          Icons.delete,
                          color: white,
                          size: 22,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          );
        }));
  }

  showReplayComment({required BuildContext context, commentId}) async {
    _fetchReplayCommentData(commentId, 0);
    await showModalBottomSheet(
        isScrollControlled: true,
        scrollControlDisabledMaxHeightRatio: MediaQuery.of(context).size.height,
        context: context,
        backgroundColor: transparent,
        builder: (context) => Consumer<DetailsProvider>(
                builder: (context, detailprovider, child) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: colorPrimaryDark,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      AppBar(
                        centerTitle: true,
                        backgroundColor: transparent,
                        automaticallyImplyLeading: false,
                        title: MyText(
                            color: white,
                            text: "replay",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textBig,
                            inter: false,
                            maxline: 1,
                            multilanguage: true,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: InkWell(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }

                                commentController.clear();
                                detailprovider.clearComment();
                                detailprovider.clearReplayComment();
                              },
                              child: Icon(
                                Icons.close_rounded,
                                size: 25,
                                color: white,
                              ),
                            ),
                          )
                        ],
                      ),
                      Utils.buildGradLine(),
                      Expanded(
                        child: buildReplayComment(commentId),
                      ),
                      Utils.buildGradLine(),
                      addCommentTextField(commentId, false),
                    ],
                  ),
                ),
              );
            }));
  }

  Widget buildReplayComment(commentId) {
    if (detailsProvider.replaycommentloding &&
        !detailsProvider.replayCommentloadmore) {
      return commentShimmer();
    } else {
      if (detailsProvider.replayCommentModel.result != null &&
          (detailsProvider.replaycommentList.length ?? 0) > 0) {
        return RefreshIndicator(
          backgroundColor: colorPrimaryDark,
          color: colorAccent,
          displacement: 70,
          edgeOffset: 1.0,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          strokeWidth: 3,
          onRefresh: () async {
            await detailsProvider.clearReplayComment();
            _fetchReplayCommentData(commentId, 0);
          },
          child: SingleChildScrollView(
            controller: replaycommentController,
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                //buildReplayCommentItem(commentId),
                if (detailsProvider.replayCommentloadmore)
                  SizedBox(
                    height: 50,
                    child: Utils.pageLoader(context),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget commentShimmer() {
    return ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 1,
        maxItemsPerRow: 1,
        horizontalGridSpacing: 10,
        verticalGridSpacing: 10,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(5, (index) {
          return Container(
            width: MediaQuery.of(context).size.width,
            color: colorPrimaryDark,
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Row(
              children: [
                const CustomWidget.circular(height: 35, width: 35),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(
                          height: 15, width: MediaQuery.of(context).size.width),
                      CustomWidget.roundrectborder(
                          height: 15,
                          width: MediaQuery.of(context).size.width * 0.50),
                    ],
                  ),
                ),
              ],
            ),
          );
        }));
  }

  Widget addCommentTextField(String commentId, bool isComment) {
    print('commentId:$commentId,$isComment');
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        bottom: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              key: textFieldKey,
              controller: commentController,
              maxLines: 1,
              textAlign: TextAlign.start,
              focusNode: commentFocusNode,
              decoration: InputDecoration(
                filled: true,
                fillColor: transparent,
                border: InputBorder.none,
                hintText: isComment ? "Add a comment" : "Add a reply",
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: white.withOpacity(0.7),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: white,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Consumer<DetailsProvider>(
            builder: (context, detailsProvider, _) {
              return InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: detailsProvider.addcommentloading
                    ? null
                    : () async {
                        if (commentController.text.trim().isEmpty) return;
                        await sendCommentApi(commentId, isComment);
                        commentController.clear();
                        FocusScope.of(context).unfocus();
                        Provider.of<DetailsProvider>(context, listen: false)
                            .clearReply();
                        getVideoDetails();
                      },
                child: detailsProvider.addcommentloading
                    ? SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          color: colorAccent,
                          strokeWidth: 1.5,
                        ),
                      )
                    : Icon(
                        Icons.send_outlined,
                        color: white,
                        size: 25,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  sendCommentApi(commentId, isComment) async {
    if (Constant.userID == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ResponsiveHelper.isWeb(context)
                ? const WebLogin()
                : const Login();
          },
        ),
      );
    } else {
      if (detailsProvider.detailsModel.result?[0].isComment == 0) {
        Utils().showSnackBar(context, "youcannotcommentthiscontent", false);
      } else if (commentController.text.isEmpty) {
        Utils().showSnackBar(context, "pleaseenteryourcomment", true);
      } else {
        await detailsProvider.getAddComment(
          Constant.videoType,
          widget.videoid,
          "0",
          commentController.text,
          commentId, /** First Time Comment Add Then Pass "0" Other Wise ReplayComment Added then Pass CommentId  */
        );

        if (detailsProvider.addCommentModel.status == 200) {
          if (!context.mounted) return;
          commentController.clear();

          if (isComment) {
            detailsProvider.clearComment();
            _fetchCommentData(0);
            if ((detailsProvider.commentList?.length ?? 0) > 6) {
              _commentScrollController.animateTo(
                _commentScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );

              _commentScrollController.animateTo(
                _commentScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );
            }
          } else {
            detailsProvider.clearReplayComment();
            _fetchReplayCommentData(commentId, 0);
            if ((detailsProvider.replaycommentList?.length ?? 0) > 6) {
              replaycommentController.animateTo(
                replaycommentController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );

              replaycommentController.animateTo(
                replaycommentController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );
            }
          }
        } else {
          if (!mounted) return;
          Navigator.pop(context);
          Utils().showSnackBar(
              context, detailsProvider.addCommentModel.message ?? "", false);
        }
      }
    }
  }

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    printLog("onBackPressed playerCPosition :===> $playerCPosition");
    printLog("onBackPressed videoDuration :===> $videoDuration");

    if ((playerCPosition ?? 0) > 0 &&
        (playerCPosition == videoDuration ||
            (playerCPosition ?? 0) > (videoDuration ?? 0))) {
      playerProvider.removeContentHistory(
          widget.contentType, widget.videoid, "0");
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } else if ((playerCPosition ?? 0) > 0) {
      playerProvider.addContentHistory(
          widget.contentType, widget.videoid, "$playerCPosition", "0");
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } else {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, false);
      }
    }
  }
}

class MentionText extends StatelessWidget {
  final String text;
  final Function(String username) onTap;

  const MentionText({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mentionRegex = RegExp(r'(@\w+)'); // detect @username
    final matches = mentionRegex.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: const TextStyle(color: Colors.white),
      );
    }

    List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(color: Colors.white),
        ));
      }

      final mention = match.group(0)!;
      spans.add(TextSpan(
        text: mention,
        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            onTap(mention.substring(1));
          },
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(color: Colors.white),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
