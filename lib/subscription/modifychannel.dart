import 'package:flutter/material.dart';
import 'package:fanbae/utils/utils.dart';

import '../model/modifychannelmodel.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/responsive_helper.dart';
import '../webservice/apiservice.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';

class ModifyChannel extends StatefulWidget {
  final bool isAutoRenew;
  const ModifyChannel({super.key, required this.isAutoRenew});

  @override
  State<ModifyChannel> createState() => _ModifyChannelState();
}

class _ModifyChannelState extends State<ModifyChannel> {
  bool loading = false;
  bool isToggled = false;
  int channelLimit = 0;
  List<Channels>? allChannels;
  List<Channels>? currentChannels;
  List<Channels>? upcomingChannels;
  List<int> selectedChannels = [];

  @override
  void initState() {
    getApi();
    super.initState();
  }

  getApi() async {
    setState(() {
      loading = true;
      isToggled = widget.isAutoRenew;
    });
    ModifyChannelsModel data = await ApiService().getModifyChannels();
    channelLimit = data.result.limitChannel;
    allChannels = data.result.channels;
    currentChannels = data.result.channels
        .where((channel) => channel.channelStatus == 'subscribed')
        .toList();
    upcomingChannels = data.result.channels
        .where((channel) => channel.channelStatus == "upcoming_subscribed")
        .toList();
    if (upcomingChannels != null && upcomingChannels!.isNotEmpty) {
      selectedChannels =
          upcomingChannels!.map((channel) => channel.id).toList();
    } else {
      selectedChannels = currentChannels!.map((channel) => channel.id).toList();
    }
    setState(() {
      loading = false;
    });
  }

  buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentChannels != null && currentChannels!.isNotEmpty) ...[
          Utils().titleText("currentchannels"),
          ListView.separated(
            itemCount: currentChannels!.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              return Container(
                clipBehavior: Clip.antiAlias,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  margin: const EdgeInsets.all(2.2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
                  decoration: BoxDecoration(
                      color: const Color(0xff4A4A4A).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10)),
                  child: !ResponsiveHelper.isDesktop(context)
                      ? Row(
                          children: [
                            Container(
                                clipBehavior: Clip.antiAlias,
                                margin: const EdgeInsets.only(right: 12),
                                width: MediaQuery.of(context).size.width * 0.1,
                                height: MediaQuery.of(context).size.width * 0.1,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: MyNetworkImage(
                                    imagePath: currentChannels![i].image,
                                    fit: BoxFit.cover)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: currentChannels![i].channelName,
                                    color: white,
                                    multilanguage: false,
                                    fontwaight: FontWeight.w600,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  MyText(
                                    text: currentChannels![i].fullName,
                                    color: white,
                                    multilanguage: false,
                                    fontsizeNormal: 13,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Container(
                                clipBehavior: Clip.antiAlias,
                                margin: const EdgeInsets.only(right: 20),
                                width:
                                    MediaQuery.of(context).size.width * 0.045,
                                height:
                                    MediaQuery.of(context).size.width * 0.045,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: MyNetworkImage(
                                    imagePath: currentChannels![i].image,
                                    fit: BoxFit.cover)),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 220,
                                    child: MyText(
                                      maxline: 2,
                                      text: currentChannels![i].channelName,
                                      color: white,
                                      multilanguage: false,
                                      fontwaight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: MyText(
                                      text: currentChannels![i]
                                          .fullName
                                          .toString(),
                                      color: white,
                                      multilanguage: false,
                                      fontsizeNormal: 11.3,
                                      maxline: 2,
                                      fontwaight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                height: 16,
              );
            },
          ),
          const SizedBox(height: 12)
        ],
        if (upcomingChannels != null && upcomingChannels!.isNotEmpty) ...[
          Utils().titleText("upcomingchannels"),
          ListView.separated(
            itemCount: upcomingChannels!.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              return Container(
                clipBehavior: Clip.antiAlias,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  margin: const EdgeInsets.all(2.2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
                  decoration: BoxDecoration(
                      color: const Color(0xff4A4A4A).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10)),
                  child: !ResponsiveHelper.isDesktop(context)
                      ? Row(
                          children: [
                            Container(
                                clipBehavior: Clip.antiAlias,
                                margin: const EdgeInsets.only(right: 12),
                                width: MediaQuery.of(context).size.width * 0.1,
                                height: MediaQuery.of(context).size.width * 0.1,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: MyNetworkImage(
                                    imagePath: upcomingChannels![i].image,
                                    fit: BoxFit.cover)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: upcomingChannels![i].channelName,
                                    color: white,
                                    multilanguage: false,
                                    fontwaight: FontWeight.w600,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  MyText(
                                    text: upcomingChannels![i].fullName,
                                    color: white,
                                    multilanguage: false,
                                    fontsizeNormal: 13,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Container(
                                clipBehavior: Clip.antiAlias,
                                margin: const EdgeInsets.only(right: 20),
                                width:
                                    MediaQuery.of(context).size.width * 0.045,
                                height:
                                    MediaQuery.of(context).size.width * 0.045,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: MyNetworkImage(
                                    imagePath: upcomingChannels![i].image,
                                    fit: BoxFit.cover)),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 220,
                                    child: MyText(
                                      maxline: 2,
                                      text: upcomingChannels![i].channelName,
                                      color: white,
                                      multilanguage: false,
                                      fontwaight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: MyText(
                                      text: upcomingChannels![i]
                                          .fullName
                                          .toString(),
                                      color: white,
                                      multilanguage: false,
                                      fontsizeNormal: 11.3,
                                      maxline: 2,
                                      fontwaight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                height: 16,
              );
            },
          ),
          const SizedBox(height: 12)
        ],
        if (allChannels != null && allChannels!.isNotEmpty) ...[
          Utils().titleText("modifychannels"),
          ListView.separated(
            itemCount: allChannels!.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    gradient: selectedChannels.contains(allChannels?[i].id)
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                                const Color(0xff6DA9F8).withOpacity(0.8),
                                const Color(0xFF01DED1).withOpacity(0.8),
                                const Color(0xffFE3379).withOpacity(0.8),
                              ])
                        : null,
                    borderRadius: BorderRadius.circular(12)),
                child: Container(
                  margin: const EdgeInsets.all(2.2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
                  decoration: BoxDecoration(
                      color: const Color(0xff4A4A4A).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10)),
                  child: !ResponsiveHelper.isDesktop(context)
                      ? Row(
                          children: [
                            Container(
                                clipBehavior: Clip.antiAlias,
                                margin: const EdgeInsets.only(right: 12),
                                width: MediaQuery.of(context).size.width * 0.1,
                                height: MediaQuery.of(context).size.width * 0.1,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: MyNetworkImage(
                                    imagePath: allChannels![i].image,
                                    fit: BoxFit.cover)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: allChannels![i].channelName,
                                    color: white,
                                    multilanguage: false,
                                    fontwaight: FontWeight.w600,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  MyText(
                                    text: allChannels![i].fullName,
                                    color: white,
                                    multilanguage: false,
                                    fontsizeNormal: 13,
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (selectedChannels
                                    .contains(allChannels![i].id)) {
                                  setState(() {
                                    selectedChannels.remove(allChannels![i].id);
                                  });
                                } else {
                                  if (selectedChannels.length < channelLimit) {
                                    setState(() {
                                      selectedChannels.add(allChannels![i].id);
                                    });
                                  } else {
                                    Utils().showSnackBar(
                                        context,
                                        "You can only able to select ${channelLimit} channels",
                                        false);
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7.5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: selectedChannels
                                            .contains(allChannels![i].id)
                                        ? null
                                        : buttonDisable,
                                    gradient: selectedChannels
                                            .contains(allChannels![i].id)
                                        ? Constant.gradientColor
                                        : null),
                                child: MyText(
                                  text: selectedChannels
                                          .contains(allChannels![i].id)
                                      ? "selected"
                                      : 'select',
                                  color: selectedChannels
                                          .contains(allChannels![i].id)
                                      ? pureBlack
                                      : white,
                                  fontsizeNormal: Dimens.textSmall,
                                  fontwaight: FontWeight.w700,
                                ),
                              ),
                            )
                          ],
                        )
                      : Row(
                          children: [
                            Container(
                                clipBehavior: Clip.antiAlias,
                                margin: const EdgeInsets.only(right: 20),
                                width:
                                    MediaQuery.of(context).size.width * 0.045,
                                height:
                                    MediaQuery.of(context).size.width * 0.045,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: MyNetworkImage(
                                    imagePath: allChannels![i].image,
                                    fit: BoxFit.cover)),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 220,
                                    child: MyText(
                                      maxline: 2,
                                      text: allChannels![i].channelName,
                                      color: white,
                                      multilanguage: false,
                                      fontwaight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: MyText(
                                      text: allChannels![i].fullName.toString(),
                                      color: white,
                                      multilanguage: false,
                                      fontsizeNormal: 11.3,
                                      maxline: 2,
                                      fontwaight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (selectedChannels
                                    .contains(allChannels![i].id)) {
                                  setState(() {
                                    selectedChannels.remove(allChannels![i].id);
                                  });
                                } else {
                                  if (selectedChannels.length < channelLimit) {
                                    setState(() {
                                      selectedChannels.add(allChannels![i].id);
                                    });
                                  } else {
                                    Utils().showSnackBar(
                                        context,
                                        "You can only able to select $channelLimit channels",
                                        false);
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7.5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: selectedChannels
                                            .contains(allChannels![i].id)
                                        ? null
                                        : buttonDisable,
                                    gradient: selectedChannels
                                            .contains(allChannels![i].id)
                                        ? Constant.gradientColor
                                        : null),
                                child: MyText(
                                  text: selectedChannels
                                          .contains(allChannels![i].id)
                                      ? "subscribed"
                                      : 'subscribe',
                                  color: selectedChannels
                                          .contains(allChannels![i].id)
                                      ? pureBlack
                                      : white,
                                  fontsizeNormal: Dimens.textSmall,
                                  fontwaight: FontWeight.w700,
                                ),
                              ),
                            )
                          ],
                        ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                height: 16,
              );
            },
          ),
        ]
      ],
    );
  }

  updateChannels() async {
    Utils.showProgress(context);
    ModifyChannelsModel response = await ApiService()
        .updateModifyChannels(selectedChannels, isToggled ? 1 : 0);
    Utils().hideProgress(context);
    if (mounted) {
      Utils().showSnackBar(context, response.message, false);
    }
    if (response.status == 200) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: appbgcolor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: white,
          ),
        ),
        title: MyText(
          text: "modifychannels",
          color: white,
          fontsizeNormal: Dimens.textBig,
          fontwaight: FontWeight.bold,
        ),
        actions: [
          Row(
            children: [
              Icon(
                Icons.shopping_cart,
                color: white,
                size: 19,
              ),
              const SizedBox(
                width: 5,
              ),
              channelLimit != 0
                  ? MyText(
                      text: "${selectedChannels.length}/$channelLimit",
                      multilanguage: false,
                      color: white,
                      fontwaight: FontWeight.w600,
                    )
                  : const SizedBox(),
              const SizedBox(
                width: 15,
              ),
            ],
          )
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Utils().pageBg(context,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                                width: ResponsiveHelper.isDesktop(context)
                                    ? MediaQuery.of(context).size.width * 0.5
                                    : ResponsiveHelper.isTab(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.63
                                        : MediaQuery.of(context).size.width,
                                child: buildBody()),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 13.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyText(
                            text: 'Do you want Auto-Renewal? ',
                            multilanguage: false,
                            color: white,
                            fontwaight: FontWeight.w500),
                        SizedBox(
                          height: 25,
                          width: 35,
                          child: Checkbox(
                            value: isToggled,
                            checkColor: pureBlack,
                            fillColor: WidgetStateProperty.all(
                                isToggled ? textColor : transparent),
                            onChanged: (bool? value) async {
                              setState(() {
                                isToggled = value!;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (selectedChannels.length < channelLimit) {
                        return Utils().showSnackBar(context,
                            "Need to select $channelLimit channels", false);
                      }
                      updateChannels();
                    },
                    child: Padding(
                      padding: ResponsiveHelper.isDesktop(context)
                          ? EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.35,
                              right: MediaQuery.of(context).size.width * 0.35)
                          : const EdgeInsets.all(0),
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                            gradient: Constant.gradientColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: MyText(
                            text: 'submit',
                            color: pureBlack,
                            fontwaight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )),
    ));
  }
}
