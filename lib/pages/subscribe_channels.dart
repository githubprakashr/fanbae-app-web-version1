import 'package:flutter/material.dart';
import 'package:fanbae/model/subscribeChannelModel.dart' as subscribing;
import 'package:fanbae/pages/profile.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/subscribeChannelModel.dart';
import '../model/subscribingChannels.dart';
import '../utils/color.dart';
import '../utils/customwidget.dart';
import '../utils/dimens.dart';
import '../utils/responsive_helper.dart';
import '../utils/utils.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';
import '../widget/nodata.dart';

class SubscribeChannels extends StatefulWidget {
  const SubscribeChannels({super.key});

  @override
  State<SubscribeChannels> createState() => _SubscribeChannelsState();
}

class _SubscribeChannelsState extends State<SubscribeChannels> {
  SubscribeChannelsModel subscribingChannelsModel = SubscribeChannelsModel();
  List<subscribing.Result> subscriberList = [];
  bool subscribingChannelsModelLoading = false;
  int position = 1;

  @override
  void initState() {
    // TODO: implement initState
    subscribingChannels();
    super.initState();
  }

  Future<void> subscribingChannels() async {
    setState(() {
      subscribingChannelsModelLoading = true;
    });

    subscribingChannelsModel = await ApiService().getSubscribeChannels();

    setState(() {
      if (subscribingChannelsModel.status == 200) {
        subscriberList = subscribingChannelsModel.result!;
      } else {
        subscriberList = [];
      }
      subscribingChannelsModelLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appbgcolor,
        appBar: ResponsiveHelper.checkIsWeb(context)
            ? Utils.webAppbarWithSidePanel(context: context)
            : Utils().otherPageAppBar(context, "Subscribers", false),
        body: ResponsiveHelper.checkIsWeb(context)
            ? Utils.sidePanelWithBody(
                myWidget: RefreshIndicator(
                  onRefresh: () => subscribingChannels(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildSubscribing(),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Utils().pageBg(
                context,
                child: RefreshIndicator(
                  onRefresh: () => subscribingChannels(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildSubscribing(),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
  }

  Widget buildSubscribing() {
    if (subscribingChannelsModelLoading) {
      return shimmer();
    } else {
      print(subscriberList.length ?? 0);
      if ((subscriberList.isNotEmpty ?? false)) {
        /*final activePlans =
        subscriberList!.where((plan) => plan.status == "current").toList();
        final expiredPlans =
        subscriberList!.where((plan) => plan.status != "current").toList();*/
        return Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: subscribingListItem(),
            ),
          ],
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget subscribingListItem() {
    if (subscriberList.isEmpty) {
      return const Center(child: NoData());
    }
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemCount: subscriberList.length,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = subscriberList[index];

        return InkWell(
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Profile(
                    isProfile: false,
                    channelUserid: item.id.toString(),
                    channelid: item.channelId.toString(),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  margin: const EdgeInsets.fromLTRB(1, 0, 13, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(width: 1, color: colorPrimary),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: MyNetworkImage(
                      width: 42,
                      height: 42,
                      imagePath: item.image ?? "",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      color: white,
                      text: item.fullName ?? "",
                      fontwaight: FontWeight.w500,
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
                      text: item.channelName ?? "",
                      fontwaight: FontWeight.w500,
                      fontsizeNormal: Dimens.textMedium,
                      maxline: 2,
                      multilanguage: false,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 5),
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
