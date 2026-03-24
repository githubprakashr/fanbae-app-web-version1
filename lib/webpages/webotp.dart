import 'package:fanbae/pages/feeds.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:async';
import 'dart:math' as math;
import 'package:fanbae/utils/dimens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/bottombar.dart';
import '../provider/generalprovider.dart';
import '../utils/responsive_helper.dart';

class WebOTP extends StatefulWidget {
  final String fullnumber, countrycode, countryName, number;
  final String? email;
  final String? loginType; // "1" for phone, "2" for email

  const WebOTP({
    super.key,
    required this.fullnumber,
    required this.countrycode,
    required this.countryName,
    required this.number,
    this.email,
    this.loginType,
  });

  @override
  State<WebOTP> createState() => _WebOTPState();
}

class _WebOTPState extends State<WebOTP> {
  late GeneralProvider generalProvider;
  SharedPre sharedPre = SharedPre();
  final pinPutController = TextEditingController();
  String? strDeviceType, strDeviceToken;
  bool codeResended = false;

  // OTP Timer
  Timer? _resendTimer;
  int _resendCountdown = 60; // 60 seconds
  bool _canResend = false;
  int _resendAttempts = 0;
  static const int maxResendAttempts = 3;

  @override
  void initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _getDeviceToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOTP(isResend: false);
    });
  }

  String _generate16DigitDeviceId() {
    final rnd = math.Random.secure();
    const length = 16;
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(rnd.nextInt(10));
    }
    return buffer.toString();
  }

  _getDeviceToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Try to get existing device token
      strDeviceToken = prefs.getString('device_token');

      // If no token exists, generate and save one
      // ✅ BEST PRACTICE
      if (strDeviceToken?.isEmpty ?? true) {
        strDeviceToken = _generate16DigitDeviceId();
        await prefs.setString('device_token', strDeviceToken!);
        printLog("Generated new device token: $strDeviceToken");
      } else {
        printLog("Using existing device token: $strDeviceToken");
      }

      if (kIsWeb) {
        strDeviceType = "3";
      } else {
        if (Theme.of(context).platform == TargetPlatform.android) {
          strDeviceType = "1";
        } else if (Theme.of(context).platform == TargetPlatform.iOS) {
          strDeviceType = "2";
        } else {
          strDeviceType = "0";
        }
      }
    } catch (e) {
      printLog("_getDeviceToken Exception ===> $e");
      strDeviceToken = _generate16DigitDeviceId();
    }
    printLog("===>deviceType $strDeviceType");
    printLog("===>deviceToken $strDeviceToken");
  }

  /// Start resend countdown timer
  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorPrimary.withOpacity(0.005),
                  appbgcolor,
                  appbgcolor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyImage(
                    imagePath: "appicon.png",
                    width: 200,
                    height: 200,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(height: 20),
                  MyText(
                      color: white,
                      text: "pleaseenteryourotp",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textBig,
                      fontsizeWeb: Dimens.textBig,
                      multilanguage: true,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 10),
                  MyText(
                      color: white,
                      text: "we have sent an otp to your number",
                      textalign: TextAlign.center,
                      multilanguage: true,
                      fontsizeNormal: Dimens.textDesc,
                      fontsizeWeb: Dimens.textDesc,
                      inter: false,
                      maxline: 2,
                      fontwaight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 10),
                  MyText(
                      color: colorPrimary,
                      text: widget.fullnumber.toString(),
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textMedium,
                      fontsizeWeb: Dimens.textMedium,
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
                      onCompleted: (value) {
                        _validateAndLogin();
                      },
                      textInputAction: TextInputAction.done,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      defaultPinTheme: PinTheme(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          border: Border.all(color: colorPrimary, width: 0.5),
                          color: colorPrimaryDark,
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
                  const SizedBox(height: 30),
                  // Resend OTP Section
                  _buildResendSection(),
                  const SizedBox(height: 30),
                  InkWell(
                    onTap: _validateAndLogin,
                    child: Container(
                      width: kIsWeb && MediaQuery.of(context).size.width > 1200
                          ? MediaQuery.of(context).size.width * 0.35
                          : kIsWeb && MediaQuery.of(context).size.width > 800
                              ? MediaQuery.of(context).size.width * 0.50
                              : MediaQuery.of(context).size.width * 0.75,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: Constant.gradientColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: MyText(
                          color: pureBlack,
                          fontsizeWeb: 16,
                          text: "login",
                          fontsizeNormal: 16,
                          fontwaight: FontWeight.w500,
                          maxline: 1,
                          multilanguage: true,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Consumer<GeneralProvider>(
                      builder: (context, provider, child) {
                    if (provider.isProgressLoading) {
                      return const CircularProgressIndicator(
                        color: colorPrimary,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Utils.buildBackBtn(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Build resend section with countdown timer
  Widget _buildResendSection() {
    if (_canResend) {
      return InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (_resendAttempts >= maxResendAttempts) {
            Utils()
                .showSnackBar(context, "Maximum resend attempts reached", true);
            return;
          }
          _sendOTP(isResend: true);
        },
        child: Container(
          constraints: const BoxConstraints(minWidth: 70),
          padding: const EdgeInsets.all(5),
          child: MyText(
            color: colorPrimary,
            text: _resendAttempts >= maxResendAttempts
                ? "maxresendsreached"
                : "resend",
            multilanguage: true,
            fontsizeNormal: Dimens.textTitle,
            fontsizeWeb: Dimens.textTitle,
            fontwaight: FontWeight.w700,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
        ),
      );
    } else {
      return MyText(
        color: gray,
        text: "Resend OTP in $_resendCountdown seconds",
        multilanguage: false,
        fontsizeNormal: Dimens.textDesc,
        fontsizeWeb: Dimens.textDesc,
        fontwaight: FontWeight.w400,
        maxline: 1,
        overflow: TextOverflow.ellipsis,
        textalign: TextAlign.center,
        fontstyle: FontStyle.normal,
      );
    }
  }

  /// Send OTP (Real API call for future implementation)
  Future<void> _sendOTP({required bool isResend}) async {
    if (isResend) {
      _resendAttempts++;
      printLog("Resend attempt:  $_resendAttempts/$maxResendAttempts");
    }

    generalProvider.setLoading(true);

    try {
      // TODO: Replace with real API call
      // Example:
      // await generalProvider.sendOTP(
      //   widget.number,
      //   widget.countrycode,
      //   widget.countryName
      // );

      // Simulated API call (REMOVE IN PRODUCTION)
      await Future.delayed(const Duration(seconds: 1));

      printLog(
          "================>>OTP Sent to ${widget.fullnumber}<<<============");

      if (!mounted) return;

      Utils().showSnackBar(context,
          isResend ? "coderesendsuccessfully" : "otpsentsuccessfully", true);

      // Start countdown timer
      _startResendTimer();
    } catch (e) {
      printLog("Error sending OTP: $e");
      if (!mounted) return;
      Utils().showSnackBar(context, "Failed to send OTP", true);
    } finally {
      if (mounted) {
        generalProvider.setLoading(false);
      }
    }
  }

  /// Validate OTP and login
  void _validateAndLogin() {
    if (pinPutController.text.toString().isEmpty) {
      Utils().showSnackBar(context, "pleaseenterotp", true);
      return;
    }

    if (pinPutController.text.trim().length != 6) {
      Utils().showSnackBar(context, "pleaseentervalidotp", true);
      return;
    }

    // TODO: For production, remove this hardcoded check
    // and implement proper backend OTP verification
    // The backend should verify the OTP, not the client

    // TEMPORARY:  Hardcoded OTP for development (REMOVE IN PRODUCTION)
    if (pinPutController.text.trim() == "123456") {
      generalProvider.setLoading(true);
      _login(widget.number.toString(), strDeviceToken ?? "");
    } else {
      Utils().showSnackBar(context, "otpinvalid", true);
    }

    /* 
    // PRODUCTION CODE (Use this in production):
    generalProvider.setLoading(true);
    _verifyOTPAndLogin(
      widget.number.toString(), 
      pinPutController.text.trim(),
      strDeviceToken ?? ""
    );
    */
  }

  /// Login after OTP verification
  _login(String mobile, String deviceId) async {
    printLog("click on Submit mobile =====> $mobile");
    printLog("click on Submit deviceId => $deviceId");
    final provider = Provider.of<GeneralProvider>(context, listen: false);
    provider.setLoading(true);

    try {
      // Determine login type: "2" for email, "1" for phone
      final loginType = widget.loginType ?? "1";
      final emailParam = widget.email ?? "";
      final mobileParam = loginType == "2" ? "" : mobile;

      printLog("📱 Login Type: $loginType");
      printLog("📧 Email: $emailParam");
      printLog("📞 Mobile: $mobileParam");

      await provider.login(
        loginType,
        emailParam,
        mobileParam,
        strDeviceType ?? "",
        strDeviceToken ?? "",
        widget.countrycode,
        widget.countryName,
      );

      if (!provider.loading) {
        provider.setLoading(false);
        if (provider.loginModel.status == 200) {
          /* Save Users Credentials */
          Utils.saveUserCreds(
              userID: provider.loginModel.result?[0].id.toString(),
              channeId: provider.loginModel.result?[0].channelId.toString(),
              channelName:
                  provider.loginModel.result?[0].channelName.toString(),
              fullName: provider.loginModel.result?[0].fullName.toString(),
              email: provider.loginModel.result?[0].email.toString(),
              mobileNumber:
                  provider.loginModel.result?[0].mobileNumber.toString(),
              countrycode:
                  provider.loginModel.result?[0].countryCode.toString(),
              countryname:
                  provider.loginModel.result?[0].channelName.toString(),
              image: provider.loginModel.result?[0].image.toString(),
              coverImg: provider.loginModel.result?[0].coverImg.toString(),
              deviceType: provider.loginModel.result?[0].deviceType.toString(),
              deviceToken:
                  provider.loginModel.result?[0].deviceToken.toString(),
              userIsBuy: provider.loginModel.result?[0].isBuy.toString(),
              isAdsFree: provider.loginModel.result?[0].adsFree.toString(),
              isCreator: provider.loginModel.result?[0].isCreator.toString(),
              walletBalance:
                  provider.loginModel.result?[0].walletBalance.toString(),
              isDownload: provider.loginModel.result?[0].isDownload.toString());

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => ResponsiveHelper.checkIsWeb(context)
                    ? const Feeds()
                    : const Bottombar()),
            (Route<dynamic> route) => false,
          );
        } else {
          if (!mounted) return;
          provider.setLoading(false);
          Utils().showSnackBar(
              context, provider.loginModel.message ?? "Login failed", true);
        }
      }
    } catch (e) {
      printLog("Login error: $e");
      provider.setLoading(false);
      if (!mounted) return;
      Utils()
          .showSnackBar(context, "An error occurred. Please try again.", true);
    }
  }

  /* 
  // FUTURE IMPLEMENTATION:  Backend OTP verification
  Future<void> _verifyOTPAndLogin(String mobile, String otp, String deviceId) async {
    final provider = Provider.of<GeneralProvider>(context, listen: false);
    
    try {
      // Call backend to verify OTP
      await provider. verifyOTP(
        mobile:  mobile,
        otp: otp,
        countryCode: widget.countrycode,
        countryName: widget.countryName,
        deviceType: strDeviceType ?? "",
        deviceToken: deviceId,
      );

      if (!provider.loading) {
        if (provider.otpVerificationModel.status == 200) {
          // OTP verified successfully, proceed to login
          await _login(mobile, deviceId);
        } else {
          provider.setLoading(false);
          if (!mounted) return;
          Utils().showSnackBar(
            context, 
            provider.otpVerificationModel.message ?? "Invalid OTP", 
            true
          );
        }
      }
    } catch (e) {
      printLog("OTP verification error: $e");
      provider.setLoading(false);
      if (!mounted) return;
      Utils().showSnackBar(context, "Failed to verify OTP", true);
    }
  }
  */

  @override
  void dispose() {
    _resendTimer?.cancel();
    pinPutController.dispose();
    super.dispose();
  }
}
