import 'package:fanbae/provider/walletprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:url_launcher/url_launcher.dart';

class WebWallet extends StatefulWidget {
  const WebWallet({super.key});

  @override
  State<WebWallet> createState() => WebWalletState();
}

class WebWalletState extends State<WebWallet> {
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
    // walletProvider.setLoadMore(false);
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
    // walletProvider.setLoadMore(tr);
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
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorPrimaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorAccent.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colorPrimary, size: 22),
              const SizedBox(width: 10),
              MyText(
                color: colorPrimary,
                text: "Creator Earnings & Policies",
                multilanguage: false,
                fontsizeNormal: Dimens.textTitle,
                fontsizeWeb: Dimens.textTitle,
                fontwaight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
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
        appBar: Utils.webAppbarWithSidePanel(
            context: context, contentType: Constant.videoSearch),
        body: Utils.sidePanelWithBody(
          myWidget: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 190),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  myWallet(),
                  const SizedBox(height: 20),
                  if (Constant.isCreator == "1") _buildCreatorPoliciesSection(),
                  const SizedBox(height: 30),
                  buildTab(),
                  buildTabItem(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget myWallet() {
    return Consumer<WalletProvider>(builder: (context, walletprovider, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyImage(width: 35, height: 35, imagePath: "ic_coin.png"),
                  const SizedBox(width: 8),
                  walletprovider.loading
                      ? MyText(
                          color: white,
                          multilanguage: false,
                          text: "0",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textlargeBig,
                          fontsizeWeb: Dimens.textlargeBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal)
                      : MyText(
                          color: white,
                          multilanguage: false,
                          text: walletprovider.profileModel.status != 200
                              ? "0"
                              : walletprovider
                                      .profileModel.result?[0].walletBalance
                                      .toString() ??
                                  "",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textlargeBig,
                          fontsizeWeb: Dimens.textlargeBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                  const SizedBox(width: 8),
                  MyText(
                      color: white,
                      multilanguage: true,
                      text: "coins",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textlargeBig,
                      fontsizeWeb: Dimens.textlargeBig,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ],
              ),
              const SizedBox(height: 12),
              MyText(
                  color: white,
                  multilanguage: false,
                  text: "Current Balance",
                  textalign: TextAlign.center,
                  fontsizeNormal: Dimens.textBig,
                  fontsizeWeb: Dimens.textBig,
                  maxline: 1,
                  fontwaight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ],
          ),
          const SizedBox(width: 45),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyImage(width: 35, height: 35, imagePath: "ic_wallet.png"),
                  const SizedBox(width: 10),
                  walletprovider.loading
                      ? MyText(
                          color: white,
                          multilanguage: false,
                          text: "\$0",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textlargeBig,
                          fontsizeWeb: Dimens.textlargeBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal)
                      : MyText(
                          color: white,
                          multilanguage: false,
                          text: walletprovider.profileModel.status != 200
                              ? "0"
                              : "${Constant.currencySymbol}${walletprovider.profileModel.result?[0].walletEarning.toString() ?? ""}",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textlargeBig,
                          fontsizeWeb: Dimens.textlargeBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                ],
              ),
              const SizedBox(height: 12),
              MyText(
                  color: white,
                  multilanguage: false,
                  text: "Withdrawal",
                  textalign: TextAlign.center,
                  fontsizeNormal: Dimens.textBig,
                  fontsizeWeb: Dimens.textBig,
                  maxline: 1,
                  fontwaight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ],
          ),
        ],
      );
    });
  }

  Widget buildTab() {
    return Consumer<WalletProvider>(builder: (context, walletprovider, child) {
      final tabs = Constant().getTransectionTabs();
      return SizedBox(
        height: 65,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: tabs.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: InkWell(
                        autofocus: false,
                        focusColor: appbgcolor,
                        highlightColor: appbgcolor,
                        hoverColor: appbgcolor,
                        splashColor: appbgcolor,
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyText(
                                  color: walletprovider.position == index
                                      ? colorPrimary
                                      : gray,
                                  text: tabs[index],
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textBig,
                                  fontsizeWeb: Dimens.textBig,
                                  inter: false,
                                  multilanguage: false,
                                  maxline: 1,
                                  fontwaight: walletprovider.position == index
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 15),
                              Container(
                                color: walletprovider.position == index
                                    ? colorPrimary
                                    : transparent,
                                height: 3,
                                width: 60,
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            Container(
              color: colorPrimaryDark,
              height: 2,
              width: MediaQuery.of(context).size.width,
            )
          ],
        ),
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
    return Consumer<WalletProvider>(builder: (context, walletprovider, child) {
      if (walletprovider.usageHistoryloading &&
          !walletprovider.usageHistoryloadMore) {
        return commanShimmer();
      } else {
        return Column(
          children: [
            buildUseHistoryItem(),
            if (walletprovider.usageHistoryloadMore)
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
                verticalGridSpacing: 10,
                listViewBuilderOptions: ListViewBuilderOptions(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                ),
                children: List.generate(
                    walletProvider.usageHistoryList?.length ?? 0, (index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                    decoration: BoxDecoration(color: colorPrimaryDark),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  color: colorPrimary,
                                  multilanguage: false,
                                  text: "Ads",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textExtraSmall,
                                  fontsizeWeb: Dimens.textExtraSmall,
                                  maxline: 1,
                                  fontwaight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
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
                                  fontsizeWeb: Dimens.textMedium,
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
                                color: white,
                                multilanguage: false,
                                text: walletProvider
                                        .usageHistoryList?[index].totalCoin
                                        .toString() ??
                                    "",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textTitle,
                                fontsizeWeb: Dimens.textTitle,
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
                verticalGridSpacing: 10,
                listViewBuilderOptions: ListViewBuilderOptions(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                ),
                children: List.generate(
                    walletProvider.adsPackageTransectionList?.length ?? 0,
                    (index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                    decoration: BoxDecoration(color: colorPrimaryDark),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  color: colorPrimary,
                                  multilanguage: false,
                                  text: Utils.timeAgoCustom(DateTime.parse(
                                      walletProvider
                                              .adsPackageTransectionList?[index]
                                              .createdAt
                                              .toString() ??
                                          "")),
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textExtraSmall,
                                  fontsizeWeb: Dimens.textExtraSmall,
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
                                      fontsizeWeb: Dimens.textMedium,
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
                                      fontsizeWeb: Dimens.textMedium,
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
                            fontsizeWeb: Dimens.textTitle,
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
                verticalGridSpacing: 10,
                listViewBuilderOptions: ListViewBuilderOptions(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                ),
                children: List.generate(
                    walletProvider.withdrawalTransectionList?.length ?? 0,
                    (index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                    decoration: BoxDecoration(color: colorPrimaryDark),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  color: colorPrimary,
                                  multilanguage: false,
                                  text: Utils.timeAgoCustom(DateTime.parse(
                                      walletProvider
                                              .withdrawalTransectionList?[index]
                                              .createdAt
                                              .toString() ??
                                          "")),
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textExtraSmall,
                                  fontsizeWeb: Dimens.textExtraSmall,
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
                                              .amount
                                              .toString() ??
                                          "",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
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
                                      fontsizeWeb: Dimens.textMedium,
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
                                "${Constant.currencySymbol} ${walletProvider.withdrawalTransectionList?[index].amount.toString() ?? ""}",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textTitle,
                            maxline: 1,
                            fontsizeWeb: Dimens.textTitle,
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

  /* Shimmer */
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
