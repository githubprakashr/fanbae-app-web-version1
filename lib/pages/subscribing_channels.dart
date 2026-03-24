import 'package:flutter/material.dart';
import 'package:fanbae/model/subscribingChannels.dart' as subscribing;
import 'package:fanbae/pages/profile.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:intl/intl.dart';

import '../model/subscribingChannels.dart';
import '../model/successmodel.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/customwidget.dart';
import '../utils/dimens.dart';
import '../utils/responsive_helper.dart';
import '../utils/utils.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';
import '../widget/nodata.dart';

class SubscribingChannels extends StatefulWidget {
  const SubscribingChannels({super.key});

  @override
  State<SubscribingChannels> createState() => _SubscribingChannelsState();
}

class _SubscribingChannelsState extends State<SubscribingChannels> {
  SubscribingChannelsModel subscribingChannelsModel =
      SubscribingChannelsModel();
  List<subscribing.Result>? subscriberList = [];
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

    subscribingChannelsModel = await ApiService().getSubscribingChannels();

    setState(() {
      if (subscribingChannelsModel.status == 200) {
        subscriberList = subscribingChannelsModel.result;
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
            : Utils().otherPageAppBar(context, "user_subscribing", true),
        body: ResponsiveHelper.checkIsWeb(context)
            ? Utils.sidePanelWithBody(
                myWidget: RefreshIndicator(
                  onRefresh: () => subscribingChannels(),
                  child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        buildSubscribing(),
                      ]),
                ),
              )
            : Utils().pageBg(
                context,
                child: RefreshIndicator(
                  onRefresh: () => subscribingChannels(),
                  child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        buildSubscribing(),
                      ]),
                ),
              ));
  }

  Widget buildSubscribing() {
    if (subscribingChannelsModelLoading) {
      return shimmer();
    } else {
      if (subscriberList != null && (subscriberList?.isNotEmpty ?? false)) {
        final activePlans =
            subscriberList!.where((plan) => plan.status == "current").toList();
        final expiredPlans =
            subscriberList!.where((plan) => plan.status != "current").toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                margin: const EdgeInsets.only(bottom: 16, top: 6),
                decoration: BoxDecoration(
                    gradient: Constant.gradientColor,
                    borderRadius: BorderRadius.circular(25)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          position = 1;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: position == 1 ? 18 : 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: position == 1 ? pureBlack : transparent,
                        ),
                        child: MyText(
                          text: "Active",
                          color: position == 1 ? pureWhite : pureBlack,
                          fontwaight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          position = 2;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: position != 1 ? 18 : 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: position != 1 ? pureBlack : transparent,
                        ),
                        child: MyText(
                          text: "Expired",
                          fontwaight: FontWeight.w500,
                          color: position != 1 ? pureWhite : pureBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              position == 1
                  ? subscribingItem(activePlans)
                  : subscribingItem(expiredPlans),
            ],
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget subscribingItem(List<subscribing.Result> list) {
    if (list.isEmpty) {
      return const Center(child: NoData());
    }
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 19),
      itemCount: list.length,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = list[index];
        bool isToggled = item.isAutoRenew == 1 ? true : false;
        return GestureDetector(
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Profile(
                    isProfile: false,
                    channelUserid: item.creatorId.toString(),
                    channelid: item.channelId.toString(),
                  );
                },
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(colors: [
                    Color(0xfffebdcf),
                    Color(0xfffcdd94),
                    Color(0xffb0eafb),
                  ]),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        item.status == "current"
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  MyText(
                                      text: 'Auto-Renewal: ',
                                      color: pureBlack,
                                      multilanguage: false,
                                      fontsizeNormal: 13.3,
                                      fontwaight: FontWeight.w600),
                                  SizedBox(
                                    height: 21,
                                    width: 21,
                                    child: Checkbox(
                                      value: isToggled,
                                      checkColor: pureWhite,
                                      fillColor: WidgetStateProperty.all(
                                          isToggled ? pureBlack : transparent),
                                      side: const BorderSide(color: pureBlack),
                                      onChanged: (bool? value) async {
                                        SuccessModel res = await ApiService()
                                            .updateAutoRenew(
                                                item.id ?? 0, 'creator');
                                        Utils().showSnackBar(
                                            context, res.message ?? '', false);
                                        setState(() {
                                          isToggled = value!;
                                        });
                                        if (res.status == 200) {
                                          subscribingChannels();
                                        }
                                      },
                                    ),
                                  )
                                ],
                              )
                            : const SizedBox(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 6),
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: MyText(
                            color: pureWhite,
                            text: item.planType ?? "",
                            fontwaight: FontWeight.w500,
                            fontsizeNormal: Dimens.textSmall,
                            maxline: 1,
                            multilanguage: false,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 53),
                    MyText(
                      color: pureBlack,
                      text: item.fullName ?? "",
                      fontwaight: FontWeight.bold,
                      fontsizeNormal: Dimens.textMedium,
                      maxline: 1,
                      multilanguage: false,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                    MyText(
                      color: pureBlack,
                      text: item.channelName ?? "",
                      fontwaight: FontWeight.w500,
                      fontsizeNormal: Dimens.textMedium,
                      maxline: 2,
                      multilanguage: false,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 7, horizontal: 10),
                          decoration: BoxDecoration(
                              color: pureWhite.withAlpha((0.3 * 255).toInt()),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: Colors.grey.shade700,
                                text: 'Pack: ',
                                fontwaight: FontWeight.w500,
                                fontsizeNormal: Dimens.textSmall,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.center,
                                fontstyle: FontStyle.normal,
                              ),
                              MyText(
                                color: pureBlack,
                                text: item.name ?? "",
                                fontwaight: FontWeight.w500,
                                fontsizeNormal: 12.8,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.center,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ),
                        if (item.planValue != 'none')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 10),
                            decoration: BoxDecoration(
                                color: pureWhite.withAlpha((0.3 * 255).toInt()),
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  color: Colors.grey.shade700,
                                  text: 'Plan Type: ',
                                  fontwaight: FontWeight.w500,
                                  fontsizeNormal: Dimens.textSmall,
                                  maxline: 1,
                                  multilanguage: false,
                                  overflow: TextOverflow.ellipsis,
                                  textalign: TextAlign.center,
                                  fontstyle: FontStyle.normal,
                                ),
                                MyText(
                                  color: pureBlack,
                                  text: item.planValue == "best_value"
                                      ? "Best value"
                                      : "Most popular",
                                  fontwaight: FontWeight.w500,
                                  fontsizeNormal: 12.8,
                                  maxline: 1,
                                  multilanguage: false,
                                  overflow: TextOverflow.ellipsis,
                                  textalign: TextAlign.center,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 7, horizontal: 10),
                          decoration: BoxDecoration(
                              color: pureWhite.withAlpha((0.3 * 255).toInt()),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: Colors.grey.shade700,
                                text: "Expires: ",
                                fontwaight: FontWeight.w500,
                                fontsizeNormal: Dimens.textSmall,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.center,
                                fontstyle: FontStyle.normal,
                              ),
                              MyText(
                                color: pureBlack,
                                text: DateFormat('dd-MM-yyyy').format(
                                    DateTime.parse(item.expireDate ?? '')),
                                fontwaight: FontWeight.w500,
                                fontsizeNormal: 12.8,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.center,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 67, // Outer size
                        height: 67,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: Constant.sweepGradient,
                        ),
                      ),
                      Container(
                        width: 61,
                        height: 61,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: MyNetworkImage(
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                            imagePath: item.image ?? ""),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
