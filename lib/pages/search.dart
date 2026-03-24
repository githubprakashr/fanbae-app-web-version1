import 'dart:developer';
import 'dart:io';
import 'package:fanbae/pages/contentdetail.dart';
import 'package:fanbae/pages/login.dart';
import 'package:fanbae/provider/musicdetailprovider.dart';
import 'package:fanbae/utils/adhelper.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/musicmanager.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fanbae/provider/searchprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class Search extends StatefulWidget {
  final String contentType;

  const Search({super.key, required this.contentType});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
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
      appBar: AppBar(
        backgroundColor: appbgcolor,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: appbgcolor,
        ),
        elevation: 0,
        titleSpacing: 0,
        title: Container(
          width: MediaQuery.of(context).size.width,
          height: 45,
          margin: const EdgeInsets.only(right: 15),
          child: TextFormField(
            obscureText: false,
            onChanged: (value) async {
              if (value.isNotEmpty) {
                await searchProvider.getSearch(
                    value.toString(), widget.contentType);
              } else {
                await searchProvider.clearProvider();
              }
            },
            keyboardType: TextInputType.text,
            controller: searchController,
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
              hintText: Locales.string(context, "searchvideocontent"),
              filled: true,
              fillColor: appbgcolor,
              contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(width: 1, color: colorPrimary),
              ),
              disabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(width: 1, color: colorPrimary),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(width: 1, color: colorPrimary),
              ),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(width: 1, color: colorPrimary)),
            ),
          ),
        ),
        centerTitle: false,
        leading: InkWell(
          hoverColor: transparent,
          splashColor: transparent,
          highlightColor: transparent,
          focusColor: transparent,
          onTap: () {
            Navigator.pop(context, false);
          },
          child: Align(
            alignment: Alignment.center,
            child: Utils.backIcon(),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 190),
              child: widget.contentType == "1" ? videoList() : musicList()),
          Utils.musicAndAdsPanel(context),
        ],
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
              minItemsPerRow: 1,
              maxItemsPerRow: 1,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 10,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(
                  searchprovider.searchmodel.video?.length ?? 0, (index) {
                return InkWell(
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
                      Utils.moveToDetail(
                          context,
                          0,
                          false,
                          searchprovider.searchmodel.video?[index].id
                                  .toString() ??
                              "",
                          false,
                          searchprovider.searchmodel.video?[index].contentType
                                  .toString() ??
                              "",
                          searchprovider.searchmodel.video?[index].isComment);
                    }
                  },
                  child: Container(
                    color: colorPrimaryDark,
                    height: 85,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Row(children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: colorPrimary),
                        ),
                        child: MyNetworkImage(
                            fit: BoxFit.cover,
                            width: 70,
                            height: 80,
                            imagePath: searchprovider
                                    .searchmodel.video?[index].portraitImg
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
                                text: searchprovider
                                        .searchmodel.video?[index].title
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textMedium,
                                inter: false,
                                maxline: 2,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                MyText(
                                    color: white,
                                    multilanguage: false,
                                    text: Utils.kmbGenerator(int.parse(
                                        searchprovider.searchmodel.video?[index]
                                                .totalView
                                                .toString() ??
                                            "")),
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
                            )
                          ],
                        ),
                      )
                    ]),
                  ),
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
              minItemsPerRow: 1,
              maxItemsPerRow: 1,
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
                    AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                        () {
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
                        position: index,
                        sectionBannerList:
                            searchprovider.searchmodel.music ?? [],
                        contentName: searchprovider
                                .searchmodel.music?[index].title
                                .toString() ??
                            "",
                        isBuy: searchprovider.searchmodel.music?[index].isBuy
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
                              imagePath: searchprovider
                                      .searchmodel.music?[index].portraitImg
                                      .toString() ??
                                  ""),
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
                                  fontsizeNormal: Dimens.textDesc,
                                  maxline: 1,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  MyText(
                                      color: white,
                                      multilanguage: false,
                                      text: Utils.kmbGenerator(int.parse(
                                          searchprovider.searchmodel
                                                  .music?[index].totalView
                                                  .toString() ??
                                              "")),
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
                                      text: "views",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textSmall,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(width: 5),
                                  MusicTitle(
                                      color: white,
                                      multilanguage: false,
                                      text: Utils.timeAgoCustom(
                                        DateTime.parse(
                                          searchprovider.searchmodel
                                                  .music?[index].createdAt ??
                                              "",
                                        ),
                                      ),
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textSmall,
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
                            moreBottomSheet(
                              searchprovider.searchmodel.music?[index].userId ??
                                  "",
                              searchprovider.searchmodel.music?[index].id ?? "",
                              index,
                              searchprovider.searchmodel.music?[index].title ??
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
                        ),
                      ],
                    ),
                  ),
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

  moreBottomSheet(reportUserid, contentid, position, contentName) {
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
                                      printLog("Added Succsessfully");
                                      Utils().showToast("Save to Playlist");
                                    } else {
                                      Utils().showToast(
                                          "${searchProvider.addremoveContentToPlaylistModel.message}");
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
                        multilanguage: false,
                        inter: false,
                        maxline: 2,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(width: 20),
                    Expanded(
                      child: MyText(
                          color: white,
                          text: searchProvider.playlistData?[index].title
                                  .toString() ??
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
}
