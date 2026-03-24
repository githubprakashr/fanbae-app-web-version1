import 'package:fanbae/players/player_video.dart';
import 'package:fanbae/players/player_youtube.dart';
import 'package:fanbae/provider/generalprovider.dart';
import 'package:fanbae/utils/customads.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/webpages/webprofile.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:expandable_text/expandable_text.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../model/successmodel.dart';
import '../music/musicdetails.dart';
import '../pages/viewmembershipplan.dart';
import '../provider/profileprovider.dart';
import '../webservice/apiservice.dart';

class WebDetail extends StatefulWidget {
  final String videoid;
  final String feedType;
  final int? stoptime;
  final bool iscontinueWatching;

  const WebDetail(
      {super.key,
      required this.videoid,
      required this.iscontinueWatching,
      required this.stoptime,
      required this.feedType});

  @override
  State<WebDetail> createState() => WebDetailState();
}

class WebDetailState extends State<WebDetail> with RouteAware {
  late DetailsProvider detailsProvider;
  late ProfileProvider profileProvider;

  late GeneralProvider generalProvider;
  late ScrollController _scrollController;
  late ScrollController replaycommentController;
  final commentController = TextEditingController();
  final replayController = TextEditingController();
  late ScrollController _commentScrollController;

  String? userImage;
  bool showAll = false;

  static bool? isPremiumBuy;
  SharedPre sharedPre = SharedPre();

  @override
  void initState() {
    detailsProvider = Provider.of<DetailsProvider>(context, listen: false);
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    printLog("StopTime===> ${widget.stoptime}");
    stopAudio();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    replaycommentController = ScrollController();
    replaycommentController.addListener(_scrollListenerReplayComment);
    _commentScrollController = ScrollController();
    _commentScrollController.addListener(_commentScrollListener);

    /* Fetch Custom Reward Ads */
    fetchRewardAds();
    super.initState();
    getApi();
    _fetchCommentData(0);
    _fetchRelatedVideo(widget.videoid, 0);
  }

  stopAudio() async {
    await audioPlayer.pause();
    await audioPlayer.stop();
  }

  getApi() async {
    await detailsProvider.getvideodetails(
        widget.videoid.toString(), widget.feedType);
    userImage = await sharedPre.read("image");
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

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if ((detailsProvider.currentPageComment ?? 0) <
              (detailsProvider.totalPageComment ?? 0) &&
          (detailsProvider.relatedVideocurrentPage ?? 0) <
              (detailsProvider.relatedVideototalPage ?? 0)) {
        await detailsProvider.setCommentLoadMore(true);
        await detailsProvider.setRelatedLoadMore(true);
        _fetchCommentData(detailsProvider.currentPageComment ?? 0);
        _fetchRelatedVideo(
            widget.videoid, detailsProvider.currentPageComment ?? 0);
      }
    }
  }

  Future<void> _fetchCommentData(int? nextPage) async {
    printLog("isMorePage  ======> ${detailsProvider.morePageComment}");
    printLog("currentPage ======> ${detailsProvider.currentPageComment}");
    printLog("totalPage   ======> ${detailsProvider.totalPageComment}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await detailsProvider.getComment(
        widget.feedType, widget.videoid, (nextPage ?? 0) + 1);
    await detailsProvider.setCommentLoading(false);
  }

/* Replay Comment Start */

  _scrollListenerReplayComment() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (detailsProvider.currentPageReplayComment ?? 0) <
            (detailsProvider.totalPageReplayComment ?? 0)) {
      await detailsProvider.setReplayCommentLoadMore(true);
      _fetchReplayCommentData(detailsProvider.commentId,
          detailsProvider.currentPageReplayComment ?? 0);
    }
  }

  Future<void> _fetchReplayCommentData(commentid, int? nextPage) async {
    printLog("isMorePage  ======> ${detailsProvider.morePageReplayComment}");
    printLog("currentPage ======> ${detailsProvider.currentPageReplayComment}");
    printLog("totalPage   ======> ${detailsProvider.totalPageReplayComment}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await detailsProvider.getReplayComment(commentid, (nextPage ?? 0) + 1);
    await detailsProvider.setReplayCommentLoadMore(false);
  }

/* Replay Comment End */

/* Related Video Start */

  Future<void> _fetchRelatedVideo(contentId, int? nextPage) async {
    await detailsProvider.getRelatedVideo(contentId, (nextPage ?? 0) + 1);
    await detailsProvider.setRelatedLoadMore(false);
  }

/* Related Video End */

  @override
  void dispose() {
    detailsProvider.clearProvider();
    generalProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      // appBar: Utils.webAppbarWithSidePanel(
      //     context: context, contentType: Constant.videoSearch),
      body: Utils().pageBg(
        context,
        child: Consumer<GeneralProvider>(
            builder: (context, generalprovider, child) {
          return SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            padding: MediaQuery.of(context).size.width > 1200
                ? const EdgeInsets.all(20)
                : const EdgeInsets.fromLTRB(20, 20, 20, 20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: MediaQuery.of(context).size.width > 1200
                ? buildLargeScreen()
                : buildSmallScreen(),
          );
        }),
      ),
    );
  }

  payVideoApi() {
    return Stack(
      children: [
        Center(
          child: GestureDetector(
            onTap: () async {
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
                        Utils()
                            .showSnackBar(context, video.message ?? '', false);
                        setState(() {
                          getApi();
                        });
                      });
                    } else {
                      Utils().showSnackBar(context, video.message ?? '', false);
                    }
                  },
                  'wantpayvideo?',
                  () {
                    Navigator.pop(context);
                  });
            },
            child: SizedBox(
              height: 325,
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
              Navigator.pop(context);
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

/* Build Video Player */

  buildLargeScreen() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              /* Video Player With Image  */
              buildImage(),
              /* Video Title With Discription With Comments */
              buildOtherDetail(),
            ],
          ),
        ),
        const SizedBox(width: 20),
        /* Related Video */
        Expanded(
          flex: 1,
          child: buildRelatedVideo(),
        ),
      ],
    );
  }

  buildSmallScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* Video Player With Image  */
            buildImage(),
            /* Video Title With Discription With Comments */
            buildOtherDetail(),
          ],
        ),
        const SizedBox(width: 20),
        /* Related Video */
        buildRelatedVideo(),
      ],
    );
  }

  // Video Image Start

  Widget buildImage() {
    return Consumer<DetailsProvider>(
        builder: (context, detailsprovider, child) {
      if (detailsProvider.loading) {
        return buildImageShimmer();
      } else {
        return Constant.userID !=
                    detailsprovider.detailsModel.result?[0].userId.toString() &&
                detailsprovider.detailsModel.result?[0].payContent == true
            ? payVideoApi()
            : videoWithRewardAds();
      }
    });
  }

  Widget buildImageShimmer() {
    return CustomWidget.roundrectborder(
      width: MediaQuery.of(context).size.width,
      height: 500,
    );
  }

  Widget buildOtherDetail() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildDiscription(),
          const SizedBox(height: 20),
          channelWithButtons(),
          const SizedBox(height: 25),
          addComment(),
          const SizedBox(height: 15),
          buildComment(),
        ],
      ),
    );
  }

// Video Image End

// build Title Discription With view Count

  Widget buildDiscription() {
    return Consumer<DetailsProvider>(
        builder: (context, detailsprovider, child) {
      if (detailsProvider.loading) {
        return buildDiscriptionShimmer();
      } else {
        if (detailsProvider.detailsModel.status == 200 &&
            detailsProvider.detailsModel.result != null) {
          if ((detailsProvider.detailsModel.result?.length ?? 0) > 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                MyText(
                    color: white,
                    text: detailsprovider.detailsModel.result?[0].title
                            .toString() ??
                        "",
                    multilanguage: false,
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textlargeBig,
                    fontsizeWeb: Dimens.textlargeBig,
                    maxline: 5,
                    fontwaight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(15),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorPrimaryDark,
                  ),
                  child: ExpandableText(
                    detailsprovider.detailsModel.result?[0].description
                            .toString() ??
                        "",
                    expandText: "Read More",
                    collapseText: "Read less",
                    maxLines: 2,
                    expandOnTextTap: true,
                    collapseOnTextTap: true,
                    linkStyle: TextStyle(
                      fontSize: Dimens.textDesc,
                      fontStyle: FontStyle.normal,
                      color: colorPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    style: TextStyle(
                      fontSize: Dimens.textMedium,
                      fontStyle: FontStyle.normal,
                      color: white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    MyText(
                        color: gray,
                        text: Utils.kmbGenerator(
                            detailsprovider.detailsModel.result?[0].totalView ??
                                0),
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        inter: false,
                        multilanguage: false,
                        maxline: 2,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(width: 5),
                    MyText(
                        color: gray,
                        text: "views",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        inter: false,
                        multilanguage: true,
                        maxline: 2,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(width: 15),
                    MyText(
                        color: gray,
                        text: Utils.timeAgoCustom(DateTime.parse(detailsprovider
                                .detailsModel.result?[0].createdAt
                                .toString() ??
                            "")),
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        inter: false,
                        multilanguage: false,
                        maxline: 2,
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
        } else {
          return const SizedBox.shrink();
        }
      }
    });
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
        const SizedBox(height: 10),
        CustomWidget.roundrectborder(
          height: 5,
          width: MediaQuery.of(context).size.width,
        ),
        CustomWidget.roundrectborder(
          height: 5,
          width: MediaQuery.of(context).size.width * 0.50,
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            CustomWidget.circular(
              height: 10,
              width: 10,
            ),
            SizedBox(width: 5),
            CustomWidget.roundrectborder(
              height: 5,
              width: 60,
            ),
            SizedBox(width: 15),
            CustomWidget.roundrectborder(
              height: 5,
              width: 60,
            ),
          ],
        ),
      ],
    );
  }

// Add Comment Seaction
  Widget addComment() {
    return Consumer<DetailsProvider>(
      builder: (context, detailsprovider, child) {
        if (detailsProvider.loading) {
          return addCommentShimmer();
        } else {
          return Constant.userID !=
                      detailsprovider.detailsModel.result?[0].userId
                          .toString() &&
                  detailsprovider.detailsModel.result?[0].payContent == true
              ? const SizedBox()
              : SingleChildScrollView(
                  controller: _commentScrollController,
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        color: white,
                        text: "comments",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textBig,
                        fontsizeWeb: Dimens.textBig,
                        inter: false,
                        maxline: 2,
                        multilanguage: true,
                        fontwaight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Constant.userID == null
                              ? MyImage(
                                  width: 35,
                                  height: 35,
                                  color: colorPrimary,
                                  imagePath: "ic_user.png",
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: MyNetworkImage(
                                    width: 35,
                                    height: 35,
                                    imagePath: userImage?.toString() ?? "",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              obscureText: false,
                              onFieldSubmitted: (value) {
                                addCommentApi();
                              },
                              keyboardType: TextInputType.text,
                              controller: commentController,
                              textInputAction: TextInputAction.done,
                              cursorColor: lightgray,
                              style: Utils.googleFontStyle(
                                4,
                                Dimens.textMedium,
                                FontStyle.normal,
                                white,
                                FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                hintStyle: Utils.googleFontStyle(
                                  4,
                                  Dimens.textMedium,
                                  FontStyle.normal,
                                  white,
                                  FontWeight.w400,
                                ),
                                hintText: "Add a comment...",
                                filled: false,
                                focusColor: transparent,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 0.8, color: colorPrimary),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 0.8, color: white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () async {
                              addCommentApi();
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
                                      width: 20,
                                      height: 20,
                                      imagePath: "ic_send.png",
                                      color: colorAccent,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
        }
      },
    );
  }

  addCommentApi() async {
    if (Constant.userID == null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const WebLogin(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      if (detailsProvider.detailsModel.result?[0].isComment == 0) {
        Utils().showSnackBar(context, "youcannotcommentthiscontent", true);
      } else if (commentController.text.isEmpty) {
        Utils().showSnackBar(context, "pleaseenteryourcomment", true);
      } else {
        await detailsProvider.getAddComment(
          "1",
          widget.videoid,
          "0",
          commentController.text.toString(),
          "0",
        );
        if (detailsProvider.addCommentModel.status == 200) {
          if (!context.mounted) return;
          commentController.clear();
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
          if (!mounted) return;
          Navigator.pop(context);
          Utils().showSnackBar(
              context, detailsProvider.addCommentModel.message ?? "", false);
        }
        commentController.clear();
      }
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

// Channel Info With Like Dislike Button
  Widget channelWithButtons() {
    return Consumer<DetailsProvider>(
        builder: (context, detailsprovider, child) {
      if (detailsprovider.loading) {
        return Utils.pageLoader(context);
      } else {
        if (MediaQuery.of(context).size.width > 1200) {
          return Constant.userID !=
                      detailsProvider.detailsModel.result?[0].userId
                          .toString() &&
                  detailsProvider.detailsModel.result?[0].payContent == true
              ? const SizedBox()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        if (Constant.userID == null) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  const WebLogin(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  WebProfile(
                                isProfile: false,
                                channelUserid: detailsProvider
                                        .detailsModel.result?[0].userId
                                        .toString() ??
                                    "",
                                channelid: detailsProvider
                                        .detailsModel.result?[0].channelId
                                        .toString() ??
                                    "",
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: MyNetworkImage(
                              width: 35,
                              height: 35,
                              imagePath: detailsProvider
                                      .detailsModel.result?[0].channelImage
                                      .toString() ??
                                  "",
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyText(
                                  color: white,
                                  text: detailsProvider
                                          .detailsModel.result?[0].channelName
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textDesc,
                                  fontsizeWeb: Dimens.textDesc,
                                  multilanguage: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  MyText(
                                      color: white,
                                      text: Utils.kmbGenerator(detailsProvider
                                              .detailsModel
                                              .result?[0]
                                              .totalSubscriber ??
                                          0),
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textSmall,
                                      fontsizeWeb: Dimens.textSmall,
                                      inter: false,
                                      maxline: 1,
                                      multilanguage: false,
                                      fontwaight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(width: 5),
                                  MyText(
                                      color: white,
                                      text: "subscriber",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      inter: false,
                                      maxline: 1,
                                      multilanguage: true,
                                      fontwaight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 25),
                          detailsProvider.detailsModel.result?[0].userId
                                      .toString() ==
                                  Constant.userID
                              ? const SizedBox.shrink()
                              : InkWell(
                                  onTap: () async {
                                    if (Constant.userID == null) {
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              const WebLogin(),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      );
                                    } else {
                                      await detailsProvider.addremoveSubscribe(
                                          detailsProvider.detailsModel
                                                  .result?[0].userId
                                                  .toString() ??
                                              "",
                                          "1");
                                    }
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(14, 8, 14, 8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: detailsProvider.detailsModel
                                                  .result?[0].isSubscribe ==
                                              0
                                          ? colorPrimary
                                          : appbgcolor,
                                      border: Border.all(
                                          width: 1, color: colorPrimary),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: MyText(
                                        color: detailsProvider.detailsModel
                                                    .result?[0].isSubscribe ==
                                                0
                                            ? black
                                            : white,
                                        text: detailsProvider.detailsModel
                                                    .result?[0].isSubscribe ==
                                                0
                                            ? "subscribe"
                                            : "subscribed",
                                        textalign: TextAlign.left,
                                        fontsizeNormal: Dimens.textSmall,
                                        fontsizeWeb: Dimens.textSmall,
                                        inter: false,
                                        maxline: 2,
                                        multilanguage: true,
                                        fontwaight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                  ),
                                ),
                          const SizedBox(width: 10),
                          detailsProvider.detailsModel.result?[0].userId
                                      .toString() ==
                                  Constant.userID
                              ? const SizedBox.shrink()
                              : InkWell(
                                  onTap: () async {
                                    if (Constant.userID == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return const WebLogin();
                                          },
                                        ),
                                      );
                                    } else {
                                      await profileProvider.getprofile(
                                        context,
                                        detailsProvider
                                                .detailsModel.result?[0].userId
                                                .toString() ??
                                            "",
                                      );
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ViewMembershipPlan(
                                              isUser: false,
                                              creatorId: profileProvider
                                                      .profileModel
                                                      .result?[0]
                                                      .id
                                                      .toString() ??
                                                  '0',
                                            );
                                          },
                                        ),
                                      );

                                      // 👉 If you want to refresh UI after coming back
                                      setState(() {});
                                    }
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 5, 8, 5),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: colorPrimary,
                                      border: Border.all(
                                          width: 1, color: colorPrimary),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: MyText(
                                        color: black,
                                        text: "subscribing",
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
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        detailsProvider.detailsModel.result?[0].isLike == 1
                            ? Container(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: colorPrimaryDark,
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        if (Constant.userID == null) {
                                          Navigator.pushReplacement(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation1,
                                                      animation2) =>
                                                  const WebLogin(),
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ),
                                          );
                                        } else {
                                          if (detailsProvider.detailsModel
                                                  .result?[0].isLike ==
                                              0) {
                                            Utils().showSnackBar(
                                                context,
                                                "youcannotlikethiscontent",
                                                true);
                                          } else {
                                            if ((detailsProvider
                                                        .detailsModel
                                                        .result?[0]
                                                        .isUserLikeDislike ??
                                                    0) ==
                                                1) {
                                              printLog("Remove Api");
                                              await detailsProvider.like(
                                                  "1",
                                                  detailsProvider.detailsModel
                                                          .result?[0].id
                                                          .toString() ??
                                                      "",
                                                  "0",
                                                  "0");
                                            } else {
                                              await detailsProvider.like(
                                                  "1",
                                                  detailsProvider.detailsModel
                                                          .result?[0].id
                                                          .toString() ??
                                                      "",
                                                  "1",
                                                  "0");
                                            }
                                          }
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          (detailsProvider
                                                          .detailsModel
                                                          .result?[0]
                                                          .isUserLikeDislike ??
                                                      0) ==
                                                  1
                                              ? MyImage(
                                                  width: 20,
                                                  height: 20,
                                                  fit: BoxFit.cover,
                                                  color: colorPrimary,
                                                  imagePath: "ic_likefill.png",
                                                )
                                              : MyImage(
                                                  width: 25,
                                                  height: 25,
                                                  imagePath: "ic_like.png",
                                                  color: white,
                                                ),
                                          const SizedBox(width: 8),
                                          MyText(
                                              color: white,
                                              text: Utils.kmbGenerator(
                                                  detailsProvider
                                                          .detailsModel
                                                          .result?[0]
                                                          .totalLike ??
                                                      0),
                                              multilanguage: false,
                                              textalign: TextAlign.center,
                                              fontsizeNormal: Dimens.textDesc,
                                              fontsizeWeb: Dimens.textDesc,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w500,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                        ],
                                      ),
                                    ),
                                    /* const SizedBox(width: 10),
                              Container(
                                width: 1,
                                height: 20,
                                color: white,
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () async {
                                  if (Constant.userID == null) {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                const WebLogin(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
                                  } else {
                                    // Dislike APi Call
                                    if (detailsProvider
                                            .detailsModel.result?[0].isLike ==
                                        0) {
                                      Utils().showSnackbar(context,
                                          "youcannotlikethiscontent", true);
                                    } else {
                                      if ((detailsProvider
                                                  .detailsModel
                                                  .result?[0]
                                                  .isUserLikeDislike ??
                                              2) ==
                                          0) {
                                        printLog("Remove Api");
                                        await detailsProvider.dislike(
                                            "1",
                                            detailsProvider
                                                    .detailsModel.result?[0].id
                                                    .toString() ??
                                                "",
                                            "0",
                                            "0");
                                      } else {
                                        await detailsProvider.dislike(
                                            "1",
                                            detailsProvider
                                                    .detailsModel.result?[0].id
                                                    .toString() ??
                                                "",
                                            "2",
                                            "0");
                                      }
                                    }
                                  }
                                },
                                child: (detailsProvider.detailsModel.result?[0]
                                                .isUserLikeDislike ??
                                            0) ==
                                        2
                                    ? MyImage(
                                        width: 25,
                                        height: 25,
                                        color: colorPrimary,
                                        imagePath: "ic_dislikefill.png",
                                      )
                                    : MyImage(
                                        width: 25,
                                        height: 25,
                                        imagePath: "ic_dislike.png",
                                      ),
                              ),
                              const SizedBox(width: 10),*/
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ],
                );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  if (Constant.userID == null) {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            WebProfile(
                          isProfile: false,
                          channelUserid: detailsProvider
                                  .detailsModel.result?[0].userId
                                  .toString() ??
                              "",
                          channelid: detailsProvider
                                  .detailsModel.result?[0].channelId
                                  .toString() ??
                              "",
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: MyNetworkImage(
                        width: 35,
                        height: 35,
                        imagePath: detailsProvider
                                .detailsModel.result?[0].channelImage
                                .toString() ??
                            "",
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                            color: white,
                            text: detailsProvider
                                    .detailsModel.result?[0].channelName
                                    .toString() ??
                                "",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textDesc,
                            fontsizeWeb: Dimens.textDesc,
                            multilanguage: false,
                            maxline: 1,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            MyText(
                                color: white,
                                text: Utils.kmbGenerator(int.parse(
                                    detailsProvider.detailsModel.result?[0]
                                            .totalSubscriber
                                            .toString() ??
                                        "")),
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textSmall,
                                fontsizeWeb: Dimens.textSmall,
                                inter: false,
                                maxline: 1,
                                multilanguage: false,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            const SizedBox(width: 5),
                            MyText(
                                color: white,
                                text: "subscriber",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textMedium,
                                fontsizeWeb: Dimens.textMedium,
                                inter: false,
                                maxline: 1,
                                multilanguage: true,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 25),
                    detailsProvider.detailsModel.result?[0].userId.toString() ==
                            Constant.userID
                        ? const SizedBox.shrink()
                        : InkWell(
                            onTap: () async {
                              if (Constant.userID == null) {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            const WebLogin(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              } else {
                                await detailsProvider.addremoveSubscribe(
                                    detailsProvider
                                            .detailsModel.result?[0].userId
                                            .toString() ??
                                        "",
                                    "1");
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: detailsProvider.detailsModel.result?[0]
                                            .isSubscribe ==
                                        0
                                    ? colorPrimary
                                    : appbgcolor,
                                border:
                                    Border.all(width: 1, color: colorPrimary),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: MyText(
                                  color: white,
                                  text: detailsProvider.detailsModel.result?[0]
                                              .isSubscribe ==
                                          0
                                      ? "subscribe"
                                      : "subscribed",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textSmall,
                                  fontsizeWeb: Dimens.textSmall,
                                  inter: false,
                                  maxline: 2,
                                  multilanguage: true,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  detailsProvider.detailsModel.result?[0].isLike == 1
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: colorPrimaryDark,
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  if (Constant.userID == null) {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                const WebLogin(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
                                  } else {
                                    if (detailsProvider
                                            .detailsModel.result?[0].isLike ==
                                        0) {
                                      Utils().showSnackBar(context,
                                          "youcannotlikethiscontent", true);
                                    } else {
                                      if ((detailsProvider
                                                  .detailsModel
                                                  .result?[0]
                                                  .isUserLikeDislike ??
                                              0) ==
                                          1) {
                                        printLog("Remove Api");
                                        await detailsProvider.like(
                                            "1",
                                            detailsProvider
                                                    .detailsModel.result?[0].id
                                                    .toString() ??
                                                "",
                                            "0",
                                            "0");
                                      } else {
                                        await detailsProvider.like(
                                            "1",
                                            detailsProvider
                                                    .detailsModel.result?[0].id
                                                    .toString() ??
                                                "",
                                            "1",
                                            "0");
                                      }
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    (detailsProvider.detailsModel.result?[0]
                                                    .isUserLikeDislike ??
                                                0) ==
                                            1
                                        ? MyImage(
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.cover,
                                            imagePath: "ic_likefill.png",
                                          )
                                        : MyImage(
                                            width: 25,
                                            height: 25,
                                            imagePath: "ic_like.png",
                                            color: white,
                                          ),
                                    const SizedBox(width: 8),
                                    MyText(
                                        color: white,
                                        text: Utils.kmbGenerator(int.parse(
                                            detailsProvider.detailsModel
                                                    .result?[0].totalLike
                                                    .toString() ??
                                                "")),
                                        multilanguage: false,
                                        textalign: TextAlign.center,
                                        fontsizeNormal: Dimens.textDesc,
                                        fontsizeWeb: Dimens.textDesc,
                                        inter: false,
                                        maxline: 1,
                                        fontwaight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              /*Container(
                                width: 1,
                                height: 20,
                                color: white,
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () async {
                                  if (Constant.userID == null) {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                const WebLogin(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
                                  } else {
                                    // Dislike APi Call
                                    if (detailsProvider
                                            .detailsModel.result?[0].isLike ==
                                        0) {
                                      Utils().showSnackBar(context,
                                          "youcannotlikethiscontent", true);
                                    } else {
                                      if ((detailsProvider
                                                  .detailsModel
                                                  .result?[0]
                                                  .isUserLikeDislike ??
                                              2) ==
                                          0) {
                                        printLog("Remove Api");
                                        await detailsProvider.dislike(
                                            "1",
                                            detailsProvider
                                                    .detailsModel.result?[0].id
                                                    .toString() ??
                                                "",
                                            "0",
                                            "0");
                                      } else {
                                        await detailsProvider.dislike(
                                            "1",
                                            detailsProvider
                                                    .detailsModel.result?[0].id
                                                    .toString() ??
                                                "",
                                            "2",
                                            "0");
                                      }
                                    }
                                  }
                                },
                                child: (detailsProvider.detailsModel.result?[0]
                                                .isUserLikeDislike ??
                                            0) ==
                                        2
                                    ? MyImage(
                                        width: 25,
                                        height: 25,
                                        imagePath: "ic_dislikefill.png",
                                      )
                                    : MyImage(
                                        width: 25,
                                        height: 25,
                                        imagePath: "ic_dislike.png",
                                      ),
                              ),
                              const SizedBox(width: 10),*/
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ],
          );
        }
      }
    });
  }

  // Comments
  Widget buildComment() {
    return Consumer<DetailsProvider>(builder: (context, detailprovider, child) {
      if (detailprovider.commentloading && !detailprovider.commentloadmore) {
        return commentShimmer();
      } else {
        return Column(
          children: [
            commentList(),
            if (detailsProvider.commentloadmore)
              Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                child: Utils.pageLoader(context),
              )
            else
              const SizedBox.shrink(),
          ],
        );
      }
    });
  }

  Widget commentList() {
    if (detailsProvider.getcommentModel.status == 200 &&
        detailsProvider.commentList != null) {
      if ((detailsProvider.commentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: detailsProvider.commentList?.length ?? 0,
            itemBuilder: (BuildContext ctx, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: MyNetworkImage(
                        width: 35,
                        height: 35,
                        imagePath: detailsProvider.commentList?[index].image
                                .toString() ??
                            "",
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                              color: white,
                              text: detailsProvider
                                      .commentList?[index].channelName
                                      .toString() ??
                                  "",
                              fontsizeNormal: Dimens.textMedium,
                              fontsizeWeb: Dimens.textMedium,
                              fontwaight: FontWeight.w500,
                              multilanguage: false,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              inter: false,
                              textalign: TextAlign.center,
                              fontstyle: FontStyle.normal),
                          const SizedBox(height: 5),
                          MyText(
                              color: gray,
                              text: detailsProvider.commentList?[index].comment
                                      .toString() ??
                                  "",
                              fontsizeNormal: Dimens.textSmall,
                              fontsizeWeb: Dimens.textSmall,
                              fontwaight: FontWeight.w400,
                              multilanguage: false,
                              inter: false,
                              maxline: 2,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.left,
                              fontstyle: FontStyle.normal),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  detailsProvider.storeReplayCommentId(
                                      detailsProvider.commentList?[index].id
                                              .toString() ??
                                          "");
                                  _fetchReplayCommentData(
                                      detailsProvider.commentList?[index].id
                                              .toString() ??
                                          "",
                                      0);
                                  replayCommentBottomSheet(
                                      index,
                                      detailsProvider.detailsModel.result?[0].id
                                              .toString() ??
                                          "",
                                      detailsProvider.commentList?[index].id
                                              .toString() ??
                                          "",
                                      detailsProvider.commentList?[index].image
                                              .toString() ??
                                          "",
                                      detailsProvider
                                              .commentList?[index].channelName
                                              .toString() ??
                                          "",
                                      detailsProvider
                                              .commentList?[index].comment
                                              .toString() ??
                                          "");
                                },
                                child: MyText(
                                  text: "replay",
                                  fontsizeNormal: Dimens.textSmall,
                                  fontsizeWeb: Dimens.textSmall,
                                  color: white,
                                  fontstyle: FontStyle.normal,
                                  inter: false,
                                  fontwaight: FontWeight.w500,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textalign: TextAlign.center,
                                  multilanguage: true,
                                ),
                              ),
                              const SizedBox(width: 15),
                              if (detailsProvider.commentList?[index].userId
                                      .toString() ==
                                  Constant.userID)
                                if (detailsProvider.deletecommentLoading)
                                  const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: colorPrimary,
                                      strokeWidth: 1,
                                    ),
                                  )
                                else
                                  InkWell(
                                    onTap: () async {
                                      if (Constant.userID == null) {
                                        Navigator.pushReplacement(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation1,
                                                    animation2) =>
                                                const WebLogin(),
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration:
                                                Duration.zero,
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
                                        await detailsProvider.getvideodetails(
                                            widget.videoid.toString(), "1");
                                      }
                                    },
                                    child: MyImage(
                                        width: 15,
                                        height: 15,
                                        color: white,
                                        imagePath: "ic_delete.png"),
                                  ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget commentShimmer() {
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (BuildContext ctx, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomWidget.circular(
                  width: 35,
                  height: 35,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(
                        width: MediaQuery.of(context).size.width,
                        height: 5,
                      ),
                      const SizedBox(height: 5),
                      CustomWidget.roundrectborder(
                        width: MediaQuery.of(context).size.width,
                        height: 5,
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          CustomWidget.circular(
                            width: 20,
                            height: 10,
                          ),
                          SizedBox(width: 15),
                          CustomWidget.circular(
                            width: 20,
                            height: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

// Replay Comment
  replayCommentBottomSheet(int index, videoid, commentid, commentUserImage,
      commentUsername, comment) {
    showDialog<void>(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return Wrap(
          children: [
            buildReplayComment(index, videoid, commentid, commentUserImage,
                commentUsername, comment),
          ],
        );
      },
    );
  }

  Widget buildReplayComment(
      index, videoid, commentId, commentUserImage, commentUsername, comment) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: colorPrimaryDark,
      child: Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20.0),
        constraints: const BoxConstraints(
          minWidth: 500,
          maxWidth: 600,
          minHeight: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 20),
                      child: MyText(
                          color: white,
                          text: "replay",
                          fontsizeNormal: Dimens.textTitle,
                          fontsizeWeb: Dimens.textTitle,
                          fontwaight: FontWeight.w500,
                          multilanguage: true,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          inter: false,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        Navigator.pop(context);
                        replayController.clear();
                        //detailsProvider.clearComment();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: MyImage(
                          width: 15,
                          height: 15,
                          imagePath: "ic_close.png",
                          fit: BoxFit.contain,
                          color: white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(width: 1, color: white)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: MyNetworkImage(
                          imagePath: commentUserImage,
                          fit: BoxFit.fill,
                          width: 26,
                          height: 26),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                          color: white,
                          text: commentUsername,
                          fontsizeNormal: Dimens.textMedium,
                          fontsizeWeb: Dimens.textMedium,
                          fontwaight: FontWeight.w500,
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          inter: false,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                      const SizedBox(height: 5),
                      MyText(
                          color: white,
                          text: comment,
                          fontsizeNormal: Dimens.textSmall,
                          fontsizeWeb: Dimens.textSmall,
                          fontwaight: FontWeight.w400,
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          inter: false,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(child: buildreplayCommentList()),
            Utils.buildGradLine(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              alignment: Alignment.center,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: replayController,
                        maxLines: 1,
                        scrollPhysics: const AlwaysScrollableScrollPhysics(),
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: transparent,
                          border: InputBorder.none,
                          hintText: "Replay Comments",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: white,
                          ),
                          contentPadding:
                              const EdgeInsets.only(left: 10, right: 10),
                        ),
                        obscureText: false,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () async {
                        if (Constant.userID == null) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  const WebLogin(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        } else if (replayController.text.isEmpty) {
                          Utils().showToast("Please Enter Your Comment");
                        } else {
                          printLog("videoid==> $videoid");
                          printLog("comment==> ${replayController.text}");
                          printLog("comment==> $commentId");
                          await detailsProvider.getaddReplayComment(
                            "1",
                            videoid,
                            "0",
                            replayController.text,
                            commentId,
                          );
                          replayController.clear();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Consumer<DetailsProvider>(
                              builder: (context, detailprovider, child) {
                            if (detailprovider.addreplaycommentloading) {
                              return const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: colorPrimary,
                                  strokeWidth: 1,
                                ),
                              );
                            } else {
                              return MyImage(
                                  width: 20,
                                  height: 20,
                                  imagePath: "ic_send.png");
                            }
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildreplayCommentList() {
    return SingleChildScrollView(
      controller: replaycommentController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
      child:
          Consumer<DetailsProvider>(builder: (context, detailprovider, child) {
        if (detailprovider.replaycommentloding &&
            !detailprovider.replayCommentloadmore) {
          return Utils.pageLoader(context);
        } else {
          return Column(
            children: [
              // replayCommentList(),
              if (detailprovider.replayCommentloadmore)
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                  child: Utils.pageLoader(context),
                )
              else
                const SizedBox.shrink(),
            ],
          );
        }
      }),
    );
  }

  /*Widget replayCommentList() {
    if (detailsProvider.replayCommentModel.status == 200) {
      if ((detailsProvider.replaycommentList.length ?? 0) > 0) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: detailsProvider.replaycommentList.length ?? 0,
                  itemBuilder: (BuildContext ctx, index) {
                    final reply =
                    detailsProvider.getReplies()[replyIndex]
                    return Container(
                      // color: gray,
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(width: 1, color: white)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: MyNetworkImage(
                                  imagePath: detailsProvider
                                          .replaycommentList[index].image
                                          .toString() ??
                                      "",
                                  fit: BoxFit.fill,
                                  width: 20,
                                  height: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                detailsProvider.replaycommentList?[index]
                                            .fullName ==
                                        ""
                                    ? MyText(
                                        color: white,
                                        text: detailsProvider
                                                .replaycommentList?[index]
                                                .fullName
                                                .toString() ??
                                            "",
                                        fontsizeNormal: Dimens.textDesc,
                                        fontsizeWeb: Dimens.textDesc,
                                        fontwaight: FontWeight.w600,
                                        multilanguage: false,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        inter: false,
                                        textalign: TextAlign.center,
                                        fontstyle: FontStyle.normal)
                                    : MyText(
                                        color: white,
                                        text: detailsProvider
                                                .replaycommentList?[index]
                                                .channelName
                                                .toString() ??
                                            "",
                                        fontsizeNormal: Dimens.textMedium,
                                        fontsizeWeb: Dimens.textMedium,
                                        fontwaight: FontWeight.w500,
                                        multilanguage: false,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        inter: false,
                                        textalign: TextAlign.center,
                                        fontstyle: FontStyle.normal),
                                const SizedBox(height: 5),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  child: MyText(
                                      color: white,
                                      text: detailsProvider
                                              .replaycommentList?[index].comment
                                              .toString() ??
                                          "",
                                      fontsizeNormal: Dimens.textSmall,
                                      fontsizeWeb: Dimens.textSmall,
                                      fontwaight: FontWeight.w400,
                                      multilanguage: false,
                                      maxline: 3,
                                      overflow: TextOverflow.ellipsis,
                                      inter: false,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (detailsProvider.replaycommentList?[index].userId
                                  .toString() ==
                              Constant.userID)
                            if (detailsProvider.deletecommentLoading)
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: colorPrimary,
                                  strokeWidth: 1,
                                ),
                              )
                            else
                              InkWell(
                                onTap: () async {
                                  if (Constant.userID == null) {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                const WebLogin(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
                                  } else {
                                    await detailsProvider.getDeleteComment(
                                      detailsProvider
                                              .replaycommentList?[index].id
                                              .toString() ??
                                          "",
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MyImage(
                                      width: 16,
                                      height: 16,
                                      color: colorPrimary,
                                      imagePath: "ic_delete.png"),
                                ),
                              )
                        ],
                      ),
                    );
                  }),
            ),
            if (detailsProvider.commentloading)
              const CircularProgressIndicator(
                color: colorPrimary,
              )
            else
              const SizedBox.shrink(),
          ],
        );
      } else {
        return const Expanded(child: NoData(title: "", subTitle: ""));
      }
    } else {
      return const Expanded(child: NoData(title: "", subTitle: ""));
    }
  }*/

  /* Related Video Intigrated Curretly Web Not a Mobile App */

  Widget buildRelatedVideo() {
    return Consumer<DetailsProvider>(builder: (context, detailprovider, child) {
      if (detailsProvider.loading && !detailsProvider.relatedVideoLoadMore) {
        return relatedVideoListShimmer();
      } else {
        if (detailsProvider.relatedVideoModel.status == 200 &&
            detailsProvider.relatedVideoList != null) {
          if ((detailsProvider.relatedVideoList?.length ?? 0) > 0) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: gray),
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  MyText(
                      color: white,
                      text: detailprovider.detailsModel.result?[0].title
                              .toString() ??
                          "",
                      fontsizeNormal: Dimens.textBig,
                      fontsizeWeb: Dimens.textBig,
                      fontwaight: FontWeight.w500,
                      multilanguage: false,
                      maxline: 3,
                      overflow: TextOverflow.ellipsis,
                      inter: false,
                      textalign: TextAlign.left,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 20),
                  relatedVideoList(),
                  if (detailsProvider.relatedVideoLoadMore)
                    SizedBox(height: 50, child: Utils.pageLoader(context))
                  else
                    const SizedBox.shrink(),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return const SizedBox.shrink();
        }
      }
    });
  }

  Widget relatedVideoList() {
    final relatedVideos = detailsProvider.relatedVideoList ?? [];

    // limit list length based on showAll
    final displayList =
        showAll ? relatedVideos : relatedVideos.take(2).toList();
    return Column(children: [
      ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: displayList.length,
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
              onTap: () {
                generalProvider.clearProvider();
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => WebDetail(
                        stoptime: 0,
                        iscontinueWatching: false,
                        videoid: detailsProvider.relatedVideoList?[index].id
                                .toString() ??
                            "",
                        feedType: widget.feedType),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: MyNetworkImage(
                              width: MediaQuery.of(context).size.width > 1200
                                  ? 120
                                  : 200,
                              height: MediaQuery.of(context).size.width > 1200
                                  ? 75
                                  : 105,
                              imagePath: detailsProvider
                                      .relatedVideoList?[index].landscapeImg
                                      .toString() ??
                                  "",
                              fit: BoxFit.cover),
                        ),
                        Positioned.fill(
                          right: 5,
                          bottom: 5,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(3, 2, 3, 2),
                              decoration: BoxDecoration(
                                color: transparent.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: MyText(
                                  color: white,
                                  text: Utils.formatTime(double.parse(
                                      detailsProvider.relatedVideoList?[index]
                                              .contentDuration
                                              .toString() ??
                                          "")),
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textExtraSmall,
                                  fontsizeWeb: Dimens.textExtraSmall,
                                  inter: false,
                                  multilanguage: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                              color: white,
                              text: detailsProvider
                                      .relatedVideoList?[index].title
                                      .toString() ??
                                  "",
                              fontsizeNormal:
                                  MediaQuery.of(context).size.width > 1200
                                      ? Dimens.textSmall
                                      : Dimens.textTitle,
                              fontsizeWeb:
                                  MediaQuery.of(context).size.width > 1200
                                      ? Dimens.textSmall
                                      : Dimens.textTitle,
                              fontwaight: FontWeight.w400,
                              multilanguage: false,
                              maxline: 2,
                              overflow: TextOverflow.ellipsis,
                              inter: false,
                              textalign: TextAlign.left,
                              fontstyle: FontStyle.normal),
                          const SizedBox(height: 5),
                          MyText(
                              color: gray,
                              text: detailsProvider
                                      .relatedVideoList?[index].channelName
                                      .toString() ??
                                  "",
                              fontsizeNormal: Dimens.textMedium,
                              fontsizeWeb: Dimens.textMedium,
                              fontwaight: FontWeight.w400,
                              multilanguage: false,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              inter: false,
                              textalign: TextAlign.left,
                              fontstyle: FontStyle.normal),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                      color: gray,
                                      text: Utils.kmbGenerator(detailsProvider
                                              .relatedVideoList?[0].totalView ??
                                          0),
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      fontwaight: FontWeight.w400,
                                      multilanguage: false,
                                      maxline: 1,
                                      overflow: TextOverflow.ellipsis,
                                      inter: false,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(width: 5),
                                  MyText(
                                      color: gray,
                                      text: "views",
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      fontwaight: FontWeight.w400,
                                      multilanguage: true,
                                      maxline: 1,
                                      overflow: TextOverflow.ellipsis,
                                      inter: false,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal),
                                ],
                              ),
                              const SizedBox(width: 5),
                              // Expanded(
                              //   child: MyText(
                              //       color: gray,
                              //       text: Utils.timeAgoCustom(
                              //         DateTime.parse(
                              //           detailsProvider.relatedVideoList?[index]
                              //                   .createdAt ??
                              //               "",
                              //         ),
                              //       ),
                              //       fontsizeNormal: Dimens.textMedium,
                              //       fontsizeWeb: Dimens.textMedium,
                              //       fontwaight: FontWeight.w400,
                              //       multilanguage: false,
                              //       maxline: 1,
                              //       overflow: TextOverflow.ellipsis,
                              //       inter: false,
                              //       textalign: TextAlign.left,
                              //       fontstyle: FontStyle.normal),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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

  Widget relatedVideoListShimmer() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (BuildContext ctx, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Row(
            children: [
              CustomWidget.roundrectborder(
                width: MediaQuery.of(context).size.width > 1200 ? 120 : 200,
                height: MediaQuery.of(context).size.width > 1200 ? 75 : 105,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(
                      height: 10,
                    ),
                    SizedBox(height: 5),
                    CustomWidget.roundrectborder(
                      height: 10,
                    ),
                    SizedBox(height: 5),
                    CustomWidget.roundrectborder(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget videoWithRewardAds() {
    return Consumer<GeneralProvider>(
        builder: (context, generalprovider, child) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 500,
          child: ((generalProvider.getRewardAdsModel.status == 200 &&
                      (generalprovider.getRewardAdsModel.result != null)) &&
                  Constant.rewardadStatus == "1" &&
                  (!(isPremiumBuy ?? false)) &&
                  (generalprovider.getRewardAdsModel.result?.isHide ?? 0) ==
                      0 &&
                  (generalprovider.isCloseRewardAds == false) &&
                  (generalprovider.showSkip == false))
              ? generalprovider.loading
                  ? buildImageShimmer()
                  : AdsPlayer(
                      contentId: widget.videoid,
                      videoUrl: generalprovider.getRewardAdsModel.result?.video
                              .toString() ??
                          "",
                    )
              : showVideoPlayer(
                  videoId:
                      detailsProvider.detailsModel.result?[0].id.toString() ??
                          "",
                  vUploadType: detailsProvider
                          .detailsModel.result?[0].contentUploadType
                          .toString() ??
                      "",
                  videoThumb: detailsProvider
                          .detailsModel.result?[0].landscapeImg
                          .toString() ??
                      "",
                  videoUrl: detailsProvider.detailsModel.result?[0].content
                          .toString() ??
                      "",
                  stoptime: widget.stoptime,
                  iscontinueWatching: widget.iscontinueWatching,
                ),
        ),
      );
    });
  }

  Widget showVideoPlayer(
      {vUploadType,
      videoId,
      videoUrl,
      videoThumb,
      stoptime,
      iscontinueWatching,
      isDownloadVideo}) {
    if (videoUrl == "") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: MyNetworkImage(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.fill,
          imagePath: videoThumb,
        ),
      );
    } else if (vUploadType == "youtube") {
      return PlayerYoutube(videoId, videoUrl, vUploadType, videoThumb, stoptime,
          iscontinueWatching);
    } else if (vUploadType == "external") {
      if (videoUrl.contains('youtube')) {
        return PlayerYoutube(videoId, videoUrl, vUploadType, videoThumb,
            stoptime, iscontinueWatching);
      } else {
        return PlayerVideo(
          videoId: videoId,
          stoptime: stoptime,
          videoUrl: videoUrl,
          vUploadType: vUploadType,
          videoThumb: videoThumb,
          iscontinueWatching: iscontinueWatching,
          isDownloadVideo: isDownloadVideo,
        );
      }
    } else {
      return PlayerVideo(
        videoId: videoId,
        stoptime: stoptime,
        videoUrl: videoUrl,
        vUploadType: vUploadType,
        videoThumb: videoThumb,
        iscontinueWatching: iscontinueWatching,
        isDownloadVideo: isDownloadVideo,
      );
    }
  }

  fetchRewardAds() async {
    await generalProvider.getAds(3);
  }

/* Play Button */
// Positioned.fill(
//   child: Align(
//     alignment: Alignment.center,
//     child: InkWell(
//       onTap: () {
//         CustomAdsHelper()
//             .showAds(context, Constant.rewardAdType, "0", () {
//           if (Constant.userID == null) {
//             Navigator.push(
//               context,
//               PageRouteBuilder(
//                 pageBuilder: (context, animation1, animation2) =>
//                     const WebLogin(),
//                 transitionDuration: Duration.zero,
//                 reverseTransitionDuration: Duration.zero,
//               ),
//             );
//           } else {
//             printLog("StopTime====>${widget.stoptime}");
//             /* StopTime Converted Milisecond To Second */
//             String stopTime = "0";
//             if (widget.stoptime.isEmpty || widget.stoptime == "") {
//               stopTime = "0";
//             } else {
//               double convertTime =
//                   int.parse(widget.stoptime) / 1000;
//               stopTime = convertTime.toString();
//             }
//             printLog("StopTime====>${widget.stoptime}");

//             audioPlayer.pause();
//             Utils.openPlayer(
//               iscontinueWatching: widget.iscontinueWatching,
//               stoptime: stopTime,
//               context: context,
//               videoId: detailsprovider.detailsModel.result?[0].id
//                       .toString() ??
//                   "",
//               videoUrl: detailsprovider
//                       .detailsModel.result?[0].content
//                       .toString() ??
//                   "",
//               vUploadType: detailsprovider
//                       .detailsModel.result?[0].contentUploadType
//                       .toString() ??
//                   "",
//               videoThumb: detailsprovider
//                       .detailsModel.result?[0].landscapeImg
//                       .toString() ??
//                   "",
//             );
//           }
//         });
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child:
//             MyImage(width: 50, height: 50, imagePath: "pause.png"),
//       ),
//     ),
//   ),
// ),
}
