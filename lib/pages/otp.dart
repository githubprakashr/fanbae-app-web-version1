import 'dart:developer';
import 'dart:math' as math;
import 'package:fanbae/utils/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fanbae/pages/bottombar.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../provider/generalprovider.dart';

class Otp extends StatefulWidget {
  final String fullnumber, countrycode, countryName, number;
  const Otp({
    super.key,
    required this.fullnumber,
    required this.countrycode,
    required this.countryName,
    required this.number,
  });

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  late GeneralProvider generalProvider;
  SharedPre sharedPre = SharedPre();
  final pinPutController = TextEditingController();
  String? strDeviceType, strDeviceToken;
  bool codeResended = false;
  bool isLoad = false;

  @override
  void initState() {
    super.initState();
    log('Mobile==> ${widget.fullnumber}');
    setState(() {
      isLoad = true;
    });
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      codeSend(false);
    });
    _getDeviceToken();
    setState(() {
      isLoad = false;
    });
  }

  String _generate16DigitDeviceId() {
    final rnd = math.Random.secure();
    const chars = '0123456789';
    return List.generate(16, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  String _digitsOnly(String input) => input.replaceAll(RegExp(r'\D'), '');

  String _localMobileFromAny(String anyNumber) {
    final digits = _digitsOnly(anyNumber);
    if (digits.length <= 10) return digits;
    return digits.substring(digits.length - 10);
  }

  String _findLocalMobileFromResult(dynamic result, {String fallback = ""}) {
    try {
      final candidates = <String?>[
        result?.mobileNumber?.toString(),
        result?.mobile?.toString(),
        result?.channelName?.toString(),
        result?.channelId?.toString(),
        result?.userName?.toString(),
        fallback,
        widget.fullnumber
      ];
      for (final c in candidates) {
        if (c == null) continue;
        final local = _localMobileFromAny(c);
        if (local.isNotEmpty) return local;
      }
    } catch (e) {
      printLog("_findLocalMobileFromResult error: $e");
    }
    return _localMobileFromAny(
        fallback.isNotEmpty ? fallback : widget.fullnumber);
  }

  _getDeviceToken() async {
    try {
      // For simplified/dev flow just generate id
      strDeviceToken = _generate16DigitDeviceId();
      strDeviceType = kIsWeb ? "" : "1";
      printLog("===>strDeviceToken $strDeviceToken");
    } catch (e) {
      printLog("_getDeviceToken Exception ===> $e");
    }
  }

  @override
  void dispose() {
    pinPutController.dispose();
    super.dispose();
  }

  codeSend(bool isResend) async {
    generalProvider.setLoading(true);
    log("================>>Code send (static OTP) <<<============");
    await Future.delayed(const Duration(milliseconds: 300));
    if (isResend) {
      Utils().showSnackBar(context, "coderesendsuccessfully", true);
    } else {
      Utils().showSnackBar(context, "codesendsuccessfully", true);
    }
    generalProvider.setLoading(false);
  }

  _checkOTPAndLogin() async {
    final entered = pinPutController.text.trim();
    if (entered.isEmpty) {
      Utils().showSnackBar(context, "pleaseenterotp", true);
      generalProvider.setLoading(false);
      return;
    }
    if (entered != "123456") {
      Utils().showSnackBar(context, "otpinvalid", true);
      generalProvider.setLoading(false);
      return;
    }

    // OTP valid -> proceed to login, derive local mobile
    final local = _localMobileFromAny(widget.fullnumber);
    _login(local, _generate16DigitDeviceId());
  }

  _login(String mobile, String generatedId) async {
    printLog("click on Submit mobile =====> $mobile");
    printLog("device id => $generatedId");

    final provider = Provider.of<GeneralProvider>(context, listen: false);
    provider.setLoading(true);

    // Send full number to backend but save cleaned mobile from server or derived value
    await provider.login("1", "", widget.fullnumber, strDeviceType ?? "",
        strDeviceToken ?? "", widget.countrycode, widget.countryName);

    if (!provider.loading) {
      if (!mounted) return;
      provider.setLoading(false);
      if (provider.loginModel.status == 200) {
        final serverMobile =
            provider.loginModel.result?[0].mobileNumber?.toString() ??
                widget.fullnumber;
        final savedMobile = _localMobileFromAny(serverMobile);

        Utils.saveUserCreds(
            userID: provider.loginModel.result?[0].id.toString(),
            channeId: provider.loginModel.result?[0].channelId.toString(),
            channelName: provider.loginModel.result?[0].channelName.toString(),
            fullName: provider.loginModel.result?[0].fullName.toString(),
            email: provider.loginModel.result?[0].email.toString(),
            mobileNumber: savedMobile,
            countrycode: provider.loginModel.result?[0].countryCode.toString(),
            countryname: provider.loginModel.result?[0].channelName.toString(),
            image: provider.loginModel.result?[0].image.toString(),
            coverImg: provider.loginModel.result?[0].coverImg.toString(),
            deviceType: provider.loginModel.result?[0].deviceType.toString(),
            deviceToken: provider.loginModel.result?[0].deviceToken.toString(),
            userIsBuy: provider.loginModel.result?[0].isBuy.toString(),
            isAdsFree: provider.loginModel.result?[0].adsFree.toString(),
            isDownload: provider.loginModel.result?[0].isDownload.toString(),
            isCreator: provider.loginModel.result?[0].isCreator.toString(),
            walletBalance:
                provider.loginModel.result?[0].walletBalance.toString());

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Bottombar()),
          (Route<dynamic> route) => false,
        );
      } else {
        provider.setLoading(false);
        Utils().showSnackBar(context, "Error", false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  // color: appbgcolorDark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.35,
                      alignment: Alignment.bottomCenter,
                      child: MyImage(
                          width: MediaQuery.of(context).size.width * 0.60,
                          height: MediaQuery.of(context).size.height * 0.25,
                          imagePath: "appicon.png"),
                    ),
                    MyText(
                        color: white,
                        text: "pleaseenteryourotp",
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textlargeBig,
                        multilanguage: true,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w800,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 5),
                    MyText(
                        color: white,
                        text: "we have sent an otp to your number",
                        textalign: TextAlign.center,
                        multilanguage: true,
                        fontsizeNormal: Dimens.textDesc,
                        inter: false,
                        maxline: 2,
                        fontwaight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 15),
                    MyText(
                        color: white,
                        text: widget.fullnumber.toString(),
                        textalign: TextAlign.center,
                        fontsizeNormal: 14,
                        inter: false,
                        multilanguage: false,
                        maxline: 2,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 55,
                      child: Pinput(
                        length: 6,
                        keyboardType: TextInputType.number,
                        controller: pinPutController,
                        textInputAction: TextInputAction.done,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        onCompleted: (value) {
                          if (pinPutController.text.toString().isEmpty) {
                            Utils()
                                .showSnackBar(context, "pleaseenterotp", true);
                          } else {
                            // Use the provider from the context to show loading state inside UI callbacks
                            final provider = Provider.of<GeneralProvider>(
                                context,
                                listen: false);
                            provider.setLoading(true);
                            _checkOTPAndLogin();
                          }
                        },
                        defaultPinTheme: PinTheme(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            border: Border.all(color: colorPrimary, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          textStyle: GoogleFonts.roboto(
                            color: white,
                            fontSize: Dimens.textBig,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        codeSend(true);
                      },
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 70),
                        padding: const EdgeInsets.all(5),
                        child: MyText(
                          color: white,
                          text: "resend",
                          multilanguage: true,
                          fontsizeNormal: Dimens.textTitle,
                          fontwaight: FontWeight.w600,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Consumer<GeneralProvider>(
                        builder: (context, provider, child) {
                      return InkWell(
                        onTap: () {
                          if (pinPutController.text.toString().isEmpty) {
                            Utils()
                                .showSnackBar(context, "pleaseenterotp", true);
                          } else {
                            provider.setLoading(true);
                            _checkOTPAndLogin();
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.06,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: provider.isProgressLoading
                              ? CircularProgressIndicator(
                                  color: white,
                                  strokeWidth: 0.8,
                                )
                              : MyText(
                                  color: colorAccent,
                                  text: "login",
                                  multilanguage: true,
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textTitle,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context, false);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Utils.backIcon(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
