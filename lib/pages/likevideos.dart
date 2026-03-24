import 'dart:developer';
import 'package:fanbae/pages/login.dart';
import 'package:fanbae/music/musicdetails.dart';
import 'package:fanbae/provider/likevideosprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class LikeVideos extends StatefulWidget {
  const LikeVideos({super.key});

  @override
  State<LikeVideos> createState() => _LikeVideosState();
}

class _LikeVideosState extends State<LikeVideos> {
  late LikeVideosProvider likeVideosProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    likeVideosProvider =
        Provider.of<LikeVideosProvider>(context, listen: false);
    _fetchData(0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (likeVideosProvider.currentPage ?? 0) <
            (likeVideosProvider.totalPage ?? 0)) {
      printLog("load more====>");
      likeVideosProvider.setLoadMore(true);
      _fetchData(likeVideosProvider.currentPage ?? 0);
    } else {
      printLog("click");
    }
  }

  Future<void> _fetchData(int? nextPage) async {
    printLog("isMorePage  ======> ${likeVideosProvider.isMorePage}");
    log("currentPage ======> ${likeVideosProvider.currentPage}");
    printLog("totalPage   ======> ${likeVideosProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await likeVideosProvider.getlikeVideos("1", (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    likeVideosProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: Utils().otherPageAppBar(context, "likevideos", true),
      body: Utils().pageBg(
        context,
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 190),
              child: buildPage(),
            ),
            Utils.musicAndAdsPanel(context),
          ],
        ),
      ),
    );
  }

  Widget buildPage() {
    return Consumer<LikeVideosProvider>(
        builder: (context, likevideoprovider, child) {
      if (likevideoprovider.loading && !likevideoprovider.loadMore) {
        return shimmer();
      } else {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              buildLikeVideoList(),
              if (likevideoprovider.loadMore)
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

  Widget buildLikeVideoList() {
    if (likeVideosProvider.likeContentModel.status == 200 &&
        likeVideosProvider.likevideoList != null) {
      if ((likeVideosProvider.likevideoList?.length ?? 0) > 0) {
        return ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 3,
          maxItemsPerRow: 3,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
          ),
          children: List.generate(
            likeVideosProvider.likevideoList?.length ?? 0,
            (index) {
              return InkWell(
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
                    audioPlayer.pause();
                    Utils.openPlayer(
                      isDownloadVideo: false,
                      iscontinueWatching: false,
                      stoptime: 0.0,
                      context: context,
                      videoId: likeVideosProvider.likevideoList?[index].id
                              .toString() ??
                          "",
                      videoUrl: likeVideosProvider.likevideoList?[index].content
                              .toString() ??
                          "",
                      vUploadType: likeVideosProvider
                              .likevideoList?[index].contentUploadType
                              .toString() ??
                          "",
                      videoThumb: likeVideosProvider
                              .likevideoList?[index].landscapeImg
                              .toString() ??
                          "",
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: MyNetworkImage(
                              width: 150,
                              height: 110,
                              fit: BoxFit.cover,
                              imagePath: likeVideosProvider
                                      .likevideoList?[index].landscapeImg
                                      .toString() ??
                                  "",
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
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
                                  }
                                  audioPlayer.pause();
                                  Utils.openPlayer(
                                    isDownloadVideo: false,
                                    iscontinueWatching: false,
                                    stoptime: 0.0,
                                    context: context,
                                    videoId: likeVideosProvider
                                            .likevideoList?[index].id
                                            .toString() ??
                                        "",
                                    videoUrl: likeVideosProvider
                                            .likevideoList?[index].content
                                            .toString() ??
                                        "",
                                    vUploadType: likeVideosProvider
                                            .likevideoList?[index]
                                            .contentUploadType
                                            .toString() ??
                                        "",
                                    videoThumb: likeVideosProvider
                                            .likevideoList?[index].landscapeImg
                                            .toString() ??
                                        "",
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: MyImage(
                                      width: 40,
                                      height: 40,
                                      imagePath: "pause.png"),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () async {
                                  await likeVideosProvider.addLikeDislike(
                                      index,
                                      "1",
                                      likeVideosProvider
                                              .likevideoList?[index].id
                                              .toString() ??
                                          "",
                                      "0",
                                      "0",
                                      true);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 5, 8, 0),
                                  child: MyImage(
                                      width: 25,
                                      height: 25,
                                      imagePath: "heart.png",
                                      color: colorPrimary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MyText(
                          color: white,
                          text: likeVideosProvider.likevideoList?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textSmall,
                          inter: false,
                          multilanguage: false,
                          maxline: 2,
                          fontwaight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          MyText(
                              color: gray,
                              text: Utils.kmbGenerator(int.parse(
                                  likeVideosProvider
                                          .likevideoList?[index].totalLike
                                          .toString() ??
                                      "")),
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textSmall,
                              inter: false,
                              multilanguage: false,
                              maxline: 2,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          const SizedBox(width: 8),
                          MyText(
                              color: gray,
                              text: "like",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textSmall,
                              inter: false,
                              multilanguage: true,
                              maxline: 2,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      ),
                    ],
                  ),
                ),
              );
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

  Widget shimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 3,
          maxItemsPerRow: 3,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            15,
            (index) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomWidget.roundrectborder(
                      width: 150,
                      height: 110,
                    ),
                    SizedBox(height: 10),
                    CustomWidget.roundrectborder(
                      width: 100,
                      height: 5,
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
      ),
    );
  }
}
