import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:fanbae/provider/walletprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/responsive_helper.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  late WalletProvider walletProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    getApi();
    _fetchDataUsageHistory(0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  getApi() async {
    /* Profile Api */
    await walletProvider.getprofile(context, Constant.userID);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (walletProvider.currentPage ?? 0) < (walletProvider.totalPage ?? 0)) {
      printLog("load more====>");
      // walletProvider.setLoadMore(true);
      // _fetchDataAdsPackageTransection(walletProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchDataUsageHistory(int? nextPage) async {
    /* get Ads Package Transection Api */
    await walletProvider.getUsageHistory((nextPage ?? 0) + 1);
    walletProvider.setUsageHistoryLoadMore(false);
  }

  Future<void> _fetchDataAdsPackageTransection(int? nextPage) async {
    /* get Ads Package Transection Api */
    // walletProvider.setLoadMore(false);
    await walletProvider.getAdsPackageTransection((nextPage ?? 0) + 1);
    walletProvider.setLoadMore(false);
  }

  Future<void> _fetchDataWithdrawalTransection(int? nextPage) async {
    /* get Ads Package Transection Api */
    await walletProvider.getWithdrawalTransection((nextPage ?? 0) + 1);
    walletProvider.setWithdrawalLoadMore(false);
  }

  @override
  void dispose() {
    walletProvider.clearProvider();
    super.dispose();
  }

  Future<void> _openCreatorPayoutPolicy() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/creator-payout');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(
            context, "Could not open creator payout policy", false);
      }
    }
  }

  Future<void> _openPlatformFeeDisclosure() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/platform-fee-disclosure');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(
            context, "Could not open platform fee disclosure", false);
      }
    }
  }

  Future<void> _openGlobalTaxVATPolicy() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/global-tax-vat-tax');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(
            context, "Could not open global tax & VAT policy", false);
      }
    }
  }

  Widget _buildCreatorPoliciesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorPrimaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorAccent.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colorPrimary, size: 20),
              const SizedBox(width: 8),
              MyText(
                color: colorPrimary,
                text: "Creator Earnings & Policies",
                multilanguage: false,
                fontsizeNormal: Dimens.textTitle,
                fontwaight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              children: [
                const TextSpan(
                    text: "Review important policies for creator earnings: "),
                TextSpan(
                  text: "Creator Payout Policy",
                  style: TextStyle(
                    color: colorPrimary,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _openCreatorPayoutPolicy,
                ),
                const TextSpan(text: ", "),
                TextSpan(
                  text: "Platform Fee Disclosure",
                  style: TextStyle(
                    color: colorPrimary,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _openPlatformFeeDisclosure,
                ),
                const TextSpan(text: ", and "),
                TextSpan(
                  text: "Global Tax & VAT Policy",
                  style: TextStyle(
                    color: colorPrimary,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _openGlobalTaxVATPolicy,
                ),
                const TextSpan(
                    text:
                        ". Understand how your earnings are calculated and processed."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: Utils().otherPageAppBar(context, "mywallet", true),
      body: Utils().pageBg(
        context,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                if (walletProvider.position == 0) {
                  _fetchDataUsageHistory(0);
                  walletProvider.clearUsageHistory();
                  /* Parchas History */
                } else if (walletProvider.position == 1) {
                  _fetchDataAdsPackageTransection(0);
                  walletProvider.clearAdsPackage();
                  /* Withdrawal History */
                } else if (walletProvider.position == 2) {
                  _fetchDataWithdrawalTransection(0);
                  walletProvider.clearWithdrawal();
                }
              },
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(0, 35, 0, 190),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Column(
                    children: [
                      myWallet(),
                      const SizedBox(height: 20),
                      if (Constant.isCreator == "1")
                        _buildCreatorPoliciesSection(),
                      const SizedBox(height: 30),
                      buildTab(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: ResponsiveHelper.checkIsWeb(context)
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: ResponsiveHelper.isDesktop(context)
                                      ? MediaQuery.of(context).size.width * 0.47
                                      : ResponsiveHelper.isTab(context)
                                          ? MediaQuery.of(context).size.width *
                                              0.615
                                          : MediaQuery.of(context).size.width,
                                  child: buildTabItem(),
                                ),
                              )
                            : buildTabItem(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Utils.musicAndAdsPanel(context),
          ],
        ),
      ),
    );
  }

  Widget myWallet() {
    return Consumer<WalletProvider>(builder: (context, walletprovider, child) {
      final walletBalance =
          walletprovider.profileModel.result?[0].walletBalance ?? 0;
      final coinValue = walletprovider.profileModel.result?[0].coinValue ?? 0;
      final withdrawalBalance =
          walletprovider.profileModel.result?[0].walletEarning ?? 0;

      final coin = walletBalance * coinValue;
      final withdrawalCoin = withdrawalBalance * coinValue;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        decoration: BoxDecoration(
            border: Border.all(color: white.withOpacity(0.4), width: 0.5),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      Color(0xff96e1ff),
                      Color(0xffffee99),
                      Color(0xffff88a1),
                      Color(0xffff7dd3),
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /* MyText(
                      color: black,
                      text:
                          '1 Coin = ${walletprovider.profileModel.result?[0].coinValue.toString() ?? ""} ${Constant.currency}',
                      textalign: TextAlign.start,
                      fontsizeNormal: Dimens.textSmall,
                      maxline: 1,
                      multilanguage: false,
                      overflow: TextOverflow.ellipsis,
                      fontwaight: FontWeight.w600,
                      fontstyle: FontStyle.normal,
                    ),*/
                    MyText(
                        color: pureBlack,
                        multilanguage: false,
                        text: "Total Balance",
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textMedium,
                        maxline: 1,
                        fontwaight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 3),
                    walletprovider.loading
                        ? MyText(
                            color: pureBlack,
                            multilanguage: false,
                            text: "0",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textDesc,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal)
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyImage(
                                  width: 19, height: 19, imagePath: "coin.png"),
                              MyText(
                                  color: pureBlack,
                                  multilanguage: false,
                                  text:
                                      walletprovider.profileModel.status != 200
                                          ? "0"
                                          : walletprovider.profileModel
                                                  .result?[0].walletBalance
                                                  .toString() ??
                                              "",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textDesc,
                                  maxline: 1,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          ),
                  ],
                ),
              ),
              if (Constant.isCreator == "1") ...[
                const SizedBox(width: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        Color(0xff96e1ff),
                        Color(0xffffee99),
                        Color(0xffff88a1),
                        Color(0xffff7dd3),
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                          color: pureBlack,
                          multilanguage: false,
                          text: "Withdrawal",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textMedium,
                          maxline: 1,
                          fontwaight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(height: 3),
                      walletprovider.loading
                          ? MyText(
                              color: pureBlack,
                              multilanguage: false,
                              text: "0",
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textDesc,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal)
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyImage(
                                    width: 19,
                                    height: 19,
                                    imagePath: "coin.png"),
                                MyText(
                                    color: pureBlack,
                                    multilanguage: false,
                                    text: walletprovider.profileModel.status !=
                                            200
                                        ? "0"
                                        : walletprovider.profileModel.result?[0]
                                                .walletEarning
                                                .toString() ??
                                            "",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textDesc,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                /*withdrawalCoin == 0
                                    ? const SizedBox()
                                    : MyText(
                                        color: black,
                                        multilanguage: false,
                                        text:
                                            '($withdrawalCoin ${Constant.currency})',
                                        textalign: TextAlign.center,
                                        fontsizeNormal: 13,
                                        maxline: 1,
                                        fontwaight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),*/
                              ],
                            ),
                      /* Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyImage(
                              width: 19,
                              height: 19,
                              imagePath: "ic_wallet.png"),
                          const SizedBox(width: 10),
                        ],
                      ),*/
                      /*  Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyImage(width: 19, height: 19, imagePath: "coin.png"),
                          const SizedBox(width: 3),
                          MyText(
                              color: black,
                              multilanguage: true,
                              text: "coins",
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textDesc,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      ),*/
                    ],
                  ),
                )
              ]
            ]),
      );
    });
  }

  Widget buildTab() {
    final tabs = Constant().getTransectionTabs();
    return Consumer<WalletProvider>(builder: (context, walletprovider, child) {
      return SizedBox(
        height: 60,
        child: ListView.builder(
            itemCount: tabs.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: InkWell(
                  autofocus: false,
                  focusColor: transparent,
                  highlightColor: transparent,
                  hoverColor: transparent,
                  splashColor: transparent,
                  onTap: () async {
                    walletprovider.changeTab(index);
                    /* Usage History */
                    if (walletprovider.position == 0) {
                      _fetchDataUsageHistory(0);
                      walletprovider.clearUsageHistory();
                      /* Parchas History */
                    } else if (walletprovider.position == 1) {
                      _fetchDataAdsPackageTransection(0);
                      walletprovider.clearAdsPackage();
                      /* Withdrawal History */
                    } else if (walletprovider.position == 2) {
                      _fetchDataWithdrawalTransection(0);
                      walletprovider.clearWithdrawal();
                    } else {
                      walletprovider.clearProvider();
                    }
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7.5, horizontal: 22),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [
                                Color(0xff96e1ff),
                                Color(0xffffee99),
                                Color(0xffff88a1),
                                Color(0xffff7dd3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          color: walletprovider.position == index
                              ? null
                              : buttonDisable,
                          borderRadius: BorderRadius.circular(10)),
                      child: MyText(
                          color: walletprovider.position == index
                              ? pureBlack
                              : white,
                          text: tabs[index],
                          textalign: TextAlign.center,
                          fontsizeNormal: 12.3,
                          inter: false,
                          multilanguage: false,
                          maxline: 1,
                          fontwaight: walletprovider.position == index
                              ? FontWeight.bold
                              : FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                  ),
                ),
              );
            }),
      );
    });
  }

  Widget buildTabItem() {
    return Consumer<WalletProvider>(builder: (context, profileprovider, child) {
      if (profileprovider.position == 0) {
        return buildUseHistory();
      } else if (profileprovider.position == 1) {
        return buildParchas();
      } else if (profileprovider.position == 2) {
        return buildWithdrawal();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

/* Use History */
  Widget buildUseHistory() {
    return Consumer<WalletProvider>(builder: (context, walletProvider, child) {
      if (walletProvider.usageHistoryloading &&
          !walletProvider.usageHistoryloadMore) {
        return commanShimmer();
      } else {
        return Column(
          children: [
            buildUseHistoryItem(),
            if (walletProvider.usageHistoryloadMore)
              Container(
                height: 50,
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

  Widget buildUseHistoryItem() {
    if (walletProvider.usageHistoryModel.status == 200 &&
        walletProvider.usageHistoryList != null) {
      if ((walletProvider.usageHistoryList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ResponsiveGridList(
                minItemWidth: 120,
                minItemsPerRow: 1,
                maxItemsPerRow: 1,
                horizontalGridSpacing: 10,
                verticalGridSpacing: 12,
                listViewBuilderOptions: ListViewBuilderOptions(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
                children: List.generate(
                    walletProvider.usageHistoryList?.length ?? 0, (index) {
                  final containerColor = index % 3;
                  return Container(
                    padding: const EdgeInsets.fromLTRB(10, 13, 20, 13),
                    decoration: BoxDecoration(
                        color: buttonDisable,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: walletProvider
                                            .usageHistoryList?[index].title
                                            .toString() ==
                                        'Gift'
                                    ? colorPrimary
                                    : const Color(0x3dafff9a),
                                borderRadius: BorderRadius.circular(30)),
                            child: Icon(
                                walletProvider.usageHistoryList?[index].title
                                            .toString() ==
                                        'Gift'
                                    ? Icons.card_giftcard_outlined
                                    : Icons.call_made,
                                color: walletProvider
                                            .usageHistoryList?[index].title
                                            .toString() ==
                                        'Gift'
                                    ? black
                                    : white)),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  MyText(
                                      color: textColor,
                                      multilanguage: false,
                                      text: walletProvider
                                                  .usageHistoryList?[index]
                                                  .message ==
                                              null
                                          ? "Ads"
                                          : 'usage',
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textExtraSmall,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  MyText(
                                      color: textColor,
                                      multilanguage: false,
                                      text: Utils.timeAgoCustom(DateTime.parse(
                                          walletProvider
                                                  .usageHistoryList?[index]
                                                  .createdAt
                                                  .toString() ??
                                              '')),
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textExtraSmall,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ],
                              ),
                              const SizedBox(height: 8),
                              MyText(
                                  color: white,
                                  multilanguage: false,
                                  text: walletProvider
                                          .usageHistoryList?[index].title
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textMedium,
                                  maxline: 1,
                                  fontwaight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            MyImage(
                                width: 15,
                                height: 15,
                                imagePath: "ic_coin.png"),
                            const SizedBox(width: 8),
                            MyText(
                                color: walletProvider.usageHistoryList?[index]
                                            .amountType ==
                                        "pending"
                                    ? Colors.orangeAccent
                                    : walletProvider.usageHistoryList?[index]
                                                .amountType ==
                                            "deducted"
                                        ? Colors.red
                                        : walletProvider
                                                    .usageHistoryList?[index]
                                                    .amountType ==
                                                "added"
                                            ? Colors.green
                                            : white,
                                multilanguage: false,
                                text: walletProvider.usageHistoryList?[index]
                                            .amountType ==
                                        "pending"
                                    ? '${walletProvider.usageHistoryList?[index].totalCoin.toString() ?? ""} pending'
                                    : walletProvider.usageHistoryList?[index]
                                                .amountType ==
                                            "added"
                                        ? '${walletProvider.usageHistoryList?[index].totalCoin.toString() ?? ""} added'
                                        : walletProvider
                                                    .usageHistoryList?[index]
                                                    .amountType ==
                                                "deducted"
                                            ? '${walletProvider.usageHistoryList?[index].totalCoin.toString() ?? ""} deducted'
                                            : walletProvider
                                                    .usageHistoryList?[index]
                                                    .totalCoin
                                                    .toString() ??
                                                "",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textTitle,
                                maxline: 1,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              )),
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  /* Parchas */
  Widget buildParchas() {
    return Consumer<WalletProvider>(builder: (context, walletprovider, child) {
      if (walletprovider.adsPackageloading && !walletprovider.loadMore) {
        return commanShimmer();
      } else {
        return Column(
          children: [
            buildParchasItem(),
            if (walletprovider.loadMore)
              Container(
                height: 50,
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

  Widget buildParchasItem() {
    if (walletProvider.adspackageTransectionModel.status == 200 &&
        walletProvider.adsPackageTransectionList != null) {
      if ((walletProvider.adsPackageTransectionList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ResponsiveGridList(
                minItemWidth: 120,
                minItemsPerRow: 1,
                maxItemsPerRow: 1,
                horizontalGridSpacing: 10,
                verticalGridSpacing: 12,
                listViewBuilderOptions: ListViewBuilderOptions(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
                children: List.generate(
                    walletProvider.adsPackageTransectionList?.length ?? 0,
                    (index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(20, 13, 20, 13),
                    decoration: BoxDecoration(
                        color: buttonDisable,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Color(0x52ffb4b5),
                                borderRadius: BorderRadius.circular(30)),
                            child: Icon(Icons.call_received, color: white)),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  color: textColor,
                                  multilanguage: false,
                                  text: Utils.timeAgoCustom(DateTime.parse(
                                      walletProvider
                                              .adsPackageTransectionList?[index]
                                              .createdAt
                                              .toString() ??
                                          "")),
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textExtraSmall,
                                  maxline: 1,
                                  fontwaight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  MyImage(
                                      width: 15,
                                      height: 15,
                                      imagePath: "ic_coin.png"),
                                  const SizedBox(width: 8),
                                  MyText(
                                      color: white,
                                      multilanguage: false,
                                      text: walletProvider
                                              .adsPackageTransectionList?[index]
                                              .coin
                                              .toString() ??
                                          "",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textMedium,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(width: 5),
                                  MyText(
                                      color: white,
                                      multilanguage: true,
                                      text: "coins",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textMedium,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        MyText(
                            color: white,
                            multilanguage: false,
                            text:
                                "${Constant.currencySymbol} ${walletProvider.adsPackageTransectionList?[index].price.toString() ?? ""}",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textTitle,
                            maxline: 1,
                            fontwaight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                  );
                }),
              )),
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  /* Withdrawal */
  Widget buildWithdrawal() {
    return Consumer<WalletProvider>(builder: (context, walletprovider, child) {
      if (walletprovider.withdrawalloading &&
          !walletprovider.withdrawalloadMore) {
        return commanShimmer();
      } else {
        return Column(
          children: [
            buildWithdrawalItem(),
            if (walletprovider.withdrawalloadMore)
              Container(
                height: 50,
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

  Widget buildWithdrawalItem() {
    if (walletProvider.withdrawalrequestModel.status == 200 &&
        walletProvider.withdrawalTransectionList != null) {
      if ((walletProvider.withdrawalTransectionList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ResponsiveGridList(
                minItemWidth: 120,
                minItemsPerRow: 1,
                maxItemsPerRow: 1,
                horizontalGridSpacing: 10,
                verticalGridSpacing: 12,
                listViewBuilderOptions: ListViewBuilderOptions(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
                children: List.generate(
                    walletProvider.withdrawalTransectionList?.length ?? 0,
                    (index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(20, 13, 20, 13),
                    decoration: BoxDecoration(
                        color: buttonDisable,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Color(0x5cffc889),
                                borderRadius: BorderRadius.circular(30)),
                            child: Icon(Icons.account_balance, color: white)),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  color: textColor,
                                  multilanguage: false,
                                  text: Utils.timeAgoCustom(DateTime.parse(
                                      walletProvider
                                              .withdrawalTransectionList?[index]
                                              .createdAt
                                              .toString() ??
                                          "")),
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textExtraSmall,
                                  maxline: 1,
                                  fontwaight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  MyImage(
                                      width: 15,
                                      height: 15,
                                      imagePath: "ic_coin.png"),
                                  const SizedBox(width: 8),
                                  MyText(
                                      color: white,
                                      multilanguage: false,
                                      text: walletProvider
                                              .withdrawalTransectionList?[index]
                                              .coin
                                              .toString() ??
                                          "",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textMedium,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(width: 5),
                                  MyText(
                                      color: white,
                                      multilanguage: true,
                                      text: "coins",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textMedium,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            MyText(
                                color: white,
                                multilanguage: false,
                                text:
                                    "${Constant.currencySymbol} ${walletProvider.withdrawalTransectionList?[index].amount.toString() ?? ""}",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textTitle,
                                maxline: 1,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            Container(
                              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                              decoration: BoxDecoration(
                                color: walletProvider
                                            .withdrawalTransectionList?[index]
                                            .status ==
                                        1
                                    ? Colors.green
                                    : pureWhite,
                                borderRadius: BorderRadius.circular(35),
                              ),
                              child: MyText(
                                color: walletProvider
                                            .withdrawalTransectionList?[index]
                                            .status ==
                                        1
                                    ? pureWhite
                                    : pureBlack,
                                text: walletProvider
                                            .withdrawalTransectionList?[index]
                                            .status ==
                                        0
                                    ? "Pending"
                                    : "Approved",
                                textalign: TextAlign.start,
                                fontsizeNormal: Dimens.textSmall,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                fontwaight: FontWeight.w700,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              )),
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  Widget commanShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 1,
            maxItemsPerRow: 1,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
            ),
            children: List.generate(8, (index) {
              return Container(
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                decoration: BoxDecoration(color: colorPrimaryDark),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomWidget.roundrectborder(height: 5, width: 80),
                          SizedBox(height: 8),
                          CustomWidget.roundrectborder(
                            height: 5,
                            width: 120,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    CustomWidget.roundrectborder(height: 5, width: 50),
                  ],
                ),
              );
            }),
          )),
    );
  }
}
