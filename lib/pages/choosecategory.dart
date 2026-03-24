import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fanbae/model/choosecategorymodel.dart';
import 'package:fanbae/model/packagechannelsmodel.dart';
import 'package:fanbae/pages/choosechannel.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/widget/mynetworkimg.dart';

import '../utils/constant.dart';
import '../utils/responsive_helper.dart';
import '../utils/utils.dart';
import '../webservice/apiservice.dart';
import '../widget/mytext.dart';

class ChooseCategory extends StatefulWidget {
  final int packageId;
  final String packageName;
  final String? packagePrice;

  const ChooseCategory(
      {super.key,
      required this.packageId,
      required this.packageName,
      this.packagePrice});

  @override
  State<ChooseCategory> createState() => _ChooseCategoryState();
}

class _ChooseCategoryState extends State<ChooseCategory> {
  bool isLoad = false;
  late ChooseCategoryModel categoryModel;
  List<int> selectCategories = [];

  @override
  void initState() {
    getCategories(context);
    super.initState();
  }

  Future<void> getCategories(BuildContext context) async {
    setState(() {
      isLoad = true;
    });
    categoryModel = await ApiService().getCategories(widget.packageId);
    if (categoryModel.status != 200) {
      Navigator.pop(context);
      Utils().showSnackBar(context, categoryModel.message, false);
    }
    setState(() {
      isLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          text: "choosecategory",
          color: white,
          fontsizeNormal: Dimens.textBig,
          fontwaight: FontWeight.bold,
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          if (selectCategories.isEmpty) {
            return Utils().showSnackBar(
                context, 'Please select at least one category.', false);
          }
          setState(() {
            isLoad = true;
          });
          PackageChannelsModel? package = await ApiService()
              .getPackageChannels(widget.packageId, selectCategories, context);

          setState(() => isLoad = false);

          if (package != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChooseChannel(
                  packageId: widget.packageId,
                  categoryId: selectCategories,
                  channel: package.result,
                  packageName: widget.packageName,
                  packagePrice: widget.packagePrice,
                ),
              ),
            );
          }
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
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              gradient: Constant.gradientColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: MyText(
                text: 'continue',
                color: pureBlack,
                fontwaight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: isLoad
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
              child: Utils().pageBg(
                context,
                child: GridView.builder(
                    itemCount: categoryModel.result.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            ResponsiveHelper.isDesktop(context) ? 6 : 3,
                        crossAxisSpacing: 11,
                        mainAxisSpacing: 13,
                        mainAxisExtent: 124),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            if (selectCategories
                                .contains(categoryModel.result[index].id)) {
                              setState(() {
                                selectCategories
                                    .remove(categoryModel.result[index].id);
                              });
                            } else {
                              setState(() {
                                selectCategories
                                    .add(categoryModel.result[index].id);
                              });
                            }
                          },
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                gradient: selectCategories.contains(
                                        categoryModel.result[index].id)
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                            const Color(0xFF2C0C53)
                                                .withOpacity(0.8),
                                            const Color(0xFF150F27)
                                                .withOpacity(0.8),
                                            const Color(0xffFE3379)
                                                .withOpacity(0.8),
                                          ])
                                    : null,
                                borderRadius: BorderRadius.circular(12)),
                            child: Container(
                              margin: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  color: Constant.darkMode == 'true'
                                      ? const Color(0xff4A4A4A).withOpacity(0.8)
                                      : const Color(0xff4A4A4A)
                                          .withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4.3),
                                          decoration: BoxDecoration(
                                              color: black.withOpacity(0.22),
                                              borderRadius:
                                                  BorderRadius.circular(25)),
                                          child: MyText(
                                            text: categoryModel
                                                .result[index].name,
                                            color: pureWhite,
                                            multilanguage: false,
                                            fontwaight: FontWeight.w500,
                                            fontsizeNormal: 11,
                                            overflow: TextOverflow.ellipsis,
                                            maxline: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  Container(
                                      height: 50,
                                      width: 50,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: MyNetworkImage(
                                          imagePath:
                                              categoryModel.result[index].image,
                                          fit: BoxFit.cover)),
                                ],
                              ),
                            ),
                          ));
                    }),
              ),
            ),
    );
  }
}
