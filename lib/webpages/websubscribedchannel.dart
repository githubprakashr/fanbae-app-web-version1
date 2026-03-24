import 'package:fanbae/music/musicdetails.dart';
import 'package:fanbae/provider/subscribedchannelprovider.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/webcontentdetail.dart';
import 'package:fanbae/webpages/webdetail.dart';
import 'package:fanbae/webpages/webprofile.dart';
import 'package:fanbae/webpages/webshorts.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/provider/profileprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../model/getcontentbychannelmodel.dart';

class WebSubscribedChannel extends StatefulWidget {
  const WebSubscribedChannel({super.key});

  @override
  State<WebSubscribedChannel> createState() => WebSubscribedChannelState();
}

class WebSubscribedChannelState extends State<WebSubscribedChannel> {
  ImagePicker picker = ImagePicker();
  XFile? frontimage;
  late ScrollController _scrollController;
  late SubscribedChannelProvider subscribedChannelProvider;

  @override
  void initState() {
    subscribedChannelProvider =
        Provider.of<SubscribedChannelProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    _fetchSubscriberData(0);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (subscribedChannelProvider.currentPage ?? 0) <
            (subscribedChannelProvider.totalPage ?? 0)) {
      subscribedChannelProvider.setLoadMore(true);
      if (subscribedChannelProvider.position == 0) {
        getTabData(subscribedChannelProvider.currentPage ?? 0, "1");
      } else if (subscribedChannelProvider.position == 1) {
        getTabData(subscribedChannelProvider.currentPage ?? 0, "4");
      } else if (subscribedChannelProvider.position == 2) {
        getTabData(subscribedChannelProvider.currentPage ?? 0, "5");
      } else if (subscribedChannelProvider.position == 3) {
        getTabData(subscribedChannelProvider.currentPage ?? 0, "3");
      } else {
        printLog("Something Went Wronge!!!");
      }
    }
  }

  getTabData(pageNo, contenttype) {
    _fetchData(
      pageNo,
      contenttype,
      subscribedChannelProvider.channelUserId,
      subscribedChannelProvider.channelId,
    );
  }

  Future<void> _fetchSubscriberData(int? nextPage) async {
    printLog("isMorePage  ======> ${subscribedChannelProvider.isMorePage}");
    printLog("currentPage ======> ${subscribedChannelProvider.currentPage}");
    printLog("totalPage   ======> ${subscribedChannelProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await subscribedChannelProvider.getSubscriberList((nextPage ?? 0) + 1);
    if (subscribedChannelProvider.subscriberlistModel.status == 200) {
      await subscribedChannelProvider.selectChannel(
          subscribedChannelProvider.subscriberList?[0].id.toString() ?? "",
          subscribedChannelProvider.subscriberList?[0].channelId.toString() ??
              "",
          0);

      subscribedChannelProvider.clearListData();

      if (subscribedChannelProvider.position == 0) {
        getTabData(0, "1");
        subscribedChannelProvider.clearListData();
        /* Podcast */
      } else if (subscribedChannelProvider.position == 1) {
        getTabData(0, "4");
        subscribedChannelProvider.clearListData();
        /* Playlist */
      } else if (subscribedChannelProvider.position == 2) {
        getTabData(0, "5");
        subscribedChannelProvider.clearListData();
        /* Short */
      } else if (subscribedChannelProvider.position == 3) {
        getTabData(0, "3");
        subscribedChannelProvider.clearListData();
        /* Other Page  */
      } else {
        subscribedChannelProvider.clearListData();
      }
    }
  }

  Future<void> _fetchData(int? nextPage, contenttype, userid, channelid) async {
    printLog("isMorePage  ======> ${subscribedChannelProvider.isMorePage}");
    printLog("currentPage ======> ${subscribedChannelProvider.currentPage}");
    printLog("totalPage   ======> ${subscribedChannelProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await subscribedChannelProvider.getcontentbyChannel(
        userid, channelid, contenttype, (nextPage ?? 0) + 1);
  }

  Future<void> _fetchRentData(channelUserId, int? nextPage) async {
    printLog("isMorePage  ======> ${subscribedChannelProvider.rentisMorePage}");
    printLog(
        "currentPage ======> ${subscribedChannelProvider.rentcurrentPage}");
    printLog("totalPage   ======> ${subscribedChannelProvider.renttotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await subscribedChannelProvider.getUserbyRentContent(
        channelUserId, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    super.dispose();
    subscribedChannelProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: Utils.webAppbarWithSidePanel(
        context: context,
        contentType: Constant.videoSearch,
      ),
      body: Utils.sidePanelWithBody(
        myWidget: Consumer<SubscribedChannelProvider>(
          builder: (context, channelProvider, child) {
            if (channelProvider.subscriberLoading &&
                !channelProvider.subscriberloadMore) {
              return Utils.pageLoader(context);
            }

            final list = channelProvider.subscriberList ?? [];

            if (channelProvider.subscriberlistModel.status == 200 &&
                list.isNotEmpty) {
              return Utils().pageBg(
                context,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      buildSubscription(list),
                      viewChannelButton(),
                      buildTab(),
                      buildTabItem(),
                    ],
                  ),
                ),
              );
            } else {
              return const NoData();
            }
          },
        ),
      ),
    );
  }

  Widget buildSubscription(List<dynamic> list) {
    return Consumer<SubscribedChannelProvider>(
        builder: (context, channelprovider, child) {
      if (channelprovider.subscriberLoading &&
          !channelprovider.subscriberloadMore) {
        return Utils.pageLoader(context);
      } else {
        if (channelprovider.subscriberlistModel.status != 200 ||
            (list.isEmpty)) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 150,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                buildSubscriptionList(list),
                if (channelprovider.subscriberloadMore)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: colorPrimary,
                      strokeWidth: 1,
                    ),
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

  Widget buildSubscriptionList(List<dynamic> list) {
    if (list.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = list[index];
        return InkWell(
          autofocus: false,
          highlightColor: transparent,
          focusColor: transparent,
          hoverColor: transparent,
          onTap: () async {
            await subscribedChannelProvider.selectChannel(
              item.id?.toString() ?? "",
              item.channelId?.toString() ?? "",
              index, // use index here
            );

            subscribedChannelProvider.clearListData();

            if (subscribedChannelProvider.position == 0) {
              getTabData(0, "1");
            } else if (subscribedChannelProvider.position == 1) {
              getTabData(0, "4");
            } else if (subscribedChannelProvider.position == 2) {
              getTabData(0, "5");
            } else if (subscribedChannelProvider.position == 3) {
              getTabData(0, "3");
            } else if (subscribedChannelProvider.position == 4) {
              _fetchRentData(subscribedChannelProvider.channelUserId, 0);
            }
          },
          child: Container(
            color: subscribedChannelProvider.channelPosition == index
                ? colorPrimaryDark
                : transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(width: 1, color: colorPrimary)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: MyNetworkImage(
                        width: 75,
                        height: 75,
                        imagePath: item.image ?? "",
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 10),
                MyText(
                  color: white,
                  text: item.fullName ?? "",
                  fontwaight: FontWeight.w500,
                  fontsizeNormal: Dimens.textMedium,
                  maxline: 1,
                  multilanguage: false,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget viewChannelButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 15, 5),
      child: InkWell(
        onTap: () async {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => WebProfile(
                isProfile: false,
                channelUserid: subscribedChannelProvider.channelUserId,
                channelid: subscribedChannelProvider.channelId,
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: colorPrimary,
            ),
            child: MyText(
                color: colorAccent,
                text: "viewprofile",
                textalign: TextAlign.center,
                fontsizeNormal: Dimens.textSmall,
                inter: false,
                multilanguage: true,
                maxline: 1,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
          ),
        ),
      ),
    );
  }

  Widget buildTab() {
    return Consumer<SubscribedChannelProvider>(
        builder: (context, profileprovider, child) {
      return SizedBox(
        height: 65,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: Constant.subscriberTabList.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      autofocus: false,
                      focusColor: black,
                      highlightColor: black,
                      hoverColor: black,
                      splashColor: black,
                      onTap: () async {
                        profileprovider.changeTab(index);
                        /* Video */
                        if (profileprovider.position == 0) {
                          getTabData(0, "1");
                          profileprovider.clearListData();
                          /* Podcast */
                        } else if (profileprovider.position == 1) {
                          getTabData(0, "4");
                          profileprovider.clearListData();
                          /* Playlist */
                        } else if (profileprovider.position == 2) {
                          getTabData(0, "5");
                          profileprovider.clearListData();
                          /* Short */
                        } else if (profileprovider.position == 3) {
                          getTabData(0, "3");
                          profileprovider.clearListData();
                          /* Other Page  */
                        } else {
                          profileprovider.clearListData();
                        }
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                                color: profileprovider.position == index
                                    ? colorPrimary
                                    : white,
                                text: Constant.subscriberTabList[index],
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textTitle,
                                inter: false,
                                multilanguage: true,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            const SizedBox(height: 20),
                            Container(
                              color: profileprovider.position == index
                                  ? colorPrimary
                                  : black,
                              height: 2,
                              width: 100,
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            Container(
              color: colorPrimaryDark,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              height: 2,
              width: MediaQuery.of(context).size.width,
            )
          ],
        ),
      );
    });
  }

  Widget buildTabItem() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.position == 0) {
        return buildVideo();
      } else if (profileprovider.position == 1) {
        return buildPadcast();
      } else if (profileprovider.position == 2) {
        return buildPlaylist();
      } else if (profileprovider.position == 3) {
        return buildReels();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget buildVideo() {
    return Consumer<SubscribedChannelProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return videoShimmer();
      } else {
        return Column(
          children: [
            video(),
            const SizedBox(height: 20),
            if (subscribedChannelProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget video() {
    if (subscribedChannelProvider.getContentbyChannelModel.status == 200 &&
        subscribedChannelProvider.channelContentList != null) {
      if ((subscribedChannelProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: Utils.crossAxisCount(context),
              maxItemsPerRow: Utils.crossAxisCount(context),
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  subscribedChannelProvider.channelContentList?.length ?? 0,
                  (index) {
                return InkWell(
                  hoverColor: transparent,
                  highlightColor: transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            WebDetail(
                                stoptime: 0,
                                iscontinueWatching: false,
                                videoid:
                                    subscribedChannelProvider
                                            .channelContentList?[index].id
                                            .toString() ??
                                        "",
                                feedType: subscribedChannelProvider
                                        .channelContentList?[index].contentType
                                        .toString() ??
                                    ""),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
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
                                imagePath: subscribedChannelProvider
                                        .channelContentList?[index].landscapeImg
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
                                        subscribedChannelProvider
                                                .channelContentList?[index]
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
                                imagePath: subscribedChannelProvider
                                        .channelContentList?[index].channelImage
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
                                      text: subscribedChannelProvider
                                              .channelContentList?[index].title
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
                                  subscribedChannelProvider
                                              .channelContentList?[index]
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
                                                text: subscribedChannelProvider
                                                        .channelContentList?[
                                                            index]
                                                        .channelName
                                                        .toString() ??
                                                    "",
                                                textalign: TextAlign.left,
                                                fontsizeNormal:
                                                    Dimens.textMedium,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MyText(
                                          color: gray,
                                          text: Utils.kmbGenerator(
                                              subscribedChannelProvider
                                                      .channelContentList?[0]
                                                      .totalView ??
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
                                                subscribedChannelProvider
                                                        .channelContentList?[
                                                            index]
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
      } else {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

  Widget videoShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.crossAxisCount(context),
          maxItemsPerRow: Utils.crossAxisCount(context),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(10, (index) {
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
          }),
        ),
      ),
    );
  }

  Widget buildPadcast() {
    return Consumer<SubscribedChannelProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return padcastShimmer();
      } else {
        return Column(
          children: [
            padcast(),
            const SizedBox(height: 20),
            if (subscribedChannelProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget padcast() {
    if (subscribedChannelProvider.getContentbyChannelModel.status == 200 &&
        subscribedChannelProvider.channelContentList != null) {
      if ((subscribedChannelProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: Utils.crossAxisCount(context),
              maxItemsPerRow: Utils.crossAxisCount(context),
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  subscribedChannelProvider.channelContentList?.length ?? 0,
                  (index) {
                return InkWell(
                  hoverColor: transparent,
                  highlightColor: transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            WebContentDetail(
                          contentDiscription: subscribedChannelProvider
                                  .channelContentList?[index].description
                                  .toString() ??
                              "",
                          contentType: subscribedChannelProvider
                                  .channelContentList?[index].contentType
                                  .toString() ??
                              "",
                          contentImage: subscribedChannelProvider
                                  .channelContentList?[index].portraitImg
                                  .toString() ??
                              "",
                          contentName: subscribedChannelProvider
                                  .channelContentList?[index].title
                                  .toString() ??
                              "",
                          /* Temporary Null ContentUserid */
                          contentUserid: "",
                          contentId: subscribedChannelProvider
                                  .channelContentList?[index].id
                                  .toString() ??
                              "",
                          playlistImage: subscribedChannelProvider
                              .channelContentList?[index].playlistImage,
                          isBuy: subscribedChannelProvider
                                  .channelContentList?[index].isBuy
                                  .toString() ??
                              "",
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Column(
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
                                imagePath: subscribedChannelProvider
                                        .channelContentList?[index].portraitImg
                                        .toString() ??
                                    "",
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: MyImage(
                                  width: 30,
                                  height: 30,
                                  imagePath: "pause.png"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      MyText(
                          color: white,
                          text: subscribedChannelProvider
                                  .channelContentList?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.center,
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
  }

  Widget padcastShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.crossAxisCount(context),
          maxItemsPerRow: Utils.crossAxisCount(context),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(8, (index) {
            return const Column(
              children: [
                CustomWidget.roundrectborder(
                  height: 180,
                ),
                SizedBox(height: 10),
                CustomWidget.roundrectborder(
                  height: 6,
                ),
                CustomWidget.roundrectborder(
                  height: 6,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget buildPlaylist() {
    return Consumer<SubscribedChannelProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return playlistShimmer();
      } else {
        return Column(
          children: [
            playlist(),
            const SizedBox(height: 20),
            if (subscribedChannelProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget playlist() {
    if (subscribedChannelProvider.getContentbyChannelModel.status == 200 &&
        subscribedChannelProvider.channelContentList != null) {
      if ((subscribedChannelProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: Utils.customCrossAxisCount(
                  context: context,
                  height1600: 6,
                  height1200: 5,
                  height800: 3,
                  height600: 2),
              maxItemsPerRow: Utils.customCrossAxisCount(
                  context: context,
                  height1600: 6,
                  height1200: 5,
                  height800: 3,
                  height600: 2),
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  subscribedChannelProvider.channelContentList?.length ?? 0,
                  (index) {
                return InkWell(
                  hoverColor: transparent,
                  highlightColor: transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            WebContentDetail(
                          contentDiscription: subscribedChannelProvider
                                  .channelContentList?[index].description
                                  .toString() ??
                              "",
                          contentType: subscribedChannelProvider
                                  .channelContentList?[index].contentType
                                  .toString() ??
                              "",
                          contentImage: subscribedChannelProvider
                                  .channelContentList?[index].portraitImg
                                  .toString() ??
                              "",
                          contentName: subscribedChannelProvider
                                  .channelContentList?[index].title
                                  .toString() ??
                              "",
                          /* Temporary Null ContentUserid */
                          contentUserid: "",
                          contentId: subscribedChannelProvider
                                  .channelContentList?[index].id
                                  .toString() ??
                              "",
                          playlistImage: subscribedChannelProvider
                              .channelContentList?[index].playlistImage,
                          isBuy: subscribedChannelProvider
                                  .channelContentList?[index].isBuy
                                  .toString() ??
                              "",
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 180,
                          child: Stack(
                            children: [
                              playlistImages(
                                  index,
                                  subscribedChannelProvider
                                          .channelContentList ??
                                      []),
                              Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "pause.png"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 150,
                          child: MyText(
                              color: white,
                              text: subscribedChannelProvider
                                      .channelContentList?[index].title
                                      .toString() ??
                                  "",
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
                                      subscribedChannelProvider
                                              .channelContentList?[index]
                                              .totalView
                                              .toString() ??
                                          "")),
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
  }

  Widget playlistShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 6,
              height1200: 5,
              height800: 3,
              height600: 1),
          maxItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 6,
              height1200: 5,
              height800: 3,
              height600: 1),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(6, (index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.rectangular(
                      height: 180, width: MediaQuery.of(context).size.width),
                  const SizedBox(height: 10),
                  CustomWidget.rectangular(
                      height: 5, width: MediaQuery.of(context).size.width),
                  const SizedBox(height: 5),
                  CustomWidget.rectangular(
                      height: 5, width: MediaQuery.of(context).size.width),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildReels() {
    return Consumer<SubscribedChannelProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return reelsShimmer();
      } else {
        return Column(
          children: [
            reels(),
            const SizedBox(height: 20),
            if (subscribedChannelProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget reels() {
    if (subscribedChannelProvider.getContentbyChannelModel.status == 200 &&
        subscribedChannelProvider.channelContentList != null) {
      if ((subscribedChannelProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
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
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  subscribedChannelProvider.channelContentList?.length ?? 0,
                  (index) {
                return InkWell(
                  hoverColor: transparent,
                  highlightColor: transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            WebShorts(
                          initialIndex: index,
                          shortType: "profile",
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 350,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MyNetworkImage(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                                imagePath: subscribedChannelProvider
                                        .channelContentList?[index].portraitImg
                                        .toString() ??
                                    "",
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: MyImage(
                                  width: 30,
                                  height: 30,
                                  imagePath: "pause.png"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      MyText(
                          color: white,
                          text: subscribedChannelProvider
                                  .channelContentList?[index].title
                                  .toString() ??
                              "",
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
              }),
            ),
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

  Widget reelsShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.crossAxisCountShorts(context),
          maxItemsPerRow: Utils.crossAxisCountShorts(context),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(8, (index) {
            return const Column(
              children: [
                CustomWidget.roundrectborder(
                  height: 350,
                ),
                SizedBox(height: 10),
                CustomWidget.roundrectborder(
                  height: 6,
                ),
                CustomWidget.roundrectborder(
                  height: 6,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget buildRentVideo() {
    return Consumer<SubscribedChannelProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return rentVideoShimmer();
      } else {
        return Column(
          children: [
            rentVideo(),
            const SizedBox(height: 20),
            if (subscribedChannelProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget rentVideo() {
    if (subscribedChannelProvider.getUserRentContentModel.status == 200 &&
        subscribedChannelProvider.rentContentList != null) {
      if ((subscribedChannelProvider.rentContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                  subscribedChannelProvider.rentContentList?.length ?? 0,
                  (index) {
                return InkWell(
                  hoverColor: transparent,
                  highlightColor: transparent,
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    audioPlayer.pause();
                    Utils.openPlayer(
                      isDownloadVideo: false,
                      iscontinueWatching: false,
                      stoptime: 0.0,
                      context: context,
                      videoId: subscribedChannelProvider
                              .rentContentList?[index].id
                              .toString() ??
                          "",
                      videoUrl: subscribedChannelProvider
                              .rentContentList?[index].content
                              .toString() ??
                          "",
                      vUploadType: subscribedChannelProvider
                              .rentContentList?[index].contentUploadType
                              .toString() ??
                          "",
                      videoThumb: subscribedChannelProvider
                              .rentContentList?[index].landscapeImg
                              .toString() ??
                          "",
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 135,
                          height: 155,
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: MyNetworkImage(
                                  imagePath: subscribedChannelProvider
                                          .rentContentList?[index].portraitImg
                                          .toString() ??
                                      "",
                                  fit: BoxFit.cover,
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: MyText(
                                      color: white,
                                      text:
                                          "${Constant.currencySymbol} ${subscribedChannelProvider.rentContentList?[index].rentPrice.toString() ?? ""}",
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
                              Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "pause.png"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 130,
                          child: MyText(
                              color: white,
                              text: subscribedChannelProvider
                                      .rentContentList?[index].title
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
              }),
            ),
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

  Widget rentVideoShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 3,
          maxItemsPerRow: 3,
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
                      width: 135,
                      height: 150,
                    ),
                    SizedBox(height: 10),
                    CustomWidget.roundrectborder(
                      width: 130,
                      height: 5,
                    ),
                    SizedBox(height: 7),
                    CustomWidget.roundrectborder(
                      width: 130,
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

  Widget playlistImages(index, List<Result>? sectionList) {
    if ((sectionList?[index].playlistImage?.length ?? 0) == 4) {
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
                        imagePath:
                            sectionList?[index].playlistImage?[0].toString() ??
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
                        imagePath:
                            sectionList?[index].playlistImage?[1].toString() ??
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
                        imagePath:
                            sectionList?[index].playlistImage?[2].toString() ??
                                "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath:
                            sectionList?[index].playlistImage?[3].toString() ??
                                "",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((sectionList?[index].playlistImage?.length ?? 0) == 3) {
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
                        imagePath:
                            sectionList?[index].playlistImage?[0].toString() ??
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
                        imagePath:
                            sectionList?[index].playlistImage?[1].toString() ??
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
                  imagePath:
                      sectionList?[index].playlistImage?[2].toString() ?? "",
                ),
              ),
            ],
          ));
    } else if ((sectionList?[index].playlistImage?.length ?? 0) == 2) {
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
                        imagePath:
                            sectionList?[index].playlistImage?[0].toString() ??
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
                        imagePath:
                            sectionList?[index].playlistImage?[1].toString() ??
                                "",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((sectionList?[index].playlistImage?.length ?? 0) == 1) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: MyNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
            imagePath: sectionList?[index].playlistImage?[0].toString() ?? "",
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
}
