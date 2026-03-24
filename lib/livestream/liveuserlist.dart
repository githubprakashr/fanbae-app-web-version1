import 'package:flutter/foundation.dart';
import 'package:fanbae/livestream/golivepreview.dart';
import 'package:fanbae/livestream/liveuserlistprovider.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/widget/customappbar.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class LiveUserList extends StatefulWidget {
  const LiveUserList({super.key});

  @override
  State<LiveUserList> createState() => LiveUserListState();
}

class LiveUserListState extends State<LiveUserList> {
  late LiveUserListProvider liveUserListProvider;
  late ScrollController _scrollController;
  io.Socket? socket;
  final TextEditingController coinController = TextEditingController();
  String _selectedFeed = 'follow';
  bool _showTopWidgets = true;
  double _lastScrollPosition = 0;
  SuccessModel successModel = SuccessModel();

  @override
  void initState() {
    liveUserListProvider =
        Provider.of<LiveUserListProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListenerCategory);
    super.initState();
    _fetchLiveUser(0);
  }

  _scrollListenerCategory() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (liveUserListProvider.currentPage ?? 0) <
            (liveUserListProvider.totalPage ?? 0)) {
      await liveUserListProvider.setLoadMore(true);
      _fetchLiveUser(liveUserListProvider.currentPage ?? 0);
    }
    final currentScroll = _scrollController.offset;
    if (currentScroll > _lastScrollPosition) {
      if (_showTopWidgets && currentScroll > 20) {
        setState(() => _showTopWidgets = false);
      }
    } else if (currentScroll < _lastScrollPosition) {
      if (!_showTopWidgets) {
        setState(() => _showTopWidgets = true);
      }
    }

    _lastScrollPosition = currentScroll;
  }

  Future<void> _fetchLiveUser(int? nextPage) async {
    await liveUserListProvider.getLiveUserList(
        (nextPage ?? 0) + 1, _selectedFeed);
    await liveUserListProvider.setLoadMore(false);
  }

  @override
  void dispose() {
    liveUserListProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      //  appBar: _showTopWidgets ? const CustomAppBar(contentType: "1") : null,
      floatingActionButton: Constant.isCreator == '1'
          ? GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const GoLiveViewPreview();
                    },
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.25,
                height: MediaQuery.of(context).size.width * 0.1,
                decoration: BoxDecoration(
                    gradient: Constant.gradientColor,
                    borderRadius: BorderRadius.circular(100)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add,
                      color: pureBlack,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    MyText(
                      text: "Go Live",
                      color: pureBlack,
                      fontwaight: FontWeight.w700,
                    )
                  ],
                ),
              ),
            )
          : null,
      body: Utils().pageBg(
        context,
        child: RefreshIndicator(
          backgroundColor: colorPrimaryDark,
          color: colorAccent,
          displacement: 70,
          edgeOffset: 1.0,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          strokeWidth: 3,
          onRefresh: () async {
            liveUserListProvider.clearProvider();
            _fetchLiveUser(0);
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                child: buildLiveUserList(),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  // Combine slide + fade
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0, -0.2), // slightly above
                    end: Offset.zero,
                  ).animate(animation);

                  return SlideTransition(
                    position: slideAnimation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _showTopWidgets
                    ? Column(
                        children: [
                          kIsWeb
                              ? const SizedBox()
                              : const CustomAppBar(contentType: "1"),
                          Container(
                            key: const ValueKey('topWidget'),
                            decoration: BoxDecoration(
                              color: appBarColor,
                            ),
                            padding: const EdgeInsets.only(
                                bottom: 15.0, left: 9, right: 9, top: 15),
                            child: liveUserListProvider.isShowSearch
                                ? Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      gradient: _selectedFeed == 'search'
                                          ? Constant.gradientColor
                                          : null,
                                      border: Border.all(
                                        color: _selectedFeed == 'search'
                                            ? transparent
                                            : textColor,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: TextFormField(
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: white,
                                              fontWeight: FontWeight.w700),
                                      controller:
                                          liveUserListProvider.searchController,
                                      decoration: InputDecoration(
                                          hintText: "Search",
                                          hintStyle: TextStyle(color: white),
                                          /*  fillColor: white.withOpacity(0.42),
                                          filled: true,*/
                                          contentPadding: const EdgeInsets.only(
                                              top: 15, left: 10),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .transparent)),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          Colors.transparent)),
                                          suffixIcon: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (liveUserListProvider
                                                    .searchController
                                                    .text
                                                    .isNotEmpty) {
                                                  liveUserListProvider
                                                      .searchController
                                                      .clear();
                                                  _fetchLiveUser(0);
                                                }
                                                liveUserListProvider
                                                        .isShowSearch =
                                                    !liveUserListProvider
                                                        .isShowSearch;
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(7.0),
                                              child: CircleAvatar(
                                                radius: 7,
                                                backgroundColor: white,
                                                child: Icon(
                                                  Icons.close,
                                                  color: black,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          )),
                                      onChanged: (value) {
                                        setState(() {
                                          _fetchLiveUser(0);
                                        });
                                      },
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedFeed = "follow";
                                              _fetchLiveUser(0);
                                            });
                                          },
                                          child: Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                                gradient:
                                                    _selectedFeed != "following"
                                                        ? Constant.gradientColor
                                                        : null,
                                                border: Border.all(
                                                    color: _selectedFeed ==
                                                            "following"
                                                        ? textColor
                                                        : transparent),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                    Icons
                                                        .person_add_alt_1_sharp,
                                                    color: _selectedFeed ==
                                                            "following"
                                                        ? white
                                                        : pureBlack,
                                                    size: 17),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                MyText(
                                                  text: "foryou",
                                                  color: _selectedFeed ==
                                                          "following"
                                                      ? white
                                                      : pureBlack,
                                                  fontwaight: FontWeight.w600,
                                                  fontsizeNormal: 12,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedFeed = "following";
                                              _fetchLiveUser(0);
                                            });
                                          },
                                          child: Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                                gradient:
                                                    _selectedFeed == "following"
                                                        ? Constant.gradientColor
                                                        : null,
                                                border: Border.all(
                                                    color: _selectedFeed !=
                                                            "following"
                                                        ? textColor
                                                        : transparent),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.person,
                                                    color: _selectedFeed ==
                                                            "follow"
                                                        ? white
                                                        : pureBlack,
                                                    size: 17),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                MyText(
                                                  text: "following",
                                                  color:
                                                      _selectedFeed == "follow"
                                                          ? white
                                                          : pureBlack,
                                                  fontwaight: FontWeight.w600,
                                                  fontsizeNormal: 12,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              liveUserListProvider
                                                      .isShowSearch =
                                                  !liveUserListProvider
                                                      .isShowSearch;
                                            });
                                          },
                                          child: Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: textColor),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.search,
                                                    color: white, size: 17),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                MyText(
                                                    text: "search",
                                                    color: white,
                                                    fontwaight: FontWeight.w600,
                                                    fontsizeNormal: 12)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      )
                    : const SizedBox(
                        key: ValueKey(
                            'emptyWidget'), // keeps AnimatedSwitcher working
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLiveUserList() {
    return Consumer<LiveUserListProvider>(
        builder: (context, liveuserlistprovider, child) {
      if (liveuserlistprovider.loading && !liveuserlistprovider.loadMore) {
        return shimmer();
      } else {
        if (liveuserlistprovider.liveUserListModel.status == 200 &&
            liveuserlistprovider.liveUserList != null) {
          if ((liveuserlistprovider.liveUserList?.length ?? 0) > 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 150,
                ),
                buildLiveUserListItem(),
                if (liveuserlistprovider.loadMore)
                  SizedBox(
                    height: 50,
                    child: Utils.pageLoader(context),
                  )
                else
                  const SizedBox.shrink(),
              ],
            );
          } else {
            return Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                NoData(),
              ],
            );
            ;
          }
        } else {
          return Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              const NoData(),
            ],
          );
        }
      }
    });
  }

  Future<void> _navigateToLive(index) async {
    await Utils.jumpToLive(
      context: context,
      isHost: false,
      userId: Constant.userID,
      videoUrl: Constant.fakeVideoUrl,
      isFake:
          liveUserListProvider.liveUserList?[index].isFake?.toString() ?? "",
      roomId:
          liveUserListProvider.liveUserList?[index].roomId?.toString() ?? "",
      userImage:
          liveUserListProvider.liveUserList?[index].image?.toString() ?? "",
      name: liveUserListProvider.liveUserList?[index].channelName?.toString() ??
          "",
      userName:
          liveUserListProvider.liveUserList?[index].channelName?.toString() ??
              "",
    );
  }

  Widget buildLiveUserListItem() {
    return GridView.builder(
      itemCount: liveUserListProvider.liveUserList?.length ?? 0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 230,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          focusColor: transparent,
          hoverColor: transparent,
          highlightColor: transparent,
          splashColor: transparent,
          onTap: () async {
            if (liveUserListProvider.liveUserList?[index].isViewable == 1) {
              await _navigateToLive(index);
              setState(() {
                _fetchLiveUser(0);
              });
            } else {
              Utils().showSnackBar(context, "insufficient_balance", true);
            }
          },
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              // color: colorPrimaryDark,
              gradient: LinearGradient(colors: [
                colorPrimaryDark.withOpacity(0.80),
                colorPrimary.withOpacity(0.60)
              ]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: Stack(
                    children: [
                      Container(
                          height: 180,
                          width: MediaQuery.of(context).size.width,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              MyNetworkImage(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  imagePath: liveUserListProvider
                                          .liveUserList?[index].image
                                          .toString() ??
                                      "",
                                  fit: BoxFit.cover),
                            ],
                          )),
                      Positioned(
                        top: 12,
                        left: 10,
                        child: Container(
                          width: 75,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                colorPrimaryDark.withOpacity(0.80),
                                colorPrimary.withOpacity(0.60)
                              ]),
                              borderRadius: BorderRadius.circular(50)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.visibility,
                                color: white,
                                size: 20,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: MyText(
                                    color: white,
                                    multilanguage: false,
                                    text: Utils.kmbGenerator(
                                        liveUserListProvider
                                                .liveUserList?[index]
                                                .totalView ??
                                            0),
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textExtraSmall,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w700,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 10,
                        child: Container(
                          height: 20,
                          width: 50,
                          decoration: BoxDecoration(
                            // color: white.withOpacity(0.3),
                            gradient: LinearGradient(colors: [
                              colorPrimaryDark.withOpacity(0.80),
                              colorPrimary.withOpacity(0.60)
                            ]),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: white, width: 0.3),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                left: -5,
                                child: Lottie.asset(
                                    "assets/effects/lottie_wave_animation.json",
                                    fit: BoxFit.cover,
                                    height: 20,
                                    width: 15),
                              ),
                              Positioned(
                                right: 5,
                                child: MyText(
                                    color: white,
                                    multilanguage: true,
                                    text: "live",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textExtraSmall,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 10,
                        child: Container(
                          height: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorPrimaryDark,
                                colorPrimaryDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: white, width: 0.3),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MyImage(
                                width: 14,
                                height: 14,
                                imagePath: "coin.png",
                                color: Constant.darkMode == "true"
                                    ? colorPrimary
                                    : pureBlack,
                              ),
                              MyText(
                                color: white,
                                multilanguage: false,
                                text:
                                    '${liveUserListProvider.liveUserList?[index].liveAmount?.toString() ?? ""}/min',
                                textalign: TextAlign.right,
                                fontsizeNormal: Dimens.textExtraSmall,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// 👤 Profile Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyNetworkImage(
                            width: 28,
                            height: 28,
                            imagePath: liveUserListProvider
                                    .liveUserList?[index].image
                                    ?.toString() ??
                                "",
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 6),

                        /// 🧩 Name + Coin container + Channel Name
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  /// 👤 Full name (ellipsized)
                                  Expanded(
                                    child: MyText(
                                      color: white,
                                      multilanguage: false,
                                      text: liveUserListProvider
                                              .liveUserList?[index].fullName
                                              ?.toString() ??
                                          "",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textSmall,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  /// 💰 Small gradient coin badge
                                ],
                              ),

                              /// 📺 Channel name below
                              const SizedBox(height: 2),
                              MyText(
                                color: white,
                                multilanguage: false,
                                text: liveUserListProvider
                                        .liveUserList?[index].channelName
                                        ?.toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textExtraSmall,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 6),

                        /// 💰 Right-side live amount (if > 0)
/*                        if ((liveUserListProvider.liveUserList?[index].liveAmount ?? 0) > 0)
                          Row(
                            children: [
                              MyImage(width: 17, height: 17, imagePath: "ic_coin.png"),
                              const SizedBox(width: 3),
                              MyText(
                                color: white,
                                multilanguage: false,
                                text: liveUserListProvider.liveUserList?[index].liveAmount?.toString() ?? "",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textSmall,
                                inter: true,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          )*/
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget shimmer() {
    return GridView.builder(
      itemCount: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 230,
      ),
      itemBuilder: (context, index) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorPrimaryDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              CustomWidget.roundrectborder(
                width: MediaQuery.of(context).size.width,
                height: 180,
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomWidget.circular(
                        width: 28,
                        height: 28,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomWidget.rectangular(
                              height: 5,
                              width: 200,
                            ),
                            CustomWidget.rectangular(
                              width: 150,
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
