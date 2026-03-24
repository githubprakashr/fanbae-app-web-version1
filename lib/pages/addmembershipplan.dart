import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fanbae/model/membership_plan_model.dart';
import 'package:fanbae/model/planfeaturesmodel.dart' as plan;
import 'package:fanbae/provider/membershipplanprovider.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/utils.dart';

class AddMembershipPlan extends StatefulWidget {
  final Result? membership;

  const AddMembershipPlan({super.key, this.membership});

  @override
  State<AddMembershipPlan> createState() => _AddMembershipPlanState();
}

class _AddMembershipPlanState extends State<AddMembershipPlan> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController offerPriceController = TextEditingController();
  final TextEditingController videoCountController = TextEditingController();
  final TextEditingController imageCountController = TextEditingController();
  final TextEditingController liveCountController = TextEditingController();
  final TextEditingController chatCountController = TextEditingController();
  String selectedPlanValue = 'none';
  String selectedPlanType = 'monthly';
  List<String> allPlanFeatures = [];
  List<Map<String, dynamic>> selectedFeatures = [
    {'type': 'video', 'count': 0}
  ];
  TextEditingController countController = TextEditingController();

  List<String> getRemainingFeatures() {
    List<String> selected =
        selectedFeatures.map((f) => f['type'] as String).toList();
    return allPlanFeatures.where((f) => !selected.contains(f)).toList();
  }

  bool isLoad = false;

  @override
  void initState() {
    if (widget.membership != null) {
      nameController.text = widget.membership!.name;
      priceController.text = widget.membership!.price.toString();
      offerPriceController.text = widget.membership!.offerPrice.toString();
      videoCountController.text =
          widget.membership!.planFeatures.video.toString();
      imageCountController.text =
          widget.membership!.planFeatures.image.toString();
      liveCountController.text =
          widget.membership!.planFeatures.liveStream.toString();
      chatCountController.text =
          widget.membership!.planFeatures.chat.toString();
      selectedPlanType = widget.membership!.planType;
      selectedPlanValue = widget.membership!.planValue;
      debugPrint(jsonEncode(widget.membership!.planFeatures));
      selectedFeatures = [
        if (widget.membership!.planFeatures.video > 0)
          {'type': 'video', 'count': widget.membership!.planFeatures.video},
        if (widget.membership!.planFeatures.image > 0)
          {'type': 'image', 'count': widget.membership!.planFeatures.image},
        if (widget.membership!.planFeatures.liveStream > 0)
          {
            'type': 'live_stream',
            'count': widget.membership!.planFeatures.liveStream
          },
        if (widget.membership!.planFeatures.chat > 0)
          {'type': 'chat', 'count': widget.membership!.planFeatures.chat},
        if (widget.membership!.planFeatures.video == 0 &&
            widget.membership!.planFeatures.image == 0 &&
            widget.membership!.planFeatures.liveStream == 0 &&
            widget.membership!.planFeatures.chat == 0)
          {'type': 'video', 'count': 0}
      ];
    }
    getPlanFeatures();

    super.initState();
  }

  getPlanFeatures() async {
    setState(() {
      isLoad = true;
    });
    plan.PlanFeaturesModel planFeatures = await ApiService().getPlanFeatures();
    if (planFeatures.status == 200) {
      for (var i in planFeatures.result) {
        allPlanFeatures.add(i.name);
      }

      print(allPlanFeatures);
    }
    setState(() {
      isLoad = false;
    });
  }

  Widget buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Utils().titleText("name"),
        Utils().myTextField(nameController, TextInputAction.next,
            TextInputType.text, 'Name', false),
        Utils().titleText("price"),
        Utils().myTextField(priceController, TextInputAction.next,
            TextInputType.number, 'Enter no of coins', false),
        Utils().titleText("offerprice"),
        Utils().myTextField(offerPriceController, TextInputAction.next,
            TextInputType.number, 'Enter no of coins', false),
        Utils().titleText("planvalue"),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: 'best_value',
                    groupValue: selectedPlanValue,
                    activeColor: colorPrimary,
                    onChanged: (value) {
                      setState(() {
                        selectedPlanValue = value!;
                      });
                    },
                  ),
                  MyText(
                    text: 'bestvalue',
                    color: white,
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Radio<String>(
                    value: 'most_popular',
                    groupValue: selectedPlanValue,
                    activeColor: colorPrimary,
                    onChanged: (value) {
                      setState(() {
                        selectedPlanValue = value!;
                      });
                    },
                  ),
                  MyText(
                    text: 'mostpopular',
                    color: white,
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Radio<String>(
                    value: 'none',
                    groupValue: selectedPlanValue,
                    activeColor: colorPrimary,
                    onChanged: (value) {
                      setState(() {
                        selectedPlanValue = value!;
                      });
                    },
                  ),
                  MyText(
                    text: 'None',
                    color: white,
                    multilanguage: false,
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              )
            ],
          ),
        ),
        Utils().titleText("plantype"),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Radio<String>(
                value: 'monthly',
                groupValue: selectedPlanType,
                activeColor: colorPrimary,
                onChanged: (value) {
                  setState(() {
                    selectedPlanType = value!;
                  });
                },
              ),
              MyText(
                text: 'monthly',
                color: white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPlanFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Utils().titleText("planfeatures"),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Row(
          children: [
            SizedBox(
              width: ResponsiveHelper.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.2
                  : MediaQuery.of(context).size.width * 0.40,
              child: MyText(
                text: 'type',
                color: white,
              ),
            ),
            SizedBox(
              width: ResponsiveHelper.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.01
                  : MediaQuery.of(context).size.width * 0.02,
            ),
            SizedBox(
              width: ResponsiveHelper.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.2
                  : MediaQuery.of(context).size.width * 0.40,
              child: MyText(
                text: 'coincount',
                color: white,
              ),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.015,
        ),
        ListView.separated(
          shrinkWrap: true,
          itemCount: selectedFeatures.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = selectedFeatures[index];
            return Row(
              key: ValueKey('row_${item['type']}'),
              children: [
                SizedBox(
                  width: ResponsiveHelper.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 0.2
                      : MediaQuery.of(context).size.width * 0.35,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('dd_${item['type']}'),
                    value: item['type'],
                    dropdownColor: colorPrimaryDark,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: white),
                    items: allPlanFeatures
                        .map((type) {
                          // Only show selected type or remaining ones
                          if (item['type'] == type ||
                              getRemainingFeatures().contains(type)) {
                            return DropdownMenuItem(
                              value: type,
                              child: MyText(text: type),
                            );
                          }
                          return null;
                        })
                        .whereType<DropdownMenuItem<String>>()
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedFeatures[index]['type'] = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: ResponsiveHelper.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 0.2
                      : MediaQuery.of(context).size.width * 0.35,
                  child: TextFormField(
                    key: ValueKey('count_${item['type']}'),
                    initialValue: item['count'].toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: white),
                    onChanged: (val) {
                      setState(() {
                        selectedFeatures[index]['count'] =
                            int.tryParse(val) ?? 0;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                      index == selectedFeatures.length - 1 &&
                              getRemainingFeatures().isNotEmpty
                          ? Icons.add_circle
                          : Icons.remove_circle,
                      color: (index == selectedFeatures.length - 1) &&
                              getRemainingFeatures().isNotEmpty
                          ? Colors.green
                          : Colors.red),
                  onPressed: () {
                    setState(() {
                      if (index == selectedFeatures.length - 1 &&
                          getRemainingFeatures().isNotEmpty) {
                        selectedFeatures.add(
                            {'type': getRemainingFeatures().first, 'count': 0});
                      } else {
                        final t = item['type'];
                        selectedFeatures.removeWhere((f) => f['type'] == t);
                      }
                    });
                  },
                ),
              ],
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              height: 12,
            );
          },
        ),
      ],
    );
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
            text: widget.membership != null
                ? "editmembershipplan"
                : "addmembershipplan",
            color: white),
      ),
      body: isLoad
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Utils().pageBg(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveHelper.isDesktop(context) ? 25 : 15.0,
                            vertical: 15),
                        child: ResponsiveHelper.isDesktop(context)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.41,
                                          child: buildContent())),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.07,
                                  ),
                                  Expanded(
                                      child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.41,
                                          child: buildPlanFeatures())),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildContent(),
                                  buildPlanFeatures(),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (nameController.text.isEmpty) {
                        return Utils()
                            .showSnackBar(context, "Name is required.", false);
                      }
                      if (priceController.text.isEmpty) {
                        return Utils()
                            .showSnackBar(context, "Price is required.", false);
                      }

                      if (offerPriceController.text.isEmpty) {
                        return Utils().showSnackBar(
                            context, "Offer Price is required.", false);
                      }
                      final double? price =
                          double.tryParse(priceController.text);
                      final double? offerPrice =
                          double.tryParse(offerPriceController.text);
                      if (offerPrice! >= price!) {
                        return Utils().showSnackBar(
                          context,
                          "Offer price must be less than the original price.",
                          false,
                        );
                      }
                      // Convert selectedFeatures into a map for easy lookup
                      final Map<String, int> featuresMap = {
                        for (var f in selectedFeatures)
                          f['type']: f['count'] ?? 0
                      };

                      // Extract values safely
                      final video = featuresMap['video'] ?? 0;
                      final image = featuresMap['image'] ?? 0;
                      final liveStream = featuresMap['liveStream'] ?? 0;
                      final chat = featuresMap['chat'] ?? 0;

                      // Validation: if ALL are zero
                      if (video == 0 &&
                          image == 0 &&
                          liveStream == 0 &&
                          chat == 0) {
                        return Utils().showSnackBar(
                          context,
                          "Please select at least one plan feature.",
                          false,
                        );
                      }

                      Utils.showProgress(context);

                      Map<String, dynamic> planFeatures = {
                        for (var feature in selectedFeatures)
                          if (feature['type'] != null &&
                              feature['count'] != null)
                            feature['type']: feature['count']
                      };

                      final membershipPlanProvider =
                          Provider.of<MembershipPlanProvider>(context,
                              listen: false);

                      await membershipPlanProvider.getMembershipPlan(
                          widget.membership?.id.toString(),
                          Constant.userID.toString(),
                          nameController.text,
                          int.parse(priceController.text),
                          int.parse(offerPriceController.text),
                          selectedPlanValue,
                          selectedPlanType,
                          planFeatures);

                      if (!mounted) return;
                      Utils().hideProgress(context);
                      if (mounted) {
                        Utils().showSnackBar(
                            context,
                            "${membershipPlanProvider.membershipPlanModel.message}",
                            false);
                      }
                      if (!membershipPlanProvider.loading) {
                        if (membershipPlanProvider.membershipPlanModel.status ==
                            200) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Container(
                      height: 48,
                      margin: EdgeInsets.only(
                          left: ResponsiveHelper.isDesktop(context)
                              ? MediaQuery.of(context).size.width * 0.35
                              : 15,
                          right: ResponsiveHelper.isDesktop(context)
                              ? MediaQuery.of(context).size.width * 0.35
                              : 15,
                          top: 15,
                          bottom: 15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(7)),
                          gradient: Constant.gradientColor),
                      child: MyText(
                          color: pureBlack,
                          text: "submit",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textMedium,
                          maxline: 1,
                          fontwaight: FontWeight.w700,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
