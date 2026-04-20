import 'dart:ui';

import 'package:fanbae/livestream/liveuserlist.dart';
import 'package:fanbae/pages/createmusic.dart';
import 'package:fanbae/pages/createpodcast.dart';
import 'package:fanbae/pages/createvideo.dart';
import 'package:fanbae/pages/feeds.dart';
import 'package:fanbae/pages/login.dart';
import 'package:fanbae/pages/requestcreator.dart';
import 'package:fanbae/pages/uploadfeed.dart';
import 'package:fanbae/provider/generalprovider.dart';
import 'package:fanbae/provider/homeprovider.dart';
import 'package:fanbae/provider/profileprovider.dart';
import 'package:fanbae/utils/adhelper.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/pages/shorts.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../livestream/golivepreview.dart';
import '../utils/motiontabbar.dart';
import '../utils/responsive_helper.dart';
import '../videorecord/createreels.dart';
import 'chathistory.dart';

ValueNotifier<AudioPlayer?> currentlyPlaying = ValueNotifier(null);
double playerMinHeight = (!kIsWeb) ? 70 : 90;
const miniplayerPercentageDeclaration = 0.7;

class Bottombar extends StatefulWidget {
  final bool? isLiveStream;
  final bool? isShort;
  final bool? isFeed;
  final bool? isChat;

  const Bottombar({
    super.key,
    this.isLiveStream,
    this.isShort,
    this.isFeed,
    this.isChat,
  });

  @override
  State<Bottombar> createState() => BottombarState();
}

class BottombarState extends State<Bottombar> with TickerProviderStateMixin {
  int selectedIndex = 0;
  bool showPost = false;
  double overlayHeight = 300;

  late final AnimationController _overlayCtrl;
  late final Animation<Offset> _overlaySlide;
  late final Animation<double> _overlayFade;
  SharedPre sharedPre = SharedPre();
  late GeneralProvider generalsetting;
  late ProfileProvider profileProvider;
  late HomeProvider homeProvider;
  MotionTabBarController? _motionTabBarController;

  @override
  void initState() {
    generalsetting = Provider.of<GeneralProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    _motionTabBarController = MotionTabBarController(
      length: ResponsiveHelper.isWeb(context) ? 4 : 5,
      vsync: this,
    );
    super.initState();
    _overlayCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 235),
    );

    final curved = CurvedAnimation(
      parent: _overlayCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _overlaySlide = Tween<Offset>(
      begin: const Offset(0, 1.5), // off-screen at bottom
      end: Offset.zero, // on-screen
    ).animate(curved);

    _overlayFade = CurvedAnimation(
      parent: _overlayCtrl,
      curve: Curves.easeOutQuad,
      reverseCurve: Curves.easeInQuad,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
      if (widget.isFeed == true) {
        _onItemTapped(0);
      }
      if (widget.isShort == true) {
        _onItemTapped(1);
      }

      if (widget.isLiveStream == true) {
        _onItemTapped(2);
      }
      if (widget.isChat == true) {
        _onItemTapped(3);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _setShowPost(false);
    _motionTabBarController!.dispose();
  }

  getData() async {
    pushNotification();
    if (Constant.userID != null) {
      await profileProvider.getprofile(context, Constant.userID);
      if (profileProvider.profileModel.status == 200 &&
          profileProvider.profileModel.result?.isNotEmpty == true) {
        final userProfile = profileProvider.profileModel.result!.first;
        await sharedPre.save(
            "userpanelstatus", userProfile.userPenalStatus.toString());
        Constant.userPanelStatus = await sharedPre.read("userpanelstatus");

        if (!kIsWeb) {
          await Utils.initializeHiveBoxes(context);
        }
      }
    } else {
      Utils.loadAds(context);
    }
    await generalsetting.getGeneralsetting();
    setState(() {});
  }

  pushNotification() async {
    // Pusher Beams is initialized in main.dart
    // No additional initialization needed here
    printLog("Push notification service already initialized via Pusher Beams");
  }

  static List<Widget> widgetOptions = <Widget>[
    const Feeds(),
    const Shorts(initialIndex: 0),
    const LiveUserList(),
    const ChatHistoryPage(),
    const Placeholder(),
  ];
  static List<Widget> widgetOptionsWeb = <Widget>[
    const Feeds(),
    const Shorts(initialIndex: 0),
    const ChatHistoryPage(),
    const Placeholder(),
  ];
  static List<Widget> emptyOption = <Widget>[];

  void _onItemTapped(int index) {
    AdHelper.showFullscreenAd(context, Constant.interstialAdType, () async {
      switch (index) {
        case 0:
          await homeProvider.setLoading(true);
          setState(() {
            selectedIndex = 0;
          });
          _setShowPost(false);
          break;

        case 1:
          setState(() {
            selectedIndex = 1;
          });
          _setShowPost(false);
          break;

        case 2:
          if (Constant.userID != null) {
            selectedIndex = 2;
            _setShowPost(false);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ResponsiveHelper.isWeb(context)
                        ? const WebLogin()
                        : const Login()));
          }
          break;

        case 3:
          if (!kIsWeb) {
            if (Constant.userID != null) {
              setState(() {
                selectedIndex = 3;
              });
              _setShowPost(false);
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ResponsiveHelper.isWeb(context)
                          ? const WebLogin()
                          : const Login()));
            }
          } else {
            if (Constant.userID != null) {
              if (Constant.isCreator == '1') {
                setState(() {
                  showPost == false ? _setShowPost(true) : _setShowPost(false);
                });
              } else if (profileProvider
                      .profileModel.result?.first.isCreatorRequest ==
                  1) {
                Utils().showSnackBar(context, 'Admin approval pending.', false);
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RequestCreator(email: Constant.email)));
              }
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ResponsiveHelper.isWeb(context)
                          ? const WebLogin()
                          : const Login()));
            }
          }
          break;

        case 4:
          if (Constant.userID != null) {
            if (Constant.isCreator == '1') {
              setState(() {
                showPost == false ? _setShowPost(true) : _setShowPost(false);
              });
            } else if (profileProvider
                    .profileModel.result?.first.isCreatorRequest ==
                1) {
              Utils().showSnackBar(context, 'Admin approval pending.', false);
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RequestCreator(email: Constant.email)));
            }
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ResponsiveHelper.isWeb(context)
                        ? const WebLogin()
                        : const Login()));
          }
          break;
      }
    });
  }

  _buildOverlayOptions(BuildContext context) {
    return SizedBox(
      height: !ResponsiveHelper.isWeb(context) ? 195 : 140,
      child: Stack(
        children: [
          Container(
            width: ResponsiveHelper.isTab(context)
                ? MediaQuery.of(context).size.width * 0.25
                : ResponsiveHelper.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.2
                    : MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xff6DA9F8).withOpacity(0.8),
                  const Color(0xFF01DED1).withOpacity(0.8),
                  const Color(0xffFE3379).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(2),
          ),
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(2),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: appBarColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (!ResponsiveHelper.isWeb(context))
                    GestureDetector(
                      onTap: () {
                        _setShowPost(false);
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
                                return const CreateReels();
                              },
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          MyImage(
                              width: 20,
                              height: 20,
                              imagePath: "ic_shorts.png",
                              color: white),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: MyText(
                                  text: "shorts",
                                  color: white,
                                  fontwaight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      _setShowPost(false);
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
                              return const UploadFeed(isAppBar: false);
                            },
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        MyImage(
                            width: 20,
                            height: 20,
                            imagePath: "feeds.png",
                            color: white),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: MyText(
                                text: "post",
                                color: white,
                                fontwaight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      _setShowPost(false);
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
                              return const CreateVideo();
                            },
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: white, size: 21),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: MyText(
                                text: "video",
                                color: white,
                                fontwaight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 20),
                  // GestureDetector(
                  //   onTap: () {
                  //     _setShowPost(false);
                  //     if (Constant.userID == null) {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) {
                  //             return const Login();
                  //           },
                  //         ),
                  //       );
                  //     } else {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) {
                  //             return const CreateMusic();
                  //           },
                  //         ),
                  //       );
                  //     }
                  //   },
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.music_note, size: 21, color: white),
                  //       const SizedBox(
                  //         width: 10,
                  //       ),
                  //       Expanded(
                  //           child: MyText(
                  //               text: "music",
                  //               color: white,
                  //               fontwaight: FontWeight.w600)),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 20),
                  // GestureDetector(
                  //   onTap: () {
                  //     _setShowPost(false);
                  //     if (Constant.userID == null) {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) {
                  //             return const Login();
                  //           },
                  //         ),
                  //       );
                  //     } else {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) {
                  //             return const CreatePodcast();
                  //           },
                  //         ),
                  //       );
                  //     }
                  //   },
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.mic, color: white, size: 21),
                  //       const SizedBox(
                  //         width: 10,
                  //       ),
                  //       Expanded(
                  //           child: MyText(
                  //               text: "podcast",
                  //               color: white,
                  //               fontwaight: FontWeight.w600)),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  if (!ResponsiveHelper.isWeb(context))
                    GestureDetector(
                      onTap: () {
                        _setShowPost(false);
                        if (Constant.userID == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Login();
                              },
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const GoLiveViewPreview();
                              },
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          MyImage(
                              width: 20,
                              height: 20,
                              imagePath: "livestream.png",
                              color: white),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: MyText(
                                  text: "live",
                                  color: white,
                                  fontwaight: FontWeight.w600)),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setShowPost(bool value) {
    if (showPost == value) return;
    setState(() => showPost = value);
    if (value) {
      _overlayCtrl.forward();
    } else {
      _overlayCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appbgcolor,
        body: Stack(
          children: [
            TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _motionTabBarController,
              children: kIsWeb && ResponsiveHelper.isDesktop(context)
                  ? emptyOption
                  : kIsWeb && !ResponsiveHelper.isDesktop(context)
                      ? widgetOptionsWeb
                      : widgetOptions,
            ),
            selectedIndex != 0
                ? const SizedBox.shrink()
                : Utils.buildMusicPanel(context),
            if (showPost == true)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _setShowPost(false);
                },
                onPanDown: (_) {
                  if (showPost == true) {
                    _setShowPost(false);
                  }
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  // blur strength
                  child: Container(
                    color: Colors.black.withOpacity(0.2), // dim effect
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            IgnorePointer(
              ignoring: !showPost,
              child: AnimatedBuilder(
                animation: _overlayFade,
                builder: (context, child) {
                  return Opacity(
                    opacity: _overlayFade.value,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _setShowPost(false), // tap outside to close
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                            sigmaX: 5 * _overlayFade.value,
                            sigmaY: 5 * _overlayFade.value),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black
                              .withOpacity(0.2 * _overlayFade.value),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                  position: _overlaySlide,
                  child: _buildOverlayOptions(context)),
            ),
          ],
        ),
        bottomNavigationBar: kIsWeb && ResponsiveHelper.isDesktop(context)
            ? null
            : MotionTabBar(
                controller: _motionTabBarController,
                initialSelectedTab: "Home",
                useSafeArea: true,
                labels: kIsWeb && ResponsiveHelper.isDesktop(context)
                    ? []
                    : kIsWeb && !ResponsiveHelper.isDesktop(context)
                        ? const [
                            "Home",
                            "Subscription",
                            "Add",
                            "Chat",
                          ]
                        : const [
                            "Home",
                            "Subscription",
                            "Add",
                            "Live",
                            "Chat",
                          ],
                icons: kIsWeb && ResponsiveHelper.isDesktop(context)
                    ? []
                    : kIsWeb && !ResponsiveHelper.isDesktop(context)
                        ? const [
                            "home.png",
                            "feeds.png",
                            "chat.png",
                            "ic_add.png"
                          ]
                        : const [
                            "home.png",
                            "feeds.png",
                            "livestream.png",
                            "chat.png",
                            "ic_add.png"
                          ],
                tabSize: 40,
                tabBarHeight: 60,
                textStyle: TextStyle(
                  fontSize: 11,
                  color: white,
                  fontWeight: FontWeight.w600,
                ),
                tabIconColor: white,
                tabIconSize: 25.0,
                tabIconSelectedSize: 25.0,
                //tabSelectedColor: button2color,
                selectedTabColor: const LinearGradient(
                    colors: [Color(0xFF0EB1FC), Color(0xFF01DED1)]),
                tabIconSelectedColor: pureBlack,
                tabBarColor: Constant.darkMode == "true"
                    ? const Color(0xff05060F)
                    : const Color(0xfffcfcfc),
                onTabItemSelected: (int value) {
                  if (ResponsiveHelper.isWeb(context)
                      ? value == 3
                      : value == 4) {
                    _onItemTapped(value);
                    return;
                  }

                  setState(() {
                    _onItemTapped(value);
                    _motionTabBarController!.index = value;
                  });
                },
              ),
      ),
    );
  }

  BottomNavigationBarItem bottomIcon({title, iconName}) {
    return BottomNavigationBarItem(
      backgroundColor: appbgcolor,
      label: '',
      activeIcon: Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle, gradient: Constant.gradientColor),
        child: Iconify(
          iconName,
          color: black,
          size: Dimens.iconbottomNav,
        ),
      ),
      icon: Container(
        margin: const EdgeInsets.only(top: 10),
        child: Iconify(
          iconName,
          color: white,
          size: Dimens.iconbottomNav,
        ),
      ),
    );
  }
}
