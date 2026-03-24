import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:fanbae/pages/otp.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/pages/bottombar.dart';
import 'package:fanbae/provider/generalprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:email_validator/email_validator.dart';
import '../webservice/socketmanager.dart';
import '../utils/firebase_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late GeneralProvider generalProvider;
  SharedPre sharedPre = SharedPre();
  final numberController = TextEditingController();
  final emailController = TextEditingController();
  String mobilenumber = "", countrycode = "", countryname = "";
  String userEmail = "";
  bool isagreeCondition = false;
  bool isAgreeTerms = false;
  bool isAgree18Plus = false;
  String? strDeviceType, strDeviceToken;
  final pinPutController = TextEditingController();
  bool codeResended = false;
  bool isOTP = false;
  bool isLoad = false;
  bool isEmailLogin = false; // Track if login is via email or phone
  final SocketManager socketManager = SocketManager();

  // ✅ Google Sign-In instance (no scopes = no People API needed)
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ✅ Magic SDK instance
  late Magic magic;

  @override
  void initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _getDeviceToken();
    _initMagicSDK();
  }

  /// Initialize Magic SDK
  void _initMagicSDK() {
    try {
      // TODO: Replace with your actual Magic Labs Publishable API Key
      // Get your API key from https://dashboard.magic.link/
      magic = Magic("pk_live_8E2F3F0BBA90BD08");
      printLog("Magic SDK initialized successfully");
    } catch (e) {
      printLog("Error initializing Magic SDK: $e");
    }
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

  Future<void> _openTermsAndConditions() async {
    // Extract base URL from Constant.baseurl (removes only '/api')
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/terms-and-conditions');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils()
            .showSnackBar(context, "Could not open terms and conditions", true);
      }
    }
  }

  Future<void> _openPrivacyPolicy() async {
    // Extract base URL from Constant.baseurl (removes only '/api')
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/privacy-policy');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(context, "Could not open privacy policy", true);
      }
    }
  }

  Future<void> _openFanbaePassAgreement() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/fanbae-agreement');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(context, "Could not open Fanbae agreement", true);
      }
    }
  }

  Future<void> _openContractBetweenFanbaeAndCreator() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/contract');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(context, "Could not open contract document", true);
      }
    }
  }

  Future<void> _openChildSafetyAndCSAM() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/child-safety-csam');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils()
            .showSnackBar(context, "Could not open child safety notice", true);
      }
    }
  }

  Future<void> _open18USC() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/18-usc');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(context, "Could not open 18 USC page", true);
      }
    }
  }

  _getDeviceToken() async {
    try {
      // Get actual FCM token from Pusher Beams
      final fcmToken = await FirebaseService.getDeviceToken();
      strDeviceToken = fcmToken ?? _generate16DigitDeviceId();
      strDeviceType = Platform.isAndroid ? "1" : "2";
      printLog(
          "📱 Pusher Beams token: ${fcmToken ?? 'Not available, using generated ID'}");
    } catch (e) {
      printLog("_getDeviceToken Exception ===> $e");
      strDeviceToken = _generate16DigitDeviceId();
    }
    printLog("===>strDeviceToken $strDeviceToken");
    printLog("===>strDeviceType $strDeviceType");
  }

  codeSend(bool isResend) async {
    generalProvider.setLoading(true);
    log("================>>Code send (static OTP) <<<============");
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        isOTP = true;
      });
    }
    if (isResend) {
      Utils().showSnackBar(context, "coderesendsuccessfully", true);
    } else {
      Utils().showSnackBar(context, "codesendsuccessfully", true);
    }
    generalProvider.setLoading(false);
  }

  /// Email Login with Magic SDK - Complete flow
  Future<void> emailLoginWithMagic() async {
    generalProvider.setLoading(true);
    try {
      log("================>>Email Login via Magic SDK <<<============");
      log("Email: $userEmail");

      // Magic SDK handles the complete OTP flow (send + verify)
      log("Calling magic.auth.loginWithEmailOTP...");
      var result = await magic.auth.loginWithEmailOTP(email: userEmail);
      log("✅ Magic SDK authentication complete! Result: $result");

      // Get the DID token after successful authentication
      var token = await magic.user.getIdToken();
      log("✅ Got DID token: $token");

      // Login directly with email (type = "5" for email)
      if (mounted) {
        _login("", userEmail, userEmail.split('@')[0], "", "5");
      }
    } catch (e, stackTrace) {
      printLog("❌ Error in Magic email login: $e");
      printLog("Stack trace: $stackTrace");
      generalProvider.setLoading(false);
      if (mounted) {
        Utils().showSnackBar(context, "Login failed: ${e.toString()}", true);
      }
    }
  }

  _checkOTPAndLogin() async {
    final entered = pinPutController.text.trim();
    if (entered.isEmpty) {
      Utils().showSnackBar(context, "pleaseenterotp", true);
      generalProvider.setLoading(false);
      return;
    }

    if (isEmailLogin) {
      // Email OTP verification via Magic SDK
      try {
        // Magic SDK automatically verifies the OTP
        // Get the DID token after successful verification
        var token = await magic.user.getIdToken();
        printLog("✅ Email OTP verified successfully! Token: $token");

        // Login with email (type = "5" for email otp with Magic SDK)
        _login("", userEmail, userEmail.split('@')[0], "", "5");
      } catch (e) {
        printLog("❌ Email OTP verification failed: $e");
        generalProvider.setLoading(false);
        Utils().showSnackBar(context, "Invalid OTP. Please try again.", true);
      }
    } else {
      // Phone OTP verification (static OTP for testing)
      if (entered != "123456") {
        generalProvider.setLoading(false);
        Utils().showSnackBar(context, "otpinvalid", true);
        return;
      }

      final localMobile = _localMobileFromAny(mobilenumber);
      _login(localMobile, _generate16DigitDeviceId(), "", "", "1");
    }
  }

  /// ✅ Google Sign-In Method
  Future<void> gmailLogin() async {
    try {
      printLog("🔵 Starting Google Sign-In...");
      generalProvider.setLoading(true);

      // Sign out first to show account picker
      await _googleSignIn.signOut();

      // Sign in
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      // User cancelled
      if (account == null) {
        printLog("❌ User cancelled sign-in");
        generalProvider.setLoading(false);
        if (!mounted) return;
        Utils().showSnackBar(context, "Sign-in cancelled", false);
        return;
      }

      // ✅ Extract user data
      String email = account.email;
      String name = account.displayName ?? email.split('@')[0];
      String photo = account.photoUrl ?? '';

      printLog("✅ Google Sign-In Success!");
      printLog("📧 Email: $email");
      printLog("👤 Name: $name");
      printLog("🖼️ Photo: $photo");

      // Send to backend with type = "2" for Google login
      if (!mounted) return;
      _login("", email, name, photo, "2");
    } catch (e) {
      printLog("❌ Google Sign-In Error: $e");
      generalProvider.setLoading(false);

      if (!mounted) return;
      Utils().showSnackBar(
          context, "Google sign-in failed.  Please try again.", true);
    }
  }

  /// Updated login method to handle both phone and Google
  _login(
    String mobileWithoutCountryCode,
    String email,
    String userName,
    String profileImg,
    String type, // "1" = phone, "2" = Google
  ) async {
    printLog("📤 Login Request:");
    printLog("Type: $type"); // 1 = phone, 2 = Google
    printLog("Mobile: $mobileWithoutCountryCode");
    printLog("Email: $email");
    printLog("Name: $userName");

    final provider = Provider.of<GeneralProvider>(context, listen: false);
    provider.setLoading(true);

    // Download profile image if Google Sign-In
    File? userProfileImg;
    if (profileImg.isNotEmpty) {
      userProfileImg = await Utils.saveImageInStorage(profileImg);
      printLog("Profile image saved: $userProfileImg");
    }

    // Call login API
    await provider.login(
      type,
      email,
      mobileWithoutCountryCode,
      strDeviceType ?? "",
      strDeviceToken ?? "",
      countrycode,
      countryname,
    );

    if (!provider.loading) {
      if (!mounted) return;
      final loginModel = provider.loginModel;
      provider.setLoading(false);

      if (loginModel.status == 200 &&
          (loginModel.result?.isNotEmpty ?? false)) {
        // Socket manager
        if (socketManager.socket?.connected == true) {
          String userId = loginModel.result?[0].id.toString() ?? '';
          print("🔐 Login - Setting user ID: $userId");
          socketManager.connectWithUserId(userId);
          socketManager.setUserId(userId);
        }

        // Save user credentials
        final serverMobile = loginModel.result?[0].mobileNumber?.toString() ??
            mobileWithoutCountryCode;
        final savedMobile = _localMobileFromAny(serverMobile);

        Utils.saveUserCreds(
            userID: loginModel.result?[0].id.toString(),
            channeId: loginModel.result?[0].channelId.toString(),
            channelName: loginModel.result?[0].channelName.toString(),
            fullName: loginModel.result?[0].fullName.toString(),
            email: loginModel.result?[0].email.toString(),
            mobileNumber: savedMobile,
            countrycode: loginModel.result?[0].countryCode.toString(),
            countryname: loginModel.result?[0].channelName.toString(),
            image: loginModel.result?[0].image.toString(),
            coverImg: loginModel.result?[0].coverImg.toString(),
            deviceType: loginModel.result?[0].deviceType.toString(),
            deviceToken: loginModel.result?[0].deviceToken.toString(),
            userIsBuy: loginModel.result?[0].isBuy.toString(),
            isAdsFree: loginModel.result?[0].adsFree.toString(),
            isDownload: loginModel.result?[0].isDownload.toString(),
            isCreator: loginModel.result?[0].isCreator.toString(),
            walletBalance: loginModel.result?[0].walletBalance.toString(),
            subscriptionPlan: loginModel.result?[0].packageName.toString());

        // Setup push notifications
        await FirebaseService.setupUserNotifications(
          loginModel.result?[0].id.toString() ?? '',
        );

        printLog("✅ Login successful!  Navigating.. .");

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Bottombar()),
          (Route<dynamic> route) => false,
        );
      } else {
        provider.setLoading(false);
        Utils().showSnackBar(
          context,
          loginModel.message ?? "Login failed",
          true,
        );
      }
    }
  }

  @override
  void dispose() {
    numberController.dispose();
    emailController.dispose();
    pinPutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: appbgcolor,
        body: Stack(
          children: [
            Consumer<GeneralProvider>(builder: (context, provider, child) {
              return isOTP
                  ? _buildOTPScreen(provider)
                  : _buildLoginScreen(provider);
            }),
            // ✅ Magic SDK Relayer - Required for Magic to work
            magic.relayer,
          ],
        ),
      ),
    );
  }

  // OTP Screen (unchanged)
  Widget _buildOTPScreen(GeneralProvider provider) {
    return SizedBox(
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
                      maxline: 2,
                      fontwaight: FontWeight.w800,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 5),
                  MyText(
                      color: white,
                      text: isEmailLogin
                          ? "We have sent an OTP to your email"
                          : "we have sent an otp to your number",
                      textalign: TextAlign.center,
                      multilanguage: !isEmailLogin,
                      fontsizeNormal: Dimens.textDesc,
                      inter: false,
                      maxline: 2,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 15),
                  MyText(
                      color: white,
                      text: isEmailLogin ? userEmail : mobilenumber.toString(),
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
                          Utils().showSnackBar(context, "pleaseenterotp", true);
                        } else {
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
                  InkWell(
                    onTap: () {
                      if (pinPutController.text.toString().isEmpty) {
                        Utils().showSnackBar(context, "pleaseenterotp", true);
                      } else {
                        if (!mounted) return;
                        provider.setLoading(true);
                        _checkOTPAndLogin();
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.06,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: Constant.gradientColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: provider.isProgressLoading
                          ? const CircularProgressIndicator(
                              color: pureBlack, strokeWidth: 0.9)
                          : MyText(
                              color: pureBlack,
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
                  ),
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
    );
  }

  // Login Screen with Google Sign-In Button
  Widget _buildLoginScreen(GeneralProvider provider) {
    return AbsorbPointer(
      absorbing: isLoad,
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: appbgcolor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            text: "hello",
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
                            text: "loginyouraccount",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textTitle,
                            multilanguage: true,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 20),
                        // Phone Sign-in Commented Out
                        // IntlPhoneField(
                        //   disableLengthCheck: true,
                        //   textAlignVertical: TextAlignVertical.center,
                        //   cursorColor: white,
                        //   autovalidateMode: AutovalidateMode.disabled,
                        //   controller: numberController,
                        //   style: Utils.googleFontStyle(4, Dimens.textTitle,
                        //       FontStyle.normal, white, FontWeight.w500),
                        //   showCountryFlag: true,
                        //   showDropdownIcon: false,
                        //   initialCountryCode: Constant.initialCountryCode,
                        //   dropdownTextStyle: Utils.googleFontStyle(
                        //       4,
                        //       Dimens.textTitle,
                        //       FontStyle.normal,
                        //       white,
                        //       FontWeight.w500),
                        //   keyboardType: TextInputType.number,
                        //   textInputAction: TextInputAction.next,
                        //   decoration: InputDecoration(
                        //     border: InputBorder.none,
                        //     hintStyle: Utils.googleFontStyle(
                        //         4,
                        //         Dimens.textMedium,
                        //         FontStyle.normal,
                        //         white,
                        //         FontWeight.w500),
                        //     hintText: "Mobile Number",
                        //     enabledBorder: OutlineInputBorder(
                        //       borderRadius:
                        //           const BorderRadius.all(Radius.circular(5)),
                        //       borderSide: BorderSide(color: white, width: 1),
                        //     ),
                        //     focusedBorder: OutlineInputBorder(
                        //       borderRadius:
                        //           const BorderRadius.all(Radius.circular(5)),
                        //       borderSide: BorderSide(color: white, width: 1),
                        //     ),
                        //   ),
                        //   onChanged: (phone) {
                        //     mobilenumber = phone.completeNumber;
                        //     countryname = phone.countryISOCode;
                        //     countrycode = phone.countryCode;
                        //     log("numberController==> ${numberController.text}");
                        //     log('mobile number==> $mobilenumber');
                        //     log('countryCode number==> $countryname');
                        //     log('countryISOCode==> $countrycode');
                        //   },
                        //   onCountryChanged: (country) {
                        //     countryname = country.code.replaceAll('+', '');
                        //     countrycode = "+${country.dialCode.toString()}";
                        //     log('countryname===> $countryname');
                        //     log('countrycode===> $countrycode');
                        //   },
                        // ),
                        // const SizedBox(height: 20),

                        // // ✅ OR Divider
                        // Row(
                        //   children: [
                        //     Expanded(
                        //         child: Divider(
                        //             color: white.withOpacity(0.3),
                        //             thickness: 1)),
                        //     Padding(
                        //       padding:
                        //           const EdgeInsets.symmetric(horizontal: 15),
                        //       child: MyText(
                        //         color: white,
                        //         text: "or",
                        //         textalign: TextAlign.center,
                        //         fontsizeNormal: 14,
                        //         inter: false,
                        //         multilanguage: true,
                        //         maxline: 1,
                        //         fontwaight: FontWeight.w500,
                        //         overflow: TextOverflow.ellipsis,
                        //         fontstyle: FontStyle.normal,
                        //       ),
                        //     ),
                        //     Expanded(
                        //         child: Divider(
                        //             color: white.withOpacity(0.3),
                        //             thickness: 1)),
                        //   ],
                        // ),
                        // const SizedBox(height: 20),

                        // ✅ Email Input Field
                        TextField(
                          controller: emailController,
                          cursorColor: white,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          style: Utils.googleFontStyle(4, Dimens.textTitle,
                              FontStyle.normal, white, FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: "Email Address",
                            hintStyle: Utils.googleFontStyle(
                                4,
                                Dimens.textMedium,
                                FontStyle.normal,
                                white.withOpacity(0.7),
                                FontWeight.w500),
                            prefixIcon:
                                Icon(Icons.email_outlined, color: white),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide(color: white, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              borderSide:
                                  BorderSide(color: colorPrimary, width: 1.5),
                            ),
                          ),
                          onChanged: (value) {
                            userEmail = value.trim();
                          },
                        ),
                        const SizedBox(height: 20),

                        // ✅ Terms, Conditions & Agreements Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: isAgreeTerms,
                                onChanged: (value) {
                                  setState(() {
                                    isAgreeTerms = value ?? false;
                                  });
                                },
                                activeColor: colorPrimary,
                                checkColor: pureBlack,
                                side: BorderSide(color: white, width: 1.5),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    "I agree to the ",
                                    style: TextStyle(
                                      color: white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _openTermsAndConditions,
                                    child: Text(
                                      "Terms and Conditions",
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ", ",
                                    style: TextStyle(
                                      color: white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _openPrivacyPolicy,
                                    child: Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ", ",
                                    style: TextStyle(
                                      color: white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _openFanbaePassAgreement,
                                    child: Text(
                                      "Fanbae Agreement",
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ", and ",
                                    style: TextStyle(
                                      color: white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _openContractBetweenFanbaeAndCreator,
                                    child: Text(
                                      "Creator Contract",
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ✅ 18+ Age Verification Checkbox
                        // ✅ 18+ Age Verification Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: isAgree18Plus,
                                onChanged: (value) {
                                  setState(() {
                                    isAgree18Plus = value ?? false;
                                  });
                                },
                                activeColor: colorPrimary,
                                checkColor: pureBlack,
                                side: BorderSide(color: white, width: 1.5),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: _open18USC,
                                    child: Text(
                                      "18 USC: ",
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "I confirm that I am 18 years or older. ",
                                    style: TextStyle(
                                      color: white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _openChildSafetyAndCSAM,
                                    child: Text(
                                      "Child Safety & CSAM Notice",
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (provider.isProgressLoading)
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 55,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colorPrimary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: CircularProgressIndicator(
                              color: colorAccent,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          InkWell(
                            onTap: () async {
                              // Validate checkboxes
                              if (!isAgreeTerms) {
                                Utils().showSnackBar(
                                    context,
                                    "Please agree to all terms and conditions",
                                    false);
                                return;
                              }
                              if (!isAgree18Plus) {
                                Utils().showSnackBar(
                                    context,
                                    "You must be 18 years or older to continue",
                                    false);
                                return;
                              }

                              // Email login with Magic SDK
                              if (emailController.text.trim().isEmpty) {
                                Utils().showSnackBar(context,
                                    "Please enter your email address", false);
                                return;
                              }

                              log("📧 Email login button tapped");
                              log("Email entered: ${emailController.text.trim()}");

                              if (!EmailValidator.validate(
                                  emailController.text.trim())) {
                                Utils().showSnackBar(context,
                                    "Please enter a valid email address", true);
                                return;
                              }
                              userEmail = emailController.text.trim();
                              log("Email validated: $userEmail");

                              setState(() {
                                isLoad = true;
                              });

                              log("Starting Magic email login...");
                              await emailLoginWithMagic();
                              log("Magic email login completed");

                              setState(() {
                                isLoad = false;
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 55,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorPrimary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: MyText(
                                  color: pureBlack,
                                  text: "continue",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textTitle,
                                  inter: false,
                                  maxline: 1,
                                  multilanguage: true,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // ✅ "OR" Divider
                        Align(
                          alignment: Alignment.center,
                          child: MyText(
                              color: white,
                              text: "or",
                              textalign: TextAlign.center,
                              fontsizeNormal: 16,
                              inter: false,
                              multilanguage: true,
                              maxline: 1,
                              fontwaight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),

                        const SizedBox(height: 20),

                        // ✅ Google Sign-In Button
                        Center(
                          child: InkWell(
                            focusColor: white,
                            hoverColor: appbgcolor.withOpacity(0.20),
                            splashColor: white,
                            highlightColor: white,
                            borderRadius: BorderRadius.circular(50),
                            onTap: gmailLogin, // ← Call Google Sign-In
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.fromLTRB(30, 15, 30, 15),
                              decoration: BoxDecoration(
                                  border: Border.all(width: 0.5, color: gray),
                                  borderRadius: BorderRadius.circular(50)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyImage(
                                    width: 20,
                                    imagePath: "ic_google.png",
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(width: 15),
                                  MyText(
                                      color: white,
                                      fontsizeWeb: Dimens.textMedium,
                                      text: "loginwithgoogle",
                                      fontsizeNormal: Dimens.textMedium,
                                      fontwaight: FontWeight.w500,
                                      maxline: 1,
                                      multilanguage: true,
                                      overflow: TextOverflow.ellipsis,
                                      textalign: TextAlign.center,
                                      fontstyle: FontStyle.normal),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Back Button
                  InkWell(
                    highlightColor: transparent,
                    hoverColor: transparent,
                    splashColor: transparent,
                    focusColor: transparent,
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const Bottombar(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(-1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                        (Route route) => false,
                      );
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
          if (isLoad)
            const Positioned.fill(
                child: Center(
                    child: CircularProgressIndicator(color: colorPrimary)))
        ],
      ),
    );
  }
}
