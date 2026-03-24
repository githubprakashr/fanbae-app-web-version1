import 'package:fanbae/pages/profile.dart';
import 'package:fanbae/provider/subscribedchannelprovider.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:provider/provider.dart';

import '../utils/responsive_helper.dart';

class SubscribedChannel extends StatefulWidget {
  const SubscribedChannel({super.key});

  @override
  State<SubscribedChannel> createState() => SubscribedChannelState();
}

class SubscribedChannelState extends State<SubscribedChannel> {
  late SubscribedChannelProvider subscribedChannelProvider;
  final ScrollController subscriberController = ScrollController();

  @override
  void initState() {
    subscribedChannelProvider =
        Provider.of<SubscribedChannelProvider>(context, listen: false);
    subscriberController.addListener(_scrollListenerCategory);
    super.initState();
    _fetchSubscriberData(0);
  }

  /* Category Scroll Pagination */
  _scrollListenerCategory() async {
    if (!subscriberController.hasClients) return;
    if (subscriberController.offset >=
            subscriberController.position.maxScrollExtent &&
        !subscriberController.position.outOfRange &&
        (subscribedChannelProvider.currentPage ?? 0) <
            (subscribedChannelProvider.totalPage ?? 0)) {
      printLog("load more====>");
      await subscribedChannelProvider.setSubscriberLoadMore(true);
      _fetchSubscriberData(subscribedChannelProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchSubscriberData(int? nextPage) async {
    printLog("isMorePage  ======> ${subscribedChannelProvider.isMorePage}");
    printLog("currentPage ======> ${subscribedChannelProvider.currentPage}");
    printLog("totalPage   ======> ${subscribedChannelProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await subscribedChannelProvider.getSubscriberList((nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    subscribedChannelProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appbgcolor,
        appBar: ResponsiveHelper.checkIsWeb(context)
            ? Utils.webAppbarWithSidePanel(context: context)
            : Utils().otherPageAppBar(context, "following", true),
        body: ResponsiveHelper.checkIsWeb(context)
            ? Utils.sidePanelWithBody(
                myWidget: buildBody(),
              )
            : Utils().pageBg(
                context,
                child: buildBody(),
              ));
  }

  Widget buildBody() {
    return Consumer<SubscribedChannelProvider>(
      builder: (context, channelProvider, child) {
        return RefreshIndicator(
          color: colorAccent,
          backgroundColor: colorPrimaryDark,
          onRefresh: () => _fetchSubscriberData(0),
          child: ListView(
            controller: subscriberController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10),
            children: [
              buildSubscription(),
            ],
          ),
        );
      },
    );
  }

  Widget buildSubscription() {
    if (subscribedChannelProvider.subscriberLoading &&
        !subscribedChannelProvider.subscriberloadMore) {
      return shimmer();
    } else {
      if (subscribedChannelProvider.subscriberList != null &&
          (subscribedChannelProvider.subscriberList?.length ?? 0) > 0) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            subscriberListItem(),
            if (subscribedChannelProvider.subscriberloadMore)
              const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: colorPrimary,
                    strokeWidth: 1,
                  ))
            else
              const SizedBox.shrink(),
          ],
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget subscriberListItem() {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemCount: subscribedChannelProvider.subscriberList?.length ?? 0,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return InkWell(
          autofocus: false,
          highlightColor: transparent,
          focusColor: transparent,
          hoverColor: transparent,
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Profile(
                    isProfile: false,
                    channelUserid: subscribedChannelProvider
                            .subscriberList?[index].id
                            .toString() ??
                        "",
                    channelid: subscribedChannelProvider
                            .subscriberList?[index].channelId
                            .toString() ??
                        "",
                  );
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: buttonDisable,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(width: 1, color: colorPrimary)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: MyNetworkImage(
                        width: 42,
                        height: 42,
                        imagePath: subscribedChannelProvider
                                .subscriberList?[index].image ??
                            "",
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      color: white,
                      text: (subscribedChannelProvider
                                      .subscriberList?[index].fullName ??
                                  "") ==
                              ""
                          ? (subscribedChannelProvider
                                  .subscriberList?[index].channelName ??
                              "")
                          : (subscribedChannelProvider
                                  .subscriberList?[index].fullName ??
                              ""),
                      fontwaight: FontWeight.bold,
                      fontsizeNormal: Dimens.textMedium,
                      maxline: 1,
                      multilanguage: false,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 5),
                    MyText(
                      color: white,
                      text: (subscribedChannelProvider
                                      .subscriberList?[index].fullName ??
                                  "") ==
                              ""
                          ? (subscribedChannelProvider
                                  .subscriberList?[index].channelId ??
                              "")
                          : (subscribedChannelProvider
                                  .subscriberList?[index].channelName ??
                              ""),
                      fontwaight: FontWeight.w500,
                      fontsizeNormal: Dimens.textMedium,
                      maxline: 1,
                      multilanguage: false,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget shimmer() {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: 10,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomWidget.circular(
              width: 45,
              height: 45,
            ),
            SizedBox(height: 10),
            CustomWidget.roundrectborder(
              width: 100,
              height: 10,
            ),
          ],
        );
      },
    );
  }
}
