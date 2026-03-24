import 'dart:developer';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/pages/login.dart';
import 'package:fanbae/pages/wallet.dart';
import 'package:fanbae/provider/profileprovider.dart';
import 'package:fanbae/provider/subscriptionprovider.dart';
import 'package:fanbae/subscription/allpayment.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/webwallet.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fanbae/model/adspackagemodel.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class AdsPackage extends StatefulWidget {
  const AdsPackage({
    Key? key,
  }) : super(key: key);

  @override
  State<AdsPackage> createState() => AdsPackageState();
}

class AdsPackageState extends State<AdsPackage> {
  late SubscriptionProvider subscriptionProvider;
  late ProfileProvider profileProvider;
  CarouselSliderController pageController = CarouselSliderController();
  String? userName, userEmail, userMobileNo, countryCode, countryName;
  SharedPre sharedPre = SharedPre();
  TextEditingController coinController = TextEditingController();
  double convertedValue = 0.0;

  @override
  void initState() {
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    super.initState();
    getApi();
    /*coinController. addListener(() {
      final int coin =
          int.tryParse(coinController.text) ?? 0;
      final double coinValue = profileProvider
          .profileModel.result? [0].coinValue ??
          0.0;

      setState(() {
        print('Before convertedValue: $convertedValue');
        convertedValue = coin * coinValue;
        print('After convertedValue: $convertedValue');
      });
    });*/
  }

  getApi() async {
    await profileProvider.getprofile(context, Constant.userID);
    await subscriptionProvider.getAdsPackage();
    await _getUserData();
    setState(() {});
  }

  @override
  void dispose() {
    coinController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: ResponsiveHelper.checkIsWeb(context)
          ? Utils.webAppbarWithSidePanel(
              context: context, contentType: Constant.videoSearch)
          : Utils().otherPageAppBar(context, "addmorecoins", true),
      body: RefreshIndicator(
        backgroundColor: colorPrimaryDark,
        color: colorAccent,
        displacement: 70,
        edgeOffset: 1.0,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        strokeWidth: 3,
        onRefresh: () async {
          await getApi();
        },
        child: Utils().pageBg(
          context,
          child: ResponsiveHelper.checkIsWeb(context)
              ? Utils.sidePanelWithBody(
                  myWidget: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                            width: ResponsiveHelper.isDesktop(context)
                                ? MediaQuery.of(context).size.width * 0.47
                                : ResponsiveHelper.isTab(context)
                                    ? MediaQuery.of(context).size.width * 0.615
                                    : MediaQuery.of(context).size.width,
                            child: currentBalance()),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                            width: ResponsiveHelper.isDesktop(context)
                                ? MediaQuery.of(context).size.width * 0.47
                                : ResponsiveHelper.isTab(context)
                                    ? MediaQuery.of(context).size.width * 0.615
                                    : MediaQuery.of(context).size.width,
                            child: _buildAdsSubscription()),
                      ),
                    ],
                  ),
                ))
              : Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.fromLTRB(20, 23, 20, 190),
                      child: Column(
                        children: [
                          currentBalance(),
                          _buildAdsSubscription(),
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

  Widget currentBalance() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      final walletBalance =
          profileprovider.profileModel.result?[0].walletBalance ?? 0;
      final coinValue = profileprovider.profileModel.result?[0].coinValue ?? 0;

      final coin = walletBalance * coinValue;
      return Container(
        decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color(0xFF150D26),
              Color(0xFF2C0C53),
              Color(0xFFE93276),
              Color(0xFF2D00F7),
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: const Color(0xFFF20089), width: 1.5),
            borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: black, borderRadius: BorderRadius.circular(30)),
                child: MyText(
                  color: white,
                  text:
                      '1 Coin = ${profileprovider.profileModel.result?[0].coinValue.toString() ?? ""} ${Constant.currency}',
                  textalign: TextAlign.start,
                  fontsizeNormal: 11,
                  maxline: 1,
                  multilanguage: false,
                  overflow: TextOverflow.ellipsis,
                  fontwaight: FontWeight.w600,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ),
            const SizedBox(height: 13),
            MyText(
              color: white,
              text: "Total Balance",
              textalign: TextAlign.start,
              fontsizeNormal: Dimens.textDesc,
              maxline: 1,
              multilanguage: false,
              overflow: TextOverflow.ellipsis,
              fontwaight: FontWeight.w600,
              fontstyle: FontStyle.normal,
            ),
            const SizedBox(height: 3),
            profileprovider.profileloading
                ? MyText(
                    color: pureBlack,
                    multilanguage: false,
                    text: "0",
                    textalign: TextAlign.center,
                    fontsizeNormal: 24,
                    maxline: 1,
                    fontwaight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyImage(width: 24, height: 24, imagePath: "coin.png"),
                      MyText(
                          color: white,
                          multilanguage: false,
                          text: profileProvider.profileModel.status == 200
                              ? '${profileProvider.profileModel.result?[0].walletBalance.toString() ?? ""} '
                              : "0",
                          textalign: TextAlign.center,
                          fontsizeNormal: 27,
                          maxline: 1,
                          fontwaight: FontWeight.w700,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
            const SizedBox(height: 13),
            Wrap(
              runSpacing: 10,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Constant.isCreator == "1"
                    ? InkWell(
                        onTap: () async {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 7),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: colorPrimaryDark,
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                              child: MyText(
                                                text: "withdrawrequest",
                                                color: white,
                                                fontsizeNormal: 18,
                                                fontwaight: FontWeight.bold,
                                              ),
                                            ),
                                            ValueListenableBuilder<
                                                TextEditingValue>(
                                              valueListenable: coinController,
                                              builder: (context, value, child) {
                                                final int coin =
                                                    int.tryParse(value.text) ??
                                                        0;
                                                final double convertedValue =
                                                    coin * coinValue;

                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Utils().titleText("coin"),
                                                    convertedValue != 0
                                                        ? Utils().titleText(
                                                            convertedValue
                                                                .toStringAsFixed(
                                                                    2))
                                                        : const SizedBox(),
                                                  ],
                                                );
                                              },
                                            ),
                                            Utils().myTextField(
                                                coinController,
                                                TextInputAction.next,
                                                TextInputType.number,
                                                "Coin value",
                                                false),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 30.0, bottom: 17),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors.grey
                                                                      .shade700),
                                                      child: MyText(
                                                          text: "back",
                                                          color: pureWhite)),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  ElevatedButton(
                                                      onPressed: () async {
                                                        if (coinController
                                                            .text.isEmpty) {
                                                          return Utils()
                                                              .showSnackBar(
                                                                  context,
                                                                  "Coin field is required",
                                                                  false);
                                                        }
                                                        if (int.parse(
                                                                coinController
                                                                    .text
                                                                    .toString()) >
                                                            int.parse(profileProvider
                                                                .profileModel
                                                                .result![0]
                                                                .walletBalance
                                                                .toString())) {
                                                          return Utils()
                                                              .showSnackBar(
                                                                  context,
                                                                  "Coin value must be lesser the your current balance",
                                                                  false);
                                                        }

                                                        Utils.showProgress(
                                                            context);

                                                        SuccessModel data =
                                                            await ApiService()
                                                                .withdrawRequest(
                                                                    Constant.userID ??
                                                                        '',
                                                                    int.parse(
                                                                        coinController
                                                                            .text));

                                                        Utils().hideProgress(
                                                            context);
                                                        coinController.clear();
                                                        Navigator.pop(context);
                                                        print(data.status);
                                                        print(data.message);
                                                        Utils().showSnackBar(
                                                            context,
                                                            data.message ?? '',
                                                            false);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  textColor),
                                                      child: MyText(
                                                          text: "submit",
                                                          color: black)),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ));
                              });
                          profileprovider.getprofile(context, Constant.userID);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE67025), Color(0xFFE93276)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                  color: const Color(0xFF8F03FF), width: 1.5)),
                          child: MyText(
                            color: white,
                            text: "withdraw",
                            textalign: TextAlign.start,
                            fontsizeNormal: Dimens.textSmall,
                            maxline: 1,
                            multilanguage: true,
                            overflow: TextOverflow.ellipsis,
                            fontwaight: FontWeight.w700,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(
                  width: 18,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const Wallet();
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 6.5, 22, 6.5),
                    decoration: BoxDecoration(
                        color: black,
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(
                            color: const Color(0xFF8F03FF), width: 1.5)),
                    child: MyText(
                      color: white,
                      text: "gotowallet",
                      textalign: TextAlign.start,
                      fontsizeNormal: Dimens.textSmall,
                      maxline: 1,
                      multilanguage: true,
                      overflow: TextOverflow.ellipsis,
                      fontwaight: FontWeight.w700,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAdsSubscription() {
    return Consumer<SubscriptionProvider>(
        builder: (context, adspackageprovider, child) {
      log("Loading===> ${adspackageprovider.adspackageLoading}");
      if (adspackageprovider.adspackageLoading) {
        return commanShimmer();
      } else {
        if (adspackageprovider.adsPackageModel.status == 200) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: ResponsiveHelper.checkIsWeb(context)
                    ? const EdgeInsets.fromLTRB(0, 50, 0, 0)
                    : const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: MyText(
                  color: white,
                  text: "coinpackages",
                  textalign: TextAlign.start,
                  fontsizeNormal: Dimens.textDesc,
                  fontsizeWeb: Dimens.textlargeBig,
                  maxline: 1,
                  multilanguage: true,
                  overflow: TextOverflow.ellipsis,
                  fontwaight: FontWeight.w600,
                  fontstyle: FontStyle.normal,
                ),
              ),
              /* Remaining Data */
              /*kIsWeb
                  ? buildAdsWebItem(adspackageprovider. adsPackageModel.result)
                  : */
              buildAdsMobileItem(adspackageprovider.adsPackageModel.result),
              const SizedBox(height: 20),
            ],
          );
        } else {
          return const NoData(title: 'test', subTitle: 'test');
        }
      }
    });
  }

  Widget buildAdsMobileItem(List<Result>? packageList) {
    if (packageList != null) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
          child: ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 1,
            maxItemsPerRow: 1,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 14,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
            ),
            children: List.generate(packageList.length, (index) {
              final containerColor = index % 3;
              return Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(12, 19, 12, 19),
                decoration: BoxDecoration(
                  gradient: containerColor == 0
                      ? const LinearGradient(colors: [
                          Color(0xFF150D26),
                          Color(0xFF2C0C53),
                          Color(0xFF150F27),
                          Color(0xFF591D47),
                        ], begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : containerColor == 1
                          ? const LinearGradient(
                              colors: [
                                  Color(0xFF150D26),
                                  Color(0xFF2C0C53),
                                  Color(0xFF150F27),
                                  Color(0xFF591D47),
                                ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight)
                          : const LinearGradient(
                              colors: [
                                  Color(0xFF150D26),
                                  Color(0xFF2C0C53),
                                  Color(0xFF150F27),
                                  Color(0xFF591D47),
                                ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                  border:
                      Border.all(color: const Color(0xFFF20089), width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: pureBlack,
                                borderRadius: BorderRadius.circular(30)),
                            child: (packageList[index].image != null &&
                                    packageList[index].image!.isNotEmpty &&
                                    packageList[index].image != "null" &&
                                    packageList[index]
                                        .image!
                                        .startsWith('http'))
                                ? MyNetworkImage(
                                    imagePath: packageList[index].image!,
                                    width: 22,
                                    height: 22,
                                    fit: BoxFit.cover,
                                  )
                                : MyImage(
                                    width: 22,
                                    height: 22,
                                    imagePath:
                                        (packageList[index].image != null &&
                                                packageList[index]
                                                    .image!
                                                    .isNotEmpty &&
                                                packageList[index].image !=
                                                    "null")
                                            ? packageList[index].image!
                                            : "coin.png",
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  MyText(
                                    color: white,
                                    text: packageList[index].name.toString(),
                                    textalign: TextAlign.start,
                                    fontsizeNormal: Dimens.textTitle,
                                    maxline: 1,
                                    multilanguage: false,
                                    overflow: TextOverflow.ellipsis,
                                    fontwaight: FontWeight.w600,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(width: 5),
                                ],
                              ),
                              Row(
                                children: [
                                  MyText(
                                    color: colorGold,
                                    text: packageList[index].coin.toString(),
                                    textalign: TextAlign.start,
                                    fontsizeNormal: Dimens.textTitle,
                                    maxline: 1,
                                    multilanguage: false,
                                    overflow: TextOverflow.ellipsis,
                                    fontwaight: FontWeight.w600,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(width: 5),
                                  MyText(
                                    color: white,
                                    text: "coins",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: Dimens.textDesc,
                                    maxline: 1,
                                    multilanguage: false,
                                    overflow: TextOverflow.ellipsis,
                                    fontwaight: FontWeight.w600,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ],
                              ),
                              MyText(
                                color: gray,
                                text:
                                    "Per ${packageList[index].expireDate} ${packageList[index].dataType.toString()}",
                                textalign: TextAlign.start,
                                fontsizeNormal: 12.7,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                fontwaight: FontWeight.w500,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        MyText(
                          color: colorGold,
                          text:
                              "${Constant.currencySymbol} ${packageList[index].price.toString()}",
                          textalign: TextAlign.start,
                          fontsizeNormal: 16,
                          maxline: 1,
                          multilanguage: false,
                          overflow: TextOverflow.ellipsis,
                          fontwaight: FontWeight.w700,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        InkWell(
                          onTap: () {
                            _checkAndPay(packageList, index);
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE67025), Color(0xFFE93276)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                  color: const Color(0xFF8F03FF), width: 1.5),
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: MyText(
                              color: black,
                              text: "Buy Now",
                              textalign: TextAlign.start,
                              fontsizeNormal: Dimens.textSmall,
                              maxline: 1,
                              multilanguage: false,
                              overflow: TextOverflow.ellipsis,
                              fontwaight: FontWeight.w700,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildAdsWebItem(List<Result>? packageList) {
    if (packageList != null) {
      return SizedBox(
        height: 280,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
            child: ListView.separated(
              itemCount: packageList.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) {
                return const SizedBox(width: 15);
              },
              itemBuilder: (context, index) {
                return Container(
                  width: 200,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: colorPrimaryDark,
                    border: Border.all(width: 0.4, color: gray),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          MyImage(
                              width: 80,
                              height: 80,
                              imagePath: "assets/images/ic_coin.png"),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyText(
                                color: white,
                                text: packageList[index].coin.toString(),
                                textalign: TextAlign.start,
                                fontsizeNormal: Dimens.textTitle,
                                fontsizeWeb: Dimens.textTitle,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                fontwaight: FontWeight.w600,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(width: 5),
                              MyText(
                                color: white,
                                text: "coins",
                                textalign: TextAlign.start,
                                fontsizeNormal: Dimens.textTitle,
                                fontsizeWeb: Dimens.textTitle,
                                maxline: 1,
                                multilanguage: true,
                                overflow: TextOverflow.ellipsis,
                                fontwaight: FontWeight.w600,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      InkWell(
                        onTap: () {
                          _checkAndPay(packageList, index);
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            gradient: const LinearGradient(
                                colors: [colorPrimary, lightgray],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: MyText(
                            color: white,
                            text:
                                "${Constant.currencySymbol} ${packageList[index].price.toString()}",
                            textalign: TextAlign.start,
                            fontsizeNormal: Dimens.textSmall,
                            fontsizeWeb: Dimens.textSmall,
                            maxline: 1,
                            multilanguage: false,
                            overflow: TextOverflow.ellipsis,
                            fontwaight: FontWeight.w700,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
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
      return const SizedBox.shrink();
    }
  }

  Widget commanShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: CustomWidget.roundrectborder(
            height: 8,
            width: 100,
          ),
        ),
        /* Remaining Data */
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 1,
              maxItemsPerRow: 1,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 14,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(8, (index) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                  decoration: BoxDecoration(
                    color: colorPrimaryDark,
                    border: Border.all(width: 0.4, color: gray),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CustomWidget.circular(
                              height: 20,
                              width: 20,
                            ),
                            SizedBox(width: 5),
                            CustomWidget.roundrectborder(
                              height: 8,
                              width: 150,
                            ),
                          ],
                        ),
                      ),
                      CustomWidget.roundrectborder(
                        height: 35,
                        width: 70,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  _checkAndPay(List<Result>? packageList, int index) async {
    if (Constant.userID != null) {
      /* Update Required data for payment */
      print(userName);
      print(userEmail);
      print(userMobileNo);
      if ((userName ?? "").isEmpty ||
          (userEmail ?? "").isEmpty ||
          (userMobileNo ?? "").isEmpty) {
        if (ResponsiveHelper.checkIsWeb(context)) {
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
      /* Update Required data for payment */
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AllPayment(
              coin: packageList?[index].coin.toString() ?? '',
              payType: 'AdsPackage',
              itemId: packageList?[index].id.toString() ?? '',
              price: packageList?[index].price.toString() ?? '',
              itemTitle: packageList?[index].name.toString() ?? '',
              typeId: '',
              videoType: '',
              productPackage: (!kIsWeb)
                  ? (Platform.isIOS
                      ? (packageList?[index].iosProductPackage.toString() ?? '')
                      : (packageList?[index].androidProductPackage.toString() ??
                          ''))
                  : '',
              currency: '',
            );
          },
        ),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const Login();
          },
        ),
      );
    }
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
      setState(() {});
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
}
