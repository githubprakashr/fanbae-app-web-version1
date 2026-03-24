import 'package:fanbae/provider/homeprovider.dart';
import 'package:fanbae/provider/profileprovider.dart';
import 'package:fanbae/provider/notificationprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../pages/login.dart';
import '../pages/notificationpage.dart';
import '../pages/profile.dart';
import '../provider/settingprovider.dart';
import '../subscription/adspackage.dart';
import '../subscription/subscription.dart';
import '../utils/adhelper.dart';
import '../utils/responsive_helper.dart';
import '../utils/utils.dart';
import '../webpages/weblogin.dart';
import 'mynetworkimg.dart';
import 'mytext.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String contentType;

  const CustomAppBar({super.key, required this.contentType});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _CustomAppBarState extends State<CustomAppBar> {
  late HomeProvider homeProvider;
  late ProfileProvider profileProvider;
  late SettingProvider settingProvider;
  SharedPre sharedPre = SharedPre();
  String image = "";

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    getApi();
    // Fetch notifications on app bar init
    if (Constant.userID != null) {
      Future.microtask(() =>
          Provider.of<NotificationProvider>(context, listen: false)
              .getNotification(1));
    }
    super.initState();
  }

  getApi() async {
    if (Constant.userID != null) {
      await homeProvider.getprofile(Constant.userID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: Constant.darkMode == "true"
            ? const Color(0xff05060F)
            : const Color(0xfffcfcfc),
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: transparent,
        titleSpacing: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Constant.darkMode == 'true' ? appBarColor : gray,
        ),
        title: Consumer<HomeProvider>(builder: (context, homeprovider, child) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 400;
          final isMediumScreen = screenWidth >= 400 && screenWidth < 600;

          // When not logged in: logo center, profile right, notification hidden
          final isLoggedIn = Constant.userID != null;

          return Container(
            // width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height,
            // decoration: BoxDecoration(
            //     image: DecorationImage(
            //         image: AssetImage(
            //             "${Constant.imageFolderPath}appbgimage.png"
            //         )
            //     )
            // ),
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left section - Crown and coins (only when logged in)
                if (isLoggedIn)
                  Row(
                    children: [
                      SizedBox(width: isSmallScreen ? 8 : 15),
                      if (Constant.userID != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Subscription();
                                },
                              ),
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MyImage(
                                  width: isSmallScreen ? 36 : 50,
                                  height: isSmallScreen ? 28 : 38,
                                  fit: BoxFit.cover,
                                  imagePath: "crown.png"),
                              if (!isSmallScreen || isMediumScreen)
                                ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                          colors: [
                                            Constant.darkMode == "true"
                                                ? colorPrimary
                                                : pureBlack,
                                            Constant.darkMode == "true"
                                                ? pureWhite
                                                : gray,
                                            Constant.darkMode == "true"
                                                ? colorPrimary
                                                : pureBlack
                                          ],
                                        ).createShader(Rect.fromLTWH(
                                            0, 0, bounds.width, bounds.height)),
                                    child: Text(
                                      (() {
                                        final result = profileProvider
                                            .profileModel.result?[0];
                                        if (result == null ||
                                            result.isBuy != 1) {
                                          return isSmallScreen
                                              ? 'Sub'
                                              : 'Subscribe';
                                        }

                                        final expireDate = DateTime.tryParse(
                                            result.expireDate.toString());
                                        if (expireDate == null) {
                                          return isSmallScreen
                                              ? 'Sub'
                                              : 'Subscribe';
                                        }

                                        final remainingDays = expireDate
                                            .difference(DateTime.now())
                                            .inDays;

                                        if (remainingDays <= 7 &&
                                            remainingDays != 0) {
                                          return isSmallScreen
                                              ? "${remainingDays}d"
                                              : "$remainingDays days left";
                                        } else if (remainingDays == 0) {
                                          return isSmallScreen
                                              ? "Exp"
                                              : "Expire Today";
                                        } else {
                                          String planName =
                                              result.packageName ??
                                                  Constant.subscriptionPlan ??
                                                  '';
                                          return isSmallScreen &&
                                                  planName.length > 5
                                              ? planName.substring(0, 5)
                                              : planName;
                                        }
                                      })(),
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 11 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ))
                            ],
                          ),
                        ),
                      SizedBox(width: isSmallScreen ? 8 : 15),
                      if (Constant.userID != null) ...[
                        InkWell(
                          focusColor: transparent,
                          splashColor: transparent,
                          highlightColor: transparent,
                          hoverColor: transparent,
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
                            height: isSmallScreen ? 30 : 35,
                            padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 6 : 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyImage(
                                  width: isSmallScreen ? 24 : 28,
                                  height: isSmallScreen ? 34 : 44,
                                  imagePath: "coin.png",
                                ),
                                SizedBox(width: isSmallScreen ? 8 : 12),
                                Consumer<ProfileProvider>(
                                  builder: (context, settingProvider, _) {
                                    return MyText(
                                      color: white,
                                      fontsizeWeb: 13,
                                      multilanguage: false,
                                      text: profileProvider.profileModel
                                              .result?[0].walletBalance
                                              .toString() ??
                                          '0',
                                      textalign: TextAlign.center,
                                      fontsizeNormal: isSmallScreen
                                          ? Dimens.textSmall
                                          : Dimens.textMedium,
                                      inter: true,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                // Center - Logo (always centered)
                Expanded(
                  child: Center(
                    child: Container(
                      width: isSmallScreen
                          ? (isLoggedIn ? 90 : 120)
                          : (isMediumScreen
                              ? (isLoggedIn ? 105 : 140)
                              : (isLoggedIn ? 120 : 160)),
                      height: isSmallScreen
                          ? (isLoggedIn ? 28 : 38)
                          : (isLoggedIn ? 36 : 46),
                      child: MyImage(
                        width: isSmallScreen
                            ? (isLoggedIn ? 90 : 120)
                            : (isMediumScreen
                                ? (isLoggedIn ? 105 : 140)
                                : (isLoggedIn ? 120 : 160)),
                        height: isSmallScreen
                            ? (isLoggedIn ? 28 : 38)
                            : (isLoggedIn ? 36 : 46),
                        imagePath: "namelogo.png",
                      ),
                    ),
                  ),
                ),

                // Right section - Notification (when logged in) and Profile
                Row(
                  children: [
                    // Notification - only show when logged in
                    if (isLoggedIn)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const NotificationPage();
                              },
                            ),
                          );
                        },
                        child: Consumer<NotificationProvider>(
                          builder: (context, notificationProvider, _) {
                            int notificationCount =
                                notificationProvider.notificationList?.length ??
                                    0;
                            return Stack(
                              children: [
                                Icon(
                                  Icons.notifications,
                                  size: isSmallScreen ? 24 : 28,
                                  color: notificationCount > 0
                                      ? Colors.amber
                                      : white,
                                ),
                                if (notificationCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(isSmallScreen ? 1 : 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: isSmallScreen ? 14 : 16,
                                        minHeight: isSmallScreen ? 14 : 16,
                                      ),
                                      child: Text(
                                        notificationCount > 99
                                            ? '99+'
                                            : notificationCount.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isSmallScreen ? 8 : 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),

                    if (isLoggedIn)
                      SizedBox(
                        width: isSmallScreen ? 15 : 20,
                      ),

                    // Profile icon - always on right
                    InkWell(
                      onTap: () {
                        AdHelper.showFullscreenAd(
                            context, Constant.interstialAdType, () {
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
                                  return Profile(
                                    isProfile: true,
                                    channelUserid: Constant.userID ?? '',
                                    channelid: "",
                                  );
                                },
                              ),
                            );
                          }
                        });
                      },
                      child: Constant.userID == null || Constant.userImage == ""
                          ? MyImage(
                              width: isSmallScreen ? 30 : 34,
                              height: isSmallScreen ? 30 : 34,
                              color: colorPrimary,
                              imagePath: "ic_user.png")
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: isSmallScreen ? 34 : 38,
                                  height: isSmallScreen ? 34 : 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: Constant.sweepGradient,
                                  ),
                                ),
                                Container(
                                  width: isSmallScreen ? 31 : 34,
                                  height: isSmallScreen ? 31 : 34,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: MyNetworkImage(
                                      fit: BoxFit.cover,
                                      width: isSmallScreen ? 28 : 31,
                                      height: isSmallScreen ? 28 : 31,
                                      imagePath: Constant.userImage ?? ""),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
