import 'dart:developer';
import 'dart:io';
import 'package:fanbae/provider/getmusicbycategoryprovider.dart';
import 'package:fanbae/provider/musicdetailprovider.dart';
import 'package:fanbae/utils/adhelper.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/musicmanager.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class GetMusicByCategoryWeb extends StatefulWidget {
  final String categoryId, title;
  const GetMusicByCategoryWeb({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  State<GetMusicByCategoryWeb> createState() => GetMusicByCategoryWebState();
}

class GetMusicByCategoryWebState extends State<GetMusicByCategoryWeb> {
  final MusicManager musicManager = MusicManager();
  late GetMusicByCategoryProvider getMusicByCategoryProvider;
  late ScrollController _scrollController;
  late ScrollController playlistController;
  final playlistTitleController = TextEditingController();

  @override
  void initState() {
    getMusicByCategoryProvider =
        Provider.of<GetMusicByCategoryProvider>(context, listen: false);
    _fetchData(0);
    _scrollController = ScrollController();
    playlistController = ScrollController();
    _scrollController.addListener(_scrollListener);
    playlistController.addListener(_scrollListenerPlaylist);
    super.initState();
  }

  /* Category All Music Pagination */
  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (getMusicByCategoryProvider.currentPage ?? 0) <
            (getMusicByCategoryProvider.totalPage ?? 0)) {
      printLog("load more====>");
      getMusicByCategoryProvider.setLoadMore(true);
      _fetchData(getMusicByCategoryProvider.currentPage ?? 0);
    }
  }

  /* Playlist Pagination */
  _scrollListenerPlaylist() async {
    if (!playlistController.hasClients) return;
    if (playlistController.offset >=
            playlistController.position.maxScrollExtent &&
        !playlistController.position.outOfRange &&
        (getMusicByCategoryProvider.playlistcurrentPage ?? 0) <
            (getMusicByCategoryProvider.playlisttotalPage ?? 0)) {
      await getMusicByCategoryProvider.setPlaylistLoadMore(true);
      _fetchPlaylist(getMusicByCategoryProvider.playlistcurrentPage ?? 0);
    }
  }

  /* Get All Category Music Api */
  Future<void> _fetchData(int? nextPage) async {
    printLog("isMorePage  ======> ${getMusicByCategoryProvider.isMorePage}");
    printLog("currentPage ======> ${getMusicByCategoryProvider.currentPage}");
    printLog("totalPage   ======> ${getMusicByCategoryProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await getMusicByCategoryProvider.getMusicbyCategory(
        widget.categoryId, (nextPage ?? 0) + 1);
  }

  /* Playlist Api */
  Future _fetchPlaylist(int? nextPage) async {
    printLog(
        "playlistmorePage  =======> ${getMusicByCategoryProvider.playlistmorePage}");
    printLog(
        "playlistcurrentPage =======> ${getMusicByCategoryProvider.playlistcurrentPage}");
    printLog(
        "playlisttotalPage   =======> ${getMusicByCategoryProvider.playlisttotalPage}");
    printLog("nextPage   ========> $nextPage");
    await getMusicByCategoryProvider.getcontentbyChannel(
        Constant.userID, Constant.channelID, "5", (nextPage ?? 0) + 1);
    printLog(
        "fetchPlaylist length ==> ${getMusicByCategoryProvider.playlistData?.length}");
  }

  @override
  void dispose() {
    getMusicByCategoryProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: Utils.webAppbarWithSidePanel(
          context: context, contentType: Constant.videoSearch),
      body: Utils.sidePanelWithBody(
        myWidget: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          child: buildPage(),
        ),
      ),
    );
  }

  Widget buildPage() {
    return Consumer<GetMusicByCategoryProvider>(
        builder: (context, getmusicbycategoryprovider, child) {
      if (getmusicbycategoryprovider.loading &&
          !getmusicbycategoryprovider.loadMore) {
        return musicListShimmer();
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyText(
                    color: white,
                    multilanguage: false,
                    text: widget.title,
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textExtraBig,
                    fontsizeWeb: Dimens.textExtraBig,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
                const SizedBox(width: 8),
                MyText(
                    color: white,
                    multilanguage: true,
                    text: "music",
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textExtraBig,
                    fontsizeWeb: Dimens.textExtraBig,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
              ],
            ),
            const SizedBox(height: 25),
            musicList(),
            if (getMusicByCategoryProvider.loadMore)
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

  Widget musicList() {
    return Consumer<GetMusicByCategoryProvider>(
        builder: (context, getmusicbycategoryprovider, child) {
      if (getmusicbycategoryprovider.getMusicByCategoryModel.status == 200 &&
          getmusicbycategoryprovider.musicList != null) {
        if ((getmusicbycategoryprovider.musicList?.length ?? 0) > 0) {
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: ResponsiveGridList(
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
                horizontalGridSpacing: 10,
                verticalGridSpacing: 25,
                listViewBuilderOptions: ListViewBuilderOptions(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                ),
                children: List.generate(
                    getmusicbycategoryprovider.musicList?.length ?? 0, (index) {
                  return InkWell(
                    onTap: () {
                      AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                          () {
                        playAudio(
                            getmusicbycategoryprovider
                                    .musicList?[index].contentType
                                    .toString() ??
                                "",
                            getmusicbycategoryprovider.musicList?[index].id
                                    .toString() ??
                                "",
                            getmusicbycategoryprovider.musicList?[index].id
                                    .toString() ??
                                "",
                            index,
                            getmusicbycategoryprovider.musicList,
                            getmusicbycategoryprovider.musicList?[index].title
                                    .toString() ??
                                "",
                            getmusicbycategoryprovider.musicList?[index].isBuy
                                    .toString() ??
                                "");
                      });
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.70,
                      height: 55,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: MyNetworkImage(
                                fit: BoxFit.cover,
                                width: 55,
                                height: 55,
                                imagePath: getmusicbycategoryprovider
                                        .musicList?[index].portraitImg
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
                                    text: getmusicbycategoryprovider
                                            .musicList?[index].title
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textMedium,
                                    fontsizeWeb: Dimens.textMedium,
                                    maxline: 2,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    MyText(
                                        color: gray,
                                        multilanguage: false,
                                        text: Utils.kmbGenerator(int.parse(
                                            getmusicbycategoryprovider
                                                    .musicList?[index].totalView
                                                    .toString() ??
                                                "")),
                                        textalign: TextAlign.left,
                                        fontsizeNormal: Dimens.textSmall,
                                        fontsizeWeb: Dimens.textSmall,
                                        inter: false,
                                        maxline: 1,
                                        fontwaight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                    const SizedBox(width: 3),
                                    MyText(
                                        color: gray,
                                        multilanguage: false,
                                        text: "views",
                                        textalign: TextAlign.left,
                                        fontsizeNormal: Dimens.textSmall,
                                        fontsizeWeb: Dimens.textSmall,
                                        inter: false,
                                        maxline: 1,
                                        fontwaight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                    const SizedBox(width: 5),
                                    MyText(
                                        color: gray,
                                        multilanguage: false,
                                        text: Utils.timeAgoCustom(
                                          DateTime.parse(
                                              getmusicbycategoryprovider
                                                      .musicList?[index]
                                                      .createdAt
                                                      .toString() ??
                                                  ""),
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
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
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
                                  getmusicbycategoryprovider
                                          .musicList?[index].portraitImg
                                          .toString() ??
                                      "",
                                  getmusicbycategoryprovider
                                          .musicList?[index].userId
                                          .toString() ??
                                      "",
                                  getmusicbycategoryprovider
                                          .musicList?[index].id
                                          .toString() ??
                                      "",
                                  index,
                                  getmusicbycategoryprovider
                                          .musicList?[index].title
                                          .toString() ??
                                      "",
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: MyImage(
                                  width: 13,
                                  height: 13,
                                  imagePath: "ic_more.png"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        } else {
          return const NoData(title: "", subTitle: "");
        }
      } else {
        return const NoData(title: "", subTitle: "");
      }
    });
  }

  Widget musicListShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: ResponsiveGridList(
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
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
          children: List.generate(10, (index) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              height: 55,
              child: const Row(
                children: [
                  CustomWidget.roundrectborder(
                    width: 55,
                    height: 55,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidget.roundrectborder(
                          width: 250,
                          height: 8,
                        ),
                        SizedBox(height: 8),
                        CustomWidget.roundrectborder(
                          width: 250,
                          height: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

/* More Item Bottom Sheet */

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
                      await getMusicByCategoryProvider.addremoveWatchLater(
                          "2", contentid, "0", "1");
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      Utils().showSnackBar(context, "savetowatchlater", true);
                    }),
                    Utils.moreFunctionItem(
                        "ic_playlisttitle.png", "savetoplaylist", () async {
                      Navigator.pop(context);
                      selectPlaylistBottomSheet(position, contentid);
                      await getMusicByCategoryProvider.getcontentbyChannel(
                          Constant.userID, Constant.channelID, "5", "1");
                    }),
                    Utils.moreFunctionItem("ic_share.png", "share", () {
                      Navigator.pop(context);
                      Utils.shareApp(Platform.isIOS
                          ? "Hey! I'm Listening $contentName. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm Listening $contentName. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
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
                              playlistId:
                                  getMusicByCategoryProvider.playlistId);
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
                Consumer<GetMusicByCategoryProvider>(
                    builder: (context, playlistprovider, child) {
                  if (playlistprovider.playlistLoading &&
                      !playlistprovider.playlistLoadmore) {
                    return const SizedBox.shrink();
                  } else {
                    if (getMusicByCategoryProvider
                                .getContentbyChannelModel.status ==
                            200 &&
                        getMusicByCategoryProvider.playlistData != null) {
                      if ((getMusicByCategoryProvider.playlistData?.length ??
                              0) >
                          0) {
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
                                if (getMusicByCategoryProvider
                                        .playlistId.isEmpty ||
                                    getMusicByCategoryProvider.playlistId ==
                                        "") {
                                  Utils().showSnackBar(
                                      context, "pleaseelectyourplaylist", true);
                                } else {
                                  await getMusicByCategoryProvider
                                      .addremoveContentToPlaylist(
                                          Constant.channelID,
                                          getMusicByCategoryProvider.playlistId,
                                          "3",
                                          contentid,
                                          "0",
                                          "1");

                                  if (!getMusicByCategoryProvider.loading) {
                                    if (getMusicByCategoryProvider
                                            .addremoveContentToPlaylistModel
                                            .status ==
                                        200) {
                                      printLog("Added Succsessfully");
                                      Utils().showToast("Save to Playlist");
                                    } else {
                                      Utils().showToast(
                                          "${getMusicByCategoryProvider.addremoveContentToPlaylistModel.message}");
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
    return Consumer<GetMusicByCategoryProvider>(
        builder: (context, playlistprovider, child) {
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
    log("Playlist Lenght==>${getMusicByCategoryProvider.playlistData?.length ?? 0}");
    log("Playlist Position==>${getMusicByCategoryProvider.playlistPosition}");
    log("Playlist Id==>${getMusicByCategoryProvider.playlistId}");
    if (getMusicByCategoryProvider.getContentbyChannelModel.status == 200 &&
        getMusicByCategoryProvider.playlistData != null) {
      if ((getMusicByCategoryProvider.playlistData?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: getMusicByCategoryProvider.playlistData?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
              onTap: () {
                getMusicByCategoryProvider.selectPlaylist(
                    index,
                    getMusicByCategoryProvider.playlistData?[index].id
                            .toString() ??
                        "",
                    true);
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                color: getMusicByCategoryProvider.playlistPosition == index &&
                        getMusicByCategoryProvider.isSelectPlaylist == true
                    ? colorPrimary
                    : colorPrimaryDark,
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                        color: getMusicByCategoryProvider.playlistPosition ==
                                    index &&
                                getMusicByCategoryProvider.isSelectPlaylist ==
                                    true
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
                          color: getMusicByCategoryProvider.playlistPosition ==
                                      index &&
                                  getMusicByCategoryProvider.isSelectPlaylist ==
                                      true
                              ? colorAccent
                              : white,
                          text: getMusicByCategoryProvider
                                  .playlistData?[index].title
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
                    getMusicByCategoryProvider.playlistPosition == index &&
                            getMusicByCategoryProvider.isSelectPlaylist == true
                        ? Icon(
                            Icons.check,
                            color:
                                getMusicByCategoryProvider.playlistPosition ==
                                            index &&
                                        getMusicByCategoryProvider
                                                .isSelectPlaylist ==
                                            true
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
            child: Consumer<GetMusicByCategoryProvider>(
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
                        radius: 50,
                        autofocus: false,
                        onTap: () {
                          Navigator.pop(context);
                          playlistTitleController.clear();
                          getMusicByCategoryProvider.isType = 0;
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
                              fontsizeWeb: Dimens.textBig,
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
                              getMusicByCategoryProvider.isType.toString(),
                            );
                            if (!createplaylistprovider.loading) {
                              if (createplaylistprovider
                                      .createPlaylistModel.status ==
                                  200) {
                                if (!context.mounted) return;
                                Utils().showSnackBar(context,
                                    "playlistcreatesuccsessfully", true);
                              } else {
                                if (!context.mounted) return;
                                Utils().showSnackBar(
                                    context,
                                    "${createplaylistprovider.createPlaylistModel.message}",
                                    true);
                              }
                            }
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            playlistTitleController.clear();
                            getMusicByCategoryProvider.isType = 0;
                            // _fetchPlaylist(0);
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

  Future<void> playAudio(
    String playingType,
    String episodeid,
    String contentid,
    int position,
    dynamic contentList,
    String contentName,
    String? isBuy,
  ) async {
    /* Play Music */
    musicManager.setInitialMusic(position, playingType, contentList, contentid,
        addView(playingType, contentid), false, 0, isBuy ?? "");
    /* Play Podcast */
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
  }
}
