import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fanbae/pages/chatpage.dart';
import 'package:fanbae/pages/contentdetail.dart';
import 'package:fanbae/model/getcontentbychannelmodel.dart' as channelcontent;
import 'package:fanbae/music/musicdetails.dart';
import 'package:fanbae/pages/createmusic.dart';
import 'package:fanbae/pages/createpodcast.dart';
import 'package:fanbae/pages/detail.dart';
import 'package:fanbae/pages/requestcreator.dart';
import 'package:fanbae/pages/setting.dart';
import 'package:fanbae/pages/showpostcontent.dart';
import 'package:fanbae/pages/shorts.dart';
import 'package:fanbae/pages/updateprofile.dart';
import 'package:fanbae/pages/uploadfeed.dart';
import 'package:fanbae/pages/viewmembershipplan.dart';
import 'package:fanbae/pages/viewratings.dart';
import 'package:fanbae/provider/feedprovider.dart';
import 'package:fanbae/subscription/adspackage.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/widget/customappbar.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/provider/profileprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../livestream/golivepreview.dart';
import '../model/getcontentbychannelmodel.dart';
import '../model/profilemodel.dart' as profile;
import '../model/successmodel.dart';
import '../players/video_player_screen.dart';
import '../provider/contentdetailprovider.dart';
import '../provider/musicdetailprovider.dart';
import '../utils/musicmanager.dart';
import '../utils/responsive_helper.dart';
import '../video_audio_call/ScheduleCall.dart';
import '../videorecord/createreels.dart';
import '../webpages/weblogin.dart';
import '../webpages/webprofile.dart';
import 'createvideo.dart';
import 'followers.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  final bool isProfile;
  final String channelUserid;
  final String channelid;

  const Profile(
      {super.key,
      required this.isProfile,
      required this.channelUserid,
      required this.channelid});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late ProfileProvider profileProvider;
  double _rating = 1.0;
  final TextEditingController _messageController = TextEditingController();
  late ContentDetailProvider contentDetailProvider;
  final playlistTitleController = TextEditingController();
  final MusicManager musicManager = MusicManager();

  ImagePicker picker = ImagePicker();
  XFile? frontimage;
  late ScrollController _scrollController;

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    contentDetailProvider =
        Provider.of<ContentDetailProvider>(context, listen: false);
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

  reloadApi(contentType) {
    getApi();
    if (widget.isProfile == true) {
      _fetchData(0, contentType, Constant.userID, Constant.channelID);
    } else {
      _fetchData(0, contentType, widget.channelUserid, widget.channelid);
    }
  }

  getApi() async {
    await profileProvider.getprofile(context,
        widget.isProfile == true ? Constant.userID : widget.channelUserid);
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
        // } else if (profileProvider.position == 1) {
        //   getTabData(profileProvider.currentPage ?? 0, "2");
        // } else if (profileProvider.position == 2) {
        //   getTabData(profileProvider.currentPage ?? 0, "4");
        // } else if (profileProvider.position == 3) {
        //   getTabData(profileProvider.currentPage ?? 0, "5");
      } else if (profileProvider.position == 1) {
        getTabData(profileProvider.currentPage ?? 0, "3");
      } else if (profileProvider.position == 2) {
        getTabData(profileProvider.currentPage ?? 0, "7");
      } else if (profileProvider.position == 3) {
        _fetchChannelFeedData(profileProvider.channelcurrentPage ?? 0);
        // } else if (profileProvider.position == 6) {
        //   getTabData(profileProvider.currentPage ?? 0, "7");
        //_fetchRentData(profileProvider.rentcurrentPage ?? 0);
      } else {
        printLog("Something Went Wrong!!!");
      }
    }
  }

  Future<void> getTabData(pageNo, contenttype) async {
    if ((widget.isProfile == true) ||
        (widget.channelUserid == Constant.userID)) {
      _fetchData(pageNo, contenttype, Constant.userID, Constant.channelID);
    } else {
      _fetchData(pageNo, contenttype, widget.channelUserid, widget.channelid);
    }
  }

  Future<void> _fetchData(int? nextPage, contenttype, userid, channelid) async {
    printLog("nextpage   ======> $nextPage");
    await profileProvider.getcontentbyChannel(
        userid, channelid, contenttype, (nextPage ?? 0) + 1);
    await profileProvider.setLoadMore(false);
  }

  Future<void> _fetchRentData(int? nextPage) async {
    printLog("nextpage   ======> $nextPage");
    await profileProvider.getUserbyRentContent(
        widget.isProfile == true ? Constant.userID : widget.channelUserid,
        (nextPage ?? 0) + 1);
    await profileProvider.setLoadMore(false);
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

  _showRatingDialog(profile.ProfileModel profile) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: "Rate ${profile.result?[0].fullName}",
                      multilanguage: false,
                      color: white,
                      fontsizeNormal: 16,
                      fontwaight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 10,
                      itemSize: 23,
                      unratedColor: white.withOpacity(0.6),
                      itemPadding: const EdgeInsets.only(right: 2),
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
                      fontsizeNormal: 15,
                      color: white,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _messageController,
                      style: TextStyle(color: white, fontSize: 13),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Enter your message",
                        hintStyle: TextStyle(color: white, fontSize: 12),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
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
                            color: textColor,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: textColor,
                            foregroundColor: black,
                          ),
                          onPressed: () async {
                            Utils.showProgress(context);

                            try {
                              final rating = await ApiService().ratingCreator(
                                _rating,
                                _messageController.text,
                                Constant.userID ?? '',
                                profile.result?[0].id.toString() ?? '',
                              );
                              // widget might have been disposed while awaiting — bail out if so
                              if (!mounted) return;

                              Utils().hideProgress(context);
                              if (mounted) {
                                Utils().showSnackBar(
                                    context, "${rating.message}", false);
                              }
                              if (rating.status == 200) {
                                Navigator.pop(context);
                                setState(() {
                                  getApi();
                                });
                              }
                            } catch (e, st) {
                              if (mounted) {
                                Utils().hideProgress(context);
                                Utils().showSnackBar(
                                    context, "Something went wrong", true);
                              }
                            }
                          },
                          child: MyText(
                            text: "submit",
                            fontwaight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    profileProvider.clearProvider();
    profileProvider.fetchMyProfile(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: white,
          ),
        ),
        title: MyText(
          text: "profile",
          color: white,
        ),
        backgroundColor: appBarColor,
      ),
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
            // } else if (profileProvider.position == 1) {
            //   profileProvider.clearListData();
            //   await getTabData(0, "2");
            // } else if (profileProvider.position == 2) {
            //   profileProvider.clearListData();
            //   await getTabData(0, "4");
            // } else if (profileProvider.position == 3) {
            //   profileProvider.clearListData();
            //   await getTabData(0, "5");
          } else if (profileProvider.position == 1) {
            profileProvider.clearListData();
            await getTabData(0, "3");
          } else if (profileProvider.position == 2) {
            profileProvider.clearListData();
            await getTabData(0, "7");
          } else if (profileProvider.position == 3) {
            await _fetchChannelFeedData(0);
            // } else if (profileProvider.position == 6) {
            //   profileProvider.clearListData();
            //   await getTabData(0, "7");
          } else {
            profileProvider.clearListData();
          }
          return;
        },
        child: Utils().pageBg(
          context,
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    buildProfile(),
                    buildTab(),
                    buildTabItem(),
                  ],
                ),
              ),
              Utils.musicAndAdsPanel(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfile() {
    return Consumer<ProfileProvider>(
        builder: (context, settingProvider, child) {
      if (settingProvider.profileloading) {
        return buildProfileShimmer();
      } else {
        if (settingProvider.profileModel.status == 200 &&
            settingProvider.profileModel.result != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    settingProvider.profileModel.result?[0].isCreator == 1
                        ? Align(
                            alignment: Alignment.center,
                            child: MyImage(
                                width: 50,
                                height: 30,
                                fit: BoxFit.cover,
                                color: colorPrimary,
                                imagePath: "crown.png"),
                          )
                        : const SizedBox.shrink(),
                    Stack(
                      children: [
                        SizedBox(
                          height: 92,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              widget.isProfile == false &&
                                      widget.channelUserid != Constant.userID
                                  ? const SizedBox()
                                  : GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return const AdsPackage();
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 35,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: BoxDecoration(
                                          gradient: Constant.gradientColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            MyImage(
                                                width: 22,
                                                height: 22,
                                                imagePath: "ic_coin.png"),
                                            const SizedBox(width: 5),
                                            Consumer<ProfileProvider>(
                                              builder: (context,
                                                  settingProvider, _) {
                                                return MyText(
                                                  color: pureBlack,
                                                  multilanguage: false,
                                                  text: Utils.kmbGenerator(
                                                    settingProvider
                                                            .profileModel
                                                            .result?[0]
                                                            .walletBalance ??
                                                        0,
                                                  ),
                                                  textalign: TextAlign.center,
                                                  fontsizeNormal:
                                                      Dimens.textMedium,
                                                  inter: true,
                                                  maxline: 1,
                                                  fontwaight: FontWeight.w700,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              Row(
                                children: [
                                  widget.isProfile == false &&
                                          widget.channelUserid !=
                                              Constant.userID
                                      ? const SizedBox()
                                      : GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    const Setting(),
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  var curve = Curves.easeInOut;

                                                  var slideTween =
                                                      Tween<Offset>(
                                                              begin:
                                                                  const Offset(
                                                                      1.0, 0.0),
                                                              end: Offset.zero)
                                                          .chain(CurveTween(
                                                              curve: curve));
                                                  var fadeTween = Tween<double>(
                                                          begin: 0.0, end: 1.0)
                                                      .chain(CurveTween(
                                                          curve: curve));

                                                  // Apply both animations using SlideTransition and FadeTransition
                                                  return Constant.userID != null
                                                      ? SlideTransition(
                                                          position:
                                                              animation.drive(
                                                                  slideTween),
                                                          child: FadeTransition(
                                                            opacity:
                                                                animation.drive(
                                                                    fadeTween),
                                                            child: child,
                                                          ),
                                                        )
                                                      : child;
                                                },
                                                transitionDuration: const Duration(
                                                    milliseconds:
                                                        500), // Smooth transition speed
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              gradient: Constant.gradientColor,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Icon(
                                              Icons.menu,
                                              color: pureBlack,
                                              size: 17,
                                            ),
                                          )),
                                  widget.isProfile == false &&
                                          widget.channelUserid !=
                                              Constant.userID
                                      ? InkWell(
                                          focusColor: transparent,
                                          splashColor: transparent,
                                          highlightColor: transparent,
                                          hoverColor: transparent,
                                          onTap: () {
                                            if (widget.isProfile == false &&
                                                widget.channelUserid !=
                                                    Constant.userID) {
                                              showMenu(
                                                context: context,
                                                position:
                                                    const RelativeRect.fromLTRB(
                                                        100, 100, 0, 0),
                                                items: <PopupMenuEntry>[
                                                  PopupMenuItem(
                                                    onTap: () async {
                                                      await profileProvider
                                                          .addremoveBlockChannel(
                                                              settingProvider
                                                                      .profileModel
                                                                      .result?[
                                                                          0]
                                                                      .id
                                                                      .toString() ??
                                                                  "",
                                                              settingProvider
                                                                      .profileModel
                                                                      .result?[
                                                                          0]
                                                                      .channelId
                                                                      .toString() ??
                                                                  "");
                                                    },
                                                    value: 'item1',
                                                    child: settingProvider
                                                                .profileModel
                                                                .result?[0]
                                                                .isBlock ==
                                                            0
                                                        ? MyText(
                                                            color: Constant.darkMode ==
                                                                    "true"
                                                                ? colorPrimaryDark
                                                                : Colors.black,
                                                            text: "blockuser",
                                                            textalign: TextAlign
                                                                .center,
                                                            fontsizeNormal: Dimens
                                                                .textTitle,
                                                            multilanguage: true,
                                                            inter: false,
                                                            maxline: 1,
                                                            fontwaight:
                                                                FontWeight.w500,
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            fontstyle: FontStyle
                                                                .normal)
                                                        : MyText(
                                                            color: Constant.darkMode ==
                                                                    "true"
                                                                ? colorPrimaryDark
                                                                : Colors.black,
                                                            text:
                                                                "removeblockuser",
                                                            textalign: TextAlign
                                                                .center,
                                                            fontsizeNormal: Dimens
                                                                .textTitle,
                                                            multilanguage: true,
                                                            inter: false,
                                                            maxline: 1,
                                                            fontwaight:
                                                                FontWeight.w500,
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            fontstyle:
                                                                FontStyle.normal),
                                                  ),
                                                  if (settingProvider
                                                          .profileModel
                                                          .result?[0]
                                                          .isReviewed ==
                                                      0)
                                                    PopupMenuItem(
                                                      onTap: () async {
                                                        _showRatingDialog(
                                                            settingProvider
                                                                .profileModel);
                                                      },
                                                      value: 'item2',
                                                      child: MyText(
                                                          color: Constant
                                                                      .darkMode ==
                                                                  "true"
                                                              ? colorPrimaryDark
                                                              : Colors.black,
                                                          text: "giverating",
                                                          textalign:
                                                              TextAlign.center,
                                                          fontsizeNormal:
                                                              Dimens.textTitle,
                                                          multilanguage: true,
                                                          inter: false,
                                                          maxline: 1,
                                                          fontwaight:
                                                              FontWeight.w500,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontstyle:
                                                              FontStyle.normal),
                                                    ),
                                                  PopupMenuItem(
                                                    onTap: () async {
                                                      await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return ChatPage(
                                                              otherUserId: widget
                                                                  .channelUserid,
                                                              otherUserName: settingProvider
                                                                      .profileModel
                                                                      .result?[
                                                                          0]
                                                                      .fullName ??
                                                                  '',
                                                              otherUserPic: settingProvider
                                                                      .profileModel
                                                                      .result?[
                                                                          0]
                                                                      .image ??
                                                                  '',
                                                              creatorId: '',
                                                            );
                                                          },
                                                        ),
                                                      );
                                                      setState(() {
                                                        getApi();
                                                      });
                                                    },
                                                    value: 'item3',
                                                    child: MyText(
                                                        color: Constant
                                                                    .darkMode ==
                                                                "true"
                                                            ? colorPrimaryDark
                                                            : Colors.black,
                                                        text: "chat",
                                                        textalign:
                                                            TextAlign.center,
                                                        fontsizeNormal:
                                                            Dimens.textTitle,
                                                        multilanguage: true,
                                                        inter: false,
                                                        maxline: 1,
                                                        fontwaight:
                                                            FontWeight.w500,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontstyle:
                                                            FontStyle.normal),
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              gradient: Constant.gradientColor,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: MyImage(
                                                width: 13.4,
                                                height: 13.4,
                                                color: black,
                                                imagePath: "ic_more.png"),
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 87, // Outer size
                                    height: 87,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: Constant.sweepGradient,
                                    ),
                                  ),
                                  Container(
                                    width: 82,
                                    height: 82,
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
                                                settingProvider
                                                        .profileModel.result !=
                                                    null)
                                            ? (settingProvider.profileModel
                                                    .result?[0].image
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
                                            Navigator.of(context)
                                                .push(
                                                  MaterialPageRoute(
                                                      builder: (_) => UpdateProfile(
                                                          channelid: Constant
                                                                  .channelID ??
                                                              "")),
                                                )
                                                .then((val) =>
                                                    val ? getApi() : null);
                                          },
                                          child: Container(
                                            width: 27,
                                            height: 27,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient:
                                                    Constant.gradientColor),
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                                fontsizeNormal: Dimens.textBig,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w700,
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
                                fontsizeNormal: Dimens.textBig,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                        const SizedBox(height: 2.5),
                        settingProvider.profileModel.result?[0].fullName == ""
                            ? MyText(
                                color: white,
                                text: settingProvider
                                        .profileModel.result?[0].fullName
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
                                        .profileModel.result?[0].fullName
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
                            GestureDetector(
                              onTap: () {
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const Followers();
                                      },
                                    ),
                                  );
                                }
                              },
                              child: Column(
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
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
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
                                }
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
                                              index != 0
                                                  ? Navigator.push(
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
                                                                  )))
                                                  : Navigator.push(
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
                                                    );
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

  Widget buildProfileShimmer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomWidget.circular(
            height: 90,
            width: 90,
          ),
          SizedBox(height: 5),
          CustomWidget.roundrectborder(
            width: 100,
            height: 8,
          ),
          SizedBox(height: 5),
          CustomWidget.roundrectborder(
            width: 80,
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget buildTab() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
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
                            /* Music */
                            // } else if (profileprovider.position == 1) {
                            //   getTabData(0, "2");
                            //   profileprovider.clearListData();
                            /* Podcast */
                            // } else if (profileprovider.position == 2) {
                            //   getTabData(0, "4");
                            //   profileprovider.clearListData();
                            /* Playlist */
                            // } else if (profileprovider.position == 3) {
                            //   getTabData(0, "5");
                            //   profileprovider.clearListData();
                            /* Short */
                          } else if (profileprovider.position == 1) {
                            getTabData(0, "3");
                            profileprovider.clearListData();
                            /* Live */
                          } else if (profileprovider.position == 2) {
                            getTabData(0, "7");
                            profileprovider.clearListData();
                            /* Feeds */
                          } else if (profileprovider.position == 3) {
                            _fetchChannelFeedData(0);
                            // } else if (profileprovider.position == 6) {
                            //   getTabData(0, "7");
                            //   profileprovider.clearListData();
                            /* Feeds */
                          }
                          /*else if (profileprovider.position == 6) {
                            _fetchRentData(0);
                            profileprovider.clearListData();
                            */ /* Other Page  */ /*
                          }*/
                          else {
                            profileprovider.clearListData();
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: const EdgeInsets.only(right: 7),
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
        // } else if (profileprovider.position == 1) {
        //   return buildMusic();
        // } else if (profileprovider.position == 2) {
        //   return buildPadcast();
        // } else if (profileprovider.position == 3) {
        //   return buildPlaylist();
      } else if (profileprovider.position == 1) {
        return buildReels();
      } else if (profileprovider.position == 2) {
        print("buildLive");
        return buildLive();
      } else if (profileprovider.position == 3) {
        return buildFeed();
        // } else if (profileprovider.position == 5) {
        //   return buildRentVideo();
        // } else if (profileprovider.position == 6) {
        //   print("buildLive");
        //   return buildLive();
      } else {
        return const SizedBox.shrink();
      }
    });
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
    final profileProvider = Provider.of<ProfileProvider>(context, listen: true);

    // ✅ Common checks for creator and owner
    final bool isOwner = Constant.userID ==
        profileProvider.profileModel.result?[0].id.toString();
    final bool isCreator = Constant.isCreator == '1';
    final bool hasVideos =
        (profileProvider.channelContentList?.length ?? 0) > 0;

    // ✅ When API succeeded
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if (hasVideos) {
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
              // ✅ Generate tiles
              children: List.generate(
                isOwner
                    ? (profileProvider.channelContentList!.length + 1)
                    : (profileProvider.channelContentList!.length),
                (index) {
                  // Show "Add" tile for creator's own profile
                  if (isOwner && isCreator && index == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateVideo(),
                            ),
                          );
                          setState(() {
                            reloadApi("1");
                          });
                        },
                        child: SizedBox(
                          height: 140,
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

                  // Adjust index safely
                  final adjustedIndex = isOwner ? index - 1 : index;
                  if (adjustedIndex < 0 ||
                      adjustedIndex >=
                          (profileProvider.channelContentList?.length ?? 0)) {
                    return const SizedBox.shrink();
                  }

                  final item =
                      profileProvider.channelContentList![adjustedIndex];

                  // ✅ Each video tile
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: InkWell(
                      onTap: () {
                        Utils.moveToDetail(
                          context,
                          0,
                          false,
                          item.id.toString(),
                          false,
                          '1',
                          item.isComment,
                        );
                      },
                      child: SizedBox(
                        height: 140,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MyNetworkImage(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                                imagePath: item.portraitImg.toString(),
                              ),
                            ),
                            if (Constant.userID ==
                                    profileProvider.profileModel.result?[0].id
                                        .toString() &&
                                profileProvider
                                        .channelContentList?[adjustedIndex]
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
                                  width: 25,
                                  height: 25,
                                  imagePath: "pause.png"),
                            ),
                            // Delete Loader or Delete Button
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
                                              item.contentType.toString(),
                                              item.id.toString(),
                                              "0",
                                            );
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
                                                pureWhite.withOpacity(0.9),
                                            child: MyImage(
                                              width: 12,
                                              height: 12,
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
                    ),
                  );
                },
              ),
            ),
          ),
        );
      } else {
        // ✅ No videos found
        if (!isCreator || !isOwner) {
          return const NoData(
              title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
        } else {
          return Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateVideo()),
                );
                setState(() {
                  reloadApi("1");
                });
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 140,
                  width: 125,
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
      // ✅ API failed or still loading
      if (!isCreator || !isOwner) {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      } else {
        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateVideo()),
              );
              setState(() {
                reloadApi("1");
              });
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 140,
                width: 125,
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

  Widget videoShimmer() {
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
          children: List.generate(10, (index) {
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
                  SizedBox(height: 8),
                  CustomWidget.roundrectborder(
                    width: 80,
                    height: 6,
                  ),
                  CustomWidget.roundrectborder(
                    width: 80,
                    height: 6,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
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

  Widget buildPadcast() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return padcastShimmer();
      } else {
        print(
            "profile :${profileprovider.profileModel.result?[0].packageName}");
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
              minItemsPerRow: 2,
              maxItemsPerRow: ResponsiveHelper.isTab(context) ? 3 : 2,
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
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const CreatePodcast();
                          },
                        ),
                      );
                      setState(() {
                        reloadApi("4");
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: ResponsiveHelper.isTab(context) ? 140 : 125,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ContentDetail(
                            contentType: content.contentType.toString() ?? "",
                            contentImage: content.portraitImg.toString() ?? "",
                            contentName: content.title.toString() ?? "",
                            contentUserid: "",
                            contentId: content.id.toString() ?? "",
                            playlistImage: content.playlistImage,
                            isBuy: content.isBuy.toString() ?? "",
                          );
                        },
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: ResponsiveHelper.isTab(context) ? 140 : 125,
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const CreatePodcast();
                    },
                  ),
                );
                setState(() {
                  reloadApi("4");
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
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const CreatePodcast();
                  },
                ),
              );
              setState(() {
                reloadApi("4");
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

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
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
              minItemsPerRow: 2,
              maxItemsPerRow: 2,
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
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const CreateMusic();
                          },
                        ),
                      );
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const CreateMusic();
                    },
                  ),
                );
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
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const CreateMusic();
                  },
                ),
              );
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

  Widget padcastShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 2,
          maxItemsPerRow: 2,
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
                  height: 100,
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
            width: MediaQuery.of(context).size.width * 0.90,
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
              minItemsPerRow: 2,
              maxItemsPerRow: ResponsiveHelper.isTab(context) ? 3 : 2,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                multilanguage: false,
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
          minItemsPerRow: 2,
          maxItemsPerRow: 2,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(6, (index) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.rectangular(height: 150, width: 160),
                  SizedBox(height: 10),
                  CustomWidget.rectangular(height: 5, width: 160),
                  SizedBox(height: 5),
                  CustomWidget.rectangular(height: 5, width: 160),
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
              minItemsPerRow: 3,
              maxItemsPerRow: 3,
              horizontalGridSpacing: 15,
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
                if (!ResponsiveHelper.isWeb(context)) {
                  if (Constant.userID ==
                      profileProvider.profileModel.result?[0].id.toString()) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 34),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const CreateReels();
                                },
                              ),
                            );
                            setState(() {
                              reloadApi("3");
                            });
                          },
                          child: SizedBox(
                            height: 150,
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
                }
                final adjustedIndex =
                    !ResponsiveHelper.isWeb(context) ? index - 1 : index;

                return InkWell(
                  focusColor: transparent,
                  splashColor: transparent,
                  highlightColor: transparent,
                  hoverColor: transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Shorts(
                            channelId: profileProvider
                                    .channelContentList?[Constant.userID ==
                                            profileProvider
                                                .profileModel.result?[0].id
                                                .toString()
                                        ? adjustedIndex
                                        : index]
                                    .channelId
                                    .toString() ??
                                "",
                            userId: profileProvider
                                    .channelContentList?[Constant.userID ==
                                            profileProvider
                                                .profileModel.result?[0].id
                                                .toString()
                                        ? adjustedIndex
                                        : index]
                                    .userId
                                    .toString() ??
                                "",
                            initialIndex: Constant.userID ==
                                    profileProvider.profileModel.result?[0].id
                                        .toString()
                                ? adjustedIndex
                                : index,
                            shortType: "profile",
                          );
                        },
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const CreateReels();
                    },
                  ),
                );
                setState(() {
                  reloadApi("3");
                });
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 140,
                  width: 125,
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
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const CreateReels();
                  },
                ),
              );
              setState(() {
                reloadApi("3");
              });
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 140,
                width: 125,
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

  Widget buildLive() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return reelsShimmer();
      } else {
        return Column(
          children: [
            live(profileprovider),
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

  Widget live(ProfileProvider profileprovider) {
    if (profileprovider.getContentbyChannelModel.status == 200 &&
        profileprovider.channelContentList != null) {
      if ((profileprovider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 2,
              maxItemsPerRow: 2,
              horizontalGridSpacing: 15,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                !ResponsiveHelper.isWeb(context)
                    ? (Constant.userID ==
                            profileprovider.profileModel.result?[0].id
                                .toString()
                        ? (profileprovider.channelContentList?.length ?? 0) + 1
                        : (profileprovider.channelContentList?.length ?? 0))
                    : (profileprovider.channelContentList?.length ?? 0),
                (index) {
                  if (!ResponsiveHelper.isWeb(context)) {
                    if (Constant.userID ==
                        profileprovider.profileModel.result?[0].id.toString()) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 34),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const GoLiveViewPreview();
                                  },
                                ),
                              );
                              setState(() {
                                reloadApi("7");
                              });
                            },
                            child: SizedBox(
                              height: 150,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey.shade700),
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
                  }

                  final adjustedIndex =
                      !ResponsiveHelper.isWeb(context) ? index - 1 : index;

                  final selectedItem = profileprovider
                      .channelContentList?[Constant.userID ==
                          profileprovider.profileModel.result?[0].id.toString()
                      ? adjustedIndex
                      : index];

                  return InkWell(
                    onTap: () {
                      if (selectedItem != null) {
                        if (selectedItem.status == 1) {
                          Utils.moveToDetail(
                            context,
                            0,
                            false,
                            selectedItem.id.toString(),
                            false,
                            '7',
                            selectedItem.isComment,
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
                          height: 150,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MyNetworkImage(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.cover,
                                  imagePath: selectedItem?.portraitImg ?? "",
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                  width: 25,
                                  height: 25,
                                  imagePath: "pause.png",
                                ),
                              ),
                              if (Constant.userID ==
                                  selectedItem?.userId.toString())
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    margin: const EdgeInsets.all(7),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 7),
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        selectedItem?.type == "free"
                                            ? const SizedBox()
                                            : MyImage(
                                                width: 18,
                                                height: 18,
                                                imagePath: 'ic_coin.png'),
                                        selectedItem?.type == "free"
                                            ? const SizedBox()
                                            : const SizedBox(width: 3.5),
                                        MyText(
                                          text: selectedItem?.status == 1
                                              ? 'Public'
                                              : 'Private',
                                          color: black,
                                          fontsizeNormal: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        MyText(
                          color: white,
                          text: selectedItem?.title ?? "",
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
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
          minItemsPerRow: 3,
          maxItemsPerRow: 3,
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
                  height: 150,
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

/* ============================== Feed ============================== */

  Widget buildFeed() {
    if (profileProvider.loading && !profileProvider.channelloadMore) {
      return shimmer();
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        child: Column(
          children: [
            feedItem(),
            const SizedBox(height: 20),
            if (profileProvider.channelloadMore)
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                child: Utils.pageLoader(context),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      );
    }
  }

  Widget feedItem() {
    if (profileProvider.getChannelFeedModel.status == 200 &&
        profileProvider.channelFeedList != null) {
      if ((profileProvider.channelFeedList?.length ?? 0) > 0) {
        return AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: ResponsiveHelper.isTab(context) ? 2 : 1,
          crossAxisSpacing: 0,
          mainAxisSpacing: 10,
          itemCount: Constant.userID ==
                  profileProvider.profileModel.result?[0].id.toString()
              ? (profileProvider.channelFeedList?.length ?? 0) + 1
              : profileProvider.channelFeedList?.length ?? 0,
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
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 23,
                      ),
                      Container(
                        height: 180,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade700),
                        ),
                        child: Center(
                          child: Icon(Icons.add,
                              size: 30, color: Colors.grey.shade700),
                        ),
                      ),
                    ],
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
                  padding: const EdgeInsets.fromLTRB(15, 0, 25, 0),
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
                      (profileProvider.channelFeedList?[feedIndex].hastegs !=
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
                          : const SizedBox.shrink(),
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
                                          color: pureBlack,
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
                feedIndex == (profileProvider.channelFeedList?.length ?? 0) - 1
                    ? const SizedBox.shrink()
                    : Utils.buildGradLine(),
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
              height: 155,
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
            height: 150,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                            description: profileProvider
                                    .channelFeedList?[index].descripation
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
                        Container(
                          color: buttonDisable,
                          child: MyNetworkImage(
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

  Widget shimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 1,
        maxItemsPerRow: 1,
        horizontalGridSpacing: 10,
        verticalGridSpacing: 10,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          5,
          (index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: colorPrimaryDark,
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(width: 1, color: gray),
                            color: colorPrimary),
                        child: const CustomWidget.circular(
                          height: 35,
                          width: 35,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomWidget.roundrectborder(
                              height: 10,
                              width: 150,
                            ),
                            CustomWidget.roundrectborder(
                              height: 10,
                              width: 150,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const CustomWidget.roundcorner(
                        height: 20,
                        width: 80,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 240,
                        child: ListView.separated(
                          separatorBuilder: (context, contentIndex) =>
                              const SizedBox(width: 10),
                          itemCount: 3,
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, contentIndex) {
                            return CustomWidget.roundcorner(
                              width: 160,
                              height: MediaQuery.of(context).size.height,
                            );
                          },
                        ),
                      ),
                      const CustomWidget.roundcorner(
                        height: 10,
                      ),
                      const CustomWidget.roundcorner(
                        height: 10,
                      ),
                      SizedBox(
                        height: 50,
                        child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),
                          itemCount: 5,
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return const CustomWidget.roundcorner(
                              width: 90,
                              height: 25,
                            );
                          },
                        ),
                      ),
                      const CustomWidget.roundcorner(
                        height: 10,
                        width: 100,
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomWidget.circular(
                                  height: 22,
                                  width: 22,
                                ),
                                SizedBox(width: 8),
                                CustomWidget.roundcorner(
                                  height: 22,
                                  width: 22,
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomWidget.circular(
                                  height: 22,
                                  width: 22,
                                ),
                                SizedBox(width: 8),
                                CustomWidget.roundcorner(
                                  height: 22,
                                  width: 22,
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

/* ============================== Feed ============================== */

  Widget buildRentVideo() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return rentVideoShimmer();
      } else {
        return Column(
          children: [
            rentVideo(),
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

  Widget rentVideo() {
    if (profileProvider.getUserRentContentModel.status == 200 &&
        profileProvider.rentContentList != null) {
      if ((profileProvider.rentContentList?.length ?? 0) > 0) {
        return Expanded(
          child: MediaQuery.removePadding(
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
                        videoUrl: profileProvider
                                .rentContentList?[index].content
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
                        height: 150,
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
                        height: 150,
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
                        height: 150,
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
                        height: 150,
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
                        height: 150,
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
          width: 160,
          height: 150,
          child: MyNetworkImage(
            width: 160,
            height: 150,
            fit: BoxFit.cover,
            imagePath: sectionList?[index].playlistImage?[0].toString() ?? "",
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
                        fontsizeNormal: 16,
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
                            fontsizeNormal: 12,
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
                            fontsizeNormal: 12,
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
                            fontsizeNormal: 12,
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
                            fontsizeNormal: 12,
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
}
