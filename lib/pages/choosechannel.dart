import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/model/packagechannelsmodel.dart';
import 'package:fanbae/pages/successpage.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:provider/provider.dart';

import '../provider/profileprovider.dart';
import '../provider/subscriptionprovider.dart';
import '../subscription/adspackage.dart';
import '../subscription/allpayment.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/responsive_helper.dart';
import '../utils/sharedpre.dart';
import '../webpages/weblogin.dart';
import '../widget/mytext.dart';
import 'login.dart';

class ChooseChannel extends StatefulWidget {
  final Result channel;
  final int packageId;
  final String packageName;
  final List<int> categoryId;
  final String? packagePrice;

  const ChooseChannel(
      {super.key,
      required this.channel,
      required this.packageId,
      required this.categoryId,
      required this.packageName,
      this.packagePrice});

  @override
  State<ChooseChannel> createState() => _ChooseChannelState();
}

class _ChooseChannelState extends State<ChooseChannel> {
  List<int> selectedChannels = [];
  late SubscriptionProvider subscriptionProvider;
  SharedPre sharedPre = SharedPre();
  String? userName, userEmail, userMobileNo, countryCode, countryName;
  bool isToggled = false;
  late ProfileProvider profileProvider;

  @override
  void initState() {
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    super.initState();
    getApi();
  }

  getApi() async {
    await subscriptionProvider.getPackage();
    await _getUserData();
    setState(() {});
  }

  _getUserData() async {
    userName = await sharedPre.read("fullname");
    userEmail = await sharedPre.read("email");
    userMobileNo = await sharedPre.read("mobilenumber");
    countryCode = await sharedPre.read("countrycode");
    countryName = await sharedPre.read("countryname");
    printLog('getUserData userName ==> $userName');
    printLog('getUserData userEmail ==> $userEmail');
    printLog('getUserData userMobileNo ==> $userMobileNo');
    printLog('getUserData countryCode ==> $countryCode');
    printLog('getUserData countryName ==> $countryName');
  }

  updateDataDialogMobile({
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
  }) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    if (!context.mounted) return;
    dynamic result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: appbgcolor,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Utils.dataUpdateDialog(
              context,
              isNameReq: isNameReq,
              isEmailReq: isEmailReq,
              isMobileReq: isMobileReq,
              nameController: nameController,
              emailController: emailController,
              mobileController: mobileController,
            ),
          ],
        );
      },
    );
    if (result != null) {
      await _getUserData();
      Future.delayed(Duration.zero).then((value) {
        if (!context.mounted) return;
        setState(() {});
      });
    }
  }

  updateDataDialogWeb({
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
  }) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    if (!context.mounted) return;
    dynamic result = await showDialog<dynamic>(
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
              minHeight: 400,
              maxHeight: 450,
            ),
            child: Wrap(
              children: [
                Utils.dataUpdateDialog(
                  context,
                  isNameReq: isNameReq,
                  isEmailReq: isEmailReq,
                  isMobileReq: isMobileReq,
                  nameController: nameController,
                  emailController: emailController,
                  mobileController: mobileController,
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) {
      await _getUserData();
      Future.delayed(Duration.zero).then((value) {
        if (!context.mounted) return;
        setState(() {});
      });
    }
  }

  _checkAndPay() async {
    if (Constant.userID != null) {
      if ((userName ?? "").isEmpty ||
          (userEmail ?? "").isEmpty ||
          (userMobileNo ?? "").isEmpty) {
        if (kIsWeb) {
          updateDataDialogWeb(
            isNameReq: (userName ?? "").isEmpty,
            isEmailReq: (userEmail ?? "").isEmpty,
            isMobileReq: (userMobileNo ?? "").isEmpty,
          );
          return;
        } else {
          updateDataDialogMobile(
            isNameReq: (userName ?? "").isEmpty,
            isEmailReq: (userEmail ?? "").isEmpty,
            isMobileReq: (userMobileNo ?? "").isEmpty,
          );
          return;
        }
      }
      // Set final amount for payment gateway
      await subscriptionProvider.setFinalAmount(widget.packagePrice ?? "0");

      // Navigate to payment gateway instead of coin deduction
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AllPayment(
              payType: "Package",
              itemId: widget.packageId.toString(),
              price: widget.packagePrice ?? "0",
              coin: "0",
              itemTitle: widget.packageName,
              typeId: selectedChannels.toString(),
              videoType: widget.categoryId.toString(),
              productPackage: "",
              currency: Constant.currency,
            );
          },
        ),
      );
    } else {
      printLog("Enter Login ");
      if (kIsWeb) {
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const WebLogin(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Login();
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: AppBar(
        backgroundColor: appBarColor,
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
          text: "choosechannels",
          color: white,
          fontsizeNormal: Dimens.textBig,
          fontwaight: FontWeight.bold,
        ),
        actions: [
          Row(
            children: [
              Icon(
                Icons.shopping_cart,
                color: white,
                size: 19,
              ),
              const SizedBox(
                width: 5,
              ),
              MyText(
                text: "${selectedChannels.length}/${widget.channel.limit}",
                multilanguage: false,
                color: white,
                fontwaight: FontWeight.w600,
              ),
              const SizedBox(
                width: 15,
              ),
            ],
          )
        ],
      ),
      body: Utils().pageBg(
        context,
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: widget.channel.channelUsers.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                itemBuilder: (BuildContext context, int i) {
                  return Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        gradient: selectedChannels
                                .contains(widget.channel.channelUsers[i].id)
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                    const Color(0xFF2C0C53).withOpacity(0.8),
                                    const Color(0xFF150F27).withOpacity(0.8),
                                    const Color(0xffFE3379).withOpacity(0.8),
                                  ])
                            : null,
                        borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      margin: const EdgeInsets.all(2.5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 13),
                      decoration: BoxDecoration(
                          color: Constant.darkMode == 'true'
                              ? const Color(0xff4A4A4A).withOpacity(0.8)
                              : const Color(0xff4A4A4A).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10)),
                      child: !ResponsiveHelper.isDesktop(context)
                          ? Row(
                              children: [
                                Container(
                                    clipBehavior: Clip.antiAlias,
                                    margin: const EdgeInsets.only(right: 12),
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height:
                                        MediaQuery.of(context).size.width * 0.1,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: MyNetworkImage(
                                        imagePath: widget
                                            .channel.channelUsers[i].image,
                                        fit: BoxFit.cover)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: widget.channel.channelUsers[i]
                                            .channelName,
                                        color: white,
                                        multilanguage: false,
                                        fontwaight: FontWeight.w600,
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      Row(
                                        children: [
                                          MyText(
                                            text: widget.channel.channelUsers[i]
                                                .subscribers
                                                .toString(),
                                            color: white,
                                            multilanguage: false,
                                            fontsizeNormal: 11.3,
                                            maxline: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(
                                            width: 2,
                                          ),
                                          MyText(
                                            text: "subscribers",
                                            color: white,
                                            multilanguage: false,
                                            fontsizeNormal: 11.3,
                                            maxline: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          MyText(
                                            text: ", ",
                                            color: white,
                                            multilanguage: false,
                                            fontsizeNormal: 11.3,
                                            maxline: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          MyText(
                                            text: widget.channel.channelUsers[i]
                                                .contents
                                                .toString(),
                                            color: white,
                                            multilanguage: false,
                                            fontsizeNormal: 11.3,
                                            maxline: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(
                                            width: 2,
                                          ),
                                          MyText(
                                            text: "videos",
                                            color: white,
                                            multilanguage: false,
                                            fontsizeNormal: 11.3,
                                            maxline: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (selectedChannels.contains(
                                        widget.channel.channelUsers[i].id)) {
                                      setState(() {
                                        selectedChannels.remove(
                                            widget.channel.channelUsers[i].id);
                                      });
                                    } else {
                                      if (selectedChannels.length <
                                          widget.channel.limit) {
                                        setState(() {
                                          selectedChannels.add(widget
                                              .channel.channelUsers[i].id);
                                        });
                                      } else {
                                        Utils().showSnackBar(
                                            context,
                                            "You can only able to select ${widget.channel.limit} channels",
                                            false);
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7.5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: selectedChannels.contains(widget
                                                .channel.channelUsers[i].id)
                                            ? null
                                            : buttonDisable,
                                        gradient: selectedChannels.contains(
                                                widget
                                                    .channel.channelUsers[i].id)
                                            ? Constant.gradientColor
                                            : null),
                                    child: MyText(
                                      text: selectedChannels.contains(
                                              widget.channel.channelUsers[i].id)
                                          ? "subscribed"
                                          : 'subscribe',
                                      color: selectedChannels.contains(
                                              widget.channel.channelUsers[i].id)
                                          ? pureBlack
                                          : white,
                                      fontsizeNormal: Dimens.textSmall,
                                      fontwaight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                    clipBehavior: Clip.antiAlias,
                                    margin: const EdgeInsets.only(right: 20),
                                    width: MediaQuery.of(context).size.width *
                                        0.045,
                                    height: MediaQuery.of(context).size.width *
                                        0.045,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: MyNetworkImage(
                                        imagePath: widget
                                            .channel.channelUsers[i].image,
                                        fit: BoxFit.cover)),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 220,
                                        child: MyText(
                                          maxline: 2,
                                          text: widget.channel.channelUsers[i]
                                              .channelName,
                                          color: white,
                                          multilanguage: false,
                                          fontwaight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: MyText(
                                          text: widget
                                              .channel.channelUsers[i].fullName
                                              .toString(),
                                          color: white,
                                          multilanguage: false,
                                          fontsizeNormal: 11.3,
                                          maxline: 2,
                                          fontwaight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 300,
                                        child: Row(
                                          children: [
                                            MyText(
                                              text: widget.channel
                                                  .channelUsers[i].subscribers
                                                  .toString(),
                                              color: white,
                                              multilanguage: false,
                                              fontsizeNormal: 11.3,
                                              maxline: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            MyText(
                                              text: "subscribers",
                                              color: white,
                                              multilanguage: false,
                                              fontsizeNormal: 11.3,
                                              maxline: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            MyText(
                                              text: ", ",
                                              color: white,
                                              multilanguage: false,
                                              fontsizeNormal: 11.3,
                                              maxline: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            MyText(
                                              text: widget.channel
                                                  .channelUsers[i].contents
                                                  .toString(),
                                              color: white,
                                              multilanguage: false,
                                              fontsizeNormal: 11.3,
                                              maxline: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            MyText(
                                              text: "videos",
                                              color: white,
                                              multilanguage: false,
                                              fontsizeNormal: 11.3,
                                              maxline: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (selectedChannels.contains(
                                        widget.channel.channelUsers[i].id)) {
                                      setState(() {
                                        selectedChannels.remove(
                                            widget.channel.channelUsers[i].id);
                                      });
                                    } else {
                                      if (selectedChannels.length <
                                          widget.channel.limit) {
                                        setState(() {
                                          selectedChannels.add(widget
                                              .channel.channelUsers[i].id);
                                        });
                                      } else {
                                        Utils().showSnackBar(
                                            context,
                                            "You can only able to select ${widget.channel.limit} channels",
                                            false);
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7.5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: selectedChannels.contains(widget
                                                .channel.channelUsers[i].id)
                                            ? null
                                            : buttonDisable,
                                        gradient: selectedChannels.contains(
                                                widget
                                                    .channel.channelUsers[i].id)
                                            ? Constant.gradientColor
                                            : null),
                                    child: MyText(
                                      text: selectedChannels.contains(
                                              widget.channel.channelUsers[i].id)
                                          ? "subscribed"
                                          : 'subscribe',
                                      color: selectedChannels.contains(
                                              widget.channel.channelUsers[i].id)
                                          ? pureBlack
                                          : white,
                                      fontsizeNormal: Dimens.textSmall,
                                      fontwaight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              ],
                            ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 15,
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 13.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 25,
                    width: 35,
                    child: Checkbox(
                      value: isToggled,
                      checkColor: pureBlack,
                      fillColor: WidgetStateProperty.all(
                          isToggled ? textColor : transparent),
                      onChanged: (bool? value) async {
                        setState(() {
                          isToggled = value!;
                        });
                      },
                    ),
                  ),
                  MyText(
                      text: 'Do you want Auto-Renewal?',
                      multilanguage: false,
                      color: white,
                      fontwaight: FontWeight.w500),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (selectedChannels.length < widget.channel.limit) {
                  return Utils().showSnackBar(context,
                      "Need to select ${widget.channel.limit} channels", false);
                }
                _checkAndPay();
              },
              child: Padding(
                padding: ResponsiveHelper.isDesktop(context)
                    ? EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.35,
                        right: MediaQuery.of(context).size.width * 0.35)
                    : const EdgeInsets.all(0),
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                      gradient: Constant.gradientColor,
                      borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: MyText(
                      text: 'purchase',
                      color: pureBlack,
                      fontwaight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
