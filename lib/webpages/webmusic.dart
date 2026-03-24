import 'package:carousel_slider/carousel_slider.dart';
import 'package:fanbae/model/sectionlistmodel.dart';
import 'package:fanbae/provider/musicdetailprovider.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customads.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/musicmanager.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/getmusicbycategoryweb.dart';
import 'package:fanbae/webpages/getmusicbylanguageweb.dart';
import 'package:fanbae/webpages/webcontentdetail.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/webpages/webseeall.dart';
import 'package:fanbae/webwidget/interactivecontainer.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/provider/musicprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:provider/provider.dart';

import '../pages/createmusic.dart';

class WebMusic extends StatefulWidget {
  const WebMusic({super.key});

  @override
  State<WebMusic> createState() => WebMusicState();
}

class WebMusicState extends State<WebMusic> {
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

  buildCreateMusicDialog() {
    return showDialog(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
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
                child: CreateMusic()),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: Utils.webAppbarWithSidePanel(
          context: context, contentType: Constant.musicSearch),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 50, right: 40),
        child: FloatingActionButton(
          onPressed: () {
            buildCreateMusicDialog();
            /*  Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const CreateMusic();
                },
              ),
            );*/
          },
          backgroundColor: colorPrimary,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      body: Utils.sidePanelWithBody(
        myWidget: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
        height: 100,
        child: ListView.builder(
            itemCount: Constant.tabList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                focusColor: appbgcolor,
                highlightColor: appbgcolor,
                hoverColor: appbgcolor,
                splashColor: appbgcolor,
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
                  } else {
                    if (!context.mounted) return;
                    Utils().showSnackBar(
                        context, "Something Went Wronge !!!", true);
                  }
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: 250,
                  padding: const EdgeInsets.fromLTRB(25, 0, 15, 0),
                  margin: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: seactionprovider.tabindex == index
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
                              color: seactionprovider.tabindex == index
                                  ? colorAccent
                                  : white,
                              imagePath: Constant.tabIconList[index]),
                          const SizedBox(width: 10),
                          MusicTitle(
                              color: seactionprovider.tabindex == index
                                  ? colorAccent
                                  : white,
                              multilanguage: true,
                              text: Constant.tabList[index],
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
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 100),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: CustomAds(adType: Constant.bannerAdType),
                ),
                const SizedBox(height: 15),
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
                    padding: const EdgeInsets.fromLTRB(15, 25, 15, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MusicTitle(
                                  color: gray,
                                  multilanguage: false,
                                  text: musicProvider
                                          .sectionList?[index].shortTitle
                                          .toString()
                                          .toUpperCase() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textMedium,
                                  fontsizeWeb: Dimens.textMedium,
                                  maxline: 1,
                                  fontwaight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 5),
                              MusicTitle(
                                  color: white,
                                  multilanguage: false,
                                  text: musicProvider.sectionList?[index].title
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textExtralargeBig,
                                  fontsizeWeb: Dimens.textExtralargeBig,
                                  maxline: 1,
                                  fontwaight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          ),
                        ),
                        musicProvider.sectionList?[index].viewAll == 1
                            ? InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (context, animation1, animation2) =>
                                              WebSeeAll(
                                        isRent: false,
                                        sectionId: musicProvider
                                                .sectionList?[index].id
                                                .toString() ??
                                            "",
                                        contentType: musicProvider
                                                .sectionList?[index].contentType
                                                .toString() ??
                                            "",
                                        title: musicProvider
                                                .sectionList?[index].title
                                                .toString() ??
                                            "",
                                      ),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 8, 15, 8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                          width: 0.8,
                                          color: white.withAlpha(20))),
                                  child: MusicTitle(
                                      color: white,
                                      multilanguage: true,
                                      text: "seeall",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      maxline: 1,
                                      fontwaight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Section Data List
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: getRemainingDataHeight(
                        musicProvider.sectionList?[index].screenLayout
                                .toString() ??
                            "",
                      ),
                      child: setSectionData(
                          index: index, sectionList: musicProvider.sectionList),
                    ),
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

  double getRemainingDataHeight(String? layoutType) {
    if (layoutType == "list_view") {
      return Dimens.listviewLayoutheightWeb;
    } else if (layoutType == "portrait") {
      return Dimens.portraitheightWeb;
    } else if (layoutType == "square") {
      return Dimens.squareheightWeb;
    } else if (layoutType == "round") {
      return Dimens.roundheightWeb;
    } else if (layoutType == "playlist") {
      return Dimens.playlistheightWeb;
    } else if (layoutType == "category") {
      return Dimens.categoryheightWeb;
    } else if (layoutType == "language") {
      return Dimens.languageheightWeb;
    } else if (layoutType == "banner_view") {
      return Dimens.podcastbannerheightWeb;
    } else if (layoutType == "landscape") {
      return Dimens.landscapPodcastheightWeb;
    } else if (layoutType == "podcast_list_view") {
      return Dimens.podcastListviewheightWeb;
    } else {
      return Dimens.squareheightWeb;
    }
  }

/* Music Layout */

  Widget square(int sectionindex, List<Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.squareheightWeb,
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              if (Constant.userID == null) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const WebLogin(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
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
                  contentDiscription: sectionList?[sectionindex]
                          .data?[index]
                          .description
                          .toString() ??
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
            },
            child: InteractiveContainer(child: (isHovered) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 125,
                        height: 125,
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
                            imagePath: sectionList?[sectionindex]
                                    .data?[index]
                                    .portraitImg
                                    .toString() ??
                                "",
                          ),
                        ),
                      ),
                      isHovered
                          ? Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: white,
                                  size: 35,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      Positioned.fill(
                        left: 10,
                        right: 10,
                        top: 10,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: MediaQuery.of(context).size.width > 400 &&
                                  isHovered
                              ? InkWell(
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
                                        sectionList?[sectionindex]
                                                .data?[index]
                                                .landscapeImg
                                                .toString() ??
                                            "",
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
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: MyImage(
                                        width: 13,
                                        height: 13,
                                        imagePath: "ic_more.png"),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 115,
                        child: MusicTitle(
                            color: white,
                            text: sectionList?[sectionindex]
                                    .data?[index]
                                    .title
                                    .toString() ??
                                "",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            fontsizeWeb: Dimens.textMedium,
                            multilanguage: false,
                            maxline: 2,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                      MediaQuery.of(context).size.width < 400
                          ? InkWell(
                              onTap: () {
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
                                  moreBottomSheet(
                                    sectionList?[sectionindex]
                                            .data?[index]
                                            .landscapeImg
                                            .toString() ??
                                        "",
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
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: MyImage(
                                    width: 13,
                                    height: 13,
                                    imagePath: "ic_more.png"),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MusicTitle(
                      color: gray,
                      text: sectionList?[sectionindex]
                              .data?[index]
                              .artistName
                              .toString() ??
                          "",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textMedium,
                      fontsizeWeb: Dimens.textMedium,
                      multilanguage: false,
                      maxline: 1,
                      fontwaight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ],
              );
            }),
          );
        },
      ),
    );
  }

  Widget portrait(int sectionindex, List<Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.portraitheightWeb,
      child: ListView.separated(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              if (Constant.userID == null) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const WebLogin(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
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
                  contentDiscription: sectionList?[sectionindex]
                          .data?[index]
                          .description
                          .toString() ??
                      "",
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
            },
            child: InteractiveContainer(child: (isHovered) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 170,
                          height: 160,
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
                              imagePath: sectionList?[sectionindex]
                                      .data?[index]
                                      .landscapeImg
                                      .toString() ??
                                  "",
                            ),
                          ),
                        ),
                        isHovered
                            ? Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: white,
                                    size: 35,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        MediaQuery.of(context).size.width > 400
                            ? Positioned.fill(
                                top: 10,
                                left: 10,
                                right: 10,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: isHovered
                                      ? InkWell(
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
                                                sectionList?[sectionindex]
                                                        .data?[index]
                                                        .landscapeImg
                                                        .toString() ??
                                                    "",
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
                                              );
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: MyImage(
                                                width: 13,
                                                height: 13,
                                                imagePath: "ic_more.png"),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 155,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: MusicTitle(
                                color: white,
                                text: sectionList?[sectionindex]
                                        .data?[index]
                                        .title
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textDesc,
                                fontsizeWeb: Dimens.textDesc,
                                multilanguage: false,
                                maxline: 2,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                          const SizedBox(width: 8),
                          MediaQuery.of(context).size.width < 400
                              ? InkWell(
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
                                        sectionList?[sectionindex]
                                                .data?[index]
                                                .landscapeImg
                                                .toString() ??
                                            "",
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
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: MyImage(
                                        width: 13,
                                        height: 13,
                                        imagePath: "ic_more.png"),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    MusicTitle(
                        color: gray,
                        text: sectionList?[sectionindex]
                                .data?[index]
                                .artistName
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textDesc,
                        fontsizeWeb: Dimens.textDesc,
                        multilanguage: false,
                        maxline: 2,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget listviewLayout(int sectionindex, List<Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 270,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(),
        child: Wrap(
          direction: Axis.vertical,
          runSpacing: -2,
          children: [
            ...List.generate(
              sectionList?[sectionindex].data?.length ?? 0,
              (index) => InkWell(
                onTap: () {
                  if (Constant.userID == null) {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
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
                      contentDiscription: sectionList?[sectionindex]
                              .data?[index]
                              .description
                              .toString() ??
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
                },
                child: InteractiveContainer(child: (isHovered) {
                  return Container(
                    width: 400,
                    height: 55,
                    margin: const EdgeInsets.fromLTRB(15, 7, 15, 7),
                    child: Row(
                      children: [
                        Consumer<MusicProvider>(
                            builder: (context, seactionprovider, child) {
                          return Stack(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
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
                                  borderRadius: BorderRadius.circular(2),
                                  child: MyNetworkImage(
                                      fit: BoxFit.cover,
                                      imagePath: sectionList?[sectionindex]
                                              .data?[index]
                                              .portraitImg
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
                          );
                        }),
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
                                  fontsizeWeb: Dimens.textDesc,
                                  maxline: 1,
                                  fontwaight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MusicTitle(
                                      color: gray,
                                      multilanguage: false,
                                      text: sectionList?[sectionindex]
                                              .data?[index]
                                              .artistName
                                              .toString() ??
                                          "",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      maxline: 1,
                                      fontwaight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(width: 5),
                                  MusicTitle(
                                      color: gray,
                                      multilanguage: false,
                                      text: Utils.kmbGenerator(int.parse(
                                          sectionList?[sectionindex]
                                                  .data?[index]
                                                  .totalView
                                                  .toString() ??
                                              "")),
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      maxline: 1,
                                      fontwaight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(width: 3),
                                  MusicTitle(
                                      color: gray,
                                      multilanguage: false,
                                      text: "views",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      maxline: 1,
                                      fontwaight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ],
                              ),
                            ],
                          ),
                        ),
                        isHovered && MediaQuery.of(context).size.width > 400
                            ? InkWell(
                                onTap: () {
                                  if (Constant.userID == null) {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                const WebLogin(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
                                  } else {
                                    moreBottomSheet(
                                      sectionList?[sectionindex]
                                              .data?[index]
                                              .landscapeImg
                                              .toString() ??
                                          "",
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
                              )
                            : const SizedBox.shrink(),
                        MediaQuery.of(context).size.width < 400
                            ? InkWell(
                                onTap: () {
                                  if (Constant.userID == null) {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                const WebLogin(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
                                  } else {
                                    moreBottomSheet(
                                      sectionList?[sectionindex]
                                              .data?[index]
                                              .landscapeImg
                                              .toString() ??
                                          "",
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
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }

/* Playlist Layout */

  Widget playlist(int sectionindex, List<Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.playlistheightWeb,
      child: ListView.separated(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          return InkWell(
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
                contentDiscription: sectionList?[sectionindex]
                        .data?[index]
                        .description
                        .toString() ??
                    "",
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
                playlistImages:
                    sectionList?[sectionindex].data?[index].playlistImage ?? [],
                isBuy:
                    sectionList?[sectionindex].data?[index].isBuy.toString() ??
                        "",
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 170,
                      height: 160,
                      child: playlistImages(sectionindex, index, sectionList)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 170,
                    child: MusicTitle(
                        color: white,
                        text: sectionList?[sectionindex]
                                .data?[index]
                                .title
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
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
                            fontsizeWeb: Dimens.textMedium,
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
                            fontsizeWeb: Dimens.textMedium,
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
          width: 170,
          height: 160,
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
                        height: MediaQuery.of(context).size.height,
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
                        height: MediaQuery.of(context).size.height,
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
                        height: MediaQuery.of(context).size.height,
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
                        height: MediaQuery.of(context).size.height,
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
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
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
                        height: MediaQuery.of(context).size.height,
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
                        height: MediaQuery.of(context).size.height,
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
                  height: MediaQuery.of(context).size.height,
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
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
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
                        height: MediaQuery.of(context).size.height,
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
                        height: MediaQuery.of(context).size.height,
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
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: MyNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
            imagePath: sectionList?[sectionindex]
                    .data?[index]
                    .playlistImage?[0]
                    .toString() ??
                "",
          ));
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
      height: Dimens.categoryheightWeb,
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
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      GetMusicByCategoryWeb(
                    categoryId:
                        sectionList?[sectionindex].data?[index].id.toString() ??
                            "",
                    title: sectionList?[sectionindex]
                            .data?[index]
                            .title
                            .toString() ??
                        "",
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Utils.generateRendomColor().withOpacity(0.30),
                  width: 225,
                  padding: const EdgeInsets.all(15),
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
            ),
          );
        },
      ),
    );
  }

  Widget language(int sectionindex, List<Result>? sectionList) {
    return Container(
      alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width,
      height: Dimens.languageheightWeb,
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      GetMusicByLanguageWeb(
                    languageId:
                        sectionList?[sectionindex].data?[index].id.toString() ??
                            "",
                    title: sectionList?[sectionindex]
                            .data?[index]
                            .title
                            .toString() ??
                        "",
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              alignment: Alignment.center,
              foregroundDecoration: BoxDecoration(
                color: Utils.generateRendomColor().withOpacity(0.30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: MusicTitle(
                  color: white,
                  multilanguage: false,
                  text: sectionList?[sectionindex]
                          .data?[index]
                          .title
                          .toString() ??
                      "",
                  textalign: TextAlign.center,
                  fontsizeNormal: Dimens.textMedium,
                  fontsizeWeb: Dimens.textMedium,
                  maxline: 1,
                  fontwaight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
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
      height: Dimens.roundheightWeb,
      child: ListView.separated(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
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
                contentDiscription: sectionList?[sectionindex]
                        .data?[index]
                        .description
                        .toString() ??
                    "",
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
            child: InteractiveContainer(child: (isHovered) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: MyNetworkImage(
                      width: 130,
                      height: 130,
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
                        fontsizeNormal: Dimens.textSmall,
                        fontsizeWeb: Dimens.textSmall,
                        multilanguage: false,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ),
                ],
              );
            }),
          );
        },
      ),
    );
  }

/* Podcast */
  Widget bannerPodcast(int sectionindex, List<Result>? sectionList) {
    return SizedBox(
      height: Dimens.podcastbannerheightWeb,
      child: CarouselSlider.builder(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        carouselController: bannerController,
        options: CarouselOptions(
          initialPage: 0,
          height: MediaQuery.of(context).size.height,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
          autoPlay: false,
          autoPlayCurve: Curves.linear,
          enableInfiniteScroll: true,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(seconds: 3),
          viewportFraction: 0.6,
          onPageChanged: (index, reason) async {},
        ),
        itemBuilder: (BuildContext context, int index, int pageViewIndex) {
          return InkWell(
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
                contentDiscription: sectionList?[sectionindex]
                        .data?[index]
                        .description
                        .toString() ??
                    "",
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
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        imagePath: sectionList?[sectionindex]
                                .data?[index]
                                .portraitImg
                                .toString() ??
                            "",
                        fit: BoxFit.cover),
                    Positioned.fill(
                      left: 15,
                      right: 15,
                      bottom: 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.60,
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
                                      fontsizeWeb: Dimens.textDesc,
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
            ),
          );
        },
      ),
    );
  }

  Widget landscapPodcast(int sectionindex, List<Result>? sectionList) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: Dimens.landscapPodcastheightWeb,
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Wrap(
          direction: Axis.vertical,
          runSpacing: 30,
          children: [
            ...List.generate(
              sectionList?[sectionindex].data?.length ?? 0,
              (index) => InkWell(
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
                    contentDiscription: sectionList?[sectionindex]
                            .data?[index]
                            .description
                            .toString() ??
                        "",
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
                  width: 250,
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
                            borderRadius: BorderRadius.circular(5),
                            child: MyNetworkImage(
                                width: MediaQuery.of(context).size.width,
                                height: 140,
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
                      const SizedBox(height: 15),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
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
                              fontsizeWeb: Dimens.textDesc,
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
          ],
        ),
      ),
    );
  }

  Widget podcastListview(int sectionindex, List<Result>? sectionList) {
    return SizedBox(
      height: Dimens.podcastListviewheightWeb,
      child: ListView.separated(
          itemCount: sectionList?[sectionindex].data?.length ?? 0,
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            return InkWell(
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
                  contentDiscription: sectionList?[sectionindex]
                          .data?[index]
                          .description
                          .toString() ??
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
                width: 400,
                height: MediaQuery.of(context).size.height,
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
                                  fontsizeWeb: Dimens.textExtraBig,
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
                                  fontsizeWeb: Dimens.textMedium,
                                  maxline: 2,
                                  fontwaight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    MusicTitle(
                        color: white,
                        multilanguage: true,
                        text: "episodes",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        maxline: 2,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 10),
                    ListView.builder(
                        itemCount: 1,
                        // itemCount: sectionList?[sectionindex]
                        //         .data?[index]
                        //         .episodeArray
                        //         ?.length ??
                        //     0,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          fontsizeWeb: Dimens.textTitle,
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
                                          fontsizeWeb: Dimens.textSmall,
                                          maxline: 1,
                                          fontwaight: FontWeight.w400,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Stack(
                                  children: <Widget>[
                                    Text(
                                      (index + 1).toString(),
                                      style: TextStyle(
                                        fontSize: 50,
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 6
                                          ..color = colorPrimary,
                                      ),
                                    ),
                                    Text(
                                      (index + 1).toString(),
                                      style: TextStyle(
                                        fontSize: 50,
                                        color: white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                  ],
                ),
              ),
            );
          }),
    );
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
                      CustomWidget.roundrectborder(height: 10, width: 200),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(height: 10, width: 200),
                    ],
                  ),
                  CustomWidget.roundrectborder(height: 10, width: 100),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: Dimens.listviewLayoutheightWeb,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child:
                      Wrap(direction: Axis.vertical, runSpacing: -2, children: [
                    ...List.generate(
                      20,
                      (index) => Container(
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
                      CustomWidget.roundrectborder(height: 10, width: 200),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(height: 10, width: 200),
                    ],
                  ),
                  CustomWidget.roundrectborder(height: 10, width: 100),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: Dimens.squareheightWeb,
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(width: 3),
                itemCount: 10,
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
                          width: 125,
                          height: 125,
                        ),
                        SizedBox(height: 5),
                        CustomWidget.roundrectborder(
                          width: 120,
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
                      CustomWidget.roundrectborder(height: 10, width: 200),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(height: 10, width: 200),
                    ],
                  ),
                  CustomWidget.roundrectborder(height: 10, width: 100),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: Dimens.roundheightWeb,
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(width: 3),
                itemCount: 10,
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
                          width: 130,
                          height: 130,
                        ),
                        SizedBox(height: 5),
                        CustomWidget.roundrectborder(
                          width: 100,
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
    required String? contentDiscription,
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
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => WebContentDetail(
            contentType: playingType,
            contentUserid: contentUserid ?? "",
            contentImage: podcastimage ?? "",
            contentName: contentName,
            playlistImage: playlistImages ?? [],
            contentId: contentid,
            contentDiscription: contentDiscription ?? "",
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
              minHeight: 220,
              maxHeight: 250,
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
                          child: MusicTitle(
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
                        const SizedBox(width: 20),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            size: 25,
                            color: white,
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
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget moreFunctionItem(icon, title, onTap) {
    return ListTile(
      iconColor: white,
      textColor: white,
      title: MusicTitle(
        color: white,
        text: title,
        fontwaight: FontWeight.w500,
        fontsizeNormal: Dimens.textTitle,
        fontsizeWeb: Dimens.textTitle,
        maxline: 1,
        multilanguage: true,
        overflow: TextOverflow.ellipsis,
        textalign: TextAlign.left,
        fontstyle: FontStyle.normal,
      ),
      leading: MyImage(
        width: 20,
        height: 20,
        imagePath: icon,
        color: white,
      ),
      onTap: onTap,
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
                        MusicTitle(
                            color: white,
                            text: "selectplaylist",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textBig,
                            fontsizeWeb: Dimens.textBig,
                            multilanguage: true,
                            maxline: 2,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            createPlaylistDilog(
                                playlistId: musicProvider.playlistId);
                          },
                          child: Container(
                            width: 160,
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: colorPrimary),
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
                                MusicTitle(
                                    color: white,
                                    text: "createplaylist",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textDesc,
                                    fontsizeWeb: Dimens.textDesc,
                                    multilanguage: true,
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
                      if (musicProvider.getContentbyChannelModel.status ==
                              200 &&
                          musicProvider.playlistData != null) {
                        if ((musicProvider.playlistData?.length ?? 0) > 0) {
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
                                  child: MusicTitle(
                                      color: white,
                                      text: "cancel",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textBig,
                                      fontsizeWeb: Dimens.textBig,
                                      multilanguage: true,
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
                                  if (musicProvider.playlistId.isEmpty ||
                                      musicProvider.playlistId == "") {
                                    Utils().showSnackBar(context,
                                        "pleaseelectyourplaylist", true);
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
                                        Utils().showToast(
                                            "${musicProvider.addremoveContentToPlaylistModel.message}");
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
                                  child: MusicTitle(
                                      color: colorAccent,
                                      text: "addcontent",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textBig,
                                      fontsizeWeb: Dimens.textBig,
                                      multilanguage: true,
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
        });
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
                    MusicTitle(
                        color: musicProvider.playlistPosition == index &&
                                musicProvider.isSelectPlaylist == true
                            ? colorAccent
                            : white,
                        text: "${(index + 1).toString()}.",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textTitle,
                        fontsizeWeb: Dimens.textTitle,
                        multilanguage: false,
                        maxline: 2,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(width: 20),
                    Expanded(
                      child: MusicTitle(
                          color: musicProvider.playlistPosition == index &&
                                  musicProvider.isSelectPlaylist == true
                              ? colorAccent
                              : white,
                          text: musicProvider.playlistData?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          fontsizeWeb: Dimens.textTitle,
                          multilanguage: false,
                          maxline: 2,
                          fontwaight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                    const SizedBox(width: 20),
                    musicProvider.playlistPosition == index &&
                            musicProvider.isSelectPlaylist == true
                        ? Icon(
                            Icons.check,
                            color: musicProvider.playlistPosition == index &&
                                    musicProvider.isSelectPlaylist == true
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
            child: Consumer<MusicProvider>(
                builder: (context, createplaylistprovider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MusicTitle(
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
                      MusicTitle(
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
                      MusicTitle(
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
                      MusicTitle(
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
                      MusicTitle(
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
                          child: MusicTitle(
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
                          child: MusicTitle(
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
}
