import 'package:fanbae/provider/generalprovider.dart';
import 'package:fanbae/provider/notificationprovider.dart';
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

class WebNotificationPage extends StatefulWidget {
  const WebNotificationPage({super.key});

  @override
  State<WebNotificationPage> createState() => WebNotificationPageState();
}

class WebNotificationPageState extends State<WebNotificationPage> {
  late NotificationProvider notificationProvider;
  late GeneralProvider generalProvider;
  late ScrollController _scrollController;
  Future<void>? _scrollDebounceTimer;

  @override
  void initState() {
    notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
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
      // ⏱️ Debounce scroll to prevent rapid API calls
      if (_scrollDebounceTimer != null) {
        return; // Skip if already debouncing
      }

      await notificationProvider.setLoadMore(true);
      _fetchData(notificationProvider.currentPage ?? 0);

      // Prevent another scroll request for 2 seconds
      _scrollDebounceTimer = Future.delayed(Duration(seconds: 2), () {
        _scrollDebounceTimer = null;
      });
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
    await notificationProvider.setLoadMore(false);
  }

  @override
  void dispose() {
    notificationProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimaryDark,
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: colorPrimaryDark,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: MyText(
              color: white,
              text: "notification",
              fontsizeNormal: Dimens.textBig,
              fontsizeWeb: Dimens.textBig,
              multilanguage: true,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.left,
              fontstyle: FontStyle.normal,
              fontwaight: FontWeight.w500),
        ),
        actions: [
          InkWell(
            onTap: () async {
              await generalProvider.getNotificationSectionShowHide(false);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Icon(
                Icons.close,
                color: white,
                size: 25,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        physics: const BouncingScrollPhysics(),
        child: buildNotification(),
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
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child:
                        notificationProvider.notificationList?[index].type == 1
                            ? MyImage(
                                width: 55,
                                height: 55,
                                color: colorPrimary,
                                imagePath: "ic_user.png")
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: MyNetworkImage(
                                    width: 55,
                                    height: 55,
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
                                      fontsizeWeb: Dimens.textDesc,
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
                            : MyText(
                                color: white,
                                text: notificationProvider
                                        .notificationList?[index].title
                                        ?.toString() ??
                                    "",
                                fontsizeNormal: Dimens.textDesc,
                                fontsizeWeb: Dimens.textDesc,
                                multilanguage: false,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.left,
                                fontstyle: FontStyle.normal,
                                fontwaight: FontWeight.w500),
                        const SizedBox(height: 13),
                        Consumer<NotificationProvider>(
                            builder: (context, notificationprovider, child) {
                          if (notificationprovider.position == index &&
                              notificationprovider.readnotificationloading) {
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
                                await notificationProvider.getReadNotification(
                                    index,
                                    notificationProvider
                                            .notificationList?[index].id
                                            ?.toString() ??
                                        "",
                                    true);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(25)),
                                child: MyText(
                                    color: white,
                                    text: "delete",
                                    fontsizeNormal: Dimens.textSmall,
                                    fontsizeWeb: Dimens.textSmall,
                                    multilanguage: true,
                                    maxline: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textalign: TextAlign.left,
                                    fontstyle: FontStyle.normal,
                                    fontwaight: FontWeight.w500),
                              ),
                            );
                          }
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child:
                        notificationProvider.notificationList?[index].type == 1
                            ? const SizedBox.shrink()
                            : MyNetworkImage(
                                width: 65,
                                height: 47,
                                imagePath: notificationProvider
                                        .notificationList?[index].contentImage
                                        .toString() ??
                                    "",
                                fit: BoxFit.cover),
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
