import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fanbae/pages/commonpage.dart';
import 'package:fanbae/pages/history.dart';
import 'package:fanbae/pages/likevideos.dart';
import 'package:fanbae/pages/login.dart';
import 'package:fanbae/music/musicdetails.dart';
import 'package:fanbae/pages/mydownloads.dart';
import 'package:fanbae/pages/myplaylist.dart';
import 'package:fanbae/pages/statistics.dart';
import 'package:fanbae/pages/subscibedchannel.dart';
import 'package:fanbae/pages/subscribe_channels.dart';
import 'package:fanbae/pages/subscribing_channels.dart';
import 'package:fanbae/pages/viewads.dart';
import 'package:fanbae/pages/viewmembershipplan.dart';
import 'package:fanbae/pages/viewratings.dart';
import 'package:fanbae/provider/profileprovider.dart';
import 'package:fanbae/subscription/adspackage.dart';
import 'package:fanbae/subscription/modifychannel.dart';
import 'package:fanbae/subscription/subscription.dart';
import 'package:fanbae/provider/settingprovider.dart';
import 'package:fanbae/utils/adhelper.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/video_audio_call/ScheduleCall.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:fanbae/pages/watchlater.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../model/successmodel.dart';
import '../provider/themeprovider.dart';
import '../utils/responsive_helper.dart';
import '../webpages/weblogin.dart';
import '../webservice/apiservice.dart';
import 'bottombar.dart';
import 'earnings.dart';
import 'explore.dart';
import 'followers.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double? width, height;
  late SettingProvider settingProvider;
  late ProfileProvider profileProvider;
  String? userName, userType, userMobileNo;
  final playlistTitleController = TextEditingController();
  bool isPublic = false;
  bool isPrivate = false;
  String playlistType = "0";
  SharedPre sharedPref = SharedPre();
  final passwordController = TextEditingController();
  static const List<String> _safetySlugs = [
    "complaint-policy",
    "appeal-policy",
    "report-abuse-flow",
    "dmca-takedown-request-form",
    "dmca-takedown-request",
    "dmca-takedown",
    "dmca",
    "takedown-request",
  ];
  static const List<String> _businessPolicySlugs = [
    "platform-to-business-policy",
  ];
  static const List<String> _helpCenterSlugs = [
    "faq-user",
    "faq-creator",
    "community-guidelines",
    "acceptable-use-policy",
  ];
  static const List<String> _policyOnlyPageSlugs = [
    "terms-and-conditions",
    "privacy-policy",
    "cookie-policy",
    "child-safety-csam-policy",
    "anti-trafficking-anti-coercion-policy",
    "global-tax-vat-policy",
  ];
  static const List<Color> _policyColors = [
    Color(0xff2474D0),
    Color(0xff19AFBD),
    Color(0xffE625A6),
    Color(0xffF7AF13),
    Color(0xffB000EA),
    Color(0xff01DED1),
    Color(0xff38A66F),
    Color(0xff771CF6),
  ];

  Color _colorForIndex(int index) {
    return _policyColors[index % _policyColors.length];
  }

  bool _isSafetyPage(dynamic page) {
    final url = (page.url ?? "").toString().toLowerCase();
    final pageName = (page.pageName ?? "").toString().toLowerCase();
    final title = (page.title ?? "").toString().toLowerCase();
    final normalizedTitle = title.replaceAll('-', ' ');
    return _safetySlugs.any((slug) =>
            url.contains(slug) ||
            pageName == slug ||
            title.contains(slug.replaceAll('-', ' '))) ||
        normalizedTitle.contains('dmca') ||
        normalizedTitle.contains('takedown');
  }

  bool _isBusinessPolicyPage(dynamic page) {
    final url = (page.url ?? "").toString().toLowerCase();
    final pageName = (page.pageName ?? "").toString().toLowerCase();
    final title = (page.title ?? "").toString().toLowerCase();
    final normalizedUrl = url.replaceAll(RegExp('[-_]'), ' ');
    final normalizedPageName = pageName.replaceAll(RegExp('[-_]'), ' ');
    final normalizedTitle = title.replaceAll(RegExp('[-_]'), ' ');
    return _businessPolicySlugs.any((slug) =>
            url.contains(slug) ||
            pageName == slug ||
            title.contains(slug.replaceAll('-', ' '))) ||
        normalizedUrl.contains('platform to business') ||
        normalizedPageName.contains('platform to business') ||
        normalizedTitle.contains('platform to business') ||
        normalizedUrl.contains('p2b') ||
        normalizedPageName.contains('p2b') ||
        normalizedTitle.contains('p2b');
  }

  bool _isHelpCenterPage(dynamic page) {
    final url = (page.url ?? "").toString().toLowerCase();
    final pageName = (page.pageName ?? "").toString().toLowerCase();
    final title = (page.title ?? "").toString().toLowerCase();
    final normalizedUrl = url.replaceAll(RegExp('[-_]'), ' ');
    final normalizedPageName = pageName.replaceAll(RegExp('[-_]'), ' ');
    final normalizedTitle = title.replaceAll(RegExp('[-_]'), ' ');
    return _helpCenterSlugs.any((slug) =>
            url.contains(slug) ||
            pageName == slug ||
            title.contains(slug.replaceAll('-', ' '))) ||
        normalizedUrl.contains('faq') ||
        normalizedPageName.contains('faq') ||
        normalizedTitle.contains('faq') ||
        normalizedUrl.contains('community guidelines') ||
        normalizedPageName.contains('community guidelines') ||
        normalizedTitle.contains('community guidelines') ||
        normalizedUrl.contains('acceptable use') ||
        normalizedPageName.contains('acceptable use') ||
        normalizedTitle.contains('acceptable use');
  }

  bool _isPolicyPage(dynamic page) {
    final url = (page.url ?? "").toString().toLowerCase();
    final pageName = (page.pageName ?? "").toString().toLowerCase();
    final title = (page.title ?? "").toString().toLowerCase();
    final normalizedUrl = url.replaceAll(RegExp('[-_]'), ' ');
    final normalizedPageName = pageName.replaceAll(RegExp('[-_]'), ' ');
    final normalizedTitle = title.replaceAll(RegExp('[-_]'), ' ');
    return _policyOnlyPageSlugs.any((slug) =>
            url.contains(slug) ||
            pageName == slug ||
            title.contains(slug.replaceAll('-', ' '))) ||
        normalizedUrl.contains('terms') ||
        normalizedPageName.contains('terms') ||
        normalizedTitle.contains('terms') ||
        normalizedUrl.contains('privacy') ||
        normalizedPageName.contains('privacy') ||
        normalizedTitle.contains('privacy') ||
        normalizedUrl.contains('cookie') ||
        normalizedPageName.contains('cookie') ||
        normalizedTitle.contains('cookie') ||
        normalizedUrl.contains('child safety') ||
        normalizedPageName.contains('child safety') ||
        normalizedTitle.contains('child safety') ||
        normalizedUrl.contains('anti-trafficking') ||
        normalizedPageName.contains('anti-trafficking') ||
        normalizedTitle.contains('anti-trafficking') ||
        normalizedUrl.contains('tax') ||
        normalizedPageName.contains('tax') ||
        normalizedTitle.contains('tax');
  }

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    settingProvider = Provider.of<SettingProvider>(context, listen: false);
    super.initState();
    getApi();
  }

  getApi() async {
    await profileProvider.getprofile(context, Constant.userID.toString());
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: MyText(
          text: "usermenus",
          color: white,
          fontwaight: FontWeight.bold,
          fontsizeNormal: Dimens.textBig,
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: white,
          ),
        ),
      ),
      body: Utils().pageBg(
        context,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 200),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              subscriptionDisc(),
              const SizedBox(
                height: 10,
              ),
              Constant.userID == null
                  ? const SizedBox.shrink()
                  : settingItem("explore.png", "explore", false, () {
                      Utils().showInterstitalAds(
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
                                return const ExploreChannels();
                              },
                            ),
                          );
                        }
                      });
                    }, const Color(0xff8000f8)),
              if (Constant.isCreator == '1')
                Constant.userID == null
                    ? const SizedBox.shrink()
                    : settingItem("earning.png", "earnings", false, () {
                        Utils().showInterstitalAds(
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
                                  return const Earnings(
                                    appBarView: true,
                                  );
                                },
                              ),
                            );
                          }
                        });
                      }, const Color(0xd21900fd)),
              Constant.userID == null
                  ? const SizedBox.shrink()
                  : settingItem("history.png", "history", false, () {
                      Utils().showInterstitalAds(
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
                                return const History();
                              },
                            ),
                          );
                        }
                      });
                    }, const Color(0xffEAAD00)),
              /* Download Page */
              Constant.userID == null
                  ? const SizedBox.shrink()
                  : Constant.isDownload == "1"
                      ? settingItem("ic_download.png", "download", false, () {
                          Utils().showInterstitalAds(
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
                              navigatorKey.currentState?.push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const MyDownloads();
                                  },
                                ),
                              );
                            }
                          });
                        }, const Color(0xff771CF6))
                      : const SizedBox.shrink(),
              /* SubscriberList Page */
              Constant.userID == null
                  ? const SizedBox.shrink()
                  : settingItem("person_plus.png", "following", false, () {
                      Utils().showInterstitalAds(
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
                                return const SubscribedChannel();
                              },
                            ),
                          );
                        }
                      });
                    }, const Color(0xfff500fd)),
              if (Constant.isCreator == '1')
                Constant.userID == null
                    ? const SizedBox.shrink()
                    : settingItem("followers.png", "followers", false, () {
                        Utils().showInterstitalAds(
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
                                  return const Followers();
                                },
                              ),
                            );
                          }
                        });
                      }, const Color(0xff6819bd)),
              //Subscribing channels                                                                                                                                                                                                                                                                                                                                      ................................................................................................................................................................................................................................................................................................................................................................................................................................................
              Constant.userID != null
                  ? settingItem("subscription.png", "user_subscribing", false,
                      () {
                      Utils().showInterstitalAds(
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
                                return const SubscribingChannels();
                              },
                            ),
                          );
                        }
                      });
                    }, const Color(0xa1bd1963))
                  : const SizedBox.shrink(),

              /// View subscribed users of your channel
              if (Constant.isCreator == '1')
                Constant.userID == null
                    ? const SizedBox.shrink()
                    : settingItem("ic_subscriber.png", "subscribers", false,
                        () {
                        Utils().showInterstitalAds(
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
                                  return const SubscribeChannels();
                                },
                              ),
                            );
                          }
                        });
                      }, const Color(0xff19AFBD)),
              /* Wallet Page */
              Constant.userID == null
                  ? const SizedBox.shrink()
                  : Consumer<ProfileProvider>(
                      builder: (context, profileProvider, child) {
                      return settingItem(
                          "ic_walletborder.png", "mywallet", false, () {
                        Utils().showInterstitalAds(
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
                                  return const AdsPackage();
                                },
                              ),
                            );
                          }
                        });
                      }, const Color(0xff6E13F7));
                    }),
              /* subscription Page */
              Constant.userID == null
                  ? const SizedBox.shrink()
                  : Consumer<ProfileProvider>(
                      builder: (context, profileProvider, child) {
                      return settingItem1(
                          "subscription.png", "platform_subscription", false,
                          () {
                        AdHelper.showFullscreenAd(
                            context, Constant.interstialAdType, () async {
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
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Subscription();
                                },
                              ),
                            );
                            setState(() {
                              getApi();
                            });
                          }
                        });
                      }, const Color(0xFF01DED1));
                    }),
              /* schedule call page*/
              Constant.userID == null
                  ? const SizedBox.shrink()
                  : settingItem("schedule.png", "schedulecall", false, () {
                      Utils().showInterstitalAds(
                          context, Constant.interstialAdType, () {
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
                                return const ScheduleCall(isCreator: true);
                              },
                            ),
                          );
                        }
                      });
                    }, const Color(0xffc82c2c)),
              /* rent Page */
              /*         Constant.userID == null
                  ? const SizedBox.shrink()
                  : settingItem("rent.png", "rent", false, () {
                      Utils().showInterstitalAds(
                          context, Constant.interstialAdType, () {
                        if (Constant.userID == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const ResponsiveHelper.isWeb(context)? const WebLogin():const Login();
                              },
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Rent();
                              },
                            ),
                          );
                        }
                      });
                    }, const Color(0xffE625A6)),*/
              /* Ads Page */
              Constant.userID != null
                  ? Constant.isCreator != "1"
                      ? const SizedBox.shrink()
                      : settingItem("ad.png", "ads", false, () {
                          Utils().showInterstitalAds(
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
                                    return const ViewAds();
                                  },
                                ),
                              );
                            }
                          });
                        }, const Color(0xff2474D0))
                  : SizedBox(),
              /* myplaylist Page */
              // Constant.userID == null
              //     ? const SizedBox.shrink()
              //     : settingItem("ic_playlisttitle.png", "myplaylist", false,
              //         () {
              //       AdHelper.showFullscreenAd(
              //           context, Constant.interstialAdType, () {
              //         if (Constant.userID == null) {
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) {
              //                 return ResponsiveHelper.isWeb(context)
              //                     ? const WebLogin()
              //                     : const Login();
              //               },
              //             ),
              //           );
              //         } else {
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) {
              //                 return const MyPlayList();
              //               },
              //             ),
              //           );
              //         }
              //       });
              //     }, const Color(0xFF01DED1)),
              /* watchlater Page */
              Constant.userID == null
                  ? const SizedBox.shrink()
                  : settingItem("ic_watchlater.png", "watchlater", false, () {
                      Utils().showInterstitalAds(
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
                                return const WatchLater();
                              },
                            ),
                          );
                        }
                      });
                    }, const Color(0xff38A66F)),
              /* likevideos Page */
              Constant.userID == null
                  ? const SizedBox.shrink()
                  : settingItem("heart.png", "likevideos", false, () {
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
                                return const LikeVideos();
                              },
                            ),
                          );
                        }
                      });
                    }, const Color(0xffF7AF13)),
              /* UserPanel Dilog Sheet */
              /*    Consumer<SettingProvider>(
                  builder: (context, profileprovider, child) {
                if (Constant.userID == null) {
                  return const SizedBox.shrink();
                } else {
                  if (profileprovider.loading) {
                    return const SizedBox.shrink();s
                  } else {
                    return settingItem("userpanel.png", "userpanel", false, () {
                      printLog("userpanal==>${Constant.userPanelStatus}");
                      if (Constant.userPanelStatus == "0" ||
                          Constant.userPanelStatus == "" ||
                          Constant.userPanelStatus == null) {
                        userPanelActiveDilog();
                      } else {
                        edituserPanelDilog();
                      }
                    });
                  }
                }
              }),*/
              // /* chooselanguage Bottom Sheet */
              settingItem("ic_link.png", "chooselanguage", false, () {
                _languageChangeDialog();
              }, const Color(0xffF38081)),
              /* Delete Account */
              Constant.userID == null
                  ? const SizedBox.shrink()
                  : settingItem(
                      "ic_delete.png",
                      Constant.userID != null
                          ? "deleteaccount"
                          : "deleteaccount",
                      false, () {
                      deleteConfirmDialog();
                    }, const Color(0xff771CF6)),
              /* Login Logout */
              settingItem("ic_logout.png",
                  Constant.userID != null ? "logout" : "login", false, () {
                Constant.userID != null
                    ? logoutConfirmDialog()
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ResponsiveHelper.isWeb(context)
                                    ? const WebLogin()
                                    : const Login()));
              }, const Color(0xffFD676A)),
              // Consumer<ThemeProvider>(
              //   builder: (context, provider, child) {
              //     return SwitchListTile(
              //       activeColor: colorPrimary,
              //       title: Padding(
              //         padding: const EdgeInsets.only(left: 6.5),
              //         child: MyText(
              //             text: "Dark Mode",
              //             color: white,
              //             multilanguage: false),
              //       ),
              //       value: Constant.darkMode == 'true' ? true : false,
              //       onChanged: (val) {
              //         provider.toggleTheme(val);
              //         Navigator.pushAndRemoveUntil(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) => const Bottombar(),
              //           ),
              //           (Route<dynamic> route) => false,
              //         );
              //       },
              //     );
              //   },
              // ),
              Constant.isCreator == "1"
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: 22, top: 15.0, bottom: 15),
                      child: MyText(
                        text: "contentcreatormenus",
                        color: white,
                        fontsizeNormal: Dimens.textBig,
                        fontwaight: FontWeight.bold,
                      ),
                    )
                  : const SizedBox(),
              //statistics
              Constant.isCreator == "1"
                  ? settingItem("statistics.png", "dashboard", false, () {
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
                                return const Statistics();
                              },
                            ),
                          );
                        }
                      });
                    }, const Color(0xFF01DED1))
                  : const SizedBox(),
              //membership plan
              Constant.isCreator == "1"
                  ? settingItem("membership.png", "membershipplan", false, () {
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
                                return ViewMembershipPlan(
                                    isUser: true,
                                    creatorId: Constant.userID.toString());
                              },
                            ),
                          );
                        }
                      });
                    }, const Color(0xffE625A6))
                  : const SizedBox(),
              /* ratings page*/
              Constant.isCreator == "1"
                  ? Constant.userID == null
                      ? const SizedBox.shrink()
                      : settingItem("star.png", "rating", false, () {
                          Utils().showInterstitalAds(
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
                                    return ViewRatings(
                                        id: Constant.userID != null
                                            ? int.parse(Constant.userID!)
                                            : 0);
                                  },
                                ),
                              );
                            }
                          });
                        }, const Color(0xffB000EA))
                  : const SizedBox(),
              //    subsciptionDisc(),
              /* Safety Policies */
              buildSafetyAccordion(),
              /* Business & Platform Policies */
              buildBusinessPoliciesAccordion(),
              /* Help Center */
              buildHelpCenterAccordion(),
              /* Get Pages Api*/
              buildPagesAccordion(),
              socialLinkList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPagesAccordion() {
    return Consumer<SettingProvider>(
        builder: (context, settingprovider, child) {
      if (settingprovider.getpagesModel.result == null ||
          settingprovider.getpagesModel.result!.isEmpty) {
        return const SizedBox.shrink();
      }

      final pages = settingprovider.getpagesModel.result!;
      final filteredPages = pages.where((page) => _isPolicyPage(page)).toList();

      if (filteredPages.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        decoration: BoxDecoration(
          border: Border.all(color: colorPrimary.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF00DAFA),
              radius: 17,
              child: Icon(
                Icons.policy,
                color: pureWhite,
                size: 20,
              ),
            ),
            title: MyText(
              color: white,
              text: "Policy",
              textalign: TextAlign.left,
              fontsizeNormal: 15,
              multilanguage: false,
              inter: false,
              maxline: 1,
              fontwaight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
            iconColor: white,
            collapsedIconColor: white,
            children: [
              ...List.generate(
                filteredPages.length,
                (index) => InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return CommonPage(
                            title: filteredPages[index].title?.toString() ?? "",
                            url: filteredPages[index].url?.toString() ?? "",
                            multilanguage: false,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colorPrimary.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _colorForIndex(index),
                          radius: 17,
                          child: MyNetworkImage(
                            width: 22,
                            height: 22,
                            imagePath:
                                filteredPages[index].icon?.toString() ?? "",
                            color: pureWhite,
                            isPagesIcon: true,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: MyText(
                            color: white.withOpacity(0.9),
                            text: filteredPages[index].title?.toString() ?? "",
                            textalign: TextAlign.left,
                            fontsizeNormal: 14,
                            multilanguage: false,
                            inter: false,
                            maxline: 3,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.visible,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: white.withOpacity(0.5),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildSafetyAccordion() {
    return Consumer<SettingProvider>(
        builder: (context, settingprovider, child) {
      final pages = settingprovider.getpagesModel.result ?? [];
      final safetyPages = pages.where((page) => _isSafetyPage(page)).toList();

      if (safetyPages.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        decoration: BoxDecoration(
          border: Border.all(color: colorPrimary.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFFF024),
              radius: 17,
              child: Icon(
                Icons.safety_check,
                color: pureWhite,
                size: 20,
              ),
            ),
            title: MyText(
              color: white,
              text: "Safety",
              textalign: TextAlign.left,
              fontsizeNormal: 15,
              multilanguage: false,
              inter: false,
              maxline: 1,
              fontwaight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
            iconColor: white,
            collapsedIconColor: white,
            children: safetyPages
                .asMap()
                .entries
                .map((entry) => _buildPolicyDynamicItem(
                      title: entry.value.title?.toString() ?? "",
                      url: entry.value.url?.toString() ?? "",
                      icon: entry.value.icon?.toString(),
                      color: _colorForIndex(entry.key),
                    ))
                .toList(),
          ),
        ),
      );
    });
  }

  Widget buildBusinessPoliciesAccordion() {
    return Consumer<SettingProvider>(
        builder: (context, settingprovider, child) {
      final pages = settingprovider.getpagesModel.result ?? [];
      final businessPages =
          pages.where((page) => _isBusinessPolicyPage(page)).toList();

      if (businessPages.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        decoration: BoxDecoration(
          border: Border.all(color: colorPrimary.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFE0009C),
              radius: 17,
              child: Icon(
                Icons.business_center,
                color: pureWhite,
                size: 20,
              ),
            ),
            title: MyText(
              color: white,
              text: "Business & Platform Policies",
              textalign: TextAlign.left,
              fontsizeNormal: 15,
              multilanguage: false,
              inter: false,
              maxline: 1,
              fontwaight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
            iconColor: white,
            collapsedIconColor: white,
            children: businessPages
                .asMap()
                .entries
                .map((entry) => _buildPolicyDynamicItem(
                      title: entry.value.title?.toString() ?? "",
                      url: entry.value.url?.toString() ?? "",
                      icon: entry.value.icon?.toString(),
                      color: _colorForIndex(entry.key),
                    ))
                .toList(),
          ),
        ),
      );
    });
  }

  Widget buildHelpCenterAccordion() {
    return Consumer<SettingProvider>(
        builder: (context, settingprovider, child) {
      final pages = settingprovider.getpagesModel.result ?? [];
      final helpCenterPages =
          pages.where((page) => _isHelpCenterPage(page)).toList();

      if (helpCenterPages.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        decoration: BoxDecoration(
          border: Border.all(color: colorPrimary.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF919191),
              radius: 17,
              child: Icon(
                Icons.help,
                color: pureWhite,
                size: 20,
              ),
            ),
            title: MyText(
              color: white,
              text: "Help Center",
              textalign: TextAlign.left,
              fontsizeNormal: 15,
              multilanguage: false,
              inter: false,
              maxline: 1,
              fontwaight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
            iconColor: white,
            collapsedIconColor: white,
            children: helpCenterPages
                .asMap()
                .entries
                .map((entry) => _buildPolicyDynamicItem(
                      title: entry.value.title?.toString() ?? "",
                      url: entry.value.url?.toString() ?? "",
                      icon: entry.value.icon?.toString(),
                      color: _colorForIndex(entry.key),
                    ))
                .toList(),
          ),
        ),
      );
    });
  }

  Widget _buildPolicyDynamicItem({
    required String title,
    required String url,
    String? icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CommonPage(
                title: title,
                url: url,
                multilanguage: false,
              );
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorPrimary.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            icon != null && icon.isNotEmpty
                ? CircleAvatar(
                    backgroundColor: color,
                    radius: 17,
                    child: MyNetworkImage(
                      width: 22,
                      height: 22,
                      imagePath: icon,
                      color: pureWhite,
                      isPagesIcon: true,
                      fit: BoxFit.contain,
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: color,
                    radius: 17,
                    child: Icon(
                      Icons.policy_outlined,
                      color: pureWhite,
                      size: 20,
                    ),
                  ),
            const SizedBox(width: 15),
            Expanded(
              child: MyText(
                color: white.withOpacity(0.9),
                text: title,
                textalign: TextAlign.left,
                fontsizeNormal: 14,
                multilanguage: false,
                inter: false,
                maxline: 3,
                fontwaight: FontWeight.w400,
                overflow: TextOverflow.visible,
                fontstyle: FontStyle.normal,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: white.withOpacity(0.5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPages() {
    return Consumer<SettingProvider>(
        builder: (context, settingprovider, child) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView.builder(
            itemCount: settingprovider.getpagesModel.result?.length ?? 0,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return settingItem(
                  settingprovider.getpagesModel.result?[index].icon
                          .toString() ??
                      "",
                  settingprovider.getpagesModel.result?[index].title
                          .toString() ??
                      "",
                  true, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CommonPage(
                        title: settingprovider
                                .getpagesModel.result?[index].title
                                .toString() ??
                            "",
                        url: settingprovider.getpagesModel.result?[index].url
                                .toString() ??
                            "",
                        multilanguage: false,
                      );
                    },
                  ),
                );
              },
                  index % 2 == 0
                      ? const Color(0xff2474D0)
                      : const Color(0xff19AFBD));
            }),
      );
    });
  }

  Widget settingItem(
      String imagepath, String title, bool isPages, onTap, Color color) {
    return InkWell(
      /*hoverColor: colorPrimary,
      highlightColor: colorPrimary,*/
      autofocus: true,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        child: Row(
          children: [
            isPages == true
                ? CircleAvatar(
                    backgroundColor: color,
                    radius: 17,
                    child: MyNetworkImage(
                      width: 22,
                      height: 22,
                      imagePath: imagepath,
                      color: pureWhite,
                      isPagesIcon: false,
                      fit: BoxFit.contain,
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: color,
                    radius: 17,
                    child: MyImage(
                      width: 20,
                      height: 20,
                      imagePath: imagepath,
                      color: pureWhite,
                    ),
                  ),
            const SizedBox(width: 15),
            MyText(
                color: white,
                text: title,
                textalign: TextAlign.left,
                fontsizeNormal: 15,
                multilanguage: isPages == true ? false : true,
                inter: false,
                maxline: 2,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
          ],
        ),
      ),
    );
  }

  Widget settingItem1(
      String imagepath, String title, bool isPages, onTap, Color color) {
    return InkWell(
      /*hoverColor: colorPrimary,
      highlightColor: colorPrimary,*/
      autofocus: true,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        child: Row(
          children: [
            isPages == true
                ? CircleAvatar(
                    backgroundColor: color,
                    radius: 17,
                    child: MyNetworkImage(
                      width: 22,
                      height: 22,
                      imagePath: imagepath,
                      color: pureWhite,
                      isPagesIcon: false,
                      fit: BoxFit.contain,
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: color,
                    radius: 17,
                    child: MyImage(
                      width: 80,
                      height: 80,
                      imagePath: imagepath,
                      color: pureWhite,
                    ),
                  ),
            const SizedBox(width: 15),
            MyText(
                color: white,
                text: title,
                textalign: TextAlign.left,
                fontsizeNormal: 15,
                multilanguage: isPages == true ? false : true,
                inter: false,
                maxline: 2,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
          ],
        ),
      ),
    );
  }

  Widget languageItem(onTap, title) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
        decoration: BoxDecoration(
          // color: colorAccent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 1, color: colorPrimary),
        ),
        alignment: Alignment.center,
        child: MyText(
            color: white,
            text: title,
            textalign: TextAlign.left,
            fontsizeNormal: 16,
            multilanguage: true,
            inter: false,
            maxline: 2,
            fontwaight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal),
      ),
    );
  }

  userPanelActiveDilog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          insetAnimationCurve: Curves.bounceInOut,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            width: MediaQuery.of(context).size.width * 0.90,
            height: 320,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorPrimary.withOpacity(0.10),
            ),
            child: Consumer<SettingProvider>(
                builder: (context, settingprovider, child) {
              return Column(
                children: [
                  MyText(
                      color: white,
                      text: "userpanel",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textExtraBig,
                      multilanguage: true,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 25),
                  TextField(
                    cursorColor: white,
                    obscureText: settingprovider.isPasswordVisible,
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    style: Utils.googleFontStyle(1, Dimens.textBig,
                        FontStyle.normal, white, FontWeight.w500),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          color: white,
                          settingprovider.isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          settingprovider.passwordHideShow();
                        },
                      ),
                      hintText: "Give your User Panel Password",
                      hintStyle: Utils.googleFontStyle(1, Dimens.textBig,
                          FontStyle.normal, gray, FontWeight.w500),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      MyText(
                          color: white,
                          multilanguage: true,
                          text: "status",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
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
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          settingprovider.selectUserPanel("on", true);
                          printLog("type==>${settingprovider.isActiveType}");
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: settingprovider.isUserpanelType == "on" &&
                                      settingprovider.isActive == true
                                  ? colorPrimary
                                  : colorPrimaryDark,
                              shape: BoxShape.circle),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "on",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textTitle,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          settingprovider.selectUserPanel("off", true);
                          printLog("type==>${settingprovider.isActiveType}");
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: settingprovider.isUserpanelType == "off" &&
                                      settingprovider.isActive == true
                                  ? colorPrimary
                                  : colorPrimaryDark,
                              shape: BoxShape.circle),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "off",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textTitle,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        radius: 50,
                        autofocus: false,
                        onTap: () {
                          Navigator.pop(context);
                          settingprovider.clearUserPanel();
                          passwordController.clear();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorPrimaryDark,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorPrimary.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5, //New
                              )
                            ],
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "cancel",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () async {
                            if (passwordController.text.isEmpty) {
                              Utils().showSnackBar(
                                  context, "pleaseenteryourpassword", true);
                            } else if (passwordController.text.length < 6) {
                              Utils().showSnackBar(
                                  context, "passwordmustbesixcharecter", true);
                            } else if (settingprovider.isUserpanelType ==
                                "off") {
                              Utils().showSnackBar(
                                  context, "pleaseselectuserpanelstatus", true);
                            } else {
                              /* Userpanal Api */
                              await settingProvider.getActiveUserPanel(
                                  passwordController.text,
                                  settingprovider.isActiveType);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              settingprovider.clearUserPanel();
                              passwordController.clear();
                              Utils().showSnackBar(context,
                                  "userpanalactivesuccsessfully", true);

                              await profileProvider.getprofile(
                                  context, Constant.userID);

                              await sharedPref.save(
                                  "userpanelstatus",
                                  profileProvider.profileModel.result?[0]
                                          .userPenalStatus
                                          .toString() ??
                                      "");
                              Constant.userPanelStatus =
                                  await sharedPref.read("userpanelstatus");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(
                              color: colorPrimary,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: colorPrimary.withOpacity(0.40),
                                  blurRadius: 10.0,
                                  spreadRadius: 0.5,
                                )
                              ],
                            ),
                            child: MyText(
                                color: colorAccent,
                                multilanguage: true,
                                text: "active",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textBig,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
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

  edituserPanelDilog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          insetAnimationCurve: Curves.bounceInOut,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            width: MediaQuery.of(context).size.width * 0.90,
            height: 240,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorPrimary.withOpacity(0.10),
            ),
            child: Consumer<SettingProvider>(
                builder: (context, settingprovider, child) {
              return Column(
                children: [
                  MyText(
                      color: white,
                      text: "changepassword",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textExtraBig,
                      multilanguage: true,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 25),
                  TextField(
                    cursorColor: white,
                    obscureText: settingprovider.isPasswordVisible,
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    style: Utils.googleFontStyle(1, Dimens.textBig,
                        FontStyle.normal, white, FontWeight.w500),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          color: white,
                          settingprovider.isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          settingprovider.passwordHideShow();
                        },
                      ),
                      hintText: "Edit User Panel Password",
                      hintStyle: Utils.googleFontStyle(1, Dimens.textBig,
                          FontStyle.normal, gray, FontWeight.w500),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        radius: 50,
                        autofocus: false,
                        onTap: () {
                          Navigator.pop(context);
                          passwordController.clear();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorPrimaryDark,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorPrimary.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5, //New
                              )
                            ],
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "cancel",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () async {
                            if (passwordController.text.isEmpty) {
                              Utils().showSnackBar(
                                  context, "pleaseenteryourpassword", true);
                            } else if (passwordController.text.length < 6) {
                              Utils().showSnackBar(
                                  context, "passwordmustbesixcharecter", true);
                            } else {
                              /* Userpanal Api */
                              await settingProvider.getActiveUserPanel(
                                  passwordController.text, "1");
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              passwordController.clear();
                              Utils().showSnackBar(
                                  context, "passwordchangesuccsessfully", true);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(
                              color: colorPrimary,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: colorPrimary.withOpacity(0.40),
                                  blurRadius: 10.0,
                                  spreadRadius: 0.5,
                                )
                              ],
                            ),
                            child: MyText(
                                color: colorAccent,
                                multilanguage: true,
                                text: "edit",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textBig,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
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

  _languageChangeDialog() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, state) {
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: colorPrimaryDark,
                    padding: const EdgeInsets.all(23),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "selectlanguage",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: Dimens.textTitle,
                          fontwaight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),

                        /* English */
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "English",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('en');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Afrikaans */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Afrikaans",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('af');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Arabic */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Arabic",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('ar');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* German */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "German",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('de');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Spanish */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Spanish",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('es');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* French */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "French",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('fr');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Gujarati */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Gujarati",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('gu');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Hindi */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Hindi",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('hi');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Indonesian */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Indonesian",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('id');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Dutch */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Dutch",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('nl');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Portuguese (Brazil) */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Portuguese (Brazil)",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('pt');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Albanian */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Albanian",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('sq');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Turkish */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Turkish",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('tr');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Vietnamese */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Vietnamese",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('vi');
                                    Navigator.pop(context);
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLanguage({
    required String langName,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: colorPrimary,
            width: .5,
          ),
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(5),
        ),
        child: MyText(
          color: white,
          text: langName,
          textalign: TextAlign.center,
          fontsizeNormal: Dimens.textTitle,
          multilanguage: false,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontwaight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  logoutConfirmDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              color: colorPrimaryDark,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "confirmsognout",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: Dimens.textTitle,
                          fontwaight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        MyText(
                          color: white,
                          text: "areyousurewanrtosignout",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: Dimens.textSmall,
                          fontwaight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDialogBtn(
                          title: 'cancel',
                          isPositive: false,
                          isMultilang: true,
                          onClick: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildDialogBtn(
                          title: 'logout',
                          isPositive: true,
                          isMultilang: true,
                          onClick: () async {
                            Navigator.pop(context);

                            // Clear user session immediately
                            Constant.userID = null;
                            await Utils.setUserId(null);

                            // Navigate to login
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ResponsiveHelper.isWeb(context)
                                        ? const WebLogin()
                                        : const Login(),
                              ),
                              (route) => false,
                            );

                            // Background cleanup (non-blocking)
                            Future.microtask(() async {
                              try {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.clear();
                              } catch (_) {}

                              try {
                                await _auth.signOut();
                              } catch (_) {}

                              try {
                                await GoogleSignIn().signOut();
                              } catch (_) {}

                              try {
                                await Utils.clearUserCreds();
                              } catch (_) {}

                              try {
                                audioPlayer.stop();
                                audioPlayer.pause();
                              } catch (_) {}
                            });
                          },
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
    ).then((value) {
      if (!mounted) return;
      Utils.loadAds(context);
      setState(() {});
    });
  }

  deleteConfirmDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              color: colorPrimaryDark,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "deleteaccount",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: Dimens.textTitle,
                          fontwaight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        MyText(
                          color: white,
                          text: "are_you_sure_want_to_delete_account?",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: Dimens.textSmall,
                          fontwaight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDialogBtn(
                          title: 'cancel',
                          isPositive: false,
                          isMultilang: true,
                          onClick: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildDialogBtn(
                          title: 'deleteaccount',
                          isPositive: true,
                          isMultilang: true,
                          onClick: () async {
                            final profileProvider =
                                Provider.of<ProfileProvider>(context,
                                    listen: false);
                            try {
                              await settingProvider
                                  .deleteAccount(Constant.userID);

                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(Constant.userID.toString())
                                  .delete();

                              // (Optional) Realtime DB if you use it
                              // await FirebaseDatabase.instance.ref("users/${Constant.userID}").remove();

                              final googleSignIn = GoogleSignIn();
                              if (await googleSignIn.isSignedIn()) {
                                await googleSignIn.signOut();
                              }

                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.clear();
                              await profileProvider.clearProvider();
                              Constant.userID = null;

                              audioPlayer.stop();
                              audioPlayer.pause();

                              if (!context.mounted) return;

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ResponsiveHelper.isWeb(context)
                                            ? const WebLogin()
                                            : const Login()),
                                (route) => false,
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              print("Delete account error: $e");
                              Utils().showSnackBar(context,
                                  "Failed to delete account: $e", false);
                            }
                          },
                        )
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
  }

  Widget _buildDialogBtn({
    required String title,
    required bool isPositive,
    required bool isMultilang,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Container(
        constraints: const BoxConstraints(minWidth: 75),
        height: 50,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: isPositive ? colorPrimary : transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 0.5, color: white)),
        child: MyText(
          color: isPositive ? colorAccent : white,
          text: title,
          multilanguage: isMultilang,
          textalign: TextAlign.center,
          fontsizeNormal: Dimens.textTitle,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontwaight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  Widget subscriptionDisc() {
    if (Constant.userID != null) {
      if (profileProvider.loading) {
        return const SizedBox.shrink();
      } else {
        if (profileProvider.profileModel.result?[0].isBuy == 1) {
          String formattedDate = '';
          if (profileProvider.profileModel.result?[0].expireDate != null) {
            DateTime dateTime = DateTime.parse(
                profileProvider.profileModel.result![0].expireDate!);
            formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
          }
          return Container(
            height: 128,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 15.0),
            padding: const EdgeInsets.only(left: 30.0, right: 15, top: 17),
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage("assets/images/current_plan.png"))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    profileProvider.profileModel.result?[0].isAutoRenew == 1
                        ? InkWell(
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
                                        return ModifyChannel(
                                            isAutoRenew: profileProvider
                                                        .profileModel
                                                        .result?[0]
                                                        .isAutoRenew ==
                                                    1
                                                ? true
                                                : false);
                                      },
                                    ),
                                  );
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(8, 5, 8, 7),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color:
                                      pureBlack.withAlpha((0.1 * 255).toInt())),
                              child: MyText(
                                  color: pureBlack,
                                  text: "Modify",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textSmall,
                                  multilanguage: false,
                                  maxline: 2,
                                  fontwaight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        AdHelper.showFullscreenAd(
                            context, Constant.interstialAdType, () async {
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
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Subscription();
                                },
                              ),
                            );
                            setState(() {
                              getApi();
                            });
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 7),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: pureBlack),
                        child: MyText(
                            color: pureWhite,
                            text: "Upgrade",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textSmall,
                            multilanguage: false,
                            maxline: 2,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: MyText(
                          color: pureBlack,
                          text: profileProvider
                                  .profileModel.result?[0].packageName
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          multilanguage: false,
                          maxline: 1,
                          fontwaight: FontWeight.w800,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.fromLTRB(9, 3, 9, 3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: white),
                      child: Row(
                        children: [
                          MyImage(
                              width: 19, height: 19, imagePath: "ic_coin.png"),
                          const SizedBox(
                            width: 3,
                          ),
                          MusicTitle(
                              color: black,
                              text: profileProvider
                                      .profileModel.result?[0].packagePrice
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textMedium,
                              multilanguage: false,
                              maxline: 2,
                              fontwaight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        MyText(
                            text: 'Auto-Renewal: ',
                            multilanguage: false,
                            fontsizeNormal: 12.2,
                            fontwaight: FontWeight.w500),
                        profileProvider.profileModel.result?[0].isAutoRenew == 1
                            ? Icon(Icons.check_box,
                                color: Colors.green.shade700)
                            : Container(
                                width: 17,
                                height: 17,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(3)),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey.shade200,
                                  size: 15,
                                ))
                      ],
                    ),
                    MyText(
                        text: 'Expires in $formattedDate',
                        multilanguage: false,
                        fontsizeNormal: 11,
                        fontwaight: FontWeight.w500),
                  ],
                )
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget socialLinkList() {
    return Consumer<SettingProvider>(
        builder: (context, settingprovider, child) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        margin: const EdgeInsets.fromLTRB(0, 25, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyText(
                color: white,
                multilanguage: true,
                text: "socialprofiles",
                textalign: TextAlign.center,
                fontsizeNormal: Dimens.textMedium,
                inter: false,
                maxline: 1,
                fontwaight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                  itemCount:
                      settingprovider.socialLinkModel.result?.length ?? 0,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      focusColor: transparent,
                      hoverColor: transparent,
                      highlightColor: transparent,
                      splashColor: transparent,
                      onTap: () {
                        Utils.lanchAdsUrl(
                          settingprovider.socialLinkModel.result?[index].url
                                  .toString() ??
                              "",
                        );
                      },
                      child: Container(
                        width: 45,
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: MyNetworkImage(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.contain,
                          imagePath: settingprovider
                                  .socialLinkModel.result?[index].image
                                  .toString() ??
                              "",
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      );
    });
  }
}
