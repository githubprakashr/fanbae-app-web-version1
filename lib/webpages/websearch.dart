import 'dart:developer';
import 'dart:io';
import 'package:fanbae/provider/musicdetailprovider.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/musicmanager.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/webcontentdetail.dart';
import 'package:fanbae/webpages/webdetail.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/webwidget/interactivecontainer.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/provider/searchprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class WebSearch extends StatefulWidget {
  final String contentType;
  const WebSearch({super.key, required this.contentType});

  @override
  State<WebSearch> createState() => WebSearchState();
}

class WebSearchState extends State<WebSearch> {
  final searchController = TextEditingController();
  final MusicManager musicManager = MusicManager();
  late SearchProvider searchProvider;
  late ScrollController playlistController;
  final playlistTitleController = TextEditingController();

  @override
  void initState() {
    searchProvider = Provider.of<SearchProvider>(context, listen: false);
    playlistController = ScrollController();
    playlistController.addListener(_scrollListenerPlaylist);
    super.initState();
  }

  getApi() async {
    await searchProvider.getSearch(searchController.text, widget.contentType);
  }

  /* Playlist Pagination */
  _scrollListenerPlaylist() async {
    if (!playlistController.hasClients) return;
    if (playlistController.offset >=
            playlistController.position.maxScrollExtent &&
        !playlistController.position.outOfRange &&
        (searchProvider.playlistcurrentPage ?? 0) <
            (searchProvider.playlisttotalPage ?? 0)) {
      await searchProvider.setPlaylistLoadMore(true);
      _fetchPlaylist(searchProvider.playlistcurrentPage ?? 0);
    }
  }

  /* Playlist Api */
  Future _fetchPlaylist(int? nextPage) async {
    printLog("playlistmorePage  =======> ${searchProvider.playlistmorePage}");
    printLog(
        "playlistcurrentPage =======> ${searchProvider.playlistcurrentPage}");
    printLog(
        "playlisttotalPage   =======> ${searchProvider.playlisttotalPage}");
    printLog("nextPage   ========> $nextPage");
    await searchProvider.getcontentbyChannel(
        Constant.userID, Constant.channelID, "5", (nextPage ?? 0) + 1);
    printLog("fetchPlaylist length ==> ${searchProvider.playlistData?.length}");
  }

  @override
  void dispose() {
    searchProvider.clearProvider();
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
          padding: const EdgeInsets.only(bottom: 180),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSearch(),
              widget.contentType == "1" ? videoList() : musicList(),
            ],
          ),
        ),
      ),
    );
  }

  buildSearch() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width > 800
            ? MediaQuery.of(context).size.width * 0.40
            : MediaQuery.of(context).size.width,
        height: 55,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: TextFormField(
            obscureText: false,
            controller: searchController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            cursorColor: lightgray,
            style: GoogleFonts.roboto(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                color: white,
                fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              hintStyle: GoogleFonts.roboto(
                  fontSize: 14,
                  fontStyle: FontStyle.normal,
                  color: white,
                  fontWeight: FontWeight.w400),
              hintText: Locales.string(context, "search"),
              filled: true,
              fillColor: appbgcolor,
              contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide(width: 1, color: colorPrimary),
              ),
              disabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide(width: 1, color: colorPrimary),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide(width: 1, color: colorPrimary),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide(width: 1, color: colorPrimary),
              ),
            ),
            onChanged: (value) {
              getApi();
            },
          ),
        ),
      ),
    );
  }

  Widget videoList() {
    return Consumer<SearchProvider>(builder: (context, searchprovider, child) {
      if (searchprovider.searchloading) {
        return Utils.pageLoader(context);
      } else {
        if (searchprovider.searchmodel.status == 200 &&
            (searchprovider.searchmodel.video?.length ?? 0) > 0) {
          return Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            width: MediaQuery.of(context).size.width,
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: Utils.crossAxisCount(context),
              maxItemsPerRow: Utils.crossAxisCount(context),
              horizontalGridSpacing: 15,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(
                  searchprovider.searchmodel.video?.length ?? 0, (index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            WebDetail(
                                stoptime: 0,
                                iscontinueWatching: false,
                                videoid:
                                    searchprovider.searchmodel.video?[index].id
                                            .toString() ??
                                        "",
                                feedType: searchprovider
                                        .searchmodel.video?[index].contentType
                                        .toString() ??
                                    ""),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
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
                                borderRadius: BorderRadius.circular(15),
                                child: MyNetworkImage(
                                    fit: BoxFit.fill,
                                    imagePath: searchprovider.searchmodel
                                            .video?[index].landscapeImg
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
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 4, 5, 4),
                                  decoration: BoxDecoration(
                                    color: transparent.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: MyText(
                                      color: white,
                                      text: Utils.formatTime(double.parse(
                                          searchprovider.searchmodel
                                                  .video?[index].contentDuration
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
                            isHovered && MediaQuery.of(context).size.width > 400
                                ? Positioned.fill(
                                    left: 15,
                                    right: 15,
                                    top: 15,
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
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
                                              searchprovider
                                                      .searchmodel
                                                      .video?[index]
                                                      .landscapeImg
                                                      .toString() ??
                                                  "",
                                              searchprovider.searchmodel
                                                      .video?[index].userId
                                                      .toString() ??
                                                  "",
                                              searchprovider.searchmodel
                                                      .video?[index].id
                                                      .toString() ??
                                                  "",
                                              index,
                                              searchprovider.searchmodel
                                                      .video?[index].title
                                                      .toString() ??
                                                  "",
                                            );
                                          }
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
                                  imagePath: searchprovider.searchmodel
                                          .video?[index].channelImage
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
                                        text: searchprovider
                                                .searchmodel.video?[index].title
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
                                    searchprovider.searchmodel.video?[index]
                                                .channelName
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
                                                  text: searchprovider
                                                          .searchmodel
                                                          .video?[index]
                                                          .channelName
                                                          .toString() ??
                                                      "",
                                                  textalign: TextAlign.left,
                                                  fontsizeNormal:
                                                      Dimens.textMedium,
                                                  fontsizeWeb:
                                                      Dimens.textMedium,
                                                  inter: false,
                                                  maxline: 2,
                                                  multilanguage: false,
                                                  fontwaight: FontWeight.w400,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal),
                                            ],
                                          ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        MyText(
                                            color: gray,
                                            text: Utils.kmbGenerator(
                                                searchprovider.searchmodel
                                                        .video?[0].totalView ??
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
                                                  searchprovider
                                                          .searchmodel
                                                          .video?[index]
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
                              const SizedBox(width: 12),
                              MediaQuery.of(context).size.width < 400
                                  ? InkWell(
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
                                            searchprovider.searchmodel
                                                    .video?[index].landscapeImg
                                                    .toString() ??
                                                "",
                                            searchprovider.searchmodel
                                                    .video?[index].userId
                                                    .toString() ??
                                                "",
                                            searchprovider.searchmodel
                                                    .video?[index].id
                                                    .toString() ??
                                                "",
                                            index,
                                            searchprovider.searchmodel
                                                    .video?[index].title
                                                    .toString() ??
                                                "",
                                          );
                                        }
                                      },
                                      child: Icon(
                                        Icons.more_vert_outlined,
                                        color: white,
                                        size: 20,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                );
              }),
            ),
          );
        } else {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: const NoData(
                title: "nodatavideotitle", subTitle: "nodatavideosubtitle"),
          );
        }
      }
    });
  }

  Widget musicList() {
    return Consumer<SearchProvider>(builder: (context, searchprovider, child) {
      if (searchprovider.searchloading) {
        return Utils.pageLoader(context);
      } else {
        if (searchprovider.searchmodel.status == 200 &&
            (searchprovider.searchmodel.music?.length ?? 0) > 0) {
          return Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            width: MediaQuery.of(context).size.width,
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
              verticalGridSpacing: 10,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(
                  searchprovider.searchmodel.music?.length ?? 0, (index) {
                return InkWell(
                  onTap: () {
                    playAudio(
                      playingType: searchprovider
                              .searchmodel.music?[index].contentType
                              .toString() ??
                          "",
                      episodeid: searchprovider.searchmodel.music?[index].id
                              .toString() ??
                          "",
                      contentid: searchprovider.searchmodel.music?[index].id
                              .toString() ??
                          "",
                      contentDiscription: searchprovider
                              .searchmodel.music?[index].description
                              .toString() ??
                          "",
                      position: index,
                      sectionBannerList: searchprovider.searchmodel.music ?? [],
                      contentName: searchprovider
                              .searchmodel.music?[index].title
                              .toString() ??
                          "",
                      isBuy: searchprovider.searchmodel.music?[index].isBuy
                              .toString() ??
                          "",
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
                                  borderRadius: BorderRadius.circular(5),
                                  child: MyNetworkImage(
                                      fit: BoxFit.cover,
                                      imagePath: searchprovider.searchmodel
                                              .music?[index].portraitImg
                                              .toString() ??
                                          ""),
                                ),
                              ),
                              isHovered
                                  ? Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: white,
                                          size: 25,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink()
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MusicTitle(
                                    color: white,
                                    multilanguage: false,
                                    text: searchprovider
                                            .searchmodel.music?[index].title
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textMedium,
                                    fontsizeWeb: Dimens.textMedium,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                const SizedBox(height: 5),
                                MyText(
                                    color: gray,
                                    multilanguage: false,
                                    text: Utils.timeAgoCustom(
                                      DateTime.parse(
                                        searchprovider.searchmodel.music?[index]
                                                .createdAt ??
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
                          isHovered && MediaQuery.of(context).size.width > 400
                              ? InkWell(
                                  onTap: () {
                                    moreBottomSheet(
                                      searchprovider.searchmodel.music?[index]
                                              .landscapeImg ??
                                          "",
                                      searchprovider.searchmodel.music?[index]
                                              .userId ??
                                          "",
                                      searchprovider
                                              .searchmodel.music?[index].id ??
                                          "",
                                      index,
                                      searchprovider.searchmodel.music?[index]
                                              .title ??
                                          "",
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: MyImage(
                                        width: 13,
                                        height: 13,
                                        imagePath: "ic_more.png"),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          MediaQuery.of(context).size.width < 400
                              ? InkWell(
                                  onTap: () {
                                    moreBottomSheet(
                                      searchprovider.searchmodel.music?[index]
                                              .landscapeImg ??
                                          "",
                                      searchprovider.searchmodel.music?[index]
                                              .userId ??
                                          "",
                                      searchprovider
                                              .searchmodel.music?[index].id ??
                                          "",
                                      index,
                                      searchprovider.searchmodel.music?[index]
                                              .title ??
                                          "",
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: MyImage(
                                        width: 13,
                                        height: 13,
                                        imagePath: "ic_more.png"),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    );
                  }),
                );
              }),
            ),
          );
        } else {
          return const NoData(
              title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
        }
      }
    });
  }

  moreBottomSheet(videoImage, reportUserid, contentid, position, contentName) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: colorPrimaryDark,
      context: context,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 700),
        reverseDuration: const Duration(milliseconds: 300),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Utils.moreFunctionItem(
                      "ic_watchlater.png", "savetowatchlater", () async {
                    await searchProvider.addremoveWatchLater(
                        "2", contentid, "0", "1");
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    Utils().showSnackBar(context, "savetowatchlater", true);
                  }),
                  Utils.moreFunctionItem(
                      "ic_playlisttitle.png", "savetoplaylist", () async {
                    Navigator.pop(context);
                    selectPlaylistBottomSheet(position, contentid);
                    await searchProvider.getcontentbyChannel(
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
        );
      },
    );
  }

  /* Playlist Bottom Sheet */
  selectPlaylistBottomSheet(position, contentid) {
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
                              playlistId: searchProvider.playlistId);
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
                Consumer<SearchProvider>(
                    builder: (context, playlistprovider, child) {
                  if (playlistprovider.playlistLoading &&
                      !playlistprovider.playlistLoadmore) {
                    return const SizedBox.shrink();
                  } else {
                    if (searchProvider.getContentbyChannelModel.status == 200 &&
                        searchProvider.playlistData != null) {
                      if ((searchProvider.playlistData?.length ?? 0) > 0) {
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
                                if (searchProvider.playlistId.isEmpty ||
                                    searchProvider.playlistId == "") {
                                  Utils().showSnackBar(
                                      context, "pleaseelectyourplaylist", true);
                                } else {
                                  await searchProvider
                                      .addremoveContentToPlaylist(
                                          Constant.channelID,
                                          searchProvider.playlistId,
                                          "2",
                                          contentid,
                                          "0",
                                          "1");

                                  if (!searchProvider.searchloading) {
                                    if (searchProvider
                                            .addremoveContentToPlaylistModel
                                            .status ==
                                        200) {
                                      if (!context.mounted) return;
                                      Utils().showSnackBar(
                                          context,
                                          "${searchProvider.addremoveContentToPlaylistModel.message}",
                                          false);
                                    } else {
                                      if (!context.mounted) return;
                                      Utils().showSnackBar(
                                          context,
                                          "${searchProvider.addremoveContentToPlaylistModel.message}",
                                          false);
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
          );
        });
      },
    );
  }

  Widget buildPlayList() {
    return Consumer<SearchProvider>(
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
    log("Playlist Lenght==>${searchProvider.playlistData?.length ?? 0}");
    log("Playlist Position==>${searchProvider.playlistPosition}");
    log("Playlist Id==>${searchProvider.playlistId}");
    if (searchProvider.getContentbyChannelModel.status == 200 &&
        searchProvider.playlistData != null) {
      if ((searchProvider.playlistData?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: searchProvider.playlistData?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
              onTap: () {
                searchProvider.selectPlaylist(
                    index,
                    searchProvider.playlistData?[index].id.toString() ?? "",
                    true);
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                color: searchProvider.playlistPosition == index &&
                        searchProvider.isSelectPlaylist == true
                    ? colorPrimary
                    : colorPrimaryDark,
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                        color: searchProvider.playlistPosition == index &&
                                searchProvider.isSelectPlaylist == true
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
                          color: searchProvider.playlistPosition == index &&
                                  searchProvider.isSelectPlaylist == true
                              ? colorAccent
                              : white,
                          text: searchProvider.playlistData?[index].title
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
                    searchProvider.playlistPosition == index &&
                            searchProvider.isSelectPlaylist == true
                        ? Icon(
                            Icons.check,
                            color: searchProvider.playlistPosition == index &&
                                    searchProvider.isSelectPlaylist == true
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
              // borderRadius: BorderRadius.circular(20),
            ),
            child: Consumer<SearchProvider>(
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
                          fontsizeNormal: Dimens.textDesc,
                          fontsizeWeb: Dimens.textDesc,
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
                          searchProvider.isType = 0;
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
                              searchProvider.isType.toString(),
                            );
                            if (!createplaylistprovider.searchloading) {
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
                            searchProvider.isType = 0;
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

  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    String? podcastimage,
    String? contentUserid,
    required String? contentDiscription,
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
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => WebContentDetail(
            contentType: playingType,
            contentUserid: contentUserid ?? "",
            contentDiscription: contentDiscription ?? "",
            contentImage: podcastimage ?? "",
            contentName: contentName,
            playlistImage: playlistImages ?? [],
            contentId: contentid,
            isBuy: isBuy ?? "",
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
