import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:fanbae/pages/login.dart';
import 'package:fanbae/music/musicdetails.dart';
import 'package:fanbae/pages/profile.dart';
import 'package:fanbae/pages/viewmembershipplan.dart';
import 'package:fanbae/provider/shortprovider.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/webshorts.dart';
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
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bx.dart';
import 'package:iconify_flutter/icons/teenyicons.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:video_player/video_player.dart';

import '../livestream/livestreamprovider.dart';
import '../model/membership_plan_model.dart';
import '../model/successmodel.dart';
import '../provider/profileprovider.dart';
import '../subscription/adspackage.dart';
import '../webpages/weblogin.dart';
import '../webpages/webprofile.dart';
import '../webservice/apiservice.dart';
import '../widget/customappbar.dart';
import 'bottombar.dart';

class Shorts extends StatefulWidget {
  final String? shortType, userId, channelId, videoId;
  final int initialIndex;

  const Shorts({
    Key? key,
    this.shortType,
    required this.initialIndex,
    this.userId,
    this.channelId,
    this.videoId,
  }) : super(key: key);

  @override
  State<Shorts> createState() => ShortsState();
}

class ShortsState extends State<Shorts> with SingleTickerProviderStateMixin {
  List<String> allVideos = [];
  SharedPre sharePref = SharedPre();
  late ProgressDialog prDialog;
  late ShortProvider shortProvider;
  final commentController = TextEditingController();
  late ScrollController commentListController;
  late ScrollController reportReasonController;
  int checkboxIndex = 0;
  bool ischange = true;
  List<VideoPlayerController> controllers = [];
  late VideoPlayerController controller;
  late ScrollController replaycommentController;
  late Future<void> initializeVideoPlayerFuture;
  late PreloadPageController preloadPageController;
  late AnimationController _controller;
  String _selectedFeed = 'for_you';
  bool isCoinLoad = false;
  bool _showTopWidgets = true;
  late ProfileProvider profileProvider;
  late LiveStreamProvider liveStreamProvider;
  MembershipPlanModel? membershipPlanModel;
  final FocusNode commentFocusNode = FocusNode();
  final GlobalKey textFieldKey = GlobalKey();

  bool get isDeepLink => widget.videoId != null;

  late ScrollController _giftScrollController;
  ScrollDirection _lastScrollDirection = ScrollDirection.idle;

  @override
  void initState() {
    printLog("initalIndex ==> ${widget.initialIndex}");
    shortProvider = Provider.of<ShortProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    liveStreamProvider =
        Provider.of<LiveStreamProvider>(context, listen: false);
    _giftScrollController = ScrollController();

    _giftScrollController.addListener(_scrollGiftListener);

    audioPlayer.pause();
    commentListController = ScrollController();
    reportReasonController = ScrollController();
    replaycommentController = ScrollController();
    commentListController.addListener(_scrollListener);
    reportReasonController.addListener(_scrollListenerReportReason);
    replaycommentController.addListener(_scrollListenerReplayComment);
    preloadPageController =
        PreloadPageController(initialPage: widget.initialIndex);

    getApi();
    getData();
    _fetchDataAndInitialize();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    super.initState();
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

  getData() async {
    if (Constant.userID != null) {
      await profileProvider.getProfileReel(context, Constant.userID);
      if (profileProvider.profileModelReel.status == 200 &&
          profileProvider.profileModelReel.result != null) {
        await sharePref.save(
            "userpanelstatus",
            profileProvider.profileModelReel.result?[0].userPenalStatus
                    .toString() ??
                "");
        Constant.userPanelStatus = await sharePref.read("userpanelstatus");
        if (!kIsWeb) {
          await Utils.initializeHiveBoxes(context);
        }
      }
    } else {
      Utils.loadAds(context);
    }

    setState(() {});
  }

  Future<void> _fetchDataAndInitialize() async {
    if (widget.shortType == "profile" || widget.shortType == "watchlater") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (preloadPageController.hasClients) {
          preloadPageController.jumpToPage(widget.initialIndex);
        }
      });
    }
  }

  getApi() async {
    if (widget.shortType == "profile") {
      await shortProvider.getcontentbyChannelShort(
          widget.userId, widget.channelId, "3", "1");
    } else if (widget.shortType == "watchlater") {
      await shortProvider.getContentByWatchLater("3", "1");
    } else {
      await shortProvider.getShortList(1, _selectedFeed);
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

  Future<void> _loadMembershipForIndex(int index) async {
    final userId =
        shortProvider.shortVideoList?[index].userId?.toString() ?? "";
    if (userId.isEmpty) return;

    // 👉 Fetch profile for this user
    await profileProvider.getProfileReel(context, userId);

    final creatorId =
        profileProvider.profileModelReel.result?[0].id.toString() ?? "0";

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
      await shortProvider.getShortList(nextPage, _selectedFeed);
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

  Future _fetchReplayCommentData(commentid, int? nextPage) async {
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
    shortProvider.clearProvider();
    _controller.dispose();
    commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: ResponsiveHelper.checkIsWeb(context)
          ? Utils.webAppbarWithSidePanel(
              context: context, contentType: Constant.videoSearch)
          : null,
      body: ResponsiveHelper.checkIsWeb(context)
          ? Utils.sidePanelWithBody(
              myWidget: RefreshIndicator(
                  backgroundColor: appbgcolor,
                  color: colorAccent,
                  displacement: 70,
                  edgeOffset: 1.0,
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  strokeWidth: 3,
                  onRefresh: () async {
                    await shortProvider.clearProvider();
                    getApi();
                    getData();
                    _fetchDataAndInitialize();
                  },
                  child: buildLayout()),
            )
          : RefreshIndicator(
              backgroundColor: appbgcolor,
              color: colorAccent,
              displacement: 70,
              edgeOffset: 1.0,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              strokeWidth: 3,
              onRefresh: () async {
                await shortProvider.clearProvider();
                getApi();
                getData();
                _fetchDataAndInitialize();
              },
              child: buildLayout()),
    );
  }

  Widget buildLayout() {
    if (widget.shortType == "profile") {
      return _buildProfileShort();
    } else if (widget.shortType == "watchlater") {
      return _buildWatchLaterShort();
    } else {
      return Utils().pageBg(context, child: _buildShort());
    }
  }

  Widget buildSearchField() {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        gradient: _selectedFeed == 'search' ? Constant.gradientColor : null,
        border: Border.all(
          color: _selectedFeed == 'search' ? transparent : textColor,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: white, fontWeight: FontWeight.w700),
        controller: shortProvider.searchController,
        decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(color: white),
            /* fillColor: ResponsiveHelper.checkIsWeb(context)
                ? colorPrimaryDark
                : white.withOpacity(0.42),
            filled: true,*/
            contentPadding: const EdgeInsets.only(top: 15, left: 10),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
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
                padding: const EdgeInsets.all(7.0),
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
      ),
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
                    color: _selectedFeed == "for_you" ? pureBlack : white,
                    size: 17,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  MyText(
                    text: "foryou",
                    fontwaight: FontWeight.w600,
                    fontsizeNormal: 12,
                    color: _selectedFeed == "for_you" ? pureBlack : white,
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
                      color: _selectedFeed != "for_you" ? pureBlack : white,
                      size: 17),
                  const SizedBox(
                    width: 4,
                  ),
                  MyText(
                    text: "following",
                    color: _selectedFeed != "for_you" ? pureBlack : white,
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

/* Simple Short */
  Widget _buildShort() {
    return Stack(
      children: [
        Consumer<ShortProvider>(
          builder: (context, shortprovider, child) {
            if (shortprovider.loading) {
              return shimmer();
            } else {
              if (shortprovider.shortModel.status == 200) {
                if (shortprovider.shortVideoList != null &&
                    (shortprovider.shortVideoList?.length ?? 0) > 0) {
                  return _buildShortPageView();
                } else {
                  return const NoPost(
                      title: "no_posts_available", subTitle: "");
                }
              } else {
                return const NoPost(title: "no_posts_available", subTitle: "");
              }
            }
          },
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 330),
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
              ? Column(
                  children: [
                    ResponsiveHelper.checkIsWeb(context)
                        ? const SizedBox()
                        : const CustomAppBar(contentType: "1"),
                    Container(
                      key: const ValueKey(
                          'topWidget'), // important for animation
                      decoration: BoxDecoration(
                        color: ResponsiveHelper.checkIsWeb(context)
                            ? transparent
                            : appBarColor,
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
                    ),
                  ],
                )
              : const SizedBox(
                  key:
                      ValueKey('emptyWidget'), // keeps AnimatedSwitcher working
                ),
        ),
      ],
    );
  }

  Widget _buildShortPageView() {
    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: !ResponsiveHelper.isMobile(context)
                ? 370
                : MediaQuery.of(context).size.width,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is UserScrollNotification) {
                  if (notification.direction == ScrollDirection.forward) {
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
                  } else if (notification.direction == ScrollDirection.idle) {
                    // When scrolling stops, keep the last state
                    setState(() {
                      _lastScrollDirection = notification.direction;
                    });
                  }
                }
                return false;
              },
              child: PreloadPageView.builder(
                itemCount: shortProvider.shortVideoList?.length ?? 0,
                scrollDirection: Axis.vertical,
                preloadPagesCount: 4,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      /* Reels Video */
                      ReelsPlayer(
                        isLiveStream: false,
                        pagePos: index,
                        index: index,
                        thumbnailImg: shortProvider
                                .shortVideoList?[index].portraitImg
                                .toString() ??
                            "",
                        videoUrl: widget.videoId != null
                            ? widget.videoId ?? ''
                            : shortProvider.shortVideoList?[index].content
                                    .toString() ??
                                "",
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            // stronger blur if needed
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.11,
                              decoration: BoxDecoration(
                                  color: black.withOpacity(0.3),
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(20),
                                      topLeft: Radius.circular(
                                          20))), // optional: darken
                            ),
                          ),
                        ),
                      ),

                      /* Like, Dislike, Comment, Share and More Buttons*/
                      Positioned.fill(
                        bottom: MediaQuery.of(context).size.height * 0.12,
                        right: !ResponsiveHelper.isMobile(context) ? 20 : 15,
                        left: 15,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Like Button With Like Count
                              InkWell(
                                hoverColor: transparent,
                                splashColor: transparent,
                                highlightColor: transparent,
                                focusColor: transparent,
                                onTap: () async {
                                  if (Constant.userID == null) {
                                    ResponsiveHelper.checkIsWeb(context)
                                        ? Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation1,
                                                      animation2) =>
                                                  const WebLogin(),
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ),
                                          )
                                        : Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return ResponsiveHelper.isWeb(
                                                        context)
                                                    ? const WebLogin()
                                                    : const Login();
                                              },
                                            ),
                                          );
                                  } else {
                                    if (shortProvider
                                            .shortVideoList?[index].isLike ==
                                        0) {
                                      Utils().showSnackBar(context,
                                          "youcannotlikethiscontent", true);
                                    } else {
                                      //  Call Like APi Call
                                      if ((shortProvider.shortVideoList?[index]
                                                  .isUserLikeDislike ??
                                              0) ==
                                          1) {
                                        await shortProvider.shortLike(
                                            index,
                                            "3",
                                            shortProvider
                                                    .shortVideoList?[index].id
                                                    .toString() ??
                                                "",
                                            "0",
                                            "0");
                                      } else {
                                        await shortProvider.shortLike(
                                            index,
                                            "3",
                                            shortProvider
                                                    .shortVideoList?[index].id
                                                    .toString() ??
                                                "",
                                            "1",
                                            "0");
                                      }
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return ScaleTransition(
                                          scale: animation, child: child);
                                    },
                                    child: (shortProvider.shortVideoList?[index]
                                                    .isUserLikeDislike ??
                                                0) ==
                                            1
                                        ? const Iconify(
                                            Bx.bxs_like,
                                            size: 28,
                                            color: Colors.redAccent,
                                            key: ValueKey<int>(1),
                                          )
                                        : const Iconify(
                                            Bx.like,
                                            size: 28,
                                            key: ValueKey<int>(2),
                                            color: pureWhite,
                                          ),
                                  ),
                                ),
                              ),
                              shortProvider.shortVideoList?[index].isComment ==
                                      0
                                  ? const SizedBox()
                                  : MyText(
                                      color: pureWhite,
                                      text: Utils.kmbGenerator(int.parse(
                                          shortProvider.shortVideoList?[index]
                                                  .totalLike
                                                  .toString() ??
                                              "")),
                                      multilanguage: false,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: 12,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                              const SizedBox(height: 15),
                              // Dislike Button With Deslike Count
                              /* InkWell(
                                onTap: () async {
                                  if (Constant.userID == null) {
                                    ResponsiveHelper.checkIsWeb(context) ?  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation1,
                                            animation2) =>
                                        const WebLogin(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                        Duration.zero,
                                      ),
                                    ) : Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const Login();
                                        },
                                      ),
                                    );
                                  } else {
                                    if (shortProvider
                                            .shortVideoList?[index].isLike ==
                                        0) {
                                      Utils().showSnackbar(context,
                                          "youcannotlikethiscontent", true);
                                    } else {
                                      //  Call DisLike APi Call
                                      if ((shortProvider.shortVideoList?[index]
                                                  .isUserLikeDislike ??
                                              2) ==
                                          0) {
                                        printLog("Remove Api");
                                        await shortProvider.shortDislike(
                                            index,
                                            "3",
                                            shortProvider
                                                    .shortVideoList?[index].id
                                                    .toString() ??
                                                "",
                                            "0",
                                            "0");
                                      } else {
                                        await shortProvider.shortDislike(
                                            index,
                                            "3",
                                            shortProvider
                                                    .shortVideoList?[index].id
                                                    .toString() ??
                                                "",
                                            "2",
                                            "0");
                                      }
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return ScaleTransition(
                                          scale: animation, child: child);
                                    },
                                    child: (shortProvider.shortVideoList?[index]
                                                    .isUserLikeDislike ??
                                                0) ==
                                            2
                                        ? const Iconify(
                                            Bx.bxs_dislike,
                                            size: 28,
                                            color: Colors.redAccent,
                                            key: ValueKey<int>(1),
                                          )
                                        : Iconify(
                                            Bx.dislike,
                                            size: 28,
                                            key: ValueKey<int>(2),
                                            color: white,
                                          ),
                                  ),
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
                                  fontsizeNormal: 12,
                                  multilanguage: false,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 15),*/
                              // Commenet Button Bottom Sheet Open
                              InkWell(
                                onTap: () {
                                  shortProvider.storeContentId(shortProvider
                                          .shortVideoList?[index].id
                                          .toString() ??
                                      "");
                                  // Call Comment bottom Sheet
                                  shortProvider.getComment(
                                      "3",
                                      shortProvider.shortVideoList?[index].id
                                              .toString() ??
                                          "",
                                      1);

                                  commentBottomSheet(
                                      videoid: shortProvider
                                              .shortVideoList?[index].id
                                              .toString() ??
                                          "",
                                      index: index,
                                      isShortType: "short");
                                },
                                child: const Iconify(
                                  Teenyicons.message_text_alt_solid,
                                  size: 20,
                                  color: pureWhite,
                                ),
                              ),
                              const SizedBox(height: 2),
                              shortProvider.shortVideoList?[index].isComment ==
                                      0
                                  ? const SizedBox()
                                  : MyText(
                                      color: pureWhite,
                                      text: Utils.kmbGenerator(shortProvider
                                              .shortVideoList?[index]
                                              .totalComment ??
                                          0),
                                      multilanguage: false,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: 12,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                              const SizedBox(height: 15),
                              // Share Button
                              if (!ResponsiveHelper.isWeb(context))
                                InkWell(
                                  onTap: () {
                                    if (Constant.userID == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ResponsiveHelper.isWeb(
                                                    context)
                                                ? const WebLogin()
                                                : const Login();
                                          },
                                        ),
                                      );
                                    } else {
                                      final liveUrl =
                                          "Hey! I'm watching ${shortProvider.shortVideoList?[index].title ?? ""} "
                                          "on ${Constant.appName}! 🎬\n"
                                          "Watch here 👉 https://fanbae.tv/shorts?s=${shortProvider.shortVideoList?[index].channelId}/${shortProvider.shortVideoList?[index].userId}/$index/${shortProvider.shortVideoList?[index].content?.split('/')[3]}\n";
                                      Utils.shareApp(liveUrl);
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      MyImage(
                                          width: 25,
                                          height: 25,
                                          color: pureWhite,
                                          imagePath: "ic_share.png"),
                                      const SizedBox(height: 2),
                                      MyText(
                                          color: pureWhite,
                                          text: "share",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 12,
                                          multilanguage: true,
                                          inter: false,
                                          maxline: 1,
                                          fontwaight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 15),
                              Constant.userID ==
                                      (shortProvider
                                              .shortVideoList?[index].userId
                                              .toString() ??
                                          '')
                                  ? const SizedBox()
                                  : InkWell(
                                      onTap: () {
                                        if (Constant.userID == null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return ResponsiveHelper.isWeb(
                                                        context)
                                                    ? const WebLogin()
                                                    : const Login();
                                              },
                                            ),
                                          );
                                        } else {
                                          moreBottomSheet(
                                            shortProvider.shortVideoList?[index]
                                                    .userId
                                                    .toString() ??
                                                "",
                                            shortProvider
                                                    .shortVideoList?[index].id
                                                    .toString() ??
                                                "",
                                          );
                                        }
                                      },
                                      child: MyImage(
                                          width: 20,
                                          height: 20,
                                          imagePath: "ic_more.png"),
                                    ),
                              const SizedBox(height: 20),
                              Constant.userID ==
                                      (shortProvider
                                              .shortVideoList?[index].userId
                                              .toString() ??
                                          '')
                                  ? const SizedBox()
                                  : Utils().circleIconWithButton(
                                      circleSize: 50,
                                      iconSize: 48,
                                      color: white.withOpacity(0.20),
                                      icon: "ic_gift.webp",
                                      onTap: () {
                                        if (Constant.userID == null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return ResponsiveHelper.isWeb(
                                                        context)
                                                    ? const WebLogin()
                                                    : const Login();
                                              },
                                            ),
                                          );
                                        } else {
                                          openGift(shortProvider
                                                  .shortVideoList?[index].userId
                                                  .toString() ??
                                              '');
                                        }
                                      },
                                    ),
                              /*    !kIsWeb && Constant.isCreator == '1'
                                  ? InkWell(
                                      onTap: () {
                                        if (Constant.userID == null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return const ResponsiveHelper.isWeb(context)? const WebLogin():const Login();
                                              },
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return const CreateReels();
                                              },
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(13),
                                        decoration: BoxDecoration(
                                            gradient: Constant.gradientColor,
                                            shape: BoxShape.circle),
                                        child: const Icon(
                                          Icons.add,
                                          size: 23,
                                          color: pureBlack,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink()*/
                            ],
                          ),
                        ),
                      ),
                      /* Channel Name, Reels Title */
                      Positioned.fill(
                        bottom: 10,
                        left: !ResponsiveHelper.isMobile(context) ? 20 : 20,
                        right: 15,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /* Uploded Reels User Image */
                            shortProvider.shortVideoList?[index].userId != 0
                                ? InkWell(
                                    onTap: ResponsiveHelper.checkIsWeb(context)
                                        ? () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation1,
                                                        animation2) =>
                                                    WebProfile(
                                                  isProfile: false,
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
                                          }
                                        : () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  print(
                                                      'channel Id :${shortProvider.shortVideoList?[index].channelId.toString() ?? ""}');

                                                  return Profile(
                                                    isProfile: false,
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
                                                  );
                                                },
                                              ),
                                            );
                                            setState(() {
                                              context
                                                  .read<ProfileProvider>()
                                                  .fetchMyProfile(context);
                                            });
                                          },
                                    child: Container(
                                      width: 350,
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 4, 0, 4),
                                      child: Row(
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                width: 38, // Outer size
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient:
                                                      Constant.sweepGradient,
                                                ),
                                              ),
                                              Container(
                                                width: 33,
                                                height: 33,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: MyNetworkImage(
                                                    width: 28,
                                                    height: 28,
                                                    fit: BoxFit.cover,
                                                    imagePath: shortProvider
                                                            .shortVideoList?[
                                                                index]
                                                            .channelImage
                                                            .toString() ??
                                                        ""),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: MyText(
                                                color: white,
                                                text: shortProvider
                                                        .shortVideoList?[index]
                                                        .channelName
                                                        .toString() ??
                                                    "",
                                                multilanguage: false,
                                                textalign: TextAlign.left,
                                                fontsizeNormal:
                                                    Dimens.textTitle,
                                                inter: false,
                                                maxline: 1,
                                                fontwaight: FontWeight.w600,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal),
                                          ),
                                          const SizedBox(width: 10),
                                          /* User Subscribe Button */
                                          Constant.userID !=
                                                  shortProvider
                                                      .shortVideoList?[index]
                                                      .userId
                                                      .toString()
                                              ? InkWell(
                                                  onTap: () async {
                                                    if (Constant.userID ==
                                                        null) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return ResponsiveHelper
                                                                    .isWeb(
                                                                        context)
                                                                ? const WebLogin()
                                                                : const Login();
                                                          },
                                                        ),
                                                      );
                                                    } else {
                                                      await shortProvider
                                                          .addremoveSubscribe(
                                                              index,
                                                              shortProvider
                                                                      .shortVideoList?[
                                                                          index]
                                                                      .userId
                                                                      .toString() ??
                                                                  "",
                                                              "1",
                                                              widget.shortType);
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 4, 10, 4),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 1,
                                                          color: colorPrimary),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      gradient: Constant
                                                          .gradientColor,
                                                    ),
                                                    child: MyText(
                                                        color: pureBlack,
                                                        text: shortProvider
                                                                    .shortVideoList?[
                                                                        index]
                                                                    .isSubscribe ==
                                                                0
                                                            ? "subscribe"
                                                            : "subscribed",
                                                        multilanguage: true,
                                                        textalign:
                                                            TextAlign.center,
                                                        fontsizeNormal:
                                                            Dimens.textSmall,
                                                        inter: false,
                                                        maxline: 1,
                                                        fontwaight:
                                                            FontWeight.w600,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontstyle:
                                                            FontStyle.normal),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Constant.userID !=
                                                      shortProvider
                                                          .shortVideoList?[
                                                              index]
                                                          .userId
                                                          .toString() &&
                                                  (membershipPlanModel
                                                          ?.result.isNotEmpty ??
                                                      false)
                                              ? InkWell(
                                                  onTap: () async {
                                                    if (Constant.userID ==
                                                        null) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return ResponsiveHelper
                                                                    .isWeb(
                                                                        context)
                                                                ? const WebLogin()
                                                                : const Login();
                                                          },
                                                        ),
                                                      );
                                                    } else {
                                                      if (profileProvider
                                                              .profileModelReel
                                                              .result?[0]
                                                              .id
                                                              .toString() ==
                                                          Constant.userID) {
                                                        await profileProvider
                                                            .getProfileReel(
                                                          context,
                                                          shortProvider
                                                                  .shortVideoList?[
                                                                      index]
                                                                  .userId
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
                                                                      .profileModelReel
                                                                      .result?[
                                                                          0]
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
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 4, 10, 4),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: shortProvider
                                                                  .shortVideoList?[
                                                                      index]
                                                                  .purchasePackage ==
                                                              0
                                                          ? colorPrimary
                                                          : appbgcolor,
                                                      border: Border.all(
                                                          width: 1,
                                                          color: colorPrimary),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: MyText(
                                                        color: shortProvider
                                                                    .shortVideoList?[
                                                                        index]
                                                                    .purchasePackage ==
                                                                0
                                                            ? pureBlack
                                                            : white,
                                                        text: shortProvider
                                                                    .shortVideoList?[
                                                                        index]
                                                                    .purchasePackage ==
                                                                0
                                                            ? "subscribing"
                                                            : 'subscriber',
                                                        textalign:
                                                            TextAlign.left,
                                                        fontsizeNormal:
                                                            Dimens.textSmall,
                                                        inter: false,
                                                        maxline: 2,
                                                        multilanguage: true,
                                                        fontwaight:
                                                            FontWeight.w500,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontstyle:
                                                            FontStyle.normal),
                                                  ),
                                                )
                                              : const SizedBox.shrink()
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
                                            textalign: TextAlign.left,
                                            fontsizeNormal: Dimens.textTitle,
                                            inter: false,
                                            maxline: 1,
                                            fontwaight: FontWeight.w600,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal),
                                      ),
                                    ],
                                  ),
                            /* User Title */
                            Container(
                              width: 250,
                              margin: const EdgeInsets.fromLTRB(0, 2, 0, 7),
                              child: SizedBox(
                                height: 15,
                                child: MyText(
                                    text: shortProvider
                                            .shortVideoList?[index].title
                                            .toString() ??
                                        "",
                                    multilanguage: false,
                                    fontsizeNormal: Dimens.textSmall,
                                    color: white),
                              ),
                            ),
                            /* Gif Image Music */
                            // Padding(
                            //   padding: const EdgeInsets.fromLTRB(0, 2, 0, 5),
                            //   child: Row(
                            //     children: [
                            //       MyImage(
                            //           width: 12,
                            //           height: 12,
                            //           imagePath: "music.png",
                            //           color: white),
                            //       const SizedBox(width: 15),
                            //       MyText(
                            //           color: white,
                            //           text: "originalsound",
                            //           textalign: TextAlign.center,
                            //           fontsizeNormal: Dimens.textSmall,
                            //           multilanguage: true,
                            //           inter: false,
                            //           maxline: 1,
                            //           fontwaight: FontWeight.w500,
                            //           overflow: TextOverflow.ellipsis,
                            //           fontstyle: FontStyle.normal),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                /* Reels Pagination Content */
                onPageChanged: (index) async {
                  _loadMembershipForIndex(index);
                  if (index > 0 && (index % 2) == 0) {
                    _fetchAllShort();
                  }
                  printLog("onPageChanged value ======> $index");
                  log("totalComment==>${shortProvider.shortVideoList?[index].totalComment.toString() ?? ""}");
                },
              ),
            ),
          ),
        ),
        //       Constant.isCreator == '1' ? createShortButton() : const SizedBox.shrink(),
      ],
    );
  }

/* Profile Short */
  Widget _buildProfileShort() {
    return Consumer<ShortProvider>(
      builder: (context, profileShortprovider, child) {
        if (profileShortprovider.loading) {
          return shimmer();
        } else {
          if (profileShortprovider.profileShortList != null &&
              (profileShortprovider.profileShortList?.length ?? 0) > 0) {
            return _buildProfileShortPageView();
          } else {
            return const NoPost(title: "", subTitle: "");
          }
        }
      },
    );
  }

  Widget _buildProfileShortPageView() {
    return Stack(
      children: [
        PreloadPageView.builder(
          controller: preloadPageController,
          itemCount: shortProvider.profileShortList?.length ?? 0,
          scrollDirection: Axis.vertical,
          preloadPagesCount: 4,
          itemBuilder: (context, index) {
            printLog("Index==>$index");
            printLog("initialindex==>${widget.initialIndex}");
            return Stack(
              children: [
                /* Reels Video */
                ReelsPlayer(
                  isLiveStream: false,
                  pagePos: index,
                  index: index,
                  thumbnailImg: shortProvider
                          .profileShortList?[index].portraitImg
                          .toString() ??
                      "",
                  videoUrl: shortProvider.profileShortList?[index].content
                          .toString() ??
                      "",
                ),
                /* Like, Dislike, Comment, Share and More Buttons*/
                Positioned.fill(
                  bottom: 30,
                  right: 15,
                  left: 15,
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
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ResponsiveHelper.isWeb(context)
                                        ? const WebLogin()
                                        : const Login();
                                  },
                                ),
                              );
                            } else {
                              if (shortProvider
                                      .profileShortList?[index].isLike ==
                                  0) {
                                Utils().showSnackBar(
                                    context, "youcannotlikethiscontent", true);
                              } else {
                                //  Call Like APi Call
                                if ((shortProvider.profileShortList?[index]
                                            .isUserLikeDislike ??
                                        0) ==
                                    1) {
                                  printLog("Remove Api");
                                  await shortProvider.profileShortLike(
                                      index,
                                      "3",
                                      shortProvider.profileShortList?[index].id
                                              .toString() ??
                                          "",
                                      "0",
                                      "0");
                                } else {
                                  await shortProvider.profileShortLike(
                                      index,
                                      "3",
                                      shortProvider.profileShortList?[index].id
                                              .toString() ??
                                          "",
                                      "1",
                                      "0");
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: (shortProvider.profileShortList?[index]
                                              .isUserLikeDislike ??
                                          0) ==
                                      1
                                  ? const Iconify(
                                      Bx.bxs_like,
                                      size: 26,
                                      color: colorPrimary,
                                      key: ValueKey<int>(1),
                                    )
                                  : Iconify(
                                      Bx.like,
                                      size: 26,
                                      key: const ValueKey<int>(2),
                                      color: white,
                                    ),
                            ),
                          ),
                        ),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(int.parse(shortProvider
                                    .profileShortList?[index].totalLike
                                    .toString() ??
                                "")),
                            multilanguage: false,
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 15),
                        // Dislike Button With Deslike Count
                        /* InkWell(
                          onTap: () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              if (shortProvider
                                      .profileShortList?[index].isLike ==
                                  0) {
                                Utils().showSnackbar(
                                    context, "youcannotlikethiscontent", true);
                              } else {
                                //  Call DisLike APi Call
                                if ((shortProvider.profileShortList?[index]
                                            .isUserLikeDislike ??
                                        2) ==
                                    0) {
                                  printLog("Remove Api");
                                  await shortProvider.profileShortDislike(
                                      index,
                                      "3",
                                      shortProvider.profileShortList?[index].id
                                              .toString() ??
                                          "",
                                      "0",
                                      "0");
                                } else {
                                  await shortProvider.profileShortDislike(
                                      index,
                                      "3",
                                      shortProvider.profileShortList?[index].id
                                              .toString() ??
                                          "",
                                      "2",
                                      "0");
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: (shortProvider.profileShortList?[index]
                                              .isUserLikeDislike ??
                                          0) ==
                                      2
                                  ? const Iconify(
                                      Bx.bxs_dislike,
                                      size: 26,
                                      color: colorPrimary,
                                      key: ValueKey<int>(1),
                                    )
                                  : Iconify(
                                      Bx.dislike,
                                      size: 26,
                                      key: ValueKey<int>(2),
                                      color: white,
                                    ),
                            ),
                          ),
                        ),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(int.parse(shortProvider
                                    .profileShortList?[index].totalDislike
                                    .toString() ??
                                "")),
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            multilanguage: false,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 15),*/
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
                                shortProvider.profileShortList?[index].id
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
                          child: Iconify(
                            Teenyicons.message_text_alt_solid,
                            size: 20,
                            color: white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(shortProvider
                                    .profileShortList?[index].totalComment ??
                                0),
                            multilanguage: false,
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 15),
                        // Share Button
                        if (!ResponsiveHelper.isWeb(context))
                          InkWell(
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
                                final liveUrl =
                                    "Hey! I'm watching ${shortProvider.shortVideoList?[index].title ?? ""} "
                                    "on ${Constant.appName}! 🎬\n"
                                    "Watch here 👉 https://fanbae.tv/shorts?s=${shortProvider.shortVideoList?[index].channelId}/${shortProvider.shortVideoList?[index].userId}/$index/${shortProvider.shortVideoList?[index].content?.split('/')[3]}\n";
                                Utils.shareApp(liveUrl);
                              }
                            },
                            child: Column(
                              children: [
                                MyImage(
                                    width: 25,
                                    height: 25,
                                    imagePath: "ic_share.png"),
                                const SizedBox(height: 2),
                                MyText(
                                    color: white,
                                    text: "share",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: 12,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ),
                        const SizedBox(height: 15),
                        InkWell(
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
                              moreBottomSheet(
                                shortProvider.profileShortList?[index].userId
                                        .toString() ??
                                    "",
                                shortProvider.profileShortList?[index].id
                                        .toString() ??
                                    "",
                              );
                            }
                          },
                          child: MyImage(
                              width: 20, height: 20, imagePath: "ic_more.png"),
                        ),
                        const SizedBox(height: 20),

                        Constant.userID ==
                                (shortProvider.profileShortList?[index].userId
                                        .toString() ??
                                    '')
                            ? const SizedBox()
                            : Utils().circleIconWithButton(
                                circleSize: 50,
                                iconSize: 48,
                                color: white.withOpacity(0.20),
                                icon: "ic_gift.webp",
                                onTap: () {
                                  openGift(shortProvider
                                          .shortVideoList?[index].userId
                                          .toString() ??
                                      '');
                                },
                              ),
                      ],
                    ),
                  ),
                ),
                /* Channel Name, Reels Title */
                Positioned.fill(
                  bottom: 30,
                  left: 15,
                  right: 15,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* Uploded Reels User Image */

                      shortProvider.profileShortList?[index].userId != 0
                          ? InkWell(
                              onTap: ResponsiveHelper.checkIsWeb(context)
                                  ? () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              WebProfile(
                                            isProfile: false,
                                            channelUserid: shortProvider
                                                    .profileShortList?[index]
                                                    .userId
                                                    .toString() ??
                                                "",
                                            channelid: shortProvider
                                                    .profileShortList?[index]
                                                    .channelId
                                                    .toString() ??
                                                "",
                                          ),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      );
                                    }
                                  : () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return Profile(
                                              isProfile: false,
                                              channelUserid: shortProvider
                                                      .profileShortList?[index]
                                                      .userId
                                                      .toString() ??
                                                  "",
                                              channelid: shortProvider
                                                      .profileShortList?[index]
                                                      .channelId
                                                      .toString() ??
                                                  "",
                                            );
                                          },
                                        ),
                                      );
                                      setState(() {
                                        context
                                            .read<ProfileProvider>()
                                            .fetchMyProfile(context);
                                      });
                                    },
                              child: Container(
                                width: 250,
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: MyNetworkImage(
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.cover,
                                          imagePath: shortProvider
                                                  .profileShortList?[index]
                                                  .channelImage
                                                  .toString() ??
                                              ""),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: shortProvider
                                                  .profileShortList?[index]
                                                  .channelName
                                                  .toString() ==
                                              ""
                                          ? MyText(
                                              color: white,
                                              text: "guestuser",
                                              multilanguage: true,
                                              textalign: TextAlign.left,
                                              fontsizeNormal: Dimens.textTitle,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal)
                                          : MyText(
                                              color: white,
                                              text: shortProvider
                                                      .profileShortList?[index]
                                                      .channelName
                                                      .toString() ??
                                                  "",
                                              multilanguage: false,
                                              textalign: TextAlign.left,
                                              fontsizeNormal: Dimens.textTitle,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                    ),
                                    const SizedBox(width: 10),
                                    /* User Subscribe Button */
                                    Constant.userID !=
                                            shortProvider
                                                .profileShortList?[index].userId
                                                .toString()
                                        ? InkWell(
                                            onTap: () async {
                                              if (Constant.userID == null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return ResponsiveHelper
                                                              .isWeb(context)
                                                          ? const WebLogin()
                                                          : const Login();
                                                    },
                                                  ),
                                                );
                                              } else {
                                                await shortProvider
                                                    .addremoveSubscribe(
                                                        index,
                                                        shortProvider
                                                                .profileShortList?[
                                                                    index]
                                                                .userId
                                                                .toString() ??
                                                            "",
                                                        "1",
                                                        widget.shortType);
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 5, 5, 5),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: colorPrimary,
                                              ),
                                              child: MyText(
                                                  color: colorAccent,
                                                  text: shortProvider
                                                              .profileShortList?[
                                                                  index]
                                                              .isSubscribe ==
                                                          0
                                                      ? "subscribe"
                                                      : "subscribed",
                                                  multilanguage: true,
                                                  textalign: TextAlign.center,
                                                  fontsizeNormal:
                                                      Dimens.textSmall,
                                                  inter: false,
                                                  maxline: 1,
                                                  fontwaight: FontWeight.w600,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal),
                                            ),
                                          )
                                        : const SizedBox.shrink()
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
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textTitle,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              ],
                            ),
                      /* User Title */
                      Container(
                        width: 250,
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                        child: SizedBox(
                          height: 20,
                          child: MyMarqueeText(
                              text: shortProvider.profileShortList?[index].title
                                      .toString() ??
                                  "",
                              fontsize: Dimens.textMedium,
                              color: white),
                        ),
                      ),
                      /* Gif Image Music */
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Row(
                          children: [
                            MyImage(
                                width: 15,
                                height: 15,
                                imagePath: "music.png",
                                color: white),
                            const SizedBox(width: 15),
                            MyText(
                                color: white,
                                text: "originalsound",
                                textalign: TextAlign.center,
                                fontsizeNormal: 12,
                                multilanguage: true,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          /* Reels Pagination Content */
          onPageChanged: (index) async {
            if (index > 0 && (index % 2) == 0) {
              _fetchUserShort();
            }
            printLog("onPageChanged value ======> $index");
          },
        ),
        /* Back Button */
        backButton(),
        /* Create Short */
        !kIsWeb && Constant.isCreator == '1'
            ? createShortButton()
            : const SizedBox(),
      ],
    );
  }

/* WatchLater Short */
  Widget _buildWatchLaterShort() {
    return Consumer<ShortProvider>(
      builder: (context, watchlaterShortprovider, child) {
        if (watchlaterShortprovider.loading) {
          return shimmer();
        } else {
          if (watchlaterShortprovider.watchlaterShortList != null &&
              (watchlaterShortprovider.watchlaterShortList?.length ?? 0) > 0) {
            return _buildWatchLaterShortPageView();
          } else {
            return const NoPost(title: "no_posts_available", subTitle: "");
          }
        }
      },
    );
  }

  Widget _buildWatchLaterShortPageView() {
    return Stack(
      children: [
        PreloadPageView.builder(
          controller: preloadPageController,
          itemCount: shortProvider.watchlaterShortList?.length ?? 0,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            printLog("Index==>$index");
            printLog("initialindex==>${widget.initialIndex}");
            return Stack(
              children: [
                /* Reels Video */
                ReelsPlayer(
                  isLiveStream: false,
                  index: index,
                  pagePos: index,
                  thumbnailImg: shortProvider
                          .watchlaterShortList?[index].portraitImg
                          .toString() ??
                      "",
                  videoUrl: shortProvider.watchlaterShortList?[index].content
                          .toString() ??
                      "",
                ),
                /* Like, Dislike, Comment, Share and More Buttons */
                Positioned.fill(
                  bottom: 30,
                  right: 15,
                  left: 15,
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
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ResponsiveHelper.isWeb(context)
                                        ? const WebLogin()
                                        : const Login();
                                  },
                                ),
                              );
                            } else {
                              if (shortProvider
                                      .watchlaterShortList?[index].isLike ==
                                  0) {
                                Utils().showSnackBar(
                                    context, "youcannotlikethiscontent", true);
                              } else {
                                //  Call Like APi Call
                                if ((shortProvider.watchlaterShortList?[index]
                                            .isUserLikeDislike ??
                                        0) ==
                                    1) {
                                  printLog("Remove Api");
                                  await shortProvider.watchLaterShortLike(
                                      index,
                                      "3",
                                      shortProvider
                                              .watchlaterShortList?[index].id
                                              .toString() ??
                                          "",
                                      "0",
                                      "0");
                                } else {
                                  await shortProvider.watchLaterShortLike(
                                      index,
                                      "3",
                                      shortProvider
                                              .watchlaterShortList?[index].id
                                              .toString() ??
                                          "",
                                      "1",
                                      "0");
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: (shortProvider.watchlaterShortList?[index]
                                              .isUserLikeDislike ??
                                          0) ==
                                      1
                                  ? const Iconify(
                                      Bx.bxs_like,
                                      size: 26,
                                      color: colorPrimary,
                                      key: ValueKey<int>(1),
                                    )
                                  : Iconify(
                                      Bx.like,
                                      size: 26,
                                      key: ValueKey<int>(2),
                                      color: white,
                                    ),
                            ),
                          ),
                        ),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(int.parse(shortProvider
                                    .watchlaterShortList?[index].totalLike
                                    .toString() ??
                                "")),
                            multilanguage: false,
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 15),
                        // Dislike Button With Deslike Count
                        /*  InkWell(
                          onTap: () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              if (shortProvider
                                      .watchlaterShortList?[index].isLike ==
                                  0) {
                                Utils().showSnackbar(
                                    context, "youcannotlikethiscontent", true);
                              } else {
                                //  Call DisLike APi Call
                                if ((shortProvider.watchlaterShortList?[index]
                                            .isUserLikeDislike ??
                                        2) ==
                                    0) {
                                  printLog("Remove Api");
                                  await shortProvider.watchLaterShortDislike(
                                      index,
                                      "3",
                                      shortProvider
                                              .watchlaterShortList?[index].id
                                              .toString() ??
                                          "",
                                      "0",
                                      "0");
                                } else {
                                  await shortProvider.watchLaterShortDislike(
                                      index,
                                      "3",
                                      shortProvider
                                              .watchlaterShortList?[index].id
                                              .toString() ??
                                          "",
                                      "2",
                                      "0");
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: (shortProvider.watchlaterShortList?[index]
                                              .isUserLikeDislike ??
                                          0) ==
                                      2
                                  ? const Iconify(
                                      Bx.bxs_dislike,
                                      size: 26,
                                      color: colorPrimary,
                                      key: ValueKey<int>(1),
                                    )
                                  : Iconify(
                                      Bx.dislike,
                                      size: 26,
                                      key: const ValueKey<int>(2),
                                      color: white,
                                    ),
                            ),
                          ),
                        ),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(int.parse(shortProvider
                                    .watchlaterShortList?[index].totalDislike
                                    .toString() ??
                                "")),
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            multilanguage: false,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 15),*/
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
                                shortProvider.watchlaterShortList?[index].id
                                        .toString() ??
                                    "",
                                1);

                            commentBottomSheet(
                                videoid: shortProvider
                                        .watchlaterShortList?[index].id
                                        .toString() ??
                                    "",
                                index: index,
                                isShortType: "watchlater");
                          },
                          child: Iconify(
                            Teenyicons.message_text_alt_solid,
                            size: 20,
                            color: white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(shortProvider
                                    .watchlaterShortList?[index].totalComment ??
                                0),
                            multilanguage: false,
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 15),
                        // Share Button
                        if (!ResponsiveHelper.isWeb(context))
                          InkWell(
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
                                final liveUrl =
                                    "Hey! I'm watching ${shortProvider.shortVideoList?[index].title ?? ""} "
                                    "on ${Constant.appName}! 🎬\n"
                                    "Watch here 👉 https://fanbae.tv/shorts?s=${shortProvider.shortVideoList?[index].channelId}/${shortProvider.shortVideoList?[index].userId}/$index/${shortProvider.shortVideoList?[index].content?.split('/')[3]}\n";
                                Utils.shareApp(liveUrl);
                              }
                            },
                            child: Column(
                              children: [
                                MyImage(
                                    width: 25,
                                    height: 25,
                                    imagePath: "ic_share.png"),
                                const SizedBox(height: 2),
                                MyText(
                                    color: white,
                                    text: "share",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: 12,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ),

                        const SizedBox(height: 15),
                        InkWell(
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
                              moreBottomSheet(
                                shortProvider.watchlaterShortList?[index].userId
                                        .toString() ??
                                    "",
                                shortProvider.watchlaterShortList?[index].id
                                        .toString() ??
                                    "",
                              );
                            }
                          },
                          child: MyImage(
                              width: 20, height: 20, imagePath: "ic_more.png"),
                        ),
                        const SizedBox(height: 20),
                        imageDisc(
                            image: shortProvider
                                    .watchlaterShortList?[index].portraitImg
                                    .toString() ??
                                ""),
                      ],
                    ),
                  ),
                ),
                /* Channel Name, Reels Title */
                Positioned.fill(
                  bottom: 30,
                  left: 15,
                  right: 15,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* Uploded Reels User Image */

                      shortProvider.watchlaterShortList?[index].userId != 0
                          ? InkWell(
                              onTap: ResponsiveHelper.checkIsWeb(context)
                                  ? () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              WebProfile(
                                            isProfile: false,
                                            channelUserid: shortProvider
                                                    .watchlaterShortList?[index]
                                                    .userId
                                                    .toString() ??
                                                "",
                                            channelid: shortProvider
                                                    .watchlaterShortList?[index]
                                                    .channelId
                                                    .toString() ??
                                                "",
                                          ),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      );
                                    }
                                  : () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return Profile(
                                              isProfile: false,
                                              channelUserid: shortProvider
                                                      .watchlaterShortList?[
                                                          index]
                                                      .userId
                                                      .toString() ??
                                                  "",
                                              channelid: shortProvider
                                                      .watchlaterShortList?[
                                                          index]
                                                      .channelId
                                                      .toString() ??
                                                  "",
                                            );
                                          },
                                        ),
                                      );
                                      setState(() {
                                        context
                                            .read<ProfileProvider>()
                                            .fetchMyProfile(context);
                                      });
                                    },
                              child: Container(
                                width: 250,
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: MyNetworkImage(
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.cover,
                                          imagePath: shortProvider
                                                  .watchlaterShortList?[index]
                                                  .channelImage
                                                  .toString() ??
                                              ""),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: shortProvider
                                                  .watchlaterShortList?[index]
                                                  .channelName
                                                  .toString() ==
                                              ""
                                          ? MyText(
                                              color: white,
                                              text: "guestuser",
                                              multilanguage: true,
                                              textalign: TextAlign.left,
                                              fontsizeNormal: Dimens.textTitle,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal)
                                          : MyText(
                                              color: white,
                                              text: shortProvider
                                                      .watchlaterShortList?[
                                                          index]
                                                      .channelName
                                                      .toString() ??
                                                  "",
                                              multilanguage: false,
                                              textalign: TextAlign.left,
                                              fontsizeNormal: Dimens.textTitle,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                    ),
                                    const SizedBox(width: 10),
                                    /* User Subscribe Button */
                                    Constant.userID ==
                                            shortProvider
                                                .watchlaterShortList?[index]
                                                .userId
                                                .toString()
                                        ? InkWell(
                                            onTap: () async {
                                              if (Constant.userID == null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return ResponsiveHelper
                                                              .isWeb(context)
                                                          ? const WebLogin()
                                                          : const Login();
                                                    },
                                                  ),
                                                );
                                              } else {
                                                await shortProvider
                                                    .addremoveSubscribe(
                                                        index,
                                                        shortProvider
                                                                .watchlaterShortList?[
                                                                    index]
                                                                .userId
                                                                .toString() ??
                                                            "",
                                                        "1",
                                                        widget.shortType);
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 5, 5, 5),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: colorPrimary,
                                              ),
                                              child: MyText(
                                                  color: colorAccent,
                                                  text: shortProvider
                                                              .watchlaterShortList?[
                                                                  index]
                                                              .isSubscribe ==
                                                          0
                                                      ? "subscribe"
                                                      : "subscribed",
                                                  multilanguage: true,
                                                  textalign: TextAlign.center,
                                                  fontsizeNormal:
                                                      Dimens.textSmall,
                                                  inter: false,
                                                  maxline: 1,
                                                  fontwaight: FontWeight.w600,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal),
                                            ),
                                          )
                                        : const SizedBox.shrink()
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
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textTitle,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              ],
                            ),
                      /* User Title */
                      Container(
                        width: 250,
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                        child: SizedBox(
                          height: 20,
                          child: MyMarqueeText(
                              text: shortProvider
                                      .watchlaterShortList?[index].title
                                      .toString() ??
                                  "",
                              fontsize: Dimens.textMedium,
                              color: white),
                        ),
                      ),
                      /* Gif Image Music */
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Row(
                          children: [
                            MyImage(
                                width: 15,
                                height: 15,
                                imagePath: "music.png",
                                color: white),
                            const SizedBox(width: 15),
                            MyText(
                                color: white,
                                text: "originalsound",
                                textalign: TextAlign.center,
                                fontsizeNormal: 12,
                                multilanguage: true,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          /* Reels Pagination Content */
          onPageChanged: (index) async {
            if (index > 0 && (index % 2) == 0) {
              _fetchWatchLaterShort();
            }
            printLog("onPageChanged value ======> $index");
          },
        ),
        /* Back Button */
        backButton(),
        /* Create Short */
        !ResponsiveHelper.checkIsWeb(context) && Constant.isCreator == '1'
            ? createShortButton()
            : const SizedBox(),
      ],
    );
  }

  Widget shimmer() {
    return Stack(
      children: [
        PageView.builder(
          itemCount: 1,
          scrollDirection: Axis.vertical,
          allowImplicitScrolling: true,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: appbgcolor,
                ),
                const Positioned.fill(
                  bottom: 30,
                  right: 20,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomWidget.circular(
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(height: 10),
                        CustomWidget.roundrectborder(
                          width: 30,
                          height: 15,
                        ),
                        SizedBox(height: 20),
                        CustomWidget.circular(
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(height: 10),
                        CustomWidget.roundrectborder(
                          width: 30,
                          height: 15,
                        ),
                        SizedBox(height: 20),
                        CustomWidget.circular(
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(height: 10),
                        CustomWidget.roundrectborder(
                          width: 30,
                          height: 15,
                        ),
                        SizedBox(height: 20),
                        CustomWidget.circular(
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(height: 10),
                        CustomWidget.roundrectborder(
                          width: 30,
                          height: 15,
                        ),
                        SizedBox(height: 20),
                        CustomWidget.circular(
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(height: 20),
                        CustomWidget.roundrectborder(
                          width: 45,
                          height: 45,
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned.fill(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomWidget.roundcorner(
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(width: 10),
                          CustomWidget.roundrectborder(
                            width: 150,
                            height: 15,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      CustomWidget.roundrectborder(
                        width: 200,
                        height: 15,
                      ),
                      CustomWidget.roundrectborder(
                        width: 200,
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          onPageChanged: (index) async {},
        ),
      ],
    );
  }

/* Comment Bottom Sheet */
  commentBottomSheet(
      {required int index, required videoid, required isShortType}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: MediaQuery.of(context).size.height,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Wrap(
            children: [
              buildComment(index, videoid, isShortType),
            ],
          ),
        );
      },
    ).whenComplete(() {
      log("comment Back");
      commentController.clear();
      shortProvider.clearComment();
    });
  }

/* Build Comment List */
  Widget buildComment1(index, dynamic videoid, isShortType) {
    return kIsWeb
        ? Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            backgroundColor: colorPrimaryDark,
            child: Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              constraints: const BoxConstraints(
                minWidth: 700,
                maxWidth: double.infinity,
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
                                if ((shortProvider.commentList?.length ?? 0) >
                                    0) {
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
                                            itemCount: commentprovider
                                                    .commentList?.length ??
                                                0,
                                            itemBuilder:
                                                (BuildContext ctx, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 10, 0, 10),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              1),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          border: Border.all(
                                                              width: 1,
                                                              color: white)),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
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
                                                            CrossAxisAlignment
                                                                .start,
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
                                                                  Dimens
                                                                      .textMedium,
                                                              fontsizeWeb: Dimens
                                                                  .textMedium,
                                                              fontwaight:
                                                                  FontWeight
                                                                      .w500,
                                                              multilanguage:
                                                                  false,
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
                                                          const SizedBox(
                                                              height: 8),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
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
                                                                fontsizeNormal: Dimens
                                                                    .textSmall,
                                                                fontsizeWeb: Dimens
                                                                    .textSmall,
                                                                fontwaight:
                                                                    FontWeight
                                                                        .w400,
                                                                multilanguage:
                                                                    false,
                                                                maxline: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                inter: false,
                                                                textalign:
                                                                    TextAlign
                                                                        .left,
                                                                fontstyle:
                                                                    FontStyle
                                                                        .normal),
                                                          ),
                                                          const SizedBox(
                                                              height: 7),
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                onTap:
                                                                    () async {
                                                                  shortProvider.storeReplayCommentId(shortProvider
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
                                                                              .commentList?[index]
                                                                              .comment
                                                                              .toString() ??
                                                                          "",
                                                                      isShortType);

                                                                  await shortProvider.getReplayComment(
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
                                                                              color: gray,
                                                                              text: "seeall",
                                                                              fontsizeNormal: Dimens.textSmall,
                                                                              fontsizeWeb: Dimens.textSmall,
                                                                              fontwaight: FontWeight.w400,
                                                                              multilanguage: true,
                                                                              maxline: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              inter: false,
                                                                              textalign: TextAlign.center,
                                                                              fontstyle: FontStyle.normal),
                                                                          const SizedBox(
                                                                              width: 5),
                                                                          MyText(
                                                                              color: gray,
                                                                              text: Utils.kmbGenerator(int.parse(
                                                                                commentprovider.commentList?[index].totalReply.toString() ?? "",
                                                                              )),
                                                                              fontsizeNormal: Dimens.textSmall,
                                                                              fontsizeWeb: Dimens.textSmall,
                                                                              fontwaight: FontWeight.w400,
                                                                              multilanguage: false,
                                                                              maxline: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              inter: false,
                                                                              textalign: TextAlign.center,
                                                                              fontstyle: FontStyle.normal),
                                                                          const SizedBox(
                                                                              width: 5),
                                                                          MyText(
                                                                              color: gray,
                                                                              text: "comments",
                                                                              fontsizeNormal: Dimens.textSmall,
                                                                              fontsizeWeb: Dimens.textSmall,
                                                                              fontwaight: FontWeight.w400,
                                                                              multilanguage: true,
                                                                              maxline: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              inter: false,
                                                                              textalign: TextAlign.center,
                                                                              fontstyle: FontStyle.normal),
                                                                        ],
                                                                      )
                                                                    : MyText(
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
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              if (commentprovider
                                                                      .commentList?[
                                                                          index]
                                                                      .userId
                                                                      .toString() ==
                                                                  Constant
                                                                      .userID)
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
                                                                      strokeWidth:
                                                                          1,
                                                                    ),
                                                                  )
                                                                else
                                                                  InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      await shortProvider.getDeleteComment(
                                                                          commentprovider.commentList?[index].id.toString() ??
                                                                              "",
                                                                          true,
                                                                          index,
                                                                          isShortType);
                                                                    },
                                                                    child: MyImage(
                                                                        width:
                                                                            15,
                                                                        height:
                                                                            15,
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
                            scrollPhysics:
                                const AlwaysScrollableScrollPhysics(),
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
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          const WebLogin(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            } else if (commentController.text.isEmpty) {
                              Utils().showToast("Please Enter Your Comment");
                            } else {
                              if (shortProvider
                                          .shortVideoList?[index].isComment ==
                                      0 &&
                                  isShortType == "short") {
                                Utils().showSnackBar(context,
                                    "youcannotcommentthiscontent", true);
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
          )
        : AnimatedPadding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            duration: const Duration(milliseconds: 100),
            curve: Curves.decelerate,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              width: MediaQuery.of(context).size.width,
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
                              fontsizeNormal: 15,
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
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Column(
                        children: [
                          Consumer<ShortProvider>(
                              builder: (context, commentprovider, child) {
                            if (shortProvider.commentloading &&
                                !shortProvider.commentLoadmore) {
                              return Utils.pageLoader(context);
                            } else {
                              if (shortProvider.getcommentModel.status == 200 &&
                                  shortProvider.commentList != null) {
                                if ((shortProvider.commentList?.length ?? 0) >
                                    0) {
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
                                            itemCount: commentprovider
                                                    .commentList?.length ??
                                                0,
                                            itemBuilder:
                                                (BuildContext ctx, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 10, 0, 10),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              1),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          border: Border.all(
                                                              width: 1,
                                                              color: white)),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        child: MyNetworkImage(
                                                            imagePath: commentprovider
                                                                    .commentList?[
                                                                        index]
                                                                    .image
                                                                    .toString() ??
                                                                "",
                                                            fit: BoxFit.fill,
                                                            width: 25,
                                                            height: 25),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        commentprovider
                                                                    .commentList?[
                                                                        index]
                                                                    .channelName
                                                                    .toString() ==
                                                                ""
                                                            ? MyText(
                                                                color: white,
                                                                text:
                                                                    "guestuser",
                                                                fontsizeNormal: Dimens
                                                                    .textTitle,
                                                                fontwaight:
                                                                    FontWeight
                                                                        .w500,
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
                                                                        .normal)
                                                            : MyText(
                                                                color: white,
                                                                text: commentprovider
                                                                        .commentList?[
                                                                            index]
                                                                        .channelName
                                                                        .toString() ??
                                                                    "",
                                                                fontsizeNormal:
                                                                    Dimens
                                                                        .textTitle,
                                                                fontwaight:
                                                                    FontWeight
                                                                        .w500,
                                                                multilanguage:
                                                                    false,
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
                                                        const SizedBox(
                                                            height: 8),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
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
                                                                  Dimens
                                                                      .textMedium,
                                                              fontwaight:
                                                                  FontWeight
                                                                      .w400,
                                                              multilanguage:
                                                                  false,
                                                              maxline: 10,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              inter: false,
                                                              textalign:
                                                                  TextAlign
                                                                      .left,
                                                              fontstyle:
                                                                  FontStyle
                                                                      .normal),
                                                        ),
                                                        const SizedBox(
                                                            height: 7),
                                                        Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () async {
                                                                shortProvider.storeReplayCommentId(
                                                                    shortProvider
                                                                            .commentList?[index]
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
                                                                            .commentList?[index]
                                                                            .comment
                                                                            .toString() ??
                                                                        "",
                                                                    isShortType);

                                                                await shortProvider.getReplayComment(
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
                                                                            fontsizeNormal: Dimens
                                                                                .textSmall,
                                                                            fontwaight: FontWeight
                                                                                .w400,
                                                                            multilanguage:
                                                                                true,
                                                                            maxline:
                                                                                1,
                                                                            overflow: TextOverflow
                                                                                .ellipsis,
                                                                            inter:
                                                                                false,
                                                                            textalign:
                                                                                TextAlign.center,
                                                                            fontstyle: FontStyle.normal),
                                                                        const SizedBox(
                                                                            width:
                                                                                5),
                                                                        MyText(
                                                                            color:
                                                                                gray,
                                                                            text: Utils.kmbGenerator(int
                                                                                .parse(
                                                                              commentprovider.commentList?[index].totalReply.toString() ?? "",
                                                                            )),
                                                                            fontsizeNormal: Dimens
                                                                                .textSmall,
                                                                            fontwaight: FontWeight
                                                                                .w400,
                                                                            multilanguage:
                                                                                false,
                                                                            maxline:
                                                                                1,
                                                                            overflow: TextOverflow
                                                                                .ellipsis,
                                                                            inter:
                                                                                false,
                                                                            textalign:
                                                                                TextAlign.center,
                                                                            fontstyle: FontStyle.normal),
                                                                        const SizedBox(
                                                                            width:
                                                                                5),
                                                                        MyText(
                                                                            color:
                                                                                gray,
                                                                            text:
                                                                                "comments",
                                                                            fontsizeNormal: Dimens
                                                                                .textSmall,
                                                                            fontwaight: FontWeight
                                                                                .w400,
                                                                            multilanguage:
                                                                                true,
                                                                            maxline:
                                                                                1,
                                                                            overflow: TextOverflow
                                                                                .ellipsis,
                                                                            inter:
                                                                                false,
                                                                            textalign:
                                                                                TextAlign.center,
                                                                            fontstyle: FontStyle.normal),
                                                                      ],
                                                                    )
                                                                  : MyText(
                                                                      color:
                                                                          gray,
                                                                      text:
                                                                          "seeall",
                                                                      fontsizeNormal: Dimens
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
                                                                    strokeWidth:
                                                                        1,
                                                                  ),
                                                                )
                                                              else
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    await shortProvider.getDeleteComment(
                                                                        commentprovider.commentList?[index].id.toString() ??
                                                                            "",
                                                                        true,
                                                                        index,
                                                                        isShortType);
                                                                  },
                                                                  child: MyImage(
                                                                      width: 15,
                                                                      height:
                                                                          15,
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
                                  return Align(
                                    alignment: Alignment.center,
                                    child: MyImage(
                                      width: 130,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.40,
                                      fit: BoxFit.contain,
                                      imagePath: Constant.darkMode == 'true'
                                          ? "nodata.png"
                                          : "noDataWhiteTheme.png",
                                    ),
                                  );
                                }
                              } else {
                                return Align(
                                  alignment: Alignment.center,
                                  child: MyImage(
                                    width: 130,
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    fit: BoxFit.contain,
                                    imagePath: Constant.darkMode == 'true'
                                        ? "nodata.png"
                                        : "noDataWhiteTheme.png",
                                  ),
                                );
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
                    // height: 50,
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 20),
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
                              scrollPhysics:
                                  const AlwaysScrollableScrollPhysics(),
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
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const Login();
                                    },
                                  ),
                                );
                              } else if (commentController.text.isEmpty) {
                                Utils().showToast("Please Enter Your Comment");
                              } else {
                                if (isShortType == "short" &&
                                    shortProvider
                                            .shortVideoList?[index].isComment ==
                                        0) {
                                  Utils().showSnackBar(context,
                                      "youcannotcommentthiscontent", true);
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
                            child: Consumer<ShortProvider>(
                              builder: (context, commentprovider, child) {
                                if (commentprovider.addcommentloading) {
                                  return const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: colorPrimary,
                                      strokeWidth: 1,
                                    ),
                                  );
                                } else {
                                  return Icon(
                                    Icons.send_outlined,
                                    color: white,
                                    size: 25,
                                  );
                                }
                              },
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

  /* kIsWeb
  ? Dialog(
  shape:
  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  clipBehavior: Clip.antiAliasWithSaveLayer,
  backgroundColor: colorPrimaryDark,
  child: Container(
  width: MediaQuery.of(context).size.width,
  alignment: Alignment.center,
  constraints: const BoxConstraints(
  minWidth: 700,
  maxWidth: double.infinity,
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
  if ((shortProvider.commentList?.length ?? 0) >
  0) {
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
  itemCount: commentprovider
      .commentList?.length ??
  0,
  itemBuilder:
  (BuildContext ctx, index) {
  return Padding(
  padding:
  const EdgeInsets.fromLTRB(
  0, 10, 0, 10),
  child: Row(
  crossAxisAlignment:
  CrossAxisAlignment.start,
  mainAxisAlignment:
  MainAxisAlignment.start,
  children: [
  Container(
  padding:
  const EdgeInsets.all(
  1),
  decoration: BoxDecoration(
  borderRadius:
  BorderRadius
      .circular(50),
  border: Border.all(
  width: 1,
  color: white)),
  child: ClipRRect(
  borderRadius:
  BorderRadius
      .circular(50),
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
  CrossAxisAlignment
      .start,
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
  Dimens
      .textMedium,
  fontsizeWeb: Dimens
      .textMedium,
  fontwaight:
  FontWeight
      .w500,
  multilanguage:
  false,
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
  const SizedBox(
  height: 8),
  SizedBox(
  width: MediaQuery.of(
  context)
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
  fontsizeNormal: Dimens
      .textSmall,
  fontsizeWeb: Dimens
      .textSmall,
  fontwaight:
  FontWeight
      .w400,
  multilanguage:
  false,
  maxline: 3,
  overflow:
  TextOverflow
      .ellipsis,
  inter: false,
  textalign:
  TextAlign
      .left,
  fontstyle:
  FontStyle
      .normal),
  ),
  const SizedBox(
  height: 7),
  Row(
  children: [
  InkWell(
  onTap:
  () async {
  shortProvider.storeReplayCommentId(shortProvider
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
      .commentList?[index]
      .comment
      .toString() ??
  "",
  isShortType);

  await shortProvider.getReplayComment(
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
  color: gray,
  text: "seeall",
  fontsizeNormal: Dimens.textSmall,
  fontsizeWeb: Dimens.textSmall,
  fontwaight: FontWeight.w400,
  multilanguage: true,
  maxline: 1,
  overflow: TextOverflow.ellipsis,
  inter: false,
  textalign: TextAlign.center,
  fontstyle: FontStyle.normal),
  const SizedBox(
  width: 5),
  MyText(
  color: gray,
  text: Utils.kmbGenerator(int.parse(
  commentprovider.commentList?[index].totalReply.toString() ?? "",
  )),
  fontsizeNormal: Dimens.textSmall,
  fontsizeWeb: Dimens.textSmall,
  fontwaight: FontWeight.w400,
  multilanguage: false,
  maxline: 1,
  overflow: TextOverflow.ellipsis,
  inter: false,
  textalign: TextAlign.center,
  fontstyle: FontStyle.normal),
  const SizedBox(
  width: 5),
  MyText(
  color: gray,
  text: "comments",
  fontsizeNormal: Dimens.textSmall,
  fontsizeWeb: Dimens.textSmall,
  fontwaight: FontWeight.w400,
  multilanguage: true,
  maxline: 1,
  overflow: TextOverflow.ellipsis,
  inter: false,
  textalign: TextAlign.center,
  fontstyle: FontStyle.normal),
  ],
  )
      : MyText(
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
  ),
  const SizedBox(
  width: 10),
  if (commentprovider
      .commentList?[
  index]
      .userId
      .toString() ==
  Constant
      .userID)
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
  strokeWidth:
  1,
  ),
  )
  else
  InkWell(
  onTap:
  () async {
  await shortProvider.getDeleteComment(
  commentprovider.commentList?[index].id.toString() ??
  "",
  true,
  index,
  isShortType);
  },
  child: MyImage(
  width:
  15,
  height:
  15,
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
  scrollPhysics:
  const AlwaysScrollableScrollPhysics(),
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
  pageBuilder:
  (context, animation1, animation2) =>
  const WebLogin(),
  transitionDuration: Duration.zero,
  reverseTransitionDuration: Duration.zero,
  ),
  );
  } else if (commentController.text.isEmpty) {
  Utils().showToast("Please Enter Your Comment");
  } else {
  if (shortProvider
      .shortVideoList?[index].isComment ==
  0 &&
  isShortType == "short") {
  Utils().showSnackBar(context,
  "youcannotcommentthiscontent", true);
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
  )
      :*/

  Widget buildComment(index, dynamic videoid, isShortType) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        constraints: BoxConstraints(
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        width: MediaQuery.of(context).size.width,
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
                        fontsizeNormal: 15,
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
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  children: [
                    Consumer<ShortProvider>(
                        builder: (context, commentprovider, child) {
                      if (shortProvider.commentloading &&
                          !shortProvider.commentLoadmore) {
                        return Utils.pageLoader(context);
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
                                      reverse: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          commentprovider.commentList?.length ??
                                              0,
                                      itemBuilder: (BuildContext ctx, index) {
                                        final comment =
                                            commentprovider.commentList![index];
                                        final commentId = comment.id.toString();

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                      imagePath: comment.image
                                                          .toString(),
                                                      fit: BoxFit.fill,
                                                      width: 25,
                                                      height: 25),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.47,
                                                          child: MyText(
                                                              color: white,
                                                              text: comment
                                                                          .channelName
                                                                          .toString() ==
                                                                      ""
                                                                  ? "guestuser"
                                                                  : comment
                                                                      .channelName
                                                                      .toString(),
                                                              fontsizeNormal: Dimens
                                                                  .textTitle,
                                                              fontwaight: FontWeight
                                                                  .w500,
                                                              multilanguage:
                                                                  false,
                                                              maxline: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              inter: false,
                                                              textalign:
                                                                  TextAlign
                                                                      .start,
                                                              fontstyle:
                                                                  FontStyle
                                                                      .normal),
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
                                                          textalign:
                                                              TextAlign.left,
                                                          multilanguage: false,
                                                          fontsizeNormal: 10,
                                                          inter: false,
                                                          maxline: 1,
                                                          fontwaight:
                                                              FontWeight.w400,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontstyle:
                                                              FontStyle.normal,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.70,
                                                      child: MyText(
                                                          color: white,
                                                          text: comment.comment
                                                              .toString(),
                                                          fontsizeNormal:
                                                              Dimens.textMedium,
                                                          fontwaight:
                                                              FontWeight.w400,
                                                          multilanguage: false,
                                                          maxline: 10,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          inter: false,
                                                          textalign:
                                                              TextAlign.left,
                                                          fontstyle:
                                                              FontStyle.normal),
                                                    ),
                                                    const SizedBox(height: 7),
                                                    InkWell(
                                                        onTap: () async {
                                                          print(commentId);
                                                          shortProvider
                                                              .storeReplayCommentId(
                                                                  commentId);

                                                          WidgetsBinding
                                                              .instance
                                                              .addPostFrameCallback(
                                                                  (_) {
                                                            if (textFieldKey
                                                                    .currentContext !=
                                                                null) {
                                                              FocusScope.of(
                                                                      textFieldKey
                                                                          .currentContext!)
                                                                  .requestFocus(
                                                                      commentFocusNode);
                                                            }
                                                          });
                                                        },
                                                        child: MyText(
                                                            color: gray,
                                                            text: "Reply",
                                                            fontsizeNormal:
                                                                Dimens
                                                                    .textSmall,
                                                            fontwaight:
                                                                FontWeight.w400,
                                                            multilanguage:
                                                                false,
                                                            maxline: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            inter: false,
                                                            textalign: TextAlign
                                                                .center,
                                                            fontstyle: FontStyle
                                                                .normal)),
                                                    if ((comment.isReply ?? 0) >
                                                        0)
                                                      InkWell(
                                                        onTap: () =>
                                                            shortProvider
                                                                .toggleReplies(
                                                                    commentId),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 15,
                                                                  top: 5),
                                                          child: MyText(
                                                            color: colorAccent,
                                                            text: shortProvider
                                                                    .isRepliesExpanded(
                                                                        commentId)
                                                                ? "Hide replies"
                                                                : "View replies",
                                                            fontsizeNormal:
                                                                Dimens
                                                                    .textSmall,
                                                            multilanguage:
                                                                false,
                                                            textalign:
                                                                TextAlign.left,
                                                            inter: false,
                                                            maxline: 5,
                                                            fontwaight:
                                                                FontWeight.w400,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontstyle: FontStyle
                                                                .normal,
                                                          ),
                                                        ),
                                                      ),

                                                    // ----------------- Replies Section -----------------
                                                    if (shortProvider
                                                        .isRepliesExpanded(
                                                            commentId))
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        child: Column(
                                                          children: [
                                                            // Show loader while fetching replies
                                                            if (shortProvider
                                                                .replaycommentloding)
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              )
                                                            else
                                                              Builder(
                                                                builder: (_) {
                                                                  final replies =
                                                                      shortProvider
                                                                          .getReplies(
                                                                              commentId);

                                                                  if (replies
                                                                      .isEmpty) {
                                                                    return const NoData();
                                                                  }
                                                                  return ListView
                                                                      .builder(
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        const NeverScrollableScrollPhysics(),
                                                                    reverse:
                                                                        true,
                                                                    itemCount:
                                                                        replies
                                                                            .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            replyIndex) {
                                                                      // ✅ safeguard to prevent RangeError
                                                                      if (replyIndex <
                                                                              0 ||
                                                                          replyIndex >=
                                                                              replies.length) {
                                                                        return const SizedBox
                                                                            .shrink();
                                                                      }

                                                                      final reply =
                                                                          replies[
                                                                              replyIndex];

                                                                      return Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            CircleAvatar(
                                                                              radius: 15,
                                                                              backgroundImage: NetworkImage(reply.image ?? ""),
                                                                            ),
                                                                            const SizedBox(width: 10),
                                                                            Expanded(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      SizedBox(
                                                                                        width: 120,
                                                                                        child: MyText(
                                                                                          color: white,
                                                                                          text: reply.fullName ?? "",
                                                                                          fontsizeNormal: Dimens.textSmall,
                                                                                          multilanguage: false,
                                                                                          textalign: TextAlign.left,
                                                                                          inter: false,
                                                                                          maxline: 1,
                                                                                          fontwaight: FontWeight.w400,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                          fontstyle: FontStyle.normal,
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(width: 10),
                                                                                      MyText(
                                                                                        color: white,
                                                                                        text: Utils.timeAgoCustom(
                                                                                          DateTime.parse(reply.createdAt ?? ""),
                                                                                        ),
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
                                                                                  MyText(
                                                                                    color: white,
                                                                                    text: reply.comment ?? "",
                                                                                    fontsizeNormal: Dimens.textSmall,
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
                                                                                  await shortProvider.getDeleteComment(
                                                                                    reply.id.toString(),
                                                                                    false,
                                                                                    index,
                                                                                    isShortType,
                                                                                  );
                                                                                  shortProvider.deleteReply(
                                                                                    commentId,
                                                                                    reply.id ?? 0,
                                                                                  );
                                                                                },
                                                                                child: MyImage(
                                                                                  width: 15,
                                                                                  height: 15,
                                                                                  imagePath: "ic_delete.png",
                                                                                ),
                                                                              ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            const Divider(
                                                                color: gray),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              if (comment.userId.toString() ==
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
                                                      color: colorPrimary,
                                                      strokeWidth: 1,
                                                    ),
                                                  )
                                                else
                                                  InkWell(
                                                    onTap: () async {
                                                      await shortProvider
                                                          .getDeleteComment(
                                                              commentId,
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
                                                const SizedBox.shrink(),
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
                            return Align(
                              alignment: Alignment.center,
                              child: MyImage(
                                width: 130,
                                height:
                                    MediaQuery.of(context).size.height * 0.40,
                                fit: BoxFit.contain,
                                imagePath: Constant.darkMode == 'true'
                                    ? "nodata.png"
                                    : "noDataWhiteTheme.png",
                              ),
                            );
                          }
                        } else {
                          return Align(
                            alignment: Alignment.center,
                            child: MyImage(
                              width: 130,
                              height: MediaQuery.of(context).size.height * 0.35,
                              fit: BoxFit.contain,
                              imagePath: Constant.darkMode == 'true'
                                  ? "nodata.png"
                                  : "noDataWhiteTheme.png",
                            ),
                          );
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
              // height: 50,
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
              alignment: Alignment.center,
              child: Center(
                child: Consumer<ShortProvider>(
                  builder: (context, commentProvider, child) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: textFieldKey,
                            controller: commentController,
                            focusNode: commentFocusNode,
                            maxLines: 1,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: transparent,
                              border: InputBorder.none,
                              hintText:
                                  commentProvider.replyingToCommentId != null
                                      ? "Add a reply"
                                      : "Add comment",
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: white,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        InkWell(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else if (commentController.text.isEmpty) {
                              Utils().showToast("Please Enter Your Comment");
                            } else {
                              if (isShortType == "short" &&
                                  shortProvider
                                          .shortVideoList?[index].isComment ==
                                      0) {
                                Utils().showSnackBar(context,
                                    "youcannotcommentthiscontent", true);
                                Navigator.pop(context);
                              } else {
                                print(shortProvider.replyingToCommentId ??
                                    'no data');
                                if (shortProvider.replyingToCommentId != null) {
                                  // Send reply API
                                  await shortProvider.getaddReplayComment(
                                    "3",
                                    videoid,
                                    "0",
                                    commentController.text,
                                    shortProvider.replyingToCommentId ?? "0",
                                  );
                                  _fetchReplayCommentData(
                                      shortProvider.replayCommentId,
                                      shortProvider.currentPageReplayComment ??
                                          0);
                                  if (shortProvider.replayCommentModel.status ==
                                      200) {
                                    shortProvider.expandedReplies.add(
                                        shortProvider.replyingToCommentId ??
                                            "0");
                                  }

                                  //shortProvider.notifyListeners();
                                } else {
                                  // New comment
                                  await shortProvider.getaddcomment(
                                    index,
                                    "3",
                                    videoid,
                                    "0",
                                    commentController.text,
                                    "0",
                                    widget.shortType,
                                  );
                                }

                                commentController.clear();
                                shortProvider.clearReply();
                                FocusScope.of(context).unfocus();
                              }
                            }
                          },
                          child: Consumer<ShortProvider>(
                            builder: (context, commentprovider, child) {
                              if (commentprovider.addcommentloading) {
                                return const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: colorPrimary,
                                    strokeWidth: 1,
                                  ),
                                );
                              } else {
                                return Icon(
                                  Icons.send_outlined,
                                  color: white,
                                  size: 25,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

/* More Button Bottom Sheet */
  moreBottomSheet(reportUserid, contentid) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: colorPrimaryDark,
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.shortType == "watchlater"
                      ? const SizedBox.shrink()
                      : Utils.moreFunctionItem(
                          "ic_watchlater.png", "savetowatchlater", () async {
                          await shortProvider.addremoveWatchLater(
                              "3", contentid, "0", "1");
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          Utils()
                              .showSnackBar(context, "savetowatchlater", true);
                        }),
                  Utils.moreFunctionItem("report.png", "report", () async {
                    Navigator.pop(context);
                    _fetchReportReason(0);
                    reportBottomSheet(reportUserid, contentid);
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchGift(int? nextPage) async {
    await liveStreamProvider.getProfile(context, widget.userId);
    await liveStreamProvider.fetchGift((nextPage ?? 0) + 1);
  }

  void openGift(userId) {
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
                              print(userId);
                              return GestureDetector(
                                onTap: () async {
                                  SuccessModel success = await ApiService()
                                      .sendGift(
                                          userId,
                                          livestreamprovider
                                              .giftList?[index].id);
                                  Navigator.pop(context);
                                  if (success.status == 200) {
                                    if (context.mounted) {
                                      Provider.of<ProfileProvider>(context,
                                              listen: false)
                                          .fetchMyProfile(context);
                                    }
                                    showGeneralDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      barrierLabel: '',
                                      transitionDuration:
                                          const Duration(milliseconds: 500),
                                      // animation duration
                                      pageBuilder: (context, anim1, anim2) {
                                        // Auto close after 3 seconds
                                        Future.delayed(
                                            const Duration(seconds: 3), () {
                                          if (Navigator.canPop(context)) {
                                            Navigator.pop(context);
                                          }
                                        });
                                        return Align(
                                          alignment: const Alignment(0, 0.4),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: ScaleTransition(
                                              scale: CurvedAnimation(
                                                parent: anim1,
                                                curve: Curves.easeOutBack,
                                                reverseCurve: Curves.easeInBack,
                                              ),
                                              child: Dialog(
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: AspectRatio(
                                                  aspectRatio: 1.8,
                                                  child: Container(
                                                    decoration: ShapeDecoration(
                                                        shape: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        color: Colors.white),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        MyNetworkImage(
                                                          width: 45,
                                                          height: 45,
                                                          imagePath:
                                                              livestreamprovider
                                                                      .giftList?[
                                                                          index]
                                                                      .image
                                                                      .toString() ??
                                                                  "",
                                                          fit: BoxFit.cover,
                                                        ),
                                                        MyText(
                                                          text:
                                                              'Your Gift has been sent',
                                                          color: pureBlack,
                                                          multilanguage: false,
                                                        ),
                                                        ShaderMask(
                                                          shaderCallback: (bounds) =>
                                                              const LinearGradient(
                                                            colors: [
                                                              Colors.green,
                                                              Colors.green
                                                            ],
                                                          ).createShader(
                                                                  Rect.fromLTWH(
                                                                      0,
                                                                      0,
                                                                      bounds
                                                                          .width,
                                                                      bounds
                                                                          .height)),
                                                          child: MyText(
                                                            text:
                                                                'Successfully',
                                                            multilanguage:
                                                                false,
                                                            color: white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      transitionBuilder:
                                          (context, anim1, anim2, child) {
                                        return FadeTransition(
                                          opacity: CurvedAnimation(
                                            parent: anim1,
                                            curve: Curves.easeInOut,
                                          ),
                                          child: child,
                                        );
                                      },
                                    );
                                  } else {
                                    Utils().showSnackBar(
                                        context, success.message ?? '', false);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color: colorPrimary,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: colorPrimary),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                          borderRadius:
                                              BorderRadius.circular(6),
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
                                      Container(
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
                                    ],
                                  ),
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

/* Report Reason Bottom Sheet */
  reportBottomSheet(reportUserid, contentid) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: transparent,
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(15),
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.50,
            decoration: BoxDecoration(
              color: colorPrimaryDark,
              borderRadius: BorderRadius.circular(10),
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
                              pageBuilder: (context, animation1, animation2) =>
                                  const Login(),
                            ),
                          );
                        } else {
                          if (shortProvider.reasonId == "" ||
                              shortProvider.reasonId.isEmpty) {
                            Utils().showSnackBar(
                                context, "pleaseselectyourreportreason", true);
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
          );
        });
      },
    );
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
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
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
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        constraints: BoxConstraints(
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        width: MediaQuery.of(context).size.width,
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
                            MaterialPageRoute(
                              builder: (context) {
                                return const Login();
                              },
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
                                  color: white,
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
          return Column(
            children: [
              // replayCommentList(isShortPage),
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

  /*Widget replayCommentList(isShortPage) {
    if (shortProvider.replayCommentModel.status == 200) {
      if ((shortProvider.replaycommentList.length ?? 0) > 0) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: shortProvider.replaycommentList.length ?? 0,
                  itemBuilder: (BuildContext ctx, index) {
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
                                  imagePath: shortProvider
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
                                shortProvider.replaycommentList?[index].fullName ==
                                        ""
                                    ? MyText(
                                        color: white,
                                        text: shortProvider
                                                .replaycommentList?[index]
                                                .fullName
                                                .toString() ??
                                            "",
                                        fontsizeNormal: Dimens.textDesc,
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
                                                .replaycommentList?[index]
                                                .channelName
                                                .toString() ??
                                            "",
                                        fontsizeNormal: Dimens.textMedium,
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
                                      color: gray,
                                      text: shortProvider
                                              .replaycommentList?[index].comment
                                              .toString() ??
                                          "",
                                      fontsizeNormal: Dimens.textSmall,
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
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const Login();
                                        },
                                      ),
                                    );
                                  } else {
                                    await shortProvider.getDeleteComment(
                                        shortProvider
                                                .replaycommentList?[index].id
                                                .toString() ??
                                            "",
                                        false,
                                        index,
                                        isShortPage);
                                  }
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: colorPrimary),
                                  child: MyText(
                                      color: white,
                                      text: "delete",
                                      fontsizeNormal: Dimens.textSmall,
                                      fontwaight: FontWeight.w400,
                                      multilanguage: true,
                                      maxline: 3,
                                      overflow: TextOverflow.ellipsis,
                                      inter: false,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal),
                                ),
                              )
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
        return const Expanded(child: NoData(title: "", subTitle: ""));
      }
    } else {
      return const Expanded(child: NoData(title: "", subTitle: ""));
    }
  }*/

  Widget createShortButton() {
    return const SizedBox();
/*    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
          child: InkWell(
            onTap: () {
              if (Constant.userID == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const Login();
                    },
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const CreateReels();
                    },
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  gradient: Constant.gradientColor, shape: BoxShape.circle),
              child: const Icon(
                Icons.add,
                size: 22,
                color: pureBlack,
              ),
            ),
          ),
        ),
      ),
    );*/
  }

  Widget imageDisc({required String image}) {
    return RotationTransition(
      turns: _controller,
      child: Material(
        elevation: 10,
        shadowColor: gray,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          height: 50,
          width: 50,
          padding: const EdgeInsets.all(3.5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xff0febf7),
                Color(0xFF01DED1),
                Color(0xffd64ea3),
                Color(0xff5500ff),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: MyNetworkImage(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              imagePath: image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget backButton() {
    return Positioned.fill(
      top: 60,
      left: 20,
      right: 20,
      child: Align(
          alignment: Alignment.topLeft,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop(false);
            },
            child: Utils.backIcon(),
          )),
    );
  }
}
