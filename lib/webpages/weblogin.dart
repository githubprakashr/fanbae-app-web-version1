import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:fanbae/pages/feeds.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/webpages/webotp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:fanbae/provider/generalprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import '../pages/bottombar.dart';
import '../utils/responsive_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';
import '../utils/firebase_service.dart';

// Conditional import for dart:js
import 'dart:js' if (dart.library.io) '../utils/js_stub.dart' as js;

class WebLogin extends StatefulWidget {
  const WebLogin({super.key});

  @override
  State<WebLogin> createState() => _WebLoginState();
}

class _WebLoginState extends State<WebLogin> {
  late GeneralProvider generalProvider;
  SharedPre sharePref = SharedPre();
  bool passwordVisible = false;
  File? mProfileImg;
  dynamic strDeviceToken;
  String? deviceType;
  bool isagreeCondition = true; // Default to true for now
  bool isAgreeTerms = false;
  bool isAgree18Plus = false;

  TextEditingController numberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String mobilenumber = "", countrycode = "", countryname = "";
  String countryCode = "";
  bool isOtp = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  void initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _getDeviceToken();
  }

  /// Generate a persistent 16-digit device ID
  String _generate16DigitDeviceId() {
    final rnd = math.Random.secure();
    const length = 16;
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(rnd.nextInt(10)); // digit 0-9
    }
    return buffer.toString();
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

  /// Get or create persistent device token
  _getDeviceToken() async {
    try {
      if (kIsWeb) {
        // Web platform - use generated device ID
        SharedPreferences prefs = await SharedPreferences.getInstance();
        strDeviceToken = prefs.getString('device_token');

        if (strDeviceToken == null || strDeviceToken.isEmpty) {
          strDeviceToken = _generate16DigitDeviceId();
          await prefs.setString('device_token', strDeviceToken);
          printLog("Generated new device token for web: $strDeviceToken");
        } else {
          printLog("Using existing device token for web: $strDeviceToken");
        }
        deviceType = "3";
      } else {
        // Mobile platform - get actual FCM token from Pusher Beams
        final fcmToken = await FirebaseService.getDeviceToken();
        strDeviceToken = fcmToken ?? _generate16DigitDeviceId();

        if (Platform.isAndroid) {
          deviceType = "1";
        } else if (Platform.isIOS) {
          deviceType = "2";
        } else {
          deviceType = "0";
        }

        printLog(
            "📱 Pusher Beams token: ${fcmToken ?? 'Not available, using generated ID'}");
      }
    } catch (e) {
      printLog("_getDeviceToken Exception ===> $e");
      // Fallback to random token if everything fails
      strDeviceToken = _generate16DigitDeviceId();
      if (kIsWeb) {
        deviceType = "3";
      } else if (!kIsWeb && Platform.isAndroid) {
        deviceType = "1";
      } else if (!kIsWeb && Platform.isIOS) {
        deviceType = "2";
      } else {
        deviceType = "0";
      }
    }
    printLog("===>deviceType $deviceType");
    printLog("===>deviceToken $strDeviceToken");
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
                children: [
                  loginItem(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: ResponsiveHelper.checkIsWeb(context)
                  ? Utils.buildBackBtn(context)
                  : InkWell(
                      borderRadius: BorderRadius.circular(30),
                      focusColor: gray.withOpacity(0.5),
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const Bottombar(isFeed: true),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin =
                                  Offset(-1.0, 0.0); // Start from the left
                              const end =
                                  Offset.zero; // End at the current position
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
                        padding: const EdgeInsets.all(5.0),
                        child: Utils.backIcon(),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget loginItem() {
    return Column(
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
            fontsizeWeb: 20,
            text: "loginyouraccount",
            fontsizeNormal: 20,
            fontwaight: FontWeight.w600,
            maxline: 1,
            multilanguage: true,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal),
        const SizedBox(height: 15),
        // Phone Sign-in Commented Out
        // SizedBox(
        //   width: kIsWeb && MediaQuery.of(context).size.width > 1200
        //       ? MediaQuery.of(context).size.width * 0.35
        //       : kIsWeb && MediaQuery.of(context).size.width > 800
        //           ? MediaQuery.of(context).size.width * 0.50
        //           : MediaQuery.of(context).size.width * 0.75,
        //   child: IntlPhoneField(
        //     keyboardType: TextInputType.number,
        //     cursorColor: white,
        //     textInputAction: TextInputAction.done,
        //     controller: numberController,
        //     initialCountryCode: Constant.initialCountryCode,
        //     showCountryFlag: true,
        //     dropdownTextStyle: GoogleFonts.inter(
        //         fontSize: Dimens.textMedium,
        //         fontStyle: FontStyle.normal,
        //         color: white,
        //         fontWeight: FontWeight.w500),
        //     onChanged: (phone) {
        //       mobilenumber = phone.completeNumber;
        //       countryname = phone.countryISOCode;
        //       countrycode = phone.countryCode;
        //       log('mobile number==> $mobilenumber');
        //       log('countryCode number==> $countryname');
        //       log('countryISOCode==> $countrycode');
        //     },
        //     onCountryChanged: (country) {
        //       countryname = country.code;
        //       countrycode = "+${country.dialCode.toString()}";
        //       log('countryname===> $countryname');
        //       log('countrycode===> $countrycode');
        //     },
        //     style: GoogleFonts.inter(
        //         fontSize: Dimens.textMedium,
        //         fontStyle: FontStyle.normal,
        //         color: white,
        //         fontWeight: FontWeight.w500),
        //     decoration: InputDecoration(
        //       hintText: Locales.string(context, "mobilenumber"),
        //       hintStyle: GoogleFonts.inter(
        //           fontSize: Dimens.textMedium,
        //           fontStyle: FontStyle.normal,
        //           color: white,
        //           fontWeight: FontWeight.w400),
        //       focusedBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(5),
        //         borderSide: const BorderSide(width: 0.5, color: gray),
        //       ),
        //       disabledBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(5),
        //         borderSide: const BorderSide(width: 0.5, color: gray),
        //       ),
        //       enabledBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(5),
        //         borderSide: const BorderSide(width: 0.5, color: gray),
        //       ),
        //       contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        //       border:
        //           OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        //       fillColor: white,
        //       filled: false,
        //     ),
        //     onSubmitted: (newValue) {
        //       _handleLogin();
        //     },
        //   ),
        // ),
        // const SizedBox(height: 20),
        // /* OR Divider */
        // SizedBox(
        //   width: kIsWeb && MediaQuery.of(context).size.width > 1200
        //       ? MediaQuery.of(context).size.width * 0.35
        //       : kIsWeb && MediaQuery.of(context).size.width > 800
        //           ? MediaQuery.of(context).size.width * 0.50
        //           : MediaQuery.of(context).size.width * 0.75,
        //   child: Row(
        //     children: [
        //       Expanded(
        //           child: Divider(color: gray.withOpacity(0.5), thickness: 1)),
        //       Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 15),
        //         child: MyText(
        //           color: gray,
        //           text: "OR",
        //           fontsizeNormal: Dimens.textSmall,
        //           fontsizeWeb: Dimens.textSmall,
        //           fontwaight: FontWeight.w400,
        //           maxline: 1,
        //           overflow: TextOverflow.ellipsis,
        //           textalign: TextAlign.center,
        //           fontstyle: FontStyle.normal,
        //         ),
        //       ),
        //       Expanded(
        //           child: Divider(color: gray.withOpacity(0.5), thickness: 1)),
        //     ],
        //   ),
        // ),
        // const SizedBox(height: 20),
        /* Email Input Field */
        SizedBox(
          width: kIsWeb && MediaQuery.of(context).size.width > 1200
              ? MediaQuery.of(context).size.width * 0.35
              : kIsWeb && MediaQuery.of(context).size.width > 800
                  ? MediaQuery.of(context).size.width * 0.50
                  : MediaQuery.of(context).size.width * 0.75,
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: white,
            textInputAction: TextInputAction.done,
            style: GoogleFonts.inter(
              fontSize: Dimens.textMedium,
              fontStyle: FontStyle.normal,
              color: white,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: Locales.string(context, "email_address"),
              hintStyle: GoogleFonts.inter(
                fontSize: Dimens.textMedium,
                fontStyle: FontStyle.normal,
                color: white.withOpacity(0.6),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon:
                  const Icon(Icons.email_outlined, color: gray, size: 20),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(width: 0.5, color: gray),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(width: 0.5, color: gray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(width: 0.5, color: gray),
              ),
              contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              fillColor: white,
              filled: false,
            ),
            onSubmitted: (value) {
              _handleLogin();
            },
          ),
        ),
        const SizedBox(height: 20),

        // ✅ Terms and Conditions Checkbox
        SizedBox(
          width: kIsWeb && MediaQuery.of(context).size.width > 1200
              ? MediaQuery.of(context).size.width * 0.35
              : kIsWeb && MediaQuery.of(context).size.width > 800
                  ? MediaQuery.of(context).size.width * 0.50
                  : MediaQuery.of(context).size.width * 0.75,
          child: Row(
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
        ),
        const SizedBox(height: 15),

        // ✅ 18+ Age Verification Checkbox
        SizedBox(
          width: kIsWeb && MediaQuery.of(context).size.width > 1200
              ? MediaQuery.of(context).size.width * 0.35
              : kIsWeb && MediaQuery.of(context).size.width > 800
                  ? MediaQuery.of(context).size.width * 0.50
                  : MediaQuery.of(context).size.width * 0.75,
          child: Row(
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
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: _handleLogin,
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
        const SizedBox(height: 20),
        /* Google Sign-In Button */
        InkWell(
          focusColor: white,
          hoverColor: appbgcolor.withOpacity(0.20),
          splashColor: white,
          highlightColor: white,
          borderRadius: BorderRadius.circular(50),
          onTap: gmailLogin,
          child: Container(
            width: 300,
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
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
        const SizedBox(height: 20),
        Consumer<GeneralProvider>(builder: (context, provider, child) {
          if (provider.isProgressLoading) {
            return const CircularProgressIndicator(
              color: colorPrimary,
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  /// Handle phone number login
  void _handlePhoneLogin() {
    if (numberController.text.isEmpty) {
      Utils().showSnackBar(context, "pleaseenteryourmobilenumber", true);
    } else if (isagreeCondition != true) {
      Utils().showSnackBar(context, "pleaseaccepttermsandcondition", true);
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => WebOTP(
            fullnumber: mobilenumber,
            countrycode: countrycode,
            countryName: countryname,
            number: numberController.text,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  /// Handle login (email only)
  void _handleLogin() {
    // Only check for email
    if (emailController.text.trim().isNotEmpty) {
      _handleEmailLogin();
    } else {
      Utils().showSnackBar(context, "Please enter your email address", true);
    }
  }

  /// Handle email login with Magic Labs
  /// Handle email login - Backend OTP approach (works on web and mobile)
  void _handleEmailLogin() async {
    final email = emailController.text.trim();

    // Validate checkboxes
    if (!isAgreeTerms) {
      Utils().showSnackBar(
          context, "Please agree to all terms and conditions", false);
      return;
    }
    if (!isAgree18Plus) {
      Utils().showSnackBar(
          context, "You must be 18 years or older to continue", false);
      return;
    }

    // Validate email format
    if (!EmailValidator.validate(email)) {
      Utils().showSnackBar(context, "enter_valid_email", true);
      return;
    }

    // Check terms and conditions
    if (isagreeCondition != true) {
      Utils().showSnackBar(context, "pleaseaccepttermsandcondition", true);
      return;
    }

    try {
      generalProvider.setLoading(true);
      printLog("📧 Initializing Magic and sending email OTP to: $email");

      // Only use JavaScript on web platform
      if (kIsWeb) {
        // Use Magic Web SDK via JavaScript interop
        try {
          js.context.callMethod('ensureMagicSDKReady', [
            js.allowInterop((_) {
              try {
                // Initialize Magic with API key after SDK is confirmed loaded.
                final initialized = js.context
                    .callMethod('initMagic', ['pk_live_8E2F3F0BBA90BD08']);

                if (initialized != true) {
                  throw Exception("Failed to initialize Magic SDK");
                }

                printLog("✅ Magic initialized");

                // Send email OTP with callbacks
                js.context.callMethod('sendMagicEmailOTP', [
                  email,
                  js.allowInterop((didToken) {
                    printLog("✅ Magic OTP sent successfully, token: $didToken");

                    // Proceed with backend login directly
                    // We already have the email, no need to fetch metadata
                    _proceedWithEmailLogin(email);
                  }),
                  js.allowInterop((error) {
                    printLog("❌ Magic email OTP error: $error");
                    generalProvider.setLoading(false);
                    if (mounted) {
                      Utils().showSnackBar(
                          context, "Failed to send email verification", false);
                    }
                  })
                ]);
              } catch (e) {
                generalProvider.setLoading(false);
                printLog("❌ Magic Web SDK init/send error: $e");
                if (!mounted) return;
                Utils().showSnackBar(
                    context, "Failed to send email verification", false);
              }
            }),
            js.allowInterop((error) {
              generalProvider.setLoading(false);
              printLog("❌ Magic SDK not ready: $error");
              if (!mounted) return;
              Utils().showSnackBar(
                  context, "Magic OTP is currently unavailable", false);
            })
          ]);
        } catch (e) {
          generalProvider.setLoading(false);
          printLog("❌ Magic Web SDK error: $e");
          if (!mounted) return;
          Utils().showSnackBar(
              context, "Failed to send email verification", false);
        }
      } else {
        // For non-web platforms (mobile/desktop), call backend API directly
        printLog("📱 Mobile platform - calling backend API for Magic Labs");

        try {
          // Call backend API with type "5" for Magic Labs email login
          await generalProvider.login(
            "5", // Type 5 = Magic Labs Email OTP
            email, // Email
            "", // Mobile (empty for email login)
            deviceType ?? "", // Device type
            strDeviceToken ?? "", // Device token
            "", // Country code (empty for email login)
            "", // Country name (empty for email login)
          );

          if (!generalProvider.loading) {
            final loginData =
                generalProvider.loginModel.result?.isNotEmpty == true
                    ? generalProvider.loginModel.result!.first
                    : null;

            if (generalProvider.loginModel.status == 200 && loginData != null) {
              // Save user credentials
              await Utils.saveUserCreds(
                userID: loginData.id.toString(),
                channeId: loginData.channelId.toString(),
                channelName: loginData.channelName.toString(),
                fullName: loginData.fullName.toString(),
                email: loginData.email.toString(),
                mobileNumber: loginData.mobileNumber.toString(),
                countrycode: loginData.countryCode.toString(),
                countryname: loginData.channelName.toString(),
                image: loginData.image.toString(),
                coverImg: loginData.coverImg.toString(),
                deviceType: loginData.deviceType.toString(),
                deviceToken: loginData.deviceToken.toString(),
                userIsBuy: loginData.isBuy.toString(),
                isAdsFree: loginData.adsFree.toString(),
                isCreator: loginData.isCreator.toString(),
                walletBalance: loginData.walletBalance.toString(),
                isDownload: loginData.isDownload.toString(),
              );

              // Setup push notifications
              if (!kIsWeb) {
                await FirebaseService.setupUserNotifications(
                  loginData.id.toString(),
                );
              }

              generalProvider.setLoading(false);
              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => ResponsiveHelper.checkIsWeb(context)
                      ? const Feeds()
                      : const Bottombar(),
                ),
                (Route<dynamic> route) => false,
              );
            } else {
              generalProvider.setLoading(false);
              if (!mounted) return;
              Utils().showSnackBar(
                context,
                generalProvider.loginModel.message ?? "Login failed",
                true,
              );
            }
          }
        } catch (e) {
          generalProvider.setLoading(false);
          printLog("❌ Mobile Magic Labs login error: $e");
          if (!mounted) return;
          Utils()
              .showSnackBar(context, "Login failed. Please try again.", false);
        }
      }
    } catch (e) {
      generalProvider.setLoading(false);
      printLog("❌ Email login error: $e");

      if (!mounted) return;
      Utils()
          .showSnackBar(context, "Failed to proceed with email login", false);
    }
  }

  void _proceedWithEmailLogin(String email) async {
    try {
      // Magic Labs authenticated successfully - now login via backend API
      printLog("✅ Magic authentication successful - logging in via backend...");

      // Call backend API with email login (type "5" - Magic Labs)
      await generalProvider.login(
        "5", // Type 5 = Magic Labs Email OTP
        email, // Email
        "", // Mobile (empty for email login)
        deviceType ?? "3", // Device type
        strDeviceToken ?? "", // Device token
        "", // Country code (empty for email login)
        "", // Country name (empty for email login)
      );

      if (!generalProvider.loading) {
        final loginData = generalProvider.loginModel.result?.isNotEmpty == true
            ? generalProvider.loginModel.result!.first
            : null;

        if (generalProvider.loginModel.status == 200 && loginData != null) {
          // Save user credentials from backend response
          printLog("✅ Backend login successful - saving user data...");

          await Utils.saveUserCreds(
            userID: loginData.id.toString(),
            channeId: loginData.channelId.toString(),
            channelName: loginData.channelName.toString(),
            fullName: loginData.fullName.toString(),
            email: loginData.email.toString(),
            mobileNumber: loginData.mobileNumber.toString(),
            countrycode: loginData.countryCode.toString(),
            countryname: loginData.channelName.toString(),
            image: loginData.image.toString(),
            coverImg: loginData.coverImg.toString(),
            deviceType: loginData.deviceType.toString(),
            deviceToken: loginData.deviceToken.toString(),
            userIsBuy: loginData.isBuy.toString(),
            isAdsFree: loginData.adsFree.toString(),
            isCreator: loginData.isCreator.toString(),
            walletBalance: loginData.walletBalance.toString(),
            isDownload: loginData.isDownload.toString(),
          );

          // Setup push notifications
          if (!kIsWeb) {
            await FirebaseService.setupUserNotifications(
              loginData.id.toString(),
            );
          }

          // Load general settings
          printLog("📡 Loading general settings...");
          await generalProvider.getGeneralsetting();

          if (generalProvider.generalsettingModel.result != null) {
            for (var i = 0;
                i < generalProvider.generalsettingModel.result!.length;
                i++) {
              await SharedPre().save(
                generalProvider.generalsettingModel.result?[i].key.toString() ??
                    "",
                generalProvider.generalsettingModel.result?[i].value
                        .toString() ??
                    "",
              );
            }
            printLog("✅ General settings loaded successfully");
          }

          generalProvider.setLoading(false);

          if (!mounted) return;

          // Navigate to Bottombar - same as Google login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => ResponsiveHelper.checkIsWeb(context)
                  ? const Feeds()
                  : const Bottombar(),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          // Backend returned error
          generalProvider.setLoading(false);
          if (!mounted) return;
          Utils().showSnackBar(
            context,
            generalProvider.loginModel.message ?? "Login failed",
            true,
          );
        }
      }
    } catch (e) {
      generalProvider.setLoading(false);
      printLog("❌ Email login error: $e");

      if (!mounted) return;
      Utils().showSnackBar(context, "Login failed. Please try again.", false);
    }
  }

  /// Google Sign-In Implementation
  Future<void> gmailLogin() async {
    try {
      generalProvider.setLoading(true);

      // Sign out first to ensure account picker shows
      await _googleSignIn.signOut();

      // Trigger Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        printLog("Google Sign-In cancelled by user");
        generalProvider.setLoading(false);
        if (!mounted) return;
        Utils().showSnackBar(context, "signincanceled", true);
        return;
      }

      // Extract user data
      final String email = googleUser.email;
      final String userName = googleUser.displayName ?? '';
      final String profileImg = googleUser.photoUrl ?? '';

      printLog("✅ Google Sign-In Success:");
      printLog("Email: $email");
      printLog("Name: $userName");
      printLog("Photo: $profileImg");

      // Proceed with authentication
      if (!mounted) return;
      checkAndNavigate(email, userName, profileImg, "", "2");
    } catch (e) {
      printLog("❌ Google sign-in error: $e");
      generalProvider.setLoading(false);

      if (!mounted) return;

      // Show user-friendly error message
      String errorMessage = "googlesigninfailed";
      if (e.toString().contains('network_error')) {
        errorMessage = "networkerror";
      } else if (e.toString().contains('sign_in_canceled')) {
        errorMessage = "signincanceled";
      } else if (e.toString().contains('sign_in_failed')) {
        errorMessage = "signinfailed";
      }

      Utils().showSnackBar(context, errorMessage, true);
    }
  }

  checkAndNavigate(
    String email,
    String userName,
    String profileImg,
    String password,
    String type,
  ) async {
    final loginItem = Provider.of<GeneralProvider>(context, listen: false);
    generalProvider.setLoading(true);

    File? userProfileImg = await Utils.saveImageInStorage(
        profileImg); // handles empty string internally
    printLog("userProfileImg ===========> $userProfileImg");

    await loginItem.login(
        type, email, "", deviceType ?? "", strDeviceToken ?? "", "", "");

    printLog('checkAndNavigate loading ==>> ${loginItem.loading}');

    if (!loginItem.loading) {
      final loginData = generalProvider.loginModel.result?.isNotEmpty == true
          ? generalProvider.loginModel.result!.first
          : null;

      if (loginItem.loginModel.status == 200 && loginData != null) {
        Utils.saveUserCreds(
            userID: loginData.id.toString(),
            channeId: loginData.channelId.toString(),
            channelName: loginData.channelName.toString(),
            fullName: loginData.fullName.toString(),
            email: loginData.email.toString(),
            mobileNumber: loginData.mobileNumber.toString(),
            countrycode: loginData.countryCode.toString(),
            countryname: loginData.channelName.toString(),
            image: loginData.image.toString(),
            coverImg: loginData.coverImg.toString(),
            deviceType: loginData.deviceType.toString(),
            deviceToken: loginData.deviceToken.toString(),
            userIsBuy: loginData.isBuy.toString(),
            isAdsFree: loginData.adsFree.toString(),
            isCreator: loginData.isCreator.toString(),
            walletBalance: loginData.walletBalance.toString(),
            isDownload: loginData.isDownload.toString());

        // Setup push notifications
        if (!kIsWeb) {
          await FirebaseService.setupUserNotifications(
            loginData.id.toString(),
          );
        }

        generalProvider.setLoading(false);
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
        generalProvider.setLoading(false);
        Utils().showSnackBar(
            context, loginItem.loginModel.message ?? "Login failed", true);
      }
    }
  }

  @override
  void dispose() {
    numberController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
