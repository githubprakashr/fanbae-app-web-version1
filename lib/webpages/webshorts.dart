import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:fanbae/music/musicdetails.dart';
import 'package:fanbae/provider/shortprovider.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/webpages/webprofile.dart';
import 'package:fanbae/widget/mymarqueetext.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:fanbae/widget/nopost.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/pages/reelsplayer.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_html/html.dart' as html;

import '../livestream/livestreamprovider.dart';
import '../model/membership_plan_model.dart';
import '../model/successmodel.dart';
import '../pages/bottombar.dart';
import '../pages/shorts.dart';
import '../pages/viewmembershipplan.dart';
import '../provider/generalprovider.dart';
import '../provider/homeprovider.dart';
import '../provider/profileprovider.dart';
import '../subscription/adspackage.dart';
import '../utils/responsive_helper.dart';
import '../webservice/apiservice.dart';

class WebShorts extends StatefulWidget {
  final String? shortType;
  final int? initialIndex;

  const WebShorts({Key? key, this.shortType, this.initialIndex})
      : super(key: key);

  @override
  State<WebShorts> createState() => WebShortsState();
}

class WebShortsState extends State<WebShorts> {
  SharedPre sharePref = SharedPre();
  late ProgressDialog prDialog;
  late ShortProvider shortProvider;
  final commentController = TextEditingController();
  final CarouselSliderController _shortPageController =
      CarouselSliderController();
  final CarouselSliderController _profileController =
      CarouselSliderController();
  final CarouselSliderController _watchLaterController =
      CarouselSliderController();
  late ScrollController commentListController;
  late ScrollController reportReasonController;
  bool ischange = true;
  List<VideoPlayerController> controllers = [];
  late VideoPlayerController controller;
  late ScrollController replaycommentController;
  late Future<void> initializeVideoPlayerFuture;
  late ProfileProvider profileProvider;
  MembershipPlanModel? membershipPlanModel;

  String _selectedFeed = 'for_you';
  bool _showTopWidgets = true;
  ScrollDirection _lastScrollDirection = ScrollDirection.idle;
  late GeneralProvider generalProvider;
  late HomeProvider homeProvider;
  late ScrollController _giftScrollController;
  late LiveStreamProvider liveStreamProvider;

  @override
  void initState() {
    shortProvider = Provider.of<ShortProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    liveStreamProvider =
        Provider.of<LiveStreamProvider>(context, listen: false);

    _giftScrollController = ScrollController();

    _giftScrollController.addListener(_scrollGiftListener);
    //getProfileData();
    audioPlayer.pause();
    getApi();
    commentListController = ScrollController();
    reportReasonController = ScrollController();
    replaycommentController = ScrollController();
    commentListController.addListener(_scrollListener);
    reportReasonController.addListener(_scrollListenerReportReason);
    replaycommentController.addListener(_scrollListenerReplayComment);
    super.initState();
    printLog("Userid==> ${Constant.userID}");
  }

  _scrollGiftListener() async {
    if (!_giftScrollController.hasClients) return;
    if (_giftScrollController.offset >=
            _giftScrollController.position.maxScrollExtent &&
        !_giftScrollController.position.outOfRange &&
        (liveStreamProvider.currentPage ?? 0) <
            (liveStreamProvider.totalPage ?? 0)) {
      await liveStreamProvider.setLoadMore(true);
      _fetchGift(liveStreamProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchGift(int? nextPage) async {
    await liveStreamProvider.getProfile(context, Constant.userID);
    await liveStreamProvider.fetchGift((nextPage ?? 0) + 1);
  }

  getApi() async {
    if (widget.shortType == "profile") {
      await shortProvider.getcontentbyChannelShort(
          Constant.userID, Constant.channelID, "3", "1");
    } else if (widget.shortType == "watchlater") {
      await shortProvider.getContentByWatchLater("3", "1");
    } else {
      await shortProvider.getShortList(1, _selectedFeed);
    }
  }

  Future<void> _loadMembershipForIndex(int index) async {
    final userId =
        shortProvider.shortVideoList?[index].userId?.toString() ?? "";
    if (userId.isEmpty) return;

    // 👉 Fetch profile for this user
    await profileProvider.getprofile(context, userId);

    final creatorId =
        profileProvider.profileModel.result?[0].id.toString() ?? "0";

    // 👉 Fetch membership plans for this creator
    membershipPlanModel = await ApiService().getMembershipPlans(
      creatorId,
      Constant.userID,
    );

    if (membershipPlanModel != null) {
      print('membershipPlanModel${membershipPlanModel!.result.length}');
    }

    setState(() {}); // refresh UI
  }

  getProfileData() async {
    await generalProvider.getWebGeneralsetting(context);

    if (!mounted) return;
    Utils().getDeviceTokenWithPermissionWeb();

    if (Constant.userID != null) {
      await homeProvider.getprofile(Constant.userID);
      await sharePref.save(
          "userpanelstatus",
          homeProvider.profileModel.result?[0].userPenalStatus.toString() ??
              "");
      Constant.userPanelStatus = await sharePref.read("userpanelstatus");

      await Utils.getCustomAdsStatus();
    }
  }

  _scrollListener() async {
    if (!commentListController.hasClients) return;
    if (commentListController.offset >=
            commentListController.position.maxScrollExtent &&
        !commentListController.position.outOfRange &&
        (shortProvider.currentPageComment ?? 0) <
            (shortProvider.totalPageComment ?? 0)) {
      _fetchCommentNewData(
          shortProvider.commentId, shortProvider.currentPageComment ?? 0);
    }
  }

  _scrollListenerReportReason() async {
    if (!reportReasonController.hasClients) return;
    if (reportReasonController.offset >=
            reportReasonController.position.maxScrollExtent &&
        !reportReasonController.position.outOfRange &&
        (shortProvider.reportcurrentPage ?? 0) <
            (shortProvider.reporttotalPage ?? 0)) {
      await shortProvider.setReportReasonLoadMore(true);
      _fetchReportReason(shortProvider.reportcurrentPage ?? 0);
    }
  }

  _scrollListenerReplayComment() async {
    if (!replaycommentController.hasClients) return;
    if (replaycommentController.offset >=
            replaycommentController.position.maxScrollExtent &&
        !replaycommentController.position.outOfRange &&
        (shortProvider.currentPageReplayComment ?? 0) <
            (shortProvider.totalPageReplayComment ?? 0)) {
      await shortProvider.setReplayCommentLoadMore(true);
      _fetchReplayCommentData(shortProvider.replayCommentId,
          shortProvider.currentPageReplayComment ?? 0);
    }
  }

  Future _fetchReportReason(int? nextPage) async {
    printLog("reportmorePage  =======> ${shortProvider.reportmorePage}");
    printLog("reportcurrentPage =======> ${shortProvider.reportcurrentPage}");
    printLog("reporttotalPage   =======> ${shortProvider.reporttotalPage}");
    printLog("nextPage   ========> $nextPage");
    await shortProvider.getReportReason("2", (nextPage ?? 0) + 1);
    printLog(
        "fetchReportReason length ==> ${shortProvider.reportReasonList?.length}");
  }

  Future _fetchAllShort() async {
    printLog("isMorePage  =======> ${shortProvider.morePage}");
    printLog("currentPage =======> ${shortProvider.currentPage}");
    printLog("totalPage   =======> ${shortProvider.totalPage}");
    int nextPage = (shortProvider.currentPage ?? 0) + 1;
    printLog("nextPage   ========> $nextPage");
    if ((shortProvider.currentPage ?? 0) <= (shortProvider.totalPage ?? 0) &&
        nextPage <= (shortProvider.totalPage ?? 0)) {
      await shortProvider.getShortList(nextPage, '');
    }
    printLog(
        "shortVideoList length ==> ${shortProvider.shortVideoList?.length}");
  }

  Future _fetchCommentNewData(contentid, int? nextPage) async {
    printLog("isMorePage  =======> ${shortProvider.morePageComment}");
    printLog("currentPage =======> ${shortProvider.currentPageComment}");
    printLog("totalPage   =======> ${shortProvider.totalPageComment}");
    int nextPage = (shortProvider.currentPageComment ?? 0) + 1;
    printLog("nextPage   ========> $nextPage");
    if ((shortProvider.currentPageComment ?? 0) <=
            (shortProvider.totalPageComment ?? 0) &&
        nextPage <= (shortProvider.totalPageComment ?? 0)) {
      await shortProvider.getComment("3", contentid, nextPage);
    }
    printLog("commentlist length ==> ${shortProvider.commentList?.length}");
  }

  Future _fetchUserShort() async {
    printLog("userShortmorePage  =======> ${shortProvider.userShortmorePage}");
    printLog(
        "userShortcurrentPage =======> ${shortProvider.profileShortcurrentPage}");
    printLog(
        "userShorttotalPage   =======> ${shortProvider.profileShorttotalPage}");
    int nextPage = (shortProvider.profileShortcurrentPage ?? 0) + 1;
    printLog("nextPage   ========> $nextPage");
    if ((shortProvider.profileShortcurrentPage ?? 0) <=
            (shortProvider.profileShorttotalPage ?? 0) &&
        nextPage <= (shortProvider.profileShorttotalPage ?? 0)) {
      await shortProvider.getcontentbyChannelShort(
          Constant.userID, Constant.channelID, "3", nextPage);
    }
    printLog(
        "UsershortList length ==> ${shortProvider.profileShortList?.length}");
  }

  Future _fetchWatchLaterShort() async {
    printLog("userShortmorePage  =======> ${shortProvider.userShortmorePage}");
    printLog(
        "userShortcurrentPage =======> ${shortProvider.profileShortcurrentPage}");
    printLog(
        "userShorttotalPage   =======> ${shortProvider.profileShorttotalPage}");
    int nextPage = (shortProvider.profileShortcurrentPage ?? 0) + 1;
    printLog("nextPage   ========> $nextPage");
    if ((shortProvider.profileShortcurrentPage ?? 0) <=
            (shortProvider.profileShorttotalPage ?? 0) &&
        nextPage <= (shortProvider.profileShorttotalPage ?? 0)) {
      await shortProvider.getcontentbyChannelShort(
          Constant.userID, Constant.channelID, "3", nextPage);
    }
    printLog(
        "UsershortList length ==> ${shortProvider.profileShortList?.length}");
  }

  Future<void> _fetchReplayCommentData(commentid, int? nextPage) async {
    printLog("isMorePage  ======> ${shortProvider.morePageReplayComment}");
    printLog("currentPage ======> ${shortProvider.currentPageReplayComment}");
    printLog("totalPage   ======> ${shortProvider.totalPageReplayComment}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await shortProvider.getReplayComment(commentid, (nextPage ?? 0) + 1);
    await shortProvider.setReplayCommentLoadMore(false);
  }

  @override
  void dispose() {
    // shortProvider.clearProvider();
    super.dispose();
  }

  Widget buildSearchField() {
    return TextFormField(
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: white, fontWeight: FontWeight.w700),
      controller: shortProvider.searchController,
      decoration: InputDecoration(
          hintText: "search",
          hintStyle: TextStyle(color: white),
          fillColor: ResponsiveHelper.checkIsWeb(context)
              ? colorPrimaryDark
              : white.withOpacity(0.42),
          filled: true,
          contentPadding: const EdgeInsets.only(top: 15, left: 10),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent)),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                if (shortProvider.searchController.text.isNotEmpty) {
                  shortProvider.searchController.clear();
                  getApi();
                }
                shortProvider.isShowSearch = !shortProvider.isShowSearch;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(13.0),
              child: CircleAvatar(
                radius: 7,
                backgroundColor: white,
                child: Icon(
                  Icons.close,
                  color: black,
                  size: 14,
                ),
              ),
            ),
          )),
      onChanged: (value) {
        setState(() {
          getApi();
        });
      },
    );
  }

  Widget buildTopWidgets() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedFeed = "for_you";
                getApi();
              });
            },
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                  gradient: _selectedFeed == "for_you"
                      ? Constant.gradientColor
                      : null,
                  border: Border.all(
                      color:
                          _selectedFeed != "for_you" ? textColor : transparent),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_alt_1_sharp,
                    color: _selectedFeed != "for_you" ? white : black,
                    size: 17,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  MyText(
                    text: "foryou",
                    fontwaight: FontWeight.w600,
                    fontsizeNormal: 12,
                    color: _selectedFeed != "for_you" ? white : black,
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedFeed = "following";
                getApi();
              });
            },
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                  gradient: _selectedFeed != "for_you"
                      ? Constant.gradientColor
                      : null,
                  border: Border.all(
                      color:
                          _selectedFeed == "for_you" ? textColor : transparent),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person,
                      color: _selectedFeed == "for_you" ? white : black,
                      size: 17),
                  const SizedBox(
                    width: 4,
                  ),
                  MyText(
                    text: "following",
                    color: _selectedFeed == "for_you" ? white : black,
                    fontwaight: FontWeight.w600,
                    fontsizeNormal: 12,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                shortProvider.isShowSearch = !shortProvider.isShowSearch;
              });
            },
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                  border: Border.all(color: textColor),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, color: white, size: 17),
                  const SizedBox(
                    width: 4,
                  ),
                  MyText(
                      text: "search",
                      color: white,
                      fontwaight: FontWeight.w600,
                      fontsizeNormal: 12)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      generalProvider.isPanel = false;
    }
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: Utils.webAppbarWithSidePanel(
          context: context, contentType: Constant.videoSearch),
      body: Utils.sidePanelWithBody(
        myWidget: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLayout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLayout() {
    if (widget.shortType == "profile") {
      return _buildProfileShortPageView();
    } else if (widget.shortType == "watchlater") {
      return _buildWatchLaterShortPageView();
    } else {
      return _buildShortPageView();
    }
  }

/* Simple Short */

  Widget _buildShortPageView() {
    return Stack(
      children: [
        Consumer<ShortProvider>(builder: (context, shortprovider, child) {
          if (shortprovider.loading) {
            return shimmer();
          } else {
            if (shortprovider.shortModel.status == 200) {
              if (shortprovider.shortVideoList != null &&
                  (shortprovider.shortVideoList?.length ?? 0) > 0) {
                return Utils().pageBg(
                  context,
                  child: Stack(
                    children: [
                      NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          if (notification is UserScrollNotification) {
                            if (notification.direction ==
                                ScrollDirection.forward) {
                              // Scrolling up
                              setState(() {
                                _lastScrollDirection = notification.direction;
                                _showTopWidgets = true;
                              });
                            } else if (notification.direction ==
                                ScrollDirection.reverse) {
                              // Scrolling down
                              setState(() {
                                _lastScrollDirection = notification.direction;
                                _showTopWidgets = false;
                              });
                            } else if (notification.direction ==
                                ScrollDirection.idle) {
                              // When scrolling stops, keep the last state
                              setState(() {
                                _lastScrollDirection = notification.direction;
                              });
                            }
                          }
                          return false;
                        },
                        child: CarouselSlider.builder(
                            itemCount:
                                shortProvider.shortVideoList?.length ?? 0,
                            carouselController: _shortPageController,
                            options: CarouselOptions(
                              initialPage: 0,
                              scrollPhysics:
                                  const AlwaysScrollableScrollPhysics(),
                              onPageChanged: (index, reason) async {
                                _loadMembershipForIndex(index);
                                await shortProvider.changePageViewIndex(index);
                                if (index > 0 && (index % 2) == 0) {
                                  _fetchAllShort();
                                }
                              },
                              scrollDirection: Axis.vertical,
                              height: ((html.window.screen?.height as double) *
                                  0.80),
                              enlargeCenterPage: false,
                              enlargeFactor: 0.18,
                              autoPlay: false,
                              autoPlayCurve: Curves.easeInOutQuart,
                              enableInfiniteScroll: false,
                              viewportFraction: 1.0,
                            ),
                            itemBuilder: (BuildContext context, int index,
                                int pageViewIndex) {
                              return Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                    width: MediaQuery.of(context).size.width >
                                            600
                                        ? Dimens.getResponsiveBox(context, 0)
                                        : MediaQuery.of(context).size.width *
                                            0.80,
                                    height: ((html.window.screen?.height
                                            as double) *
                                        0.70),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: ReelsPlayer(
                                            isLiveStream: false,
                                            index: index,
                                            pagePos: index,
                                            thumbnailImg: shortProvider
                                                    .shortVideoList?[index]
                                                    .portraitImg
                                                    .toString() ??
                                                "",
                                            videoUrl: shortProvider
                                                    .shortVideoList?[index]
                                                    .content
                                                    .toString() ??
                                                "",
                                          ),
                                        ),
                                        /* Channel Name, Reels Title */
                                        Positioned.fill(
                                          left: 5,
                                          right: 5,
                                          bottom: 5,
                                          child: Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                /* Uploded Reels User Image */
                                                shortProvider
                                                            .shortVideoList?[
                                                                index]
                                                            .userId !=
                                                        0
                                                    ? InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            PageRouteBuilder(
                                                              pageBuilder: (context,
                                                                      animation1,
                                                                      animation2) =>
                                                                  WebProfile(
                                                                isProfile:
                                                                    false,
                                                                channelUserid: shortProvider
                                                                        .shortVideoList?[
                                                                            index]
                                                                        .userId
                                                                        .toString() ??
                                                                    "",
                                                                channelid: shortProvider
                                                                        .shortVideoList?[
                                                                            index]
                                                                        .channelId
                                                                        .toString() ??
                                                                    "",
                                                              ),
                                                              transitionDuration:
                                                                  Duration.zero,
                                                              reverseTransitionDuration:
                                                                  Duration.zero,
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          width: 250,
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  0, 5, 0, 5),
                                                          child: Row(
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50),
                                                                child: MyNetworkImage(
                                                                    width: 25,
                                                                    height: 25,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    imagePath: shortProvider
                                                                            .shortVideoList?[index]
                                                                            .channelImage
                                                                            .toString() ??
                                                                        ""),
                                                              ),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Expanded(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Expanded(
                                                                      child: shortProvider.shortVideoList?[index].channelName.toString() ==
                                                                              ""
                                                                          ? MyText(
                                                                              color:
                                                                                  white,
                                                                              text:
                                                                                  "guestuser",
                                                                              multilanguage:
                                                                                  true,
                                                                              textalign: TextAlign
                                                                                  .left,
                                                                              fontsizeNormal: Dimens
                                                                                  .textTitle,
                                                                              inter:
                                                                                  false,
                                                                              maxline:
                                                                                  1,
                                                                              fontwaight: FontWeight
                                                                                  .w600,
                                                                              overflow: TextOverflow
                                                                                  .ellipsis,
                                                                              fontstyle: FontStyle
                                                                                  .normal)
                                                                          : MyText(
                                                                              color: white,
                                                                              text: shortProvider.shortVideoList?[index].channelName.toString() ?? "",
                                                                              multilanguage: false,
                                                                              textalign: TextAlign.left,
                                                                              fontsizeNormal: Dimens.textTitle,
                                                                              inter: false,
                                                                              maxline: 1,
                                                                              fontwaight: FontWeight.w600,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              fontstyle: FontStyle.normal),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            10),
                                                                    /* User Subscribe Button */
                                                                    Constant.userID !=
                                                                            shortProvider.shortVideoList?[index].userId
                                                                                .toString()
                                                                        ? InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              if (Constant.userID == null) {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  PageRouteBuilder(
                                                                                    pageBuilder: (context, animation1, animation2) => const WebLogin(),
                                                                                    transitionDuration: Duration.zero,
                                                                                    reverseTransitionDuration: Duration.zero,
                                                                                  ),
                                                                                );
                                                                              } else {
                                                                                await shortProvider.addremoveSubscribe(index, shortProvider.shortVideoList?[index].userId.toString() ?? "", "1", widget.shortType);
                                                                              }
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(5),
                                                                                color: shortProvider.shortVideoList?[index].isSubscribe == 0 ? colorPrimary : transparent,
                                                                                gradient: shortProvider.shortVideoList?[index].isSubscribe == 0 ? Constant.gradientColor : null,
                                                                              ),
                                                                              child: MyText(color: shortProvider.shortVideoList?[index].isSubscribe == 0 ? pureBlack : white, text: shortProvider.shortVideoList?[index].isSubscribe == 0 ? "subscribe" : "subscribed", multilanguage: true, textalign: TextAlign.center, fontsizeNormal: 10, fontsizeWeb: 11, inter: false, maxline: 1, fontwaight: FontWeight.w600, overflow: TextOverflow.ellipsis, fontstyle: FontStyle.normal),
                                                                            ),
                                                                          )
                                                                        : const SizedBox
                                                                            .shrink(),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Constant.userID != shortProvider.shortVideoList?[index].userId.toString() &&
                                                                            (membershipPlanModel?.result.isNotEmpty ??
                                                                                false)
                                                                        ? InkWell(
                                                                            onTap:
                                                                                () async {
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
                                                                                if (profileProvider.profileModel.result?[0].id.toString() == Constant.userID) {
                                                                                  await profileProvider.getprofile(
                                                                                    context,
                                                                                    shortProvider.shortVideoList?[index].userId.toString() ?? "",
                                                                                  );
                                                                                }

                                                                                // 👉 Then navigate after profile data is ready
                                                                                await Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) {
                                                                                      return ViewMembershipPlan(
                                                                                        isUser: false,
                                                                                        creatorId: profileProvider.profileModel.result?[0].id.toString() ?? '0',
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                );

                                                                                // 👉 If you want to refresh UI after coming back
                                                                                setState(() {});
                                                                              }
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(5),
                                                                                gradient: Constant.gradientColor,
                                                                              ),
                                                                              child: MyText(color: pureBlack, text: "subscribing", multilanguage: true, textalign: TextAlign.center, fontsizeNormal: Dimens.textSmall, fontsizeWeb: 11, inter: false, maxline: 1, fontwaight: FontWeight.w500, overflow: TextOverflow.ellipsis, fontstyle: FontStyle.normal),
                                                                            ),
                                                                          )
                                                                        : const SizedBox
                                                                            .shrink()
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : Row(
                                                        children: [
                                                          MyImage(
                                                              width: 25,
                                                              height: 25,
                                                              fit: BoxFit.cover,
                                                              color:
                                                                  colorPrimary,
                                                              imagePath:
                                                                  "ic_user.png"),
                                                          const SizedBox(
                                                              width: 8),
                                                          Expanded(
                                                            child: MyText(
                                                                color: white,
                                                                text: "Admin",
                                                                multilanguage:
                                                                    false,
                                                                textalign:
                                                                    TextAlign
                                                                        .left,
                                                                fontsizeNormal:
                                                                    Dimens
                                                                        .textTitle,
                                                                inter: false,
                                                                maxline: 1,
                                                                fontwaight:
                                                                    FontWeight
                                                                        .w600,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontstyle:
                                                                    FontStyle
                                                                        .normal),
                                                          ),
                                                        ],
                                                      ),
                                                /* User Title */
                                                Container(
                                                  width: 250,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 5, 0, 45),
                                                  child: SizedBox(
                                                    height: 20,
                                                    child: MyText(
                                                        text: shortProvider
                                                                .shortVideoList?[
                                                                    index]
                                                                .title
                                                                .toString() ??
                                                            "",
                                                        fontsizeNormal:
                                                            Dimens.textMedium,
                                                        multilanguage: false,
                                                        color: white),
                                                  ),
                                                ),
                                                /* Gif Image Music */
                                                /*Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    MyImage(
                                                        width: 15,
                                                        height: 15,
                                                        imagePath: "music.png",
                                                        color: white),
                                                    const SizedBox(width: 15),
                                                    Expanded(
                                                      child: Align(
                                                        alignment:
                                                            Alignment.centerLeft,
                                                        child: MyText(
                                                            color: white,
                                                            text: "originalsound",
                                                            textalign:
                                                                TextAlign.center,
                                                            fontsizeNormal: 12,
                                                            multilanguage: true,
                                                            inter: false,
                                                            maxline: 1,
                                                            fontwaight:
                                                                FontWeight.w400,
                                                            overflow:
                                                                TextOverflow.ellipsis,
                                                            fontstyle:
                                                                FontStyle.normal),
                                                      ),
                                                    ),
                                                  ],
                                                ),*/
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  /* All Buttons */
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width >
                                            800
                                        ? Dimens.getResponsiveBox(context, 0)
                                        : 400,
                                    height: ((html.window.screen?.height
                                            as double) *
                                        0.64),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Like Button With Like Count
                                          InkWell(
                                            onTap: () async {
                                              if (Constant.userID == null) {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context,
                                                            animation1,
                                                            animation2) =>
                                                        const WebLogin(),
                                                    transitionDuration:
                                                        Duration.zero,
                                                    reverseTransitionDuration:
                                                        Duration.zero,
                                                  ),
                                                );
                                              } else {
                                                if (shortProvider
                                                        .shortVideoList?[index]
                                                        .isLike ==
                                                    0) {
                                                  Utils().showSnackBar(
                                                      context,
                                                      "youcannotlikethiscontent",
                                                      true);
                                                } else {
                                                  //  Call Like APi Call
                                                  if ((shortProvider
                                                              .shortVideoList?[
                                                                  index]
                                                              .isUserLikeDislike ??
                                                          0) ==
                                                      1) {
                                                    printLog("Remove Api");
                                                    await shortProvider.shortLike(
                                                        index,
                                                        "3",
                                                        shortProvider
                                                                .shortVideoList?[
                                                                    index]
                                                                .id
                                                                .toString() ??
                                                            "",
                                                        "0",
                                                        "0");
                                                  } else {
                                                    await shortProvider.shortLike(
                                                        index,
                                                        "3",
                                                        shortProvider
                                                                .shortVideoList?[
                                                                    index]
                                                                .id
                                                                .toString() ??
                                                            "",
                                                        "1",
                                                        "0");
                                                  }
                                                }
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: colorPrimaryDark
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              margin:
                                                  const EdgeInsets.all(10.0),
                                              child: (shortProvider
                                                              .shortVideoList?[
                                                                  index]
                                                              .isUserLikeDislike ??
                                                          0) ==
                                                      1
                                                  ? MyImage(
                                                      width: 26,
                                                      height: 26,
                                                      color: Colors.red,
                                                      imagePath:
                                                          "ic_likefill.png")
                                                  : MyImage(
                                                      width: 26,
                                                      height: 26,
                                                      imagePath: "ic_like.png"),
                                            ),
                                          ),
                                          MyText(
                                              color: white,
                                              text: Utils.kmbGenerator(
                                                  int.parse(shortProvider
                                                          .shortVideoList?[
                                                              index]
                                                          .totalLike
                                                          .toString() ??
                                                      "")),
                                              multilanguage: false,
                                              textalign: TextAlign.center,
                                              fontsizeNormal: Dimens.textSmall,
                                              fontsizeWeb: Dimens.textSmall,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w400,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                          const SizedBox(height: 5),
                                          // Dislike Button With Deslike Count
                                          /*  InkWell(
                                            onTap: () async {
                                              if (Constant.userID == null) {
                                                Navigator.push(
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
                                                if (shortProvider
                                                        .shortVideoList?[index]
                                                        .isLike ==
                                                    0) {
                                                  Utils().showSnackbar(
                                                      context,
                                                      "youcannotlikethiscontent",
                                                      true);
                                                } else {
                                                  //  Call DisLike APi Call
                                                  if ((shortProvider
                                                              .shortVideoList?[index]
                                                              .isUserLikeDislike ??
                                                          2) ==
                                                      0) {
                                                    printLog("Remove Api");
                                                    await shortProvider.shortDislike(
                                                        index,
                                                        "3",
                                                        shortProvider
                                                                .shortVideoList?[
                                                                    index]
                                                                .id
                                                                .toString() ??
                                                            "",
                                                        "0",
                                                        "0");
                                                  } else {
                                                    await shortProvider.shortDislike(
                                                        index,
                                                        "3",
                                                        shortProvider
                                                                .shortVideoList?[
                                                                    index]
                                                                .id
                                                                .toString() ??
                                                            "",
                                                        "2",
                                                        "0");
                                                  }
                                                }
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: colorPrimaryDark
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              padding: const EdgeInsets.all(10.0),
                                              margin: const EdgeInsets.all(10.0),
                                              child: (shortProvider
                                                              .shortVideoList?[index]
                                                              .isUserLikeDislike ??
                                                          0) ==
                                                      2
                                                  ? MyImage(
                                                      width: 26,
                                                      height: 26,
                                                      color: Colors.red,
                                                      imagePath: "ic_dislikefill.png")
                                                  : MyImage(
                                                      width: 26,
                                                      height: 26,
                                                      imagePath: "ic_dislike.png"),
                                            ),
                                          ),
                                          MyText(
                                              color: white,
                                              text: Utils.kmbGenerator(int.parse(
                                                  shortProvider.shortVideoList?[index]
                                                          .totalDislike
                                                          .toString() ??
                                                      "")),
                                              textalign: TextAlign.center,
                                              fontsizeNormal: Dimens.textSmall,
                                              fontsizeWeb: Dimens.textSmall,
                                              multilanguage: false,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                          const SizedBox(height: 5),*/
                                          // Commenet Button Bottom Sheet Open
                                          InkWell(
                                            onTap: () {
                                              shortProvider.storeContentId(
                                                  shortProvider
                                                          .shortVideoList?[
                                                              index]
                                                          .id
                                                          .toString() ??
                                                      "");
                                              // Call Comment bottom Sheet
                                              shortProvider.getComment(
                                                  "3",
                                                  shortProvider
                                                          .shortVideoList?[
                                                              index]
                                                          .id
                                                          .toString() ??
                                                      "",
                                                  1);

                                              commentBottomSheet(
                                                  videoid: shortProvider
                                                          .shortVideoList?[
                                                              index]
                                                          .id
                                                          .toString() ??
                                                      "",
                                                  index: index,
                                                  isShortType: "short");
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: colorPrimaryDark
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              margin:
                                                  const EdgeInsets.all(10.0),
                                              child: MyImage(
                                                  width: 23,
                                                  height: 23,
                                                  color: white,
                                                  imagePath: "ic_comment.png"),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          MyText(
                                              color: white,
                                              text: Utils.kmbGenerator(
                                                  shortProvider
                                                          .shortVideoList?[
                                                              index]
                                                          .totalComment ??
                                                      0),
                                              multilanguage: false,
                                              textalign: TextAlign.center,
                                              fontsizeNormal: Dimens.textSmall,
                                              fontsizeWeb: Dimens.textSmall,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                          const SizedBox(height: 5),
                                          InkWell(
                                            onTap: () {
                                              if (Constant.userID == null) {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context,
                                                            animation1,
                                                            animation2) =>
                                                        const WebLogin(),
                                                    transitionDuration:
                                                        Duration.zero,
                                                    reverseTransitionDuration:
                                                        Duration.zero,
                                                  ),
                                                );
                                              } else {
                                                moreBottomSheet(
                                                  shortProvider
                                                          .shortVideoList?[
                                                              index]
                                                          .portraitImg
                                                          .toString() ??
                                                      "",
                                                  shortProvider
                                                          .shortVideoList?[
                                                              index]
                                                          .title
                                                          .toString() ??
                                                      "",
                                                  shortProvider
                                                          .shortVideoList?[
                                                              index]
                                                          .userId
                                                          .toString() ??
                                                      "",
                                                  shortProvider
                                                          .shortVideoList?[
                                                              index]
                                                          .id
                                                          .toString() ??
                                                      "",
                                                );
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: colorPrimaryDark
                                                    .withOpacity(0.35),
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              margin:
                                                  const EdgeInsets.all(10.0),
                                              child: MyImage(
                                                  width: 20,
                                                  height: 20,
                                                  imagePath: "ic_more.png"),
                                            ),
                                          ),
                                          Constant.userID ==
                                                  (shortProvider
                                                          .shortVideoList?[
                                                              index]
                                                          .userId
                                                          .toString() ??
                                                      '')
                                              ? const SizedBox()
                                              : Utils().circleIconWithButton(
                                                  circleSize: 50,
                                                  iconSize: 48,
                                                  color:
                                                      white.withOpacity(0.20),
                                                  icon: "ic_gift.webp",
                                                  onTap: () {
                                                    if (Constant.userID ==
                                                        null) {
                                                      Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          pageBuilder: (context,
                                                                  animation1,
                                                                  animation2) =>
                                                              const WebLogin(),
                                                          transitionDuration:
                                                              Duration.zero,
                                                          reverseTransitionDuration:
                                                              Duration.zero,
                                                        ),
                                                      );
                                                    } else {
                                                      openGift();
                                                    }
                                                  },
                                                ),
                                          // ClipRRect(
                                          //   borderRadius: BorderRadius.circular(5),
                                          //   child: MyNetworkImage(
                                          //     width: 50,
                                          //     height: 50,
                                          //     imagePath: shortProvider
                                          //             .shortVideoList?[index]
                                          //             .portraitImg
                                          //             .toString() ??
                                          //         "",
                                          //     fit: BoxFit.cover,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ),
                      /* if ((MediaQuery.of(context).size.width > 800) &&
                          (shortProvider.shortVideoList != null &&
                              (shortProvider.shortVideoList?.length ?? 0) > 1))
                        Positioned.fill(
                          top: 20,
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                upDownButton(
                                    type: "up",
                                    onTap: () {
                                      _scrollUp();
                                    }),
                                upDownButton(
                                    type: "down",
                                    onTap: () {
                                      _scrollDown();
                                    }),
                              ],
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink()*/
                    ],
                  ),
                );
              } else {
                return const NoPost(title: "no_posts_available", subTitle: "");
              }
            } else {
              return const NoPost(title: "no_posts_available", subTitle: "");
            }
          }
        }),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            // Combine slide + fade
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, -0.2), // slightly above
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _showTopWidgets
              ? Container(
                  key: const ValueKey('topWidget'), // important for animation
                  decoration: BoxDecoration(
                    color: ResponsiveHelper.checkIsWeb(context)
                        ? transparent
                        : appBarColor,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(22),
                      bottomLeft: Radius.circular(22),
                    ),
                  ),
                  padding: EdgeInsets.only(
                      bottom: 15.0,
                      left: 9,
                      right: 9,
                      top: ResponsiveHelper.checkIsWeb(context) ? 0 : 15),
                  child: shortProvider.isShowSearch
                      ? !ResponsiveHelper.isMobile(context)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 360,
                                  child: buildSearchField(),
                                ),
                              ],
                            )
                          : buildSearchField()
                      : !ResponsiveHelper.isMobile(context)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 360,
                                  child: buildTopWidgets(),
                                ),
                              ],
                            )
                          : buildTopWidgets(),
                )
              : const SizedBox(
                  key:
                      ValueKey('emptyWidget'), // keeps AnimatedSwitcher working
                ),
        ),
      ],
    );
  }

  void openGift() {
    _fetchGift(0);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(25),
          topStart: Radius.circular(25),
        ),
      ),
      builder: (context) => Container(
        height: 550,
        width: MediaQuery.of(context).size.width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorPrimaryDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 65,
              decoration: BoxDecoration(gradient: Constant.gradientColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  Consumer<ProfileProvider>(
                      builder: (context, settingProvider, child) {
                    return Container(
                      height: 34,
                      padding: const EdgeInsets.only(left: 5, right: 10),
                      decoration: BoxDecoration(
                        color: white,
                        border: Border.all(color: black.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyImage(
                              width: 22, height: 22, imagePath: "ic_coin.png"),
                          const SizedBox(width: 5),
                          MyText(
                              color: black,
                              multilanguage: false,
                              text: Utils.kmbGenerator(settingProvider
                                      .profileModel.result?[0].walletBalance ??
                                  0),
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textSmall,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      ),
                    );
                  }),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 4,
                          width: 35,
                          decoration: BoxDecoration(
                            color: black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 15),
                        MyText(
                            color: pureBlack,
                            multilanguage: true,
                            text: "gifttitle",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textTitle,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!mounted) return;
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: transparent,
                        border: Border.all(color: pureBlack),
                      ),
                      child: Center(
                          child: MyImage(
                              width: 15,
                              color: pureBlack,
                              height: 15,
                              imagePath: "ic_close.png")),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Consumer<LiveStreamProvider>(
                builder: (context, livestreamprovider, child) {
              if (livestreamprovider.giftloading) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (livestreamprovider.fetchGiftModel.result != null &&
                    livestreamprovider.giftList != null &&
                    (livestreamprovider.giftList?.length ?? 0) > 0) {
                  return Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      scrollDirection: Axis.vertical,
                      controller: _giftScrollController,
                      child: Column(
                        children: [
                          ResponsiveGridList(
                            minItemWidth: 120,
                            minItemsPerRow: 3,
                            maxItemsPerRow: 3,
                            horizontalGridSpacing: 12,
                            verticalGridSpacing: 10,
                            listViewBuilderOptions: ListViewBuilderOptions(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                            ),
                            children: List.generate(
                                livestreamprovider.giftList?.length ?? 0,
                                (index) {
                              return Container(
                                decoration: BoxDecoration(
                                  // color: colorPrimary,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: colorPrimary),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: MyNetworkImage(
                                          width: 45,
                                          height: 45,
                                          imagePath: livestreamprovider
                                                  .giftList?[index].image
                                                  .toString() ??
                                              "",
                                          fit: BoxFit.cover),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: gray.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: MyText(
                                          color: white,
                                          multilanguage: false,
                                          text:
                                              "${livestreamprovider.giftList?[index].price.toString() ?? ""} Coins",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: Dimens.textSmall,
                                          inter: false,
                                          maxline: 1,
                                          fontwaight: FontWeight.w700,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        SuccessModel success =
                                            await ApiService().sendGift(
                                                shortProvider
                                                    .shortVideoList?[index]
                                                    .userId,
                                                livestreamprovider
                                                    .giftList?[index].id);
                                        Navigator.pop(context);
                                        Utils().showSnackBar(context,
                                            success.message ?? '', false);
                                      },
                                      child: Container(
                                        height: 35,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: Constant.gradientColor,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  bottom: Radius.circular(15)),
                                        ),
                                        child: MyText(
                                            color: pureBlack,
                                            multilanguage: true,
                                            text: "send",
                                            textalign: TextAlign.center,
                                            fontsizeNormal: Dimens.textDesc,
                                            inter: false,
                                            maxline: 1,
                                            fontwaight: FontWeight.w600,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                          if (livestreamprovider.giftloadMore)
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
            }),
            const SizedBox(height: 10),
            /* Recharge Button */
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const AdsPackage();
                          },
                        ),
                      );
                    },
                    child: Container(
                      height: 45,
                      width: 130,
                      decoration: BoxDecoration(
                        gradient: Constant.gradientColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 5),
                            MyImage(
                                width: 22,
                                height: 22,
                                imagePath: "ic_coin.png"),
                            const SizedBox(width: 5),
                            MyText(
                                color: pureBlack,
                                multilanguage: true,
                                text: "addcoins",
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  /* Profile Short */

  Widget _buildProfileShortPageView() {
    return Consumer<ShortProvider>(
        builder: (context, profileShortprovider, child) {
      if (profileShortprovider.loading) {
        return shimmer();
      } else {
        if (profileShortprovider.getContentbyChannelModel.status == 200) {
          if (profileShortprovider.profileShortList != null &&
              (profileShortprovider.profileShortList?.length ?? 0) > 0) {
            return Stack(
              children: [
                CarouselSlider.builder(
                    itemCount:
                        profileShortprovider.profileShortList?.length ?? 0,
                    carouselController: _profileController,
                    options: CarouselOptions(
                      initialPage: 0,
                      scrollPhysics: const AlwaysScrollableScrollPhysics(),
                      onPageChanged: (index, reason) async {
                        if (index > 0 && (index % 2) == 0) {
                          _fetchUserShort();
                        }
                        printLog("onPageChanged value ======> $index");
                      },
                      scrollDirection: Axis.vertical,
                      height: ((html.window.screen?.height as double) * 0.80),
                      enlargeCenterPage: false,
                      enlargeFactor: 0.18,
                      autoPlay: false,
                      autoPlayCurve: Curves.easeInOutQuart,
                      enableInfiniteScroll: false,
                      viewportFraction: 1.0,
                    ),
                    itemBuilder:
                        (BuildContext context, int index, int pageViewIndex) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                            width: MediaQuery.of(context).size.width > 600
                                ? Dimens.getResponsiveBox(context, 0)
                                : MediaQuery.of(context).size.width * 0.80,
                            height:
                                ((html.window.screen?.height as double) * 0.70),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: ReelsPlayer(
                                    isLiveStream: false,
                                    index: index,
                                    pagePos: index,
                                    thumbnailImg: profileShortprovider
                                            .profileShortList?[index]
                                            .portraitImg
                                            .toString() ??
                                        "",
                                    videoUrl: profileShortprovider
                                            .profileShortList?[index].content
                                            .toString() ??
                                        "",
                                  ),
                                ),
                                /* Channel Name, Reels Title */
                                Positioned.fill(
                                  left: 5,
                                  right: 5,
                                  bottom: 5,
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /* Uploded Reels User Image */
                                        profileShortprovider
                                                    .profileShortList?[index]
                                                    .userId !=
                                                0
                                            ? InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (context,
                                                              animation1,
                                                              animation2) =>
                                                          WebProfile(
                                                        isProfile: false,
                                                        channelUserid:
                                                            profileShortprovider
                                                                    .profileShortList?[
                                                                        index]
                                                                    .userId
                                                                    .toString() ??
                                                                "",
                                                        channelid:
                                                            profileShortprovider
                                                                    .profileShortList?[
                                                                        index]
                                                                    .channelId
                                                                    .toString() ??
                                                                "",
                                                      ),
                                                      transitionDuration:
                                                          Duration.zero,
                                                      reverseTransitionDuration:
                                                          Duration.zero,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: 250,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 5, 0, 5),
                                                  child: Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        child: MyNetworkImage(
                                                            width: 25,
                                                            height: 25,
                                                            fit: BoxFit.cover,
                                                            imagePath: profileShortprovider
                                                                    .profileShortList?[
                                                                        index]
                                                                    .channelImage
                                                                    .toString() ??
                                                                ""),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              child: profileShortprovider
                                                                          .profileShortList?[
                                                                              index]
                                                                          .channelName
                                                                          .toString() ==
                                                                      ""
                                                                  ? MyText(
                                                                      color:
                                                                          white,
                                                                      text:
                                                                          "guestuser",
                                                                      multilanguage:
                                                                          true,
                                                                      textalign:
                                                                          TextAlign
                                                                              .left,
                                                                      fontsizeNormal:
                                                                          Dimens
                                                                              .textTitle,
                                                                      inter:
                                                                          false,
                                                                      maxline:
                                                                          1,
                                                                      fontwaight:
                                                                          FontWeight
                                                                              .w600,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal)
                                                                  : MyText(
                                                                      color:
                                                                          white,
                                                                      text: profileShortprovider
                                                                              .profileShortList?[
                                                                                  index]
                                                                              .channelName
                                                                              .toString() ??
                                                                          "",
                                                                      multilanguage:
                                                                          false,
                                                                      textalign:
                                                                          TextAlign
                                                                              .left,
                                                                      fontsizeNormal:
                                                                          Dimens
                                                                              .textTitle,
                                                                      inter:
                                                                          false,
                                                                      maxline:
                                                                          1,
                                                                      fontwaight:
                                                                          FontWeight
                                                                              .w600,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            /* User Subscribe Button */
                                                            Constant.userID !=
                                                                    profileShortprovider
                                                                        .profileShortList?[
                                                                            index]
                                                                        .userId
                                                                        .toString()
                                                                ? InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      if (Constant
                                                                              .userID ==
                                                                          null) {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          PageRouteBuilder(
                                                                            pageBuilder: (context, animation1, animation2) =>
                                                                                const WebLogin(),
                                                                            transitionDuration:
                                                                                Duration.zero,
                                                                            reverseTransitionDuration:
                                                                                Duration.zero,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        await shortProvider.addremoveSubscribe(
                                                                            index,
                                                                            profileShortprovider.profileShortList?[index].userId.toString() ??
                                                                                "",
                                                                            "1",
                                                                            widget.shortType);
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          5,
                                                                          5,
                                                                          5,
                                                                          5),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              5),
                                                                          color: profileShortprovider.profileShortList?[index].isSubscribe == 0
                                                                              ? colorPrimary
                                                                              : transparent,
                                                                          border: Border.all(
                                                                              width: 1,
                                                                              color: colorPrimary)),
                                                                      child: MyText(
                                                                          color:
                                                                              white,
                                                                          text: profileShortprovider.profileShortList?[index].isSubscribe == 0
                                                                              ? "subscribe"
                                                                              : "subscribed",
                                                                          multilanguage:
                                                                              true,
                                                                          textalign: TextAlign
                                                                              .center,
                                                                          fontsizeNormal: Dimens
                                                                              .textSmall,
                                                                          inter:
                                                                              false,
                                                                          maxline:
                                                                              1,
                                                                          fontwaight: FontWeight
                                                                              .w600,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          fontstyle:
                                                                              FontStyle.normal),
                                                                    ),
                                                                  )
                                                                : const SizedBox
                                                                    .shrink()
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Row(
                                                children: [
                                                  MyImage(
                                                      width: 25,
                                                      height: 25,
                                                      fit: BoxFit.cover,
                                                      color: colorPrimary,
                                                      imagePath: "ic_user.png"),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: MyText(
                                                        color: white,
                                                        text: "Admin",
                                                        multilanguage: false,
                                                        textalign:
                                                            TextAlign.left,
                                                        fontsizeNormal:
                                                            Dimens.textTitle,
                                                        inter: false,
                                                        maxline: 1,
                                                        fontwaight:
                                                            FontWeight.w600,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontstyle:
                                                            FontStyle.normal),
                                                  ),
                                                ],
                                              ),
                                        /* User Title */
                                        Container(
                                          width: 250,
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 5, 0, 10),
                                          child: SizedBox(
                                            height: 20,
                                            child: MyMarqueeText(
                                                text: profileShortprovider
                                                        .profileShortList?[
                                                            index]
                                                        .title
                                                        .toString() ??
                                                    "",
                                                fontsize: Dimens.textMedium,
                                                color: white),
                                          ),
                                        ),
                                        /* Gif Image Music */
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            MyImage(
                                                width: 15,
                                                height: 15,
                                                imagePath: "music.png",
                                                color: white),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: MyText(
                                                    color: white,
                                                    text: "originalsound",
                                                    textalign: TextAlign.center,
                                                    fontsizeNormal: 12,
                                                    multilanguage: true,
                                                    inter: false,
                                                    maxline: 1,
                                                    fontwaight: FontWeight.w400,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontstyle:
                                                        FontStyle.normal),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          /* All Buttons */
                          SizedBox(
                            width: MediaQuery.of(context).size.width > 800
                                ? Dimens.getResponsiveBox(context, 0)
                                : 400,
                            height:
                                ((html.window.screen?.height as double) * 0.70),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Like Button With Like Count
                                  InkWell(
                                    onTap: () async {
                                      if (Constant.userID == null) {
                                        Navigator.push(
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
                                        if (shortProvider
                                                .profileShortList?[index]
                                                .isLike ==
                                            0) {
                                          Utils().showSnackBar(context,
                                              "youcannotlikethiscontent", true);
                                        } else {
                                          //  Call Like APi Call
                                          if ((shortProvider
                                                      .profileShortList?[index]
                                                      .isUserLikeDislike ??
                                                  0) ==
                                              1) {
                                            printLog("Remove Api");
                                            await shortProvider
                                                .profileShortLike(
                                                    index,
                                                    "3",
                                                    shortProvider
                                                            .profileShortList?[
                                                                index]
                                                            .id
                                                            .toString() ??
                                                        "",
                                                    "0",
                                                    "0");
                                          } else {
                                            await shortProvider
                                                .profileShortLike(
                                                    index,
                                                    "3",
                                                    shortProvider
                                                            .profileShortList?[
                                                                index]
                                                            .id
                                                            .toString() ??
                                                        "",
                                                    "1",
                                                    "0");
                                          }
                                        }
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            colorPrimaryDark.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: const EdgeInsets.all(12.0),
                                      margin: const EdgeInsets.all(10.0),
                                      child: (profileShortprovider
                                                      .profileShortList?[index]
                                                      .isUserLikeDislike ??
                                                  0) ==
                                              1
                                          ? MyImage(
                                              width: 30,
                                              height: 30,
                                              color: colorPrimary,
                                              imagePath: "ic_likefill.png")
                                          : MyImage(
                                              width: 30,
                                              height: 30,
                                              imagePath: "ic_like.png"),
                                    ),
                                  ),
                                  MyText(
                                      color: white,
                                      text: Utils.kmbGenerator(int.parse(
                                          profileShortprovider
                                                  .profileShortList?[index]
                                                  .totalLike
                                                  .toString() ??
                                              "")),
                                      multilanguage: false,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      fontsizeWeb: Dimens.textSmall,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(height: 5),
                                  // Dislike Button With Deslike Count
                                  InkWell(
                                    onTap: () async {
                                      if (Constant.userID == null) {
                                        Navigator.push(
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
                                        if (shortProvider
                                                .profileShortList?[index]
                                                .isLike ==
                                            0) {
                                          Utils().showSnackBar(context,
                                              "youcannotlikethiscontent", true);
                                        } else {
                                          //  Call DisLike APi Call
                                          if ((shortProvider
                                                      .profileShortList?[index]
                                                      .isUserLikeDislike ??
                                                  2) ==
                                              0) {
                                            printLog("Remove Api");
                                            await shortProvider
                                                .profileShortDislike(
                                                    index,
                                                    "3",
                                                    shortProvider
                                                            .profileShortList?[
                                                                index]
                                                            .id
                                                            .toString() ??
                                                        "",
                                                    "0",
                                                    "0");
                                          } else {
                                            await shortProvider
                                                .profileShortDislike(
                                                    index,
                                                    "3",
                                                    shortProvider
                                                            .profileShortList?[
                                                                index]
                                                            .id
                                                            .toString() ??
                                                        "",
                                                    "2",
                                                    "0");
                                          }
                                        }
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            colorPrimaryDark.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: const EdgeInsets.all(12.0),
                                      margin: const EdgeInsets.all(10.0),
                                      child: (profileShortprovider
                                                      .profileShortList?[index]
                                                      .isUserLikeDislike ??
                                                  0) ==
                                              2
                                          ? MyImage(
                                              width: 30,
                                              height: 30,
                                              imagePath: "ic_dislikefill.png")
                                          : MyImage(
                                              width: 30,
                                              height: 30,
                                              imagePath: "ic_dislike.png"),
                                    ),
                                  ),
                                  MyText(
                                      color: white,
                                      text: Utils.kmbGenerator(int.parse(
                                          profileShortprovider
                                                  .profileShortList?[index]
                                                  .totalDislike
                                                  .toString() ??
                                              "")),
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      fontsizeWeb: Dimens.textSmall,
                                      multilanguage: false,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(height: 5),
                                  // Commenet Button Bottom Sheet Open
                                  InkWell(
                                    onTap: () {
                                      shortProvider.storeContentId(shortProvider
                                              .profileShortList?[index].id
                                              .toString() ??
                                          "");
                                      // Call Comment bottom Sheet
                                      shortProvider.getComment(
                                          "3",
                                          shortProvider
                                                  .profileShortList?[index].id
                                                  .toString() ??
                                              "",
                                          1);

                                      commentBottomSheet(
                                          videoid: shortProvider
                                                  .profileShortList?[index].id
                                                  .toString() ??
                                              "",
                                          index: index,
                                          isShortType: "profile");
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            colorPrimaryDark.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: const EdgeInsets.all(12.0),
                                      margin: const EdgeInsets.all(10.0),
                                      child: MyImage(
                                          width: 25,
                                          height: 25,
                                          imagePath: "ic_comment.png"),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  MyText(
                                      color: white,
                                      text: Utils.kmbGenerator(
                                          profileShortprovider
                                                  .profileShortList?[index]
                                                  .totalComment ??
                                              0),
                                      multilanguage: false,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      fontsizeWeb: Dimens.textSmall,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(height: 5),
                                  InkWell(
                                    onTap: () {
                                      if (Constant.userID == null) {
                                        Navigator.push(
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
                                        moreBottomSheet(
                                          shortProvider.profileShortList?[index]
                                                  .portraitImg
                                                  .toString() ??
                                              "",
                                          shortProvider.profileShortList?[index]
                                                  .title
                                                  .toString() ??
                                              "",
                                          shortProvider.profileShortList?[index]
                                                  .userId
                                                  .toString() ??
                                              "",
                                          shortProvider
                                                  .profileShortList?[index].id
                                                  .toString() ??
                                              "",
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            colorPrimaryDark.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: const EdgeInsets.all(12.0),
                                      margin: const EdgeInsets.all(10.0),
                                      child: MyImage(
                                          width: 20,
                                          height: 20,
                                          imagePath: "ic_more.png"),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: MyNetworkImage(
                                      width: 50,
                                      height: 50,
                                      imagePath: profileShortprovider
                                              .profileShortList?[index]
                                              .portraitImg
                                              .toString() ??
                                          "",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                if ((MediaQuery.of(context).size.width > 800) &&
                    (profileShortprovider.profileShortList != null &&
                        (profileShortprovider.profileShortList?.length ?? 0) >
                            1))
                  Positioned.fill(
                    top: 20,
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          upDownButton(
                              type: "up",
                              onTap: () {
                                _scrollUp();
                              }),
                          upDownButton(
                              type: "down",
                              onTap: () {
                                _scrollDown();
                              }),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink()
              ],
            );
          } else {
            return const NoPost(title: "no_posts_available", subTitle: "");
          }
        } else {
          return const NoPost(title: "no_posts_available", subTitle: "");
        }
      }
    });
  }

/* WatchLater Short */

  Widget _buildWatchLaterShortPageView() {
    return Consumer<ShortProvider>(
        builder: (context, watchlaterShortprovider, child) {
      if (watchlaterShortprovider.loading) {
        return shimmer();
      } else {
        if (watchlaterShortprovider.watchlaterModel.status == 200) {
          if (watchlaterShortprovider.watchlaterShortList != null &&
              (watchlaterShortprovider.watchlaterShortList?.length ?? 0) > 0) {
            return Stack(
              children: [
                CarouselSlider.builder(
                    itemCount:
                        watchlaterShortprovider.watchlaterShortList?.length ??
                            0,
                    carouselController: _profileController,
                    options: CarouselOptions(
                      initialPage: 0,
                      scrollPhysics: const AlwaysScrollableScrollPhysics(),
                      onPageChanged: (index, reason) async {
                        if (index > 0 && (index % 2) == 0) {
                          _fetchWatchLaterShort();
                        }
                      },
                      scrollDirection: Axis.vertical,
                      height: ((html.window.screen?.height as double) * 0.80),
                      enlargeCenterPage: false,
                      enlargeFactor: 0.18,
                      autoPlay: false,
                      autoPlayCurve: Curves.easeInOutQuart,
                      enableInfiniteScroll: false,
                      viewportFraction: 1.0,
                    ),
                    itemBuilder:
                        (BuildContext context, int index, int pageViewIndex) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                            width: MediaQuery.of(context).size.width > 600
                                ? Dimens.getResponsiveBox(context, 0)
                                : MediaQuery.of(context).size.width * 0.80,
                            height:
                                ((html.window.screen?.height as double) * 0.70),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: ReelsPlayer(
                                    isLiveStream: false,
                                    index: index,
                                    pagePos: index,
                                    thumbnailImg: watchlaterShortprovider
                                            .watchlaterShortList?[index]
                                            .portraitImg
                                            .toString() ??
                                        "",
                                    videoUrl: watchlaterShortprovider
                                            .watchlaterShortList?[index].content
                                            .toString() ??
                                        "",
                                  ),
                                ),
                                /* Channel Name, Reels Title */
                                Positioned.fill(
                                  left: 5,
                                  right: 5,
                                  bottom: 5,
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /* Uploded Reels User Image */
                                        watchlaterShortprovider
                                                    .watchlaterShortList?[index]
                                                    .userId !=
                                                0
                                            ? InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (context,
                                                              animation1,
                                                              animation2) =>
                                                          WebProfile(
                                                        isProfile: false,
                                                        channelUserid:
                                                            watchlaterShortprovider
                                                                    .watchlaterShortList?[
                                                                        index]
                                                                    .userId
                                                                    .toString() ??
                                                                "",
                                                        channelid:
                                                            watchlaterShortprovider
                                                                    .watchlaterShortList?[
                                                                        index]
                                                                    .channelId
                                                                    .toString() ??
                                                                "",
                                                      ),
                                                      transitionDuration:
                                                          Duration.zero,
                                                      reverseTransitionDuration:
                                                          Duration.zero,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: 250,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 5, 0, 5),
                                                  child: Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        child: MyNetworkImage(
                                                            width: 25,
                                                            height: 25,
                                                            fit: BoxFit.cover,
                                                            imagePath: watchlaterShortprovider
                                                                    .watchlaterShortList?[
                                                                        index]
                                                                    .channelImage
                                                                    .toString() ??
                                                                ""),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              child: watchlaterShortprovider
                                                                          .watchlaterShortList?[
                                                                              index]
                                                                          .channelName
                                                                          .toString() ==
                                                                      ""
                                                                  ? MyText(
                                                                      color:
                                                                          white,
                                                                      text:
                                                                          "guestuser",
                                                                      multilanguage:
                                                                          true,
                                                                      textalign:
                                                                          TextAlign
                                                                              .left,
                                                                      fontsizeNormal:
                                                                          Dimens
                                                                              .textTitle,
                                                                      inter:
                                                                          false,
                                                                      maxline:
                                                                          1,
                                                                      fontwaight:
                                                                          FontWeight
                                                                              .w600,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal)
                                                                  : MyText(
                                                                      color:
                                                                          white,
                                                                      text: watchlaterShortprovider
                                                                              .watchlaterShortList?[
                                                                                  index]
                                                                              .channelName
                                                                              .toString() ??
                                                                          "",
                                                                      multilanguage:
                                                                          false,
                                                                      textalign:
                                                                          TextAlign
                                                                              .left,
                                                                      fontsizeNormal:
                                                                          Dimens
                                                                              .textTitle,
                                                                      inter:
                                                                          false,
                                                                      maxline:
                                                                          1,
                                                                      fontwaight:
                                                                          FontWeight
                                                                              .w600,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            /* User Subscribe Button */
                                                            Constant.userID !=
                                                                    watchlaterShortprovider
                                                                        .watchlaterShortList?[
                                                                            index]
                                                                        .userId
                                                                        .toString()
                                                                ? InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      if (Constant
                                                                              .userID ==
                                                                          null) {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          PageRouteBuilder(
                                                                            pageBuilder: (context, animation1, animation2) =>
                                                                                const WebLogin(),
                                                                            transitionDuration:
                                                                                Duration.zero,
                                                                            reverseTransitionDuration:
                                                                                Duration.zero,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        await shortProvider.addremoveSubscribe(
                                                                            index,
                                                                            shortProvider.watchlaterShortList?[index].userId.toString() ??
                                                                                "",
                                                                            "1",
                                                                            widget.shortType);
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          5,
                                                                          5,
                                                                          5,
                                                                          5),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              5),
                                                                          color: watchlaterShortprovider.watchlaterShortList?[index].isSubscribe == 0
                                                                              ? colorPrimary
                                                                              : transparent,
                                                                          border: Border.all(
                                                                              width: 1,
                                                                              color: colorPrimary)),
                                                                      child: MyText(
                                                                          color:
                                                                              white,
                                                                          text: watchlaterShortprovider.watchlaterShortList?[index].isSubscribe == 0
                                                                              ? "subscribe"
                                                                              : "subscribed",
                                                                          multilanguage:
                                                                              true,
                                                                          textalign: TextAlign
                                                                              .center,
                                                                          fontsizeNormal: Dimens
                                                                              .textSmall,
                                                                          inter:
                                                                              false,
                                                                          maxline:
                                                                              1,
                                                                          fontwaight: FontWeight
                                                                              .w600,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          fontstyle:
                                                                              FontStyle.normal),
                                                                    ),
                                                                  )
                                                                : const SizedBox
                                                                    .shrink()
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Row(
                                                children: [
                                                  MyImage(
                                                      width: 25,
                                                      height: 25,
                                                      fit: BoxFit.cover,
                                                      color: colorPrimary,
                                                      imagePath: "ic_user.png"),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: MyText(
                                                        color: white,
                                                        text: "Admin",
                                                        multilanguage: false,
                                                        textalign:
                                                            TextAlign.left,
                                                        fontsizeNormal:
                                                            Dimens.textTitle,
                                                        inter: false,
                                                        maxline: 1,
                                                        fontwaight:
                                                            FontWeight.w600,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontstyle:
                                                            FontStyle.normal),
                                                  ),
                                                ],
                                              ),
                                        /* User Title */
                                        Container(
                                          width: 250,
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 5, 0, 10),
                                          child: SizedBox(
                                            height: 20,
                                            child: MyMarqueeText(
                                                text: watchlaterShortprovider
                                                        .watchlaterShortList?[
                                                            index]
                                                        .title
                                                        .toString() ??
                                                    "",
                                                fontsize: Dimens.textMedium,
                                                color: white),
                                          ),
                                        ),
                                        /* Gif Image Music */
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            MyImage(
                                                width: 15,
                                                height: 15,
                                                imagePath: "music.png",
                                                color: white),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: MyText(
                                                    color: white,
                                                    text: "originalsound",
                                                    textalign: TextAlign.center,
                                                    fontsizeNormal: 12,
                                                    multilanguage: true,
                                                    inter: false,
                                                    maxline: 1,
                                                    fontwaight: FontWeight.w400,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontstyle:
                                                        FontStyle.normal),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          /* All Buttons */
                          SizedBox(
                            width: MediaQuery.of(context).size.width > 800
                                ? Dimens.getResponsiveBox(context, 0)
                                : 400,
                            height:
                                ((html.window.screen?.height as double) * 0.70),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Like Button With Like Count
                                  InkWell(
                                    onTap: () async {
                                      if (Constant.userID == null) {
                                        Navigator.push(
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
                                        if (shortProvider
                                                .watchlaterShortList?[index]
                                                .isLike ==
                                            0) {
                                          Utils().showSnackBar(context,
                                              "youcannotlikethiscontent", true);
                                        } else {
                                          //  Call Like APi Call
                                          if ((shortProvider
                                                      .watchlaterShortList?[
                                                          index]
                                                      .isUserLikeDislike ??
                                                  0) ==
                                              1) {
                                            printLog("Remove Api");
                                            await shortProvider
                                                .watchLaterShortLike(
                                                    index,
                                                    "3",
                                                    shortProvider
                                                            .watchlaterShortList?[
                                                                index]
                                                            .id
                                                            .toString() ??
                                                        "",
                                                    "0",
                                                    "0");
                                          } else {
                                            await shortProvider
                                                .watchLaterShortLike(
                                                    index,
                                                    "3",
                                                    shortProvider
                                                            .watchlaterShortList?[
                                                                index]
                                                            .id
                                                            .toString() ??
                                                        "",
                                                    "1",
                                                    "0");
                                          }
                                        }
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            colorPrimaryDark.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: const EdgeInsets.all(12.0),
                                      margin: const EdgeInsets.all(10.0),
                                      child: (watchlaterShortprovider
                                                      .watchlaterShortList?[
                                                          index]
                                                      .isUserLikeDislike ??
                                                  0) ==
                                              1
                                          ? MyImage(
                                              width: 30,
                                              height: 30,
                                              color: colorPrimary,
                                              imagePath: "ic_likefill.png")
                                          : MyImage(
                                              width: 30,
                                              height: 30,
                                              imagePath: "ic_like.png"),
                                    ),
                                  ),
                                  MyText(
                                      color: white,
                                      text: Utils.kmbGenerator(int.parse(
                                          watchlaterShortprovider
                                                  .watchlaterShortList?[index]
                                                  .totalLike
                                                  .toString() ??
                                              "")),
                                      multilanguage: false,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      fontsizeWeb: Dimens.textSmall,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(height: 5),
                                  // Dislike Button With Deslike Count
                                  InkWell(
                                    onTap: () async {
                                      if (Constant.userID == null) {
                                        Navigator.push(
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
                                        if (shortProvider
                                                .watchlaterShortList?[index]
                                                .isLike ==
                                            0) {
                                          Utils().showSnackBar(context,
                                              "youcannotlikethiscontent", true);
                                        } else {
                                          //  Call DisLike APi Call
                                          if ((shortProvider
                                                      .watchlaterShortList?[
                                                          index]
                                                      .isUserLikeDislike ??
                                                  2) ==
                                              0) {
                                            printLog("Remove Api");
                                            await shortProvider
                                                .watchLaterShortDislike(
                                                    index,
                                                    "3",
                                                    shortProvider
                                                            .watchlaterShortList?[
                                                                index]
                                                            .id
                                                            .toString() ??
                                                        "",
                                                    "0",
                                                    "0");
                                          } else {
                                            await shortProvider
                                                .watchLaterShortDislike(
                                                    index,
                                                    "3",
                                                    shortProvider
                                                            .watchlaterShortList?[
                                                                index]
                                                            .id
                                                            .toString() ??
                                                        "",
                                                    "2",
                                                    "0");
                                          }
                                        }
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            colorPrimaryDark.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: const EdgeInsets.all(12.0),
                                      margin: const EdgeInsets.all(10.0),
                                      child: (watchlaterShortprovider
                                                      .watchlaterShortList?[
                                                          index]
                                                      .isUserLikeDislike ??
                                                  0) ==
                                              2
                                          ? MyImage(
                                              width: 30,
                                              height: 30,
                                              imagePath: "ic_dislikefill.png")
                                          : MyImage(
                                              width: 30,
                                              height: 30,
                                              imagePath: "ic_dislike.png"),
                                    ),
                                  ),
                                  MyText(
                                      color: white,
                                      text: Utils.kmbGenerator(int.parse(
                                          watchlaterShortprovider
                                                  .watchlaterShortList?[index]
                                                  .totalDislike
                                                  .toString() ??
                                              "")),
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      fontsizeWeb: Dimens.textSmall,
                                      multilanguage: false,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(height: 5),
                                  // Commenet Button Bottom Sheet Open
                                  InkWell(
                                    onTap: () {
                                      shortProvider.storeContentId(shortProvider
                                              .watchlaterShortList?[index].id
                                              .toString() ??
                                          "");
                                      // Call Comment bottom Sheet
                                      shortProvider.getComment(
                                          "3",
                                          shortProvider
                                                  .watchlaterShortList?[index]
                                                  .id
                                                  .toString() ??
                                              "",
                                          1);

                                      commentBottomSheet(
                                          videoid: shortProvider
                                                  .watchlaterShortList?[index]
                                                  .id
                                                  .toString() ??
                                              "",
                                          index: index,
                                          isShortType: "watchlater");
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            colorPrimaryDark.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: const EdgeInsets.all(12.0),
                                      margin: const EdgeInsets.all(10.0),
                                      child: MyImage(
                                          width: 25,
                                          height: 25,
                                          imagePath: "ic_comment.png"),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  MyText(
                                      color: white,
                                      text: Utils.kmbGenerator(
                                          watchlaterShortprovider
                                                  .watchlaterShortList?[index]
                                                  .totalComment ??
                                              0),
                                      multilanguage: false,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      fontsizeWeb: Dimens.textSmall,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(height: 5),
                                  InkWell(
                                    onTap: () {
                                      if (Constant.userID == null) {
                                        Navigator.push(
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
                                        moreBottomSheet(
                                          shortProvider
                                                  .watchlaterShortList?[index]
                                                  .portraitImg
                                                  .toString() ??
                                              "",
                                          shortProvider
                                                  .watchlaterShortList?[index]
                                                  .title
                                                  .toString() ??
                                              "",
                                          shortProvider
                                                  .watchlaterShortList?[index]
                                                  .userId
                                                  .toString() ??
                                              "",
                                          shortProvider
                                                  .watchlaterShortList?[index]
                                                  .id
                                                  .toString() ??
                                              "",
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            colorPrimaryDark.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: const EdgeInsets.all(12.0),
                                      margin: const EdgeInsets.all(10.0),
                                      child: MyImage(
                                          width: 20,
                                          height: 20,
                                          imagePath: "ic_more.png"),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: MyNetworkImage(
                                      width: 50,
                                      height: 50,
                                      imagePath: watchlaterShortprovider
                                              .watchlaterShortList?[index]
                                              .portraitImg
                                              .toString() ??
                                          "",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                if ((MediaQuery.of(context).size.width > 800) &&
                    (watchlaterShortprovider.watchlaterShortList != null &&
                        (watchlaterShortprovider.watchlaterShortList?.length ??
                                0) >
                            1))
                  Positioned.fill(
                    top: 20,
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          upDownButton(
                              type: "up",
                              onTap: () {
                                _scrollUp();
                              }),
                          upDownButton(
                              type: "down",
                              onTap: () {
                                _scrollDown();
                              }),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink()
              ],
            );
          } else {
            return const NoPost(title: "no_posts_available", subTitle: "");
          }
        } else {
          return const NoPost(title: "no_posts_available", subTitle: "");
        }
      }
    });
  }

  Widget shimmer() {
    return Stack(
      children: [
        PageView.builder(
          itemCount: shortProvider.shortVideoList?.length ?? 0,
          scrollDirection: Axis.vertical,
          allowImplicitScrolling: true,
          itemBuilder: (context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /* Reels Video */
                CustomWidget.webImageRound(
                  width: 370,
                  height: MediaQuery.of(context).size.width,
                ),
                const SizedBox(width: 15),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Like Button With Like Count
                      CustomWidget.circular(
                        height: 40,
                        width: 40,
                      ),
                      CustomWidget.roundrectborder(
                        height: 5,
                        width: 35,
                      ),
                      SizedBox(height: 5),
                      // Dislike Button With Deslike Count
                      CustomWidget.circular(
                        height: 40,
                        width: 40,
                      ),
                      CustomWidget.roundrectborder(
                        height: 5,
                        width: 35,
                      ),
                      SizedBox(height: 5),
                      // Commenet Button Bottom Sheet Open
                      CustomWidget.circular(
                        height: 40,
                        width: 40,
                      ),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(
                        height: 5,
                        width: 35,
                      ),
                      SizedBox(height: 5),
                      CustomWidget.circular(
                        height: 40,
                        width: 40,
                      ),
                      SizedBox(height: 20),
                      CustomWidget.roundrectborder(
                        height: 50,
                        width: 50,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          /* Reels Pagination Content */
          onPageChanged: (index) async {
            await shortProvider.changePageViewIndex(index);
            if (index > 0 && (index % 2) == 0) {
              _fetchAllShort();
            }
          },
        ),
      ],
    );
  }

/* Comment Bottom Sheet */
  commentBottomSheet(
      {required int index, required videoid, required isShortType}) {
    showDialog<void>(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return Wrap(
          children: [
            buildComment(index, videoid, isShortType),
          ],
        );
      },
    ).whenComplete(() {
      commentController.clear();
      shortProvider.clearComment();
    });
  }

/* Build Comment List */
  Widget buildComment(index, dynamic videoid, isShortType) {
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: MyText(
                        color: white,
                        multilanguage: true,
                        text: "comments",
                        fontsizeNormal: Dimens.textDesc,
                        fontsizeWeb: Dimens.textDesc,
                        fontstyle: FontStyle.normal,
                        fontwaight: FontWeight.w600,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.start,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        Navigator.pop(context);
                        commentController.clear();
                        shortProvider.clearComment();
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
            Utils.buildGradLine(),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: commentListController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Consumer<ShortProvider>(
                        builder: (context, commentprovider, child) {
                      if (shortProvider.commentloading &&
                          !shortProvider.commentLoadmore) {
                        return Align(
                          alignment: Alignment.center,
                          child: Utils.pageLoader(context),
                        );
                      } else {
                        if (shortProvider.getcommentModel.status == 200 &&
                            shortProvider.commentList != null) {
                          if ((shortProvider.commentList?.length ?? 0) > 0) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          commentprovider.commentList?.length ??
                                              0,
                                      itemBuilder: (BuildContext ctx, index) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(1),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: white)),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: MyNetworkImage(
                                                      imagePath: commentprovider
                                                              .commentList?[
                                                                  index]
                                                              .image
                                                              .toString() ??
                                                          "",
                                                      fit: BoxFit.fill,
                                                      width: 30,
                                                      height: 30),
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    MyText(
                                                        color: white,
                                                        text: commentprovider
                                                                .commentList?[
                                                                    index]
                                                                .channelName
                                                                .toString() ??
                                                            "",
                                                        fontsizeNormal:
                                                            Dimens.textMedium,
                                                        fontsizeWeb:
                                                            Dimens.textMedium,
                                                        fontwaight:
                                                            FontWeight.w500,
                                                        multilanguage: false,
                                                        maxline: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        inter: false,
                                                        textalign:
                                                            TextAlign.center,
                                                        fontstyle:
                                                            FontStyle.normal),
                                                    const SizedBox(height: 8),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.70,
                                                      child: MyText(
                                                          color: white,
                                                          text: commentprovider
                                                                  .commentList?[
                                                                      index]
                                                                  .comment
                                                                  .toString() ??
                                                              "",
                                                          fontsizeNormal:
                                                              Dimens.textSmall,
                                                          fontsizeWeb:
                                                              Dimens.textSmall,
                                                          fontwaight:
                                                              FontWeight.w400,
                                                          multilanguage: false,
                                                          maxline: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          inter: false,
                                                          textalign:
                                                              TextAlign.left,
                                                          fontstyle:
                                                              FontStyle.normal),
                                                    ),
                                                    const SizedBox(height: 7),
                                                    Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: () async {
                                                            shortProvider.storeReplayCommentId(
                                                                shortProvider
                                                                        .commentList?[
                                                                            index]
                                                                        .id
                                                                        .toString() ??
                                                                    "");
                                                            // Set Replay Comment Channal name
                                                            commentController
                                                                .clear();

                                                            Navigator.pop(
                                                                context);

                                                            replayCommentBottomSheet(
                                                                index,
                                                                videoid,
                                                                commentprovider
                                                                        .commentList?[
                                                                            index]
                                                                        .id
                                                                        .toString() ??
                                                                    "",
                                                                commentprovider
                                                                        .commentList?[
                                                                            index]
                                                                        .image
                                                                        .toString() ??
                                                                    "",
                                                                commentprovider
                                                                        .commentList?[
                                                                            index]
                                                                        .fullName
                                                                        .toString() ??
                                                                    "",
                                                                commentprovider
                                                                        .commentList?[
                                                                            index]
                                                                        .comment
                                                                        .toString() ??
                                                                    "",
                                                                isShortType);

                                                            await shortProvider
                                                                .getReplayComment(
                                                                    commentprovider
                                                                            .commentList?[index]
                                                                            .id
                                                                            .toString() ??
                                                                        "",
                                                                    1);
                                                          },
                                                          child: commentprovider
                                                                      .commentList?[
                                                                          index]
                                                                      .totalReply !=
                                                                  0
                                                              ? Row(
                                                                  children: [
                                                                    MyText(
                                                                        color:
                                                                            gray,
                                                                        text:
                                                                            "seeall",
                                                                        fontsizeNormal:
                                                                            Dimens
                                                                                .textSmall,
                                                                        fontsizeWeb:
                                                                            Dimens
                                                                                .textSmall,
                                                                        fontwaight:
                                                                            FontWeight
                                                                                .w400,
                                                                        multilanguage:
                                                                            true,
                                                                        maxline:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        inter:
                                                                            false,
                                                                        textalign:
                                                                            TextAlign
                                                                                .center,
                                                                        fontstyle:
                                                                            FontStyle.normal),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    MyText(
                                                                        color:
                                                                            gray,
                                                                        text: Utils.kmbGenerator(int
                                                                            .parse(
                                                                          commentprovider.commentList?[index].totalReply.toString() ??
                                                                              "",
                                                                        )),
                                                                        fontsizeNormal:
                                                                            Dimens
                                                                                .textSmall,
                                                                        fontsizeWeb:
                                                                            Dimens
                                                                                .textSmall,
                                                                        fontwaight:
                                                                            FontWeight
                                                                                .w400,
                                                                        multilanguage:
                                                                            false,
                                                                        maxline:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        inter:
                                                                            false,
                                                                        textalign:
                                                                            TextAlign
                                                                                .center,
                                                                        fontstyle:
                                                                            FontStyle.normal),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    MyText(
                                                                        color:
                                                                            gray,
                                                                        text:
                                                                            "comments",
                                                                        fontsizeNormal:
                                                                            Dimens
                                                                                .textSmall,
                                                                        fontsizeWeb:
                                                                            Dimens
                                                                                .textSmall,
                                                                        fontwaight:
                                                                            FontWeight
                                                                                .w400,
                                                                        multilanguage:
                                                                            true,
                                                                        maxline:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        inter:
                                                                            false,
                                                                        textalign:
                                                                            TextAlign
                                                                                .center,
                                                                        fontstyle:
                                                                            FontStyle.normal),
                                                                  ],
                                                                )
                                                              : MyText(
                                                                  color: gray,
                                                                  text:
                                                                      "seeall",
                                                                  fontsizeNormal:
                                                                      Dimens
                                                                          .textSmall,
                                                                  fontsizeWeb: Dimens
                                                                      .textSmall,
                                                                  fontwaight:
                                                                      FontWeight
                                                                          .w400,
                                                                  multilanguage:
                                                                      true,
                                                                  maxline: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  inter: false,
                                                                  textalign:
                                                                      TextAlign
                                                                          .center,
                                                                  fontstyle:
                                                                      FontStyle
                                                                          .normal),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        if (commentprovider
                                                                .commentList?[
                                                                    index]
                                                                .userId
                                                                .toString() ==
                                                            Constant.userID)
                                                          if (commentprovider
                                                                  .deletecommentLoading &&
                                                              commentprovider
                                                                      .deleteItemIndex ==
                                                                  index)
                                                            const SizedBox(
                                                              height: 20,
                                                              width: 20,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color:
                                                                    colorPrimary,
                                                                strokeWidth: 1,
                                                              ),
                                                            )
                                                          else
                                                            InkWell(
                                                              onTap: () async {
                                                                await shortProvider.getDeleteComment(
                                                                    commentprovider
                                                                            .commentList?[index]
                                                                            .id
                                                                            .toString() ??
                                                                        "",
                                                                    true,
                                                                    index,
                                                                    isShortType);
                                                              },
                                                              child: MyImage(
                                                                  width: 15,
                                                                  height: 15,
                                                                  imagePath:
                                                                      "ic_delete.png"),
                                                            )
                                                        else
                                                          const SizedBox
                                                              .shrink(),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                                if (shortProvider.commentloading)
                                  const CircularProgressIndicator(
                                    color: colorPrimary,
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
                      }
                    }),
                  ],
                ),
              ),
            ),
            Utils.buildGradLine(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: commentController,
                      maxLines: 1,
                      scrollPhysics: const AlwaysScrollableScrollPhysics(),
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: transparent,
                        border: InputBorder.none,
                        hintText: "Add Comments",
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
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                const WebLogin(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      } else if (commentController.text.isEmpty) {
                        Utils().showToast("Please Enter Your Comment");
                      } else {
                        if (shortProvider.shortVideoList?[index].isComment ==
                                0 &&
                            isShortType == "short") {
                          Utils().showSnackBar(
                              context, "youcannotcommentthiscontent", true);
                          Navigator.pop(context);
                        } else {
                          await shortProvider.getaddcomment(
                              index,
                              "3",
                              videoid,
                              "0",
                              commentController.text,
                              "0",
                              widget.shortType);

                          commentController.clear();
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: (shortProvider.addcommentloading)
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: colorPrimary,
                                strokeWidth: 1,
                              ),
                            )
                          : MyImage(
                              height: 15,
                              width: 15,
                              fit: BoxFit.contain,
                              imagePath: "ic_send.png",
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

/* More Button Bottom Sheet */
  moreBottomSheet(contentImage, contentName, reportUserid, contentid) {
    return showDialog(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: colorPrimaryDark,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            constraints: const BoxConstraints(
              minWidth: 500,
              maxWidth: 500,
              minHeight: 250,
              maxHeight: 300,
            ),
            child: Wrap(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: MyNetworkImage(
                            imagePath: contentImage,
                            fit: BoxFit.fill,
                            width: 50,
                            height: 50,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: MyText(
                            color: white,
                            text: contentName,
                            fontwaight: FontWeight.w600,
                            fontsizeNormal: Dimens.textTitle,
                            fontsizeWeb: Dimens.textTitle,
                            maxline: 2,
                            multilanguage: false,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.left,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 0.5,
                      color: lightgray.withOpacity(0.20),
                    ),
                    const SizedBox(height: 20),
                    widget.shortType == "watchlater"
                        ? const SizedBox.shrink()
                        : Utils.moreFunctionItem(
                            "ic_watchlater.png", "savetowatchlater", () async {
                            await shortProvider.addremoveWatchLater(
                                "3", contentid, "0", "1");
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            Utils().showSnackBar(
                                context, "savetowatchlater", true);
                          }),
                    Utils.moreFunctionItem("report.png", "report", () async {
                      Navigator.pop(context);
                      _fetchReportReason(0);
                      reportBottomSheet(reportUserid, contentid);
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

/* Report Reason Bottom Sheet */
  reportBottomSheet(reportUserid, contentid) {
    return showDialog(
        context: context,
        barrierColor: transparent,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 35,
                    alignment: Alignment.centerLeft,
                    child: MyText(
                        color: white,
                        text: "selectreportreason",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textBig,
                        fontsizeWeb: Dimens.textBig,
                        multilanguage: true,
                        inter: false,
                        maxline: 2,
                        fontwaight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: buildReportReasonList(),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          shortProvider.reportReasonList?.clear();
                          shortProvider.position = 0;
                          shortProvider.clearSelectReportReason();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1, color: white),
                          ),
                          child: MyText(
                              color: white,
                              text: "cancel",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              fontsizeWeb: Dimens.textBig,
                              multilanguage: true,
                              inter: false,
                              maxline: 2,
                              fontwaight: FontWeight.w700,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () async {
                          if (Constant.userID == null) {
                            Navigator.push(
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
                            if (shortProvider.reasonId == "" ||
                                shortProvider.reasonId.isEmpty) {
                              Utils().showSnackBar(context,
                                  "pleaseselectyourreportreason", true);
                            } else {
                              await shortProvider.addContentReport(
                                  reportUserid,
                                  contentid,
                                  shortProvider
                                          .reportReasonList?[
                                              shortProvider.reportposition ?? 0]
                                          .reason
                                          .toString() ??
                                      "",
                                  "1");
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              Utils().showSnackBar(
                                  context,
                                  "${shortProvider.addContentReportModel.message}",
                                  false);
                              shortProvider.clearSelectReportReason();
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          decoration: BoxDecoration(
                              color: colorPrimary,
                              borderRadius: BorderRadius.circular(5)),
                          child: MyText(
                              color: colorAccent,
                              text: "report",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              fontsizeWeb: Dimens.textBig,
                              multilanguage: true,
                              inter: false,
                              maxline: 2,
                              fontwaight: FontWeight.w700,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget buildReportReasonList() {
    return Consumer<ShortProvider>(
        builder: (context, reportreasonprovider, child) {
      if (reportreasonprovider.getcontentreportloading &&
          !reportreasonprovider.getcontentreportloadmore) {
        return Utils.pageLoader(context);
      } else {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          controller: reportReasonController,
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              buildReportReasonListItem(),
              if (reportreasonprovider.getcontentreportloadmore)
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                  child: Utils.pageLoader(context),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      }
    });
  }

  Widget buildReportReasonListItem() {
    if (shortProvider.getRepostReasonModel.status == 200 &&
        shortProvider.reportReasonList != null) {
      if ((shortProvider.reportReasonList?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: shortProvider.reportReasonList?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  shortProvider.selectReportReason(
                      index,
                      true,
                      shortProvider.reportReasonList?[index].id.toString() ??
                          "");
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 1,
                              color: shortProvider.reportposition == index
                                  ? colorPrimary
                                  : gray)),
                      child: Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: shortProvider.reportposition == index
                              ? colorPrimary
                              : transparent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: MyText(
                          color: shortProvider.reportposition == index &&
                                  shortProvider.isSelectReason == true
                              ? colorAccent
                              : white,
                          text: shortProvider.reportReasonList?[index].reason
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          fontsizeWeb: Dimens.textTitle,
                          multilanguage: false,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                    /*const SizedBox(width: 20),
                    shortProvider.reportposition == index &&
                            shortProvider.isSelectReason == true
                        ? Icon(
                            Icons.check,
                            color: shortProvider.reportposition == index &&
                                    shortProvider.isSelectReason == true
                                ? colorAccent
                                : white,
                          )
                        : const SizedBox.shrink(),*/
                  ],
                ),
              ),
            );
          },
        );
      } else {
        printLog("null Array");
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      printLog("null Array Last");
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

/* ReplayComment Bottom Sheet */
  // Replay Comment
  replayCommentBottomSheet(int index, videoid, commentid, commentUserImage,
      commentUsername, comment, isShortPage) {
    return showDialog<void>(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return Wrap(
          children: [
            buildReplayComment(index, videoid, commentid, commentUserImage,
                commentUsername, comment, isShortPage),
          ],
        );
      },
    ).whenComplete(() {
      commentController.clear();
      shortProvider.clearReplayComment();
    });
  }

  Widget buildReplayComment(index, videoid, commentId, commentUserImage,
      commentUsername, comment, isShortPage) {
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
                        commentController.clear();
                        shortProvider.clearComment();
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
            Expanded(child: buildreplayCommentList(isShortPage)),
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
                        controller: commentController,
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
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  const WebLogin(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        } else if (commentController.text.isEmpty) {
                          Utils().showToast("Please Enter Your Comment");
                        } else {
                          printLog("videoid==> $videoid");
                          printLog("comment==> ${commentController.text}");
                          printLog("comment==> $commentId");
                          await shortProvider.getaddReplayComment(
                            "3",
                            videoid,
                            "0",
                            commentController.text,
                            commentId,
                          );
                          commentController.clear();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Consumer<ShortProvider>(
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

  Widget buildreplayCommentList(isShortPage) {
    return SingleChildScrollView(
      controller: replaycommentController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
      child: Consumer<ShortProvider>(builder: (context, detailprovider, child) {
        if (detailprovider.replaycommentloding &&
            !detailprovider.replayCommentloadmore) {
          return Utils.pageLoader(context);
        } else {
          if (shortProvider.replayCommentModel.status == 200) {
            if ((shortProvider.replaycommentList?.length ?? 0) > 0) {
              return Column(
                children: [
                  //replayCommentList(isShortPage),
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
            } else {
              return const NoData(title: "", subTitle: "");
            }
          } else {
            return const NoData(title: "", subTitle: "");
          }
        }
      }),
    );
  }

  /* Widget replayCommentList(isShortPage) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shortProvider.replaycommentList?.length ?? 0,
          shrinkWrap: true,
          itemBuilder: (BuildContext ctx, index) {
            return Container(
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
                          imagePath: shortProvider
                                  .replaycommentList?[index].image
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
                        shortProvider.replaycommentList?[index].fullName == ""
                            ? MyText(
                                color: white,
                                text: shortProvider
                                        .replaycommentList?[index].fullName
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
                                text: shortProvider
                                        .replaycommentList?[index].channelName
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
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: MyText(
                              color: white,
                              text: shortProvider
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
                  if (shortProvider.replaycommentList?[index].userId
                          .toString() ==
                      Constant.userID)
                    if (shortProvider.deletecommentLoading &&
                        shortProvider.deleteItemIndex == index)
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
                            Navigator.push(
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
                            await shortProvider.getDeleteComment(
                                shortProvider.replaycommentList?[index].id
                                        .toString() ??
                                    "",
                                false,
                                index,
                                isShortPage);
                            if (!mounted) return;
                            if (!shortProvider.deletecommentLoading) {
                              if (shortProvider.deleteCommentModel.status ==
                                  200) {
                                Utils().showSnackBar(
                                    context,
                                    "${shortProvider.deleteCommentModel.message}",
                                    false);
                              } else {
                                Utils().showSnackBar(
                                    context,
                                    "${shortProvider.deleteCommentModel.message}",
                                    false);
                              }
                            }
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
    );
  }*/

/* Up Down Button */

  Widget upDownButton({type, onTap}) {
    return InkWell(
      hoverColor: transparent,
      highlightColor: transparent,
      focusColor: transparent,
      splashColor: transparent,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorPrimaryDark,
          shape: BoxShape.circle,
        ),
        child: Icon(
            type == "up" ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: white,
            size: 25),
      ),
    );
  }

  void _scrollUp() {
    if (widget.shortType == "profile") {
      _profileController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else if (widget.shortType == "watchlater") {
      _watchLaterController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _shortPageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollDown() {
    if (widget.shortType == "profile") {
      _profileController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else if (widget.shortType == "watchlater") {
      _watchLaterController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _shortPageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }
}
