import 'package:fanbae/provider/profileprovider.dart';
import 'package:fanbae/provider/settingprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiveUserPanel extends StatefulWidget {
  const ActiveUserPanel({super.key});

  @override
  State<ActiveUserPanel> createState() => _ActiveUserPanelState();
}

class _ActiveUserPanelState extends State<ActiveUserPanel> {
  final passwordController = TextEditingController();
  late ProfileProvider profileProvider;
  SharedPre sharedPre = SharedPre();

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /* User Panel Active */
    if (Constant.userPanelStatus == "0" ||
        Constant.userPanelStatus == "" ||
        Constant.userPanelStatus == null) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: colorPrimaryDark,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20.0),
          constraints: const BoxConstraints(
            minWidth: 300,
            maxWidth: 400,
            minHeight: 280,
            maxHeight: 320,
          ),
          child: Consumer<SettingProvider>(
              builder: (context, settingprovider, child) {
            return Column(
              children: [
                MyText(
                    color: white,
                    text: "userpanel",
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textExtraBig,
                    fontsizeWeb: Dimens.textExtraBig,
                    multilanguage: true,
                    inter: false,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
                const SizedBox(height: 25),
                TextField(
                  cursorColor: white,
                  obscureText: settingprovider.isPasswordVisible,
                  controller: passwordController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  style: Utils.googleFontStyle(1, Dimens.textBig,
                      FontStyle.normal, white, FontWeight.w500),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        color: white,
                        settingprovider.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        settingprovider.passwordHideShow();
                      },
                    ),
                    hintText: "Give your User Panel Password",
                    hintStyle: Utils.googleFontStyle(1, Dimens.textBig,
                        FontStyle.normal, gray, FontWeight.w500),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: gray),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: gray),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    MyText(
                        color: white,
                        multilanguage: true,
                        text: "status",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textBig,
                        maxline: 1,
                        fontwaight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(width: 8),
                    MyText(
                        color: white,
                        multilanguage: false,
                        text: ":",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textBig,
                        maxline: 1,
                        fontwaight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(width: 20),
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        settingprovider.selectUserPanel("on", true);
                        printLog("type==>${settingprovider.isActiveType}");
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: settingprovider.isUserpanelType == "on" &&
                                    settingprovider.isActive == true
                                ? colorPrimary
                                : colorPrimaryDark,
                            shape: BoxShape.circle),
                        child: MyText(
                            color: white,
                            multilanguage: true,
                            text: "on",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textTitle,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ),
                    const SizedBox(width: 20),
                    InkWell(
                      onTap: () {
                        settingprovider.selectUserPanel("off", true);
                        printLog("type==>${settingprovider.isActiveType}");
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: settingprovider.isUserpanelType == "off" &&
                                    settingprovider.isActive == true
                                ? colorPrimary
                                : colorPrimaryDark,
                            shape: BoxShape.circle),
                        child: MyText(
                            color: white,
                            multilanguage: true,
                            text: "off",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textTitle,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      radius: 50,
                      autofocus: false,
                      onTap: () {
                        Navigator.pop(context);
                        settingprovider.clearUserPanel();
                        passwordController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        decoration: BoxDecoration(
                          color: colorPrimaryDark,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: colorPrimary.withOpacity(0.40),
                              blurRadius: 10.0,
                              spreadRadius: 0.5,
                            )
                          ],
                        ),
                        child: MyText(
                            color: white,
                            multilanguage: true,
                            text: "cancel",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textBig,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () async {
                          final profileProvider = Provider.of<ProfileProvider>(
                              context,
                              listen: false);

                          if (passwordController.text.isEmpty) {
                            Utils().showSnackBar(
                                context, "pleaseenteryourpassword", true);
                          } else if (passwordController.text.length < 6) {
                            Utils().showSnackBar(
                                context, "passwordmustbesixcharecter", true);
                          } else if (settingprovider.isUserpanelType == "off") {
                            Utils().showSnackBar(
                                context, "pleaseselectuserpanelstatus", true);
                          } else {
                            /* Userpanal Api */

                            await settingprovider.getActiveUserPanel(
                                passwordController.text,
                                settingprovider.isActiveType);

                            if (settingprovider.updateprofileModel.status ==
                                200) {
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              passwordController.clear();
                              Utils().showSnackBar(context,
                                  "userpanalactivesuccsessfully", true);
                              await profileProvider.getprofile(
                                  context, Constant.userID);
                              await sharedPre.save(
                                  "userpanelstatus",
                                  profileProvider.profileModel.result?[0]
                                          .userPenalStatus
                                          .toString() ??
                                      "");
                              Constant.userPanelStatus =
                                  await sharedPre.read("userpanelstatus");
                            } else {
                              if (!context.mounted) return;
                              Utils().showSnackBar(
                                  context,
                                  "${settingprovider.updateprofileModel.message}",
                                  false);
                            }
                            settingprovider.clearUserPanel();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorPrimary.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5,
                              )
                            ],
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "active",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      );
    } else {
      /* User Panel Edit  */
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: colorPrimaryDark,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20.0),
          constraints: const BoxConstraints(
            minWidth: 300,
            maxWidth: 400,
            minHeight: 200,
            maxHeight: 220,
          ),
          child: Consumer<SettingProvider>(
              builder: (context, settingprovider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MusicTitle(
                    color: white,
                    text: "changepassword",
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textlargeBig,
                    fontsizeWeb: Dimens.textlargeBig,
                    multilanguage: true,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
                const SizedBox(height: 25),
                TextField(
                  cursorColor: white,
                  obscureText: settingprovider.isPasswordVisible,
                  controller: passwordController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  style: Utils.googleFontStyle(1, Dimens.textBig,
                      FontStyle.normal, white, FontWeight.w500),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        color: white,
                        settingprovider.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        settingprovider.passwordHideShow();
                      },
                    ),
                    hintText: "Edit User Panel Password",
                    hintStyle: Utils.googleFontStyle(1, Dimens.textBig,
                        FontStyle.normal, gray, FontWeight.w500),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: gray),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: gray),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      radius: 50,
                      autofocus: false,
                      onTap: () {
                        Navigator.pop(context);
                        passwordController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        decoration: BoxDecoration(
                          color: colorPrimaryDark,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: colorPrimary.withOpacity(0.40),
                              blurRadius: 10.0,
                              spreadRadius: 0.5,
                            )
                          ],
                        ),
                        child: MyText(
                            color: white,
                            multilanguage: true,
                            text: "cancel",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textBig,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () async {
                          if (passwordController.text.isEmpty) {
                            Utils().showSnackBar(
                                context, "pleaseenteryourpassword", true);
                          } else if (passwordController.text.length < 6) {
                            Utils().showSnackBar(
                                context, "passwordmustbesixcharecter", true);
                          } else {
                            /* Userpanal Api */
                            await settingprovider.getActiveUserPanel(
                                passwordController.text, "1");
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            passwordController.clear();
                            Utils().showSnackBar(
                                context, "passwordchangesuccsessfully", true);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorPrimary.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5,
                              )
                            ],
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "edit",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      );
    }
  }
}
