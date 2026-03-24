import 'package:fanbae/provider/generalprovider.dart';
import 'package:fanbae/provider/homeprovider.dart';
import 'package:fanbae/provider/profileprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customads.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/webdetail.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/webwidget/interactivecontainer.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../pages/createvideo.dart';

class WebHome extends StatefulWidget {
  const WebHome({super.key});

  @override
  State<WebHome> createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  late HomeProvider homeProvider;
  late GeneralProvider generalProvider;
  late ProfileProvider profileProvider;
  int checkboxIndex = 0;
  final playlistTitleController = TextEditingController();
  ScrollController videoscrollController = ScrollController();
  final ScrollController categoryController = ScrollController();
  late ScrollController reportReasonController;
  late ScrollController playlistController;
  SharedPre sharedPre = SharedPre();

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    getProfileData();
    reportReasonController = ScrollController();
    playlistController = ScrollController();
    categoryController.addListener(_scrollListenerCategory);
    videoscrollController.addListener(_scrollListenerVideo);
    reportReasonController.addListener(_scrollListenerReportReason);
    playlistController.addListener(_scrollListenerPlaylist);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi();
    });
  }

/* Category Scroll Pagination */
  _scrollListenerCategory() async {
    if (!categoryController.hasClients) return;
    if (categoryController.offset >=
            categoryController.position.maxScrollExtent &&
        !categoryController.position.outOfRange &&
        (homeProvider.categorycurrentPage ?? 0) <
            (homeProvider.categorytotalPage ?? 0)) {
      printLog("load more====>");
      await homeProvider.setCategoryLoadMore(true);
      _fetchDataCategory(homeProvider.categorycurrentPage ?? 0);
    } else {
      printLog("else");
    }
  }

/* Video Scroll Pagination  */
  _scrollListenerVideo() async {
    if (!videoscrollController.hasClients) return;
    if (videoscrollController.offset >=
            videoscrollController.position.maxScrollExtent &&
        !videoscrollController.position.outOfRange &&
        (homeProvider.videolistcurrentPage ?? 0) <
            (homeProvider.videolisttotalPage ?? 0)) {
      printLog("load more====>");
      await homeProvider.setVideoListLoadMore(true);
      if (homeProvider.catindex == 0) {
        _fetchDataVideo("1", homeProvider.categoryid,
            homeProvider.videolistcurrentPage ?? 0);
      } else {
        _fetchDataVideo("", homeProvider.categoryid,
            homeProvider.videolistcurrentPage ?? 0);
      }
    }
  }

/* Report Reason Pagination */
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

/* Playlist Pagination */
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

/* First Time Open Page Call This Method */
  getApi() async {
    await await homeProvider.setLoading(true);
    await _fetchDataCategory(0);
    await _fetchDataVideo("1", "0", 0);
    await homeProvider.setLoading(false);
  }

/* Category Api  */
  Future<void> _fetchDataCategory(int? nextPage) async {
    printLog("isMorePage  ======> ${homeProvider.categoryisMorePage}");
    printLog("currentPage ======> ${homeProvider.categorycurrentPage}");
    printLog("totalPage   ======> ${homeProvider.categorytotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await homeProvider.getVideoCategory((nextPage ?? 0) + 1);
  }

/* Video Api  */
  Future<void> _fetchDataVideo(ishomepage, categoryid, int? nextPage) async {
    printLog("isMorePage  ======> ${homeProvider.videolistisMorePage}");
    printLog("currentPage ======> ${homeProvider.videolistcurrentPage}");
    printLog("totalPage   ======> ${homeProvider.videolisttotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await homeProvider.getvideolist(
        ishomepage, categoryid, (nextPage ?? 0) + 1);
  }

/* Report Reason Api */
  Future _fetchReportReason(int? nextPage) async {
    printLog("reportmorePage  =======> ${homeProvider.reportmorePage}");
    printLog("reportcurrentPage =======> ${homeProvider.reportcurrentPage}");
    printLog("reporttotalPage   =======> ${homeProvider.reporttotalPage}");
    printLog("nextPage   ========> $nextPage");
    await homeProvider.getReportReason("2", (nextPage ?? 0) + 1);
    printLog(
        "fetchReportReason length ==> ${homeProvider.reportReasonList?.length}");
  }

/* Playlist Api */
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

  getProfileData() async {
    await generalProvider.getWebGeneralsetting(context);

    if (!mounted) return;
    Utils().getDeviceTokenWithPermissionWeb();

    if (Constant.userID != null) {
      await homeProvider.getprofile(Constant.userID);
      await sharedPre.save(
          "userpanelstatus",
          homeProvider.profileModel.result?[0].userPenalStatus.toString() ??
              "");
      Constant.userPanelStatus = await sharedPre.read("userpanelstatus");

      await Utils.getCustomAdsStatus();
    } else {}
  }

  buildCreateVideoDialog() {
    return showDialog(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 115, vertical: 70),
          backgroundColor: colorPrimaryDark,
          child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorPrimaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const CreateVideo()),
        );
      },
    );
  }

  @override
  void dispose() {
    homeProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printLog("width===> ${MediaQuery.of(context).size.width}");
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: Utils.webAppbarWithSidePanel(
          context: context, contentType: Constant.videoSearch),
      body: Utils.sidePanelWithBody(
        myWidget: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCategory(),
            Expanded(
              child: RefreshIndicator(
                backgroundColor: colorPrimaryDark,
                color: colorPrimary,
                displacement: 70,
                edgeOffset: 1.0,
                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                strokeWidth: 3,
                onRefresh: () async {
                  await homeProvider.clearProvider();
                  getApi();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: videoscrollController,
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 100),
                  child: buildVideo(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 50, right: 40),
        child: FloatingActionButton(
          onPressed: () async {
            await buildCreateVideoDialog();
            setState(() {
              getApi();
            });
          },
          backgroundColor: colorPrimary,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildCategory() {
    return Consumer<HomeProvider>(builder: (context, categoryprovider, child) {
      if (categoryprovider.categoryloading &&
          !categoryprovider.categoryloadMore) {
        return categoryShimmer();
      } else {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          controller: categoryController,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              videocategoryList(),
              if (homeProvider.categoryloadMore)
                const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: colorPrimary,
                      strokeWidth: 1,
                    ))
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      }
    });
  }

  Widget videocategoryList() {
    if (homeProvider.categorymodel.status == 200 &&
        homeProvider.categorydataList != null) {
      if ((homeProvider.categorydataList?.length ?? 0) > 0) {
        return SizedBox(
          height: 65,
          child: ListView.builder(
            itemCount: homeProvider.categorydataList?.length ?? 0,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return InkWell(
                autofocus: false,
                borderRadius: BorderRadius.circular(10),
                highlightColor: appbgcolor,
                focusColor: appbgcolor,
                hoverColor: appbgcolor,
                onTap: () async {
                  homeProvider.selectCategory(index,
                      homeProvider.categorydataList?[index].id.toString());
                  await homeProvider.setVideoLoading(true);
                  if (index == 0) {
                    _fetchDataVideo("1", "0", 0);
                    homeProvider.clearVideoListData();
                  } else {
                    _fetchDataVideo("0",
                        homeProvider.categorydataList?[index].id.toString(), 0);
                    homeProvider.clearVideoListData();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: homeProvider.catindex == index
                        ? colorPrimary
                        : colorPrimaryDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyText(
                        color: homeProvider.catindex == index
                            ? colorAccent
                            : white,
                        text: homeProvider.categorydataList?[index].name ?? "",
                        fontwaight: FontWeight.w500,
                        fontsizeNormal: Dimens.textSmall,
                        fontsizeWeb: Dimens.textSmall,
                        maxline: 1,
                        multilanguage: false,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  ),
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

  Widget categoryShimmer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 65,
      child: ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(5, 10, 5, 15),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return const CustomWidget.roundrectborder(height: 8, width: 100);
        },
      ),
    );
  }

  Widget buildVideo() {
    return Consumer<HomeProvider>(builder: (context, videolistprovider, child) {
      if (videolistprovider.videoloading && !videolistprovider.videoloadMore) {
        return allVideoShimmer();
      } else {
        if (homeProvider.videolistmodel.status == 200 &&
            homeProvider.videoList != null) {
          if ((homeProvider.videoList?.length ?? 0) > 0) {
            return Column(
              children: [
                CustomAds(adType: Constant.bannerAdType),
                const SizedBox(height: 20),
                allVideo(),
                if (homeProvider.videoloadMore)
                  SizedBox(height: 50, child: Utils.pageLoader(context))
                else
                  const SizedBox.shrink(),
              ],
            );
          } else {
            return const NoData(
                title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
          }
        } else {
          return const NoData(
              title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
        }
      }
    });
  }

  Widget allVideo() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: Utils.customCrossAxisCount(
          context: context,
          height1600: 5,
          height1200: 4,
          height800: 3,
          height600: 2),
      maxItemsPerRow: Utils.customCrossAxisCount(
          context: context,
          height1600: 5,
          height1200: 4,
          height800: 3,
          height600: 2),
      horizontalGridSpacing: 15,
      verticalGridSpacing: 25,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
      children: List.generate(
        homeProvider.videoList?.length ?? 0,
        (index) {
          return InkWell(
            highlightColor: transparent,
            hoverColor: transparent,
            splashColor: transparent,
            focusColor: transparent,
            onTap: () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () {
                /* if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {*/
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => WebDetail(
                        stoptime: 0,
                        iscontinueWatching: false,
                        videoid:
                            homeProvider.videoList?[index].id.toString() ?? "",
                        feedType: homeProvider.videoList?[index].contentType
                                .toString() ??
                            ""),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                //     }
              });
            },
            child: InteractiveContainer(child: (isHovered) {
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 180,
                        alignment: Alignment.center,
                        foregroundDecoration: isHovered
                            ? BoxDecoration(
                                gradient: LinearGradient(
                                colors: [
                                  appbgcolor.withOpacity(0.50),
                                  appbgcolor.withOpacity(0.50)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ))
                            : null,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: MyNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.fill,
                              height: MediaQuery.of(context).size.height,
                              imagePath: homeProvider
                                      .videoList?[index].landscapeImg
                                      .toString() ??
                                  ""),
                        ),
                      ),
                      Positioned.fill(
                        right: 15,
                        bottom: 15,
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
                                text: Utils.formatTime(double.parse(homeProvider
                                        .videoList?[index].contentDuration
                                        .toString() ??
                                    "")),
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textSmall,
                                fontsizeWeb: Dimens.textSmall,
                                multilanguage: false,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                        ),
                      ),
                      isHovered
                          ? Positioned.fill(
                              left: 15,
                              right: 15,
                              top: 15,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () {
                                    Utils().showInterstitalAds(
                                        context, Constant.interstialAdType, () {
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
                                        moreBottomSheet(
                                          homeProvider.videoList?[index]
                                                  .landscapeImg
                                                  .toString() ??
                                              "",
                                          homeProvider.videoList?[index].userId
                                                  .toString() ??
                                              "",
                                          homeProvider.videoList?[index].id
                                                  .toString() ??
                                              "",
                                          index,
                                          homeProvider.videoList?[index].title
                                                  .toString() ??
                                              "",
                                        );
                                      }
                                    });
                                  },
                                  child: Icon(
                                    Icons.more_vert_outlined,
                                    color: white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(3, 20, 3, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: MyNetworkImage(
                              width: 32,
                              height: 32,
                              imagePath: homeProvider
                                      .videoList?[index].channelImage
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
                                    text: homeProvider.videoList?[index].title
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textTitle,
                                    fontsizeWeb: Dimens.textTitle,
                                    inter: false,
                                    maxline: 2,
                                    multilanguage: false,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                homeProvider.videoList?[index].channelName
                                            .toString() ==
                                        ""
                                    ? const SizedBox.shrink()
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          MyText(
                                              color: gray,
                                              text: homeProvider
                                                      .videoList?[index]
                                                      .channelName
                                                      .toString() ??
                                                  "",
                                              textalign: TextAlign.left,
                                              fontsizeNormal: Dimens.textMedium,
                                              fontsizeWeb: Dimens.textMedium,
                                              inter: false,
                                              maxline: 2,
                                              multilanguage: false,
                                              fontwaight: FontWeight.w400,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                        ],
                                      ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    MyText(
                                        color: gray,
                                        text: Utils.kmbGenerator(homeProvider
                                                .videoList?[0].totalView ??
                                            0),
                                        textalign: TextAlign.left,
                                        fontsizeNormal: Dimens.textMedium,
                                        fontsizeWeb: Dimens.textMedium,
                                        inter: false,
                                        maxline: 2,
                                        multilanguage: false,
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
                                        maxline: 2,
                                        multilanguage: true,
                                        fontwaight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: MyText(
                                          color: gray,
                                          text: Utils.timeAgoCustom(
                                            DateTime.parse(
                                              homeProvider.videoList?[index]
                                                      .createdAt ??
                                                  "",
                                            ),
                                          ),
                                          textalign: TextAlign.left,
                                          fontsizeNormal: Dimens.textMedium,
                                          fontsizeWeb: Dimens.textMedium,
                                          inter: false,
                                          maxline: 1,
                                          multilanguage: false,
                                          fontwaight: FontWeight.w400,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          );
        },
      ),
    );
  }

  Widget allVideoShimmer() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: Utils.customCrossAxisCount(
          context: context,
          height1600: 5,
          height1200: 4,
          height800: 3,
          height600: 2),
      maxItemsPerRow: Utils.customCrossAxisCount(
          context: context,
          height1600: 5,
          height1200: 4,
          height800: 3,
          height600: 2),
      horizontalGridSpacing: 15,
      verticalGridSpacing: 25,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
      children: List.generate(
        20,
        (index) {
          return Column(
            children: [
              CustomWidget.webImageRound(
                width: MediaQuery.of(context).size.width,
                height: 180,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(3, 20, 3, 20),
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
                            height: 5,
                          ),
                          CustomWidget.roundrectborder(
                            width: 250,
                            height: 5,
                          ),
                          CustomWidget.roundrectborder(
                            width: 250,
                            height: 5,
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
      ),
    );
  } /* More Item Bottom Sheet */

  moreBottomSheet(videoImage, reportUserid, contentid, position, contentName) {
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
              minHeight: 320,
              maxHeight: 350,
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
                            imagePath: videoImage,
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
                    Utils.moreFunctionItem(
                        "ic_watchlater.png", "savetowatchlater", () async {
                      await homeProvider.addremoveWatchLater(
                          "1", contentid, "0", "1");
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      Utils().showSnackBar(context, "savetowatchlater", true);
                    }),
                    Utils.moreFunctionItem(
                        "ic_playlisttitle.png", "savetoplaylist", () async {
                      Navigator.pop(context);
                      selectPlaylistBottomSheet(position, contentid);
                      _fetchPlaylist(0);
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
                minWidth: 400,
                maxWidth: 500,
                minHeight: 450,
                maxHeight: 500,
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
                                "1");
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
            return InkWell(
              onTap: () {
                homeProvider.selectReportReason(index, true,
                    homeProvider.reportReasonList?[index].id.toString() ?? "");
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                color: homeProvider.reportPosition == index &&
                        homeProvider.isSelectReason == true
                    ? colorPrimary
                    : colorPrimaryDark,
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                        color: homeProvider.reportPosition == index &&
                                homeProvider.isSelectReason == true
                            ? colorAccent
                            : white,
                        text: "${(index + 1).toString()}.",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textTitle,
                        fontsizeWeb: Dimens.textTitle,
                        multilanguage: false,
                        inter: false,
                        maxline: 2,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(width: 20),
                    Expanded(
                      child: MyText(
                          color: homeProvider.reportPosition == index &&
                                  homeProvider.isSelectReason == true
                              ? colorAccent
                              : white,
                          text: homeProvider.reportReasonList?[index].reason
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
                    const SizedBox(width: 20),
                    homeProvider.reportPosition == index &&
                            homeProvider.isSelectReason == true
                        ? Icon(
                            Icons.check,
                            color: homeProvider.reportPosition == index &&
                                    homeProvider.isSelectReason == true
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

/* Playlist Bottom Sheet */
  selectPlaylistBottomSheet(position, contentid) {
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
              minWidth: 400,
              maxWidth: 500,
              minHeight: 450,
              maxHeight: 500,
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
                          fontsizeWeb: Dimens.textBig,
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
                                color: colorAccent,
                                size: 22,
                              ),
                              const SizedBox(width: 5),
                              MyText(
                                  color: white,
                                  text: "createplaylist",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textDesc,
                                  fontsizeWeb: Dimens.textDesc,
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
                                playlistprovider.clearPlaylistData();
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
                                      "1",
                                      contentid,
                                      "0",
                                      "1");

                                  if (!homeProvider
                                      .addremovecontentplaylistloading) {
                                    if (homeProvider
                                            .addremoveContentToPlaylistModel
                                            .status ==
                                        200) {
                                      printLog("Added Succsessfully");
                                      Utils().showToast("Save to Playlist");
                                    } else {
                                      Utils().showToast(
                                          "${homeProvider.addremoveContentToPlaylistModel.message}");
                                    }
                                  }
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
          ),
        );
      },
    );
  }

  Widget buildPlayList() {
    return Consumer<HomeProvider>(builder: (context, playlistprovider, child) {
      if (playlistprovider.playlistLoading &&
          !playlistprovider.playlistLoadmore) {
        return Utils.pageLoader(context);
      } else {
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
      }
    });
  }

  Widget buildPlaylistItem() {
    if (homeProvider.getContentbyChannelModel.status == 200 &&
        homeProvider.playlistData != null) {
      if ((homeProvider.playlistData?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: homeProvider.playlistData?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
              onTap: () {
                homeProvider.selectPlaylist(
                    index,
                    homeProvider.playlistData?[index].id.toString() ?? "",
                    true);
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
                        fontsizeWeb: Dimens.textTitle,
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
                          text: homeProvider.playlistData?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          fontsizeWeb: Dimens.textTitle,
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
      } else {
        return const NoData(
            title: "noplaylistfound", subTitle: "createnewplaylist");
      }
    } else {
      return const NoData(
          title: "noplaylistfound", subTitle: "createnewplaylist");
    }
  }

/* Create Playlist Bottom Sheet */
  createPlaylistDilog({playlistId}) {
    printLog("playlistId==> $playlistId");
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
              minWidth: 400,
              maxWidth: 500,
              minHeight: 300,
              maxHeight: 350,
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
                      fontsizeWeb: Dimens.textExtraBig,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 30),
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
                    onSubmitted: (value) {
                      getCreatePlaylistApi();
                    },
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
                          fontsizeWeb: Dimens.textBig,
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
                          fontsizeWeb: Dimens.textBig,
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
                          fontsizeWeb: Dimens.textDesc,
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
                          fontsizeWeb: Dimens.textDesc,
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
                        radius: 15,
                        borderRadius: BorderRadius.circular(15),
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
                            borderRadius: BorderRadius.circular(15),
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
                              fontsizeWeb: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(width: 25),
                      InkWell(
                        radius: 15,
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          getCreatePlaylistApi();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: colorPrimary.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5,
                              )
                            ],
                          ),
                          child: MyText(
                              color: colorAccent,
                              multilanguage: true,
                              text: "create",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              fontsizeWeb: Dimens.textBig,
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

  getCreatePlaylistApi() async {
    if (playlistTitleController.text.isEmpty) {
      Utils().showSnackBar(context, "pleaseenterplaylistname", true);
    } else if (homeProvider.isType == 0) {
      Utils().showSnackBar(context, "pleaseselectplaylisttype", true);
    } else {
      await homeProvider.getcreatePlayList(
        Constant.channelID,
        playlistTitleController.text,
        homeProvider.isType.toString(),
      );
      if (!homeProvider.loading) {
        if (homeProvider.createPlaylistModel.status == 200) {
          if (!mounted) return;
          Utils().showSnackBar(
              context, "${homeProvider.createPlaylistModel.message}", false);
        } else {
          if (!mounted) return;
          Utils().showSnackBar(
              context, "${homeProvider.createPlaylistModel.message}", false);
        }
      }
      if (!mounted) return;
      Navigator.pop(context);
      playlistTitleController.clear();
      homeProvider.isType = 0;
    }
  }
}
