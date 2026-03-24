import 'package:carousel_slider/carousel_slider.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/pages/choosecategory.dart';
import 'package:fanbae/provider/subscriptionprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/webwidget/interactivecontainer.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/packagemodel.dart';
import '../pages/login.dart';
import '../provider/profileprovider.dart';
import '../utils/adhelper.dart';
import '../utils/responsive_helper.dart';
import '../widget/musictitle.dart';
import 'adspackage.dart';
import 'allpayment.dart';
import 'modifychannel.dart';

class Subscription extends StatefulWidget {
  const Subscription({
    Key? key,
  }) : super(key: key);

  @override
  State<Subscription> createState() => SubscriptionState();
}

class SubscriptionState extends State<Subscription> {
  late SubscriptionProvider subscriptionProvider;
  late ProfileProvider profileProvider;
  CarouselSliderController pageController = CarouselSliderController();
  SharedPre sharedPre = SharedPre();
  String? userName, userEmail, userMobileNo, countryCode, countryName;
  bool isToggled = false;
  bool isLoad = false;

  @override
  void initState() {
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);

    super.initState();
    getApi();
  }

  getApi() async {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    isToggled =
        profileProvider.profileModel.result?[0].isAutoRenew == 1 ? true : false;
    await subscriptionProvider.getPackage();
    await _getUserData();
    setState(() {});
  }

  @override
  void dispose() {
    subscriptionProvider.clearProvider();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: ResponsiveHelper.checkIsWeb(context)
          ? Utils.webAppbarWithSidePanel(
              context: context, contentType: Constant.videoSearch)
          : AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: Constant.gradientColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyImage(
                              width: 22, height: 22, imagePath: "ic_coin.png"),
                          const SizedBox(width: 5),
                          Consumer<ProfileProvider>(
                            builder: (context, settingProvider, _) {
                              return MyText(
                                color: pureBlack,
                                multilanguage: false,
                                text: Utils.kmbGenerator(
                                  settingProvider.profileModel.result?[0]
                                          .walletBalance ??
                                      0,
                                ),
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textMedium,
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
                )
              ],
              backgroundColor: appbgcolor,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: transparent,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: appbgcolor,
              ),
              elevation: 0,
              centerTitle: false,
              leading: InkWell(
                focusColor: transparent,
                highlightColor: transparent,
                hoverColor: transparent,
                splashColor: transparent,
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Utils.backIcon(),
                ),
              ),
              title: MyText(
                  color: white,
                  multilanguage: true,
                  text: "subscription",
                  textalign: TextAlign.center,
                  fontsizeNormal: 16,
                  inter: false,
                  maxline: 1,
                  fontwaight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ),
      body: RefreshIndicator(
        onRefresh: () => getApi(),
        child: ResponsiveHelper.checkIsWeb(context)
            ? Utils.sidePanelWithBody(
                myWidget: buildBody(),
              )
            : buildBody(),
      ),
    );
  }

  //}

  Widget buildBody() {
    return Utils().pageBg(
      context,
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Column(
              children: [
                const SizedBox(
                  height: 25,
                ),
                MyImage(
                    width: 100,
                    height: 90,
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
                !ResponsiveHelper.checkIsWeb(context)
                    ? subscriptionDisc()
                    : subscriptionWebDisc(),
                const SizedBox(height: 15),
                _buildSubscription(),
              ],
            ),
          ),
          Utils.musicAndAdsPanel(context),
        ],
      ),
    );
  }

  Widget _buildSubscription() {
    if (subscriptionProvider.loading) {
      return SizedBox(
        height: 100,
        child: Utils.pageLoader(context),
      );
    } else {
      if (subscriptionProvider.packageModel.status == 200 &&
          subscriptionProvider.packageModel.result!.isNotEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            /* Remaining Data */
            _buildItems(subscriptionProvider.packageModel.result),
          ],
        );
      } else {
        return const NoData(title: '', subTitle: '');
      }
    }
  }

  Widget _buildItems(List<Result>? packageList) {
    return buildMobileItem(packageList);
  }

  Widget subscriptionDisc() {
    if (Constant.userID != null) {
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
          padding: const EdgeInsets.only(left: 27.0, right: 12, top: 17),
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
                ],
              ),
              SizedBox(
                height: profileProvider.profileModel.result?[0].isAutoRenew == 1
                    ? 14
                    : 32,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: MyText(
                        color: pureBlack,
                        text: profileProvider
                                .profileModel.result?[0].packageName
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsizeNormal: 17,
                        multilanguage: false,
                        maxline: 1,
                        fontwaight: FontWeight.w800,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50), color: white),
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
                height: 11,
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
                          ? Icon(Icons.check_box, color: Colors.green.shade700)
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
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget subscriptionWebDisc() {
    if (Constant.userID != null) {
      return Consumer<ProfileProvider>(
          builder: (context, profileprovider, child) {
        if (profileprovider.loading) {
          print('subscriptionDisc loading');
          return const SizedBox.shrink();
        } else {
          print('subscriptionDisc not loading');
          if (profileprovider.profileModel.result?[0].isBuy == 1) {
            String formattedDate = '';
            if (profileprovider.profileModel.result?[0].expireDate != null) {
              DateTime dateTime = DateTime.parse(
                  profileprovider.profileModel.result![0].expireDate!);
              formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
            }
            return Container(
              height: 155,
              width: ResponsiveHelper.isTab(context)
                  ? MediaQuery.of(context).size.width * 0.65
                  : MediaQuery.of(context).size.width * 0.38,
              margin:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
              padding: const EdgeInsets.only(left: 45.0, right: 15, top: 55),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/current_plan.png"),
                      fit: BoxFit.fill)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyText(
                              color: pureBlack,
                              text: profileprovider
                                      .profileModel.result?[0].packageName
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              multilanguage: false,
                              maxline: 2,
                              fontwaight: FontWeight.w800,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: white),
                            child: MusicTitle(
                                color: black,
                                text:
                                    "${Constant.currencySymbol}${profileprovider.profileModel.result?[0].packagePrice.toString() ?? ""}",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textMedium,
                                multilanguage: false,
                                maxline: 2,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          isToggled
                              ? InkWell(
                                  onTap: () {
                                    AdHelper.showFullscreenAd(
                                        context, Constant.interstialAdType, () {
                                      if (Constant.userID == null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return ResponsiveHelper.isWeb(
                                                      context)
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
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 7, 8, 7),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: pureBlack
                                            .withAlpha((0.1 * 255).toInt())),
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
                                        return const Subscription();
                                      },
                                    ),
                                  );
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: pureBlack),
                              child: MyText(
                                  color: pureWhite,
                                  text: "Upgrade Now",
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
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyText(
                          text: 'Expires in $formattedDate',
                          multilanguage: false,
                          fontsizeNormal: 11,
                          fontwaight: FontWeight.w500),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyText(
                              text: 'Auto-Renewal: ',
                              multilanguage: false,
                              fontsizeNormal: 12.2,
                              fontwaight: FontWeight.w500),
                          profileProvider.profileModel.result?[0].isAutoRenew ==
                                  1
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
                      )
                    ],
                  )
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      });
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildMobileItem(List<Result>? packageList) {
    if (packageList != null) {
      return CarouselSlider.builder(
        itemCount: packageList.length,
        carouselController: pageController,
        options: CarouselOptions(
          initialPage: 0,
          height: MediaQuery.of(context).size.height,
          enlargeCenterPage: packageList.length > 1 ? true : false,
          enlargeFactor: ResponsiveHelper.checkIsWeb(context) ? 0.30 : 0.22,
          autoPlay: false,
          autoPlayCurve: Curves.easeInOutQuart,
          enableInfiniteScroll: packageList.length > 1
              ? ResponsiveHelper.checkIsWeb(context)
                  ? packageList.length > 3
                      ? true
                      : false
                  : true
              : false,
          viewportFraction: ResponsiveHelper.checkIsWeb(context) ? 0.35 : 0.73,
        ),
        itemBuilder: (BuildContext context, int index, int pageViewIndex) {
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color(0xFFF20089), width: 1.5),
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(colors: [
                    Color(0xFF150D26),
                    Color(0xFF2C0C53),
                    Color(0xFF150F27),
                    Color(0xFF591D47),
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 18, right: 18),
                      constraints: const BoxConstraints(minHeight: 55),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: MyText(
                              color: white,
                              text: packageList[index].name ?? "",
                              textalign: TextAlign.start,
                              fontsizeNormal: Dimens.textTitle,
                              maxline: 1,
                              multilanguage: false,
                              overflow: TextOverflow.ellipsis,
                              fontwaight: FontWeight.w700,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                          const SizedBox(width: 5),
                          MyImage(
                              width: 21, height: 21, imagePath: "ic_coin.png"),
                          const SizedBox(width: 5),
                          MyText(
                            color: white,
                            text:
                                "${packageList[index].price.toString()} / ${packageList[index].time.toString()} ${packageList[index].type.toString()}",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textTitle,
                            maxline: 1,
                            multilanguage: false,
                            overflow: TextOverflow.ellipsis,
                            fontwaight: FontWeight.w600,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 0.5,
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white.withOpacity(0.4),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(1, 9, 1, 9),
                      constraints: const BoxConstraints(minHeight: 0),
                      child: SingleChildScrollView(
                        child: _buildBenefits(packageList, index),
                      ),
                    ),
                    packageList[index].description != null
                        ? Container(
                            padding: const EdgeInsets.only(left: 18, right: 18),
                            child: SingleChildScrollView(
                              child: MyText(
                                color: white,
                                text: "* ${packageList[index].description}",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textTitle,
                                maxline: 10,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                fontwaight: FontWeight.w600,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(height: 15),
                    /* Choose Plan */
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () async {
                          if (packageList[index].isBuy != 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ChooseCategory(
                                    packageId: packageList[index].id ?? 0,
                                    packageName: packageList[index].name ?? '',
                                    packagePrice:
                                        packageList[index].price.toString(),
                                  );
                                },
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 42,
                          width: !kIsWeb
                              ? MediaQuery.of(context).size.width * 0.4
                              : !ResponsiveHelper.isDesktop(context)
                                  ? MediaQuery.of(context).size.width * 0.4
                                  : MediaQuery.of(context).size.width * 0.2,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE67025), Color(0xFFE93276)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                                color: const Color(0xFF8F03FF), width: 1.5),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Consumer<SubscriptionProvider>(
                            builder: (context, subscriptionProvider, child) {
                              return MyText(
                                color: pureWhite,
                                text: (packageList[index].isBuy == 1)
                                    ? "currentplan"
                                    : "chooseplan",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textMedium,
                                fontwaight: FontWeight.w700,
                                multilanguage: true,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildWebItem(List<Result>? packageList) {
    if (packageList != null) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemCount: packageList.length,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return InteractiveContainer(child: (isHovered) {
              return AnimatedScale(
                scale: isHovered ? 1.05 : 1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: Wrap(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width > 800
                            ? MediaQuery.of(context).size.width * 0.40
                            : MediaQuery.of(context).size.width * 0.80,
                        decoration: BoxDecoration(
                          color: isHovered
                              ? colorPrimary
                              : (packageList[index].isBuy == 1
                                  ? colorPrimary
                                  : transparent),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1, color: colorPrimary),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding:
                                  const EdgeInsets.only(left: 18, right: 18),
                              constraints: const BoxConstraints(minHeight: 75),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: MyText(
                                      color: white,
                                      text: packageList[index].name ?? "",
                                      textalign: TextAlign.start,
                                      fontsizeNormal: Dimens.textlargeBig,
                                      fontsizeWeb: Dimens.textlargeBig,
                                      maxline: 1,
                                      multilanguage: false,
                                      overflow: TextOverflow.ellipsis,
                                      fontwaight: FontWeight.w800,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  MyText(
                                    color: white,
                                    text:
                                        "${Constant.currencySymbol} ${packageList[index].price.toString()} / ${packageList[index].time.toString()} ${packageList[index].type.toString()}",
                                    textalign: TextAlign.right,
                                    fontsizeNormal: Dimens.textTitle,
                                    fontsizeWeb: Dimens.textTitle,
                                    maxline: 1,
                                    multilanguage: false,
                                    overflow: TextOverflow.ellipsis,
                                    fontwaight: FontWeight.w600,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(1, 9, 1, 9),
                              constraints: const BoxConstraints(minHeight: 0),
                              child: SingleChildScrollView(
                                child: _buildBenefits(packageList, index),
                              ),
                            ),
                            const SizedBox(height: 20),

                            /* Choose Plan */
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(5),
                                onTap: () async {
                                  if (packageList[index].isBuy != 1) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ChooseCategory(
                                            packageId:
                                                packageList[index].id ?? 0,
                                            packageName:
                                                packageList[index].name ?? '',
                                            packagePrice: packageList[index]
                                                .price
                                                .toString(),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  height: 45,
                                  width: 200,
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  margin:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  decoration: BoxDecoration(
                                    color: isHovered
                                        ? white
                                        : (packageList[index].isBuy == 1
                                            ? white
                                            : colorPrimary),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  alignment: Alignment.center,
                                  child: Consumer<SubscriptionProvider>(
                                    builder:
                                        (context, subscriptionProvider, child) {
                                      return MyText(
                                        color: isHovered
                                            ? black
                                            : (packageList[index].isBuy == 1
                                                ? black
                                                : white),
                                        text: (packageList[index].isBuy == 1)
                                            ? "current"
                                            : "chooseplan",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: Dimens.textTitle,
                                        fontwaight: FontWeight.w700,
                                        multilanguage: true,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildBenefits(List<Result>? packageList, int? index) {
    if (packageList?[index ?? 0].data != null &&
        (packageList?[index ?? 0].data?.length ?? 0) > 0) {
      return AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        padding: const EdgeInsets.fromLTRB(15, 2, 15, 5),
        itemCount: (packageList?[index ?? 0].data?.length ?? 0),
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
                const Icon(
                  Icons.star,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MyText(
                    color: white,
                    text: packageList?[index ?? 0].data?[position].packageKey ??
                        "",
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
                ((packageList?[index ?? 0].data?[position].packageValue ??
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
                        color: white,
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
                      ),
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
