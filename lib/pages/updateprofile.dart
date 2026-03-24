// ignore_for_file: deprecated_member_use
import 'dart:developer';
import 'dart:io';
import 'package:fanbae/provider/profileprovider.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:fanbae/provider/updateprofileprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  final String channelid;

  const UpdateProfile({super.key, required this.channelid});

  @override
  State<UpdateProfile> createState() => UpdateProfileState();
}

class UpdateProfileState extends State<UpdateProfile> {
  final ImagePicker picker = ImagePicker();
  SharedPre sharedPre = SharedPre();
  late UpdateprofileProvider updateprofileProvider;
  late ProfileProvider profileProvider;
  String userid = "", name = "", countrycode = "", countryname = "";
  String gendarvalue = 'Male';
  XFile? _image;
  XFile? _coverImage;
  bool iseditimg = false;
  bool iseditcoverImg = false;
  final nameController = TextEditingController();
  final channelNameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  final descriptionController = TextEditingController();
  final liveAmtController = TextEditingController();
  final chatAmtController = TextEditingController();
  final audioCallAmtController = TextEditingController();
  final videoCallAmtController = TextEditingController();
  String mobileNumber = '';

  @override
  void initState() {
    updateprofileProvider =
        Provider.of<UpdateprofileProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    super.initState();
    getApi();
  }

  getApi() async {
    await profileProvider.getprofile(context, Constant.userID);
    print(profileProvider.profileModel.result?[0].mobileNumber.toString());
    print(profileProvider.profileModel.result?[0].mobileNumber.toString());
    print(profileProvider.profileModel.result?[0].mobileNumber.toString());
    nameController.text =
        profileProvider.profileModel.result?[0].fullName.toString() ?? "";
    emailController.text =
        profileProvider.profileModel.result?[0].email.toString() ?? "";
    numberController.text =
        profileProvider.profileModel.result?[0].mobileNumber.toString() ?? "";
    descriptionController.text =
        profileProvider.profileModel.result?[0].description.toString() ?? "";
    channelNameController.text =
        profileProvider.profileModel.result?[0].channelName.toString() ?? "";
    liveAmtController.text =
        profileProvider.profileModel.result?[0].liveAmount.toString() ?? "";
    chatAmtController.text =
        profileProvider.profileModel.result?[0].chatAmount.toString() ?? "";
    audioCallAmtController.text =
        profileProvider.profileModel.result?[0].audioCallAmount.toString() ??
            "";
    videoCallAmtController.text =
        profileProvider.profileModel.result?[0].videoCallAmount.toString() ??
            "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      body: SingleChildScrollView(
        //    scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Consumer<UpdateprofileProvider>(
            builder: (context, updateprofileProvider, child) {
          return Consumer<ProfileProvider>(
              builder: (context, profileprovider, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: ResponsiveHelper.isWeb(context)
                            ? MediaQuery.of(context).size.height * 0.45
                            : MediaQuery.of(context).size.height * 0.40,
                        child: MyImage(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.15,
                          imagePath: 'profilebg.png',
                          fit: BoxFit.cover,
                        )),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 1.3,
                    )
                  ],
                ),
                // /* Bottom Black Overlay */
                // Positioned.fill(
                //   child: Container(
                //     decoration: BoxDecoration(
                //       color: appbgcolor.withOpacity(0.5),
                //     ),
                //   ),
                // ),
                Positioned.fill(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height * 0.135,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        color: appbgcolor,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Utils().pageBg(
                      context,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(15,
                            MediaQuery.of(context).size.height * 0.075, 15, 0),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Utils().titleText("name"),
                            Utils().myTextField(
                                nameController,
                                TextInputAction.next,
                                TextInputType.text,
                                Constant.fullname,
                                false),
                            Utils().titleText("channelname"),
                            Utils().myTextField(
                                channelNameController,
                                TextInputAction.next,
                                TextInputType.text,
                                Constant.channelname,
                                false),
                            Utils().titleText("description"),
                            Utils().myTextField(
                                descriptionController,
                                TextInputAction.next,
                                TextInputType.text,
                                Constant.channelname,
                                false),
                            Utils().titleText("email"),
                            Utils().myTextField(
                                emailController,
                                TextInputAction.next,
                                TextInputType.text,
                                Constant.email,
                                emailController.text.isNotEmpty ? true : false),
                            Utils().titleText("mobile"),
                            IntlPhoneField(
                              disableLengthCheck: true,
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: white,
                              autovalidateMode: AutovalidateMode.disabled,
                              controller: numberController,
                              style: Utils.googleFontStyle(4, Dimens.textTitle,
                                  FontStyle.normal, white, FontWeight.w500),
                              showCountryFlag: true,
                              showDropdownIcon: false,
                              initialCountryCode: Constant.initialCountryCode,
                              dropdownTextStyle: Utils.googleFontStyle(
                                  4,
                                  Dimens.textTitle,
                                  FontStyle.normal,
                                  white,
                                  FontWeight.w500),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: buttonDisable,
                                hintText: Constant.mobile,
                                hintStyle: GoogleFonts.montserrat(
                                    fontSize: 12.5,
                                    fontStyle: FontStyle.normal,
                                    color: white,
                                    fontWeight: FontWeight.w500),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 11, horizontal: 11),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  borderSide: BorderSide(color: transparent),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  borderSide: BorderSide(color: transparent),
                                ),
                              ),
                              onChanged: (phone) {
                                mobileNumber = phone.completeNumber;
                                countryname = phone.countryISOCode;
                                countrycode = phone.countryCode;
                                log("numberController==> ${numberController.text}");
                                log('mobile number==> $mobileNumber');
                                log('countryCode number==> $countryname');
                                log('countryISOCode==> $countrycode');
                              },
                              onCountryChanged: (country) {
                                countryname = country.code.replaceAll('+', '');
                                countrycode = "+${country.dialCode.toString()}";
                                log('countryname===> $countryname');
                                log('countrycode===> $countrycode');
                              },
                            ),
                            /* Utils().myTextField(
                                numberController,
                                TextInputAction.next,
                                const TextInputType.numberWithOptions(
                                    signed: false, decimal: true),
                                Constant.mobile,
                                numberController.text.isNotEmpty
                                    ? true
                                    : false),*/
                            if (Constant.isCreator == "1") ...[
                              Utils().titleText("liveprice"),
                              Utils().myTextField(
                                  liveAmtController,
                                  TextInputAction.next,
                                  TextInputType.number,
                                  "Coins per Live Stream",
                                  false),
                              Utils().titleText("chatprice"),
                              Utils().myTextField(
                                  chatAmtController,
                                  TextInputAction.next,
                                  TextInputType.number,
                                  "Coins per chat",
                                  false),
                              Utils().titleText("audiocallprice"),
                              Utils().myTextField(
                                  audioCallAmtController,
                                  TextInputAction.next,
                                  TextInputType.number,
                                  "Coins per Audio Call",
                                  false),
                              Utils().titleText("videocallprice"),
                              Utils().myTextField(
                                  videoCallAmtController,
                                  TextInputAction.next,
                                  TextInputType.number,
                                  "Coins per Video Call",
                                  false),
                            ],
                            const SizedBox(height: 40),
                            InkWell(
                              onTap: () async {
                                await updateProfileApi();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(7)),
                                    gradient: Constant.gradientColor),
                                child: MyText(
                                    color: pureBlack,
                                    text: "submit",
                                    multilanguage: true,
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textMedium,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                /* Back Button With Change CoverImage */
                Positioned.fill(
                  left: 15,
                  right: 15,
                  top: 8,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    child: const Icon(Icons.arrow_back),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                MyText(
                                    color: black,
                                    text: "editprofile",
                                    multilanguage: true,
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textBig,
                                    maxline: 1,
                                    fontwaight: FontWeight.w700,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ),
                          // InkWell(
                          //   onTap: () async {
                          //     try {
                          //       var coverImage = await picker.pickImage(
                          //           source: ImageSource.gallery,
                          //           imageQuality: 100);
                          //       setState(() {
                          //         _coverImage = coverImage;
                          //         iseditcoverImg = true;
                          //       });
                          //     } catch (e) {
                          //       printLog("Error ==>${e.toString()}");
                          //     }
                          //   },
                          //   child: Container(
                          //     padding: EdgeInsets.all(8),
                          //     decoration: BoxDecoration(
                          //       color: black.withOpacity(0.3),
                          //       shape: BoxShape.circle
                          //     ),
                          //     child: MyImage(
                          //         width: 22,
                          //         height: 22,
                          //         imagePath: "ic_camera.png"),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),

                /* Profile Image  */

                Positioned.fill(
                  top: MediaQuery.of(context).size.height * 0.06,
                  child: SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 95, // Outer size
                            height: 95,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: Constant.sweepGradient,
                            ),
                          ),
                          Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: _image == null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: MyNetworkImage(
                                        imagePath: profileProvider
                                                .profileModel.result?[0].image
                                                .toString() ??
                                            "",
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.file(
                                        height: 151,
                                        width: 151,
                                        File(_image?.path ?? ""),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: InkWell(
                                onTap: () async {
                                  try {
                                    var image = await picker.pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 100);
                                    setState(() {
                                      _image = image;
                                      iseditimg = true;
                                    });
                                  } catch (e) {
                                    printLog("Error ==>${e.toString()}");
                                  }
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: white,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          });
        }),
      ),
    );
  }

  // Widget myTextField(
  //     controller, textInputAction, keyboardType, labletext, isMobile) {
  //   log("code==> ${updateprofileProvider.profileModel.result?[0].countryName.toString() ?? ""}");
  //   return SizedBox(
  //     height: 55,
  //     child: isMobile == false
  //         ? TextFormField(
  //             textAlign: TextAlign.left,
  //             obscureText: false,
  //             keyboardType: keyboardType,
  //             controller: controller,
  //             textInputAction: textInputAction,
  //             cursorColor: white,
  //             style: GoogleFonts.montserrat(
  //                 fontSize: 14,
  //                 fontStyle: FontStyle.normal,
  //                 color: white,
  //                 fontWeight: FontWeight.w500),
  //             decoration: InputDecoration(
  //               labelText: labletext,
  //               labelStyle: GoogleFonts.montserrat(
  //                   fontSize: 14,
  //                   fontStyle: FontStyle.normal,
  //                   color: colorPrimary,
  //                   fontWeight: FontWeight.w500),
  //               contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
  //               enabledBorder: const OutlineInputBorder(
  //                 borderRadius: BorderRadius.all(Radius.circular(8.0)),
  //                 borderSide: BorderSide(color: white, width: 1.5),
  //               ),
  //               focusedBorder: const OutlineInputBorder(
  //                 borderRadius: BorderRadius.all(Radius.circular(8.0)),
  //                 borderSide: BorderSide(color: white, width: 1.5),
  //               ),
  //             ),
  //           )
  //         : IntlPhoneField(
  //             disableLengthCheck: true,
  //             textAlignVertical: TextAlignVertical.center,
  //             autovalidateMode: AutovalidateMode.disabled,
  //             controller: controller,
  //             inputFormatters: [
  //               FilteringTextInputFormatter.digitsOnly,
  //             ],
  //             style: Utils.googleFontStyle(
  //                 4, 16, FontStyle.normal, white, FontWeight.w500),
  //             showCountryFlag: true,
  //             showDropdownIcon: false,
  //             initialCountryCode: updateprofileProvider
  //                             .profileModel.result?[0].countryName ==
  //                         "" ||
  //                     updateprofileProvider
  //                             .profileModel.result?[0].countryName ==
  //                         null
  //                 ? Constant.initialCountryCode
  //                 : updateprofileProvider.profileModel.result?[0].countryName
  //                         .toString() ??
  //                     Constant.initialCountryCode,
  //             dropdownTextStyle: Utils.googleFontStyle(
  //                 4, 16, FontStyle.normal, white, FontWeight.w500),
  //             keyboardType: keyboardType,
  //             textInputAction: textInputAction,
  //             decoration: InputDecoration(
  //               labelText: labletext,
  //               fillColor: transparent,
  //               border: InputBorder.none,
  //               labelStyle: Utils.googleFontStyle(
  //                   4, 14, FontStyle.normal, colorPrimary, FontWeight.w500),
  //               enabledBorder: const OutlineInputBorder(
  //                 borderRadius: BorderRadius.all(Radius.circular(10)),
  //                 borderSide: BorderSide(color: white, width: 1),
  //               ),
  //               focusedBorder: const OutlineInputBorder(
  //                 borderRadius: BorderRadius.all(Radius.circular(10)),
  //                 borderSide: BorderSide(color: white, width: 1),
  //               ),
  //             ),
  //             onChanged: (phone) {
  //               mobilenumber = phone.number;
  //               countryname = phone.countryISOCode;
  //               countrycode = phone.countryCode;
  //               log('mobile number==> $mobilenumber');
  //               log('countryCode number==> $countryname');
  //               log('countryISOCode==> $countrycode');
  //             },
  //             onCountryChanged: (country) {
  //               countryname = country.code.replaceAll('+', '');
  //               countrycode = "+${country.dialCode.toString()}";
  //               log('countryname===> $countryname');
  //               log('countrycode===> $countrycode');
  //             },
  //           ),
  //   );
  // }

  updateProfileApi() async {
    dynamic image;
    dynamic coverImage;
    String fullname = nameController.text.toString();
    String channelName = channelNameController.text.toString();
    String description = descriptionController.text.toString();
    String email = emailController.text.toString();
    String number = numberController.text.toString();
    int liveAmount = int.parse(liveAmtController.text.toString());
    int chatAmount = int.parse(chatAmtController.text.toString());
    int audioCallAmount = int.parse(audioCallAmtController.text.toString());
    int videoCallAmount = int.parse(videoCallAmtController.text.toString());

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isNotEmpty) {
      if (!emailRegex.hasMatch(email)) {
        return Utils().showSnackBar(context, "Enter a valid Email", false);
      }
    }

    if (iseditimg) {
      image = File(_image?.path ?? "");
    } else {
      image = File("");
    }

    if (iseditcoverImg) {
      coverImage = File(_coverImage?.path ?? "");
    } else {
      coverImage = File("");
    }

    final updateprofileProvider =
        Provider.of<UpdateprofileProvider>(context, listen: false);
    Utils.showProgress(context);

    await updateprofileProvider.getupdateprofile(
        Constant.userID.toString(),
        fullname,
        channelName,
        email,
        description,
        number,
        countrycode,
        countryname,
        image,
        coverImage,
        liveAmount,
        chatAmount,
        audioCallAmount,
        videoCallAmount);
    if (!mounted) return;
    Utils().hideProgress(context);

    if (!updateprofileProvider.loading) {
      if (updateprofileProvider.updateprofileModel.status == 200) {
        if (!mounted) return;
        Utils().showSnackBar(context,
            "${updateprofileProvider.updateprofileModel.message}", false);

        getApi();
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        Utils().showSnackBar(context,
            "${updateprofileProvider.updateprofileModel.message}", false);
      }
    }
  }
}
