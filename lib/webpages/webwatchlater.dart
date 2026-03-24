import 'package:flutter/foundation.dart';
import 'package:fanbae/provider/musicdetailprovider.dart';
import 'package:fanbae/provider/watchlaterprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customads.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/musicmanager.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/webcontentdetail.dart';
import 'package:fanbae/webpages/webdetail.dart';
import 'package:fanbae/webpages/webshorts.dart';
import 'package:fanbae/webwidget/interactivecontainer.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../utils/adhelper.dart';
import '../utils/responsive_helper.dart';

class WebWatchLater extends StatefulWidget {
  const WebWatchLater({super.key});

  @override
  State<WebWatchLater> createState() => WebWatchLaterState();
}

class WebWatchLaterState extends State<WebWatchLater> {
  late ScrollController _scrollController;
  late WatchLaterProvider watchLaterProvider;
  final MusicManager musicManager = MusicManager();

  @override
  void initState() {
    watchLaterProvider =
        Provider.of<WatchLaterProvider>(context, listen: false);
    _fetchData("1", 0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (watchLaterProvider.currentPage ?? 0) <
            (watchLaterProvider.totalPage ?? 0)) {
      await watchLaterProvider.setLoadMore(true);
      if (watchLaterProvider.tabindex == 0) {
        _fetchData("1", watchLaterProvider.currentPage ?? 0);
      } else if (watchLaterProvider.tabindex == 1) {
        _fetchData("2", watchLaterProvider.currentPage ?? 0);
      } else if (watchLaterProvider.tabindex == 2) {
        _fetchData("3", watchLaterProvider.currentPage ?? 0);
      } else if (watchLaterProvider.tabindex == 3) {
        _fetchData("4", watchLaterProvider.currentPage ?? 0);
      } else if (watchLaterProvider.tabindex == 4) {
        _fetchData("7", watchLaterProvider.currentPage ?? 0);
      } else {
        if (!mounted) return;
        Utils().showSnackBar(context, "somethingwentwronge", true);
      }
    }
  }

  Future<void> _fetchData(contentType, int? nextPage) async {
    printLog("isMorePage  ======> ${watchLaterProvider.isMorePage}");
    printLog("currentPage ======> ${watchLaterProvider.currentPage}");
    printLog("totalPage   ======> ${watchLaterProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await watchLaterProvider.getContentByWatchLater(
        contentType, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    super.dispose();
    watchLaterProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: Utils.webAppbarWithSidePanel(
          context: context, contentType: Constant.videoSearch),
      body: Utils.sidePanelWithBody(
        myWidget: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 100),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tabButton(),
              buildPage(),
            ],
          ),
        ),
      ),
    );
  }

/* Tab */

  tabButton() {
    return Consumer<WatchLaterProvider>(
        builder: (context, watchlaterprovider, child) {
      return SizedBox(
        height: 100,
        child: ListView.builder(
          itemCount: Constant.watchlaterTabList.length,
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return InkWell(
              focusColor: appbgcolor,
              highlightColor: appbgcolor,
              hoverColor: appbgcolor,
              splashColor: appbgcolor,
              onTap: () async {
                await watchlaterprovider.chageTab(index);
                watchlaterprovider.clearTab();
                if (index == 0) {
                  _fetchData("1", 0);
                } else if (index == 1) {
                  _fetchData("2", 0);
                } else if (index == 2) {
                  _fetchData("3", 0);
                } else if (index == 3) {
                  _fetchData("4", 0);
                  printLog(
                      "length=====> ${watchLaterProvider.contantList?.length ?? 0}");
                } else if (index == 4) {
                  _fetchData("7", 0);
                } else {
                  if (!context.mounted) return;
                  Utils()
                      .showSnackBar(context, "Something Went Wrong!!!", false);
                }
              },
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: 200,
                padding: const EdgeInsets.fromLTRB(25, 0, 15, 0),
                margin: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: watchlaterprovider.tabindex == index
                      ? colorPrimary
                      : colorPrimaryDark,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: InteractiveContainer(child: (isHovered) {
                  return AnimatedScale(
                    scale: isHovered ? 1.2 : 1,
                    alignment: Alignment.centerLeft,
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyImage(
                            width: 28,
                            height: 28,
                            color: watchlaterprovider.tabindex == index
                                ? colorAccent
                                : white,
                            imagePath: Constant.watchlaterTabIconList[index]),
                        const SizedBox(width: 10),
                        MusicTitle(
                            color: watchlaterprovider.tabindex == index
                                ? colorAccent
                                : white,
                            multilanguage: true,
                            text: Constant.watchlaterTabList[index],
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textBig,
                            fontsizeWeb: Dimens.textBig,
                            maxline: 1,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                  );
                }),
              ),
            );
          },
        ),
      );
    });
  }

/* Tab Item According Perticular Type */
  Widget buildPage() {
    return Consumer<WatchLaterProvider>(
        builder: (context, watchlaterprovider, child) {
      if (watchlaterprovider.loading && !watchlaterprovider.loadMore) {
        return buildShimmer();
      } else {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 15, 10, 15),
          child: Column(
            children: [
              CustomAds(adType: Constant.bannerAdType),
              const SizedBox(height: 20),
              buildLayout(),
              if (watchlaterprovider.loadMore)
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                  alignment: Alignment.center,
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

  buildLayout() {
    return Consumer<WatchLaterProvider>(
        builder: (context, watchlaterprovider, child) {
      if (watchlaterprovider.tabindex == 0 ||
          watchlaterprovider.tabindex == 4) {
        return buildVideo();
      } else if (watchlaterprovider.tabindex == 1) {
        return buildMusic();
      } else if (watchlaterprovider.tabindex == 2) {
        return buildReels();
      } else if (watchlaterprovider.tabindex == 3) {
        return buildPodcast();
      } /*else if (watchlaterprovider.tabindex == 4) {
        return buildRadio();
      }*/
      else {
        return const SizedBox.shrink();
      }
    });
  }

  buildShimmer() {
    return Consumer<WatchLaterProvider>(
        builder: (context, watchlaterprovider, child) {
      if (watchlaterprovider.tabindex == 0 ||
          watchlaterprovider.tabindex == 4) {
        return buildVideoShimmer();
      } else if (watchlaterprovider.tabindex == 1) {
        return buildMusicShimmer();
      } else if (watchlaterprovider.tabindex == 2) {
        return buildReelsShimmer();
      } else if (watchlaterprovider.tabindex == 3) {
        return buildPodcastShimmer();
      } /* else if (watchlaterprovider.tabindex == 4) {
        return buildRadioShimmer();
      }*/
      else {
        return const SizedBox.shrink();
      }
    });
  }

/*  Video Item */
  Widget buildVideo() {
    if (watchLaterProvider.watchlaterModel.status == 200 &&
        watchLaterProvider.contantList != null) {
      if ((watchLaterProvider.contantList?.length ?? 0) > 0) {
        return ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.crossAxisCount(context),
          maxItemsPerRow: Utils.crossAxisCount(context),
          horizontalGridSpacing: 15,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
          ),
          children: List.generate(
            watchLaterProvider.contantList?.length ?? 0,
            (index) {
              return buildVideoItem(index: index);
            },
          ),
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

  Widget buildVideoItem({required int index}) {
    return InkWell(
      onTap: () {
        if (ResponsiveHelper.checkIsWeb(context)) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => WebDetail(
                  stoptime: 0,
                  iscontinueWatching: false,
                  videoid:
                      watchLaterProvider.contantList?[index].id.toString() ??
                          "",
                  feedType: watchLaterProvider.contantList?[index].contentType
                          .toString() ??
                      ""),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else {
          AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
            Utils.moveToDetail(
                context,
                0,
                false,
                watchLaterProvider.contantList?[index].id.toString() ?? "",
                false,
                watchLaterProvider.contantList?[index].contentType.toString() ??
                    "",
                watchLaterProvider.contantList?[index].isComment);
          });
        }
      },
      child: InteractiveContainer(child: (isHovered) {
        return Column(
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 180,
                  foregroundDecoration: isHovered
                      ? BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              appbgcolor.withOpacity(0.50),
                              appbgcolor.withOpacity(0.50)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        )
                      : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: MyNetworkImage(
                        fit: BoxFit.fill,
                        imagePath: watchLaterProvider
                                .contantList?[index].landscapeImg
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
                      child: MyText(
                          color: white,
                          text: Utils.formatTime(double.parse(watchLaterProvider
                                  .contantList?[index].contentDuration
                                  .toString() ??
                              "")),
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
                MediaQuery.of(context).size.width > 1050
                    ? Positioned.fill(
                        top: 15,
                        right: 15,
                        left: 15,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: isHovered
                              ? (watchLaterProvider.position == index &&
                                      watchLaterProvider
                                          .deleteWatchlaterloading)
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: colorPrimary,
                                        strokeWidth: 1,
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        /* Remove Watch Later Api */
                                        await watchLaterProvider
                                            .addremoveWatchLater(
                                                index,
                                                watchLaterProvider
                                                        .contantList?[index]
                                                        .contentType
                                                        .toString() ??
                                                    "",
                                                watchLaterProvider
                                                        .contantList?[index].id
                                                        .toString() ??
                                                    "",
                                                "0",
                                                "0");
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: MyImage(
                                          width: 20,
                                          height: 20,
                                          imagePath: "ic_delete.png",
                                          color: white,
                                        ),
                                      ),
                                    )
                              : const SizedBox.shrink(),
                        ),
                      )
                    : Positioned.fill(
                        top: 15,
                        right: 15,
                        left: 15,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: (watchLaterProvider.position == index &&
                                  watchLaterProvider.deleteWatchlaterloading)
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: colorPrimary,
                                    strokeWidth: 1,
                                  ),
                                )
                              : InkWell(
                                  onTap: () async {
                                    /* Remove Watch Later Api */
                                    await watchLaterProvider
                                        .addremoveWatchLater(
                                            index,
                                            watchLaterProvider
                                                    .contantList?[index]
                                                    .contentType
                                                    .toString() ??
                                                "",
                                            watchLaterProvider
                                                    .contantList?[index].id
                                                    .toString() ??
                                                "",
                                            "0",
                                            "0");
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: MyImage(
                                      width: 20,
                                      height: 20,
                                      imagePath: "ic_delete.png",
                                      color: white,
                                    ),
                                  ),
                                ),
                        ),
                      ),
              ],
            ),
            Padding(
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
                      imagePath: watchLaterProvider
                              .contantList?[index].channelImage
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
                            text: watchLaterProvider.contantList?[index].title
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
                        watchLaterProvider.contantList?[index].channelName
                                    .toString() ==
                                ""
                            ? const SizedBox.shrink()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  MyText(
                                      color: gray,
                                      text: watchLaterProvider
                                              .contantList?[index].channelName
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
                                text: Utils.kmbGenerator(watchLaterProvider
                                        .contantList?[0].totalView ??
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
                            MyText(
                                color: gray,
                                text: Utils.timeAgoCustom(
                                  DateTime.parse(
                                    watchLaterProvider
                                            .contantList?[index].createdAt ??
                                        "",
                                  ),
                                ),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget buildVideoShimmer() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: Utils.crossAxisCount(context),
      maxItemsPerRow: Utils.crossAxisCount(context),
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
  }

/*  Music Item */
  Widget buildMusic() {
    if (watchLaterProvider.watchlaterModel.status == 200 &&
        watchLaterProvider.contantList != null) {
      if ((watchLaterProvider.contantList?.length ?? 0) > 0) {
        return ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 3,
              height1200: 3,
              height800: 2,
              height600: 1),
          maxItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 3,
              height1200: 3,
              height800: 2,
              height600: 1),
          horizontalGridSpacing: 5,
          verticalGridSpacing: 15,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            watchLaterProvider.contantList?.length ?? 0,
            (index) {
              return buildMusicItem(index: index);
            },
          ),
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

  Widget buildMusicItem({required int index}) {
    return InkWell(
      onTap: () {
        playAudio(
          playingType:
              watchLaterProvider.contantList?[index].contentType.toString() ??
                  "",
          episodeid: watchLaterProvider.contantList?[index].id.toString() ?? "",
          contentid: watchLaterProvider.contantList?[index].id.toString() ?? "",
          contentDiscription:
              watchLaterProvider.contantList?[index].description.toString() ??
                  "",
          position: index,
          sectionBannerList: watchLaterProvider.contantList ?? [],
          contentName:
              watchLaterProvider.contantList?[index].title.toString() ?? "",
          isBuy: watchLaterProvider.contantList?[index].isBuy.toString() ?? "",
        );
      },
      child: InteractiveContainer(child: (isHovered) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.80,
          height: 55,
          margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    foregroundDecoration: isHovered
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                appbgcolor.withOpacity(0.50),
                                appbgcolor.withOpacity(0.50)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          )
                        : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: MyNetworkImage(
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          imagePath: watchLaterProvider
                                  .contantList?[index].portraitImg
                                  .toString() ??
                              ""),
                    ),
                  ),
                  MediaQuery.of(context).size.width > 1050
                      ? Positioned.fill(
                          top: 15,
                          right: 15,
                          left: 15,
                          child: Align(
                            alignment: Alignment.center,
                            child: isHovered
                                ? (watchLaterProvider.position == index &&
                                        watchLaterProvider
                                            .deleteWatchlaterloading)
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: colorPrimary,
                                          strokeWidth: 1,
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () async {
                                          /* Remove Watch Later Api */
                                          await watchLaterProvider
                                              .addremoveWatchLater(
                                                  index,
                                                  watchLaterProvider
                                                          .contantList?[index]
                                                          .contentType
                                                          .toString() ??
                                                      "",
                                                  watchLaterProvider
                                                          .contantList?[index]
                                                          .id
                                                          .toString() ??
                                                      "",
                                                  "0",
                                                  "0");
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: MyImage(
                                            width: 20,
                                            height: 20,
                                            imagePath: "ic_delete.png",
                                            color: white,
                                          ),
                                        ),
                                      )
                                : const SizedBox.shrink(),
                          ),
                        )
                      : Positioned.fill(
                          top: 15,
                          right: 15,
                          left: 15,
                          child: Align(
                            alignment: Alignment.center,
                            child: (watchLaterProvider.position == index &&
                                    watchLaterProvider.deleteWatchlaterloading)
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: colorPrimary,
                                      strokeWidth: 1,
                                    ),
                                  )
                                : InkWell(
                                    onTap: () async {
                                      /* Remove Watch Later Api */
                                      await watchLaterProvider
                                          .addremoveWatchLater(
                                              index,
                                              watchLaterProvider
                                                      .contantList?[index]
                                                      .contentType
                                                      .toString() ??
                                                  "",
                                              watchLaterProvider
                                                      .contantList?[index].id
                                                      .toString() ??
                                                  "",
                                              "0",
                                              "0");
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: MyImage(
                                        width: 20,
                                        height: 20,
                                        imagePath: "ic_delete.png",
                                        color: white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                ],
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
                        text: watchLaterProvider.contantList?[index].title
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textDesc,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 5),
                    MyText(
                        color: gray,
                        multilanguage: false,
                        text: Utils.timeAgoCustom(
                          DateTime.parse(
                            watchLaterProvider.contantList?[index].createdAt ??
                                "",
                          ),
                        ),
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textSmall,
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
        );
      }),
    );
  }

  Widget buildMusicShimmer() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: Utils.customCrossAxisCount(
          context: context,
          height1600: 3,
          height1200: 3,
          height800: 2,
          height600: 1),
      maxItemsPerRow: Utils.customCrossAxisCount(
          context: context,
          height1600: 3,
          height1200: 3,
          height800: 2,
          height600: 1),
      horizontalGridSpacing: 5,
      verticalGridSpacing: 15,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(
        30,
        (index) {
          return Container(
            width: 400,
            height: 55,
            margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: const CustomWidget.roundrectborder(
                    width: 50,
                    height: 50,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(
                      width: 200,
                      height: 5,
                    ),
                    SizedBox(height: 8),
                    CustomWidget.roundrectborder(
                      width: 200,
                      height: 5,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

/* Shorts Item */
  Widget buildReels() {
    if (watchLaterProvider.watchlaterModel.status == 200 &&
        watchLaterProvider.contantList != null) {
      if ((watchLaterProvider.contantList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: Utils.customCrossAxisCount(
                context: context,
                height1600: 7,
                height1200: 6,
                height800: 4,
                height600: 2),
            maxItemsPerRow: Utils.customCrossAxisCount(
                context: context,
                height1600: 7,
                height1200: 6,
                height800: 4,
                height600: 2),
            horizontalGridSpacing: 15,
            verticalGridSpacing: 25,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(watchLaterProvider.contantList?.length ?? 0,
                (index) {
              return buildReelsItem(index: index);
            }),
          ),
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

  Widget buildReelsItem({required int index}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => WebShorts(
              initialIndex: index,
              shortType: "watchlater",
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: InteractiveContainer(child: (isHovered) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 350,
                  foregroundDecoration: isHovered
                      ? BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              appbgcolor.withOpacity(0.50),
                              appbgcolor.withOpacity(0.50)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        )
                      : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: MyNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                      imagePath: watchLaterProvider
                              .contantList?[index].portraitImg
                              .toString() ??
                          "",
                    ),
                  ),
                ),
                MediaQuery.of(context).size.width > 1050
                    ? Positioned.fill(
                        top: 15,
                        right: 15,
                        left: 15,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: isHovered
                              ? (watchLaterProvider.position == index &&
                                      watchLaterProvider
                                          .deleteWatchlaterloading)
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: colorPrimary,
                                        strokeWidth: 1,
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        /* Remove Watch Later Api */
                                        await watchLaterProvider
                                            .addremoveWatchLater(
                                                index,
                                                watchLaterProvider
                                                        .contantList?[index]
                                                        .contentType
                                                        .toString() ??
                                                    "",
                                                watchLaterProvider
                                                        .contantList?[index].id
                                                        .toString() ??
                                                    "",
                                                "0",
                                                "0");
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: MyImage(
                                          width: 20,
                                          height: 20,
                                          imagePath: "ic_delete.png",
                                          color: white,
                                        ),
                                      ),
                                    )
                              : const SizedBox.shrink(),
                        ),
                      )
                    : Positioned.fill(
                        top: 15,
                        right: 15,
                        left: 15,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: (watchLaterProvider.position == index &&
                                  watchLaterProvider.deleteWatchlaterloading)
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: colorPrimary,
                                    strokeWidth: 1,
                                  ),
                                )
                              : InkWell(
                                  onTap: () async {
                                    /* Remove Watch Later Api */
                                    await watchLaterProvider
                                        .addremoveWatchLater(
                                            index,
                                            watchLaterProvider
                                                    .contantList?[index]
                                                    .contentType
                                                    .toString() ??
                                                "",
                                            watchLaterProvider
                                                    .contantList?[index].id
                                                    .toString() ??
                                                "",
                                            "0",
                                            "0");
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: MyImage(
                                      width: 20,
                                      height: 20,
                                      imagePath: "ic_delete.png",
                                      color: white,
                                    ),
                                  ),
                                ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 10),
            MyText(
                color: white,
                text: watchLaterProvider.contantList?[index].title.toString() ??
                    "",
                textalign: TextAlign.left,
                fontsizeNormal: Dimens.textMedium,
                fontsizeWeb: Dimens.textMedium,
                inter: false,
                multilanguage: false,
                maxline: 2,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
          ],
        );
      }),
    );
  }

  Widget buildReelsShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 7,
              height1200: 6,
              height800: 4,
              height600: 2),
          maxItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 7,
              height1200: 6,
              height800: 4,
              height600: 2),
          horizontalGridSpacing: 15,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(14, (index) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.roundrectborder(
                  height: 350,
                ),
                SizedBox(height: 10),
                CustomWidget.roundrectborder(
                  width: 150,
                  height: 6,
                ),
                CustomWidget.roundrectborder(
                  width: 150,
                  height: 6,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

/* Podcast Item */
  Widget buildPodcast() {
    printLog(
        "buildPodcast=====> ${watchLaterProvider.contantList?.length ?? 0}");
    if (watchLaterProvider.watchlaterModel.status == 200 &&
        watchLaterProvider.contantList != null) {
      if ((watchLaterProvider.contantList?.length ?? 0) > 0) {
        return ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 5,
              height1200: 4,
              height800: 3,
              height600: 1),
          maxItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 5,
              height1200: 4,
              height800: 3,
              height600: 1),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            watchLaterProvider.contantList?.length ?? 0,
            (index) {
              return buildPodcastItem(index: index);
            },
          ),
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

  Widget buildPodcastItem({required int index}) {
    return InkWell(
      onTap: () {
        playAudio(
          playingType:
              watchLaterProvider.contantList?[index].contentType.toString() ??
                  "",
          episodeid: watchLaterProvider.contantList?[index].episode?[0].id
                  .toString() ??
              "",
          contentid: watchLaterProvider.contantList?[index].id.toString() ?? "",
          contentDiscription:
              watchLaterProvider.contantList?[index].description.toString() ??
                  "",
          position: index,
          contentName: watchLaterProvider.contantList?[index].episode?[0].name
                  .toString() ??
              "",
          isBuy: watchLaterProvider.contantList?[index].isBuy.toString() ?? "",
          sectionBannerList: watchLaterProvider.contantList ?? [],
          podcastimage:
              watchLaterProvider.contantList?[index].portraitImg.toString() ??
                  "",
        );
      },
      child: InteractiveContainer(child: (isHovered) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  foregroundDecoration: isHovered
                      ? BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              appbgcolor.withOpacity(0.50),
                              appbgcolor.withOpacity(0.50)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        )
                      : null,
                  width: MediaQuery.of(context).size.width,
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MyNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                      imagePath: watchLaterProvider
                              .contantList?[index].episode?[0].portraitImg ??
                          "",
                    ),
                  ),
                ),

                /* PlayButton */
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: isHovered
                        ? Icon(
                            Icons.play_arrow,
                            color: white,
                            size: 45,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),

                /* Delete Button  */
                MediaQuery.of(context).size.width > 1050
                    ? Positioned.fill(
                        top: 15,
                        right: 15,
                        left: 15,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: isHovered
                              ? (watchLaterProvider.position == index &&
                                      watchLaterProvider
                                          .deleteWatchlaterloading)
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: colorPrimary,
                                        strokeWidth: 1,
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        /* Remove Watch Later Api */
                                        await watchLaterProvider
                                            .addremoveWatchLater(
                                                index,
                                                watchLaterProvider
                                                        .contantList?[index]
                                                        .contentType
                                                        .toString() ??
                                                    "",
                                                watchLaterProvider
                                                        .contantList?[index].id
                                                        .toString() ??
                                                    "",
                                                watchLaterProvider
                                                        .contantList?[index]
                                                        .episode?[0]
                                                        .id
                                                        .toString() ??
                                                    "",
                                                "0");
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: MyImage(
                                          width: 20,
                                          height: 20,
                                          imagePath: "ic_delete.png",
                                          color: white,
                                        ),
                                      ),
                                    )
                              : const SizedBox.shrink(),
                        ),
                      )
                    : Positioned.fill(
                        top: 15,
                        right: 15,
                        left: 15,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: (watchLaterProvider.position == index &&
                                  watchLaterProvider.deleteWatchlaterloading)
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: colorPrimary,
                                    strokeWidth: 1,
                                  ),
                                )
                              : InkWell(
                                  onTap: () async {
                                    /* Remove Watch Later Api */
                                    await watchLaterProvider
                                        .addremoveWatchLater(
                                            index,
                                            watchLaterProvider
                                                    .contantList?[index]
                                                    .contentType
                                                    .toString() ??
                                                "",
                                            watchLaterProvider
                                                    .contantList?[index].id
                                                    .toString() ??
                                                "",
                                            watchLaterProvider
                                                    .contantList?[index]
                                                    .episode?[0]
                                                    .id
                                                    .toString() ??
                                                "",
                                            "0");
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: MyImage(
                                      width: 20,
                                      height: 20,
                                      imagePath: "ic_delete.png",
                                      color: white,
                                    ),
                                  ),
                                ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 15),
            MyText(
                color: white,
                text: watchLaterProvider.contantList?[index].episode?[0].name ??
                    "",
                textalign: TextAlign.left,
                fontsizeNormal: Dimens.textMedium,
                fontsizeWeb: Dimens.textMedium,
                inter: false,
                multilanguage: false,
                maxline: 2,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
          ],
        );
      }),
    );
  }

  Widget buildPodcastShimmer() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: Utils.customCrossAxisCount(
          context: context,
          height1600: 5,
          height1200: 4,
          height800: 3,
          height600: 1),
      maxItemsPerRow: Utils.customCrossAxisCount(
          context: context,
          height1600: 5,
          height1200: 4,
          height800: 3,
          height600: 1),
      horizontalGridSpacing: 10,
      verticalGridSpacing: 25,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
      ),
      children: List.generate(
        20,
        (index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget.roundrectborder(
                width: MediaQuery.of(context).size.width,
                height: 180,
              ),
              const SizedBox(height: 15),
              const CustomWidget.roundrectborder(
                width: 200,
                height: 5,
              ),
              const CustomWidget.roundrectborder(
                width: 200,
                height: 5,
              ),
            ],
          );
        },
      ),
    );
  }

/* Radio Item */
  Widget buildRadio() {
    if (watchLaterProvider.watchlaterModel.status == 200 &&
        watchLaterProvider.contantList != null) {
      if ((watchLaterProvider.contantList?.length ?? 0) > 0) {
        return ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: Utils.customCrossAxisCount(
                context: context,
                height1600: 8,
                height1200: 6,
                height800: 4,
                height600: 2),
            maxItemsPerRow: Utils.customCrossAxisCount(
                context: context,
                height1600: 8,
                height1200: 6,
                height800: 4,
                height600: 2),
            horizontalGridSpacing: 25,
            verticalGridSpacing: 25,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(watchLaterProvider.contantList?.length ?? 0,
                (index) {
              return buildRadioItem(index: index);
            }));
      } else {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

  Widget buildRadioItem({required int index}) {
    return InkWell(
      onTap: () {
        playAudio(
          playingType:
              watchLaterProvider.contantList?[index].contentType.toString() ??
                  "",
          episodeid: watchLaterProvider.contantList?[index].id.toString() ?? "",
          contentid: watchLaterProvider.contantList?[index].id.toString() ?? "",
          contentDiscription:
              watchLaterProvider.contantList?[index].description.toString() ??
                  "",
          position: index,
          contentName:
              watchLaterProvider.contantList?[index].title.toString() ?? "",
          isBuy: watchLaterProvider.contantList?[index].isBuy.toString() ?? "",
          sectionBannerList: watchLaterProvider.contantList,
          contentUserid:
              watchLaterProvider.contantList?[index].userId.toString() ?? "",
          playlistImages: [],
          podcastimage:
              watchLaterProvider.contantList?[index].portraitImg.toString() ??
                  "",
        );
      },
      child: InteractiveContainer(child: (isHovered) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    foregroundDecoration: isHovered
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                appbgcolor.withOpacity(0.50),
                                appbgcolor.withOpacity(0.50)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          )
                        : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: MyNetworkImage(
                        fit: BoxFit.cover,
                        imagePath: watchLaterProvider
                                .contantList?[index].portraitImg
                                .toString() ??
                            "",
                      ),
                    ),
                  ),

                  /* Delete Button  */
                  MediaQuery.of(context).size.width > 1050
                      ? Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: isHovered
                                ? (watchLaterProvider.position == index &&
                                        watchLaterProvider
                                            .deleteWatchlaterloading)
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: colorPrimary,
                                          strokeWidth: 1,
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () async {
                                          /* Remove Watch Later Api */
                                          await watchLaterProvider
                                              .addremoveWatchLater(
                                                  index,
                                                  watchLaterProvider
                                                          .contantList?[index]
                                                          .contentType
                                                          .toString() ??
                                                      "",
                                                  watchLaterProvider
                                                          .contantList?[index]
                                                          .id
                                                          .toString() ??
                                                      "",
                                                  "0",
                                                  "0");
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: MyImage(
                                            width: 20,
                                            height: 20,
                                            imagePath: "ic_delete.png",
                                            color: white,
                                          ),
                                        ),
                                      )
                                : const SizedBox.shrink(),
                          ),
                        )
                      : Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: (watchLaterProvider.position == index &&
                                    watchLaterProvider.deleteWatchlaterloading)
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: colorPrimary,
                                      strokeWidth: 1,
                                    ),
                                  )
                                : InkWell(
                                    onTap: () async {
                                      /* Remove Watch Later Api */
                                      await watchLaterProvider
                                          .addremoveWatchLater(
                                              index,
                                              watchLaterProvider
                                                      .contantList?[index]
                                                      .contentType
                                                      .toString() ??
                                                  "",
                                              watchLaterProvider
                                                      .contantList?[index].id
                                                      .toString() ??
                                                  "",
                                              "0",
                                              "0");
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: MyImage(
                                        width: 20,
                                        height: 20,
                                        imagePath: "ic_delete.png",
                                        color: white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 100,
                child: MyText(
                    color: white,
                    text: watchLaterProvider.contantList?[index].title
                            .toString() ??
                        "",
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textMedium,
                    fontsizeWeb: Dimens.textMedium,
                    inter: false,
                    multilanguage: false,
                    maxline: 1,
                    fontwaight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildRadioShimmer() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: Utils.customCrossAxisCount(
          context: context,
          height1600: 8,
          height1200: 6,
          height800: 4,
          height600: 2),
      maxItemsPerRow: Utils.customCrossAxisCount(
          context: context,
          height1600: 8,
          height1200: 6,
          height800: 4,
          height600: 2),
      horizontalGridSpacing: 25,
      verticalGridSpacing: 25,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(
        25,
        (index) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              children: [
                CustomWidget.circular(
                  width: 130,
                  height: 130,
                ),
                SizedBox(height: 8),
                CustomWidget.roundrectborder(
                  width: 100,
                  height: 5,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

/* PlayAudio Methods */
  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    String? podcastimage,
    String? contentDiscription,
    String? contentUserid,
    required int position,
    dynamic sectionBannerList,
    dynamic playlistImages,
    required String contentName,
    required String? isBuy,
  }) async {
    /* Only Music Direct Play*/
    if (playingType == "2") {
      musicManager.setInitialMusic(position, playingType, sectionBannerList,
          contentid, addView(playingType, contentid), false, 0, isBuy ?? "");
      /* Otherwise Open Perticular ContaentDetail Page  */
    } else if (playingType == "4") {
      printLog("Enter Podvast");
      musicManager.setInitialPodcastEpisode(
          context,
          episodeid,
          position,
          playingType,
          sectionBannerList,
          contentid,
          addView(playingType, contentid),
          false,
          0,
          isBuy ?? "",
          "episode");
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => WebContentDetail(
            contentType: playingType,
            contentUserid: contentUserid ?? "",
            contentImage: podcastimage ?? "",
            contentName: contentName,
            playlistImage: playlistImages ?? [],
            contentId: contentid,
            isBuy: isBuy ?? "",
            contentDiscription: contentDiscription ?? "",
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
  }
}
