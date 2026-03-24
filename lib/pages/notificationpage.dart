import 'package:fanbae/provider/notificationprovider.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  late NotificationProvider notificationProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    _fetchData(0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (notificationProvider.currentPage ?? 0) <
            (notificationProvider.totalPage ?? 0)) {
      _fetchData(notificationProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchData(int? nextPage) async {
    printLog("isMorePage  ======> ${notificationProvider.isMorePage}");
    printLog("currentPage ======> ${notificationProvider.currentPage}");
    printLog("totalPage   ======> ${notificationProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await notificationProvider.getNotification((nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    // notificationProvider.clearProvider(); // <-- Do not clear notifications here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: Utils().otherPageAppBar(context, "notification", true),
      body: Utils().pageBg(
        context,
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(18, 15, 18, 190),
              physics: const BouncingScrollPhysics(),
              child: buildNotification(),
            ),
            Utils.musicAndAdsPanel(context),
          ],
        ),
      ),
    );
  }

  Widget buildNotification() {
    return Consumer<NotificationProvider>(
        builder: (context, notificationprovider, child) {
      if (notificationprovider.loading && !notificationprovider.loadmore) {
        return notificationShimmer();
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            notificationList(),
            if (notificationProvider.loadmore)
              SizedBox(
                height: 50,
                child: Utils.pageLoader(context),
              )
            else
              const SizedBox.shrink(),
          ],
        );
      }
    });
  }

  Widget notificationList() {
    if (notificationProvider.getNotificationModel.status == 200 &&
        notificationProvider.notificationList != null) {
      if ((notificationProvider.notificationList?.length ?? 0) > 0) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: notificationProvider.notificationList?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: buttonDisable),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      // border: Border.all(width: 1, color: colorPrimary),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child:
                        notificationProvider.notificationList?[index].type == 1
                            ? MyImage(
                                width: 50,
                                height: 50,
                                imagePath: "ic_user.png",
                                color: colorPrimary,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: MyNetworkImage(
                                    width: 50,
                                    height: 50,
                                    imagePath: notificationProvider
                                            .notificationList?[index].userImage
                                            .toString() ??
                                        "",
                                    fit: BoxFit.cover),
                              ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        notificationProvider.notificationList?[index].type == 1
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                      color: white,
                                      text: notificationProvider
                                              .notificationList?[index].title
                                              ?.toString() ??
                                          "",
                                      fontsizeNormal: Dimens.textDesc,
                                      multilanguage: false,
                                      maxline: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal,
                                      fontwaight: FontWeight.w500),
                                  const SizedBox(height: 5),
                                  MyText(
                                      color: white,
                                      text: Utils.timeAgoCustom(DateTime.parse(
                                          notificationProvider
                                                  .notificationList?[index]
                                                  .createdAt
                                                  ?.toString() ??
                                              "")),
                                      fontsizeNormal: Dimens.textDesc,
                                      multilanguage: false,
                                      maxline: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal,
                                      fontwaight: FontWeight.w500),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    constraints:
                                        const BoxConstraints(minHeight: 0),
                                    alignment: Alignment.centerLeft,
                                    child: ExpandableText(
                                      notificationProvider
                                              .notificationList?[index].message
                                              .toString() ??
                                          "",
                                      expandText: "Read More",
                                      collapseText: "Read less",
                                      maxLines: 2,
                                      expandOnTextTap: true,
                                      collapseOnTextTap: true,
                                      linkStyle: TextStyle(
                                        fontSize: Dimens.textDesc,
                                        fontStyle: FontStyle.normal,
                                        color: colorPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      style: TextStyle(
                                        fontSize: Dimens.textSmall,
                                        fontStyle: FontStyle.normal,
                                        color: gray,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                      color: Constant.darkMode == "true"
                                          ? colorPrimary
                                          : button1color,
                                      text: notificationProvider
                                              .notificationList?[index].title
                                              ?.toString() ??
                                          "",
                                      fontsizeNormal: Dimens.textDesc,
                                      multilanguage: false,
                                      maxline: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal,
                                      fontwaight: FontWeight.w500),
                                  const SizedBox(height: 5),
                                  MyText(
                                      color: white,
                                      text: Utils.timeAgoCustom(DateTime.parse(
                                          notificationProvider
                                                  .notificationList?[index]
                                                  .createdAt
                                                  ?.toString() ??
                                              "")),
                                      fontsizeNormal: Dimens.textDesc,
                                      multilanguage: false,
                                      maxline: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal,
                                      fontwaight: FontWeight.w500)
                                ],
                              ),
                        const SizedBox(height: 13),
                        // Constant.userID == null
                        //     ? const SizedBox.shrink()
                        //     : Consumer<NotificationProvider>(builder:
                        //         (context, notificationprovider, child) {
                        //         if (notificationprovider.position == index &&
                        //             notificationprovider
                        //                 .readnotificationloading) {
                        //           return const SizedBox(
                        //             height: 20,
                        //             width: 20,
                        //             child: CircularProgressIndicator(
                        //               color: colorPrimary,
                        //               strokeWidth: 1,
                        //             ),
                        //           );
                        //         } else {
                        //           return InkWell(
                        //             onTap: () async {
                        //               await notificationProvider
                        //                   .getReadNotification(
                        //                       index,
                        //                       notificationProvider
                        //                               .notificationList?[index]
                        //                               .id
                        //                               ?.toString() ??
                        //                           "",
                        //                       true);
                        //             },
                        //             child: MyImage(
                        //                 width: 16,
                        //                 height: 16,
                        //                 imagePath: "ic_delete.png"),
                        //           );
                        //         }
                        //       }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Constant.userID == null
                          ? const SizedBox.shrink()
                          : Consumer<NotificationProvider>(
                              builder: (context, notificationprovider, child) {
                              if (notificationprovider.position == index &&
                                  notificationprovider
                                      .readnotificationloading) {
                                return const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: colorPrimary,
                                    strokeWidth: 1,
                                  ),
                                );
                              } else {
                                return InkWell(
                                  onTap: () async {
                                    await notificationProvider
                                        .getReadNotification(
                                            index,
                                            notificationProvider
                                                    .notificationList?[index].id
                                                    ?.toString() ??
                                                "",
                                            true);
                                  },
                                  child:
                                      Icon(Icons.close, color: white, size: 18),
                                );
                              }
                            }),
                      const SizedBox(height: 10),
                      notificationProvider
                                      .notificationList?[index].contentImage !=
                                  null &&
                              !notificationProvider
                                  .notificationList![index].contentImage!
                                  .contains('no_img.png')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: notificationProvider
                                          .notificationList?[index].type ==
                                      1
                                  ? const SizedBox.shrink()
                                  : MyNetworkImage(
                                      width: 65,
                                      height: 45,
                                      imagePath: notificationProvider
                                              .notificationList?[index]
                                              .contentImage
                                              .toString() ??
                                          "",
                                      fit: BoxFit.cover),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  Widget notificationShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (BuildContext ctx, index) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomWidget.circular(
                width: 55,
                height: 55,
              ),
              SizedBox(width: 10),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.roundrectborder(
                    width: 250,
                    height: 8,
                  ),
                  SizedBox(height: 5),
                  CustomWidget.roundrectborder(
                    width: 250,
                    height: 8,
                  ),
                ],
              )),
            ],
          ),
        );
      },
    );
  }
}
