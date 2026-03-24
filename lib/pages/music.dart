import 'dart:developer';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fanbae/model/sectionlistmodel.dart';
import 'package:fanbae/pages/createmusic.dart';
import 'package:fanbae/pages/getmusicbycategory.dart';
import 'package:fanbae/pages/getmusicbylanguage.dart';
import 'package:fanbae/pages/login.dart';
import 'package:fanbae/pages/contentdetail.dart';
import 'package:fanbae/pages/seeall.dart';
import 'package:fanbae/provider/musicdetailprovider.dart';
import 'package:fanbae/utils/adhelper.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/musicmanager.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/customappbar.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/provider/musicprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:provider/provider.dart';

class Music extends StatefulWidget {
  const Music({super.key});

  @override
  State<Music> createState() => _MusicState();
}

class _MusicState extends State<Music> {
  final MusicManager musicManager = MusicManager();
  CarouselSliderController bannerController = CarouselSliderController();
  late MusicProvider musicProvider;
  late MusicDetailProvider musicDetailProvider;
  late ScrollController _scrollController;
  late ScrollController playlistController;
  final playlistTitleController = TextEditingController();
  int episodeIndex = 0;

  @override
  void initState() {
    musicProvider = Provider.of<MusicProvider>(context, listen: false);
    musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    _scrollController = ScrollController();
    playlistController = ScrollController();
    _scrollController.addListener(_scrollListener);
    playlistController.addListener(_scrollListenerPlaylist);
    super.initState();
    _fetchData("1", "0", 0);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (musicProvider.sectioncurrentPage ?? 0) <
            (musicProvider.sectiontotalPage ?? 0)) {
      printLog("load more====>");
      musicProvider.setSectionLoadMore(true);
      if (musicProvider.tabindex == 0) {
        _fetchData("1", "0", musicProvider.sectioncurrentPage ?? 0);
      } else if (musicProvider.tabindex == 1) {
        _fetchData(
            "2", Constant.musicType, musicProvider.sectioncurrentPage ?? 0);
      } else if (musicProvider.tabindex == 2) {
        _fetchData(
            "2", Constant.radioType, musicProvider.sectioncurrentPage ?? 0);
      } else if (musicProvider.tabindex == 3) {
        _fetchData(
            "2", Constant.podcastType, musicProvider.sectioncurrentPage ?? 0);
      }
    }
  }

  /* Playlist Pagination */
  _scrollListenerPlaylist() async {
    if (!playlistController.hasClients) return;
    if (playlistController.offset >=
            playlistController.position.maxScrollExtent &&
        !playlistController.position.outOfRange &&
        (musicProvider.playlistcurrentPage ?? 0) <
            (musicProvider.playlisttotalPage ?? 0)) {
      await musicProvider.setPlaylistLoadMore(true);
      _fetchPlaylist(musicProvider.playlistcurrentPage ?? 0);
    }
  }

/* Section Data Api */
  Future<void> _fetchData(ishomepage, contenttype, int? nextPage) async {
    printLog("isMorePage  ======> ${musicProvider.sectionisMorePage}");
    printLog("currentPage ======> ${musicProvider.sectioncurrentPage}");
    printLog("totalPage   ======> ${musicProvider.sectiontotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await musicProvider.getSeactionList(
        ishomepage, contenttype, (nextPage ?? 0) + 1);
  }

  /* Playlist Api */
  Future _fetchPlaylist(int? nextPage) async {
    printLog("playlistmorePage  =======> ${musicProvider.playlistmorePage}");
    printLog(
        "playlistcurrentPage =======> ${musicProvider.playlistcurrentPage}");
    printLog("playlisttotalPage   =======> ${musicProvider.playlisttotalPage}");
    printLog("nextPage   ========> $nextPage");
    await musicProvider.getcontentbyChannel(
        Constant.userID, Constant.channelID, "5", (nextPage ?? 0) + 1);
    printLog("fetchPlaylist length ==> ${musicProvider.playlistData?.length}");
  }

  @override
  void dispose() {
    musicProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: const CustomAppBar(contentType: "2"),
      floatingActionButton: Constant.isCreator == '1'
          ? GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const CreateMusic();
                    },
                  ),
                );
                setState(() {});
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.115,
                height: MediaQuery.of(context).size.width * 0.115,
                decoration: BoxDecoration(
                    gradient: Constant.gradientColor,
                    borderRadius: BorderRadius.circular(40)),
                child: const Icon(Icons.add, color: pureBlack),
              ),
            )
          : null,
      body: Utils().pageBg(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tabButton(),
            buildPage(),
          ],
        ),
      ),
    );
  }

/* Tab layout */

  tabButton() {
    return Consumer<MusicProvider>(builder: (context, seactionprovider, child) {
      return SizedBox(
        height: 63,
        child: ListView.builder(
            itemCount: Constant.tabList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                focusColor: colorPrimaryDark,
                highlightColor: colorPrimaryDark,
                hoverColor: colorPrimaryDark,
                splashColor: colorPrimaryDark,
                onTap: () async {
                  await seactionprovider.chageTab(index);
                  await seactionprovider.setLoading(true);
                  await seactionprovider.clearTab();
                  if (index == 0) {
                    _fetchData("1", "0", 0);
                  } else if (index == 1) {
                    _fetchData("2", Constant.musicType, 0);
                  } else if (index == 2) {
                    _fetchData("2", Constant.radioType, 0);
                  } else if (index == 3) {
                    _fetchData("2", Constant.podcastType, 0);
                  }
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: seactionprovider.tabindex == index
                        ? colorPrimary
                        : buttonDisable,
                    gradient: seactionprovider.tabindex == index
                        ? Constant.gradientColor
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    //  border: Border.all(color: colorPrimary, width: 1)
                  ),
                  child: MusicTitle(
                      color: seactionprovider.tabindex == index
                          ? pureBlack
                          : white,
                      multilanguage: true,
                      text: Constant.tabList[index],
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textSmall,
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ),
              );
            }),
      );
    });
  }

/* Section layout*/

  Widget buildPage() {
    return Consumer<MusicProvider>(builder: (context, seactionprovider, child) {
      if (seactionprovider.sectionloading &&
          !seactionprovider.sectionLoadMore) {
        return commanShimmer();
      } else {
        return Expanded(
          child: RefreshIndicator(
            backgroundColor: colorPrimaryDark,
            color: colorPrimary,
            displacement: 70,
            edgeOffset: 1.0,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            strokeWidth: 3,
            onRefresh: () async {
              await musicProvider.setLoading(true);
              await musicProvider.clearTab();
              if (musicProvider.tabindex == 0) {
                _fetchData("1", "0", 0);
              } else if (musicProvider.tabindex == 1) {
                _fetchData("2", Constant.musicType, 0);
              } else if (musicProvider.tabindex == 2) {
                _fetchData("2", Constant.radioType, 0);
              } else if (musicProvider.tabindex == 3) {
                _fetchData("2", Constant.podcastType, 0);
              }
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 200),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  setSectionByType(),
                  if (musicProvider.sectionLoadMore)
                    Container(
                      height: 50,
                      margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                      child: Utils.pageLoader(context),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  Widget setSectionByType() {
    if (musicProvider.sectionListModel.status == 200 &&
        musicProvider.sectionList != null) {
      if ((musicProvider.sectionList?.length ?? 0) > 0) {
        return ListView.builder(
          itemCount: musicProvider.sectionList?.length ?? 0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (musicProvider.sectionList?[index].data != null &&
                (musicProvider.sectionList?[index].data?.length ?? 0) > 0) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MusicTitle(
                                  color: white,
                                  multilanguage: false,
                                  text: musicProvider.sectionList?[index].title
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textBig,
                                  maxline: 1,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 5),
                              MusicTitle(
                                  color: gray,
                                  multilanguage: false,
                                  text: musicProvider
                                          .sectionList?[index].shortTitle
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textMedium,
                                  maxline: 1,
                                  fontwaight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          ),
                        ),
                        musicProvider.sectionList?[index].viewAll == 1
                            ? InkWell(
                                splashColor: transparent,
                                highlightColor: transparent,
                                hoverColor: transparent,
                                focusColor: transparent,
                                onTap: () {
                                  AdHelper.showFullscreenAd(
                                      context, Constant.interstialAdType, () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return SeeAll(
                                            isRent: false,
                                            sectionId: musicProvider
                                                    .sectionList?[index].id
                                                    .toString() ??
                                                "",
                                            contentType: musicProvider
                                                    .sectionList?[index]
                                                    .contentType
                                                    .toString() ??
                                                "",
                                            title: musicProvider
                                                    .sectionList?[index].title
                                                    .toString() ??
                                                "",
                                          );
                                        },
                                      ),
                                    );
                                  });
                                },
                                child: MusicTitle(
                                    color: colorPrimary,
                                    multilanguage: true,
                                    text: "seeall",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: 14,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Section Data List
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: getRemainingDataHeight(
                        musicProvider.sectionList?[index].screenLayout
                                .toString() ??
                            "",
                        index,
                        musicProvider.sectionList ?? []),
                    child: setSectionData(
                        index: index,
                        sectionList: musicProvider.sectionList ?? []),
                  )
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  Widget setSectionData(
      {required int index, required List<Result>? sectionList}) {
    /* screen_layout =>  landscape, potrait, square */
    if ((sectionList?[index].screenLayout.toString() ?? "") == "list_view") {
      return listviewLayout(index, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "square") {
      return square(index, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "portrait") {
      return portrait(index, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") == "round") {
      return round(index, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "playlist") {
      return playlist(index, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "category") {
      return category(index, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "language") {
      return language(index, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "banner_view") {
      return bannerPodcast(index, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "landscape") {
      return landscapPodcast(index, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "podcast_list_view") {
      return podcastListview(index, sectionList);
    } else {
      return square(index, sectionList);
    }
  }

  double getRemainingDataHeight(
      String? layoutType, int sectionindex, List<Result>? sectionList) {
    if (layoutType == "list_view") {
      return Dimens.listviewLayoutheight;
    } else if (layoutType == "portrait") {
      return Dimens.portraitheight;
    } else if (layoutType == "square") {
      return Dimens.squareheight;
    } else if (layoutType == "round") {
      return Dimens.roundheight;
    } else if (layoutType == "playlist") {
      return Dimens.playlistheight;
    } else if (layoutType == "category") {
      return Dimens.categoryheight;
    } else if (layoutType == "language") {
      return Dimens.languageheight;
    } else if (layoutType == "banner_view") {
      return Dimens.podcastbannerheight;
    } else if (layoutType == "landscape") {
      if ((sectionList?[sectionindex].data?.length ?? 0) > 1) {
        return 400;
      } else {
        return 175;
      }
    } else if (layoutType == "podcast_list_view") {
      return Dimens.podcastListviewheight;
    } else {
      return Dimens.squareheight;
    }
  }

/* Music Layout */

  Widget square(int sectionindex, List<Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.squareheight,
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: 3),
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
            splashColor: transparent,
            highlightColor: transparent,
            hoverColor: transparent,
            focusColor: transparent,
            onTap: () {
              AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
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
                  playAudio(
                    playingType: sectionList?[sectionindex]
                            .data?[index]
                            .contentType
                            .toString() ??
                        "",
                    episodeid:
                        sectionList?[sectionindex].data?[index].id.toString() ??
                            "",
                    contentid:
                        sectionList?[sectionindex].data?[index].id.toString() ??
                            "",
                    position: index,
                    sectionBannerList: sectionList?[sectionindex].data ?? [],
                    contentName: sectionList?[sectionindex]
                            .data?[index]
                            .title
                            .toString() ??
                        "",
                    isBuy: sectionList?[sectionindex]
                            .data?[index]
                            .isBuy
                            .toString() ??
                        "",
                  );
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MyNetworkImage(
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      imagePath: sectionList?[sectionindex]
                              .data?[index]
                              .portraitImg
                              .toString() ??
                          "",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: MusicTitle(
                            color: white,
                            text: sectionList?[sectionindex]
                                    .data?[index]
                                    .title
                                    .toString() ??
                                "",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textSmall,
                            multilanguage: false,
                            maxline: 2,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                      InkWell(
                        splashColor: transparent,
                        highlightColor: transparent,
                        hoverColor: transparent,
                        focusColor: transparent,
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
                            moreBottomSheet(
                                sectionList?[sectionindex]
                                        .data?[index]
                                        .userId
                                        .toString() ??
                                    "",
                                sectionList?[sectionindex]
                                        .data?[index]
                                        .id
                                        .toString() ??
                                    "",
                                index,
                                sectionList?[sectionindex]
                                        .data?[index]
                                        .title
                                        .toString() ??
                                    "",
                                index);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: MyImage(
                              width: 13, height: 13, imagePath: "ic_more.png"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget portrait(int sectionindex, List<Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.portraitheight,
      child: ListView.separated(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          return InkWell(
            splashColor: transparent,
            highlightColor: transparent,
            hoverColor: transparent,
            focusColor: transparent,
            onTap: () {
              AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
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
                  playAudio(
                    playingType: sectionList?[sectionindex]
                            .data?[index]
                            .contentType
                            .toString() ??
                        "",
                    episodeid:
                        sectionList?[sectionindex].data?[index].id.toString() ??
                            "",
                    contentid:
                        sectionList?[sectionindex].data?[index].id.toString() ??
                            "",
                    position: index,
                    sectionBannerList: sectionList?[sectionindex].data ?? [],
                    contentName: sectionList?[sectionindex]
                            .data?[index]
                            .title
                            .toString() ??
                        "",
                    isBuy: sectionList?[sectionindex]
                            .data?[index]
                            .isBuy
                            .toString() ??
                        "",
                  );
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: MyNetworkImage(
                      width: 150,
                      height: 140,
                      fit: BoxFit.cover,
                      imagePath: sectionList?[sectionindex]
                              .data?[index]
                              .landscapeImg
                              .toString() ??
                          "",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 140,
                        child: MusicTitle(
                            color: white,
                            text: sectionList?[sectionindex]
                                    .data?[index]
                                    .title
                                    .toString() ??
                                "",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textSmall,
                            multilanguage: false,
                            maxline: 2,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                      InkWell(
                        splashColor: transparent,
                        highlightColor: transparent,
                        hoverColor: transparent,
                        focusColor: transparent,
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
                            moreBottomSheet(
                                sectionList?[sectionindex]
                                        .data?[index]
                                        .userId
                                        .toString() ??
                                    "",
                                sectionList?[sectionindex]
                                        .data?[index]
                                        .id
                                        .toString() ??
                                    "",
                                index,
                                sectionList?[sectionindex]
                                        .data?[index]
                                        .title
                                        .toString() ??
                                    "",
                                index);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: MyImage(
                              width: 13, height: 13, imagePath: "ic_more.png"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget listviewLayout(int sectionindex, List<Result>? sectionList) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 270,
        // color: gray,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Wrap(direction: Axis.vertical, runSpacing: -2, children: [
            ...List.generate(
              sectionList?[sectionindex].data?.length ?? 0,
              (index) => InkWell(
                splashColor: transparent,
                highlightColor: transparent,
                hoverColor: transparent,
                focusColor: transparent,
                onTap: () {
                  AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
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
                      playAudio(
                        playingType: sectionList?[sectionindex]
                                .data?[index]
                                .contentType
                                .toString() ??
                            "",
                        episodeid: sectionList?[sectionindex]
                                .data?[index]
                                .id
                                .toString() ??
                            "",
                        contentid: sectionList?[sectionindex]
                                .data?[index]
                                .id
                                .toString() ??
                            "",
                        position: index,
                        sectionBannerList:
                            sectionList?[sectionindex].data ?? [],
                        contentName: sectionList?[sectionindex]
                                .data?[index]
                                .title
                                .toString() ??
                            "",
                        isBuy: sectionList?[sectionindex]
                                .data?[index]
                                .isBuy
                                .toString() ??
                            "",
                      );
                    }
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
                            imagePath: sectionList?[sectionindex]
                                    .data?[index]
                                    .portraitImg
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
                                text: sectionList?[sectionindex]
                                        .data?[index]
                                        .title
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textDesc,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                MyText(
                                    color: white,
                                    multilanguage: false,
                                    text: sectionList?[sectionindex]
                                            .data?[index]
                                            .artistName
                                            .toString() ??
                                        "",
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
                                    text: Utils.kmbGenerator(int.parse(
                                        sectionList?[sectionindex]
                                                .data?[index]
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
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        splashColor: transparent,
                        highlightColor: transparent,
                        hoverColor: transparent,
                        focusColor: transparent,
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
                            moreBottomSheet(
                                sectionList?[sectionindex]
                                        .data?[index]
                                        .userId
                                        .toString() ??
                                    "",
                                sectionList?[sectionindex]
                                        .data?[index]
                                        .id
                                        .toString() ??
                                    "",
                                index,
                                sectionList?[sectionindex]
                                        .data?[index]
                                        .title
                                        .toString() ??
                                    "",
                                index);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: MyImage(
                              width: 13, height: 13, imagePath: "ic_more.png"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]),
        ));
  }

/* Playlist Layout */

  Widget playlist(int sectionindex, List<Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.playlistheight,
      child: ListView.separated(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          return InkWell(
            splashColor: transparent,
            highlightColor: transparent,
            hoverColor: transparent,
            focusColor: transparent,
            onTap: () {
              AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
                playAudio(
                  playingType: sectionList?[sectionindex]
                          .data?[index]
                          .contentType
                          .toString() ??
                      "",
                  episodeid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  contentid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  position: index,
                  sectionBannerList: sectionList?[sectionindex].data ?? [],
                  contentName: sectionList?[sectionindex]
                          .data?[index]
                          .title
                          .toString() ??
                      "",
                  contentUserid: sectionList?[sectionindex]
                          .data?[index]
                          .userId
                          .toString() ??
                      "",
                  podcastimage: sectionList?[sectionindex]
                          .data?[index]
                          .portraitImg
                          .toString() ??
                      "",
                  playlistImages:
                      sectionList?[sectionindex].data?[index].playlistImage ??
                          [],
                  isBuy: sectionList?[sectionindex]
                          .data?[index]
                          .isBuy
                          .toString() ??
                      "",
                );
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  playlistImages(sectionindex, index, sectionList),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 150,
                    child: MusicTitle(
                        color: white,
                        text: sectionList?[sectionindex]
                                .data?[index]
                                .title
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        multilanguage: false,
                        maxline: 1,
                        fontwaight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MusicTitle(
                            color: gray,
                            text: Utils.kmbGenerator(int.parse(
                                sectionList?[sectionindex]
                                        .data?[index]
                                        .totalView
                                        .toString() ??
                                    "")),
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            multilanguage: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MusicTitle(
                            color: gray,
                            text: "views",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            multilanguage: true,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget playlistImages(sectionindex, index, List<Result>? sectionList) {
    if ((sectionList?[sectionindex].data?[index].playlistImage?.length ?? 0) ==
        4) {
      return SizedBox(
          width: 160,
          height: 150,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionList?[sectionindex]
                                .data?[index]
                                .playlistImage?[0]
                                .toString() ??
                            "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionList?[sectionindex]
                                .data?[index]
                                .playlistImage?[1]
                                .toString() ??
                            "",
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionList?[sectionindex]
                                .data?[index]
                                .playlistImage?[2]
                                .toString() ??
                            "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionList?[sectionindex]
                                .data?[index]
                                .playlistImage?[3]
                                .toString() ??
                            "",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((sectionList?[sectionindex].data?[index].playlistImage?.length ??
            0) ==
        3) {
      return SizedBox(
          width: 160,
          height: 150,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionList?[sectionindex]
                                .data?[index]
                                .playlistImage?[0]
                                .toString() ??
                            "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionList?[sectionindex]
                                .data?[index]
                                .playlistImage?[1]
                                .toString() ??
                            "",
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: MyNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  imagePath: sectionList?[sectionindex]
                          .data?[index]
                          .playlistImage?[2]
                          .toString() ??
                      "",
                ),
              ),
            ],
          ));
    } else if ((sectionList?[sectionindex].data?[index].playlistImage?.length ??
            0) ==
        2) {
      return SizedBox(
          width: 160,
          height: 150,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionList?[sectionindex]
                                .data?[index]
                                .playlistImage?[0]
                                .toString() ??
                            "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionList?[sectionindex]
                                .data?[index]
                                .playlistImage?[1]
                                .toString() ??
                            "",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((sectionList?[sectionindex].data?[index].playlistImage?.length ??
            0) ==
        1) {
      return SizedBox(
          width: 160,
          height: 150,
          child: MyNetworkImage(
            width: 160,
            height: 150,
            fit: BoxFit.cover,
            imagePath: sectionList?[sectionindex]
                    .data?[index]
                    .playlistImage?[0]
                    .toString() ??
                "",
          ));
    } else {
      return Container(
        width: 160,
        height: 150,
        color: colorPrimaryDark,
        alignment: Alignment.center,
        child: MyImage(width: 35, height: 35, imagePath: "ic_music.png"),
      );
    }
  }

/* Categories and Language */

  Widget category(int sectionindex, List<Result>? sectionList) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: Dimens.categoryheight,
        alignment: Alignment.centerLeft,
        child: ListView.separated(
            itemCount: sectionList?[sectionindex].data?.length ?? 0,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(width: 7),
            itemBuilder: (context, index) {
              return InkWell(
                splashColor: transparent,
                highlightColor: transparent,
                hoverColor: transparent,
                focusColor: transparent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return GetMusicByCategory(
                          categoryId: sectionList?[sectionindex]
                                  .data?[index]
                                  .id
                                  .toString() ??
                              "",
                          title: sectionList?[sectionindex]
                                  .data?[index]
                                  .title
                                  .toString() ??
                              "",
                        );
                      },
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    color: Utils.generateRendomColor().withOpacity(0.30),
                    width: 150,
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    height: MediaQuery.of(context).size.height,
                    child: MusicTitle(
                        color: white,
                        multilanguage: false,
                        text: sectionList?[sectionindex]
                                .data?[index]
                                .title
                                .toString() ??
                            "",
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textTitle,
                        fontsizeWeb: Dimens.textTitle,
                        maxline: 2,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ),
                ),
              );
            }));
  }

  Widget language(int sectionindex, List<Result>? sectionList) {
    return Container(
      // color: gray,
      alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width,
      height: Dimens.languageheight,
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: 7),
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
            splashColor: transparent,
            highlightColor: transparent,
            hoverColor: transparent,
            focusColor: transparent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return GetMusicByLanguage(
                      languageId: sectionList?[sectionindex]
                              .data?[index]
                              .id
                              .toString() ??
                          "",
                      title: sectionList?[sectionindex]
                              .data?[index]
                              .title
                              .toString() ??
                          "",
                    );
                  },
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                color: Utils.generateRendomColor().withOpacity(0.30),
                width: 150,
                padding: const EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                height: MediaQuery.of(context).size.height,
                child: MusicTitle(
                    color: white,
                    multilanguage: false,
                    text: sectionList?[sectionindex]
                            .data?[index]
                            .title
                            .toString() ??
                        "",
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textTitle,
                    fontsizeWeb: Dimens.textTitle,
                    maxline: 2,
                    fontwaight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
              ),
            ),
          );
        },
      ),
    );
  }

/* Radio Layout */

  Widget round(int sectionindex, List<Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.roundheight,
      child: ListView.separated(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        separatorBuilder: (context, index) => const SizedBox(width: 3),
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
            splashColor: transparent,
            highlightColor: transparent,
            hoverColor: transparent,
            focusColor: transparent,
            onTap: () {
              AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
                playAudio(
                  playingType: sectionList?[sectionindex]
                          .data?[index]
                          .contentType
                          .toString() ??
                      "",
                  episodeid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  contentid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  position: index,
                  sectionBannerList: sectionList?[sectionindex].data ?? [],
                  contentName: sectionList?[sectionindex]
                          .data?[index]
                          .title
                          .toString() ??
                      "",
                  contentUserid: sectionList?[sectionindex]
                          .data?[index]
                          .userId
                          .toString() ??
                      "",
                  podcastimage: sectionList?[sectionindex]
                          .data?[index]
                          .portraitImg
                          .toString() ??
                      "",
                  isBuy: sectionList?[sectionindex]
                          .data?[index]
                          .isBuy
                          .toString() ??
                      "",
                );
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: MyNetworkImage(
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      imagePath: sectionList?[sectionindex]
                              .data?[index]
                              .portraitImg
                              .toString() ??
                          "",
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 100,
                    child: MusicTitle(
                        color: white,
                        text: sectionList?[sectionindex]
                                .data?[index]
                                .artistName
                                .toString() ??
                            "",
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textDesc,
                        multilanguage: false,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

/* Podcast */
  Widget bannerPodcast(int sectionindex, List<Result>? sectionList) {
    return Container(
      height: Dimens.podcastbannerheight,
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
      child: CarouselSlider.builder(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        carouselController: bannerController,
        options: CarouselOptions(
          initialPage: 0,
          height: MediaQuery.of(context).size.height,
          enlargeCenterPage: true,
          autoPlay: false,
          autoPlayCurve: Curves.linear,
          enableInfiniteScroll: true,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(seconds: 3),
          viewportFraction: 1.0,
          onPageChanged: (index, reason) async {},
        ),
        itemBuilder: (BuildContext context, int index, int pageViewIndex) {
          return InkWell(
            splashColor: transparent,
            highlightColor: transparent,
            hoverColor: transparent,
            focusColor: transparent,
            onTap: () {
              playAudio(
                playingType: sectionList?[sectionindex]
                        .data?[index]
                        .contentType
                        .toString() ??
                    "",
                episodeid:
                    sectionList?[sectionindex].data?[index].id.toString() ?? "",
                contentid:
                    sectionList?[sectionindex].data?[index].id.toString() ?? "",
                position: index,
                sectionBannerList: sectionList?[sectionindex].data ?? [],
                contentName:
                    sectionList?[sectionindex].data?[index].title.toString() ??
                        "",
                contentUserid:
                    sectionList?[sectionindex].data?[index].userId.toString() ??
                        "",
                podcastimage: sectionList?[sectionindex]
                        .data?[index]
                        .portraitImg
                        .toString() ??
                    "",
                isBuy:
                    sectionList?[sectionindex].data?[index].isBuy.toString() ??
                        "",
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: MyNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                      imagePath: sectionList?[sectionindex]
                              .data?[index]
                              .portraitImg
                              .toString() ??
                          "",
                    ),
                  ),
                  Positioned.fill(
                    left: 15,
                    right: 15,
                    bottom: 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.60,
                              child: MusicTitle(
                                  color: white,
                                  multilanguage: false,
                                  text: sectionList?[sectionindex]
                                          .data?[index]
                                          .title
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textDesc,
                                  maxline: 3,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ),
                            const SizedBox(height: 5),
                            MusicTitle(
                                color: white,
                                multilanguage: false,
                                text: sectionList?[sectionindex]
                                        .data?[index]
                                        .languageName
                                        .toString() ??
                                    "",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textSmall,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                        MyImage(
                          width: 30,
                          height: 30,
                          imagePath: "ic_podcastTab.png",
                          color: white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget landscapPodcast(int sectionindex, List<Result>? sectionList) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height:
            ((sectionList?[sectionindex].data?.length ?? 0) > 1) ? 400 : 175,
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Wrap(direction: Axis.vertical, runSpacing: 0, children: [
            ...List.generate(
              sectionList?[sectionindex].data?.length ?? 0,
              (index) => InkWell(
                splashColor: transparent,
                highlightColor: transparent,
                hoverColor: transparent,
                focusColor: transparent,
                onTap: () {
                  playAudio(
                    playingType: sectionList?[sectionindex]
                            .data?[index]
                            .contentType
                            .toString() ??
                        "",
                    episodeid:
                        sectionList?[sectionindex].data?[index].id.toString() ??
                            "",
                    contentid:
                        sectionList?[sectionindex].data?[index].id.toString() ??
                            "",
                    position: index,
                    sectionBannerList: sectionList?[sectionindex].data ?? [],
                    contentName: sectionList?[sectionindex]
                            .data?[index]
                            .title
                            .toString() ??
                        "",
                    contentUserid: sectionList?[sectionindex]
                            .data?[index]
                            .userId
                            .toString() ??
                        "",
                    podcastimage: sectionList?[sectionindex]
                            .data?[index]
                            .portraitImg
                            .toString() ??
                        "",
                    isBuy: sectionList?[sectionindex]
                            .data?[index]
                            .isBuy
                            .toString() ??
                        "",
                  );
                },
                child: Container(
                  width: 210,
                  height: 200,
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: MyNetworkImage(
                                width: MediaQuery.of(context).size.width,
                                height: 120,
                                imagePath: sectionList?[sectionindex]
                                        .data?[index]
                                        .portraitImg
                                        .toString() ??
                                    "",
                                fit: BoxFit.cover),
                          ),
                          Positioned.fill(
                            left: 15,
                            right: 15,
                            bottom: 15,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: MyImage(
                                width: 30,
                                height: 30,
                                imagePath: "ic_podcastTab.png",
                                color: white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
                          child: MusicTitle(
                              color: white,
                              multilanguage: false,
                              text: sectionList?[sectionindex]
                                      .data?[index]
                                      .title
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textDesc,
                              maxline: 2,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]),
        ));
  }

  Widget podcastListview(int sectionindex, List<Result>? sectionList) {
    return CarouselSlider.builder(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        carouselController: bannerController,
        options: CarouselOptions(
          initialPage: 0,
          height: MediaQuery.of(context).size.height,
          enlargeCenterPage: false,
          autoPlay: true,
          autoPlayCurve: Curves.linear,
          enableInfiniteScroll: true,
          viewportFraction: 1.0,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(seconds: 3),
          onPageChanged: (index, reason) async {},
        ),
        itemBuilder: (BuildContext context, int index, int pageViewIndex) {
          return InkWell(
            splashColor: transparent,
            highlightColor: transparent,
            hoverColor: transparent,
            focusColor: transparent,
            onTap: () {
              playAudio(
                playingType: sectionList?[sectionindex]
                        .data?[index]
                        .contentType
                        .toString() ??
                    "",
                episodeid:
                    sectionList?[sectionindex].data?[index].id.toString() ?? "",
                contentid:
                    sectionList?[sectionindex].data?[index].id.toString() ?? "",
                position: index,
                sectionBannerList: sectionList?[sectionindex].data ?? [],
                contentName:
                    sectionList?[sectionindex].data?[index].title.toString() ??
                        "",
                contentUserid:
                    sectionList?[sectionindex].data?[index].userId.toString() ??
                        "",
                podcastimage: sectionList?[sectionindex]
                        .data?[index]
                        .portraitImg
                        .toString() ??
                    "",
                isBuy:
                    sectionList?[sectionindex].data?[index].isBuy.toString() ??
                        "",
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorPrimaryDark,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: MyNetworkImage(
                          width: 100,
                          height: 100,
                          imagePath: sectionList?[sectionindex]
                                  .data?[index]
                                  .portraitImg
                                  .toString() ??
                              "",
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MusicTitle(
                                color: white,
                                multilanguage: false,
                                text: sectionList?[sectionindex]
                                        .data?[index]
                                        .title
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textExtraBig,
                                maxline: 2,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            const SizedBox(height: 8),
                            MusicTitle(
                                color: white,
                                multilanguage: false,
                                text: sectionList?[sectionindex]
                                        .data?[index]
                                        .description
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textMedium,
                                maxline: 2,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  MusicTitle(
                      color: white,
                      multilanguage: true,
                      text: "episodes",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textMedium,
                      maxline: 2,
                      fontwaight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 10),
                  ListView.builder(
                      itemCount: 1,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, position) {
                        episodeIndex = position;
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: 55,
                          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: MyNetworkImage(
                                    fit: BoxFit.cover,
                                    width: 55,
                                    height: 55,
                                    imagePath: sectionList?[sectionindex]
                                            .data?[index]
                                            .episodeArray?[position]
                                            .portraitImg
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
                                        color: colorPrimary,
                                        multilanguage: false,
                                        text: sectionList?[sectionindex]
                                                .data?[index]
                                                .episodeArray?[position]
                                                .name
                                                .toString() ??
                                            "",
                                        textalign: TextAlign.left,
                                        fontsizeNormal: Dimens.textTitle,
                                        maxline: 1,
                                        fontwaight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                    const SizedBox(height: 8),
                                    MusicTitle(
                                        color: white,
                                        multilanguage: false,
                                        text: sectionList?[sectionindex]
                                                .data?[index]
                                                .episodeArray?[position]
                                                .description
                                                .toString() ??
                                            "",
                                        textalign: TextAlign.left,
                                        fontsizeNormal: Dimens.textSmall,
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
                  Align(
                      alignment: Alignment.centerRight,
                      child: MyImage(
                        width: 30,
                        height: 30,
                        imagePath: "ic_podcastTab.png",
                        color: white,
                      )),
                ],
              ),
            ),
          );
        });
  }

/* All Layout Common Shimmer */
  Widget commanShimmer() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(height: 10, width: 150),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(height: 10, width: 80),
                    ],
                  ),
                  CustomWidget.roundrectborder(height: 10, width: 50),
                ],
              ),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: Dimens.listviewLayoutheight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child:
                      Wrap(direction: Axis.vertical, runSpacing: -2, children: [
                    ...List.generate(
                      8,
                      (index) => Container(
                        width: MediaQuery.of(context).size.width * 0.70,
                        height: 55,
                        margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: const CustomWidget.roundrectborder(
                                width: 55,
                                height: 55,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomWidget.roundrectborder(
                                  width: 120,
                                  height: 8,
                                ),
                                SizedBox(height: 8),
                                CustomWidget.roundrectborder(
                                  width: 120,
                                  height: 8,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ]),
                )),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(height: 10, width: 150),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(height: 10, width: 80),
                    ],
                  ),
                  CustomWidget.roundrectborder(height: 10, width: 50),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: Dimens.squareheight,
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(width: 3),
                itemCount: 5,
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomWidget.roundrectborder(
                          width: 90,
                          height: 90,
                        ),
                        SizedBox(height: 5),
                        CustomWidget.roundrectborder(
                          width: 50,
                          height: 5,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(height: 10, width: 150),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(height: 10, width: 80),
                    ],
                  ),
                  CustomWidget.roundrectborder(height: 10, width: 50),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: Dimens.roundheight,
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(width: 3),
                itemCount: 5,
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomWidget.circular(
                          width: 110,
                          height: 110,
                        ),
                        SizedBox(height: 5),
                        CustomWidget.roundrectborder(
                          width: 50,
                          height: 5,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

/* PlayAudio Player */
  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    String? podcastimage,
    String? contentUserid,
    required int position,
    required List<Datum>? sectionBannerList,
    dynamic playlistImages,
    required String contentName,
    required String? isBuy,
  }) async {
    /* Only Music Direct Play*/
    if (playingType == "2") {
      musicManager.setInitialMusic(position, playingType, sectionBannerList,
          contentid, addView(playingType, contentid), false, 0, isBuy ?? "");
      await musicDetailProvider.getRelatedMusic(playingType, 0);
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

/* More Button Bottom Sheet */
  moreBottomSheet(reportUserid, contentid, position, contentName, index) {
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
                    await musicProvider.addremoveWatchLater(
                        "2", contentid, "0", "1");
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    Utils().showSnackBar(context, "savetowatchlater", true);
                  }),
                  Utils.moreFunctionItem(
                      "ic_playlisttitle.png", "savetoplaylist", () async {
                    Navigator.pop(context);
                    selectPlaylistBottomSheet(position, contentid);
                    await musicProvider.getcontentbyChannel(
                        Constant.userID, Constant.channelID, "5", "1");
                  }),
                  Utils.moreFunctionItem("ic_share.png", "share", () {
                    print(contentid);
                    Navigator.pop(context);
                    final shareUrl =
                        "Hey! I'm watching $contentName on ${Constant.appName}! 🎬\n"
                        "Watch here 👉 https://fanbae.tv/music?m=$contentid/$index\n";
                    print(contentid);
                    print(shareUrl);
                    Utils.shareApp(shareUrl);
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
                        splashColor: transparent,
                        highlightColor: transparent,
                        hoverColor: transparent,
                        focusColor: transparent,
                        onTap: () async {
                          Navigator.pop(context);
                          createPlaylistDilog(
                              playlistId: musicProvider.playlistId);
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
                Consumer<MusicProvider>(
                    builder: (context, playlistprovider, child) {
                  if (playlistprovider.playlistLoading &&
                      !playlistprovider.playlistLoadmore) {
                    return const SizedBox.shrink();
                  } else {
                    if (musicProvider.getContentbyChannelModel.status == 200 &&
                        musicProvider.playlistData != null) {
                      if ((musicProvider.playlistData?.length ?? 0) > 0) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              splashColor: transparent,
                              highlightColor: transparent,
                              hoverColor: transparent,
                              focusColor: transparent,
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
                              splashColor: transparent,
                              highlightColor: transparent,
                              hoverColor: transparent,
                              focusColor: transparent,
                              onTap: () async {
                                Navigator.pop(context);
                                if (musicProvider.playlistId.isEmpty ||
                                    musicProvider.playlistId == "") {
                                  Utils().showSnackBar(
                                      context, "pleaseelectyourplaylist", true);
                                } else {
                                  await musicProvider
                                      .addremoveContentToPlaylist(
                                          Constant.channelID,
                                          musicProvider.playlistId,
                                          "2",
                                          contentid,
                                          "0",
                                          "1");

                                  if (!musicProvider.loading) {
                                    if (musicProvider
                                            .addremoveContentToPlaylistModel
                                            .status ==
                                        200) {
                                      printLog("Added Succsessfully");
                                      Utils().showToast("Save to Playlist");
                                    } else {
                                      Utils().showToast(
                                          "${musicProvider.addremoveContentToPlaylistModel.message}");
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
                                    color: white,
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
    return Consumer<MusicProvider>(builder: (context, playlistprovider, child) {
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
    log("Playlist Lenght==>${musicProvider.playlistData?.length ?? 0}");
    log("Playlist Position==>${musicProvider.playlistPosition}");
    log("Playlist Id==>${musicProvider.playlistId}");
    if (musicProvider.getContentbyChannelModel.status == 200 &&
        musicProvider.playlistData != null) {
      if ((musicProvider.playlistData?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: musicProvider.playlistData?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
              splashColor: transparent,
              highlightColor: transparent,
              hoverColor: transparent,
              focusColor: transparent,
              onTap: () {
                musicProvider.selectPlaylist(
                    index,
                    musicProvider.playlistData?[index].id.toString() ?? "",
                    true);
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                color: musicProvider.playlistPosition == index &&
                        musicProvider.isSelectPlaylist == true
                    ? colorPrimary
                    : colorPrimaryDark,
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                        color: white,
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
                          text: musicProvider.playlistData?[index].title
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
                    musicProvider.playlistPosition == index &&
                            musicProvider.isSelectPlaylist == true
                        ? MyImage(width: 18, height: 18, imagePath: "true.png")
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
            child: Consumer<MusicProvider>(
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
                        splashColor: transparent,
                        highlightColor: transparent,
                        hoverColor: transparent,
                        focusColor: transparent,
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
                                  color: white,
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
                        splashColor: transparent,
                        highlightColor: transparent,
                        hoverColor: transparent,
                        focusColor: transparent,
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
                                  color: white,
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
                        splashColor: transparent,
                        highlightColor: transparent,
                        hoverColor: transparent,
                        focusColor: transparent,
                        radius: 50,
                        autofocus: false,
                        onTap: () {
                          Navigator.pop(context);
                          playlistTitleController.clear();
                          musicProvider.isType = 0;
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
                        splashColor: transparent,
                        highlightColor: transparent,
                        hoverColor: transparent,
                        focusColor: transparent,
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
                              musicProvider.isType.toString(),
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
                            musicProvider.isType = 0;
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
                              color: white,
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
}
