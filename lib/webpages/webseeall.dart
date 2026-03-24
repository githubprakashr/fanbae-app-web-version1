import 'package:fanbae/music/musicdetails.dart';
import 'package:fanbae/provider/musicdetailprovider.dart';
import 'package:fanbae/provider/seeallprovider.dart';
import 'package:fanbae/subscription/allpayment.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/musicmanager.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/webcontentdetail.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/webwidget/interactivecontainer.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../model/sectiondetailmodel.dart';

class WebSeeAll extends StatefulWidget {
  final String? title, contentType, sectionId;
  final bool isRent;
  const WebSeeAll({
    super.key,
    required this.title,
    required this.isRent,
    this.contentType,
    required this.sectionId,
  });

  @override
  State<WebSeeAll> createState() => WebSeeAllState();
}

class WebSeeAllState extends State<WebSeeAll> {
  final MusicManager musicManager = MusicManager();
  late SeeAllProvider seeAllProvider;
  late ScrollController _scrollController;
  final playlistTitleController = TextEditingController();

  @override
  void initState() {
    seeAllProvider = Provider.of<SeeAllProvider>(context, listen: false);
    if (widget.isRent == false) {
      _sectionDetailMusic(0);
    } else {
      _rentDetailVideo(0);
    }
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      await seeAllProvider.setSeeAllLoadMore(true);
      if (widget.isRent == false) {
        if ((seeAllProvider.sectiondatacurrentPage ?? 0) <
            (seeAllProvider.sectiondatatotalPage ?? 0)) {
          printLog("load more Music====>");
          _sectionDetailMusic(seeAllProvider.sectiondatacurrentPage ?? 0);
        }
      } else {
        if ((seeAllProvider.rentcurrentPage ?? 0) <
            (seeAllProvider.renttotalPage ?? 0)) {
          printLog("load more Rent Video====>");
          _rentDetailVideo(seeAllProvider.sectiondatacurrentPage ?? 0);
        }
      }
    }
  }

  Future<void> _sectionDetailMusic(int? nextPage) async {
    printLog("isMorePage  ======> ${seeAllProvider.sectiondataisMorePage}");
    printLog("currentPage ======> ${seeAllProvider.sectiondatacurrentPage}");
    printLog("totalPage   ======> ${seeAllProvider.sectiondatatotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await seeAllProvider.getSeactionDetail(
        widget.sectionId, (nextPage ?? 0) + 1);
    await seeAllProvider.setSeeAllLoadMore(false);
  }

  Future<void> _rentDetailVideo(int? nextPage) async {
    printLog("isMorePage  ======> ${seeAllProvider.rentisMorePage}");
    printLog("currentPage ======> ${seeAllProvider.rentcurrentPage}");
    printLog("totalPage   ======> ${seeAllProvider.renttotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await seeAllProvider.getRentSeactionDetail(
        widget.sectionId, (nextPage ?? 0) + 1);
    await seeAllProvider.setSeeAllLoadMore(false);
  }

  @override
  void dispose() {
    seeAllProvider.clearProvider();
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
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: widget.isRent == false ? buildItem() : buildRent(),
        ),
      ),
    );
  }

  Widget buildItem() {
    printLog("contenttype===>${widget.contentType}");
    return Consumer<SeeAllProvider>(
        builder: (context, sectiondataprovider, child) {
      if (sectiondataprovider.loading && !sectiondataprovider.seeallLoadMore) {
        return buildShimmer();
      } else {
        if (sectiondataprovider.sectionListModel.status == 200 &&
            sectiondataprovider.sectionDataList != null) {
          if ((sectiondataprovider.sectionDataList?.length ?? 0) > 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MusicTitle(
                    color: white,
                    text: widget.title ?? "",
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textExtraBig,
                    fontsizeWeb: Dimens.textExtraBig,
                    multilanguage: false,
                    maxline: 1,
                    fontwaight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.topLeft,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: ResponsiveGridList(
                        minItemWidth: 120,
                        minItemsPerRow: setListCount(),
                        maxItemsPerRow: setListCount(),
                        horizontalGridSpacing: 10,
                        verticalGridSpacing: 25,
                        listViewBuilderOptions: ListViewBuilderOptions(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                        ),
                        children: List.generate(
                            sectiondataprovider.sectionDataList?.length ?? 0,
                            (index) {
                          return setLayout(
                              index, sectiondataprovider.sectionDataList);
                        }),
                      ),
                    ),
                  ),
                ),
                if (seeAllProvider.seeallLoadMore)
                  Container(
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                    child: Utils.pageLoader(context),
                  )
                else
                  const SizedBox.shrink(),
              ],
            );
          } else {
            return const NoData(title: "", subTitle: "");
          }
        } else {
          return const NoData(title: "", subTitle: "");
        }
      }
    });
  }

/* ContentType = 1 = Music */
/* ContentType = 2 = Podcast */
/* ContentType = 3 = Radio */
/* ContentType = 4 = Playlist */

  Widget setLayout(index, sectionDataList) {
    if (widget.contentType == "1") {
      return buildMusic(index, sectionDataList);
    } else if (widget.contentType == "2") {
      return buildPodcast(index, sectionDataList);
    } else if (widget.contentType == "3") {
      return buildRadio(index, sectionDataList);
    } else if (widget.contentType == "4") {
      return buildPlaylist(index, sectionDataList);
    } else {
      /* Rent Video SeeAll  */
      return const SizedBox.shrink();
    }
  }

  int setListCount() {
    if (widget.contentType == "1") {
      return Utils.customCrossAxisCount(
          context: context,
          height1600: 3,
          height1200: 3,
          height800: 2,
          height600: 1);
    } else if (widget.contentType == "2") {
      return Utils.customCrossAxisCount(
          context: context,
          height1600: 5,
          height1200: 4,
          height800: 3,
          height600: 1);
    } else if (widget.contentType == "3") {
      return Utils.customCrossAxisCount(
          context: context,
          height1600: 8,
          height1200: 6,
          height800: 4,
          height600: 2);
    } else if (widget.contentType == "4") {
      return Utils.customCrossAxisCount(
          context: context,
          height1600: 7,
          height1200: 6,
          height800: 3,
          height600: 1);
    } else {
      return 0;
    }
  }

/* Music Layout */
  Widget buildMusic(int index, List<Result>? sectionDataList) {
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
            playingType: sectionDataList?[index].contentType.toString() ?? "",
            episodeid: sectionDataList?[index].id.toString() ?? "",
            contentid: sectionDataList?[index].id.toString() ?? "",
            contentDiscription:
                sectionDataList?[index].description.toString() ?? "",
            position: index,
            sectionBannerList: sectionDataList ?? [],
            contentName: sectionDataList?[index].title.toString() ?? "",
            isBuy: sectionDataList?[index].isBuy.toString() ?? "",
          );
        }
      },
      child: InteractiveContainer(child: (isHovered) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.70,
          height: 55,
          child: Row(
            children: [
              Stack(
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
                      borderRadius: BorderRadius.circular(5),
                      child: MyNetworkImage(
                          fit: BoxFit.cover,
                          imagePath:
                              sectionDataList?[index].portraitImg.toString() ??
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
                        text: sectionDataList?[index].title.toString() ?? "",
                        fontsizeNormal: Dimens.textSmall,
                        fontsizeWeb: Dimens.textSmall,
                        fontwaight: FontWeight.w400,
                        multilanguage: false,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.left,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                                color: gray,
                                text: Utils.kmbGenerator(
                                    sectionDataList?[index].totalView ?? 0),
                                fontsizeNormal: Dimens.textSmall,
                                fontsizeWeb: Dimens.textSmall,
                                fontwaight: FontWeight.w400,
                                multilanguage: false,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                inter: false,
                                textalign: TextAlign.left,
                                fontstyle: FontStyle.normal),
                            const SizedBox(width: 5),
                            MyText(
                                color: gray,
                                text: "views",
                                fontsizeNormal: Dimens.textSmall,
                                fontsizeWeb: Dimens.textSmall,
                                fontwaight: FontWeight.w400,
                                multilanguage: true,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                inter: false,
                                textalign: TextAlign.left,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: MyText(
                              color: gray,
                              text: Utils.timeAgoCustom(
                                DateTime.parse(
                                  sectionDataList?[index].createdAt ?? "",
                                ),
                              ),
                              fontsizeNormal: Dimens.textSmall,
                              fontsizeWeb: Dimens.textSmall,
                              fontwaight: FontWeight.w400,
                              multilanguage: false,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              inter: false,
                              textalign: TextAlign.left,
                              fontstyle: FontStyle.normal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

/* Radio Layout */
  Widget buildRadio(int index, List<Result>? sectionDataList) {
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
          playAudio(
            playingType: sectionDataList?[index].contentType.toString() ?? "",
            podcastimage: sectionDataList?[index].portraitImg.toString() ?? "",
            episodeid: sectionDataList?[index].id.toString() ?? "",
            contentid: sectionDataList?[index].id.toString() ?? "",
            contentDiscription:
                sectionDataList?[index].description.toString() ?? "",
            position: index,
            contentUserid: sectionDataList?[index].userId.toString() ?? "",
            sectionBannerList: sectionDataList ?? [],
            contentName: sectionDataList?[index].title.toString() ?? "",
            playlistImages: [],
            isBuy: sectionDataList?[index].isBuy.toString() ?? "",
          );
        }
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
                width: 130,
                height: 130,
                fit: BoxFit.cover,
                imagePath: sectionDataList?[index].portraitImg.toString() ?? "",
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 100,
              child: MyText(
                  color: white,
                  text: sectionDataList?[index].title.toString() ?? "",
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

/* Podcast Layout */
  Widget buildPodcast(int index, List<Result>? sectionDataList) {
    return InkWell(
      onTap: () {
        playAudio(
          playingType: sectionDataList?[index].contentType.toString() ?? "",
          podcastimage: sectionDataList?[index].portraitImg.toString() ?? "",
          episodeid: sectionDataList?[index].id.toString() ?? "",
          contentid: sectionDataList?[index].id.toString() ?? "",
          contentDiscription:
              sectionDataList?[index].description.toString() ?? "",
          position: index,
          contentUserid: sectionDataList?[index].userId.toString() ?? "",
          sectionBannerList: sectionDataList ?? [],
          contentName: sectionDataList?[index].title.toString() ?? "",
          playlistImages: [],
          isBuy: sectionDataList?[index].isBuy.toString() ?? "",
        );
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
                width: MediaQuery.of(context).size.width,
                height: 170,
                fit: BoxFit.cover,
                imagePath: sectionDataList?[index].portraitImg ?? "",
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: MyText(
                  color: white,
                  text: sectionDataList?[index].title ?? "",
                  textalign: TextAlign.left,
                  fontsizeNormal: Dimens.textSmall,
                  fontsizeWeb: Dimens.textSmall,
                  inter: false,
                  multilanguage: false,
                  maxline: 2,
                  fontwaight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ),
          ],
        ),
      ),
    );
  }

/* Playlist Layout */
  Widget buildPlaylist(int index, List<Result>? sectionDataList) {
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
          playAudio(
            playingType: sectionDataList?[index].contentType.toString() ?? "",
            podcastimage: sectionDataList?[index].portraitImg.toString() ?? "",
            episodeid: sectionDataList?[index].id.toString() ?? "",
            contentid: sectionDataList?[index].id.toString() ?? "",
            contentDiscription:
                sectionDataList?[index].description.toString() ?? "",
            position: index,
            contentUserid: sectionDataList?[index].userId.toString() ?? "",
            sectionBannerList: sectionDataList ?? [],
            contentName: sectionDataList?[index].title.toString() ?? "",
            playlistImages: sectionDataList?[index].playlistImage ?? [],
            isBuy: sectionDataList?[index].isBuy.toString() ?? "",
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 180,
              height: 170,
              child: playlistImages(index, sectionDataList),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 150,
              child: MyText(
                  color: white,
                  text: sectionDataList?[index].title.toString() ?? "",
                  textalign: TextAlign.left,
                  fontsizeNormal: Dimens.textMedium,
                  fontsizeWeb: Dimens.textMedium,
                  inter: false,
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
                  MyText(
                      color: gray,
                      text: Utils.kmbGenerator(int.parse(
                          sectionDataList?[index].totalView.toString() ?? "")),
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textMedium,
                      fontsizeWeb: Dimens.textMedium,
                      inter: false,
                      multilanguage: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
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
  }

  Widget playlistImages(index, List<Result>? sectionDataList) {
    if ((sectionDataList?[index].playlistImage?.length ?? 0) == 4) {
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
                        imagePath: sectionDataList?[index]
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
                        imagePath: sectionDataList?[index]
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
                        imagePath: sectionDataList?[index]
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
                        imagePath: sectionDataList?[index]
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
    } else if ((sectionDataList?[index].playlistImage?.length ?? 0) == 3) {
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
                        imagePath: sectionDataList?[index]
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
                        imagePath: sectionDataList?[index]
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
                  imagePath:
                      sectionDataList?[index].playlistImage?[2].toString() ??
                          "",
                ),
              ),
            ],
          ));
    } else if ((sectionDataList?[index].playlistImage?.length ?? 0) == 2) {
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
                        imagePath: sectionDataList?[index]
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
                        imagePath: sectionDataList?[index]
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
    } else if ((sectionDataList?[index].playlistImage?.length ?? 0) == 1) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: MyNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
            imagePath:
                sectionDataList?[index].playlistImage?[0].toString() ?? "",
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

/* Rent Video Layout */

  Widget buildRent() {
    return Consumer<SeeAllProvider>(
        builder: (context, sectiondataprovider, child) {
      if (sectiondataprovider.loading && !sectiondataprovider.seeallLoadMore) {
        return buildRentItemShimmer();
      } else {
        if (sectiondataprovider.rentSectionDetailModel.status == 200 &&
            sectiondataprovider.rentVideoList != null) {
          if ((sectiondataprovider.rentVideoList?.length ?? 0) > 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MusicTitle(
                    color: white,
                    text: widget.title ?? "",
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textExtraBig,
                    fontsizeWeb: Dimens.textExtraBig,
                    multilanguage: false,
                    maxline: 1,
                    fontwaight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
                const SizedBox(height: 30),
                buildRentItem(),
                if (sectiondataprovider.seeallLoadMore)
                  Container(
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                    child: Utils.pageLoader(context),
                  )
                else
                  const SizedBox.shrink(),
              ],
            );
          } else {
            return const NoData(title: "", subTitle: "");
          }
        } else {
          return const NoData(title: "", subTitle: "");
        }
      }
    });
  }

  Widget buildRentItem() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 7,
              height1200: 6,
              height800: 5,
              height600: 3),
          maxItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 7,
              height1200: 6,
              height800: 5,
              height600: 3),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
          children: List.generate(
            seeAllProvider.rentVideoList?.length ?? 0,
            (index) {
              return InkWell(
                borderRadius: BorderRadius.circular(4),
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
                  } else if (seeAllProvider.rentVideoList?[index].isRentBuy ==
                      0) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            AllPayment(
                          currency: Constant.currencySymbol,
                          itemId: seeAllProvider.rentVideoList?[index].id
                                  .toString() ??
                              "",
                          itemTitle: seeAllProvider.rentVideoList?[index].title
                                  .toString() ??
                              "",
                          payType: "Rent",
                          price: seeAllProvider.rentVideoList?[index].rentPrice
                                  .toString() ??
                              "",
                          productPackage: "",
                          typeId: "",
                          videoType: "",
                          coin: "",
                          rentSectionIndex: 0,
                          rentVideoIndex: index,
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );

                    /* Payment Option Page Ridirect */
                  } else {
                    audioPlayer.pause();
                    Utils.openPlayer(
                      isDownloadVideo: false,
                      iscontinueWatching: false,
                      stoptime: 0.0,
                      context: context,
                      videoId:
                          seeAllProvider.rentVideoList?[index].id.toString() ??
                              "",
                      videoUrl: seeAllProvider.rentVideoList?[index].content
                              .toString() ??
                          "",
                      vUploadType: seeAllProvider
                              .rentVideoList?[index].contentUploadType
                              .toString() ??
                          "",
                      videoThumb: seeAllProvider
                              .rentVideoList?[index].landscapeImg
                              .toString() ??
                          "",
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 120,
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: MyNetworkImage(
                                imagePath: seeAllProvider
                                        .rentVideoList?[index].portraitImg
                                        .toString() ??
                                    "",
                                fit: BoxFit.cover,
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            top: 10,
                            left: 15,
                            right: 15,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorPrimary,
                                ),
                                child: MyImage(
                                  width: 18,
                                  height: 18,
                                  imagePath: "ic_king.png",
                                  color: black,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 4, 10, 4),
                                decoration: BoxDecoration(
                                  color: colorPrimary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: MyText(
                                    color: colorAccent,
                                    text:
                                        "${Constant.currencySymbol} ${seeAllProvider.rentVideoList?[index].rentPrice.toString() ?? ""}",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textMedium,
                                    fontsizeWeb: Dimens.textMedium,
                                    multilanguage: false,
                                    inter: false,
                                    maxline: 2,
                                    fontwaight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 160,
                        child: MyText(
                            color: white,
                            text: seeAllProvider.rentVideoList?[index].title
                                    .toString() ??
                                "",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            fontsizeWeb: Dimens.textMedium,
                            multilanguage: false,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildRentItemShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 7,
              height1200: 6,
              height800: 5,
              height600: 3),
          maxItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 7,
              height1200: 6,
              height800: 5,
              height600: 3),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
          children: List.generate(
            10,
            (index) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(
                      height: 120,
                    ),
                    CustomWidget.roundrectborder(
                      width: 200,
                      height: 5,
                    ),
                    CustomWidget.roundrectborder(
                      width: 200,
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

/* All Shimmer */
  Widget buildShimmer() {
    return Column(
      children: [
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: setListCount(),
              maxItemsPerRow: setListCount(),
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(30, (index) {
                return setShimmer();
              }),
            ),
          ),
        ),
        if (seeAllProvider.seeallLoadMore)
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

  setShimmer() {
    if (widget.contentType == "1") {
      return buildMusicShimmer();
    } else if (widget.contentType == "2") {
      return buildPodcastShimmer();
    } else if (widget.contentType == "3") {
      return buildRadioShimmer();
    } else if (widget.contentType == "4") {
      return buildPlaylistShimmer();
    } else {
      return Utils.pageLoader(context);
    }
  }

  Widget buildMusicShimmer() {
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
                  width: 200,
                  height: 8,
                ),
                SizedBox(height: 8),
                CustomWidget.roundrectborder(
                  width: 200,
                  height: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRadioShimmer() {
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
          SizedBox(height: 10),
          CustomWidget.roundrectborder(
            width: 80,
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget buildPodcastShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CustomWidget.roundrectborder(
              width: MediaQuery.of(context).size.width,
              height: 170,
            ),
          ),
          const SizedBox(height: 10),
          const CustomWidget.roundrectborder(
            width: 200,
            height: 8,
          ),
          const CustomWidget.roundrectborder(
            width: 200,
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget buildPlaylistShimmer() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomWidget.rectangular(height: 170, width: 180),
          SizedBox(height: 10),
          CustomWidget.roundrectborder(height: 8, width: 140),
          CustomWidget.roundrectborder(height: 8, width: 140),
        ],
      ),
    );
  }

/* Open Pages */
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
    /* Play Music */
    if (widget.contentType == "1") {
      musicManager.setInitialMusic(position, playingType, sectionBannerList,
          contentid, addView(playingType, contentid), false, 0, isBuy ?? "");
    } else if (widget.contentType == "2") {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => WebContentDetail(
            contentType: playingType,
            contentUserid: contentUserid ?? "",
            contentImage: podcastimage ?? "",
            contentName: contentName,
            contentDiscription: contentDiscription ?? "",
            playlistImage: playlistImages ?? [],
            contentId: contentid,
            isBuy: isBuy ?? "",
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (widget.contentType == "3") {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => WebContentDetail(
            contentType: playingType,
            contentUserid: contentUserid ?? "",
            contentImage: podcastimage ?? "",
            contentDiscription: contentDiscription ?? "",
            contentName: contentName,
            playlistImage: playlistImages ?? [],
            contentId: contentid,
            isBuy: isBuy ?? "",
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (widget.contentType == "4") {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => WebContentDetail(
            contentType: playingType,
            contentUserid: contentUserid ?? "",
            contentImage: podcastimage ?? "",
            contentName: contentName,
            contentDiscription: contentDiscription ?? "",
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
