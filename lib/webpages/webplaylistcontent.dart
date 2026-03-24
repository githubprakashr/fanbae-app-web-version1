import 'package:fanbae/pages/contentdetail.dart';
import 'package:fanbae/provider/musicdetailprovider.dart';
import 'package:fanbae/provider/playlistcontentprovider.dart';
import 'package:fanbae/utils/adhelper.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/musicmanager.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/webdetail.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class WebPlaylistContent extends StatefulWidget {
  final String playlistId, title;
  const WebPlaylistContent(
      {super.key, required this.playlistId, required this.title});

  @override
  State<WebPlaylistContent> createState() => WebPlaylistContentState();
}

class WebPlaylistContentState extends State<WebPlaylistContent> {
  final MusicManager musicManager = MusicManager();
  late ScrollController _scrollController;
  late PlaylistContentProvider playlistContentProvider;

  @override
  void initState() {
    playlistContentProvider =
        Provider.of<PlaylistContentProvider>(context, listen: false);
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
        (playlistContentProvider.currentPage ?? 0) <
            (playlistContentProvider.totalPage ?? 0)) {
      await playlistContentProvider.setLoadMore(true);
      if (playlistContentProvider.tabindex == 0) {
        _fetchData("1", playlistContentProvider.currentPage ?? 0);
      } else if (playlistContentProvider.tabindex == 1) {
        _fetchData("2", playlistContentProvider.currentPage ?? 0);
      } else if (playlistContentProvider.tabindex == 2) {
        _fetchData("4", playlistContentProvider.currentPage ?? 0);
      } else if (playlistContentProvider.tabindex == 3) {
        _fetchData("7", playlistContentProvider.currentPage ?? 0);
      } else {
        if (!mounted) return;
        Utils().showSnackBar(context, "Something Went Wronge !!!", false);
      }
    }
  }

  Future<void> _fetchData(contentType, int? nextPage) async {
    printLog("isMorePage  ======> ${playlistContentProvider.isMorePage}");
    printLog("currentPage ======> ${playlistContentProvider.currentPage}");
    printLog("totalPage   ======> ${playlistContentProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await playlistContentProvider.getPlaylistContent(
        widget.playlistId, contentType, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    super.dispose();
    playlistContentProvider.clearProvider();
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
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 190),
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

/* Tab  */

  tabButton() {
    return Consumer<PlaylistContentProvider>(
        builder: (context, playlistcontentprovider, child) {
      return SizedBox(
        height: 100,
        child: ListView.builder(
            itemCount: Constant.selectContentTabList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                focusColor: colorPrimaryDark,
                highlightColor: colorPrimaryDark,
                hoverColor: colorPrimaryDark,
                splashColor: colorPrimaryDark,
                onTap: () async {
                  await playlistcontentprovider.chageTab(index);
                  await playlistcontentprovider.clearTab();
                  if (index == 0) {
                    _fetchData("1", 0);
                  } else if (index == 1) {
                    _fetchData("2", 0);
                  } else if (index == 2) {
                    _fetchData("4", 0);
                  } else if (index == 3) {
                    _fetchData("7", 0);
                  } else {
                    if (!context.mounted) return;
                    Utils().showSnackBar(
                        context, "Something Went Wrong!!!", false);
                  }
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: 250,
                  padding: const EdgeInsets.fromLTRB(25, 0, 15, 0),
                  margin: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: playlistcontentprovider.tabindex == index
                        ? colorPrimary
                        : colorPrimaryDark,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyImage(
                          width: 28,
                          height: 28,
                          color: white,
                          imagePath: Constant.tabIconList[index]),
                      const SizedBox(width: 10),
                      MusicTitle(
                          color: white,
                          multilanguage: true,
                          text: Constant.selectContentTabList[index],
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textBig,
                          fontsizeWeb: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                ),
              );
            }),
      );
    });
  }

/* Tab Item According Perticular Type */
  Widget buildPage() {
    return Consumer<PlaylistContentProvider>(
        builder: (context, playlistcontentprovider, child) {
      if (playlistcontentprovider.loading &&
          !playlistcontentprovider.loadMore) {
        return buildShimmer();
      } else {
        return Column(
          children: [
            buildLayout(),
            if (playlistcontentprovider.loadMore)
              Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                alignment: Alignment.center,
                child: Utils.pageLoader(context),
              )
            else
              const SizedBox.shrink(),
          ],
        );
      }
    });
  }

  buildLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Consumer<PlaylistContentProvider>(
          builder: (context, playlistcontentprovider, child) {
        if (playlistcontentprovider.tabindex == 0 ||
            playlistcontentprovider.tabindex == 3) {
          return buildVideo();
        } else if (playlistcontentprovider.tabindex == 1) {
          return buildMusic();
        } else if (playlistcontentprovider.tabindex == 2) {
          return buildPodcast();
        } /*else if (playlistcontentprovider.tabindex == 3) {
          return buildRadio();
        }*/
        else {
          return const SizedBox.shrink();
        }
      }),
    );
  }

  buildShimmer() {
    return Consumer<PlaylistContentProvider>(
        builder: (context, playlistcontentprovider, child) {
      if (playlistcontentprovider.tabindex == 0 ||
          playlistcontentprovider.tabindex == 3) {
        return buildVideoShimmer();
      } else if (playlistcontentprovider.tabindex == 1) {
        return buildMusicShimmer();
      } else if (playlistcontentprovider.tabindex == 2) {
        return buildPodcastShimmer();
      } /*else if (playlistcontentprovider.tabindex == 3) {
        return buildRadioShimmer();
      }*/
      else {
        return const SizedBox.shrink();
      }
    });
  }

/* Select Video Item */
  Widget buildVideo() {
    if (playlistContentProvider.getPlaylistContentModel.status == 200 &&
        playlistContentProvider.contantList != null) {
      if ((playlistContentProvider.contantList?.length ?? 0) > 0) {
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
            playlistContentProvider.contantList?.length ?? 0,
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
        } else {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => WebDetail(
                  stoptime: 0,
                  iscontinueWatching: false,
                  videoid: playlistContentProvider.contantList?[index].id
                          .toString() ??
                      "",
                  feedType: playlistContentProvider
                          .contantList?[index].contentType
                          .toString() ??
                      ""),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: MyNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                    height: 180,
                    imagePath: playlistContentProvider
                            .contantList?[index].landscapeImg
                            .toString() ??
                        ""),
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
                        text: Utils.formatTime(double.parse(
                            playlistContentProvider
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
              Positioned.fill(
                top: 15,
                left: 15,
                right: 15,
                child: Align(
                  alignment: Alignment.topRight,
                  child: (playlistContentProvider.position == index &&
                          playlistContentProvider.deletecontentPlaylistLoading)
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
                            await playlistContentProvider
                                .addremoveContentToPlaylist(
                                    index,
                                    Constant.channelID,
                                    widget.playlistId,
                                    playlistContentProvider
                                            .contantList?[index].contentType
                                            .toString() ??
                                        "",
                                    playlistContentProvider
                                            .contantList?[index].id
                                            .toString() ??
                                        "",
                                    "0",
                                    "0");
                          },
                          child: MyImage(
                            width: 20,
                            height: 20,
                            imagePath: "ic_delete.png",
                            color: white,
                          ),
                        ),
                ),
              )
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
                    width: 35,
                    height: 35,
                    imagePath: playlistContentProvider
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
                          text: playlistContentProvider
                                  .contantList?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          fontsizeWeb: Dimens.textTitle,
                          inter: false,
                          maxline: 2,
                          multilanguage: false,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text:
                              "${playlistContentProvider.contantList?[index].channelName.toString() ?? ""}  ",
                          style: Utils.googleFontStyle(1, Dimens.textSmall,
                              FontStyle.normal, gray, FontWeight.w400),
                          children: [
                            TextSpan(
                              text:
                                  "${Utils.kmbGenerator(playlistContentProvider.contantList?[0].totalView ?? 0)} ",
                              style: Utils.googleFontStyle(1, Dimens.textSmall,
                                  FontStyle.normal, gray, FontWeight.w400),
                            ),
                            TextSpan(
                              text: 'views ',
                              style: Utils.googleFontStyle(1, Dimens.textSmall,
                                  FontStyle.normal, gray, FontWeight.w400),
                            ),
                            TextSpan(
                              text: Utils.timeAgoCustom(
                                DateTime.parse(
                                  playlistContentProvider
                                          .contantList?[index].createdAt ??
                                      "",
                                ),
                              ),
                              style: Utils.googleFontStyle(1, Dimens.textSmall,
                                  FontStyle.normal, gray, FontWeight.w400),
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
          SizedBox(
            height: 20,
          )
        ],
      ),
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

/* Select Music Item */
  Widget buildMusic() {
    if (playlistContentProvider.getPlaylistContentModel.status == 200 &&
        playlistContentProvider.contantList != null) {
      if ((playlistContentProvider.contantList?.length ?? 0) > 0) {
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
            playlistContentProvider.contantList?.length ?? 0,
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
        AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
          playAudio(
            playingType: playlistContentProvider.contantList?[index].contentType
                    .toString() ??
                "",
            contentList: playlistContentProvider.contantList,
            contentUserid:
                playlistContentProvider.contantList?[index].userId.toString() ??
                    "",
            episodeid:
                playlistContentProvider.contantList?[index].id.toString() ?? "",
            contentid:
                playlistContentProvider.contantList?[index].id.toString() ?? "",
            position: index,
            contentName:
                playlistContentProvider.contantList?[index].title.toString() ??
                    "",
          );
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.80,
        height: 55,
        margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: MyNetworkImage(
                  fit: BoxFit.cover,
                  width: 55,
                  height: 55,
                  imagePath: playlistContentProvider
                          .contantList?[index].portraitImg
                          .toString() ??
                      ""),
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
                      text: playlistContentProvider.contantList?[index].title
                              .toString() ??
                          "",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textDesc,
                      fontsizeWeb: Dimens.textDesc,
                      inter: false,
                      maxline: 2,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 5),
                  MyText(
                      color: gray,
                      multilanguage: false,
                      text: Utils.timeAgoCustom(
                        DateTime.parse(
                          playlistContentProvider
                                  .contantList?[index].createdAt ??
                              "",
                        ),
                      ),
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textSmall,
                      fontsizeWeb: Dimens.textSmall,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (playlistContentProvider.position == index &&
                playlistContentProvider.deletecontentPlaylistLoading)
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
                  /* Remove Watch Later Api */
                  await playlistContentProvider.addremoveContentToPlaylist(
                      index,
                      Constant.channelID,
                      widget.playlistId,
                      playlistContentProvider.contantList?[index].contentType
                              .toString() ??
                          "",
                      playlistContentProvider.contantList?[index].id
                              .toString() ??
                          "",
                      "0",
                      "0");
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    width: 20,
                    height: 20,
                    imagePath: "ic_delete.png",
                    color: white,
                  ),
                ),
              )
          ],
        ),
      ),
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
        20,
        (index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.80,
            height: 60,
            margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
            child: const Row(
              children: [
                CustomWidget.roundrectborder(
                  width: 55,
                  height: 60,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(
                        height: 8,
                      ),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(
                        height: 8,
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

/* Select Podcast Item */
  Widget buildPodcast() {
    if (playlistContentProvider.getPlaylistContentModel.status == 200 &&
        playlistContentProvider.contantList != null) {
      if ((playlistContentProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: playlistContentProvider.contantList?.length ?? 0,
            itemBuilder: (BuildContext ctx, index) {
              return buildPodcastItem(index: index);
            });
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
        AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
          playAudio(
            playingType: playlistContentProvider.contantList?[index].contentType
                    .toString() ??
                "",
            contentList: playlistContentProvider.contantList,
            contentUserid:
                playlistContentProvider.contantList?[index].userId.toString() ??
                    "",
            episodeid:
                playlistContentProvider.contantList?[index].id.toString() ?? "",
            contentid:
                playlistContentProvider.contantList?[index].id.toString() ?? "",
            position: index,
            contentName:
                playlistContentProvider.contantList?[index].title.toString() ??
                    "",
            podcastimage: playlistContentProvider
                    .contantList?[index].portraitImg
                    .toString() ??
                "",
          );
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.80,
        height: 55,
        margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: MyNetworkImage(
                  fit: BoxFit.cover,
                  width: 55,
                  height: 55,
                  imagePath: playlistContentProvider
                          .contantList?[index].portraitImg
                          .toString() ??
                      ""),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                      color: colorPrimary,
                      multilanguage: false,
                      text: playlistContentProvider.contantList?[index].title
                              .toString() ??
                          "",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textDesc,
                      fontsizeWeb: Dimens.textDesc,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 5),
                  MyText(
                      color: white,
                      multilanguage: false,
                      text: Utils.timeAgoCustom(
                        DateTime.parse(
                          playlistContentProvider
                                  .contantList?[index].createdAt ??
                              "",
                        ),
                      ),
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textSmall,
                      fontsizeWeb: Dimens.textSmall,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (playlistContentProvider.position == index &&
                playlistContentProvider.deletecontentPlaylistLoading)
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
                  /* Remove Watch Later Api */
                  await playlistContentProvider.addremoveContentToPlaylist(
                      index,
                      Constant.channelID,
                      widget.playlistId,
                      playlistContentProvider.contantList?[index].contentType
                              .toString() ??
                          "",
                      playlistContentProvider.contantList?[index].id
                              .toString() ??
                          "",
                      "0",
                      "0");
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    width: 20,
                    height: 20,
                    imagePath: "ic_delete.png",
                    color: colorPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildPodcastShimmer() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        itemCount: 15,
        itemBuilder: (BuildContext ctx, index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.80,
            height: 60,
            margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
            child: const Row(
              children: [
                CustomWidget.roundrectborder(
                  width: 55,
                  height: 60,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(
                        height: 8,
                      ),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

/* Select Podcast Item */
  Widget buildRadio() {
    if (playlistContentProvider.getPlaylistContentModel.status == 200 &&
        playlistContentProvider.contantList != null) {
      if ((playlistContentProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: playlistContentProvider.contantList?.length ?? 0,
            itemBuilder: (BuildContext ctx, index) {
              return buildRadioItem(index: index);
            });
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
        AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
          playAudio(
            playingType: playlistContentProvider.contantList?[index].contentType
                    .toString() ??
                "",
            contentList: playlistContentProvider.contantList,
            contentUserid:
                playlistContentProvider.contantList?[index].userId.toString() ??
                    "",
            episodeid:
                playlistContentProvider.contantList?[index].id.toString() ?? "",
            contentid:
                playlistContentProvider.contantList?[index].id.toString() ?? "",
            position: index,
            contentName:
                playlistContentProvider.contantList?[index].title.toString() ??
                    "",
            podcastimage: playlistContentProvider
                    .contantList?[index].portraitImg
                    .toString() ??
                "",
            playlistImages: [],
          );
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.80,
        height: 55,
        margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(55),
              child: MyNetworkImage(
                  fit: BoxFit.cover,
                  width: 55,
                  height: 55,
                  imagePath: playlistContentProvider
                          .contantList?[index].portraitImg
                          .toString() ??
                      ""),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                      color: colorPrimary,
                      multilanguage: false,
                      text: playlistContentProvider.contantList?[index].title
                              .toString() ??
                          "",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textDesc,
                      fontsizeWeb: Dimens.textDesc,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 5),
                  MyText(
                      color: white,
                      multilanguage: false,
                      text: Utils.timeAgoCustom(
                        DateTime.parse(
                          playlistContentProvider
                                  .contantList?[index].createdAt ??
                              "",
                        ),
                      ),
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textSmall,
                      fontsizeWeb: Dimens.textSmall,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (playlistContentProvider.position == index &&
                playlistContentProvider.deletecontentPlaylistLoading)
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
                  /* Remove Watch Later Api */
                  await playlistContentProvider.addremoveContentToPlaylist(
                      index,
                      Constant.channelID,
                      widget.playlistId,
                      playlistContentProvider.contantList?[index].contentType
                              .toString() ??
                          "",
                      playlistContentProvider.contantList?[index].id
                              .toString() ??
                          "",
                      "0",
                      "0");
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    width: 20,
                    height: 20,
                    imagePath: "ic_delete.png",
                    color: colorPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildRadioShimmer() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        itemCount: 15,
        itemBuilder: (BuildContext ctx, index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.80,
            height: 60,
            margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
            child: const Row(
              children: [
                CustomWidget.circular(
                  width: 55,
                  height: 60,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(
                        height: 8,
                      ),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  /* Open Pages */
  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    String? podcastimage,
    String? contentUserid,
    required int position,
    dynamic contentList,
    dynamic playlistImages,
    required String contentName,
    String? isBuy,
  }) async {
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
      printLog("Enter===>");
      /* Play Music */
      if (playingType == "2") {
        musicManager.setInitialMusic(position, playingType, contentList,
            contentid, addView(playingType, contentid), false, 0, isBuy ?? "");
      } else if (playingType == "4") {
        musicManager.setInitialPodcast(
          context,
          episodeid,
          position,
          playingType,
          contentList,
          contentid,
          addView(playingType, contentid),
          false,
          0,
          isBuy ?? "",
          "podcast",
        );
      } else if (playingType == "6") {
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
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
  }
}
