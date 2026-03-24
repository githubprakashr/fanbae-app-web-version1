import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:fanbae/provider/likevideosprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customads.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/webdetail.dart';
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

class WebLikeVideos extends StatefulWidget {
  const WebLikeVideos({super.key});

  @override
  State<WebLikeVideos> createState() => WebLikeVideosState();
}

class WebLikeVideosState extends State<WebLikeVideos> {
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
      appBar: Utils.webAppbarWithSidePanel(
          context: context, contentType: Constant.videoSearch),
      body: Utils.sidePanelWithBody(
        myWidget: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 100),
          child: buildPage(),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              MusicTitle(
                  color: white,
                  text: "likevideos",
                  textalign: TextAlign.left,
                  fontsizeNormal: Dimens.textExtraBig,
                  fontsizeWeb: Dimens.textExtraBig,
                  multilanguage: true,
                  maxline: 1,
                  fontwaight: FontWeight.w700,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
              const SizedBox(height: 30),
              CustomAds(adType: Constant.bannerAdType),
              const SizedBox(height: 20),
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
          minItemsPerRow: Utils.crossAxisCount(context),
          maxItemsPerRow: Utils.crossAxisCount(context),
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
                  if (ResponsiveHelper.checkIsWeb(context)) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            WebDetail(
                                stoptime: 0,
                                iscontinueWatching: false,
                                videoid:
                                    likeVideosProvider.likevideoList?[index].id
                                            .toString() ??
                                        "",
                                feedType: likeVideosProvider
                                        .likevideoList?[index].contentType
                                        .toString() ??
                                    ""),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    AdHelper.showFullscreenAd(
                        context, Constant.interstialAdType, () {
                      Utils.moveToDetail(
                          context,
                          0,
                          false,
                          likeVideosProvider.likevideoList?[index].id
                                  .toString() ??
                              "",
                          false,
                          likeVideosProvider.likevideoList?[index].contentType
                                  .toString() ??
                              "",
                          likeVideosProvider.likevideoList?[index].isComment);
                    });
                  }
                },
                child: InteractiveContainer(child: (isHovered) {
                  return Wrap(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 180,
                            foregroundDecoration: isHovered
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
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
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.fill,
                                  imagePath: likeVideosProvider
                                          .likevideoList?[index].landscapeImg
                                          .toString() ??
                                      ""),
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: MyImage(
                                    width: 50,
                                    height: 50,
                                    imagePath: "pause.png"),
                              ),
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
                                    text: Utils.formatTime(double.parse(
                                        likeVideosProvider.likevideoList?[index]
                                                .contentDuration
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
                          isHovered
                              ? Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Consumer<LikeVideosProvider>(builder:
                                        (context, likevideoprovider, child) {
                                      if (likevideoprovider.position == index &&
                                          likevideoprovider.isRemove) {
                                        return Container(
                                          height: 25,
                                          width: 25,
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 8, 8, 8),
                                          child:
                                              const CircularProgressIndicator(
                                            color: colorPrimary,
                                            strokeWidth: 1,
                                          ),
                                        );
                                      } else {
                                        return InkWell(
                                          onTap: () async {
                                            await likeVideosProvider
                                                .addLikeDislike(
                                                    index,
                                                    "1",
                                                    likeVideosProvider
                                                            .likevideoList?[
                                                                index]
                                                            .id
                                                            .toString() ??
                                                        "",
                                                    "0",
                                                    "0",
                                                    true);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 5, 8, 0),
                                            child: MyImage(
                                                width: 25,
                                                height: 25,
                                                imagePath: "heart.png",
                                                color: colorPrimary),
                                          ),
                                        );
                                      }
                                    }),
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
                                width: 35,
                                height: 35,
                                imagePath: likeVideosProvider
                                        .likevideoList?[index].channelImage
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
                                      text: likeVideosProvider
                                              .likevideoList?[index].title
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
                                  const SizedBox(height: 5),
                                  RichText(
                                    text: TextSpan(
                                      text:
                                          "${likeVideosProvider.likevideoList?[index].channelName.toString() ?? ""}  ",
                                      style: Utils.googleFontStyle(
                                          1,
                                          Dimens.textSmall,
                                          FontStyle.normal,
                                          gray,
                                          FontWeight.w400),
                                      children: [
                                        TextSpan(
                                          text:
                                              "${Utils.kmbGenerator(likeVideosProvider.likevideoList?[0].totalView ?? 0)} ",
                                          style: Utils.googleFontStyle(
                                              1,
                                              Dimens.textSmall,
                                              FontStyle.normal,
                                              gray,
                                              FontWeight.w400),
                                        ),
                                        TextSpan(
                                          text: 'views ',
                                          style: Utils.googleFontStyle(
                                              1,
                                              Dimens.textSmall,
                                              FontStyle.normal,
                                              gray,
                                              FontWeight.w400),
                                        ),
                                        TextSpan(
                                          text: Utils.timeAgoCustom(
                                            DateTime.parse(
                                              likeVideosProvider
                                                      .likevideoList?[index]
                                                      .createdAt ??
                                                  "",
                                            ),
                                          ),
                                          style: Utils.googleFontStyle(
                                              1,
                                              Dimens.textSmall,
                                              FontStyle.normal,
                                              gray,
                                              FontWeight.w400),
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
                    ],
                  );
                }),
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
}
