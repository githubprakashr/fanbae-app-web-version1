import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:fanbae/pages/showpostcontent.dart';
import 'package:fanbae/pages/uploadfeed.dart';
import 'package:fanbae/pages/viewmembershipplan.dart';
import 'package:fanbae/pages/cookie_splash_page.dart';
import 'package:fanbae/utils/adhelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:fanbae/widget/customappbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/teenyicons.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:fanbae/pages/login.dart';
import 'package:fanbae/pages/profile.dart';
import 'package:fanbae/provider/feedprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';

import '../model/successmodel.dart';
import '../provider/detailsprovider.dart';
import '../provider/generalprovider.dart';
import '../provider/homeprovider.dart';
import '../provider/musicdetailprovider.dart';
import '../provider/profileprovider.dart';
import '../utils/musicmanager.dart';
import '../utils/sharedpre.dart';
import '../video_audio_call/videocallmanager.dart';
import '../webpages/webdetail.dart';
import '../webpages/weblogin.dart';
import '../webpages/webprofile.dart';
import '../webservice/apiservice.dart';
import '../webservice/socketmanager.dart';
import '../widget/musictitle.dart';
import 'package:fanbae/model/feedslistmodel.dart' as feed;

import 'contentdetail.dart';

class Feeds extends StatefulWidget {
  final int? openPostIndex;

  const Feeds({super.key, this.openPostIndex});

  @override
  State<Feeds> createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  SharedPre sharePref = SharedPre();
  late FeedProvider feedProvider;
  late HomeProvider homeProvider;
  late DetailsProvider detailsProvider;
  late ScrollController _scrollController;
  late ScrollController _commentScrollController;
  late ScrollController _replayCommentScrollController;
  late ScrollController _reportScrollController;
  late ScrollController playlistController;
  late ScrollController reportReasonController;
  final playlistTitleController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  String _selectedFeed = 'for_you';
  final MusicManager musicManager = MusicManager();
  bool _showTopWidgets = true;
  late ProfileProvider profileProvider;
  late GeneralProvider generalProvider;
  late SocketManager socketManager;
  final VideoCallManager _videoCallManager = VideoCallManager();
  final FocusNode commentFocusNode = FocusNode();
  final GlobalKey textFieldKey = GlobalKey();
  bool _cookieConsentGiven = false;

  double _lastScrollPosition = 0;

  @override
  void initState() {
    _checkCookieConsent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GeneralProvider>(context, listen: false)
          .setCurrentPage("home");
    });
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);

    getProfileData();
    feedProvider = Provider.of<FeedProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    detailsProvider = Provider.of<DetailsProvider>(context, listen: false);
    socketIO();
    _scrollController = ScrollController();
    _commentScrollController = ScrollController();
    _replayCommentScrollController = ScrollController();
    _reportScrollController = ScrollController();
    reportReasonController = ScrollController();
    playlistController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _commentScrollController.addListener(_commentScrollListener);
    _replayCommentScrollController.addListener(_replayCommentScrollListener);
    _reportScrollController.addListener(_reportScrollListener);
    playlistController.addListener(_scrollListenerPlaylist);
    reportReasonController.addListener(_scrollListenerReportReason);
    super.initState();

    fetchAllFeed(0);
  }

  Future<void> _checkCookieConsent() async {
    if (!kIsWeb) {
      setState(() => _cookieConsentGiven = true);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasConsent = prefs.getBool('cookie_consent_given') ?? false;
    setState(() => _cookieConsentGiven = hasConsent);
  }

  _scrollListenerReportReason() async {
    if (!reportReasonController.hasClients) return;
    if (reportReasonController.offset >=
            reportReasonController.position.maxScrollExtent &&
        !reportReasonController.position.outOfRange &&
        (homeProvider.reportcurrentPage ?? 0) <
            (homeProvider.reporttotalPage ?? 0)) {
      await homeProvider.setReportReasonLoadMore(true);
      _fetchReportReason(homeProvider.reportcurrentPage ?? 0);
    }
  }

  void socketIO() {
    socketManager = SocketManager();

    if (socketManager.socket?.connected == true) {
      debugPrint("itinnnnbnnnnnnnnnnnn");
      socketManager.setupVideoCallListeners(context, _videoCallManager);
    }
  }

  getProfileData() async {
    await generalProvider.getWebGeneralsetting(context);
    if (!mounted) return;
    Utils().getDeviceTokenWithPermissionWeb();

    if (Constant.userID != null) {
      await profileProvider.getprofile(context, Constant.userID);
      await homeProvider.getprofile(Constant.userID);
      await sharePref.save(
          "userpanelstatus",
          homeProvider.profileModel.result?[0].userPenalStatus.toString() ??
              "");
      Constant.userPanelStatus = await sharePref.read("userpanelstatus");

      await Utils.getCustomAdsStatus();
    }
  }

  Future _fetchPlaylist(int? nextPage) async {
    printLog("playlistmorePage  =======> ${homeProvider.playlistmorePage}");
    printLog(
        "playlistcurrentPage =======> ${homeProvider.playlistcurrentPage}");
    printLog("playlisttotalPage   =======> ${homeProvider.playlisttotalPage}");
    printLog("nextPage   ========> $nextPage");
    await homeProvider.getcontentbyChannel(
        Constant.userID, Constant.channelID, "5", (nextPage ?? 0) + 1);
    printLog("fetchPlaylist length ==> ${homeProvider.playlistData?.length}");
  }

  Future _fetchReportReason(int? nextPage) async {
    printLog("reportmorePage  =======> ${homeProvider.reportmorePage}");
    printLog("reportcurrentPage =======> ${homeProvider.reportcurrentPage}");
    printLog("reporttotalPage   =======> ${homeProvider.reporttotalPage}");
    printLog("nextPage   ========> $nextPage");
    await homeProvider.getReportReason("2", (nextPage ?? 0) + 1);
    printLog(
        "fetchReportReason length ==> ${homeProvider.reportReasonList?.length}");
  }

  _scrollListenerPlaylist() async {
    if (!playlistController.hasClients) return;
    if (playlistController.offset >=
            playlistController.position.maxScrollExtent &&
        !playlistController.position.outOfRange &&
        (homeProvider.playlistcurrentPage ?? 0) <
            (homeProvider.playlisttotalPage ?? 0)) {
      await homeProvider.setPlaylistLoadMore(true);
      _fetchPlaylist(homeProvider.playlistcurrentPage ?? 0);
    }
  }

  _scrollListener() async {
    if (feedProvider.isShowFilter == true) {
      setState(() {
        feedProvider.isShowFilter = false;
      });
    }
    if (feedProvider.isShowSearch == true) {
      setState(() {
        feedProvider.isShowSearch = false;
      });
    }
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (feedProvider.currentPage ?? 0) < (feedProvider.totalPage ?? 0)) {
      await feedProvider.setLoadMore(true);
      fetchAllFeed(feedProvider.currentPage ?? 0);
    }
    final currentScroll = _scrollController.offset;
    // Detect scroll direction
    if (currentScroll > _lastScrollPosition) {
      // Scrolling down
      if (_showTopWidgets && currentScroll > 20) {
        setState(() => _showTopWidgets = false);
      }
    } else if (currentScroll < _lastScrollPosition) {
      // Scrolling up - show immediately
      if (!_showTopWidgets) {
        setState(() => _showTopWidgets = true);
      }
    }

    _lastScrollPosition = currentScroll;
  }

  _commentScrollListener() async {
    if (!_commentScrollController.hasClients) return;
    if (_commentScrollController.offset >=
            _commentScrollController.position.maxScrollExtent &&
        !_commentScrollController.position.outOfRange &&
        (feedProvider.commentcurrentPage ?? 0) <
            (feedProvider.commenttotalPage ?? 0)) {
      await feedProvider.setCommentLoadMore(true);
      _fetchAllComment(
          feedProvider.postId, feedProvider.commentcurrentPage ?? 0);
    }
  }

  _replayCommentScrollListener() async {
    if (!_replayCommentScrollController.hasClients) return;
    if (_replayCommentScrollController.offset >=
            _replayCommentScrollController.position.maxScrollExtent &&
        !_replayCommentScrollController.position.outOfRange &&
        (feedProvider.replayCommentcurrentPage ?? 0) <
            (feedProvider.replayCommenttotalPage ?? 0)) {
      await feedProvider.setReplayCommentLoadMore(true);
      _fetchAllReplayComment(
          feedProvider.commentId, feedProvider.replayCommentcurrentPage ?? 0);
    }
  }

  _reportScrollListener() async {
    if (!_reportScrollController.hasClients) return;
    if (_reportScrollController.offset >=
            _reportScrollController.position.maxScrollExtent &&
        !_reportScrollController.position.outOfRange &&
        (feedProvider.reportcurrentPage ?? 0) <
            (feedProvider.replayCommenttotalPage ?? 0)) {
      await feedProvider.setReportReasonLoadMore(true);
      _fetchAllReportReason(feedProvider.reportcurrentPage ?? 0);
    }
  }

  Future<void> fetchAllFeed(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await feedProvider.getAllFeed((nextPage ?? 0) + 1);
    await feedProvider.getFeeds(_selectedFeed);
    await feedProvider.setLoadMore(false);
  }

  Future<void> _fetchAllComment(postId, int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await feedProvider.getPostComment(postId, (nextPage ?? 0) + 1);
    await feedProvider.setCommentLoadMore(false);
  }

  Future<void> _fetchAllReplayComment(commentId, int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await feedProvider.getPostReplayComment(commentId, (nextPage ?? 0) + 1);
    await feedProvider.setReplayCommentLoadMore(false);
  }

  Future<void> _fetchAllReportReason(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await feedProvider.getReportReason("2", (nextPage ?? 0) + 1);
    await feedProvider.setReportReasonLoadMore(false);
  }

  @override
  void dispose() {
    feedProvider.clearProvider();
    commentFocusNode.dispose();

    super.dispose();
  }

  Widget buildBody() {
    return Utils().pageBg(
      context,
      child: Consumer<FeedProvider>(builder: (context, feedprovider, child) {
        return RefreshIndicator(
          backgroundColor: appbgcolor,
          color: colorAccent,
          displacement: 70,
          edgeOffset: 1.0,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          strokeWidth: 3,
          onRefresh: () async {
            await feedProvider.clearProvider();
            await profileProvider.getprofile(context, Constant.userID);
            fetchAllFeed(0);
          },
          child: Stack(
            children: [
              ScrollFixWidget(
                scrollController: _scrollController,
                scrollSpeed: 3.0,
                child: Column(
                  children: [
                    buildFeed(),
                  ],
                ),
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ResponsiveHelper.checkIsWeb(context)
                              ? const SizedBox()
                              : const CustomAppBar(contentType: "1"),
                          Container(
                            width: double.infinity,
                            key: const ValueKey('topWidget'),
                            decoration: BoxDecoration(
                              color: ResponsiveHelper.checkIsWeb(context)
                                  ? transparent
                                  : appBarColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 12),
                            child: Align(
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: ResponsiveHelper.isDesktop(context)
                                      ? 900
                                      : double.infinity,
                                ),
                                child: feedprovider.isShowSearch
                                    ? Container(
                                        height: 35,
                                        decoration: BoxDecoration(
                                          gradient: _selectedFeed == 'search'
                                              ? Constant.gradientColor
                                              : null,
                                          border: Border.all(
                                            color: _selectedFeed == 'search'
                                                ? transparent
                                                : textColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: TextFormField(
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: white,
                                                  fontWeight: FontWeight.w700),
                                          controller:
                                              feedprovider.searchController,
                                          decoration: InputDecoration(
                                              hintText: "Search",
                                              hintStyle:
                                                  TextStyle(color: white),
                                              /* fillColor: white.withOpacity(0.42),
                                          filled: true,*/
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 15, left: 10),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .transparent)),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .transparent)),
                                              suffixIcon: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (feedprovider
                                                        .searchController
                                                        .text
                                                        .isNotEmpty) {
                                                      feedprovider
                                                          .searchController
                                                          .clear();
                                                      feedprovider.getFeeds(
                                                          _selectedFeed);
                                                    }
                                                    feedprovider.isShowSearch =
                                                        !feedprovider
                                                            .isShowSearch;
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(7.0),
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
                                            feedprovider
                                                .getFeeds(_selectedFeed);
                                          },
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            _buildTabButton(
                                              label: "feeds",
                                              icon:
                                                  Icons.person_add_alt_1_sharp,
                                              isSelected:
                                                  _selectedFeed == "for_you",
                                              onTap: () {
                                                setState(() {
                                                  _selectedFeed = "for_you";
                                                  feedprovider
                                                      .getFeeds(_selectedFeed);
                                                  feedprovider.selectedFilter =
                                                      'All';
                                                });
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            _buildTabButton(
                                              label: "following",
                                              icon: Icons.person,
                                              isSelected:
                                                  _selectedFeed == "following",
                                              onTap: () {
                                                setState(() {
                                                  _selectedFeed = "following";
                                                  feedprovider
                                                      .getFeeds(_selectedFeed);
                                                  feedprovider.selectedFilter =
                                                      'All';
                                                });
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            _buildTabButton(
                                              label: "search",
                                              icon: Icons.search,
                                              onTap: () {
                                                setState(() {
                                                  feedprovider.isShowSearch =
                                                      !feedprovider
                                                          .isShowSearch;
                                                  feedprovider.selectedFilter =
                                                      'All';
                                                });
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            Theme(
                                              data: Theme.of(context).copyWith(
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                hoverColor: Colors.transparent,
                                              ),
                                              child: PopupMenuButton<String>(
                                                color: Colors.transparent,
                                                elevation: 0,
                                                tooltip: '',
                                                offset: const Offset(0, 40),
                                                constraints:
                                                    const BoxConstraints(
                                                        maxHeight: 250),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                itemBuilder:
                                                    (BuildContext context) {
                                                  return [
                                                    PopupMenuItem<String>(
                                                      enabled: false,
                                                      padding: EdgeInsets.zero,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              const Color(
                                                                      0xff6DA9F8)
                                                                  .withOpacity(
                                                                      0.8),
                                                              const Color(
                                                                      0xFF01DED1)
                                                                  .withOpacity(
                                                                      0.8),
                                                              const Color(
                                                                      0xffFE3379)
                                                                  .withOpacity(
                                                                      0.8),
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xff4a4a4a),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: feedprovider
                                                                  .filters
                                                                  .map(
                                                                      (filter) {
                                                                final isSelected =
                                                                    feedprovider
                                                                            .selectedFilter ==
                                                                        filter;
                                                                return InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context); // close popup manually
                                                                    setState(
                                                                        () {
                                                                      feedprovider
                                                                              .selectedFilter =
                                                                          filter;
                                                                      feedprovider
                                                                          .getFeeds(
                                                                              _selectedFeed);

                                                                      if (Constant
                                                                              .userID ==
                                                                          null) {
                                                                        _selectedFeed =
                                                                            "for_you";
                                                                      }
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: ResponsiveHelper.isTab(
                                                                            context)
                                                                        ? MediaQuery.of(context).size.width *
                                                                            0.25
                                                                        : ResponsiveHelper.isDesktop(
                                                                                context)
                                                                            ? MediaQuery.of(context).size.width *
                                                                                0.2
                                                                            : MediaQuery.of(context).size.width *
                                                                                0.33,
                                                                    color: isSelected
                                                                        ? Colors
                                                                            .black
                                                                            .withOpacity(
                                                                                0.35)
                                                                        : Colors
                                                                            .transparent,
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .symmetric(
                                                                      vertical:
                                                                          8,
                                                                      horizontal:
                                                                          8,
                                                                    ),
                                                                    child:
                                                                        MyText(
                                                                      text:
                                                                          filter,
                                                                      fontwaight: isSelected
                                                                          ? FontWeight
                                                                              .w700
                                                                          : FontWeight
                                                                              .w500,
                                                                      color: isSelected
                                                                          ? button1color
                                                                          : pureWhite,
                                                                      multilanguage:
                                                                          false,
                                                                    ),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ];
                                                },
                                                child: _buildTabButton(
                                                  label: "filter",
                                                  icon: Icons.filter_alt,
                                                  onTap: () {},
                                                  isPopup: true,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(
                        key: ValueKey(
                            'emptyWidget'), // keeps AnimatedSwitcher working
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isPopup = false,
  }) {
    final buttonContent = Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: isSelected ? Constant.gradientColor : null,
        border: Border.all(
          color: isSelected ? transparent : textColor,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? pureBlack : white, size: 17),
          const SizedBox(width: 4),
          MyText(
            text: label,
            color: isSelected ? pureBlack : white,
            fontwaight: FontWeight.w600,
            fontsizeNormal: 12,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    return isPopup
        ? buttonContent
        : GestureDetector(
            onTap: onTap,
            child: buttonContent,
          );
  }

  @override
  Widget build(BuildContext context) {
    // Show cookie splash if consent not given
    if (!_cookieConsentGiven) {
      return CookieSplashPage(
        onConsentComplete: () {
          setState(() => _cookieConsentGiven = true);
        },
      );
    }

    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: ResponsiveHelper.checkIsWeb(context)
          ? Utils.webAppbarWithSidePanel(
              context: context, contentType: Constant.videoSearch)
          : null,
      floatingActionButton:
          Constant.isCreator == '1' && ResponsiveHelper.checkIsWeb(context)
              ? GestureDetector(
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
                      ResponsiveHelper.checkIsWeb(context)
                          ? buildCreatePostDialog()
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const UploadFeed();
                                },
                              ),
                            );
                    }
                    setState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 5, bottom: 60),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                        gradient: Constant.gradientColor,
                        borderRadius: BorderRadius.circular(40)),
                    child: const Icon(
                      Icons.add,
                      color: pureBlack,
                    ),
                  ),
                )
              : null,
      body: ResponsiveHelper.checkIsWeb(context)
          ? Utils.sidePanelWithBody(
              myWidget: buildBody(),
            )
          : buildBody(),
    );
  }

  Widget buildFeed() {
    if (feedProvider.loading && !feedProvider.loadMore) {
      return shimmer();
    } else {
      if (feedProvider.feeds != null && (feedProvider.feeds?.length ?? 0) > 0) {
        return Column(
          children: [
            const SizedBox(
              height: 120,
            ),
            buildFeedItem(),
            if (feedProvider.loadMore)
              SizedBox(
                height: 50,
                child: Utils.pageLoader(context),
              )
            else
              const SizedBox.shrink(),
          ],
        );
      } else {
        return const Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: NoData(),
        );
      }
    }
  }

  Widget allVideo(int index, feed.Result videoFeed) {
    return InkWell(
      highlightColor: transparent,
      focusColor: transparent,
      hoverColor: transparent,
      splashColor: transparent,
      onTap: ResponsiveHelper.checkIsWeb(context)
          ? () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => WebDetail(
                        stoptime: 0,
                        iscontinueWatching: false,
                        videoid: videoFeed.id.toString(),
                        feedType: videoFeed.feedType == 'live' ? '7' : '1'),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              });
            }
          : () {
              Utils.moveToDetail(
                context,
                0,
                false,
                videoFeed.id.toString(),
                false,
                videoFeed.feedType == 'live' ? '7' : '1',
                videoFeed.isComment!,
              );
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 10, 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40, // Outer size
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: Constant.sweepGradient,
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: MyNetworkImage(
                        width: 32,
                        height: 32,
                        imagePath: videoFeed.portraitImg.toString(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                          color: white,
                          text: videoFeed.title.toString(),
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textMedium,
                          maxline: 1,
                          multilanguage: false,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text: /*videoFeed.isComment == 0
                              ? ""
                              :*/
                              "${videoFeed.channelName.toString()}  ",
                          style: Utils.googleFontStyle(4, Dimens.textSmall,
                              FontStyle.normal, gray, FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  highlightColor: transparent,
                  focusColor: transparent,
                  hoverColor: transparent,
                  onTap: () async {
                    await detailsProvider.getvideodetails(
                        videoFeed.id.toString(), videoFeed.contentType);
                    moreBottomSheet(
                      videoFeed.userId,
                      videoFeed.id,
                      index,
                      videoFeed.title,
                      videoFeed.contentType,
                      videoFeed.isComment!,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.more_vert_outlined,
                      color: white,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kIsWeb ? 10 : 0)),
                child: MyNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                    height: ResponsiveHelper.checkIsWeb(context) ? 200 : 220,
                    imagePath: videoFeed.landscapeImg.toString()),
              ),
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
                        color: pureWhite,
                        text: Utils.formatTime(double.parse(feedProvider
                                .feeds?[index].contentDuration
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
              Constant.userID != videoFeed.userId.toString() &&
                      videoFeed.payContent == true
                  ? Positioned.fill(
                      top: 10,
                      left: 15,
                      right: 46,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(7, 5, 5, 4),
                          width: 90,
                          decoration: BoxDecoration(
                            color: transparent.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              MyImage(
                                  width: 17.5,
                                  height: 17.5,
                                  imagePath: "ic_coin.png"),
                              const SizedBox(
                                width: 5,
                              ),
                              MyText(
                                text: "featured",
                                fontsizeNormal: 12,
                                fontsizeWeb: 12.5,
                                color: pureWhite,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
              Positioned(
                  top: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: black.withOpacity(0.7)),
                    child: Icon(
                      Icons.play_arrow,
                      color: white,
                      size: 18,
                    ),
                  ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${Utils.kmbGenerator(videoFeed.totalView ?? 0)} ",
                    style: Utils.googleFontStyle(4, Dimens.textSmall,
                        FontStyle.normal, white, FontWeight.w400),
                  ),
                  TextSpan(
                    text: 'views ',
                    style: Utils.googleFontStyle(4, Dimens.textSmall,
                        FontStyle.normal, white, FontWeight.w400),
                  ),
                  TextSpan(
                    text: Utils.timeAgoCustom(
                      DateTime.parse(
                        videoFeed.createdAt ?? "",
                      ),
                    ),
                    style: Utils.googleFontStyle(4, Dimens.textSmall,
                        FontStyle.normal, white, FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget allPost(int index, feed.Result postFeed) {
    print(index);
    return Column(
      children: [
        InkWell(
          hoverColor: transparent,
          splashColor: transparent,
          highlightColor: transparent,
          focusColor: transparent,
          onTap: Constant.userID == null
              ? () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ResponsiveHelper.isWeb(context)
                              ? const WebLogin()
                              : const Login()));
                }
              : ResponsiveHelper.checkIsWeb(context)
                  ? () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              WebProfile(
                            isProfile: false,
                            channelUserid: postFeed.userId.toString(),
                            channelid: postFeed.channelId.toString(),
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
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
                              channelUserid: postFeed.userId.toString(),
                              channelid: postFeed.channelId.toString(),
                            );
                          },
                        ),
                      ).then((_) {
                        context.read<ProfileProvider>().fetchMyProfile(context);
                      });
                    },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 6),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: MyNetworkImage(
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                        imagePath: postFeed.profileImg.toString()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                          color: white,
                          multilanguage: false,
                          text: postFeed.fullName.toString(),
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          fontsizeWeb: Dimens.textTitle,
                          inter: true,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      MyText(
                          color: gray,
                          multilanguage: false,
                          text: Utils.timeAgoCustom(
                            DateTime.parse(
                              postFeed.createdAt.toString(),
                            ),
                          ),
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textSmall,
                          inter: true,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      /* MyText(
                          color: gray,
                          multilanguage: false,
                          text: postFeed.title.toString() ?? "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textSmall,
                          inter: true,
                          maxline: 1,
                          fontwaight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),*/
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  splashColor: transparent,
                  highlightColor: transparent,
                  hoverColor: transparent,
                  focusColor: transparent,
                  borderRadius: BorderRadius.circular(50),
                  onTap: () async {
                    await showReportReason(
                        context: context, postId: postFeed.id.toString());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Iconify(
                      Ic.outline_more_vert,
                      color: white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            postContent(index, postFeed),
            (Constant.userID != postFeed.userId.toString() &&
                    postFeed.payContent == true)
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              iconWithCount(
                                size: 24,
                                showText: true,
                                iconPath: (postFeed.totalLike ?? 0) == 1
                                    ? Mdi.heart
                                    : Ion.md_heart_empty,
                                iconColor: (postFeed.totalLike ?? 0) == 1
                                    ? Colors.redAccent
                                    : white,
                                count: Utils.kmbGenerator(
                                  int.parse(postFeed.totalLike.toString()),
                                ),
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
                                    await feedProvider.like(
                                        index, postFeed.id ?? 0);
                                  }
                                },
                              ),
                              ResponsiveHelper.checkIsWeb(context) ||
                                      postFeed.isComment == 0
                                  ? const SizedBox()
                                  : iconWithCount(
                                      size: 20,
                                      showText: true,
                                      iconColor: white,
                                      iconPath:
                                          Teenyicons.message_text_alt_solid,
                                      count: Utils.kmbGenerator(
                                        int.parse(
                                          postFeed.totalComment.toString(),
                                        ),
                                      ),
                                      onTap: () async {
                                        showComment(
                                          context: context,
                                          postIndex: index,
                                          postId: postFeed.id.toString(),
                                          postIsComment:
                                              postFeed.isComment ?? 0,
                                        );
                                      },
                                    ),
                              if (!ResponsiveHelper.isWeb(context))
                                iconWithCount(
                                    size: 24,
                                    iconColor: white,
                                    showText: false,
                                    iconPath: Bi.send,
                                    onTap: () async {
                                      final shareUrl =
                                          "Hey! I'm watching ${postFeed.title} on ${Constant.appName}! 🎬\n"
                                          "Watch here 👉 https://fanbae.tv/post?p=${postFeed.id}/$index\n";

                                      print(shareUrl);
                                      Utils.shareApp(shareUrl);
                                    }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            /*postFeed.descripation.toString().isNotEmpty
                ?*/
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: MyText(
                  color: white,
                  multilanguage: false,
                  text: postFeed.descripation.toString() ?? "",
                  textalign: TextAlign.left,
                  fontsizeNormal: Dimens.textSmall,
                  inter: true,
                  maxline: 2,
                  fontwaight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            )
            /*: const SizedBox(),*/
          ],
        ),
      ],
    );
  }

  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    String? podcastimage,
    String? contentUserid,
    required int position,
    dynamic sectionBannerList,
    dynamic playlistImages,
    required String contentName,
    required String? isBuy,
  }) async {
    if (playingType == "2") {
      musicManager.setInitialMusic(position, playingType, sectionBannerList,
          contentid, addView(playingType, contentid), false, 0, isBuy ?? "");
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ContentDetail(
              contentType: playingType,
              contentUserid: contentUserid ?? "",
              contentImage: podcastimage ?? "",
              contentName: contentName,
              playlistImage: playlistImages ?? [],
              contentId: contentid,
              isBuy: isBuy ?? "",
            );
          },
        ),
      );
    }
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
  }

  Widget allMusic(int index, feed.Result musicFeed, List<feed.Result> allFeed) {
    List<feed.Result> allMusicFeed = allFeed
        .where((item) => item.feedType?.toLowerCase() == 'music')
        .toList();
    final position = allMusicFeed
        .indexWhere((item) => item.id.toString() == musicFeed.id.toString());
    return InkWell(
      onTap: () {
        AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
          playAudio(
            playingType: musicFeed.contentType.toString(),
            episodeid: musicFeed.id.toString(),
            contentid: musicFeed.id.toString(),
            position: position,
            sectionBannerList: allMusicFeed,
            contentName: musicFeed.title.toString(),
            isBuy: musicFeed.isBuy.toString(),
          );
        });
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40, // Outer size
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: Constant.sweepGradient,
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: MyNetworkImage(
                            imagePath: musicFeed.channelImage ?? '',
                            fit: BoxFit.cover),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MusicTitle(
                          color: white,
                          multilanguage: false,
                          text: musicFeed.title.toString(),
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textDesc,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          MyText(
                              color: white,
                              multilanguage: false,
                              text: musicFeed.artistName.toString() ?? "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textSmall,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          const SizedBox(width: 5),
                          MyText(
                              color: white,
                              multilanguage: false,
                              text: Utils.kmbGenerator(int.tryParse(
                                      musicFeed.totalView.toString()) ??
                                  0),
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textSmall,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          const SizedBox(width: 3),
                          MyText(
                              color: white,
                              multilanguage: false,
                              text: "views",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textSmall,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            ClipRRect(
              child: Stack(
                children: [
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(kIsWeb ? 10 : 0)),
                    child: MyNetworkImage(
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        imagePath: musicFeed.landscapeImg.toString()),
                  ),
                  Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: black.withOpacity(0.7)),
                        child: Icon(
                          Icons.music_note,
                          color: white,
                          size: 18,
                        ),
                      ))
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget allPodcast(
      int index, feed.Result musicFeed, List<feed.Result> allFeed) {
    List<feed.Result> allPodcastFeed = allFeed
        .where((item) => item.feedType?.toLowerCase() == 'podcasts')
        .toList();
    return InkWell(
      onTap: () {
        AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
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
            playAudio(
                playingType: musicFeed.contentType.toString(),
                episodeid: musicFeed.id.toString(),
                contentid: musicFeed.id.toString(),
                position: index,
                sectionBannerList: allPodcastFeed,
                contentName: musicFeed.title.toString(),
                isBuy: musicFeed.isBuy.toString(),
                podcastimage: musicFeed.landscapeImg);
          }
        });
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40, // Outer size
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: Constant.sweepGradient,
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: MyNetworkImage(
                            imagePath: musicFeed.channelImage ?? '',
                            fit: BoxFit.cover),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MusicTitle(
                          color: white,
                          multilanguage: false,
                          text: musicFeed.title.toString(),
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textDesc,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (musicFeed.artistName.toString().isNotEmpty)
                            MyText(
                                color: white,
                                multilanguage: false,
                                text: musicFeed.artistName.toString(),
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textSmall,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          if (musicFeed.artistName.toString().isNotEmpty)
                            const SizedBox(width: 5),
                          MyText(
                              color: white,
                              multilanguage: false,
                              text: Utils.kmbGenerator(int.tryParse(
                                      musicFeed.totalView.toString()) ??
                                  0),
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textSmall,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          const SizedBox(width: 3),
                          MyText(
                              color: white,
                              multilanguage: false,
                              text: "views",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textSmall,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(kIsWeb ? 10 : 0),
              child: Stack(
                children: [
                  MyNetworkImage(
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      imagePath: musicFeed.landscapeImg.toString()),
                  Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: black.withOpacity(0.7)),
                        child: Icon(
                          Icons.mic,
                          color: white,
                          size: 18,
                        ),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFeedItem() {
    return kIsWeb
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: Utils.customCrossAxisCount(
                  context: context,
                  height1600: 4,
                  height1200: 3,
                  height800: 3,
                  height600: 2),
              maxItemsPerRow: Utils.customCrossAxisCount(
                  context: context,
                  height1600: 4,
                  height1200: 3,
                  height800: 3,
                  height600: 2),
              horizontalGridSpacing: 15,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                feedProvider.feeds?.length ?? 0,
                (index) {
                  return Container(
                    child: feedProvider.feeds?[index].feedType == "post"
                        ? allPost(index, feedProvider.feeds![index])
                        : feedProvider.feeds?[index].feedType == "video" ||
                                feedProvider.feeds?[index].feedType == "live"
                            ? allVideo(index, feedProvider.feeds![index])
                            : feedProvider.feeds?[index].feedType == "podcasts"
                                ? allPodcast(index, feedProvider.feeds![index],
                                    feedProvider.feeds!)
                                : allMusic(index, feedProvider.feeds![index],
                                    feedProvider.feeds!),
                  );
                },
              ),
            ),
          )
        : ListView.separated(
            shrinkWrap: true,
            itemCount: feedProvider.feeds?.length ?? 0,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return feedProvider.feeds?[index].feedType == "post"
                  ? allPost(index, feedProvider.feeds![index])
                  : feedProvider.feeds?[index].feedType == "video" ||
                          feedProvider.feeds?[index].feedType == "live"
                      ? allVideo(index, feedProvider.feeds![index])
                      : feedProvider.feeds?[index].feedType == "podcasts"
                          ? allPodcast(index, feedProvider.feeds![index],
                              feedProvider.feeds!)
                          : allMusic(index, feedProvider.feeds![index],
                              feedProvider.feeds!);
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 20);
            },
          );
  }

  Widget shimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ResponsiveGridList(
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
        children: List.generate(
          5,
          (index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                      height: 225,
                      child: ListView.separated(
                        separatorBuilder: (context, contentIndex) =>
                            const SizedBox(width: 10),
                        itemCount: 1,
                        //  padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, contentIndex) {
                          return CustomWidget.roundcorner(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: colorPrimaryDark,
                      padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(width: 1, color: gray),
                            ),
                            child: const CustomWidget.circular(
                              height: 35,
                              width: 35,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomWidget.roundrectborder(
                                  height: 10,
                                  width: 150,
                                ),
                                CustomWidget.roundrectborder(
                                  height: 10,
                                  width: 150,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const CustomWidget.roundcorner(
                            height: 20,
                            width: 80,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildCreatePostDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: transparent,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 115, vertical: 70),
          backgroundColor: colorPrimaryDark,
          child: Stack(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: colorPrimaryDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const UploadFeed(
                  fromDialog: true,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: white.withOpacity(0.3), shape: BoxShape.circle),
                    child: const Icon(
                      Icons.close,
                      size: 23,
                      color: Colors.white, // or any color that suits your theme
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  payPostApi(index, feed.Result postFeed) {
    final bool isSubscribed = postFeed.isSubscriber != 0;
    final bool isSubscribing = postFeed.purchasePackage == 0;
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: black,
        child: Stack(
          children: [
            GestureDetector(
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
                    Utils().conformDialog(
                        context,
                        () async {
                          Utils.showProgress(context);
                          SuccessModel video = await ApiService().payVideoPost(
                              Constant.userID ?? '',
                              'post',
                              feedProvider.feeds![index].id ?? 0);
                          if (!mounted) return;
                          Utils().hideProgress(context);
                          if (video.status == 200) {
                            setState(() {
                              Utils().showSnackBar(
                                  context, video.message ?? '', false);
                              feedProvider.feeds?[index].payContent = false;
                            });
                            /*await feedProvider.clearProvider();
                            _fetchAllFeed(0);*/
                          } else {
                            Utils().showSnackBar(
                                context, video.message ?? '', false);
                          }
                        },
                        "wanttobuy",
                        () {
                          Navigator.pop(context);
                        });
                  }
                },
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  // adjust blur strength
                  child: MyNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                    imagePath: feedProvider.feeds![index].postContent?[0]
                                ["content_type"] ==
                            1
                        ? (feedProvider
                                .feeds?[index].postContent?[0]["content_url"]
                                .toString() ??
                            "")
                        : (feedProvider.feeds?[index]
                                .postContent?[0]["thumbnail_image"]
                                .toString() ??
                            ""),
                  ),
                )),
            // 🔹 Pay button overlay (bottom left)
            Positioned(
              top: 12,
              left: 12,
              child: GestureDetector(
                onTap: () async {
                  Utils().conformDialog(
                      context,
                      () async {
                        Utils.showProgress(context);
                        SuccessModel video = await ApiService().payVideoPost(
                            Constant.userID ?? '',
                            'post',
                            feedProvider.feeds![index].id ?? 0);
                        if (!mounted) return;
                        Utils().hideProgress(context);
                        if (video.status == 200) {
                          setState(() {
                            Utils().showSnackBar(
                                context, video.message ?? '', false);
                          });
                          await feedProvider.clearProvider();
                          fetchAllFeed(0);
                        } else {
                          Utils().showSnackBar(
                              context, video.message ?? '', false);
                        }
                      },
                      "wanttobuy",
                      () {
                        Navigator.pop(context);
                      });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        multilanguage: false,
                        color: pureWhite,
                        fontwaight: FontWeight.w600,
                        text: "Pay ",
                      ),
                      MyImage(
                        width: 18,
                        height: 18,
                        imagePath: "ic_coin.png",
                      ),
                      MyText(
                        multilanguage: false,
                        color: pureWhite,
                        fontwaight: FontWeight.w600,
                        text: " ${feedProvider.feeds![index].payCoin} to view",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  if (!ResponsiveHelper.checkIsWeb(context) &&
                      postFeed.userId.toString() != Constant.userID)
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (Constant.userID == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ResponsiveHelper.isWeb(context)
                                    ? const WebLogin()
                                    : const Login(),
                              ),
                            );
                          } else {
                            await feedProvider.addRemoveSubscriber(
                                index, postFeed.userId.toString(), "1");
                          }
                        },
                        child: Container(
                          height: 42,
                          decoration: const BoxDecoration(
                              //color: isSubscribed ? buttonDisable : appbgcolor,
                              // borderRadius: BorderRadius.circular(8),
                              color: Color(0xfff16296)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyImage(
                                width: 18,
                                height: 18,
                                color: pureBlack,
                                imagePath: isSubscribed
                                    ? "ic_usertrue.png"
                                    : "ic_followuser.png",
                              ),
                              const SizedBox(width: 6),
                              MyText(
                                  fontsizeNormal: 15,
                                  text: !isSubscribed ? 'Follow' : 'Following',
                                  color: pureBlack),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (!ResponsiveHelper.checkIsWeb(context) &&
                      postFeed.userId.toString() != Constant.userID)
                    Expanded(
                      child: InkWell(
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
                            await profileProvider.getprofile(
                              context,
                              postFeed.userId.toString(),
                            );
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
                          height: 42,
                          decoration: const BoxDecoration(
                            // borderRadius: BorderRadius.circular(8),
                            //  gradient: isSubscribing ? Constant.gradientColor : null,
                            //color: !isSubscribing ? buttonDisable : null,
                            color: Color(0xff2ecdf1),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /* MyImage(
                                width: 18,
                                height: 18,
                                color: white,
                                imagePath: isSubscribing
                                    ? "ic_king.png"
                                    : "ic_king.png",
                              ),*/
                              Icon(
                                isSubscribing
                                    ? Icons.notification_add_outlined
                                    : Icons.notifications_active_outlined,
                                color: pureBlack,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              MyText(
                                fontsizeNormal: 15,
                                color: pureBlack,
                                text: isSubscribing
                                    ? "subscribing"
                                    : "subscriber",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            feedProvider.feeds?[index].postContent?[0]["content_type"] == 1
                ? const SizedBox.shrink()
                : Positioned.fill(
                    child: Align(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: white,
                        size: 35,
                      ),
                    ),
                  ),
            Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: black.withOpacity(0.7)),
                  child: MyImage(
                    width: 20,
                    height: 20,
                    imagePath: 'ic_shorts.png',
                    color: white,
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget iconWithCount(
      {required onTap,
      required double size,
      required String iconPath,
      required bool showText,
      required Color iconColor,
      count}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      focusColor: transparent,
      splashColor: transparent,
      highlightColor: transparent,
      hoverColor: transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
        child: showText == true
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Iconify(
                    iconPath,
                    color: iconColor,
                    size: size,
                  ),
                  const SizedBox(width: 8),
                  MyText(
                      color: white,
                      multilanguage: false,
                      text: count.toString(),
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textMedium,
                      inter: true,
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ],
              )
            : Iconify(
                iconPath,
                color: white,
                size: size,
              ),
      ),
    );
  }

  Widget postContent(index, feed.Result postFeed) {
    final bool isSubscribed = postFeed.isSubscriber != 0;
    final bool isSubscribing = postFeed.purchasePackage == 0;
    if (feedProvider.feeds?[index].postContent != null &&
        ((feedProvider.feeds?[index].postContent?.length ?? 0) > 0)) {
      if ((feedProvider.feeds?[index].postContent?.length ?? 0) == 1) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: kIsWeb ? 200 : 300,
          child: InkWell(
            splashColor: transparent,
            highlightColor: transparent,
            hoverColor: transparent,
            focusColor: transparent,
            onTap: (Constant.userID !=
                        feedProvider.feeds?[index].userId.toString() &&
                    feedProvider.feeds?[index].payContent == true)
                ? null
                : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ShowPostContent(
                            clickPos: 0,
                            title:
                                feedProvider.feeds?[index].title.toString() ??
                                    "",
                            type: "feed",
                            description:
                                feedProvider.feeds?[index].descripation,
                            attachment: feedProvider.feeds?[index].attachment,
                            postContent:
                                feedProvider.feeds?[index].postContent ?? [],
                          );
                        },
                      ),
                    );
                  },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kIsWeb ? 10 : 0),
              child: (Constant.userID !=
                          feedProvider.feeds?[index].userId.toString() &&
                      feedProvider.feeds?[index].payContent == true)
                  ? payPostApi(index, postFeed)
                  : Stack(
                      children: [
                        MyNetworkImage(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.cover,
                          imagePath: feedProvider.feeds![index].postContent?[0]
                                      ["content_type"] ==
                                  1
                              ? (feedProvider.feeds?[index]
                                      .postContent?[0]["content_url"]
                                      .toString() ??
                                  "")
                              : (feedProvider.feeds?[index]
                                      .postContent?[0]["thumbnail_image"]
                                      .toString() ??
                                  ""),
                        ),
                        feedProvider.feeds?[index].postContent?[0]
                                    ["content_type"] ==
                                1
                            ? const SizedBox.shrink()
                            : Positioned.fill(
                                child: Align(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    color: white,
                                    size: 35,
                                  ),
                                ),
                              ),
                        Positioned(
                            top: 10,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: black.withOpacity(0.7)),
                              child: MyImage(
                                width: 20,
                                height: 20,
                                imagePath: 'ic_shorts.png',
                                color: white,
                              ),
                            )),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            children: [
                              if (postFeed.userId.toString() != Constant.userID)
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      if (Constant.userID == null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ResponsiveHelper.isWeb(context)
                                                    ? const WebLogin()
                                                    : const Login(),
                                          ),
                                        );
                                      } else {
                                        await feedProvider.addRemoveSubscriber(
                                            index,
                                            postFeed.userId.toString(),
                                            "1");
                                      }
                                    },
                                    child: Container(
                                      height: 42,
                                      decoration: const BoxDecoration(
                                          //color: isSubscribed ? buttonDisable : appbgcolor,
                                          // borderRadius: BorderRadius.circular(8),
                                          color: Color(0xfff16296)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          MyImage(
                                            width: 18,
                                            height: 18,
                                            color: pureBlack,
                                            imagePath: isSubscribed
                                                ? "ic_usertrue.png"
                                                : "ic_followuser.png",
                                          ),
                                          const SizedBox(width: 6),
                                          MyText(
                                              fontsizeNormal: 15,
                                              text: !isSubscribed
                                                  ? 'Follow'
                                                  : 'Following',
                                              color: pureBlack),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (postFeed.userId.toString() != Constant.userID)
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
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
                                        await profileProvider.getprofile(
                                          context,
                                          postFeed.userId.toString(),
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
                                        setState(() {});
                                      }
                                    },
                                    child: Container(
                                      height: 42,
                                      decoration: const BoxDecoration(
                                        // borderRadius: BorderRadius.circular(8),
                                        //  gradient: isSubscribing ? Constant.gradientColor : null,
                                        //color: !isSubscribing ? buttonDisable : null,
                                        color: Color(0xff2ecdf1),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          /* MyImage(
                                width: 18,
                                height: 18,
                                color: white,
                                imagePath: isSubscribing
                                    ? "ic_king.png"
                                    : "ic_king.png",
                              ),*/
                                          Icon(
                                            isSubscribing
                                                ? Icons
                                                    .notification_add_outlined
                                                : Icons
                                                    .notifications_active_outlined,
                                            color: pureBlack,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          MyText(
                                            fontsizeNormal: 15,
                                            color: pureBlack,
                                            text: isSubscribing
                                                ? "subscribing"
                                                : "subscriber",
                                          ),
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
          ),
        );
      } else {
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          height: kIsWeb ? 200 : 400,
          child: InkWell(
            splashColor: transparent,
            highlightColor: transparent,
            hoverColor: transparent,
            focusColor: transparent,
            onTap: (Constant.userID !=
                        feedProvider.feeds?[index].userId.toString() &&
                    feedProvider.feeds?[index].payContent == true)
                ? null
                : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ShowPostContent(
                            clickPos: 0,
                            title:
                                feedProvider.feeds?[index].title.toString() ??
                                    "",
                            description:
                                feedProvider.feeds?[index].descripation,
                            attachment: feedProvider.feeds?[index].attachment,
                            type: "feed",
                            postContent:
                                feedProvider.feeds?[index].postContent ?? [],
                          );
                        },
                      ),
                    );
                  },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kIsWeb ? 10 : 0),
              child: (Constant.userID !=
                          feedProvider.feeds?[index].userId.toString() &&
                      feedProvider.feeds?[index].payContent == true)
                  ? payPostApi(index, postFeed)
                  : Stack(
                      children: [
                        MyNetworkImage(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.cover,
                          imagePath: feedProvider.feeds![index].postContent?[0]
                                      ["content_type"] ==
                                  1
                              ? (feedProvider.feeds?[index]
                                      .postContent?[0]["content_url"]
                                      .toString() ??
                                  "")
                              : (feedProvider.feeds?[index]
                                      .postContent?[0]["thumbnail_image"]
                                      .toString() ??
                                  ""),
                        ),
                        feedProvider.feeds?[index].postContent?[0]
                                    ["content_type"] ==
                                1
                            ? const SizedBox.shrink()
                            : Positioned.fill(
                                child: Align(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    color: white,
                                    size: 35,
                                  ),
                                ),
                              ),
                        Positioned(
                            top: 10,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: black.withOpacity(0.7)),
                              child: MyImage(
                                width: 20,
                                height: 20,
                                imagePath: 'ic_shorts.png',
                                color: white,
                              ),
                            ))
                      ],
                    ),
            ),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  /* ====================== Feed Comment ====================== */

  showComment(
      {required BuildContext context,
      postId,
      postIndex,
      required int postIsComment}) async {
    _fetchAllComment(postId, 0);
    await showModalBottomSheet(
        isScrollControlled: true,
        scrollControlDisabledMaxHeightRatio: MediaQuery.of(context).size.height,
        context: context,
        barrierColor: black.withOpacity(0.7),
        backgroundColor: transparent,
        isDismissible: false,
        builder: (context) =>
            Consumer<FeedProvider>(builder: (context, feedprovider, child) {
              final isReplying = feedprovider.replyingToCommentId != null;

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
                              splashColor: transparent,
                              highlightColor: transparent,
                              hoverColor: transparent,
                              focusColor: transparent,
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                                commentController.clear();
                                feedProvider.clearComment();
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
                        child: buildComment(postId, postIndex, postIsComment),
                      ),
                      Utils.buildGradLine(),
                      addCommentTextField(
                          postIndex,
                          postId,
                          isReplying
                              ? int.parse(feedprovider.replyingToCommentId!)
                              : 0,
                          !isReplying,
                          postIsComment),
                    ],
                  ),
                ),
              );
            }));
  }

  Widget buildComment(postId, postIndex, postIsComment) {
    if (feedProvider.commentloading && !feedProvider.commentloadMore) {
      return commentShimmer();
    } else {
      if (feedProvider.commentList != null &&
          (feedProvider.commentList?.length ?? 0) > 0) {
        return RefreshIndicator(
          backgroundColor: colorPrimaryDark,
          color: colorAccent,
          displacement: 70,
          edgeOffset: 1.0,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          strokeWidth: 3,
          onRefresh: () async {
            await feedProvider.clearComment();
            _fetchAllComment(postId, 0);
          },
          child: SingleChildScrollView(
            controller: _commentScrollController,
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                buildCommentItem(postId, postIndex, postIsComment),
                if (feedProvider.commentloadMore)
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
        return const Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: NoData(),
        );
      }
    }
  }

  Widget buildCommentItem(postId, postIndex, postIsComment) {
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
      children: List.generate(feedProvider.commentList?.length ?? 0, (index) {
        final comment = feedProvider.commentList![index];
        final commentId = comment.id.toString();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          MyText(
                            color: white,
                            text: comment.fullName?.isEmpty ?? true
                                ? comment.channelName ?? ""
                                : comment.fullName ?? "",
                            textalign: TextAlign.left,
                            multilanguage: false,
                            fontsizeNormal: Dimens.textMedium,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
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
                          feedProvider.storeReplayCommentId(commentId);
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
                      await feedProvider.postDeleteComment(
                          postIndex, commentId);
                      feedProvider.clearComment();
                      _fetchAllComment(postId, 0);
                    },
                    child:
                        const Icon(Icons.delete, color: Colors.white, size: 22),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            if ((comment.isReply ?? 0) > 0)
              InkWell(
                onTap: () => feedProvider.toggleReplies(commentId),
                child: Padding(
                  padding: const EdgeInsets.only(left: 55, top: 5),
                  child: MyText(
                    color: colorAccent,
                    text: feedProvider.isRepliesExpanded(commentId)
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
            if (feedProvider.isRepliesExpanded(commentId))
              Padding(
                padding: const EdgeInsets.only(left: 55, top: 5),
                child: Column(
                  children: [
                    feedProvider.getReplies(commentId).isNotEmpty
                        ? Column(
                            children: List.generate(
                              feedProvider.getReplies(commentId).length,
                              (replyIndex) {
                                final reply = feedProvider
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
                                                            reply.createdAt ??
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
                                              await feedProvider
                                                  .postDeleteComment(postIndex,
                                                      reply.id.toString());
                                              feedProvider.clearReplayComment();
                                              _fetchAllReplayComment(
                                                  reply.id.toString(), 0);
                                              feedProvider.deleteReply(
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

  Widget buildCommentItem1(postId, postIndex, postIsComment) {
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
        children: List.generate(feedProvider.commentList?.length ?? 0, (index) {
          final comment = feedProvider.commentList![index];
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
                        imagePath: comment.image.toString()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      feedProvider.commentList?[index].fullName == ""
                          ? MyText(
                              color: white,
                              multilanguage: false,
                              text: feedProvider.commentList?[index].channelName
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textMedium,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal)
                          : MyText(
                              color: white,
                              multilanguage: false,
                              text: feedProvider.commentList?[index].fullName
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textMedium,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                      MyText(
                          color: gray,
                          multilanguage: false,
                          text: feedProvider.commentList?[index].comment
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textSmall,
                          inter: false,
                          maxline: 5,
                          fontwaight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                ),
                InkWell(
                  splashColor: transparent,
                  highlightColor: transparent,
                  hoverColor: transparent,
                  focusColor: transparent,
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }

                    commentController.clear();
                    feedProvider.storeCommentId(
                      postId,
                      feedProvider.commentList?[index].id.toString() ?? "",
                    );
                    showReplayComment(
                      context: context,
                      postId: postId,
                      postIndex: postIndex,
                      commentId: feedProvider.commentList?[index].id ?? 0,
                      postIsComment: postIsComment,
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
                const SizedBox(width: 15),
                feedProvider.commentList?[index].userId.toString() ==
                        Constant.userID
                    ? InkWell(
                        splashColor: transparent,
                        highlightColor: transparent,
                        hoverColor: transparent,
                        focusColor: transparent,
                        onTap: () async {
                          await feedProvider.postDeleteComment(
                              postIndex,
                              feedProvider.commentList?[index].id.toString() ??
                                  "");
                          feedProvider.clearComment();
                          _fetchAllComment(postId, 0);
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

  showReplayComment(
      {required BuildContext context,
      postId,
      commentId,
      postIndex,
      required int postIsComment}) async {
    _fetchAllReplayComment(commentId, 0);
    await showModalBottomSheet(
        isScrollControlled: true,
        scrollControlDisabledMaxHeightRatio: MediaQuery.of(context).size.height,
        context: context,
        barrierColor: black.withOpacity(0.7),
        backgroundColor: transparent,
        builder: (context) =>
            Consumer<FeedProvider>(builder: (context, feedprovider, child) {
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
                              splashColor: transparent,
                              highlightColor: transparent,
                              hoverColor: transparent,
                              focusColor: transparent,
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }

                                commentController.clear();
                                feedProvider.clearComment();
                                feedProvider.clearReplayComment();
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
                        child: buildReplayComment(postId, commentId, postIndex),
                      ),
                      Utils.buildGradLine(),
                      addCommentTextField(
                          postIndex, postId, commentId, false, postIsComment),
                    ],
                  ),
                ),
              );
            }));
  }

  Widget buildReplayComment(postId, commentId, postIndex) {
    if (feedProvider.replayCommentloading &&
        !feedProvider.replayCommentloadMore) {
      return commentShimmer();
    } else {
      if ((feedProvider.replaycommentList.length) > 0) {
        return RefreshIndicator(
          backgroundColor: colorPrimaryDark,
          color: colorAccent,
          displacement: 70,
          edgeOffset: 1.0,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          strokeWidth: 3,
          onRefresh: () async {
            await feedProvider.clearReplayComment();
            _fetchAllReplayComment(commentId, 0);
          },
          child: SingleChildScrollView(
            controller: _replayCommentScrollController,
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                //buildReplayCommentItem(postId, commentId, postIndex),
                if (feedProvider.replayCommentloadMore)
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
        return const Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: NoData(),
        );
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

  Widget addCommentTextField(
      postIndex, postId, int commentId, isComment, int postIsComment) {
    return Padding(
      padding: EdgeInsets.only(
          left: 15, right: 15, bottom: (Platform.isAndroid) ? 0 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              key: textFieldKey,
              focusNode: commentFocusNode,
              controller: commentController,
              maxLines: 1,
              scrollPhysics: const AlwaysScrollableScrollPhysics(),
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                filled: true,
                fillColor: transparent,
                border: InputBorder.none,
                hintText: isComment ? "Add a comment" : "Add a reply",
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  color: white,
                ),
                contentPadding: const EdgeInsets.only(left: 10, right: 10),
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
          const SizedBox(width: 5),
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () async {
              sendCommentApi(
                  postIndex, postId, commentId, isComment, postIsComment);
            },
            child: feedProvider.addCommentLoading
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
          ),
        ],
      ),
    );
  }

  sendCommentApi(
      postIndex, postId, int commentId, isComment, int postIsComment) async {
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
    } else if (postIsComment == 0) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      commentController.clear();
      feedProvider.clearComment();
      feedProvider.clearReplayComment();
      Utils().showSnackBar(context, "youcannotcommentthiscontent", true);
    } else {
      if (commentController.text.isEmpty) {
        Utils().showSnackBar(context, "pleaseenteryourcomment", true);
      } else {
        await feedProvider.addPostComment(
            postIndex, postId, commentController.text, commentId);

        if (feedProvider.addPostCommentModel.status == 200) {
          if (!context.mounted) return;
          commentController.clear();

          if (isComment) {
            feedProvider.clearComment();
            _fetchAllComment(postId, 0);
            if ((feedProvider.commentList?.length ?? 0) > 6) {
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
            feedProvider.clearReplayComment();
            _fetchAllReplayComment(commentId, 0);
            if ((feedProvider.replaycommentList.length) > 6) {
              _replayCommentScrollController.animateTo(
                _replayCommentScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );

              _replayCommentScrollController.animateTo(
                _replayCommentScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );
            }
          }
        } else {
          if (!mounted) return;
          Navigator.pop(context);
          Utils().showSnackBar(
              context, feedProvider.addPostCommentModel.message ?? "", false);
        }
      }
    }
  }

  showReportReason({required BuildContext context, postId}) async {
    await _fetchAllReportReason(0);
    feedProvider.reportReasonList != null &&
            feedProvider.reportReasonList!.isNotEmpty
        ? feedProvider.selectReportReason(
            0, feedProvider.reportReasonList?[0].id.toString() ?? "")
        : feedProvider.selectReportReason(0, "");
    if (!context.mounted) return;
    await showModalBottomSheet(
        isScrollControlled: true,
        barrierColor: black.withOpacity(0.7),
        scrollControlDisabledMaxHeightRatio: MediaQuery.of(context).size.height,
        context: context,
        backgroundColor: transparent,
        builder: (context) =>
            Consumer<FeedProvider>(builder: (context, feedprovider, child) {
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
                            text: "report",
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
                                feedProvider.clearReportReason();
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
                        child: buildReportReason(),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }

                                feedProvider.clearReportReason();
                              },
                              child: Container(
                                width: 100,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border:
                                      Border.all(width: 1, color: colorPrimary),
                                ),
                                child: MyText(
                                    color: colorPrimary,
                                    multilanguage: true,
                                    text: "cancel",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textTitle,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
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
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ResponsiveHelper.isWeb(context)
                                            ? const WebLogin()
                                            : const Login();
                                      },
                                    ),
                                  );
                                } else {
                                  await feedProvider.addPostReason(
                                      postId, feedProvider.reason);

                                  if (feedProvider
                                          .addContentReportModel.status ==
                                      200) {
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    Utils().showSnackBar(
                                        context,
                                        feedProvider.addContentReportModel
                                                .message ??
                                            "",
                                        false);
                                  } else {
                                    if (!context.mounted) return;
                                    Utils().showSnackBar(
                                        context,
                                        feedProvider.addContentReportModel
                                                .message ??
                                            "",
                                        false);
                                  }
                                }
                              },
                              child: Container(
                                width: 100,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: colorPrimary,
                                ),
                                child: MyText(
                                    color: Constant.darkMode == 'true'
                                        ? pureBlack
                                        : pureWhite,
                                    multilanguage: true,
                                    text: "report",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textTitle,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            }));
  }

  Widget buildReportReason() {
    if (feedProvider.getcontentreportloading &&
        !feedProvider.getcontentreportloadmore) {
      return commentShimmer();
    } else {
      if (feedProvider.reportReasonList != null &&
          (feedProvider.reportReasonList?.length ?? 0) > 0) {
        return SingleChildScrollView(
          controller: _reportScrollController,
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              buildReportReasonItem(),
              if (feedProvider.getcontentreportloadmore)
                SizedBox(
                  height: 50,
                  child: Utils.pageLoader(context),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      } else {
        return const Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: NoData(),
        );
      }
    }
  }

  moreBottomSheet(
      reportUserid, contentid, position, contentName, contentType, isComment) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withOpacity(0.7),
      backgroundColor: colorPrimaryDark,
      context: context,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 700),
        reverseDuration: const Duration(milliseconds: 300),
      ),
      isScrollControlled: true,
      builder: (context) {
        debugPrint(detailsProvider.detailsModel.result?[0].userId.toString());
        debugPrint(Constant.userID);

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Utils.moreFunctionItem("ic_watchlater.png", "addtowatchlater",
                      () async {
                    if (Constant.userID == null) {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const Login();
                          },
                        ),
                      );
                    } else {
                      print('contentType :$contentType');
                      print('contentId :$contentid');
                      Navigator.of(context).pop();
                      await feedProvider.addremoveWatchLater(
                          contentType, contentid, "0", "1");
                      if (!context.mounted) return;
                      Utils().showSnackBar(context, "savetowatchlater", true);
                    }
                  }),
                  Utils.moreFunctionItem(
                      "ic_playlisttitle.png", "savetoplaylist", () async {
                    if (Constant.userID == null) {
                      Navigator.of(context).pop();
                      kIsWeb
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const WebLogin();
                                },
                              ),
                            )
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Login();
                                },
                              ),
                            );
                    } else {
                      Navigator.pop(context);
                      selectPlaylistBottomSheet(
                          position, contentid, contentType);
                      _fetchPlaylist(0);
                    }
                  }),
                  if (!ResponsiveHelper.isWeb(context))
                    Utils.moreFunctionItem("ic_share.png", "share", () {
                      Navigator.pop(context);
                      print('liveUrl contentType :$contentType');
                      final liveUrl = contentType == 1
                          ? "Hey! I'm watching ${detailsProvider.detailsModel.result?[0].title ?? ""} "
                              "on ${Constant.appName}! 🎬\n"
                              "Watch here 👉 https://fanbae.tv/video?v=$contentid/$isComment/${detailsProvider.detailsModel.result?[0].content?.split('/')[3]}\n"
                          : "Hey! I'm watching ${detailsProvider.detailsModel.result?[0].title ?? ""} "
                              "on ${Constant.appName}! 🎬\n"
                              "Watch here 👉 https://fanbae.tv/live?l=$contentid/$isComment/${detailsProvider.detailsModel.result?[0].content?.split('/')[3]}\n";
                      Utils.shareApp(liveUrl);
                    }),
                  detailsProvider.detailsModel.result?[0].userId.toString() ==
                          Constant.userID
                      ? const SizedBox()
                      : Utils.moreFunctionItem("report.png", "report",
                          () async {
                          if (Constant.userID == null) {
                            Navigator.of(context).pop();
                            kIsWeb
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const WebLogin();
                                      },
                                    ),
                                  )
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const Login();
                                      },
                                    ),
                                  );
                          } else {
                            Navigator.pop(context);
                            _fetchReportReason(0);
                            reportBottomSheet(
                                reportUserid, contentid, contentType);
                          }
                        }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  reportBottomSheet(reportUserid, contentid, contentType) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withOpacity(0.7),
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
                        homeProvider.reportReasonList?.clear();
                        homeProvider.position = 0;
                        homeProvider.clearSelectReportReason();
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
                        if (homeProvider.reasonId == "" ||
                            homeProvider.reasonId.isEmpty) {
                          Utils().showSnackBar(
                              context, "pleaseselectyourreportreason", true);
                        } else {
                          await homeProvider.addContentReport(
                              reportUserid,
                              contentid,
                              homeProvider
                                      .reportReasonList?[
                                          homeProvider.reportPosition ?? 0]
                                      .reason
                                      .toString() ??
                                  "",
                              contentType);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          Utils().showSnackBar(
                              context, "reportaddsuccsessfully", true);
                          homeProvider.clearSelectReportReason();
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
    return Consumer<HomeProvider>(
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
    if (homeProvider.getRepostReasonModel.status == 200 &&
        homeProvider.reportReasonList != null) {
      if ((homeProvider.reportReasonList?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: homeProvider.reportReasonList?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  homeProvider.selectReportReason(
                      index,
                      true,
                      homeProvider.reportReasonList?[index].id.toString() ??
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
                              color: homeProvider.reportPosition == index
                                  ? colorPrimary
                                  : gray)),
                      child: Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: homeProvider.reportPosition == index
                              ? colorPrimary
                              : transparent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: MyText(
                          color: white,
                          text: homeProvider.reportReasonList?[index].reason
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          multilanguage: false,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                    const SizedBox(width: 20),
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

  selectPlaylistBottomSheet(position, contentid, contentType) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withOpacity(0.7),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                          color: white,
                          text: "selectplaylist",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          multilanguage: true,
                          inter: false,
                          maxline: 2,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          createPlaylistDilog(
                              playlistId: homeProvider.playlistId);
                        },
                        child: Container(
                          width: 160,
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: colorPrimary),
                              borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: white,
                                size: 22,
                              ),
                              const SizedBox(width: 5),
                              MyText(
                                  color: white,
                                  text: "createplaylist",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textDesc,
                                  multilanguage: true,
                                  inter: false,
                                  maxline: 2,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: buildPlayList(),
                ),
                Consumer<HomeProvider>(
                    builder: (context, playlistprovider, child) {
                  if (playlistprovider.playlistLoading &&
                      !playlistprovider.playlistLoadmore) {
                    return const SizedBox.shrink();
                  } else {
                    if (homeProvider.getContentbyChannelModel.status == 200 &&
                        homeProvider.playlistData != null) {
                      if ((homeProvider.playlistData?.length ?? 0) > 0) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                // playlistprovider.clearPlaylistData();
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(width: 1, color: white),
                                ),
                                child: MyText(
                                    color: white,
                                    text: "cancel",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textTitle,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 2,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            ),
                            const SizedBox(width: 20),
                            InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                if (homeProvider.playlistId.isEmpty ||
                                    homeProvider.playlistId == "") {
                                  Utils().showSnackBar(
                                      context, "pleaseelectyourplaylist", true);
                                } else {
                                  await homeProvider.addremoveContentToPlaylist(
                                      Constant.channelID,
                                      homeProvider
                                              .getContentbyChannelModel
                                              .result?[homeProvider
                                                      .playlistPosition ??
                                                  0]
                                              .id
                                              .toString() ??
                                          "",
                                      contentType,
                                      contentid,
                                      "0",
                                      "1");

                                  Utils().showSnackBar(
                                      context,
                                      homeProvider.getContentbyChannelModel
                                              .message ??
                                          "",
                                      false);
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                decoration: BoxDecoration(
                                    color: colorPrimary,
                                    borderRadius: BorderRadius.circular(5)),
                                child: MyText(
                                    color: colorAccent,
                                    text: "addcontent",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textTitle,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 2,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
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
                }),
              ],
            ),
          );
        });
      },
    );
  }

  Widget buildPlayList() {
    return Consumer<HomeProvider>(builder: (context, playlistprovider, child) {
      if (playlistprovider.playlistLoading &&
          !playlistprovider.playlistLoadmore) {
        return Utils.pageLoader(context);
      } else {
        if (homeProvider.playlistData != null &&
            (homeProvider.playlistData?.length ?? 0) > 0) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            controller: playlistController,
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                buildPlaylistItem(),
                if (playlistprovider.playlistLoadmore)
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
        } else {
          return const NoData(
              title: "noplaylistfound", subTitle: "createnewplaylist");
        }
      }
    });
  }

  Widget buildPlaylistItem() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: homeProvider.playlistData?.length ?? 0,
      itemBuilder: (BuildContext ctx, index) {
        return InkWell(
          onTap: () {
            homeProvider.selectPlaylist(index,
                homeProvider.playlistData?[index].id.toString() ?? "", true);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            color: homeProvider.playlistPosition == index &&
                    homeProvider.isSelectPlaylist == true
                ? colorPrimary
                : colorPrimaryDark,
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyText(
                    color: homeProvider.playlistPosition == index &&
                            homeProvider.isSelectPlaylist == true
                        ? colorAccent
                        : white,
                    text: "${(index + 1).toString()}.",
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textTitle,
                    multilanguage: false,
                    inter: false,
                    maxline: 2,
                    fontwaight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
                const SizedBox(width: 20),
                Expanded(
                  child: MyText(
                      color: homeProvider.playlistPosition == index &&
                              homeProvider.isSelectPlaylist == true
                          ? colorAccent
                          : white,
                      text:
                          homeProvider.playlistData?[index].title.toString() ??
                              "",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textTitle,
                      multilanguage: false,
                      inter: false,
                      maxline: 2,
                      fontwaight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ),
                const SizedBox(width: 20),
                homeProvider.playlistPosition == index &&
                        homeProvider.isSelectPlaylist == true
                    ? Icon(
                        Icons.check,
                        color: homeProvider.playlistPosition == index &&
                                homeProvider.isSelectPlaylist == true
                            ? colorAccent
                            : white,
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }

  createPlaylistDilog({playlistId}) {
    printLog("playlistId==> $playlistId");
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          insetAnimationCurve: Curves.bounceInOut,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            width: MediaQuery.of(context).size.width * 0.90,
            height: 300,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorPrimary.withOpacity(0.10),
            ),
            child: Consumer<HomeProvider>(
                builder: (context, createplaylistprovider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyText(
                      color: white,
                      multilanguage: true,
                      text: "newplaylist",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textExtraBig,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 25),
                  TextField(
                    cursorColor: white,
                    controller: playlistTitleController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    style: Utils.googleFontStyle(1, Dimens.textBig,
                        FontStyle.normal, white, FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: "Give your playlist a title",
                      hintStyle: Utils.googleFontStyle(1, Dimens.textBig,
                          FontStyle.normal, gray, FontWeight.w500),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      MyText(
                          color: white,
                          multilanguage: true,
                          text: "privacy",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 8),
                      MyText(
                          color: white,
                          multilanguage: false,
                          text: ":",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          createplaylistprovider.selectPrivacy(type: 1);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: createplaylistprovider.isType == 1
                                ? colorPrimary
                                : transparent,
                            border: Border.all(
                                width: 2,
                                color: createplaylistprovider.isType == 1
                                    ? colorPrimary
                                    : white),
                          ),
                          child: createplaylistprovider.isType == 1
                              ? Icon(
                                  Icons.check,
                                  color: colorAccent,
                                  size: 15,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      MyText(
                          color: white,
                          multilanguage: true,
                          text: "public",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textDesc,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          createplaylistprovider.selectPrivacy(type: 2);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: createplaylistprovider.isType == 2
                                ? colorPrimary
                                : transparent,
                            border: Border.all(
                                width: 2,
                                color: createplaylistprovider.isType == 2
                                    ? colorPrimary
                                    : white),
                          ),
                          child: createplaylistprovider.isType == 2
                              ? Icon(
                                  Icons.check,
                                  color: colorAccent,
                                  size: 15,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      MyText(
                          color: white,
                          multilanguage: true,
                          text: "private",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textDesc,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        radius: 50,
                        autofocus: false,
                        onTap: () {
                          Navigator.pop(context);
                          playlistTitleController.clear();
                          homeProvider.isType = 0;
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorPrimaryDark,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorPrimary.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5, //New
                              )
                            ],
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "cancel",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(width: 25),
                      InkWell(
                        onTap: () async {
                          if (playlistTitleController.text.isEmpty) {
                            Utils().showSnackBar(
                                context, "pleaseenterplaylistname", true);
                          } else if (createplaylistprovider.isType == 0) {
                            Utils().showSnackBar(
                                context, "pleaseselectplaylisttype", true);
                          } else {
                            await createplaylistprovider.getcreatePlayList(
                              Constant.channelID,
                              playlistTitleController.text,
                              homeProvider.isType.toString(),
                            );
                            if (!createplaylistprovider.loading) {
                              if (createplaylistprovider
                                      .createPlaylistModel.status ==
                                  200) {
                                if (!context.mounted) return;
                                Utils().showSnackBar(
                                    context,
                                    "${createplaylistprovider.createPlaylistModel.message}",
                                    false);
                              } else {
                                if (!context.mounted) return;
                                Utils().showSnackBar(
                                    context,
                                    "${createplaylistprovider.createPlaylistModel.message}",
                                    false);
                              }
                            }
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            playlistTitleController.clear();
                            homeProvider.isType = 0;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorPrimary.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5, //New
                              )
                            ],
                          ),
                          child: MyText(
                              color: colorAccent,
                              multilanguage: true,
                              text: "create",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget buildReportReasonItem() {
    return ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 1,
        maxItemsPerRow: 1,
        horizontalGridSpacing: 25,
        verticalGridSpacing: 25,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children:
            List.generate(feedProvider.reportReasonList?.length ?? 0, (index) {
          return InkWell(
            onTap: () async {
              feedProvider.selectReportReason(index,
                  feedProvider.reportReasonList?[index].id.toString() ?? "");
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: colorPrimaryDark,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 1,
                            color: feedProvider.reportPosition == index
                                ? colorPrimary
                                : gray)),
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: feedProvider.reportPosition == index
                            ? colorPrimary
                            : transparent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: MyText(
                        color: white,
                        multilanguage: false,
                        text: feedProvider.reportReasonList?[index].reason
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textTitle,
                        inter: true,
                        maxline: 5,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ),
                ],
              ),
            ),
          );
        }));
  }
}

class ScrollFixWidget extends StatelessWidget {
  final ScrollController scrollController;
  final Widget child;
  final double scrollSpeed;

  const ScrollFixWidget({
    super.key,
    required this.scrollController,
    required this.child,
    this.scrollSpeed = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          final newOffset =
              scrollController.offset + (event.scrollDelta.dy * 2.5);
          final max = scrollController.position.maxScrollExtent;
          final min = scrollController.position.minScrollExtent;
          scrollController.jumpTo(newOffset.clamp(min, max));
        }
      },
      child: ScrollConfiguration(
        behavior: CustomScrollBehavior(2.5),
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: child,
        ),
      ),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  final double scrollSpeed;

  const CustomScrollBehavior(this.scrollSpeed);

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return super.buildScrollbar(context, child, details);
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return super.buildOverscrollIndicator(context, child, details);
  }
}
