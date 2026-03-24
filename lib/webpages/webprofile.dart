import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fanbae/music/musicdetails.dart';
import 'package:fanbae/pages/updateprofile.dart';
import 'package:fanbae/provider/updateprofileprovider.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/webdetail.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/webpages/webshorts.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/provider/profileprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../model/getcontentbychannelmodel.dart';
import 'package:fanbae/model/profilemodel.dart' as profile;

import '../model/successmodel.dart';
import '../pages/chatpage.dart';
import '../pages/contentdetail.dart';
import '../pages/createmusic.dart';
import '../pages/createpodcast.dart';
import '../pages/createvideo.dart';
import '../pages/login.dart';
import '../pages/profile.dart';
import '../pages/requestcreator.dart';
import '../pages/showpostcontent.dart';
import '../pages/uploadfeed.dart';
import '../pages/viewmembershipplan.dart';
import '../pages/viewratings.dart';
import '../players/video_player_screen.dart';
import '../provider/contentdetailprovider.dart';
import '../provider/feedprovider.dart';
import '../provider/musicdetailprovider.dart';
import '../utils/musicmanager.dart';
import '../video_audio_call/ScheduleCall.dart';
import '../webservice/apiservice.dart';

class WebProfile extends StatefulWidget {
  final bool isProfile;
  final String channelUserid;
  final String channelid;

  const WebProfile(
      {super.key,
      required this.isProfile,
      required this.channelUserid,
      required this.channelid});

  @override
  State<WebProfile> createState() => WebProfileState();
}

class WebProfileState extends State<WebProfile> {
  ImagePicker picker = ImagePicker();
  XFile? frontimage;
  late ScrollController _scrollController;
  late ProfileProvider profileProvider;
  final MusicManager musicManager = MusicManager();
  final playlistTitleController = TextEditingController();

  /* Update Profile Web */
  String mobilenumber = "", countrycode = "", countryname = "";

  // ignore: deprecated_member_use
  final nameController = TextEditingController();
  final channelNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  final liveAmtController = TextEditingController();
  late ContentDetailProvider contentDetailProvider;

  double _rating = 1.0;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    log("channelUserid===>${widget.channelUserid}");
    log("loginUserid===>${Constant.userID}");
    contentDetailProvider =
        Provider.of<ContentDetailProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    getApi();
    if (widget.isProfile == true) {
      _fetchData(0, "1", Constant.userID, Constant.channelID);
    } else {
      _fetchData(0, "1", widget.channelUserid, widget.channelid);
    }
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  getApi() async {
    await profileProvider.getprofile(context,
        widget.isProfile == true ? Constant.userID : widget.channelUserid);
  }

  Future<void> _fetchChannelFeedData(int? nextPage) async {
    printLog("nextpage   ======> $nextPage");
    await profileProvider.getChannelFeed(
        /*widget.isProfile == true ?*/
        Constant.userID /*: widget.channelUserid*/,
        widget.isProfile == true ? Constant.channelID : widget.channelid,
        (nextPage ?? 0) + 1);

    await profileProvider.setLoadMore(false);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (profileProvider.currentPage ?? 0) < (profileProvider.totalPage ?? 0)) {
      printLog("load more====>");
      profileProvider.setLoadMore(true);
      if (profileProvider.position == 0) {
        getTabData(profileProvider.currentPage ?? 0, "1");
      } else if (profileProvider.position == 1) {
        getTabData(profileProvider.currentPage ?? 0, "2");
      } else if (profileProvider.position == 2) {
        getTabData(profileProvider.currentPage ?? 0, "4");
      } else if (profileProvider.position == 3) {
        getTabData(profileProvider.currentPage ?? 0, "5");
      } else if (profileProvider.position == 4) {
        getTabData(profileProvider.currentPage ?? 0, "3");
      } else if (profileProvider.position == 5) {
        _fetchChannelFeedData(profileProvider.channelcurrentPage ?? 0);
      } else if (profileProvider.position == 6) {
        getTabData(profileProvider.currentPage ?? 0, "7");
        //_fetchRentData(profileProvider.rentcurrentPage ?? 0);
      } else {
        printLog("Something Went Wrong!!!");
      }
    }
  }

  getTabData(pageNo, contenttype) {
    if (widget.isProfile == true) {
      _fetchData(pageNo, contenttype, Constant.userID, Constant.channelID);
    } else {
      _fetchData(pageNo, contenttype, widget.channelUserid, widget.channelid);
    }
  }

  Future<void> _fetchData(int? nextPage, contenttype, userid, channelid) async {
    printLog("isMorePage  ======> ${profileProvider.isMorePage}");
    printLog("currentPage ======> ${profileProvider.currentPage}");
    printLog("totalPage   ======> ${profileProvider.totalPage}");
    printLog("userId   ======> $userid");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await profileProvider.getcontentbyChannel(
        userid, channelid, contenttype, (nextPage ?? 0) + 1);
  }

  Future<void> _fetchRentData(int? nextPage) async {
    printLog("isMorePage  ======> ${profileProvider.rentisMorePage}");
    printLog("currentPage ======> ${profileProvider.rentcurrentPage}");
    printLog("totalPage   ======> ${profileProvider.renttotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await profileProvider.getUserbyRentContent(
        widget.isProfile == true ? Constant.userID : widget.channelUserid,
        (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    super.dispose();
    profileProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: Utils.webAppbarWithSidePanel(
          context: context, contentType: Constant.videoSearch),
      body: RefreshIndicator(
        backgroundColor: colorPrimaryDark,
        color: colorAccent,
        displacement: 70,
        edgeOffset: 1.0,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        strokeWidth: 3,
        onRefresh: () async {
          if (profileProvider.position == 0) {
            profileProvider.clearListData();
            await getTabData(0, "1");
          } else if (profileProvider.position == 1) {
            profileProvider.clearListData();
            await getTabData(0, "2");
          } else if (profileProvider.position == 2) {
            profileProvider.clearListData();
            await getTabData(0, "4");
          } else if (profileProvider.position == 3) {
            profileProvider.clearListData();
            await getTabData(0, "5");
          } else if (profileProvider.position == 4) {
            profileProvider.clearListData();
            await getTabData(0, "3");
          } else if (profileProvider.position == 5) {
            await _fetchChannelFeedData(0);
          } else if (profileProvider.position == 6) {
            profileProvider.clearListData();
            await getTabData(0, "7");
          } else {
            profileProvider.clearListData();
          }
          return;
        },
        child: Utils.sidePanelWithBody(
          isProfile: true,
          myWidget: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveHelper.checkIsWeb(context)
                    ? buildInfo()
                    : buildProfile(),
                const Divider(
                  height: 1,
                  color: gray,
                  thickness: 0.5,
                  endIndent: 20,
                ),
                buildTab(),
                buildTabItem(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfile() {
    return Consumer<ProfileProvider>(
        builder: (context, settingProvider, child) {
      if (settingProvider.profileloading) {
        return buildImageShimmer();
      } else {
        if (settingProvider.profileModel.status == 200 &&
            settingProvider.profileModel.result != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                const SizedBox(height: 5),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25),
                    Stack(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 110, // Outer size
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: Constant.sweepGradient,
                              ),
                            ),
                            Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: MyNetworkImage(
                                  width: 74,
                                  height: 74,
                                  fit: BoxFit.cover,
                                  imagePath: (settingProvider
                                                  .profileModel.status ==
                                              200 &&
                                          settingProvider.profileModel.result !=
                                              null)
                                      ? (settingProvider
                                              .profileModel.result?[0].image
                                              .toString() ??
                                          "")
                                      : ""),
                            ),
                          ],
                        ),
                        ((widget.isProfile == true) ||
                                (widget.channelUserid == Constant.userID))
                            ? Positioned.fill(
                                bottom: 3,
                                right: 3,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: InkWell(
                                    onTap: () {
                                      if (ResponsiveHelper.checkIsWeb(
                                              context) &&
                                          !ResponsiveHelper.isMobile(context)) {
                                        buildUpdateProfileDialog(settingProvider
                                            .profileModel.result);
                                      } else {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) => UpdateProfile(
                                                  channelid:
                                                      Constant.channelID ??
                                                          "")),
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 27,
                                      height: 27,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: Constant.gradientColor),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: pureBlack,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        settingProvider.profileModel.result?[0].fullName == ""
                            ? MyText(
                                color: white,
                                text: settingProvider
                                        .profileModel.result?[0].channelName
                                        .toString() ??
                                    "",
                                multilanguage: false,
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textBig,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal)
                            : MyText(
                                color: white,
                                text: settingProvider
                                        .profileModel.result?[0].fullName
                                        .toString() ??
                                    "",
                                multilanguage: false,
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textBig,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                        const SizedBox(height: 2.5),
                        settingProvider.profileModel.result?[0].channelName ==
                                ""
                            ? MyText(
                                color: white,
                                text: settingProvider
                                        .profileModel.result?[0].channelName
                                        .toString() ??
                                    "",
                                multilanguage: false,
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textSmall,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal)
                            : MyText(
                                color: white,
                                text: settingProvider
                                        .profileModel.result?[0].channelName
                                        .toString() ??
                                    "",
                                multilanguage: false,
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textSmall,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                MyText(
                                    color: white,
                                    text: "totalcontent",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
                                    inter: false,
                                    maxline: 1,
                                    multilanguage: true,
                                    fontwaight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                const SizedBox(width: 4),
                                MyText(
                                    color: white,
                                    text: Utils.kmbGenerator((settingProvider
                                                .profileModel
                                                .result?[0]
                                                .totalContent ??
                                            0)
                                        .round()),
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textMedium,
                                    inter: false,
                                    maxline: 1,
                                    multilanguage: false,
                                    fontwaight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                MyText(
                                    color: white,
                                    text: "followers",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                const SizedBox(width: 4),
                                MyText(
                                    color: white,
                                    text: Utils.kmbGenerator((settingProvider
                                                .profileModel
                                                .result?[0]
                                                .totalSubscriber ??
                                            0)
                                        .round()),
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textMedium,
                                    multilanguage: false,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                settingProvider.profileModel.result?[0]
                                            .avgRating ==
                                        0
                                    ? null
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ViewRatings(
                                              id: int.parse(
                                                  widget.channelUserid),
                                            );
                                          },
                                        ),
                                      );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                      color: white,
                                      text: "rating",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      multilanguage: true,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(width: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 17.5,
                                      ),
                                      const SizedBox(width: 2.5),
                                      MyText(
                                          color: white,
                                          text: Utils.kmbGenerator(
                                              (settingProvider
                                                          .profileModel
                                                          .result?[0]
                                                          .avgRating ??
                                                      0)
                                                  .round()),
                                          textalign: TextAlign.center,
                                          fontsizeNormal: Dimens.textMedium,
                                          multilanguage: false,
                                          inter: false,
                                          maxline: 1,
                                          fontwaight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    settingProvider.profileModel.result?[0].description == ""
                        ? MyText(
                            color: white,
                            text: settingProvider
                                    .profileModel.result?[0].description
                                    .toString() ??
                                "",
                            multilanguage: false,
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textSmall,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal)
                        : MyText(
                            color: white,
                            text: settingProvider
                                    .profileModel.result?[0].description
                                    .toString() ??
                                "",
                            multilanguage: false,
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textSmall,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                    const SizedBox(height: 30),
                    if (settingProvider.profileModel.result?[0].isCreator
                            .toString() ==
                        "1") ...[
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: white, width: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...[
                                {
                                  "icon": Icons.chat,
                                  "label": "chat",
                                  "amount": settingProvider
                                      .profileModel.result?[0].chatAmount,
                                  "suffix": "/chat",
                                },
                                {
                                  "icon": Icons.call,
                                  "label": "audiocall",
                                  "amount": settingProvider
                                      .profileModel.result?[0].audioCallAmount,
                                  "suffix": "/min",
                                },
                                {
                                  "icon": Icons.videocam,
                                  "label": "videocall",
                                  "amount": settingProvider
                                      .profileModel.result?[0].videoCallAmount,
                                  "suffix": "/min",
                                },
                              ].asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;

                                return Row(
                                  children: [
                                    GestureDetector(
                                      onTap: widget.isProfile == false &&
                                              widget.channelUserid !=
                                                  Constant.userID
                                          ? () {
                                              index == 0
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChatPage(
                                                          otherUserId: settingProvider
                                                                  .profileModel
                                                                  .result?[0]
                                                                  .id
                                                                  .toString() ??
                                                              '',
                                                          otherUserName:
                                                              settingProvider
                                                                      .profileModel
                                                                      .result?[
                                                                          0]
                                                                      .fullName
                                                                      .toString() ??
                                                                  '',
                                                          otherUserPic: settingProvider
                                                                  .profileModel
                                                                  .result?[0]
                                                                  .image
                                                                  .toString() ??
                                                              '',
                                                          creatorId: '',
                                                        ),
                                                      ),
                                                    )
                                                  : null;
                                            }
                                          : null,
                                      child: Column(
                                        children: [
                                          Icon(item["icon"] as IconData,
                                              color: white, size: 22),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 2.5, top: 0.5),
                                            child: MyText(
                                              text: item["label"] as String,
                                              color: white,
                                              fontsizeNormal: 13,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              MyImage(
                                                  width: 15,
                                                  height: 15,
                                                  imagePath: "ic_coin.png"),
                                              MyText(
                                                text:
                                                    " ${(item["amount"] ?? '').toString()}${item["suffix"]}",
                                                color: white,
                                                multilanguage: false,
                                                fontsizeNormal: 13,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (index < 2) // divider only between items
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 23),
                                        height: 45,
                                        width: 1.5,
                                        color: white,
                                      ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ((Constant.userID == null) ||
                                (widget.isProfile == true) ||
                                (widget.channelUserid == Constant.userID))
                            ? const SizedBox.shrink()
                            : InkWell(
                                focusColor: transparent,
                                splashColor: transparent,
                                highlightColor: transparent,
                                hoverColor: transparent,
                                onTap: () async {
                                  final feedProvider =
                                      Provider.of<FeedProvider>(context,
                                          listen: false);
                                  await profileProvider.addRemoveSubscriber(
                                      0,
                                      profileProvider.profileModel.result?[0].id
                                              .toString() ??
                                          "",
                                      "1");

                                  if (profileProvider
                                          .addremoveSubscribeModel.status ==
                                      200) {
                                    await feedProvider.getAllFeed(0);
                                  }
                                },
                                child: Container(
                                  width: 150,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: transparent,
                                    border: Border.all(
                                        width: 1.5, color: button1color),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MyText(
                                          color: button1color,
                                          multilanguage: true,
                                          text: settingProvider.profileModel
                                                      .result?[0].isSubscribe ==
                                                  0
                                              ? "subscribe"
                                              : "subscribed",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: Dimens.textSmall,
                                          inter: true,
                                          maxline: 1,
                                          fontwaight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                    ],
                                  ),
                                ),
                              ),
                        const SizedBox(width: 15),
                        settingProvider.profileModel.result?[0]
                                        .isCreatorRequest ==
                                    0 &&
                                Constant.userID ==
                                    settingProvider.profileModel.result?[0].id
                                        .toString()
                            ? InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return RequestCreator(
                                          email: settingProvider.profileModel
                                                  .result?[0].email ??
                                              '',
                                        );
                                      },
                                    ),
                                  );
                                  setState(() {
                                    getApi();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 11),
                                  decoration: BoxDecoration(
                                      gradient: Constant.gradientColor,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: MyText(
                                      text: "requestcreator",
                                      color: pureBlack,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      inter: true,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              )
                            : Container(),
                        settingProvider.profileModel.result?[0]
                                        .isCreatorRequest ==
                                    2 &&
                                settingProvider
                                        .profileModel.result?[0].isCreator ==
                                    0 &&
                                Constant.userID ==
                                    settingProvider.profileModel.result?[0].id
                                        .toString()
                            ? Tooltip(
                                message: "Admin approval pending.",
                                triggerMode: TooltipTriggerMode.tap,
                                preferBelow: false,
                                margin: const EdgeInsets.only(bottom: 5),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 11),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: textColor),
                                      borderRadius: BorderRadius.circular(50)),
                                  child: MyText(
                                      text: "requestpending",
                                      color: textColor,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      inter: true,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              )
                            : Container(),
                        settingProvider.profileModel.result?[0].isCreator ==
                                    1 &&
                                Constant.userID ==
                                    settingProvider.profileModel.result?[0].id
                                        .toString()
                            ? InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ViewMembershipPlan(
                                            isUser: true,
                                            creatorId: Constant.userID ?? '0');
                                      },
                                    ),
                                  );
                                  setState(() {
                                    getApi();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 11),
                                  decoration: BoxDecoration(
                                      gradient: Constant.gradientColor,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: MyText(
                                      text: 'viewplans',
                                      color: pureBlack,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      inter: true,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              )
                            : const SizedBox(),
                        Constant.userID !=
                                settingProvider.profileModel.result?[0].id
                                    .toString()
                            ? InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ViewMembershipPlan(
                                          isUser: false,
                                          creatorId: settingProvider
                                                  .profileModel.result?[0].id
                                                  .toString() ??
                                              '0',
                                        );
                                      },
                                    ),
                                  );
                                  setState(() {
                                    getApi();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 11),
                                  decoration: BoxDecoration(
                                      gradient: Constant.gradientColor,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: MyText(
                                      text: settingProvider.profileModel
                                                  .result?[0].purchasePackage ==
                                              1
                                          ? 'Subscribed'
                                          : 'Buy Subscription',
                                      color: pureBlack,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      inter: true,
                                      multilanguage: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              )
                            : const SizedBox()
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ],
            ),
          );
        } else {
          return profileNoData();
        }
      }
    });
  }

  reloadApi(contentType) {
    getApi();
    if (widget.isProfile == true) {
      _fetchData(0, contentType, Constant.userID, Constant.channelID);
    } else {
      _fetchData(0, contentType, widget.channelUserid, widget.channelid);
    }
  }

  buildInfo() {
    return Consumer<ProfileProvider>(
        builder: (context, settingProvider, child) {
      if (settingProvider.profileloading) {
        return buildImageShimmer();
      } else {
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 110, // Outer size
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: Constant.sweepGradient,
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: MyNetworkImage(
                                width: 74,
                                height: 74,
                                fit: BoxFit.cover,
                                imagePath: (settingProvider
                                                .profileModel.status ==
                                            200 &&
                                        settingProvider.profileModel.result !=
                                            null)
                                    ? (settingProvider
                                            .profileModel.result?[0].image
                                            .toString() ??
                                        "")
                                    : ""),
                          ),
                        ],
                      ),
                      ((widget.isProfile == true) ||
                              (widget.channelUserid == Constant.userID))
                          ? Positioned.fill(
                              bottom: 3,
                              right: 3,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: InkWell(
                                  onTap: () {
                                    if (ResponsiveHelper.checkIsWeb(context) &&
                                        !ResponsiveHelper.isMobile(context)) {
                                      buildUpdateProfileDialog(
                                          settingProvider.profileModel.result);
                                    } else {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => UpdateProfile(
                                                channelid:
                                                    Constant.channelID ?? "")),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 27,
                                    height: 27,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: Constant.gradientColor),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: pureBlack,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        settingProvider.profileModel.result?[0].fullName == ""
                            ? MyText(
                                color: white,
                                text: settingProvider
                                        .profileModel.result?[0].channelName
                                        .toString() ??
                                    "",
                                multilanguage: false,
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textBig,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal)
                            : MyText(
                                color: white,
                                text: settingProvider
                                        .profileModel.result?[0].fullName
                                        .toString() ??
                                    "",
                                multilanguage: false,
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textBig,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                        const SizedBox(height: 2.5),
                        settingProvider.profileModel.result?[0].channelName ==
                                ""
                            ? MyText(
                                color: white,
                                text: settingProvider
                                        .profileModel.result?[0].channelName
                                        .toString() ??
                                    "",
                                multilanguage: false,
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textSmall,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal)
                            : MyText(
                                color: white,
                                text: settingProvider
                                        .profileModel.result?[0].channelName
                                        .toString() ??
                                    "",
                                multilanguage: false,
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textSmall,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                    color: white,
                                    text: "totalcontent",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
                                    inter: false,
                                    maxline: 1,
                                    multilanguage: true,
                                    fontwaight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                const SizedBox(width: 4),
                                MyText(
                                    color: white,
                                    text: Utils.kmbGenerator((settingProvider
                                                .profileModel
                                                .result?[0]
                                                .totalContent ??
                                            0)
                                        .round()),
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textMedium,
                                    inter: false,
                                    maxline: 1,
                                    multilanguage: false,
                                    fontwaight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                    color: white,
                                    text: "followers",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                const SizedBox(width: 4),
                                MyText(
                                    color: white,
                                    text: Utils.kmbGenerator((settingProvider
                                                .profileModel
                                                .result?[0]
                                                .totalSubscriber ??
                                            0)
                                        .round()),
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textMedium,
                                    multilanguage: false,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                settingProvider.profileModel.result?[0]
                                            .avgRating ==
                                        0
                                    ? null
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ViewRatings(
                                              id: int.parse(
                                                  widget.channelUserid),
                                            );
                                          },
                                        ),
                                      );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                      color: white,
                                      text: "rating",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      multilanguage: true,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(width: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 17.5,
                                      ),
                                      const SizedBox(width: 2.5),
                                      MyText(
                                          color: white,
                                          text: Utils.kmbGenerator(
                                              (settingProvider
                                                          .profileModel
                                                          .result?[0]
                                                          .avgRating ??
                                                      0)
                                                  .round()),
                                          textalign: TextAlign.center,
                                          fontsizeNormal: Dimens.textMedium,
                                          multilanguage: false,
                                          inter: false,
                                          maxline: 1,
                                          fontwaight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (ResponsiveHelper.isDesktop(context))
                    if (settingProvider.profileModel.result?[0].isCreator
                            .toString() ==
                        "1") ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 50.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: white, width: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...[
                                  {
                                    "icon": Icons.chat,
                                    "label": "chat",
                                    "amount": settingProvider
                                        .profileModel.result?[0].chatAmount,
                                    "suffix": "/chat",
                                  },
                                  {
                                    "icon": Icons.call,
                                    "label": "audiocall",
                                    "amount": settingProvider.profileModel
                                        .result?[0].audioCallAmount,
                                    "suffix": "/min",
                                  },
                                  {
                                    "icon": Icons.videocam,
                                    "label": "videocall",
                                    "amount": settingProvider.profileModel
                                        .result?[0].videoCallAmount,
                                    "suffix": "/min",
                                  },
                                ].asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;

                                  return Row(
                                    children: [
                                      GestureDetector(
                                        onTap: widget.isProfile == false &&
                                                widget.channelUserid !=
                                                    Constant.userID
                                            ? () {
                                                index == 0
                                                    ? Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatPage(
                                                            otherUserId: settingProvider
                                                                    .profileModel
                                                                    .result?[0]
                                                                    .id
                                                                    .toString() ??
                                                                '',
                                                            otherUserName: settingProvider
                                                                    .profileModel
                                                                    .result?[0]
                                                                    .fullName
                                                                    .toString() ??
                                                                '',
                                                            otherUserPic: settingProvider
                                                                    .profileModel
                                                                    .result?[0]
                                                                    .image
                                                                    .toString() ??
                                                                '',
                                                            creatorId: '',
                                                          ),
                                                        ),
                                                      )
                                                    : Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ScheduleCall(
                                                                      isCreator:
                                                                          false,
                                                                      creatorId: settingProvider
                                                                              .profileModel
                                                                              .result?[0]
                                                                              .id
                                                                              .toString() ??
                                                                          '',
                                                                    )));
                                              }
                                            : null,
                                        child: Column(
                                          children: [
                                            Icon(item["icon"] as IconData,
                                                color: white, size: 22),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2.5, top: 0.5),
                                              child: MyText(
                                                text: item["label"] as String,
                                                color: white,
                                                fontsizeNormal: 13,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                MyImage(
                                                    width: 15,
                                                    height: 15,
                                                    imagePath: "ic_coin.png"),
                                                MyText(
                                                  text:
                                                      " ${(item["amount"] ?? '').toString()}${item["suffix"]}",
                                                  color: white,
                                                  multilanguage: false,
                                                  fontsizeNormal: 13,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (index <
                                          2) // divider only between items
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 23),
                                          height: 45,
                                          width: 1.5,
                                          color: white,
                                        ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                ],
              ),
              const SizedBox(height: 15),
              Row(children: [
                settingProvider.profileModel.result?[0].description == ""
                    ? MyText(
                        color: white,
                        text: settingProvider
                                .profileModel.result?[0].description
                                .toString() ??
                            "",
                        multilanguage: false,
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textSmall,
                        inter: false,
                        maxline: 2,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal)
                    : MyText(
                        color: white,
                        text: settingProvider
                                .profileModel.result?[0].description
                                .toString() ??
                            "",
                        multilanguage: false,
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textSmall,
                        inter: false,
                        maxline: 2,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                const Spacer(),
                if (ResponsiveHelper.isDesktop(context))
                  Padding(
                    padding: const EdgeInsets.only(right: 50.0),
                    child: Row(
                      children: [
                        ((Constant.userID == null) ||
                                (widget.isProfile == true) ||
                                (widget.channelUserid == Constant.userID))
                            ? const SizedBox.shrink()
                            : InkWell(
                                focusColor: transparent,
                                splashColor: transparent,
                                highlightColor: transparent,
                                hoverColor: transparent,
                                onTap: () async {
                                  final feedProvider =
                                      Provider.of<FeedProvider>(context,
                                          listen: false);
                                  await profileProvider.addRemoveSubscriber(
                                      0,
                                      profileProvider.profileModel.result?[0].id
                                              .toString() ??
                                          "",
                                      "1");

                                  if (profileProvider
                                          .addremoveSubscribeModel.status ==
                                      200) {
                                    await feedProvider.getAllFeed(0);
                                  }
                                },
                                child: Container(
                                  width: 150,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: transparent,
                                    border: Border.all(
                                        width: 1.5, color: button1color),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MyText(
                                          color: button1color,
                                          multilanguage: true,
                                          text: settingProvider.profileModel
                                                      .result?[0].isSubscribe ==
                                                  0
                                              ? "subscribe"
                                              : "subscribed",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: Dimens.textSmall,
                                          inter: true,
                                          maxline: 1,
                                          fontwaight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                    ],
                                  ),
                                ),
                              ),
                        const SizedBox(width: 15),
                        settingProvider.profileModel.result?[0]
                                        .isCreatorRequest ==
                                    0 &&
                                Constant.userID ==
                                    settingProvider.profileModel.result?[0].id
                                        .toString()
                            ? InkWell(
                                onTap: () async {
                                  await buildRequestCreatorDialog(
                                      settingProvider.profileModel.result);
                                  setState(() {
                                    getApi();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 11),
                                  decoration: BoxDecoration(
                                      gradient: Constant.gradientColor,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: MyText(
                                      text: "requestcreator",
                                      color: pureBlack,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      inter: true,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              )
                            : Container(),
                        settingProvider.profileModel.result?[0]
                                        .isCreatorRequest ==
                                    1 &&
                                settingProvider
                                        .profileModel.result?[0].isCreator ==
                                    0 &&
                                Constant.userID ==
                                    settingProvider.profileModel.result?[0].id
                                        .toString()
                            ? Tooltip(
                                message: "Admin approval pending.",
                                triggerMode: TooltipTriggerMode.tap,
                                preferBelow: false,
                                margin: const EdgeInsets.only(bottom: 5),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 11),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: textColor),
                                      borderRadius: BorderRadius.circular(50)),
                                  child: MyText(
                                      text: "pending",
                                      color: textColor,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      inter: true,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              )
                            : Container(),
                        settingProvider.profileModel.result?[0].isCreator ==
                                    1 &&
                                Constant.userID ==
                                    settingProvider.profileModel.result?[0].id
                                        .toString()
                            ? InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ViewMembershipPlan(
                                            isUser: true,
                                            creatorId: Constant.userID ?? '0');
                                      },
                                    ),
                                  );
                                  setState(() {
                                    getApi();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 11),
                                  decoration: BoxDecoration(
                                      gradient: Constant.gradientColor,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: MyText(
                                      text: 'viewplans',
                                      color: pureBlack,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      inter: true,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              )
                            : const SizedBox(),
                        Constant.userID !=
                                settingProvider.profileModel.result?[0].id
                                    .toString()
                            ? InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ViewMembershipPlan(
                                          isUser: false,
                                          creatorId: settingProvider
                                                  .profileModel.result?[0].id
                                                  .toString() ??
                                              '0',
                                        );
                                      },
                                    ),
                                  );
                                  setState(() {
                                    getApi();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 11),
                                  decoration: BoxDecoration(
                                      gradient: Constant.gradientColor,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: MyText(
                                      text: settingProvider.profileModel
                                                  .result?[0].purchasePackage ==
                                              1
                                          ? 'Subscribed'
                                          : 'Buy Subscription',
                                      color: pureBlack,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      inter: true,
                                      multilanguage: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  )
              ]),
              const SizedBox(height: 15),
              if (!ResponsiveHelper.isDesktop(context))
                if (settingProvider.profileModel.result?[0].isCreator
                        .toString() ==
                    "1") ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 50.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: white, width: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...[
                              {
                                "icon": Icons.chat,
                                "label": "chat",
                                "amount": settingProvider
                                    .profileModel.result?[0].chatAmount,
                                "suffix": "/chat",
                              },
                              {
                                "icon": Icons.call,
                                "label": "audiocall",
                                "amount": settingProvider
                                    .profileModel.result?[0].audioCallAmount,
                                "suffix": "/min",
                              },
                              {
                                "icon": Icons.videocam,
                                "label": "videocall",
                                "amount": settingProvider
                                    .profileModel.result?[0].videoCallAmount,
                                "suffix": "/min",
                              },
                            ].asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;

                              return Row(
                                children: [
                                  Column(
                                    children: [
                                      Icon(item["icon"] as IconData,
                                          color: white, size: 22),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 2.5, top: 0.5),
                                        child: MyText(
                                          text: item["label"] as String,
                                          color: white,
                                          fontsizeNormal: 13,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          MyImage(
                                              width: 15,
                                              height: 15,
                                              imagePath: "ic_coin.png"),
                                          MyText(
                                            text:
                                                " ${(item["amount"] ?? '').toString()}${item["suffix"]}",
                                            color: white,
                                            multilanguage: false,
                                            fontsizeNormal: 13,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (index < 2) // divider only between items
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 23),
                                      height: 45,
                                      width: 1.5,
                                      color: white,
                                    ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              const SizedBox(height: 15),
              if (!ResponsiveHelper.isDesktop(context))
                Padding(
                  padding: const EdgeInsets.only(right: 50.0),
                  child: Row(
                    children: [
                      ((Constant.userID == null) ||
                              (widget.isProfile == true) ||
                              (widget.channelUserid == Constant.userID))
                          ? const SizedBox.shrink()
                          : InkWell(
                              focusColor: transparent,
                              splashColor: transparent,
                              highlightColor: transparent,
                              hoverColor: transparent,
                              onTap: () async {
                                final feedProvider = Provider.of<FeedProvider>(
                                    context,
                                    listen: false);
                                await profileProvider.addRemoveSubscriber(
                                    0,
                                    profileProvider.profileModel.result?[0].id
                                            .toString() ??
                                        "",
                                    "1");

                                if (profileProvider
                                        .addremoveSubscribeModel.status ==
                                    200) {
                                  await feedProvider.getAllFeed(0);
                                }
                              },
                              child: Container(
                                width: 150,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: transparent,
                                  border: Border.all(
                                      width: 1.5, color: button1color),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    MyText(
                                        color: button1color,
                                        multilanguage: true,
                                        text: settingProvider.profileModel
                                                    .result?[0].isSubscribe ==
                                                0
                                            ? "subscribe"
                                            : "subscribed",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: Dimens.textSmall,
                                        inter: true,
                                        maxline: 1,
                                        fontwaight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                  ],
                                ),
                              ),
                            ),
                      const SizedBox(width: 15),
                      settingProvider.profileModel.result?[0]
                                      .isCreatorRequest ==
                                  0 &&
                              Constant.userID ==
                                  settingProvider.profileModel.result?[0].id
                                      .toString()
                          ? InkWell(
                              onTap: () async {
                                if (kIsWeb &&
                                    !ResponsiveHelper.isMobile(context)) {
                                  await buildRequestCreatorDialog(
                                      settingProvider.profileModel.result);
                                } else {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return RequestCreator(
                                          email: settingProvider.profileModel
                                                  .result?[0].email ??
                                              '',
                                        );
                                      },
                                    ),
                                  );
                                }
                                setState(() {
                                  getApi();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 11),
                                decoration: BoxDecoration(
                                    gradient: Constant.gradientColor,
                                    borderRadius: BorderRadius.circular(50)),
                                child: MyText(
                                    text: "requestcreator",
                                    color: pureBlack,
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
                                    inter: true,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            )
                          : Container(),
                      settingProvider.profileModel.result?[0]
                                      .isCreatorRequest ==
                                  1 &&
                              settingProvider
                                      .profileModel.result?[0].isCreator ==
                                  0 &&
                              Constant.userID ==
                                  settingProvider.profileModel.result?[0].id
                                      .toString()
                          ? Tooltip(
                              message: "Admin approval pending.",
                              triggerMode: TooltipTriggerMode.tap,
                              preferBelow: false,
                              margin: const EdgeInsets.only(bottom: 5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 11),
                                decoration: BoxDecoration(
                                    border: Border.all(color: textColor),
                                    borderRadius: BorderRadius.circular(50)),
                                child: MyText(
                                    text: "pending",
                                    color: textColor,
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
                                    inter: true,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            )
                          : Container(),
                      settingProvider.profileModel.result?[0].isCreator == 1 &&
                              Constant.userID ==
                                  settingProvider.profileModel.result?[0].id
                                      .toString()
                          ? InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ViewMembershipPlan(
                                          isUser: true,
                                          creatorId: Constant.userID ?? '0');
                                    },
                                  ),
                                );
                                setState(() {
                                  getApi();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 11),
                                decoration: BoxDecoration(
                                    gradient: Constant.gradientColor,
                                    borderRadius: BorderRadius.circular(50)),
                                child: MyText(
                                    text: 'viewplans',
                                    color: pureBlack,
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
                                    inter: true,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            )
                          : const SizedBox(),
                      Constant.userID !=
                              settingProvider.profileModel.result?[0].id
                                  .toString()
                          ? InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ViewMembershipPlan(
                                        isUser: false,
                                        creatorId: settingProvider
                                                .profileModel.result?[0].id
                                                .toString() ??
                                            '0',
                                      );
                                    },
                                  ),
                                );
                                setState(() {
                                  getApi();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 11),
                                decoration: BoxDecoration(
                                    gradient: Constant.gradientColor,
                                    borderRadius: BorderRadius.circular(50)),
                                child: MyText(
                                    text: settingProvider.profileModel
                                                .result?[0].purchasePackage ==
                                            1
                                        ? 'Subscribed'
                                        : 'Buy Subscription',
                                    color: pureBlack,
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
                                    inter: true,
                                    multilanguage: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                )
            ],
          ),
        );
      }
    });
  }

  void _showRatingDialog(profile.ProfileModel profile) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.36,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rate ${profile.result?[0].fullName}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(
                  height: 10,
                ),
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 10,
                  itemSize: 26,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 2.5),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    _rating = rating;
                  },
                ),
                const SizedBox(height: 16),
                MyText(
                  text: "message",
                  fontsizeNormal: 16,
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Enter your message",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: MyText(
                        text: "Cancel",
                        color: colorPrimary,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimary,
                        foregroundColor: white,
                      ),
                      onPressed: () async {
                        Utils.showProgress(context);
                        SuccessModel rating = await ApiService().ratingCreator(
                            _rating,
                            _messageController.text,
                            Constant.userID ?? '',
                            profile.result?[0].id.toString() ?? '');
                        if (!mounted) return;
                        Utils().hideProgress(context);
                        if (rating.status == 200) {
                          if (!mounted) return;
                          Navigator.pop(context);
                          Utils().showSnackBar(
                              context, "${rating.message}", false);
                          getApi();
                        } else {
                          Utils().showSnackBar(
                              context, "${rating.message}", false);
                        }
                      },
                      child: const Text("Submit"),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildButtons({onTap, title, multilanguage}) {
    return InkWell(
      hoverColor: transparent,
      highlightColor: transparent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        decoration: BoxDecoration(
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(50),
        ),
        child: MyText(
            color: white,
            text: title,
            textalign: TextAlign.center,
            fontsizeNormal: Dimens.textSmall,
            fontsizeWeb: Dimens.textSmall,
            inter: false,
            multilanguage: multilanguage ?? true,
            maxline: 1,
            fontwaight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal),
      ),
    );
  }

  Widget buildImageShimmer() {
    return const Padding(
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: Row(
        children: [
          CustomWidget.circular(
            width: 160,
            height: 160,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomWidget.roundrectborder(
                  width: 200,
                  height: 12,
                ),
                SizedBox(height: 15),
                CustomWidget.roundrectborder(
                  width: 200,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTab() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0, top: 15),
        child: SizedBox(
          height: 90,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: Constant.profileTabList.length,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                    // physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        focusColor: transparent,
                        splashColor: transparent,
                        highlightColor: transparent,
                        hoverColor: transparent,
                        onTap: () async {
                          profileprovider.changeTab(index);
                          /* Video */
                          if (profileprovider.position == 0) {
                            getTabData(0, "1");
                            profileprovider.clearListData();
                            /* Podcast */
                          } else if (profileprovider.position == 1) {
                            getTabData(0, "2");
                            profileprovider.clearListData();
                            /* Playlist */
                          } else if (profileprovider.position == 2) {
                            getTabData(0, "4");
                            profileprovider.clearListData();
                            /* Playlist */
                          } else if (profileprovider.position == 3) {
                            getTabData(0, "5");
                            profileprovider.clearListData();
                            /* Short */
                          } else if (profileprovider.position == 4) {
                            getTabData(0, "3");
                            profileprovider.clearListData();
                            /* Other Page  */
                          } else if (profileprovider.position == 5) {
                            _fetchChannelFeedData(0);
                            // } else if (profileprovider.position == 5) {
                            //   _fetchRentData(0);
                            //   profileprovider.clearListData();
                            /* Other Page  */
                          } else if (profileprovider.position == 6) {
                            getTabData(0, "7");
                            profileprovider.clearListData();
                            /* Feeds */
                          } else {
                            profileprovider.clearListData();
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.only(right: 7),
                            decoration: BoxDecoration(
                                color: profileprovider.position == index
                                    ? Colors.grey.withOpacity(0.35)
                                    : transparent,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                MyImage(
                                    width: 35,
                                    height: 35,
                                    imagePath:
                                        Constant.profileTabIconList[index]),
                                const SizedBox(
                                  height: 7,
                                ),
                                MyText(
                                    color: white,
                                    text: Constant.profileTabList[index],
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textMedium,
                                    inter: false,
                                    multilanguage: true,
                                    maxline: 1,
                                    fontwaight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                const SizedBox(height: 13),
                                const SizedBox(
                                  height: 0,
                                  width: 85,
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              Container(
                color: transparent,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                height: 1,
                width: MediaQuery.of(context).size.width,
              )
            ],
          ),
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
        return buildMusic();
      } else if (profileprovider.position == 2) {
        return buildPodcast();
      } else if (profileprovider.position == 3) {
        return buildPlaylist();
      } else if (profileprovider.position == 4) {
        return buildReels();
      } else if (profileprovider.position == 5) {
        return buildFeeds();
        // } else if (profileprovider.position == 5) {
        //   return buildRentVideo();
      } else if (profileprovider.position == 6) {
        return buildLive();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget buildLive() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return reelsShimmer();
      } else {
        return Column(
          children: [
            live(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
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

  Widget live() {
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
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
                  !ResponsiveHelper.isWeb(context)
                      ? (Constant.userID ==
                              profileProvider.profileModel.result?[0].id
                                  .toString()
                          ? (profileProvider.channelContentList?.length ?? 0) +
                              1
                          : (profileProvider.channelContentList?.length ?? 0))
                      : (profileProvider.channelContentList?.length ?? 0),
                  (index) {
                final adjustedIndex =
                    !ResponsiveHelper.isWeb(context) ? index - 1 : index;

                return InkWell(
                  focusColor: transparent,
                  splashColor: transparent,
                  highlightColor: transparent,
                  hoverColor: transparent,
                  onTap: () {
                    final selectedItem = profileProvider.channelContentList?[
                        Constant.userID ==
                                profileProvider.profileModel.result?[0].id
                                    .toString()
                            ? adjustedIndex
                            : index];

                    if (selectedItem != null) {
                      if (selectedItem.status == 1) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                WebDetail(
                                    stoptime: 0,
                                    iscontinueWatching: false,
                                    videoid: selectedItem.id.toString(),
                                    feedType:
                                        selectedItem.contentType.toString()),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              url: selectedItem.content.toString(),
                              title: selectedItem.title.toString(),
                              contentId: selectedItem.id.toString(),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                imagePath: profileProvider
                                        .channelContentList?[Constant.userID ==
                                                profileProvider
                                                    .profileModel.result?[0].id
                                                    .toString()
                                            ? adjustedIndex
                                            : index]
                                        .portraitImg
                                        .toString() ??
                                    "",
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: MyImage(
                                  width: 25,
                                  height: 25,
                                  imagePath: "pause.png"),
                            ),
                            if (Constant.userID ==
                                profileProvider
                                    .channelContentList?[Constant.userID ==
                                            profileProvider
                                                .profileModel.result?[0].id
                                                .toString()
                                        ? adjustedIndex
                                        : index]
                                    .userId
                                    .toString())
                              Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  margin: const EdgeInsets.all(7),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 7),
                                  decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      profileProvider
                                                  .channelContentList?[
                                                      Constant.userID ==
                                                              profileProvider
                                                                  .profileModel
                                                                  .result?[0]
                                                                  .id
                                                                  .toString()
                                                          ? adjustedIndex
                                                          : index]
                                                  .type ==
                                              "free"
                                          ? const SizedBox()
                                          : MyImage(
                                              width: 18,
                                              height: 18,
                                              imagePath: 'ic_coin.png'),
                                      profileProvider
                                                  .channelContentList?[
                                                      Constant.userID ==
                                                              profileProvider
                                                                  .profileModel
                                                                  .result?[0]
                                                                  .id
                                                                  .toString()
                                                          ? adjustedIndex
                                                          : index]
                                                  .type ==
                                              "free"
                                          ? const SizedBox()
                                          : const SizedBox(width: 3.5),
                                      MyText(
                                        text: profileProvider
                                                    .channelContentList?[
                                                        Constant.userID ==
                                                                profileProvider
                                                                    .profileModel
                                                                    .result?[0]
                                                                    .id
                                                                    .toString()
                                                            ? adjustedIndex
                                                            : index]
                                                    .status ==
                                                1
                                            ? 'Public'
                                            : 'Private',
                                        color: black,
                                        multilanguage: false,
                                        fontsizeNormal: 12,
                                        fontsizeWeb: 12.5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (Constant.userID !=
                                    profileProvider
                                        .channelContentList?[Constant.userID ==
                                                profileProvider
                                                    .profileModel.result?[0].id
                                                    .toString()
                                            ? adjustedIndex
                                            : index]
                                        .userId
                                        .toString() &&
                                profileProvider
                                        .channelContentList?[Constant.userID ==
                                                profileProvider
                                                    .profileModel.result?[0].id
                                                    .toString()
                                            ? adjustedIndex
                                            : index]
                                        .isBuy ==
                                    1)
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: const EdgeInsets.all(7),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 7),
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: transparent.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      MyImage(
                                          width: 17.5,
                                          height: 17.5,
                                          imagePath: "ic_coin.png"),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      MyText(
                                        text: "featured",
                                        fontsizeNormal: 12,
                                        fontsizeWeb: 12.5,
                                        color: white,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            if (profileProvider.deleteItemIndex ==
                                    (Constant.userID ==
                                            profileProvider
                                                .profileModel.result?[0].id
                                                .toString()
                                        ? adjustedIndex
                                        : index) &&
                                profileProvider.deletecontentLoading)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: colorPrimary,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () async {
                                    Utils().conformDialog(
                                        context,
                                        () async {
                                          if (widget.channelUserid ==
                                              Constant.userID) {
                                            await profileProvider.getDeleteContent(
                                                Constant.userID ==
                                                        profileProvider
                                                            .profileModel
                                                            .result?[0]
                                                            .id
                                                            .toString()
                                                    ? adjustedIndex
                                                    : index,
                                                profileProvider
                                                        .channelContentList?[Constant
                                                                    .userID ==
                                                                profileProvider
                                                                    .profileModel
                                                                    .result?[0]
                                                                    .id
                                                                    .toString()
                                                            ? adjustedIndex
                                                            : index]
                                                        .contentType
                                                        .toString() ??
                                                    "",
                                                profileProvider
                                                        .channelContentList?[Constant
                                                                    .userID ==
                                                                profileProvider
                                                                    .profileModel
                                                                    .result?[0]
                                                                    .id
                                                                    .toString()
                                                            ? adjustedIndex
                                                            : index]
                                                        .id
                                                        .toString() ??
                                                    "",
                                                "0");
                                          }
                                        },
                                        "wanttodelete",
                                        () {
                                          Navigator.pop(context);
                                        });
                                  },
                                  child: widget.channelUserid == Constant.userID
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 8, 5, 8),
                                          child: CircleAvatar(
                                            radius: 13,
                                            backgroundColor: pureWhite,
                                            child: MyImage(
                                                width: 13,
                                                height: 13,
                                                color: Colors.red,
                                                imagePath: "ic_delete.png"),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      MyText(
                          color: white,
                          text: profileProvider
                                  .channelContentList?[Constant.userID ==
                                          profileProvider
                                              .profileModel.result?[0].id
                                              .toString()
                                      ? adjustedIndex
                                      : index]
                                  .title
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textSmall,
                          inter: false,
                          multilanguage: false,
                          maxline: 1,
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

  Widget buildMusic() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return padcastShimmer();
      } else {
        print(
            "profile :${profileprovider.profileModel.result?[0].packageName}");
        return Column(
          children: [
            music(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
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

  Widget music() {
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
        final isOwner = Constant.userID ==
            profileProvider.profileModel.result?[0].id.toString();
        final itemCount = (profileProvider.channelContentList?.length ?? 0) +
            (isOwner ? 1 : 0);
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
              children: List.generate(itemCount, (index) {
                if (isOwner && index == 0) {
                  return InkWell(
                    onTap: () async {
                      if (ResponsiveHelper.isMobile(context)) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const CreateMusic();
                            },
                          ),
                        );
                      } else {
                        await buildCreatePostDialog("music");
                      }
                      setState(() {
                        reloadApi("2");
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade600),
                      ),
                      child: const Center(
                        child: Icon(Icons.add, size: 35, color: Colors.grey),
                      ),
                    ),
                  );
                }
                final contentIndex = isOwner ? index - 1 : index;

                if (contentIndex < 0 ||
                    contentIndex >=
                        (profileProvider.channelContentList?.length ?? 0)) {
                  return const SizedBox.shrink();
                }

                final content =
                    profileProvider.channelContentList![contentIndex];
                // Adjust index because of +1

                return InkWell(
                  onTap: () {
                    /*musicManager.setInitialMusic(
                        content.id ??0,
                        content.contentType.toString(),
                        profileProvider.channelContentList,
                        content.id.toString(),
                        addView(content.contentType.toString(), content.id.toString()),
                        false,
                        0,
                        content.isBuy.toString());*/
                    playAudio(
                      playingType: content.contentType.toString(),
                      episodeid: content.id.toString(),
                      contentid: content.id.toString(),
                      position: content.id ?? 0,
                      sectionBannerList: profileProvider.channelContentList,
                      contentName: content.title.toString(),
                      isBuy: content.isBuy.toString(),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MyNetworkImage(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                                imagePath: content.portraitImg.toString() ?? "",
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: MyImage(
                                  width: 30,
                                  height: 30,
                                  imagePath: "pause.png"),
                            ),
                            if (profileProvider.deleteItemIndex ==
                                    (Constant.userID ==
                                            profileProvider
                                                .profileModel.result?[0].id
                                                .toString()
                                        ? contentIndex
                                        : index) &&
                                profileProvider.deletecontentLoading)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: colorPrimary,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () async {
                                    Utils().conformDialog(
                                        context,
                                        () async {
                                          if (widget.channelUserid ==
                                              Constant.userID) {
                                            await profileProvider.getDeleteContent(
                                                Constant.userID ==
                                                        profileProvider
                                                            .profileModel
                                                            .result?[0]
                                                            .id
                                                            .toString()
                                                    ? contentIndex
                                                    : index,
                                                profileProvider
                                                        .channelContentList?[Constant
                                                                    .userID ==
                                                                profileProvider
                                                                    .profileModel
                                                                    .result?[0]
                                                                    .id
                                                                    .toString()
                                                            ? contentIndex
                                                            : index]
                                                        .contentType
                                                        .toString() ??
                                                    "",
                                                profileProvider
                                                        .channelContentList?[Constant
                                                                    .userID ==
                                                                profileProvider
                                                                    .profileModel
                                                                    .result?[0]
                                                                    .id
                                                                    .toString()
                                                            ? contentIndex
                                                            : index]
                                                        .id
                                                        .toString() ??
                                                    "",
                                                "0");
                                          }
                                        },
                                        "wanttodelete",
                                        () {
                                          Navigator.pop(context);
                                        });
                                  },
                                  child: widget.channelUserid == Constant.userID
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 8, 5, 8),
                                          child: CircleAvatar(
                                            radius: 13.5,
                                            backgroundColor: pureWhite,
                                            child: MyImage(
                                                width: 14,
                                                height: 14,
                                                color: Colors.red,
                                                imagePath: "ic_delete.png"),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      MyText(
                          color: white,
                          text: profileProvider
                                  .channelContentList?[Constant.userID ==
                                          profileProvider
                                              .profileModel.result?[0].id
                                              .toString()
                                      ? contentIndex
                                      : index]
                                  .title
                                  .toString() ??
                              "",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textMedium,
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
        if (Constant.isCreator != "1" ||
            (Constant.userID !=
                profileProvider.profileModel.result?[0].id.toString())) {
          return const NoData(
              title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
        } else {
          return Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: InkWell(
              onTap: () async {
                if (ResponsiveHelper.isMobile(context)) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const CreateMusic();
                      },
                    ),
                  );
                } else {
                  await buildCreatePostDialog("music");
                }
                setState(() {
                  reloadApi("2");
                });
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 120,
                  width: 200,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                    child: Center(
                      child: Icon(Icons.add,
                          size: 30, color: Colors.grey.shade700),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    } else {
      if (Constant.isCreator != "1" ||
          (Constant.userID !=
              profileProvider.profileModel.result?[0].id.toString())) {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      } else {
        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: InkWell(
            onTap: () async {
              if (ResponsiveHelper.isMobile(context)) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const CreateMusic();
                    },
                  ),
                );
              } else {
                await buildCreatePostDialog("music");
              }
              setState(() {
                reloadApi("2");
              });
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 120,
                width: 200,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  child: Center(
                    child:
                        Icon(Icons.add, size: 30, color: Colors.grey.shade700),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
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
    if (playingType == "2") {
      musicManager.setInitialMusic(position, playingType, sectionBannerList,
          contentid, addView(playingType, contentid), false, 0, isBuy ?? "");
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

  Widget buildVideo() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return videoShimmer();
      } else {
        return Column(
          children: [
            video(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
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
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 130,
              minItemsPerRow: 3,
              maxItemsPerRow: 3,
              horizontalGridSpacing: 5,
              verticalGridSpacing: 15,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  Constant.userID ==
                          profileProvider.profileModel.result?[0].id.toString()
                      ? (profileProvider.channelContentList?.length ?? 0) + 1
                      : (profileProvider.channelContentList?.length ?? 0),
                  (index) {
                if (Constant.userID ==
                    profileProvider.profileModel.result?[0].id.toString()) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: InkWell(
                        onTap: () async {
                          if (ResponsiveHelper.isMobile(context)) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const CreateVideo(isAppBar: true);
                                },
                              ),
                            );
                          } else {
                            await buildCreatePostDialog("video");
                          }
                          setState(() {
                            reloadApi("1");
                          });
                        },
                        child: SizedBox(
                          height: 180,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade700),
                            ),
                            child: Center(
                              child: Icon(Icons.add,
                                  size: 30, color: Colors.grey.shade700),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }
                final adjustedIndex = Constant.userID ==
                        profileProvider.profileModel.result?[0].id.toString()
                    ? index - 1
                    : index;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              WebDetail(
                                  stoptime: 0,
                                  iscontinueWatching: false,
                                  videoid: profileProvider
                                          .channelContentList?[adjustedIndex].id
                                          .toString() ??
                                      "",
                                  feedType: profileProvider
                                          .channelContentList?[adjustedIndex]
                                          .contentType
                                          .toString() ??
                                      ""),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: SizedBox(
                      // width: 90,
                      height: 180,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: MyNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              fit: BoxFit.cover,
                              imagePath: profileProvider
                                      .channelContentList?[adjustedIndex]
                                      .portraitImg
                                      .toString() ??
                                  "",
                            ),
                          ),
                          if (Constant.userID ==
                                  profileProvider.profileModel.result?[0].id
                                      .toString() &&
                              profileProvider.channelContentList?[adjustedIndex]
                                      .type !=
                                  'free')
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 8, 5, 8),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(3, 3, 3, 3),
                                    decoration: BoxDecoration(
                                        color: white.withOpacity(0.9),
                                        shape: BoxShape.circle),
                                    child: MyImage(
                                        width: 18,
                                        height: 18,
                                        imagePath: "ic_coin.png"),
                                  )),
                            ),
                          Align(
                            alignment: Alignment.center,
                            child: MyImage(
                                width: 25, height: 25, imagePath: "pause.png"),
                          ),
                          if (profileProvider.deleteItemIndex ==
                                  adjustedIndex &&
                              profileProvider.deletecontentLoading)
                            const Padding(
                              padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: colorPrimary,
                                    strokeWidth: 1,
                                  ),
                                ),
                              ),
                            )
                          else
                            Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () async {
                                  Utils().conformDialog(
                                      context,
                                      () async {
                                        if (widget.channelUserid ==
                                            Constant.userID) {
                                          await profileProvider
                                              .getDeleteContent(
                                                  adjustedIndex,
                                                  profileProvider
                                                          .channelContentList?[
                                                              adjustedIndex]
                                                          .contentType
                                                          .toString() ??
                                                      "",
                                                  profileProvider
                                                          .channelContentList?[
                                                              adjustedIndex]
                                                          .id
                                                          .toString() ??
                                                      "",
                                                  "0");
                                        }
                                      },
                                      "wanttodelete",
                                      () {
                                        Navigator.pop(context);
                                      });
                                },
                                child: widget.channelUserid == Constant.userID
                                    ? Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 8, 5, 8),
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor:
                                              white.withOpacity(0.9),
                                          child: MyImage(
                                              width: 12,
                                              height: 12,
                                              color: Colors.red,
                                              imagePath: "ic_delete.png"),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      } else {
        if (Constant.isCreator != "1" ||
            (Constant.userID !=
                profileProvider.profileModel.result?[0].id.toString())) {
          return const NoData(
              title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
        } else {
          return Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: InkWell(
              onTap: () async {
                if (ResponsiveHelper.isMobile(context)) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const CreateVideo(isAppBar: true);
                      },
                    ),
                  );
                } else {
                  await buildCreatePostDialog("video");
                }
                setState(() {
                  reloadApi("1");
                });
              },
              child: SizedBox(
                height: 180,
                width: 180,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  child: Center(
                    child:
                        Icon(Icons.add, size: 30, color: Colors.grey.shade700),
                  ),
                ),
              ),
            ),
          );
        }
      }
    } else {
      if (Constant.isCreator != "1" ||
          (Constant.userID !=
              profileProvider.profileModel.result?[0].id.toString())) {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      } else {
        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: InkWell(
            onTap: () async {
              if (ResponsiveHelper.isMobile(context)) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const CreateVideo(isAppBar: true);
                    },
                  ),
                );
              } else {
                await buildCreatePostDialog("video");
              }
              setState(() {
                reloadApi("1");
              });
            },
            child: SizedBox(
              height: 180,
              width: 180,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Center(
                  child: Icon(Icons.add, size: 30, color: Colors.grey.shade700),
                ),
              ),
            ),
          ),
        );
      }
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

  Widget buildPodcast() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return padcastShimmer();
      } else {
        return Column(
          children: [
            padcast(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
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
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
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
                  Constant.userID ==
                          profileProvider.profileModel.result?[0].id.toString()
                      ? (profileProvider.channelContentList?.length ?? 0) + 1
                      : (profileProvider.channelContentList?.length ?? 0),
                  (index) {
                if (Constant.userID ==
                    profileProvider.profileModel.result?[0].id.toString()) {
                  if (index == 0) {
                    return InkWell(
                      onTap: () async {
                        if (ResponsiveHelper.isMobile(context)) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const CreatePodcast(isAppBar: true);
                              },
                            ),
                          );
                        } else {
                          await buildCreatePostDialog("podcast");
                        }
                        setState(() {
                          reloadApi("4");
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 180,
                        margin: EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade600),
                        ),
                        child: const Center(
                          child: Icon(Icons.add, size: 35, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                }
                // Adjust index because of +1
                final contentIndex = index - 1;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ContentDetail(
                            contentType: profileProvider
                                    .channelContentList?[Constant.userID ==
                                            profileProvider
                                                .profileModel.result?[0].id
                                                .toString()
                                        ? contentIndex
                                        : index]
                                    .contentType
                                    .toString() ??
                                "",
                            contentImage: profileProvider
                                    .channelContentList?[Constant.userID ==
                                            profileProvider
                                                .profileModel.result?[0].id
                                                .toString()
                                        ? contentIndex
                                        : index]
                                    .portraitImg
                                    .toString() ??
                                "",
                            contentName: profileProvider
                                    .channelContentList?[Constant.userID ==
                                            profileProvider
                                                .profileModel.result?[0].id
                                                .toString()
                                        ? contentIndex
                                        : index]
                                    .title
                                    .toString() ??
                                "",
                            contentUserid: "",
                            contentId: profileProvider
                                    .channelContentList?[Constant.userID ==
                                            profileProvider
                                                .profileModel.result?[0].id
                                                .toString()
                                        ? contentIndex
                                        : index]
                                    .id
                                    .toString() ??
                                "",
                            playlistImage: profileProvider
                                .channelContentList?[Constant.userID ==
                                        profileProvider
                                            .profileModel.result?[0].id
                                            .toString()
                                    ? contentIndex
                                    : index]
                                .playlistImage,
                            isBuy: profileProvider
                                    .channelContentList?[Constant.userID ==
                                            profileProvider
                                                .profileModel.result?[0].id
                                                .toString()
                                        ? contentIndex
                                        : index]
                                    .isBuy
                                    .toString() ??
                                "",
                          );
                        },
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
                                imagePath: profileProvider
                                        .channelContentList?[Constant.userID ==
                                                profileProvider
                                                    .profileModel.result?[0].id
                                                    .toString()
                                            ? contentIndex
                                            : index]
                                        .portraitImg
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
                            if (profileProvider.deleteItemIndex ==
                                    (Constant.userID ==
                                            profileProvider
                                                .profileModel.result?[0].id
                                                .toString()
                                        ? contentIndex
                                        : index) &&
                                profileProvider.deletecontentLoading)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: colorPrimary,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () async {
                                    Utils().conformDialog(
                                        context,
                                        () async {
                                          if (widget.channelUserid ==
                                              Constant.userID) {
                                            await profileProvider.getDeleteContent(
                                                Constant.userID ==
                                                        profileProvider
                                                            .profileModel
                                                            .result?[0]
                                                            .id
                                                            .toString()
                                                    ? contentIndex
                                                    : index,
                                                profileProvider
                                                        .channelContentList?[Constant
                                                                    .userID ==
                                                                profileProvider
                                                                    .profileModel
                                                                    .result?[0]
                                                                    .id
                                                                    .toString()
                                                            ? contentIndex
                                                            : index]
                                                        .contentType
                                                        .toString() ??
                                                    "",
                                                profileProvider
                                                        .channelContentList?[Constant
                                                                    .userID ==
                                                                profileProvider
                                                                    .profileModel
                                                                    .result?[0]
                                                                    .id
                                                                    .toString()
                                                            ? contentIndex
                                                            : index]
                                                        .id
                                                        .toString() ??
                                                    "",
                                                "0");
                                          }
                                        },
                                        "wanttodelete",
                                        () {
                                          Navigator.pop(context);
                                        });
                                  },
                                  child: widget.channelUserid == Constant.userID
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 8, 5, 8),
                                          child: CircleAvatar(
                                            radius: 13.5,
                                            backgroundColor: white,
                                            child: MyImage(
                                                width: 14,
                                                height: 14,
                                                color: Colors.red,
                                                imagePath: "ic_delete.png"),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      MyText(
                          color: white,
                          text: profileProvider
                                  .channelContentList?[Constant.userID ==
                                          profileProvider
                                              .profileModel.result?[0].id
                                              .toString()
                                      ? contentIndex
                                      : index]
                                  .title
                                  .toString() ??
                              "",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textMedium,
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
        if (Constant.isCreator != "1" ||
            (Constant.userID !=
                profileProvider.profileModel.result?[0].id.toString())) {
          return const NoData(
              title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
        } else {
          return Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: InkWell(
              onTap: () async {
                if (ResponsiveHelper.isMobile(context)) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const CreatePodcast(isAppBar: true);
                      },
                    ),
                  );
                } else {
                  await buildCreatePostDialog("podcast");
                }
                setState(() {
                  reloadApi("4");
                });
              },
              child: SizedBox(
                height: 180,
                width: 180,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  child: Center(
                    child:
                        Icon(Icons.add, size: 30, color: Colors.grey.shade700),
                  ),
                ),
              ),
            ),
          );
        }
      }
    } else {
      if (Constant.isCreator != "1" ||
          (Constant.userID !=
              profileProvider.profileModel.result?[0].id.toString())) {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      } else {
        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: InkWell(
            onTap: () async {
              if (ResponsiveHelper.isMobile(context)) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const CreatePodcast(isAppBar: true);
                    },
                  ),
                );
              } else {
                await buildCreatePostDialog("podcast");
              }
              setState(() {
                reloadApi("4");
              });
            },
            child: SizedBox(
              height: 180,
              width: 180,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Center(
                  child: Icon(Icons.add, size: 30, color: Colors.grey.shade700),
                ),
              ),
            ),
          ),
        );
      }
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
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return playlistShimmer();
      } else {
        return Column(
          children: [
            playlist(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
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

  createPlaylistDialog() {
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
            width: MediaQuery.of(context).size.width * 0.39,
            height: 300,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorPrimary.withOpacity(0.10),
              // borderRadius: BorderRadius.circular(20),
            ),
            child: Consumer<ContentDetailProvider>(
                builder: (context, createplaylistprovider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                      color: white,
                      multilanguage: true,
                      text: "newplaylist",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textBig,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 25),
                  Utils().myTextField(playlistTitleController,
                      TextInputAction.next, TextInputType.name, "Name", false),
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
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: createplaylistprovider.isType == 1
                                ? textColor
                                : transparent,
                            border: Border.all(
                                width: 1.5,
                                color: createplaylistprovider.isType == 1
                                    ? textColor
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
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: createplaylistprovider.isType == 2
                                ? textColor
                                : transparent,
                            border: Border.all(
                                width: 1.5,
                                color: createplaylistprovider.isType == 2
                                    ? textColor
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
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        radius: 50,
                        autofocus: false,
                        onTap: () {
                          Navigator.pop(context);
                          playlistTitleController.clear();
                          contentDetailProvider.isType = 0;
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          decoration: BoxDecoration(
                            color: buttonDisable,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "cancel",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textMedium,
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
                            Navigator.pop(context);
                            await createplaylistprovider.getcreatePlayList(
                              Constant.channelID,
                              playlistTitleController.text,
                              contentDetailProvider.isType.toString(),
                            );
                            if (!createplaylistprovider.loading) {
                              if (createplaylistprovider
                                      .createPlaylistModel.status ==
                                  200) {
                                playlistTitleController.clear();
                                contentDetailProvider.isType = 0;
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

                            playlistTitleController.clear();
                            contentDetailProvider.isType = 0;
                            // _fetchPlaylist(0);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          decoration: BoxDecoration(
                            gradient: Constant.gradientColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: MyText(
                              color: pureBlack,
                              multilanguage: true,
                              text: "create",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textMedium,
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

  Widget playlist() {
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
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
                Constant.userID ==
                        profileProvider.profileModel.result?[0].id.toString()
                    ? (profileProvider.channelContentList?.length ?? 0) + 1
                    : (profileProvider.channelContentList?.length ?? 0),
                (index) {
                  if (Constant.userID ==
                      profileProvider.profileModel.result?[0].id.toString()) {
                    if (index == 0) {
                      return InkWell(
                        onTap: () async {
                          await createPlaylistDialog();
                          setState(() {
                            reloadApi("5");
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Column(
                            children: [
                              Container(
                                width: 160,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: white.withOpacity(0.5)),
                                ),
                                child: Center(
                                  child:
                                      Icon(Icons.add, size: 40, color: white),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  // Actual content list starts from index - 1
                  int actualIndex = index - 1;
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            final content = profileProvider.channelContentList![
                                Constant.userID ==
                                        profileProvider
                                            .profileModel.result?[0].id
                                            .toString()
                                    ? actualIndex
                                    : index];
                            return ContentDetail(
                              contentType: content.contentType.toString(),
                              contentImage: content.portraitImg.toString(),
                              contentName: content.title.toString(),
                              contentUserid: "",
                              contentId: content.id.toString(),
                              playlistImage: content.playlistImage,
                              isBuy: content.isBuy.toString(),
                            );
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 150,
                            child: Stack(
                              children: [
                                playlistImages(
                                    Constant.userID ==
                                            profileProvider
                                                .profileModel.result?[0].id
                                                .toString()
                                        ? actualIndex
                                        : index,
                                    profileProvider.channelContentList ?? []),
                                Align(
                                  alignment: Alignment.center,
                                  child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "pause.png",
                                  ),
                                ),
                                if (profileProvider.deleteItemIndex ==
                                        (Constant.userID ==
                                                profileProvider
                                                    .profileModel.result?[0].id
                                                    .toString()
                                            ? actualIndex
                                            : index) &&
                                    profileProvider.deletecontentLoading)
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: colorPrimary,
                                          strokeWidth: 1,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () async {
                                        Utils().conformDialog(
                                            context,
                                            () async {
                                              if (widget.channelUserid ==
                                                  Constant.userID) {
                                                await profileProvider
                                                    .getDeleteContent(
                                                  Constant.userID ==
                                                          profileProvider
                                                              .profileModel
                                                              .result?[0]
                                                              .id
                                                              .toString()
                                                      ? actualIndex
                                                      : index,
                                                  profileProvider
                                                          .channelContentList?[Constant
                                                                      .userID ==
                                                                  profileProvider
                                                                      .profileModel
                                                                      .result?[
                                                                          0]
                                                                      .id
                                                                      .toString()
                                                              ? actualIndex
                                                              : index]
                                                          .contentType
                                                          .toString() ??
                                                      "",
                                                  profileProvider
                                                          .channelContentList?[Constant
                                                                      .userID ==
                                                                  profileProvider
                                                                      .profileModel
                                                                      .result?[
                                                                          0]
                                                                      .id
                                                                      .toString()
                                                              ? actualIndex
                                                              : index]
                                                          .id
                                                          .toString() ??
                                                      "",
                                                  "0",
                                                );
                                              }
                                            },
                                            "wanttodelete",
                                            () {
                                              Navigator.pop(context);
                                            });
                                      },
                                      child: widget.channelUserid ==
                                              Constant.userID
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 8, 5, 8),
                                              child: CircleAvatar(
                                                radius: 13,
                                                backgroundColor: pureWhite,
                                                child: MyImage(
                                                  width: 13,
                                                  height: 13,
                                                  color: Colors.red,
                                                  imagePath: "ic_delete.png",
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 150,
                            child: MyText(
                              color: white,
                              multilanguage: false,
                              text: profileProvider
                                      .channelContentList?[Constant.userID ==
                                              profileProvider
                                                  .profileModel.result?[0].id
                                                  .toString()
                                          ? actualIndex
                                          : index]
                                      .title
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textMedium,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              MyText(
                                color: gray,
                                text: Utils.kmbGenerator(int.parse(
                                    profileProvider
                                            .channelContentList?[
                                                Constant.userID ==
                                                        profileProvider
                                                            .profileModel
                                                            .result?[0]
                                                            .id
                                                            .toString()
                                                    ? actualIndex
                                                    : index]
                                            .totalView
                                            .toString() ??
                                        "0")),
                                fontsizeNormal: Dimens.textMedium,
                                fontwaight: FontWeight.w600,
                              ),
                              const SizedBox(width: 5),
                              MyText(
                                color: gray,
                                text: "views",
                                fontsizeNormal: Dimens.textMedium,
                                fontwaight: FontWeight.w600,
                              ),
                            ],
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
      } else {
        if (Constant.isCreator != "1" ||
            (Constant.userID !=
                profileProvider.profileModel.result?[0].id.toString())) {
          return const NoData(
              title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
        } else {
          return InkWell(
            onTap: () async {
              await createPlaylistDialog();
              setState(() {
                reloadApi("5");
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 160,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: white.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Icon(Icons.add, size: 40, color: white),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        }
      }
    } else {
      if (Constant.isCreator != "1" ||
          (Constant.userID !=
              profileProvider.profileModel.result?[0].id.toString())) {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      } else {
        return InkWell(
          onTap: () async {
            await createPlaylistDialog();
            setState(() {
              reloadApi("5");
            });
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 160,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: white.withOpacity(0.4)),
                    ),
                    child: Center(
                      child: Icon(Icons.add, size: 40, color: white),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      }
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
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return reelsShimmer();
      } else {
        return Column(
          children: [
            reels(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
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
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
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
                  profileProvider.channelContentList?.length ?? 0, (index) {
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
                                imagePath: profileProvider
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
                            if (profileProvider.deleteItemIndex == index &&
                                profileProvider.deletecontentLoading)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: colorPrimary,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  hoverColor: transparent,
                                  highlightColor: transparent,
                                  onTap: () async {
                                    Utils().conformDialog(
                                        context,
                                        () async {
                                          if (widget.channelUserid ==
                                              Constant.userID) {
                                            await profileProvider
                                                .getDeleteContent(
                                                    index,
                                                    profileProvider
                                                            .channelContentList?[
                                                                index]
                                                            .contentType
                                                            .toString() ??
                                                        "",
                                                    profileProvider
                                                            .channelContentList?[
                                                                index]
                                                            .id
                                                            .toString() ??
                                                        "",
                                                    "0");
                                          }
                                        },
                                        "wanttodelete",
                                        () {
                                          Navigator.pop(context);
                                        });
                                  },
                                  child: widget.channelUserid == Constant.userID
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 8, 5, 8),
                                          child: MyImage(
                                              width: 20,
                                              height: 20,
                                              color: white,
                                              imagePath: "ic_delete.png"),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      MyText(
                          color: white,
                          text: profileProvider.channelContentList?[index].title
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

  Widget buildFeeds() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return rentVideoShimmer();
      } else {
        return Column(
          children: [
            feedItem(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
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

  Widget postContent(index) {
    if (profileProvider.channelFeedList?[index].postContent != null &&
        ((profileProvider.channelFeedList?[index].postContent?.length ?? 0) >
            0)) {
      if ((profileProvider.channelFeedList?[index].postContent?.length ?? 0) ==
          1) {
        return Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 15),
          height: 200,
          child: InkWell(
            onTap: (Constant.userID !=
                        profileProvider.channelFeedList?[index].userId
                            .toString() &&
                    profileProvider.channelFeedList?[index].payContent == true)
                ? null
                : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ShowPostContent(
                            clickPos: 0,
                            title: profileProvider.channelFeedList?[index].title
                                    .toString() ??
                                "",
                            type: "profile",
                            postContent: profileProvider
                                    .channelFeedList?[index].postContent ??
                                [],
                          );
                        },
                      ),
                    );
                  },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: (Constant.userID !=
                          profileProvider.channelFeedList?[index].userId
                              .toString() &&
                      profileProvider.channelFeedList?[index].payContent ==
                          true)
                  ? payPostApi(index)
                  : Stack(
                      children: [
                        MyNetworkImage(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.cover,
                          imagePath: profileProvider.channelFeedList?[index]
                                      .postContent?[0].contentType ==
                                  1
                              ? (profileProvider.channelFeedList?[index]
                                      .postContent?[0].contentUrl
                                      .toString() ??
                                  "")
                              : (profileProvider.channelFeedList?[index]
                                      .postContent?[0].thumbnailImage
                                      .toString() ??
                                  ""),
                        ),
                        if (Constant.userID ==
                                profileProvider.profileModel.result?[0].id
                                    .toString() &&
                            profileProvider.channelFeedList?[index].type !=
                                'free')
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 8, 5, 8),
                            child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(3, 3, 3, 3),
                                  decoration: BoxDecoration(
                                      color: white.withOpacity(0.9),
                                      shape: BoxShape.circle),
                                  child: MyImage(
                                      width: 18,
                                      height: 18,
                                      imagePath: "ic_coin.png"),
                                )),
                          ),
                        profileProvider.channelFeedList?[index].postContent?[0]
                                    .contentType ==
                                1
                            ? const SizedBox.shrink()
                            : Positioned.fill(
                                child: Align(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    color: white,
                                    size: 35,
                                  ),
                                ),
                              ),
                      ],
                    ),
            ),
          ),
        );
      } else {
        return SizedBox(
          height: 220,
          child: ListView.separated(
            separatorBuilder: (context, contentIndex) =>
                const SizedBox(width: 10),
            itemCount:
                profileProvider.channelFeedList?[index].postContent?.length ??
                    0,
            padding: const EdgeInsets.fromLTRB(10, 20, 0, 15),
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, contentIndex) {
              return InkWell(
                onTap: (Constant.userID !=
                            profileProvider.channelFeedList?[index].userId
                                .toString() &&
                        profileProvider.channelFeedList?[index].payContent ==
                            true)
                    ? null
                    : () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ShowPostContent(
                                clickPos: contentIndex,
                                title: profileProvider
                                        .channelFeedList?[index].title
                                        .toString() ??
                                    "",
                                type: "profile",
                                postContent: profileProvider
                                        .channelFeedList?[index].postContent ??
                                    [],
                              );
                            },
                          ),
                        );
                      },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: (Constant.userID !=
                              profileProvider.channelFeedList?[index].userId
                                  .toString() &&
                          profileProvider.channelFeedList?[index].payContent ==
                              true)
                      ? payPostApi(index)
                      : Stack(
                          children: [
                            MyNetworkImage(
                              width: 160,
                              height: MediaQuery.of(context).size.height,
                              fit: BoxFit.cover,
                              imagePath: profileProvider
                                          .channelFeedList?[index]
                                          .postContent?[contentIndex]
                                          .contentType ==
                                      1
                                  ? (profileProvider.channelFeedList?[index]
                                          .postContent?[contentIndex].contentUrl
                                          .toString() ??
                                      "")
                                  : (profileProvider
                                          .channelFeedList?[index]
                                          .postContent?[contentIndex]
                                          .thumbnailImage
                                          .toString() ??
                                      ""),
                            ),
                            profileProvider
                                        .channelFeedList?[index]
                                        .postContent?[contentIndex]
                                        .contentType ==
                                    1
                                ? const SizedBox.shrink()
                                : Positioned.fill(
                                    child: Align(
                                      child: Icon(
                                        Icons.play_circle_outline,
                                        color: white,
                                        size: 35,
                                      ),
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
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget feedItem() {
    if (profileProvider.getChannelFeedModel.status == 200 &&
        profileProvider.channelFeedList != null) {
      if ((profileProvider.channelFeedList?.length ?? 0) > 0) {
        return AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          itemCount: Constant.userID ==
                  profileProvider.profileModel.result?[0].id.toString()
              ? (profileProvider.channelFeedList?.length ?? 0) + 1
              : profileProvider.channelFeedList?.length ?? 0,
          // Add 1 for the add button
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (Constant.userID ==
                profileProvider.profileModel.result?[0].id.toString()) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const UploadFeed(isAppBar: false);
                        },
                      ),
                    );
                  },
                  child: Container(
                    height: 140,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                    child: Center(
                      child: Icon(Icons.add,
                          size: 30, color: Colors.grey.shade700),
                    ),
                  ),
                );
              }
            }
            // Adjust index for feed items (subtract 1 because we added the add button)
            final feedIndex = Constant.userID ==
                    profileProvider.profileModel.result?[0].id.toString()
                ? index - 1
                : index;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 15, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                        child: MyText(
                            color: white,
                            multilanguage: false,
                            text: profileProvider
                                    .channelFeedList?[feedIndex].title
                                    .toString() ??
                                "",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textDesc,
                            inter: false,
                            maxline: 3,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                      /*profileProvider
                                  .channelFeedList?[feedIndex].descripation ==
                              ""
                          ? const SizedBox.shrink()
                          : Container(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                              width: MediaQuery.of(context).size.width,
                              constraints: BoxConstraints(
                                minHeight: 50,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.3,
                              ),
                              child: ExpandableText(
                                expandOnTextTap: true,
                                collapseOnTextTap: true,
                                style: GoogleFonts.roboto(
                                    fontSize: Dimens.textSmall,
                                    fontStyle: FontStyle.normal,
                                    color: gray,
                                    fontWeight: FontWeight.w400),
                                profileProvider.channelFeedList?[feedIndex]
                                        .descripation
                                        .toString() ??
                                    "",
                                expandText: 'Read More',
                                collapseText: "Read Less",
                                linkColor: colorAccent,
                                maxLines: 5,
                              ),
                            ),*/
                      /*  (profileProvider.channelFeedList?[feedIndex].hastegs !=
                          null &&
                          ((profileProvider.channelFeedList?[feedIndex]
                              .hastegs?.length ??
                              0) >
                              0))
                          ? SizedBox(
                        height: 50,
                        child: ListView.separated(
                          separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                          itemCount: profileProvider
                              .channelFeedList?[feedIndex]
                              .hastegs
                              ?.length ??
                              0,
                          padding:
                          const EdgeInsets.fromLTRB(10, 10, 0, 15),
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, hashtagIndex) {
                            return Container(
                              alignment: Alignment.center,
                              padding:
                              const EdgeInsets.fromLTRB(12, 3, 12, 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border:
                                Border.all(width: 0.8, color: gray),
                              ),
                              child: MyText(
                                  color: gray,
                                  multilanguage: false,
                                  text:
                                  "# ${profileProvider.channelFeedList?[feedIndex].hastegs?[hashtagIndex]["name"] ?? ""}",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textSmall,
                                  inter: true,
                                  maxline: 10,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            );
                          },
                        ),
                      )
                          : const SizedBox.shrink(),*/
                      postContent(feedIndex),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: MyText(
                                  color: gray,
                                  multilanguage: false,
                                  text: Utils.timeAgoCustom(
                                    DateTime.parse(
                                      profileProvider
                                              .channelFeedList?[feedIndex]
                                              .createdAt
                                              .toString() ??
                                          "",
                                    ),
                                  ),
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textSmall,
                                  inter: true,
                                  maxline: 10,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ),
                            (profileProvider.channelFeedList?[feedIndex].userId
                                        .toString() ==
                                    Constant.userID)
                                ? InkWell(
                                    hoverColor: transparent,
                                    highlightColor: transparent,
                                    splashColor: transparent,
                                    focusColor: transparent,
                                    onTap: () async {
                                      await profileProvider.deletePost(
                                          profileProvider
                                                  .channelFeedList?[feedIndex]
                                                  .id
                                                  .toString() ??
                                              "",
                                          Constant.channelID);
                                      Utils().showSnackBar(
                                          context,
                                          profileProvider
                                                  .successModel.message ??
                                              "",
                                          false);
                                      if (profileProvider.successModel.status ==
                                          200) {
                                        // if (!context.mounted) return;
                                        // Utils().showSnackbar(
                                        //     context,
                                        //     profileProvider
                                        //         .successModel.message ??
                                        //         "",
                                        //     false);
                                        profileProvider.clearChannelFeed();
                                        _fetchChannelFeedData(0);
                                      } else {
                                        if (!context.mounted) return;
                                        Utils().showSnackBar(
                                            context,
                                            profileProvider
                                                    .successModel.message ??
                                                "",
                                            false);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 5, 15, 5),
                                      decoration: BoxDecoration(
                                        color: colorPrimary,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: MyText(
                                          color: colorAccent,
                                          multilanguage: true,
                                          text: "delete",
                                          textalign: TextAlign.left,
                                          fontsizeNormal: Dimens.textMedium,
                                          inter: false,
                                          maxline: 3,
                                          fontwaight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                    ),
                                  )
                                : const SizedBox.shrink()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      } else {
        if (Constant.isCreator != "1" ||
            (Constant.userID !=
                profileProvider.profileModel.result?[0].id.toString())) {
          return const NoData(
              title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
        } else {
          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const UploadFeed(isAppBar: false);
                  },
                ),
              );
            },
            child: Container(
              height: 180,
              width: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade700),
              ),
              child: Center(
                child: Icon(Icons.add, size: 30, color: Colors.grey.shade700),
              ),
            ),
          );
        }
      }
    } else {
      if (Constant.isCreator != "1" ||
          (Constant.userID !=
              profileProvider.profileModel.result?[0].id.toString())) {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      } else {
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const UploadFeed(isAppBar: false);
                },
              ),
            );
          },
          child: Container(
            height: 180,
            width: MediaQuery.of(context).size.width * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade700),
            ),
            child: Center(
              child: Icon(Icons.add, size: 30, color: Colors.grey.shade700),
            ),
          ),
        );
      }
    }
  }

  payPostApi(index) {
    return Center(
      child: Container(
        height: 210,
        width: MediaQuery.of(context).size.width,
        color: black,
        child: Stack(
          children: [
            GestureDetector(
                onTap: () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ResponsiveHelper.isWeb(context)
                              ? const WebLogin()
                              : const Login();
                        },
                      ),
                    );
                  } else {
                    Utils().conformDialog(
                        context,
                        () async {
                          Utils.showProgress(context);
                          SuccessModel video = await ApiService().payVideoPost(
                              Constant.userID ?? '',
                              'post',
                              profileProvider.channelFeedList![index].id ?? 0);
                          if (!mounted) return;
                          Utils().hideProgress(context);
                          if (video.status == 200) {
                            setState(() {
                              Utils().showSnackBar(
                                  context, video.message ?? '', false);
                            });
                            _fetchChannelFeedData(0);
                          } else {
                            Utils().showSnackBar(
                                context, video.message ?? '', false);
                          }
                        },
                        "wanttobuy",
                        () {
                          Navigator.pop(context);
                        });
                  }
                },
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  // adjust blur strength
                  child: MyNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                    imagePath: profileProvider.channelFeedList![index]
                                .postContent?[0].contentType ==
                            1
                        ? (profileProvider.channelFeedList?[index]
                                .postContent?[0].contentUrl
                                .toString() ??
                            "")
                        : (profileProvider.channelFeedList?[index]
                                .postContent?[0].thumbnailImage
                                .toString() ??
                            ""),
                  ),
                )),
            // 🔹 Pay button overlay (bottom left)
            Positioned(
              bottom: 12,
              left: 12,
              child: GestureDetector(
                onTap: () async {
                  Utils().conformDialog(
                      context,
                      () async {
                        Utils.showProgress(context);
                        SuccessModel video = await ApiService().payVideoPost(
                            Constant.userID ?? '',
                            'post',
                            profileProvider.channelFeedList![index].id ?? 0);
                        if (!mounted) return;
                        Utils().hideProgress(context);
                        if (video.status == 200) {
                          setState(() {
                            Utils().showSnackBar(
                                context, video.message ?? '', false);
                          });
                          _fetchChannelFeedData(0);
                        } else {
                          Utils().showSnackBar(
                              context, video.message ?? '', false);
                        }
                      },
                      "wanttobuy",
                      () {
                        Navigator.pop(context);
                      });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54, // semi-transparent bg for visibility
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        multilanguage: false,
                        color: pureWhite,
                        fontwaight: FontWeight.w600,
                        text: "Pay ",
                      ),
                      MyImage(
                        width: 18,
                        height: 18,
                        imagePath: "ic_coin.png",
                      ),
                      MyText(
                        multilanguage: false,
                        color: pureWhite,
                        fontwaight: FontWeight.w600,
                        text:
                            " ${profileProvider.channelFeedList![index].payCoin} to view",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            profileProvider
                        .channelFeedList?[index].postContent?[0].contentType ==
                    1
                ? const SizedBox.shrink()
                : Positioned.fill(
                    child: Align(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: white,
                        size: 35,
                      ),
                    ),
                  ),
            Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: black.withOpacity(0.7)),
                  child: MyImage(
                    width: 20,
                    height: 20,
                    imagePath: 'ic_shorts.png',
                    color: white,
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget rentVideo() {
    if (profileProvider.getUserRentContentModel.status == 200 &&
        profileProvider.rentContentList != null) {
      if ((profileProvider.rentContentList?.length ?? 0) > 0) {
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
                  profileProvider.rentContentList?.length ?? 0, (index) {
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
                      videoId: profileProvider.rentContentList?[index].id
                              .toString() ??
                          "",
                      videoUrl: profileProvider.rentContentList?[index].content
                              .toString() ??
                          "",
                      vUploadType: profileProvider
                              .rentContentList?[index].contentUploadType
                              .toString() ??
                          "",
                      videoThumb: profileProvider
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
                                  imagePath: profileProvider
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
                                          "${Constant.currencySymbol} ${profileProvider.rentContentList?[index].rentPrice.toString() ?? ""}",
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
                              text: profileProvider
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

  Widget profileNoData() {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: colorPrimaryDark,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            hoverColor: transparent,
                            highlightColor: transparent,
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Utils.backIcon(),
                          ),
                          const SizedBox(width: 15),
                          MyText(
                              color: white,
                              text: "myprofile",
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textBig,
                              fontsizeWeb: Dimens.textBig,
                              multilanguage: true,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      ),
                    ),
                    widget.isProfile == false
                        ? InkWell(
                            hoverColor: transparent,
                            highlightColor: transparent,
                            onTap: () {
                              // showMenu(
                              //   context: context,
                              //   position:
                              //       const RelativeRect.fromLTRB(100, 100, 0, 0),
                              //   items: <PopupMenuEntry>[
                              //     PopupMenuItem(
                              //       onTap: () async {},
                              //       value: 'item1',
                              //       child: settingProvider.profileModel
                              //                   .result?[0].isBlock ==
                              //               0
                              //           ? MyText(
                              //               color: appbgcolorDark,
                              //               text: "blockuser",
                              //               textalign: TextAlign.center,
                              //               fontsize: Dimens.textTitle,
                              //               multilanguage: true,
                              //               inter: false,
                              //               maxline: 1,
                              //               fontwaight: FontWeight.w500,
                              //               overflow: TextOverflow.ellipsis,
                              //               fontstyle: FontStyle.normal)
                              //           : MyText(
                              //               color: appbgcolorDark,
                              //               text: "removeblockuser",
                              //               textalign: TextAlign.center,
                              //               fontsize: Dimens.textTitle,
                              //               multilanguage: true,
                              //               inter: false,
                              //               maxline: 1,
                              //               fontwaight: FontWeight.w500,
                              //               overflow: TextOverflow.ellipsis,
                              //               fontstyle: FontStyle.normal),
                              //     ),
                              //   ],
                              // );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyImage(
                                  width: 15,
                                  height: 15,
                                  imagePath: "ic_more.png"),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 15),
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: colorPrimary),
                              borderRadius: BorderRadius.circular(60)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: MyImage(
                              width: 90,
                              height: 90,
                              fit: BoxFit.fill,
                              color: colorPrimary,
                              imagePath: "ic_user.png",
                            ),
                          ),
                        ),
                        widget.isProfile == true
                            ? Positioned.fill(
                                bottom: 3,
                                right: 3,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: InkWell(
                                    hoverColor: transparent,
                                    highlightColor: transparent,
                                    onTap: () {
                                      if (Utils.checkLoginUser(context)) {
                                        Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                  builder: (_) => UpdateProfile(
                                                      channelid:
                                                          Constant.channelID ??
                                                              "")),
                                            )
                                            .then(
                                                (val) => val ? getApi() : null);
                                      }
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colorPrimary),
                                      child: Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MyText(
                        color: colorPrimary,
                        text: "Guest User",
                        multilanguage: false,
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textTitle,
                        fontsizeWeb: Dimens.textTitle,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                            color: white,
                            text: "0",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textSmall,
                            fontsizeWeb: Dimens.textSmall,
                            multilanguage: false,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: white,
                            text: "subscriber",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textSmall,
                            fontsizeWeb: Dimens.textSmall,
                            multilanguage: true,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: white,
                            text: "0",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textSmall,
                            fontsizeWeb: Dimens.textSmall,
                            inter: false,
                            maxline: 1,
                            multilanguage: false,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: white,
                            text: "content",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textSmall,
                            fontsizeWeb: Dimens.textSmall,
                            inter: false,
                            maxline: 1,
                            multilanguage: true,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  buildUpdateProfileDialog(List<profile.Result>? profileData) {
    return showDialog(
      context: context,
      barrierColor: black.withOpacity(0.7),
      // keep transparent so we see custom background
      builder: (context) {
        return Stack(
          children: [
            // Custom background
            /* Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),*/
            // Your dialog
            Center(
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                backgroundColor: colorPrimaryDark,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(
                    minWidth: 400,
                    maxWidth: 500,
                    minHeight: 500,
                    maxHeight: 550,
                  ),
                  child: UpdateProfile(channelid: Constant.channelID ?? ""),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  buildRequestCreatorDialog(List<profile.Result>? profileData) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: black.withOpacity(0.7),
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 115, vertical: 70),
          backgroundColor: colorPrimaryDark,
          child: Stack(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: colorPrimaryDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RequestCreator(
                  email: profileData?[0].email ?? '',
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: white.withOpacity(0.3), shape: BoxShape.circle),
                    child: const Icon(
                      Icons.close,
                      size: 23,
                      color: Colors.white, // or any color that suits your theme
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildCreatePostDialog(String type) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: transparent,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 115, vertical: 70),
          backgroundColor: colorPrimaryDark,
          child: Stack(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: colorPrimaryDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: type == "video"
                    ? const CreateVideo(isAppBar: false)
                    : type == "podcast"
                        ? const CreatePodcast(isAppBar: false)
                        : type == 'music'
                            ? const CreateMusic(
                                isAppBar: false,
                              )
                            : const UploadFeed(
                                isAppBar: false, fromDialog: true),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: white.withOpacity(0.3), shape: BoxShape.circle),
                    child: const Icon(
                      Icons.close,
                      size: 23,
                      color: Colors.white, // or any color that suits your theme
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget myTextField(
      controller, textInputAction, keyboardType, labletext, isMobile) {
    return SizedBox(
      height: 55,
      child: isMobile == false
          ? TextFormField(
              textAlign: TextAlign.left,
              obscureText: false,
              keyboardType: keyboardType,
              controller: controller,
              textInputAction: textInputAction,
              cursorColor: white,
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontStyle: FontStyle.normal,
                  color: white,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: labletext,
                labelStyle: GoogleFonts.montserrat(
                    fontSize: Dimens.textMedium,
                    fontStyle: FontStyle.normal,
                    color: colorPrimary,
                    fontWeight: FontWeight.w500),
                contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: white, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: white, width: 1.5),
                ),
              ),
            )
          : IntlPhoneField(
              disableLengthCheck: true,
              textAlignVertical: TextAlignVertical.center,
              autovalidateMode: AutovalidateMode.disabled,
              controller: controller,
              style: Utils.googleFontStyle(4, Dimens.textMedium,
                  FontStyle.normal, white, FontWeight.w500),
              showCountryFlag: false,
              showDropdownIcon: false,
              initialCountryCode: Constant.initialCountryCode,
              dropdownTextStyle: Utils.googleFontStyle(4, Dimens.textMedium,
                  FontStyle.normal, white, FontWeight.w500),
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              decoration: InputDecoration(
                labelText: labletext,
                fillColor: transparent,
                border: InputBorder.none,
                labelStyle: Utils.googleFontStyle(4, Dimens.textMedium,
                    FontStyle.normal, colorPrimary, FontWeight.w500),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: white, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: white, width: 1),
                ),
              ),
              onChanged: (phone) {
                mobilenumber = phone.number;
                countryname = phone.countryISOCode;
                countrycode = phone.countryCode;
                log('mobile number==> $mobilenumber');
                log('countryCode number==> $countryname');
                log('countryISOCode==> $countrycode');
              },
              onCountryChanged: (country) {
                countryname = country.code.replaceAll('+', '');
                countrycode = "+${country.dialCode.toString()}";
                log('countryname===> $countryname');
                log('countrycode===> $countrycode');
              },
            ),
    );
  }

  Widget space(double space) {
    return SizedBox(height: MediaQuery.of(context).size.height * space);
  }

  Widget updateProfileButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          hoverColor: transparent,
          highlightColor: transparent,
          radius: 15,
          borderRadius: BorderRadius.circular(15),
          autofocus: false,
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: BoxDecoration(
              color: colorPrimaryDark,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: colorPrimary.withOpacity(0.40),
                  blurRadius: 10.0,
                  spreadRadius: 0.5,
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
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
          ),
        ),
        const SizedBox(width: 25),
        InkWell(
          hoverColor: transparent,
          highlightColor: transparent,
          radius: 15,
          borderRadius: BorderRadius.circular(15),
          onTap: () async {
            final updateprofileProvider =
                Provider.of<UpdateprofileProvider>(context, listen: false);

            String fullname = nameController.text.toString();
            String channelName = channelNameController.text.toString();
            String description = descriptionController.text.toString();
            String email = emailController.text.toString();
            int liveAmount = int.parse(liveAmtController.text.toString());

            Utils.showProgress(context);

            await updateprofileProvider.getupdateprofile(
                Constant.userID.toString(),
                fullname,
                channelName,
                email,
                description,
                mobilenumber,
                countrycode,
                channelName,
                File(""),
                File(""),
                liveAmount,
                liveAmount,
                liveAmount,
                liveAmount);

            if (updateprofileProvider.loading) {
              if (!mounted) return;
              Utils.showProgress(context);
            } else {
              if (updateprofileProvider.updateprofileModel.status == 200) {
                if (!mounted) return;
                Utils().showSnackBar(
                    context,
                    "${updateprofileProvider.updateprofileModel.status}",
                    false);
                if (!mounted) return;
                Utils().hideProgress(context);
                getApi();
                Navigator.pop(context);
              } else {
                if (!mounted) return;
                Utils().showSnackBar(
                    context,
                    "${updateprofileProvider.updateprofileModel.status}",
                    false);
                Utils().hideProgress(context);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: BoxDecoration(
              color: colorPrimary,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: colorPrimary.withOpacity(0.40),
                  blurRadius: 10.0,
                  spreadRadius: 0.5,
                )
              ],
            ),
            child: MyText(
                color: white,
                multilanguage: true,
                text: "update",
                textalign: TextAlign.left,
                fontsizeNormal: Dimens.textBig,
                fontsizeWeb: Dimens.textBig,
                maxline: 1,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
          ),
        ),
      ],
    );
  }
}
