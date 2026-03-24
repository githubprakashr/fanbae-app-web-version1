import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fanbae/model/membership_plan_model.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/pages/addmembershipplan.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:intl/intl.dart';

import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/responsive_helper.dart';
import '../utils/utils.dart';
import '../webservice/apiservice.dart';
import '../widget/myimage.dart';

class ViewMembershipPlan extends StatefulWidget {
  final bool isUser;
  final String creatorId;

  const ViewMembershipPlan(
      {super.key, required this.isUser, required this.creatorId});

  @override
  State<ViewMembershipPlan> createState() => _ViewMembershipPlanState();
}

class _ViewMembershipPlanState extends State<ViewMembershipPlan> {
  late MembershipPlanModel membershipPlanModel;
  int? selectedIndex;
  CarouselSliderController pageController = CarouselSliderController();

  bool isLoad = false;

  @override
  void initState() {
    // TODO: implement initState
    getMembershipPlan(context);
    super.initState();
  }

  Future<void> getMembershipPlan(BuildContext context) async {
    setState(() {
      isLoad = true;
    });

    print(widget.isUser);
    print(widget.creatorId);
    membershipPlanModel = await ApiService()
        .getMembershipPlans(widget.creatorId, Constant.userID);
    if (membershipPlanModel.status != 200) {
      Navigator.pop(context);
      Utils().showSnackBar(context, membershipPlanModel.message, false);
    }
    setState(() {
      isLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: AppBar(
        backgroundColor: appbgcolor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: white,
          ),
        ),
        title: MyText(text: "membershipplans", color: white),
        actions: [
          widget.isUser
              ? GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const AddMembershipPlan();
                        },
                      ),
                    );
                    setState(() {
                      getMembershipPlan(context);
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 11),
                    margin: const EdgeInsets.only(right: 15, left: 8),
                    decoration: BoxDecoration(
                        gradient: Constant.gradientColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add,
                          color: pureBlack,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Add",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: black),
                        )
                      ],
                    ),
                  ),
                )
              : const SizedBox()
        ],
      ),
      body: isLoad
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : membershipPlanModel.result.isEmpty
              ? Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMembershipPlan(),
                        ),
                      );
                    },
                    child: MyImage(
                      width:
                          MediaQuery.of(context).size.width > 1200 ? 750 : 350,
                      height:
                          MediaQuery.of(context).size.width > 1200 ? 750 : 750,
                      fit: BoxFit.contain,
                      imagePath: "creator_subscription_no_image.jpeg",
                    ),
                  ),
                )
              : !ResponsiveHelper.isMobile(context)
                  ? buildWebItem(membershipPlanModel.result)
                  : Utils().pageBg(
                      context,
                      child: Column(
                        children: [
                          MyImage(
                              width: 215,
                              height: 150,
                              fit: BoxFit.cover,
                              imagePath: "subscribeimage.png"),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: CarouselSlider.builder(
                              options: CarouselOptions(
                                initialPage: 0,
                                height: MediaQuery.of(context).size.height,
                                enlargeCenterPage:
                                    membershipPlanModel.result.length > 1
                                        ? true
                                        : false,
                                enlargeFactor: kIsWeb &&
                                        !ResponsiveHelper.isMobile(context)
                                    ? 0.30
                                    : 0.40,
                                autoPlay: false,
                                autoPlayCurve: Curves.easeInOutQuart,
                                enableInfiniteScroll: membershipPlanModel
                                            .result.length >
                                        1
                                    ? kIsWeb &&
                                            !ResponsiveHelper.isMobile(context)
                                        ? membershipPlanModel.result.length > 3
                                            ? true
                                            : false
                                        : true
                                    : false,
                                viewportFraction: kIsWeb &&
                                        !ResponsiveHelper.isMobile(context)
                                    ? 0.35
                                    : 0.73,
                              ),
                              itemCount: membershipPlanModel.result.length,
                              itemBuilder: (BuildContext context, int index,
                                  int pageViewIndex) {
                                var membership = membershipPlanModel.result;
                                final isPurchased =
                                    membership[index].planPurchased;
                                final isSelected = selectedIndex == index;
                                final containerColor = index % 3;
                                print("containerColor: ${containerColor}");

                                String formattedDate = '';
                                if (isPurchased &&
                                    membership[index].expireDate != null &&
                                    membership[index].expireDate != '' &&
                                    membership[index].expireDate != '0') {
                                  try {
                                    DateTime dateTime = DateTime.parse(
                                        membership[index].expireDate!);
                                    formattedDate = DateFormat('dd/MM/yyyy')
                                        .format(dateTime);
                                  } catch (e) {
                                    formattedDate = '';

                                    /// fallback if parsing fails
                                  }
                                }
                                return Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: widget.isUser
                                          ? () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return AddMembershipPlan(
                                                      membership:
                                                          membership[index],
                                                    );
                                                  },
                                                ),
                                              );
                                              setState(() {
                                                getMembershipPlan(context);
                                              });
                                            }
                                          : () {
                                              if (!isPurchased) {
                                                setState(() {
                                                  selectedIndex = index;
                                                });
                                              }
                                            },
                                      child: Stack(
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 12.5),
                                                decoration: BoxDecoration(
                                                  gradient: membership[index]
                                                          .planPurchased
                                                      ? Constant
                                                          .sweepGradientpack
                                                      : null,
                                                  color: membership[index]
                                                          .planPurchased
                                                      ? null
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                    gradient: containerColor ==
                                                            0
                                                        ? const LinearGradient(
                                                            colors: [
                                                                Color(
                                                                    0xFF150D26),
                                                                Color(
                                                                    0xFF2C0C53),
                                                                Color(
                                                                    0xFF150F27),
                                                                Color(
                                                                    0xFF591D47),
                                                              ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight)
                                                        : containerColor == 1
                                                            ? const LinearGradient(
                                                                colors: [
                                                                    Color(
                                                                        0xFF150D26),
                                                                    Color(
                                                                        0xFF2C0C53),
                                                                    Color(
                                                                        0xFF150F27),
                                                                    Color(
                                                                        0xFF591D47),
                                                                  ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight)
                                                            : const LinearGradient(
                                                                colors: [
                                                                    Color(
                                                                        0xFF150D26),
                                                                    Color(
                                                                        0xFF2C0C53),
                                                                    Color(
                                                                        0xFF150F27),
                                                                    Color(
                                                                        0xFF591D47),
                                                                  ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 1,
                                                      vertical: 1),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15,
                                                      vertical: 15),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(
                                                        height: 50,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Wrap(
                                                            crossAxisAlignment:
                                                                WrapCrossAlignment
                                                                    .center,
                                                            children: [
                                                              MyText(
                                                                text: membership[
                                                                        index]
                                                                    .name,
                                                                color: white,
                                                                fontsizeNormal:
                                                                    23,
                                                                multilanguage:
                                                                    false,
                                                                fontwaight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      !widget.isUser &&
                                                              isPurchased &&
                                                              formattedDate
                                                                  .isNotEmpty
                                                          ? Center(
                                                              child: MyText(
                                                                color:
                                                                    (isSelected)
                                                                        ? white
                                                                        : white,
                                                                text:
                                                                    'Expires in $formattedDate',
                                                                multilanguage:
                                                                    false,
                                                                fontsizeNormal:
                                                                    11,
                                                                fontwaight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      const SizedBox(height: 3),
                                                      Center(
                                                        child: ShaderMask(
                                                            shaderCallback: (bounds) => containerColor ==
                                                                    0
                                                                ? const LinearGradient(
                                                                        colors: [
                                                                        Color(
                                                                            0xffffca71),
                                                                        Color(
                                                                            0xfffc9b16),
                                                                      ],
                                                                        begin: Alignment
                                                                            .topRight,
                                                                        end: Alignment
                                                                            .bottomRight)
                                                                    .createShader(
                                                                        bounds)
                                                                : containerColor ==
                                                                        1
                                                                    ? const LinearGradient(
                                                                            colors: [
                                                                            Color(0xffffca71),
                                                                            Color(0xfffc9b16),
                                                                          ],
                                                                            begin: Alignment
                                                                                .topCenter,
                                                                            end: Alignment
                                                                                .bottomRight)
                                                                        .createShader(
                                                                            bounds)
                                                                    : const LinearGradient(
                                                                            colors: [
                                                                            Color(0xffffca71),
                                                                            Color(0xfffc9b16),
                                                                          ],
                                                                            begin: Alignment
                                                                                .topRight,
                                                                            end: Alignment
                                                                                .bottomRight)
                                                                        .createShader(
                                                                            bounds),
                                                            blendMode:
                                                                BlendMode.srcIn,
                                                            child: MyImage(
                                                              width: 60,
                                                              height: 60,
                                                              imagePath:
                                                                  "img.png",
                                                            )),
                                                      ),
                                                      const SizedBox(
                                                          height: 15),

                                                      /// ---------- Features + Offer Price ----------
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 30,
                                                                right: 30),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration:
                                                              BoxDecoration(
                                                                  // color: white,
                                                                  gradient: const LinearGradient(
                                                                      colors: [
                                                                        Color(
                                                                            0xFFE67025),
                                                                        Color(
                                                                            0xFFE93276)
                                                                      ],
                                                                      begin: Alignment
                                                                          .topLeft,
                                                                      end: Alignment
                                                                          .bottomRight),
                                                                  border: Border.all(
                                                                      color: const Color(
                                                                          0xFF8F03FF),
                                                                      width:
                                                                          1.5),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30)),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Wrap(
                                                                children: [
                                                                  Text(
                                                                    membership[
                                                                            index]
                                                                        .price
                                                                        .toString(),
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .titleMedium
                                                                        ?.copyWith(
                                                                          color: (isSelected)
                                                                              ? white
                                                                              : white,
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          decoration:
                                                                              TextDecoration.lineThrough,
                                                                          decorationThickness:
                                                                              1.8,
                                                                          decorationColor:
                                                                              Colors.red,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Wrap(
                                                                children: [
                                                                  Text(
                                                                    membership[
                                                                            index]
                                                                        .offerPrice
                                                                        .toString(),
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .titleMedium
                                                                        ?.copyWith(
                                                                          color: (isSelected)
                                                                              ? white
                                                                              : white,
                                                                          fontSize:
                                                                              23,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              MyImage(
                                                                width: 35,
                                                                height: 35,
                                                                imagePath:
                                                                    "coin.png",
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 14),

                                                      /// ---------- Features Grid ----------
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          gradient:
                                                              const LinearGradient(
                                                            colors: [
                                                              Color(0xFFE67025),
                                                              Color(0xFFE93276)
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                          // color: white
                                                          //     .withOpacity(
                                                          //         0.8)
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            if (membership[
                                                                        index]
                                                                    .planFeatures
                                                                    .video !=
                                                                0)
                                                              buildFeatureItem(
                                                                context,
                                                                "feeds.png",
                                                                "Video",
                                                                membership[
                                                                        index]
                                                                    .planFeatures
                                                                    .video,
                                                                (isSelected),
                                                              ),
                                                            if (membership[
                                                                        index]
                                                                    .planFeatures
                                                                    .image !=
                                                                0)
                                                              buildFeatureItem(
                                                                context,
                                                                "ic_gallery.png",
                                                                "Image",
                                                                membership[
                                                                        index]
                                                                    .planFeatures
                                                                    .image,
                                                                (isSelected),
                                                              ),
                                                            if (membership[
                                                                        index]
                                                                    .planFeatures
                                                                    .liveStream !=
                                                                0)
                                                              buildFeatureItem(
                                                                context,
                                                                "livestream.png",
                                                                "Live Stream",
                                                                membership[
                                                                        index]
                                                                    .planFeatures
                                                                    .liveStream,
                                                                (isSelected),
                                                              ),
                                                            if (membership[
                                                                        index]
                                                                    .planFeatures
                                                                    .chat !=
                                                                0)
                                                              buildFeatureItem(
                                                                context,
                                                                "chat.png",
                                                                "Chat",
                                                                membership[
                                                                        index]
                                                                    .planFeatures
                                                                    .chat,
                                                                (isSelected),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 14),
                                                      !(membership[index]
                                                                  .planPurchased) &&
                                                              !widget.isUser
                                                          ? Center(
                                                              child: InkWell(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                onTap:
                                                                    () async {
                                                                  Utils.showProgress(
                                                                      context);
                                                                  SuccessModel
                                                                      subscribe =
                                                                      await ApiService()
                                                                          .subscribeMembership(
                                                                    Constant.userID ??
                                                                        '',
                                                                    membershipPlanModel
                                                                        .result[
                                                                            index]
                                                                        .id,
                                                                    membershipPlanModel
                                                                        .result[
                                                                            index]
                                                                        .offerPrice,
                                                                  );
                                                                  if (mounted) {
                                                                    Utils().hideProgress(
                                                                        context);
                                                                    Utils()
                                                                        .showSnackBar(
                                                                      context,
                                                                      subscribe
                                                                              .message ??
                                                                          "",
                                                                      false,
                                                                    );
                                                                  }
                                                                  if (subscribe
                                                                          .status ==
                                                                      200) {
                                                                    setState(
                                                                        () {
                                                                      getMembershipPlan(
                                                                          context);
                                                                      selectedIndex =
                                                                          null; // reset after purchase
                                                                    });
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 42,
                                                                  width: !kIsWeb
                                                                      ? MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.4
                                                                      : !ResponsiveHelper.isDesktop(
                                                                              context)
                                                                          ? MediaQuery.of(context).size.width *
                                                                              0.4
                                                                          : MediaQuery.of(context).size.width *
                                                                              0.2,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .fromLTRB(
                                                                          20,
                                                                          0,
                                                                          20,
                                                                          0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    // color:
                                                                    //     white,
                                                                    gradient:
                                                                        const LinearGradient(
                                                                      colors: [
                                                                        Color(
                                                                            0xFF150D26),
                                                                        Color(
                                                                            0xFFE93276)
                                                                      ],
                                                                      begin: Alignment
                                                                          .topLeft,
                                                                      end: Alignment
                                                                          .bottomRight,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25),
                                                                  ),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .shopping_cart,
                                                                        color:
                                                                            white,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      MyText(
                                                                        color:
                                                                            white,
                                                                        text:
                                                                            "buynow",
                                                                        textalign:
                                                                            TextAlign.center,
                                                                        fontsizeNormal:
                                                                            Dimens.textMedium,
                                                                        fontwaight:
                                                                            FontWeight.w700,
                                                                        multilanguage:
                                                                            true,
                                                                        maxline:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        fontstyle:
                                                                            FontStyle.normal,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Using negative top to slightly overlap top of the card
                                              // ---- Ribbon ----
                                              membership[index].planValue !=
                                                      'none'
                                                  ? Positioned(
                                                      top: 0,
                                                      left: -54,
                                                      child: Stack(
                                                        children: [
                                                          ShaderMask(
                                                            shaderCallback: (bounds) => containerColor ==
                                                                    0
                                                                ? const LinearGradient(
                                                                        colors: [
                                                                        Color(
                                                                            0xFF150D26),
                                                                        Color(
                                                                            0xFF2C0C53),
                                                                        Color(
                                                                            0xFFE93276),
                                                                        Color(
                                                                            0xFF2D00F7),
                                                                      ],
                                                                        begin: Alignment
                                                                            .topLeft,
                                                                        end: Alignment
                                                                            .bottomRight)
                                                                    .createShader(
                                                                        bounds)
                                                                : containerColor ==
                                                                        1
                                                                    ? const LinearGradient(
                                                                            colors: [
                                                                            Color(0xFF150D26),
                                                                            Color(0xFF2C0C53),
                                                                            Color(0xFFE93276),
                                                                            Color(0xFF2D00F7),
                                                                          ],
                                                                            begin: Alignment
                                                                                .topLeft,
                                                                            end: Alignment
                                                                                .bottomRight)
                                                                        .createShader(
                                                                            bounds)
                                                                    : const LinearGradient(
                                                                            colors: [
                                                                            Color(0xFF150D26),
                                                                            Color(0xFF2C0C53),
                                                                            Color(0xFFE93276),
                                                                            Color(0xFF2D00F7),
                                                                          ],
                                                                            begin: Alignment
                                                                                .topLeft,
                                                                            end: Alignment
                                                                                .bottomRight)
                                                                        .createShader(
                                                                            bounds),
                                                            blendMode:
                                                                BlendMode.srcIn,
                                                            child: MyImage(
                                                                width: 200,
                                                                height: 120,
                                                                imagePath:
                                                                    'badge.png'),
                                                          ),
                                                          Positioned(
                                                            top: 40,
                                                            left: 55,
                                                            child: MyText(
                                                              text: membership[
                                                                              index]
                                                                          .planValue ==
                                                                      "best_value"
                                                                  ? "Best value"
                                                                  : "Most popular",
                                                              color: white,
                                                              fontsizeNormal:
                                                                  14,
                                                              fontwaight:
                                                                  FontWeight
                                                                      .bold,
                                                              multilanguage:
                                                                  false,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                              Positioned(
                                                  right: 15,
                                                  top: 20,
                                                  child: widget.isUser
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  backgroundColor:
                                                                      colorPrimaryDark,
                                                                  content:
                                                                      MyText(
                                                                    text:
                                                                        "surewanttodelete",
                                                                    color:
                                                                        white,
                                                                    fontsizeNormal:
                                                                        16,
                                                                  ),
                                                                  actions: [
                                                                    OutlinedButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          MyText(
                                                                        text:
                                                                            'no',
                                                                        color:
                                                                            colorPrimary,
                                                                      ),
                                                                    ),
                                                                    ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          backgroundColor:
                                                                              colorPrimary),
                                                                      onPressed:
                                                                          () async {
                                                                        Utils.showProgress(
                                                                            context);
                                                                        SuccessModel
                                                                            deletePlan =
                                                                            await ApiService().deleteMembershipPlan(membership[index].id);
                                                                        Utils().hideProgress(
                                                                            context);
                                                                        Navigator.pop(
                                                                            context);
                                                                        Utils().showSnackBar(
                                                                            context,
                                                                            deletePlan.message ??
                                                                                '',
                                                                            false);
                                                                        if (deletePlan.status ==
                                                                            200) {
                                                                          setState(
                                                                              () {
                                                                            getMembershipPlan(context);
                                                                          });
                                                                        }
                                                                      },
                                                                      child:
                                                                          MyText(
                                                                        text:
                                                                            'yes',
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 8.0),
                                                            child: Icon(
                                                              Icons.delete,
                                                              color: Colors
                                                                  .redAccent,
                                                              size: 21,
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox.shrink())
                                            ],
                                          ),

                                          /// Show check only if purchased
                                          if (isPurchased)
                                            Positioned(
                                              top: 2,
                                              right: 1,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  // gradient:
                                                  //     Constant.gradientColor,
                                                  color: colorGold,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: const Icon(
                                                    Icons.check_outlined),
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

                          /// ---------- Continue Button ----------
                          /*if (!widget.isUser && selectedIndex != null)
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: InkWell(
                                onTap: () async {
                                  Utils.showProgress(context);
                                  SuccessModel subscribe =
                                      await ApiService().subscribeMembership(
                                    Constant.userID ?? '',
                                    membershipPlanModel
                                        .result[selectedIndex!].id,
                                    membershipPlanModel
                                        .result[selectedIndex!].offerPrice,
                                  );
                                  if (mounted) {
                                    Utils().hideProgress(context);
                                    Utils().showSnackBar(
                                      context,
                                      subscribe.message ?? "",
                                      false,
                                    );
                                  }
                                  if (subscribe.status == 200) {
                                    setState(() {
                                      getMembershipPlan(context);
                                      selectedIndex =
                                          null; // reset after purchase
                                    });
                                  }
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: Constant.gradientColor,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: MyText(
                                      text: "Continue",
                                      color: pureBlack,
                                      fontwaight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),*/
                        ],
                      ),
                    ),
    );
  }

  Widget buildFeatureItem(
    BuildContext context,
    String icon,
    String label,
    int value,
    bool purchased,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /*ShaderMask(
              shaderCallback: (bounds) => purchased
                  ? const LinearGradient(colors: [Colors.black, Colors.black])
                      .createShader(bounds)
                  : Constant.gradientColor.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: MyImage(
                width: 16,
                height: 16,
                imagePath: icon,
                color: purchased ? black : black,
              ),
            ),*/
            const SizedBox(width: 5),
            MyImage(
              width: 16,
              height: 16,
              imagePath: icon,
              color: purchased ? white : white,
            ),
            const SizedBox(width: 15),
            Text(
              style: TextStyle(
                fontSize: 12,
                color: purchased ? white : white,
              ),
              "No of $label",
            ),
            Spacer(),
            Text(
              "$value",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: purchased ? white : white, fontSize: 12),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget buildWebItem(List<Result>? packageList) {
    if (packageList != null) {
      return Utils().pageBg(
        context,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  MyImage(
                      width: 215,
                      height: 150,
                      fit: BoxFit.cover,
                      imagePath: "subscribeimage.png"),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MyText(
                      color: white,
                      text: "subscriptionsubdiscription",
                      textalign: TextAlign.center,
                      multilanguage: true,
                      fontsizeNormal: Dimens.textMedium,
                      fontsizeWeb: Dimens.textDesc,
                      maxline: 2,
                      overflow: TextOverflow.ellipsis,
                      fontwaight: FontWeight.w500,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CarouselSlider.builder(
                    itemCount: packageList.length,
                    carouselController: pageController,
                    options: CarouselOptions(
                      initialPage: 0,
                      height: MediaQuery.of(context).size.height,
                      enlargeCenterPage: packageList.length > 1 ? true : false,
                      enlargeFactor: kIsWeb ? 0.30 : 0.22,
                      autoPlay: false,
                      autoPlayCurve: Curves.easeInOutQuart,
                      enableInfiniteScroll: packageList.length > 1
                          ? kIsWeb
                              ? packageList.length > 3
                                  ? true
                                  : false
                              : true
                          : false,
                      viewportFraction: kIsWeb ? 0.3 : 0.73,
                    ),
                    itemBuilder:
                        (BuildContext context, int index, int pageViewIndex) {
                      return Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: widget.isUser
                                ? () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AddMembershipPlan(
                                            membership: packageList[index],
                                          );
                                        },
                                      ),
                                    );
                                    setState(() {
                                      getMembershipPlan(context);
                                    });
                                  }
                                : () {},
                            child: Container(
                              width: ResponsiveHelper.isDesktop(context)
                                  ? MediaQuery.of(context).size.width
                                  : MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: const LinearGradient(colors: [
                                  Color(0xFF150D26),
                                  Color(0xFF2C0C53),
                                  Color(0xFF150F27),
                                  Color(0xFF591D47),
                                ]),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.only(
                                          left: 18, right: 18),
                                      constraints:
                                          const BoxConstraints(minHeight: 50),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: MyText(
                                              color: white,
                                              text:
                                                  packageList[index].name ?? "",
                                              textalign: TextAlign.start,
                                              fontsizeNormal: Dimens.textTitle,
                                              maxline: 1,
                                              multilanguage: false,
                                              overflow: TextOverflow.ellipsis,
                                              fontwaight: FontWeight.bold,
                                              fontstyle: FontStyle.normal,
                                            ),
                                          ),
                                          widget.isUser
                                              ? GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                colorPrimaryDark,
                                                            content: MyText(
                                                              text:
                                                                  "surewanttodelete",
                                                              color: white,
                                                              fontsizeNormal:
                                                                  16,
                                                            ),
                                                            actions: [
                                                              OutlinedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: MyText(
                                                                    text: 'no',
                                                                    color:
                                                                        colorPrimary,
                                                                  )),
                                                              ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                          backgroundColor:
                                                                              colorPrimary),
                                                                  onPressed:
                                                                      () async {
                                                                    Utils.showProgress(
                                                                        context);
                                                                    SuccessModel
                                                                        deletePlan =
                                                                        await ApiService()
                                                                            .deleteMembershipPlan(packageList[index].id);
                                                                    Utils().hideProgress(
                                                                        context);
                                                                    Navigator.pop(
                                                                        context);
                                                                    Utils().showSnackBar(
                                                                        context,
                                                                        deletePlan.message ??
                                                                            '',
                                                                        false);
                                                                    if (deletePlan
                                                                            .status ==
                                                                        200) {
                                                                      setState(
                                                                          () {
                                                                        getMembershipPlan(
                                                                            context);
                                                                      });
                                                                    }
                                                                  },
                                                                  child: MyText(
                                                                    text: 'yes',
                                                                    color: Colors
                                                                        .white,
                                                                  ))
                                                            ],
                                                          );
                                                        });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: white
                                                            .withOpacity(0.3),
                                                        shape: BoxShape.circle),
                                                    padding:
                                                        const EdgeInsets.all(7),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: const Icon(
                                                      Icons.delete,
                                                      color: Colors.redAccent,
                                                      size: 21,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink()
                                        ],
                                      )),
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.only(
                                          left: 18, right: 18),
                                      constraints:
                                          const BoxConstraints(minHeight: 50),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFE67025),
                                                    Color(0xFFE93276)
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                border: Border.all(
                                                    color:
                                                        const Color(0xFF8F03FF),
                                                    width: 1.5),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Text(
                                              packageList[index].planValue ==
                                                      "best_value"
                                                  ? "Best value"
                                                  : "Most popular",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      color: white,
                                                      fontSize: 13),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                MyImage(
                                                    width: 17.5,
                                                    height: 17.5,
                                                    imagePath: "ic_coin.png"),
                                                const SizedBox(width: 3),
                                                Text(
                                                  packageList[index]
                                                      .price
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          decorationThickness:
                                                              1.8,
                                                          decorationColor:
                                                              colorGold),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  packageList[index]
                                                      .offerPrice
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                          color: Colors.white,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                ),
                                                MyText(
                                                  text:
                                                      " / ${packageList[index].planType}",
                                                  multilanguage: false,
                                                  fontsizeNormal: 17,
                                                  fontwaight: FontWeight.w600,
                                                  color: white,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 0.7,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(children: [
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        packageList[index].planFeatures.video ==
                                                0
                                            ? const SizedBox()
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 14,
                                                    color: white,
                                                  ),
                                                  MyText(
                                                      text: "video",
                                                      color: white,
                                                      fontwaight:
                                                          FontWeight.w600),
                                                  Text(
                                                    "${packageList[index].planFeatures.video}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                            color: white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                                ],
                                              ),
                                        packageList[index].planFeatures.image ==
                                                0
                                            ? const SizedBox()
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 14,
                                                    color: white,
                                                  ),
                                                  MyText(
                                                      text: "image",
                                                      color: white,
                                                      fontwaight:
                                                          FontWeight.w600),
                                                  Text(
                                                    "${packageList[index].planFeatures.image}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                            color: white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                                ],
                                              ),
                                        packageList[index]
                                                    .planFeatures
                                                    .liveStream ==
                                                0
                                            ? const SizedBox()
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 14,
                                                    color: white,
                                                  ),
                                                  MyText(
                                                      text: "live_stream",
                                                      color: white,
                                                      fontwaight:
                                                          FontWeight.w600),
                                                  Text(
                                                    "${packageList[index].planFeatures.liveStream}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                            color: white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                                ],
                                              ),
                                        packageList[index].planFeatures.chat ==
                                                0
                                            ? const SizedBox()
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 14,
                                                    color: white,
                                                  ),
                                                  MyText(
                                                      text: "chat",
                                                      color: white,
                                                      fontwaight:
                                                          FontWeight.w600),
                                                  Text(
                                                    "${packageList[index].planFeatures.chat}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                            color: white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                                ],
                                              ),
                                        const SizedBox(
                                          height: 35,
                                        ),
                                        if (!widget.isUser)
                                          InkWell(
                                            onTap: packageList[index]
                                                    .planPurchased
                                                ? null
                                                : () async {
                                                    Utils.showProgress(context);
                                                    SuccessModel subscribe =
                                                        await ApiService()
                                                            .subscribeMembership(
                                                                Constant.userID ??
                                                                    '',
                                                                packageList[
                                                                        index]
                                                                    .id,
                                                                packageList[
                                                                        index]
                                                                    .offerPrice);
                                                    Utils()
                                                        .hideProgress(context);
                                                    if (subscribe.status ==
                                                        200) {
                                                      setState(() {
                                                        Utils().showSnackBar(
                                                            context,
                                                            subscribe.message ??
                                                                '',
                                                            false);
                                                      });
                                                      getMembershipPlan(
                                                          context);
                                                    } else {
                                                      Utils().showSnackBar(
                                                          context,
                                                          subscribe.message ??
                                                              '',
                                                          false);
                                                    }
                                                  },
                                            child: Container(
                                              width: !kIsWeb
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4
                                                  : !ResponsiveHelper.isDesktop(
                                                          context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.4
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.2,
                                              height: 40,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 0, 20, 0),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFE67025),
                                                    Color(0xFFE93276)
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                border: Border.all(
                                                    color:
                                                        const Color(0xFF8F03FF),
                                                    width: 1.5),
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: Center(
                                                  child: MyText(
                                                text: packageList[index]
                                                        .planPurchased
                                                    ? "current"
                                                    : 'chooseplan',
                                                color: packageList[index]
                                                        .planPurchased
                                                    ? white
                                                    : white,
                                                textalign: TextAlign.center,
                                                fontsizeNormal:
                                                    Dimens.textMedium,
                                                fontwaight: FontWeight.w700,
                                                multilanguage: true,
                                                maxline: 1,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal,
                                              )),
                                            ),
                                          )
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildBenefits(List<Result>? packageList, int? index) {
    if (packageList?[index ?? 0].planFeatures != null &&
        (packageList?.length ?? 0) > 0) {
      return AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        padding: const EdgeInsets.fromLTRB(15, 2, 15, 5),
        itemCount: packageList?.length,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int position) {
          return Container(
            constraints: const BoxConstraints(minHeight: 10),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  size: 14,
                  color: white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MyText(
                    color: white,
                    text: packageList?[index ?? 0].planFeatures.video == 0
                        ? ''
                        : 'video : ${packageList![index ?? 0].planFeatures.video.toString()}',
                    textalign: TextAlign.start,
                    multilanguage: false,
                    fontsizeNormal: Dimens.textSmall,
                    maxline: 3,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w500,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(width: 20),
                Icon(Icons.check),
                /*((packageList?[index ?? 0].data?[position].packageValue ??
                    "") ==
                    "1" ||
                    (packageList?[index ?? 0]
                        .data?[position]
                        .packageValue ??
                        "") ==
                        "0")
                    ? Icon(
                  (packageList?[index ?? 0]
                      .data?[position]
                      .packageValue ??
                      "") ==
                      "1"
                      ? Icons.check
                      : Icons.close,
                  color: black,
                  size: 21,
                )
                    : MyText(
                  color: white,
                  text: packageList?[index ?? 0]
                      .data?[position]
                      .packageValue ??
                      "",
                  textalign: TextAlign.center,
                  fontsizeNormal: Dimens.textTitle,
                  multilanguage: false,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontwaight: FontWeight.bold,
                  fontstyle: FontStyle.normal,
                ),*/
              ],
            ),
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

/// ClipPath for left-fold ribbon
class RibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const fold = 12.0; // folded corner size
    final path = Path();

    path.moveTo(0, 0); // top-left
    path.lineTo(size.width, 0); // top-right
    path.lineTo(size.width, size.height); // bottom-right
    path.lineTo(fold, size.height); // bottom-left (shifted right by fold)
    path.lineTo(0, size.height - fold); // diagonal back to left
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
