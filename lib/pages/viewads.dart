import 'package:flutter/material.dart';
import 'package:fanbae/pages/create_ad.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:fanbae/widget/mynetworkimg.dart';

import '../model/creatoradmodel.dart';
import '../model/successmodel.dart';
import 'package:fanbae/model/creatoradmodel.dart' as ads;

import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/utils.dart';
import '../webservice/apiservice.dart';
import '../widget/myimage.dart';
import '../widget/mytext.dart';
import '../widget/nodata.dart';

class ViewAds extends StatefulWidget {
  const ViewAds({super.key});

  @override
  State<ViewAds> createState() => _ViewAdsState();
}

class _ViewAdsState extends State<ViewAds> {
  late CreatorAdModel adsModel;
  bool isLoad = false;

  @override
  void initState() {
    getCreatorAds(context);
    super.initState();
  }

  Future<void> getCreatorAds(BuildContext context) async {
    setState(() {
      isLoad = true;
    });
    adsModel = await ApiService().getCreatorAds(Constant.userID);
    if (adsModel.status != 200) {
      Utils().showSnackBar(context, adsModel.message ?? '', false);
    }
    setState(() {
      isLoad = false;
    });
  }

  buildCreateAdDialog(ads.Result? adItem) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: transparent,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 115, vertical: 70),
          backgroundColor: colorPrimaryDark,
          child: Stack(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: colorPrimaryDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CreateAd(ad: adItem),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: white.withOpacity(0.3), shape: BoxShape.circle),
                    child: const Icon(
                      Icons.close,
                      size: 23,
                      color: Colors.white, // or any color that suits your theme
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appbgcolor,
        appBar: ResponsiveHelper.checkIsWeb(context)
            ? Utils.webAppbarWithSidePanel(context: context)
            : AppBar(
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
                title: MyText(text: "ads", color: white),
                // actions: [
                //    GestureDetector(
                //      onTap: () async {
                //        kIsWeb ? await buildCreateAdDialog(null) : await Navigator.push(
                //          context,
                //          MaterialPageRoute(
                //            builder: (context) => CreateAd(),
                //          ),
                //        );
                //        // Refresh list
                //        getCreatorAds(context);
                //      },
                //     child: Container(
                //       padding:
                //       const EdgeInsets.symmetric(vertical: 6, horizontal: 11),
                //       margin: const EdgeInsets.only(right: 15, left: 8),
                //       decoration: BoxDecoration(
                //           color: colorPrimary,
                //           borderRadius: BorderRadius.circular(8)),
                //       child: Row(
                //         children: [
                //            Icon(
                //             Icons.add,
                //             color: white,
                //           ),
                //           const SizedBox(
                //             width: 5,
                //           ),
                //           Text(
                //             "Add",
                //             style: Theme.of(context)
                //                 .textTheme
                //                 .bodyMedium
                //                 ?.copyWith(color: white),
                //           )
                //         ],
                //       ),
                //     ),
                //   )
                // ],
              ),
        floatingActionButton: GestureDetector(
          onTap: () async {
            ResponsiveHelper.checkIsWeb(context)
                ? await buildCreateAdDialog(null)
                : await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAd(),
                    ),
                  );
            // Refresh list
            getCreatorAds(context);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 5, bottom: 25),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
                gradient: Constant.gradientColor,
                borderRadius: BorderRadius.circular(40)),
            child: const Icon(
              Icons.add,
              color: pureBlack,
            ),
          ),
        ),
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
    return isLoad
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : adsModel.result.isEmpty
            ? const NoData()
            : ResponsiveHelper.checkIsWeb(context)
                ? ListView.builder(
                    itemCount: !ResponsiveHelper.isMobile(context)
                        ? (adsModel.result.length / 3).ceil()
                        : (adsModel.result.length / 2).ceil(),
                    itemBuilder: (BuildContext context, int i) {
                      final ad = adsModel.result;
                      final firstIndex =
                          !ResponsiveHelper.isMobile(context) ? i * 3 : i * 2;
                      final secondIndex = firstIndex + 1;
                      final thirdIndex = firstIndex + 2;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                                child: buildAdItem(ad[firstIndex], context)),
                            const SizedBox(width: 10),
                            if (secondIndex < ad.length)
                              Expanded(
                                  child: buildAdItem(ad[secondIndex], context))
                            else
                              const Expanded(child: SizedBox()),
                            if (!ResponsiveHelper.isMobile(context)) ...[
                              const SizedBox(width: 10),
                              if (thirdIndex < ad.length)
                                Expanded(
                                    child: buildAdItem(ad[thirdIndex], context))
                              else
                                const Expanded(child: SizedBox()),
                            ]
                          ],
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: (adsModel.result.length),
                    itemBuilder: (BuildContext context, int i) {
                      final ad = adsModel.result;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: buildAdItem(ad[i], context),
                      );
                    },
                  );
  }

  Widget buildAdItem(ads.Result? adItem, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        ResponsiveHelper.checkIsWeb(context)
            ? await buildCreateAdDialog(adItem)
            : await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateAd(ad: adItem),
                ),
              );
        // Refresh list
        getCreatorAds(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
              child: MyNetworkImage(
                height: 55,
                width: 57,
                imagePath: adItem?.image ?? '',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MyText(
                        text: adItem?.title ?? '',
                        color: white,
                        multilanguage: false,
                        fontsizeNormal: 15,
                        fontwaight: FontWeight.w600,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.5, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: adItem?.status == "Pending"
                              ? Colors.orange.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: MyText(
                          text: adItem!.status,
                          color: adItem.status == "Pending"
                              ? Colors.orange
                              : Colors.green,
                          multilanguage: false,
                          fontsizeNormal: 11.5,
                          fontwaight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      MyImage(width: 17, height: 17, imagePath: "ic_coin.png"),
                      const SizedBox(width: 5),
                      MyText(
                        text: adItem.budget.toString() ?? '',
                        color: white,
                        multilanguage: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: colorPrimaryDark,
                      content: MyText(
                        text: "surewanttodelete",
                        color: white,
                        fontsizeNormal: 16,
                      ),
                      actions: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: MyText(text: 'no', color: colorPrimary),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorPrimary,
                          ),
                          onPressed: () async {
                            Utils.showProgress(context);
                            SuccessModel deleteAd =
                                await ApiService().deleteCreatorAd(adItem.id);
                            Utils().hideProgress(context);
                            Navigator.pop(context);
                            Utils().showSnackBar(
                                context, deleteAd.message ?? '', false);
                            if (deleteAd.status == 200) {
                              getCreatorAds(context);
                            }
                          },
                          child: MyText(text: 'yes', color: Colors.white),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
