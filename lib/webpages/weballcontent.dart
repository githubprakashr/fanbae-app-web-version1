import 'package:fanbae/provider/allcontentprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/webmyplaylist.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class WebAllContent extends StatefulWidget {
  final String playlistId;

  const WebAllContent({super.key, required this.playlistId});

  @override
  State<WebAllContent> createState() => WebAllContentState();
}

class WebAllContentState extends State<WebAllContent> {
  late ScrollController _scrollController;
  late AllContentProvider allContentProvider;

  @override
  void initState() {
    allContentProvider =
        Provider.of<AllContentProvider>(context, listen: false);
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
        (allContentProvider.currentPage ?? 0) <
            (allContentProvider.totalPage ?? 0)) {
      await allContentProvider.setLoadMore(true);
      if (allContentProvider.tabindex == 0) {
        _fetchData("1", allContentProvider.currentPage ?? 0);
      } else if (allContentProvider.tabindex == 1) {
        _fetchData("2", allContentProvider.currentPage ?? 0);
      } else if (allContentProvider.tabindex == 2) {
        _fetchData("4", allContentProvider.currentPage ?? 0);
      } else if (allContentProvider.tabindex == 3) {
        _fetchData("7", allContentProvider.currentPage ?? 0);
      } else {
        if (!mounted) return;
        Utils().showSnackBar(context, "somethingwentwronge", true);
      }
    }
  }

  Future<void> _fetchData(contentType, int? nextPage) async {
    printLog("isMorePage  ======> ${allContentProvider.isMorePage}");
    printLog("currentPage ======> ${allContentProvider.currentPage}");
    printLog("totalPage   ======> ${allContentProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await allContentProvider.getContentByPlaylist(
        contentType, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    super.dispose();
    allContentProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: Utils.webAppbarWithSidePanel(
          context: context, contentType: Constant.videoSearch),
      floatingActionButton: Consumer<AllContentProvider>(
          builder: (context, allcontentprovider, child) {
        return FloatingActionButton.extended(
          onPressed: () async {
            String contentIds = allContentProvider.storeContentId.join(",");

            if (allcontentprovider.tabindex == 0) {
              if (contentIds.isEmpty) {
                Utils().showSnackBar(context, "pleaseselectvideo", true);
              } else {
                addMultipleItemToPlaylist(
                    allContentId: contentIds, contentType: "1");
              }
            } else if (allcontentprovider.tabindex == 1) {
              if (contentIds.isEmpty) {
                Utils().showSnackBar(context, "pleaseselectmusic", true);
              } else {
                addMultipleItemToPlaylist(
                    allContentId: contentIds, contentType: "2");
              }
            } else if (allcontentprovider.tabindex == 2) {
              if (contentIds.isEmpty) {
                Utils().showSnackBar(context, "pleaseselectpodcast", true);
              } else {
                addMultipleItemToPlaylist(
                    allContentId: contentIds, contentType: "4");
              }
            } else if (allcontentprovider.tabindex == 3) {
              if (contentIds.isEmpty) {
                Utils().showSnackBar(context, "pleaseselectLive", true);
              } else {
                addMultipleItemToPlaylist(
                    allContentId: contentIds, contentType: "7");
              }
            }
            /*else if (allcontentprovider.tabindex == 3) {
              if (contentIds.isEmpty) {
                Utils().showSnackBar(context, "pleaseselectradio", true);
              } else {
                addMultipleItemToPlaylist(
                    allContentId: contentIds, contentType: "6");
              }
            }*/
            else {
              Utils().showSnackBar(context, "somethingwentwronge", true);
            }
          },
          focusColor: colorPrimary,
          backgroundColor: colorPrimary,
          elevation: 1,
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: colorAccent,
              ),
              MyText(
                  color: colorAccent,
                  text:
                      flotingButtonTitle(tabindex: allcontentprovider.tabindex),
                  textalign: TextAlign.left,
                  fontsizeNormal: Dimens.textTitle,
                  multilanguage: false,
                  inter: false,
                  maxline: 2,
                  fontwaight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ],
          ),
        );
      }),
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

/* Tab  */

  tabButton() {
    return Consumer<AllContentProvider>(
        builder: (context, allcontentprovider, child) {
      return SizedBox(
        height: 100,
        child: ListView.builder(
          itemCount: Constant.selectContentTabList.length,
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return InkWell(
              focusColor: appbgcolor,
              highlightColor: appbgcolor,
              hoverColor: appbgcolor,
              splashColor: appbgcolor,
              onHover: (value) async {
                await allcontentprovider.isTabHover(index, value);
              },
              onTap: () async {
                await allcontentprovider.chageTab(index);
                await allcontentprovider.clearTab();
                if (index == 0) {
                  allContentProvider.selectContentItemIndex.clear();
                  _fetchData("1", 0);
                } else if (index == 1) {
                  _fetchData("2", 0);
                } else if (index == 2) {
                  _fetchData("4", 0);
                } else if (index == 3) {
                  allContentProvider.selectContentItemIndex.clear();
                  _fetchData("7", 0);
                } else {
                  if (!context.mounted) return;
                  Utils()
                      .showSnackBar(context, "Something Went Wronge !!!", true);
                }
              },
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: 250,
                padding: const EdgeInsets.fromLTRB(25, 0, 15, 0),
                margin: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: allcontentprovider.tabindex == index
                      ? colorPrimary
                      : colorPrimaryDark,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: AnimatedScale(
                  scale: allcontentprovider.isHover == true &&
                          allcontentprovider.hoverPosition == index
                      ? 1.2
                      : 1,
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
                          color: allcontentprovider.tabindex == index
                              ? colorAccent
                              : white,
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
              ),
            );
          },
        ),
      );
    });
  }

/* Tab Item According Perticular Type */
  Widget buildPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 25, 0, 25),
      child: Consumer<AllContentProvider>(
          builder: (context, allcontentprovider, child) {
        if (allcontentprovider.loading && !allcontentprovider.loadMore) {
          return buildShimmer();
        } else {
          return Column(
            children: [
              buildLayout(),
              if (allcontentprovider.loadMore)
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
      }),
    );
  }

  buildLayout() {
    return Consumer<AllContentProvider>(
        builder: (context, allcontentprovider, child) {
      if (allcontentprovider.tabindex == 0 ||
          allcontentprovider.tabindex == 3) {
        return buildVideo();
      } else if (allcontentprovider.tabindex == 1) {
        return buildMusic();
      } else if (allcontentprovider.tabindex == 2) {
        return buildPodcast();
      }
      /*else if (allcontentprovider.tabindex == 3) {
        return buildRadio();
      }*/
      else {
        return const SizedBox.shrink();
      }
    });
  }

  buildShimmer() {
    return Consumer<AllContentProvider>(
        builder: (context, allcontentprovider, child) {
      if (allcontentprovider.tabindex == 0 ||
          allcontentprovider.tabindex == 3) {
        return buildVideoShimmer();
      } else if (allcontentprovider.tabindex == 1) {
        return buildMusicShimmer();
      } else if (allcontentprovider.tabindex == 2) {
        return buildPodcastShimmer();
      }
      /*else if (allcontentprovider.tabindex == 3) {
        return buildRadioShimmer();
      }*/
      else {
        return const SizedBox.shrink();
      }
    });
  }

/* Select Video Item */
  Widget buildVideo() {
    if (allContentProvider.getContentByPlaylistModel.status == 200 &&
        allContentProvider.contantList != null) {
      if ((allContentProvider.contantList?.length ?? 0) > 0) {
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
            allContentProvider.contantList?.length ?? 0,
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
        if (allContentProvider.selectContentItemIndex.contains(index)) {
          allContentProvider.removeItemContent(
              index,
              allContentProvider.contantList?[index].id.toString() ?? "",
              false);
        } else {
          allContentProvider.addItemContent(index,
              allContentProvider.contantList?[index].id.toString() ?? "", true);
        }
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 180,
                foregroundDecoration:
                    (allContentProvider.selectContentItemIndex.contains(index))
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
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fill,
                      height: MediaQuery.of(context).size.height,
                      imagePath: allContentProvider
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
                        color: pureWhite,
                        text: Utils.formatTime(double.parse(allContentProvider
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
                right: 15,
                top: 15,
                left: 15,
                child: Align(
                  alignment: Alignment.topRight,
                  child: (allContentProvider.selectContentItemIndex
                          .contains(index))
                      ? MyImage(width: 20, height: 20, imagePath: "true.png")
                      : const SizedBox.shrink(),
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
                    width: 32,
                    height: 32,
                    imagePath: allContentProvider
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
                          text: allContentProvider.contantList?[index].title
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
                      allContentProvider.contantList?[index].channelName
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
                                    text: allContentProvider
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
                              text: Utils.kmbGenerator(allContentProvider
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
                                  allContentProvider
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
    if (allContentProvider.getContentByPlaylistModel.status == 200 &&
        allContentProvider.contantList != null) {
      if ((allContentProvider.contantList?.length ?? 0) > 0) {
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
            allContentProvider.contantList?.length ?? 0,
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
        if (allContentProvider.selectContentItemIndex.contains(index)) {
          allContentProvider.removeItemContent(
              index,
              allContentProvider.contantList?[index].id.toString() ?? "",
              false);
        } else {
          allContentProvider.addItemContent(index,
              allContentProvider.contantList?[index].id.toString() ?? "", true);
        }
      },
      child: Container(
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
                  foregroundDecoration: (allContentProvider
                          .selectContentItemIndex
                          .contains(index))
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
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        imagePath: allContentProvider
                                .contantList?[index].portraitImg
                                .toString() ??
                            ""),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                      alignment: Alignment.center,
                      child: (allContentProvider.selectContentItemIndex
                              .contains(index))
                          ? MyImage(
                              width: 20, height: 20, imagePath: "true.png")
                          : const SizedBox.square()),
                )
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
                      text: allContentProvider.contantList?[index].title
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
                          allContentProvider.contantList?[index].createdAt ??
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

/* Select Podcast Item */
  Widget buildPodcast() {
    if (allContentProvider.getContentByPlaylistModel.status == 200 &&
        allContentProvider.contantList != null) {
      if ((allContentProvider.contantList?.length ?? 0) > 0) {
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
            allContentProvider.contantList?.length ?? 0,
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
        if (allContentProvider.selectContentItemIndex.contains(index)) {
          allContentProvider.removeItemContent(
              index,
              allContentProvider.contantList?[index].id.toString() ?? "",
              false);
        } else {
          allContentProvider.addItemContent(index,
              allContentProvider.contantList?[index].id.toString() ?? "", true);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 180,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MyNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                    imagePath: allContentProvider
                            .contantList?[index].portraitImg
                            .toString() ??
                        "",
                  ),
                ),
                Positioned.fill(
                  top: 15,
                  left: 15,
                  right: 15,
                  child: Align(
                      alignment: Alignment.topRight,
                      child: (allContentProvider.selectContentItemIndex
                              .contains(index))
                          ? MyImage(
                              width: 20, height: 20, imagePath: "true.png")
                          : const SizedBox.shrink()),
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          MyText(
              color: white,
              text:
                  allContentProvider.contantList?[index].title.toString() ?? "",
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
      ),
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

/* Select Podcast Item */
  Widget buildRadio() {
    if (allContentProvider.getContentByPlaylistModel.status == 200 &&
        allContentProvider.contantList != null) {
      if ((allContentProvider.contantList?.length ?? 0) > 0) {
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
            allContentProvider.contantList?.length ?? 0,
            (index) {
              return buildRadioItem(index: index);
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

  Widget buildRadioItem({required int index}) {
    return InkWell(
      onTap: () {
        if (allContentProvider.selectContentItemIndex.contains(index)) {
          allContentProvider.removeItemContent(
              index,
              allContentProvider.contantList?[index].id.toString() ?? "",
              false);
        } else {
          allContentProvider.addItemContent(index,
              allContentProvider.contantList?[index].id.toString() ?? "", true);
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 130,
                  height: 130,
                  foregroundDecoration: (allContentProvider
                          .selectContentItemIndex
                          .contains(index))
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
                    borderRadius: BorderRadius.circular(100),
                    child: MyNetworkImage(
                      fit: BoxFit.cover,
                      imagePath: allContentProvider
                              .contantList?[index].portraitImg
                              .toString() ??
                          "",
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                      alignment: Alignment.center,
                      child: (allContentProvider.selectContentItemIndex
                              .contains(index))
                          ? MyImage(
                              width: 20, height: 20, imagePath: "true.png")
                          : const SizedBox.square()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 100,
              child: MyText(
                  color: white,
                  text:
                      allContentProvider.contantList?[index].title.toString() ??
                          "",
                  textalign: TextAlign.center,
                  fontsizeNormal: Dimens.textSmall,
                  fontsizeWeb: Dimens.textSmall,
                  inter: false,
                  multilanguage: false,
                  maxline: 1,
                  fontwaight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ),
          ],
        ),
      ),
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

  String flotingButtonTitle({required tabindex}) {
    if (tabindex == 0) {
      return "Add Video";
    } else if (tabindex == 1) {
      return "Add Music";
    } else if (tabindex == 2) {
      return "Add Podcast";
    } else if (tabindex == 3) {
      return "Add Live";
    } else {
      return "Add";
    }
  }

  addMultipleItemToPlaylist(
      {required contentType, required allContentId}) async {
    await allContentProvider.addMultipleContentToPlaylist(
        widget.playlistId, contentType, allContentId);

    if (!allContentProvider.loading) {
      if (allContentProvider.addMultipleContentModel.status == 200) {
        if (!mounted) return;
        Utils().showSnackBar(context, "contentaddsuccsessfully", true);

        allContentProvider.clearAllSelectedContent();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const WebMyPlayList(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        if (!mounted) return;
        Utils().showSnackBar(context,
            "${allContentProvider.addMultipleContentModel.message}", true);
      }
    }
  }
}
