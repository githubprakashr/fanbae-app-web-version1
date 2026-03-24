// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fanbae/livestream/livestream.dart';
import 'package:fanbae/main.dart';
import 'package:fanbae/model/download_item.dart';
import 'package:fanbae/model/feedslistmodel.dart';
import 'package:fanbae/pages/bottombar.dart';
import 'package:fanbae/music/musicdetails.dart';
import 'package:fanbae/pages/chathistory.dart';
import 'package:fanbae/pages/detail.dart';
import 'package:fanbae/pages/feeds.dart';
import 'package:fanbae/pages/statistics.dart';
import 'package:fanbae/players/player_video.dart';
import 'package:fanbae/players/player_vimeo.dart';
import 'package:fanbae/players/player_youtube.dart';
import 'package:fanbae/provider/detailsprovider.dart';
import 'package:fanbae/provider/generalprovider.dart';
import 'package:fanbae/provider/notificationprovider.dart';
import 'package:fanbae/provider/profileprovider.dart';
import 'package:fanbae/provider/settingprovider.dart';
import 'package:fanbae/subscription/subscription.dart';
import 'package:fanbae/utils/adhelper.dart';
import 'package:fanbae/utils/customads.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:fanbae/webpages/webhistory.dart';
import 'package:fanbae/webpages/weblikevideos.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/webpages/webmyplaylist.dart';
import 'package:fanbae/webpages/webnotification.dart';
import 'package:fanbae/webpages/webprofile.dart';
import 'package:fanbae/webpages/webshorts.dart';
import 'package:fanbae/webpages/webwatchlater.dart';
import 'package:fanbae/webwidget/activeuserpanel.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:email_validator/email_validator.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fanbae/utils/pusher_beams_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fanbae/pages/login.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as number;
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../livestream/livestreamimage.dart';
import '../pages/earnings.dart';
import '../pages/explore.dart';
import '../pages/followers.dart';
import '../pages/shorts.dart';
import '../pages/subscibedchannel.dart';
import '../pages/subscribe_channels.dart';
import '../pages/subscribing_channels.dart';
import '../pages/viewads.dart';
import '../provider/themeprovider.dart';
import '../subscription/adspackage.dart';
import '../video_audio_call/ScheduleCall.dart';
import '../web_js/js_helper.dart';
import 'package:universal_html/html.dart' as html;

printLog(String message) {
  if (kDebugMode) {
    return print(message);
  }
}

class Utils {
  static ProgressDialog? prDialog;

  static TextStyle googleFontStyle(int inter, double fontsize,
      FontStyle fontstyle, Color color, FontWeight fontwaight) {
    if (inter == 1) {
      return GoogleFonts.poppins(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 2) {
      return GoogleFonts.lobster(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 3) {
      return GoogleFonts.rubik(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 4) {
      return GoogleFonts.roboto(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else {
      return GoogleFonts.inter(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    }
  }

  // Widget Page Loader
  static Widget pageLoader(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: colorPrimary,
      ),
    );
  }

  Widget pageBg(BuildContext context, {required Widget child}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      /*decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("${Constant.imageFolderPath}appbgimage.png"),
            fit: BoxFit.cover),
      ),*/
      child: child,
    );
  }

  showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        webShowClose: true,
        backgroundColor: white,
        webBgColor: colorPrimary,
        textColor: black,
        fontSize: 14);
  }

  static BoxDecoration setGradTTBBGWithBorder(Color colorStart, Color colorEnd,
      Color borderColor, double radius, double border) {
    return BoxDecoration(
      border: Border.all(
        color: borderColor,
        width: border,
      ),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[colorStart, colorEnd],
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  void showSnackBar(BuildContext context, String message, bool multilanguage) {
    final currentContext = scaffoldMessengerKey.currentContext;

    if (currentContext == null) {
      debugPrint("❗No current context found for ScaffoldMessenger.");
      return;
    }
    scaffoldMessengerKey.currentState?.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        width: ResponsiveHelper.checkIsWeb(currentContext)
            ? MediaQuery.of(currentContext).size.width * 0.50
            : MediaQuery.of(currentContext).size.width,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: colorPrimary,
        content: MyText(
          text: message,
          multilanguage: multilanguage,
          fontsizeNormal: Dimens.textMedium,
          fontsizeWeb: Dimens.textMedium,
          maxline: 3,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
          fontwaight: FontWeight.w500,
          color: pureBlack,
          textalign: TextAlign.center,
        ),
      ),
    );
  }

  // Global Progress Dilog
/*  static void showProgress(BuildContext context) async {
    prDialog = ProgressDialog(context);
    prDialog = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false, showLogs: false);

    prDialog!.style(
      message: "Please Wait",
      borderRadius: 5,
      progressWidget: Container(
        padding: const EdgeInsets.all(8),
        child: const CircularProgressIndicator(),
      ),
      maxProgress: 100,
      progressTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: white,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: TextStyle(
        color: black,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    );

    await prDialog!.show();
  }

  void hideProgress(BuildContext context) async {
    prDialog = ProgressDialog(context);
    if (prDialog!.isShowing()) {
      await prDialog!.hide();
    }
  }*/
  static OverlayEntry? _overlayEntry;

  static void showProgress(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Prevent interaction & back navigation
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.3),
          ),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );

    final overlay = Overlay.of(context);
    if (overlay != null && _overlayEntry != null) {
      overlay.insert(_overlayEntry!);
    }
  }

  void hideProgress(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  bgContainer(
      {required double width, required double height, required Widget child}) {
    Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("${Constant.imageFolderPath}appbgimage.png")),
      ),
      child: child,
    );
  }

  otherPageAppBar(BuildContext context, String title, bool multilanguage) {
    return AppBar(
      backgroundColor: appBarColor,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: appbgcolor,
      ),
      elevation: 0,
      centerTitle: false,
      leading: InkWell(
        focusColor: transparent,
        highlightColor: transparent,
        hoverColor: transparent,
        splashColor: transparent,
        onTap: () {
          // Navigator.pop(context);
          Navigator.of(context).pop(false);
          printLog("Back Click");
        },
        child: Align(
          alignment: Alignment.center,
          child: Utils.backIcon(),
        ),
      ),
      title: MyText(
          color: white,
          multilanguage: multilanguage,
          text: title,
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          inter: false,
          maxline: 1,
          fontwaight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal),
    );
  }

  divider(BuildContext context, EdgeInsets padding) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 1,
      padding: padding,
      color: gray,
    );
  }

  static Widget webDivider(BuildContext context, EdgeInsets padding) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 0.5,
      margin: padding,
      color: white.withOpacity(0.20),
    );
  }

  static Future<File?> saveImageInStorage(imgUrl) async {
    try {
      var response = await http.get(Uri.parse(imgUrl));
      Directory? documentDirectory;
      if (Platform.isAndroid) {
        documentDirectory = await getExternalStorageDirectory();
      } else {
        documentDirectory = await getApplicationDocumentsDirectory();
      }
      File file = File(path.join(documentDirectory?.path ?? "",
          '${DateTime.now().millisecondsSinceEpoch.toString()}.png'));
      file.writeAsBytesSync(response.bodyBytes);
      // This is a sync operation on a real
      // app you'd probably prefer to use writeAsByte and handle its Future
      return file;
    } catch (e) {
      printLog("saveImageInStorage Exception ===> $e");
      return null;
    }
  }

  static checkLoginUser(BuildContext context) {
    if (Constant.userID != null) {
      return true;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ResponsiveHelper.isWeb(context)
              ? const WebLogin()
              : const Login();
        },
      ),
    );
    return false;
  }

  static checkandNavigate(BuildContext context, movePage) {
    if (Constant.userID == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ResponsiveHelper.isWeb(context)
                ? const WebLogin()
                : const Login();
          },
        ),
      );
    } else {
      movePage();
    }
  }

  static BoxDecoration setGradientBG(
      Color colorStart, Color colorEnd, double radius) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[colorStart, colorEnd],
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setGradTTBBorderWithBG(Color colorTop, Color colorBottom,
      Color bgColor, double radius, double border) {
    return BoxDecoration(
      border: Border.all(
        color: colorAccent,
        width: border,
      ),
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  // KMB Text Generator Method
  static String kmbGenerator(int num) {
    if (num > 999 && num < 99999) {
      return "${(num / 1000).toStringAsFixed(1)} K";
    } else if (num > 99999 && num < 999999) {
      return "${(num / 1000).toStringAsFixed(0)} K";
    } else if (num > 999999 && num < 999999999) {
      return "${(num / 1000000).toStringAsFixed(1)} M";
    } else if (num > 999999999) {
      return "${(num / 1000000000).toStringAsFixed(1)} B";
    } else {
      return num.toString();
    }
  }

  String formatTimestamp(int timestampMillis) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
    DateTime now = DateTime.now();

    bool isToday = dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;

    if (isToday) {
      return DateFormat.jm().format(dateTime);
    } else if (dateTime.year == now.year) {
      return DateFormat.MMMd().format(dateTime);
    } else {
      return DateFormat.yMMMd().format(dateTime);
    }
  }

  static String timeAgoCustom(DateTime d) {
    // <-- Custom method Time Show  (Display Example  ==> 'Today 7:00 PM')     // WhatsApp Time Show Status Shimila
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    }
    if (diff.inDays >= 1) {
      return "${(diff.inDays / 1).floor()} ${(diff.inDays / 1).floor() == 1 ? "day" : "days"} ago";
    }
    if (diff.inDays > 0) {
      return DateFormat.E().add_jm().format(d);
    }
    if (diff.inHours > 0) return "Today ${DateFormat('jm').format(d)}";
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    }
    return "just now";
  }

  static String formatTime(double time) {
    Duration duration = Duration(milliseconds: time.round());
    duration.inHours;
    if (duration.inHours == 00) {
      return [duration.inMinutes, duration.inSeconds]
          .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
          .join(':');
    } else {
      return [duration.inHours, duration.inMinutes, duration.inSeconds]
          .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
          .join(':');
    }
  }

  convertMillisecondsToSeconds(double milliseconds) {
    return milliseconds / 1000;
  }

  static String generateRoomId() {
    // Create a random instance
    final random = Random();

    // Generate a random number or string
    int randomNumber =
        random.nextInt(1000000); // Generates a number between 0 and 999999

    // Combine with the "room_" prefix
    String roomId = "room_${Constant.userID}_call";

    return roomId;
  }

  static openPlayer(
      {required BuildContext context,
      required String videoId,
      required String videoUrl,
      required String vUploadType,
      required String videoThumb,
      required double stoptime,
      required bool iscontinueWatching,
      required bool isDownloadVideo}) {
    if (kIsWeb) {
      /* Normal, Vimeo & Youtube Player */
      if (!context.mounted) return;
      if (vUploadType == "youtube") {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => PlayerYoutube(
                videoId,
                videoUrl,
                vUploadType,
                videoThumb,
                stoptime,
                iscontinueWatching),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else if (vUploadType == "external") {
        if (videoUrl.contains('youtube')) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => PlayerYoutube(
                  videoId,
                  videoUrl,
                  vUploadType,
                  videoThumb,
                  stoptime,
                  iscontinueWatching),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => PlayerVideo(
                videoId: videoId,
                stoptime: stoptime,
                videoUrl: videoUrl,
                vUploadType: vUploadType,
                videoThumb: videoThumb,
                iscontinueWatching: iscontinueWatching,
                isDownloadVideo: isDownloadVideo,
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      } else {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => PlayerVideo(
              videoId: videoId,
              stoptime: stoptime,
              videoUrl: videoUrl,
              vUploadType: vUploadType,
              videoThumb: videoThumb,
              iscontinueWatching: iscontinueWatching,
              isDownloadVideo: isDownloadVideo,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    } else {
      /* Better, Youtube & Vimeo Players */
      if (vUploadType == "youtube") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerYoutube(videoId, videoUrl, vUploadType, videoThumb,
                  stoptime, iscontinueWatching);
            },
          ),
        );
      } else if (vUploadType == "vimeo") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerVimeo(videoId, videoUrl, vUploadType, videoThumb);
            },
          ),
        );
      } else if (vUploadType == "external") {
        if (videoUrl.contains('youtube')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerYoutube(videoId, videoUrl, vUploadType, videoThumb,
                    stoptime, iscontinueWatching);
              },
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerVideo(
                  videoId: videoId,
                  stoptime: stoptime,
                  videoUrl: videoUrl,
                  vUploadType: vUploadType,
                  videoThumb: videoThumb,
                  iscontinueWatching: iscontinueWatching,
                  isDownloadVideo: isDownloadVideo,
                );
              },
            ),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerVideo(
                videoId: videoId,
                stoptime: stoptime,
                videoUrl: videoUrl,
                vUploadType: vUploadType,
                videoThumb: videoThumb,
                iscontinueWatching: iscontinueWatching,
                isDownloadVideo: isDownloadVideo,
              );
            },
          ),
        );
      }
    }
  }

  static jumpToLive(
      {required BuildContext context,
      required isHost,
      required userId,
      String? isFake,
      String? userImage,
      String? userName,
      String? videoUrl,
      String? name,
      String? roomId}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return LiveStream(
            isFake: isFake,
            userId: userId,
            roomId: roomId,
            videoUrl: videoUrl,
            image: userImage,
            name: name,
            userName: userName,
            isHost: isHost,
          );
        },
      ),
    );
  }

  static Widget buildBackBtnDesign(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: backIcon(),
    );
  }

  Widget circleIconWithButton({
    String? icon,
    onTap,
    double? circleSize,
    double? iconSize,
    Color? color,
    Color? iconColor,
    BoxBorder? border,
    EdgeInsetsGeometry? padding,
    Function(LongPressStartDetails)? onLongPressStart,
    Function(LongPressEndDetails)? onLongPressEnd,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      onLongPress: () {},
      onLongPressEnd: onLongPressEnd,
      child: Container(
        height: circleSize ?? 42,
        width: circleSize ?? 42,
        padding: padding,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: buttonDisable, border: border),
        child: Center(
          child: LiveStreamImage(
            width: iconSize ?? 60,
            height: iconSize ?? 60,
            imagePath: icon ?? "",
            color: iconColor,
          ),
        ),
      ),
    );
  }

  static Widget buildMusicPanel(context) {
    return ValueListenableBuilder(
      valueListenable: currentlyPlaying,
      builder: (BuildContext context, AudioPlayer? audioObject, Widget? child) {
        if (audioObject?.audioSource != null) {
          return MusicDetails(
            ishomepage: false,
            contentid:
                ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.album)
                    .toString(),
            episodeid:
                ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.id)
                    .toString(),
            stoptime: audioPlayer.position.toString(),
            contenttype:
                ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.genre)
                    .toString(),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  static void getCurrencySymbol() async {
    SharedPre sharedPref = SharedPre();
    Constant.currencySymbol = await sharedPref.read("currency_code") ?? "";
    printLog('Constant currencySymbol ==> ${Constant.currencySymbol}');
    Constant.currency = await sharedPref.read("currency") ?? "";
    printLog('Constant currency ==> ${Constant.currency}');
  }

  static Widget buildGradLine() {
    return Container(
      height: 0.5,
      decoration: Utils.setGradTTBBGWithBorder(
          colorPrimaryDark.withOpacity(0.4),
          colorPrimary.withOpacity(0.4),
          transparent,
          0,
          0),
    );
  }

  static Widget moreFunctionItem(icon, title, onTap) {
    return ListTile(
      iconColor: white,
      textColor: white,
      title: MyText(
        color: white,
        text: title,
        fontwaight: FontWeight.w500,
        fontsizeNormal: Dimens.textTitle,
        maxline: 1,
        multilanguage: true,
        overflow: TextOverflow.ellipsis,
        textalign: TextAlign.left,
        fontstyle: FontStyle.normal,
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: white,
        ),
        child: MyImage(
          width: 20,
          height: 20,
          imagePath: icon,
          color: colorPrimary,
        ),
      ),
      onTap: onTap,
    );
  }

  static BoxDecoration setBGWithRadius(
      Color colorBg,
      double radiusTopLeft,
      double radiusTopRight,
      double radiusBottomLeft,
      double radiusBottomRight) {
    return BoxDecoration(
      color: colorBg,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radiusTopLeft),
        topRight: Radius.circular(radiusTopRight),
        bottomLeft: Radius.circular(radiusBottomLeft),
        bottomRight: Radius.circular(radiusBottomRight),
      ),
      shape: BoxShape.rectangle,
    );
  }

  static double getPercentage(int totalValue, int usedValue) {
    double percentage = 0.0;
    try {
      if (totalValue != 0) {
        percentage = ((usedValue / totalValue).clamp(0.0, 1.0) * 100);
      } else {
        percentage = 0.0;
      }
    } catch (e) {
      printLog("getPercentage Exception ==> $e");
      percentage = 0.0;
    }
    percentage = (percentage.round() / 100);
    return percentage;
  }

  static String generateRandomOrderID() {
    int getRandomNumber;
    String? finalOID;
    printLog("fixFourDigit =>>> ${Constant.fixFourDigit}");
    printLog("fixSixDigit =>>> ${Constant.fixSixDigit}");

    number.Random r = number.Random();
    int ran5thDigit = r.nextInt(9);
    printLog("Random ran5thDigit =>>> $ran5thDigit");

    int randomNumber = number.Random().nextInt(9999999);
    printLog("Random randomNumber =>>> $randomNumber");
    if (randomNumber < 0) {
      randomNumber = -randomNumber;
    }
    getRandomNumber = randomNumber;
    printLog("getRandomNumber =>>> $getRandomNumber");

    finalOID = "${Constant.fixFourDigit.toInt()}"
        "$ran5thDigit"
        "${Constant.fixSixDigit.toInt()}"
        "$getRandomNumber";
    printLog("finalOID =>>> $finalOID");

    return finalOID;
  }

  static AppBar myAppBarWithBack(
      BuildContext context, String appBarTitle, bool multilanguage) {
    return AppBar(
      elevation: 5,
      backgroundColor: appbgcolor,
      centerTitle: true,
      leading: IconButton(
        autofocus: true,
        focusColor: white.withOpacity(0.5),
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Utils.backIcon(),
      ),
      title: MyText(
        text: appBarTitle,
        multilanguage: multilanguage,
        fontsizeNormal: Dimens.textBig,
        fontstyle: FontStyle.normal,
        fontwaight: FontWeight.bold,
        textalign: TextAlign.center,
        color: white,
      ),
    );
  }

  static BoxDecoration setBackground(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static Future<void> shareApp(shareMessage) async {
    try {
      await Share.share(
        shareMessage.toString(),
        subject: Constant.appName,
      );
    } catch (e) {
      printLog("shareFile Exception ===> $e");
      return;
    }
  }

  static moveToDetail(BuildContext context, int stopTime,
      bool isContinueWatching, String videoId, isPushReplacement, contentType,
      [int? isComment]) async {
    final detailsProvider =
        Provider.of<DetailsProvider>(context, listen: false);
    await detailsProvider.setLoading(true);
    if (!context.mounted) return;

    if (isPushReplacement == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Detail(
              stoptime: stopTime,
              iscontinueWatching: isContinueWatching,
              videoid: videoId,
              isComment: isComment!,
              contentType: contentType,
            );
          },
        ),
      );
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => Detail(
            stoptime: stopTime,
            iscontinueWatching: isContinueWatching,
            videoid: videoId,
            isComment: isComment ?? 0,
            contentType: contentType,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeInOut;

            var slideTween =
                Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .chain(CurveTween(curve: curve));
            var fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: curve));

            // Apply both animations using SlideTransition and FadeTransition
            return Constant.userID != null
                ? SlideTransition(
                    position: animation.drive(slideTween),
                    child: FadeTransition(
                      opacity: animation.drive(fadeTween),
                      child: child,
                    ),
                  )
                : child;
          },
          transitionDuration:
              const Duration(milliseconds: 500), // Smooth transition speed
        ),
      );
    }
  }

  static Future<File?> saveAudioInStorage(audioUrl, audioTitle) async {
    try {
      var response = await http.get(Uri.parse(audioUrl));
      Directory? documentDirectory;
      if (Platform.isAndroid) {
        documentDirectory = await getExternalStorageDirectory();
      } else {
        documentDirectory = await getApplicationDocumentsDirectory();
      }
      File file = File(join(documentDirectory?.path ?? "",
          '${audioTitle.toString().replaceAll(" ", "").toLowerCase()}.aac'));
      file.writeAsBytesSync(response.bodyBytes);
      printLog("saveAudioInStorage file ===> ${file.path}");
      Fluttertoast.showToast(
        msg: "Download Success",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: white,
        textColor: black,
        fontSize: 14,
      );
      return file;
    } catch (e) {
      printLog("saveAudioInStorage Exception ===> $e");
      return null;
    }
  }

  static BoxDecoration setBGWithBorder(
      Color colorBg, Color colorBorder, double radius, double borderWidth) {
    return BoxDecoration(
      color: colorBg,
      border: Border.all(
        color: colorBorder,
        width: borderWidth,
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static Future<Uint8List?> generateThumbnails(videoUrl) async {
    final data = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 400, // specify the width of the thumbnail
      quality: 75, // specify the quality of the thumbnail
    );

    // Check if data is null or empty
    if (data == null || data.isEmpty) {
      throw Exception('No thumbnail data generated');
    }

    return data;
  }

  Future<void> showAlertSimple(
      BuildContext context, String msg, String positive) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(15),
          content: MyText(
            multilanguage: true,
            color: black,
            text: msg,
            fontsizeNormal: 16,
            fontwaight: FontWeight.w500,
            maxline: 5,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.start,
            fontstyle: FontStyle.normal,
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                foregroundColor: white,
                backgroundColor: appbgcolor, // foreground
              ),
              child: MyText(
                multilanguage: true,
                color: black,
                text: positive,
                fontsizeNormal: 15,
                fontwaight: FontWeight.w600,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
              ),
              onPressed: () {
                printLog("Clicked on positive!");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  /* Globel Variable  */
  static String countryCode = "", countryName = "";

  static Widget dataUpdateDialog(
    BuildContext context, {
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController mobileController,
  }) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        padding: const EdgeInsets.all(23),
        color: colorPrimaryDark,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /* Title & Subtitle */
            Container(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    color: white,
                    text: "updateprofile",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: Dimens.textTitle,
                    fontwaight: FontWeight.w700,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 3),
                  MyText(
                    color: white,
                    text: "editpersonaldetail",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: Dimens.textSmall,
                    fontwaight: FontWeight.w500,
                    maxline: 3,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  )
                ],
              ),
            ),

            /* Fullname */
            const SizedBox(height: 30),
            if (isNameReq)
              _buildTextFormField(
                isMobileNumber: false,
                controller: nameController,
                hintText: "full_name",
                inputType: TextInputType.name,
                readOnly: false,
              ),

            /* Email */
            if (isEmailReq)
              _buildTextFormField(
                isMobileNumber: false,
                controller: emailController,
                hintText: "email_address",
                inputType: TextInputType.emailAddress,
                readOnly: false,
              ),

            /* Mobile */
            if (isMobileReq)
              _buildTextFormField(
                isMobileNumber: true,
                controller: mobileController,
                hintText: "mobile_number",
                inputType: const TextInputType.numberWithOptions(
                    signed: false, decimal: false),
                readOnly: false,
              ),
            const SizedBox(height: 5),

            /* Cancel & Update Buttons */
            Container(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* Cancel */
                  InkWell(
                    onTap: () {
                      final profileEditProvider =
                          Provider.of<ProfileProvider>(context, listen: false);
                      if (!profileEditProvider.loadingUpdate) {
                        Navigator.pop(context, false);
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 75),
                      height: 50,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: white,
                          width: .5,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: MyText(
                        color: white,
                        text: "cancel",
                        multilanguage: true,
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textTitle,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontwaight: FontWeight.w500,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  /* Submit */
                  Consumer<ProfileProvider>(
                    builder: (context, profileEditProvider, child) {
                      if (profileEditProvider.loadingUpdate) {
                        return Container(
                          width: 100,
                          height: 50,
                          padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                          alignment: Alignment.center,
                          child: pageLoader(context),
                        );
                      }
                      return InkWell(
                        onTap: () async {
                          // SharedPre sharedPref = SharedPre();
                          final fullName =
                              nameController.text.toString().trim();
                          final emailAddress =
                              emailController.text.toString().trim();
                          final mobileNumber =
                              mobileController.text.toString().trim();

                          printLog(
                              "fullName =======> $fullName ; required ========> $isNameReq");
                          printLog(
                              "emailAddress ===> $emailAddress ; required ====> $isEmailReq");
                          printLog(
                              "mobileNumber ===> $mobileNumber ; required ====> $isMobileReq");
                          if (isNameReq && fullName.isEmpty) {
                            Utils()
                                .showSnackBar(context, "enter_fullname", true);
                          } else if (isEmailReq && emailAddress.isEmpty) {
                            Utils().showSnackBar(context, "enter_email", true);
                          } else if (isMobileReq && mobileNumber.isEmpty) {
                            Utils().showSnackBar(
                                context, "enter_mobile_number", true);
                          } else if (isEmailReq &&
                              !EmailValidator.validate(emailAddress)) {
                            Utils().showSnackBar(
                                context, "enter_valid_email", true);
                          } else {
                            final profileEditProvider =
                                Provider.of<ProfileProvider>(context,
                                    listen: false);
                            await profileEditProvider.setUpdateLoading(true);

                            await profileEditProvider.getUpdateDataForPayment(
                                fullName,
                                emailAddress,
                                mobileNumber,
                                countryCode,
                                countryName);
                            if (!profileEditProvider.loadingUpdate) {
                              await profileEditProvider.setUpdateLoading(false);
                              if (!context.mounted) return;
                              await profileEditProvider.getprofile(
                                  context, Constant.userID);
                              if (profileEditProvider.successModel.status ==
                                  200) {
                                SharedPre sharedPre = SharedPre();

                                if (isNameReq) {
                                  await sharedPre.save('fullname', fullName);
                                }
                                if (isEmailReq) {
                                  await sharedPre.save('email', emailAddress);
                                }
                                if (isMobileReq) {
                                  await sharedPre.save(
                                      'mobilenumber', mobileNumber);
                                }
                                print(sharedPre.read("fullname"));
                                print(sharedPre.read("email"));
                                print(sharedPre.read("mobilenumber"));
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              } else if (profileEditProvider
                                      .successModel.status !=
                                  200) {
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                                Utils().showSnackBar(
                                    context,
                                    profileEditProvider.successModel.message ??
                                        'Your Enter details is wrong',
                                    false);
                              }
                            }
                          }
                        },
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 75),
                          height: 50,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(5),
                            shape: BoxShape.rectangle,
                          ),
                          child: MyText(
                            color: white,
                            text: "submit",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textTitle,
                            multilanguage: true,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontwaight: FontWeight.w700,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget titleText(text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11, top: 20),
      child: MyText(
        text: text,
        color: white,
        fontsizeNormal: 15.8,
        fontwaight: FontWeight.w600,
      ),
    );
  }

  Widget myTextField(
      controller, textInputAction, keyboardType, labletext, readonly,
      {onTap}) {
    return TextFormField(
      readOnly: readonly,
      textAlign: TextAlign.left,
      obscureText: false,
      keyboardType: keyboardType,
      controller: controller,
      textInputAction: textInputAction,
      cursorColor: white,
      onTap: onTap,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      style: GoogleFonts.montserrat(
          fontSize: 14,
          fontStyle: FontStyle.normal,
          color: white,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        filled: true,
        fillColor: buttonDisable,
        hintText: labletext,
        hintStyle: GoogleFonts.montserrat(
            fontSize: 12.5,
            fontStyle: FontStyle.normal,
            color: white,
            fontWeight: FontWeight.w500),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 11, horizontal: 11),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: transparent),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: transparent),
        ),
      ),
    );
  }

  static Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType inputType,
    required bool readOnly,
    required bool isMobileNumber,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 45),
      margin: const EdgeInsets.only(bottom: 25),
      child: isMobileNumber == true
          ? IntlPhoneField(
              controller: controller,
              keyboardType: inputType,
              textInputAction: TextInputAction.next,
              obscureText: false,
              readOnly: readOnly,
              cursorColor: colorPrimary,
              showCountryFlag: true,
              showDropdownIcon: false,
              cursorRadius: const Radius.circular(2),
              initialCountryCode: Constant.initialCountryCode,
              dropdownTextStyle: Utils.googleFontStyle(4, Dimens.textTitle,
                  FontStyle.normal, white, FontWeight.w500),
              decoration: InputDecoration(
                filled: true,
                isDense: false,
                fillColor: transparent,
                errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: colorPrimary)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: colorPrimary)),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: colorPrimary)),
                disabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: colorPrimary)),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: colorPrimary)),
                label: MyText(
                  multilanguage: true,
                  color: white,
                  text: hintText,
                  textalign: TextAlign.start,
                  fontstyle: FontStyle.normal,
                  fontsizeNormal: Dimens.textMedium,
                  fontwaight: FontWeight.w600,
                ),
              ),
              onChanged: (phone) {
                countryName = phone.countryISOCode;
                countryCode = phone.countryCode;
                printLog('countryNamer==> $countryName');
                printLog('countryISOCode==> $countryCode');
              },
              onCountryChanged: (country) {
                countryName = country.code.replaceAll('+', '');
                countryCode = "+${country.dialCode.toString()}";
                printLog('countryNamer==> $countryName');
                printLog('countryISOCode==> $countryCode');
              },
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              style: GoogleFonts.inter(
                textStyle: TextStyle(
                  fontSize: Dimens.textMedium,
                  color: white,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                ),
              ),
            )
          : TextFormField(
              controller: controller,
              keyboardType: inputType,
              textInputAction: TextInputAction.next,
              obscureText: false,
              maxLines: 1,
              readOnly: readOnly,
              cursorColor: colorPrimary,
              cursorRadius: const Radius.circular(2),
              decoration: InputDecoration(
                filled: true,
                isDense: false,
                fillColor: transparent,
                errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: colorPrimary)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: colorPrimary)),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: colorPrimary)),
                disabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: colorPrimary)),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: colorPrimary)),
                label: MyText(
                  multilanguage: true,
                  color: white,
                  text: hintText,
                  textalign: TextAlign.start,
                  fontstyle: FontStyle.normal,
                  fontsizeNormal: Dimens.textMedium,
                  fontwaight: FontWeight.w600,
                ),
              ),
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              style: GoogleFonts.inter(
                textStyle: TextStyle(
                  fontSize: 14,
                  color: white,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
    );
  }

  conformDialog(BuildContext context, VoidCallback onTapYes, String label,
      VoidCallback onTapNo) {
    return showDialog(
        context: context,
        barrierColor: transparent,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            insetPadding: const EdgeInsets.fromLTRB(50, 25, 50, 25),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            backgroundColor: colorPrimaryDark,
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(
                minWidth: 230,
                maxWidth: 375,
                minHeight: 130,
                maxHeight: 175,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MyText(
                    color: white,
                    text: label,
                    multilanguage: true,
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textTitle,
                    fontsizeWeb: Dimens.textTitle,
                    fontwaight: FontWeight.w500,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          hoverColor: colorPrimary,
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            onTapNo();
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                            margin: const EdgeInsets.all(1),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: buttonDisable,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: MyText(
                              color: white,
                              text: "no",
                              multilanguage: true,
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textDesc,
                              fontsizeWeb: Dimens.textDesc,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontwaight: FontWeight.w500,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          hoverColor: colorPrimary,
                          onTap: () {
                            Navigator.pop(context);
                            onTapYes();
                          },
                          child: Container(
                            margin: const EdgeInsets.all(1),
                            padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: buttonDisable,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: MyText(
                              color: white,
                              text: "yes",
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textDesc,
                              fontsizeWeb: Dimens.textDesc,
                              multilanguage: true,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontwaight: FontWeight.w500,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  static Widget miniPlayerSpace() {
    return Container(
      height: 60,
    );
  }

  /* Google AdMob Methods Start */
  static Widget showBannerAd(BuildContext context) {
    if (!kIsWeb) {
      return Container(
        constraints: BoxConstraints(
          minHeight: 0,
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: AdHelper.bannerAd(context),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  static loadAds(BuildContext context) async {
    if (context.mounted) {
      AdHelper.getAds(context);
      getCustomAdsStatus();
    }
    if (!kIsWeb &&
        (((Constant.isAdsFree != "1") ||
            (Constant.isAdsFree == null) ||
            (Constant.isAdsFree == "")))) {
      AdHelper.createInterstitialAd();
      AdHelper.createRewardedAd();
    }
  }

/* Google AdMob Methods End */

  static musicAndAdsPanel(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: buildMusicPanel(context)),
          CustomAds(adType: Constant.bannerAdType),
          showBannerAd(context),
        ],
      ),
    );
  }

  static lanchAdsLink(loadingUrl) async {
    final JSHelper jsHelper = JSHelper();
    printLog("loadingUrl -----------> $loadingUrl");
    /*
      _blank => open new Tab
      _self => open in current Tab
    */
    String dataFromJS = await jsHelper.callOpenTab(loadingUrl, '_blank');
    printLog("dataFromJS -----------> $dataFromJS");
  }

  static Future<void> lanchAdsUrl(String url) async {
    printLog("_launchUrl url ===> $url");
    if (await canLaunchUrl(Uri.parse(url.toString()))) {
      await launchUrl(
        Uri.parse(url.toString()),
        mode: LaunchMode.platformDefault,
      );
    } else {
      throw "Could not launch $url";
    }
  }

  static Widget buildBackBtn(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      focusColor: gray.withOpacity(0.5),
      onTap: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Utils.backIcon(),
      ),
    );
  }

  static Future<void> clearUserCreds() async {
    SharedPre sharedPref = SharedPre();

    await sharedPref.remove("userid");
    await sharedPref.remove("channelid");
    await sharedPref.remove("channelname");
    await sharedPref.remove("fullname");
    await sharedPref.remove("email");
    await sharedPref.remove("mobilenumber");
    await sharedPref.remove("countrycode");
    await sharedPref.remove("countryname");
    await sharedPref.remove("image");
    await sharedPref.remove("coverimage");
    await sharedPref.remove("devicetype");
    await sharedPref.remove("devicetoken");
    await sharedPref.remove("userIsBuy");
    await sharedPref.remove("isAdsFree");
    await sharedPref.remove("isDownload");
    await sharedPref.remove("isCreator");
    await sharedPref.remove("subscriptionPlan");
    await sharedPref.remove("walletBalance");

    // ALSO CLEAR CONSTANTS IN MEMORY
    Constant.userID = null;
    Constant.userName = null;
    Constant.isCreator = null;
    Constant.isAdsFree = null;
    Constant.isDownload = null;
    Constant.channelID = null;
    Constant.userImage = null;
    Constant.isBuy = null;
    Constant.subscriptionPlan = null;
    Constant.walletBalance = null;
  }

  static saveUserCreds(
      {required userID,
      required channeId,
      required channelName,
      required fullName,
      required email,
      required mobileNumber,
      required countrycode,
      required countryname,
      required image,
      required coverImg,
      required deviceType,
      required deviceToken,
      required userIsBuy,
      required isAdsFree,
      required isDownload,
      required walletBalance,
      subscriptionPlan,
      required isCreator}) async {
    SharedPre sharedPref = SharedPre();
    if (userID != null) {
      await sharedPref.save("userid", userID);
      await sharedPref.save("channelid", channeId);
      await sharedPref.save("channelname", channelName);
      await sharedPref.save("fullname", fullName);
      await sharedPref.save("email", email);
      await sharedPref.save("mobilenumber", mobileNumber);
      await sharedPref.save("countrycode", countrycode);
      await sharedPref.save("countryname", countryname);
      await sharedPref.save("image", image);
      await sharedPref.save("coverimage", coverImg);
      await sharedPref.save("devicetype", deviceType);
      await sharedPref.save("devicetoken", deviceToken);
      await sharedPref.save("userIsBuy", userIsBuy);
      await sharedPref.save("isAdsFree", isAdsFree);
      await sharedPref.save("isDownload", isDownload);
      await sharedPref.save("isCreator", isCreator);
      await sharedPref.save("subscriptionPlan", subscriptionPlan);
      await sharedPref.save("walletBalance", walletBalance);
    } else {
      await sharedPref.remove("userid");
      await sharedPref.remove("channelid");
      await sharedPref.remove("channelname");
      await sharedPref.remove("fullname");
      await sharedPref.remove("email");
      await sharedPref.remove("mobilenumber");
      await sharedPref.remove("countrycode");
      await sharedPref.remove("countryname");
      await sharedPref.remove("image");
      await sharedPref.remove("coverimage");
      await sharedPref.remove("devicetype");
      await sharedPref.remove("devicetoken");
      await sharedPref.remove("userIsBuy");
      await sharedPref.remove("isAdsFree");
      await sharedPref.remove("isDownload");
      await sharedPref.remove("isCreator");
      await sharedPref.save("subscriptionPlan", subscriptionPlan);
      await sharedPref.remove("walletBalance");
    }

    Constant.userID = await sharedPref.read("userid");
    Constant.userName = await sharedPref.read("fullname");
    Constant.isCreator = await sharedPref.read("isCreator");
    Constant.isAdsFree = await sharedPref.read("isAdsFree");
    Constant.isDownload = await sharedPref.read("isDownload");
    Constant.channelID = await sharedPref.read("channelid");
    Constant.userImage = await sharedPref.read("image");
    Constant.isBuy = await sharedPref.read("userIsBuy");
    Constant.subscriptionPlan = await sharedPref.read("subscriptionPlan");
    Constant.walletBalance = await sharedPref.read("walletBalance");

    printLog('setUserId userID ==> ${Constant.userID}');
    printLog('setUserId isAdsfree ==> ${Constant.isAdsFree}');
    printLog('setUserId isDownload ==> ${Constant.isDownload}');
    printLog('setUserId channelID ==> ${Constant.channelID}');
    printLog('setUserId userImage ==> ${Constant.userImage}');
    printLog('setUserId isBuy ==> ${Constant.isBuy}');
    printLog('setUserId subscriptionPlan ==> ${Constant.subscriptionPlan}');
    printLog('setUserId walletBalance ==> ${Constant.walletBalance}');
  }

  static setUserId(userID) async {
    SharedPre sharedPref = SharedPre();
    if (userID != null) {
      await sharedPref.save("userid", userID);
    } else {
      await sharedPref.remove("userid");
      await sharedPref.remove("channelid");
      await sharedPref.remove("channelname");
      await sharedPref.remove("fullname");
      await sharedPref.remove("email");
      await sharedPref.remove("mobilenumber");
      await sharedPref.remove("countrycode");
      await sharedPref.remove("countryname");
      await sharedPref.remove("image");
      await sharedPref.remove("coverimage");
      await sharedPref.remove("devicetype");
      await sharedPref.remove("devicetoken");
      await sharedPref.remove("userIsBuy");
      await sharedPref.remove("isAdsFree");
      await sharedPref.remove("isDownload");
      await sharedPref.remove("isCreator");
    }
    Constant.userID = await sharedPref.read("userid");

    printLog('setUserId userID ==> ${Constant.userID}');
  }

  static saveLiveStreamARKey() async {
    SharedPre sharedPref = SharedPre();
    /* Live Streaming Field */
    String? liveAppID, liveAppSign, liveServerSecret, isFake;
    liveAppID = await sharedPref.read("live_appid");
    liveAppSign = await sharedPref.read("live_appsign");
    liveServerSecret = await sharedPref.read("live_serversecret");
    isFake = await sharedPref.read("is_live_streaming_fake");
    /* Deep AR Field */
    String? androidLicenseKey, iosLicenseKey;
    androidLicenseKey = await sharedPref.read("deepar_android_key");
    iosLicenseKey = await sharedPref.read("deepar_ios_key");

    /* ============================ LiveStream Start ============================ */
    if (isFake != null) {
      Constant.isFake = isFake;
      printLog("isFake :=========> ${Constant.isFake}");
    }

    if (liveAppID != null) {
      Constant.liveAppId = int.parse(liveAppID);
      printLog("liveAppId :=========> ${Constant.liveAppId}");
    }

    if (liveAppSign != null) {
      Constant.liveAppSign = liveAppSign;
      printLog("liveAppSign :=======> ${Constant.liveAppSign}");
    }

    if (liveServerSecret != null) {
      Constant.liveServerSecret = liveServerSecret;
      printLog("liveServerSecret :==> ${Constant.liveServerSecret}");
    }
    /* ============================ LiveStream End ============================ */

    /* ============================ DeepAr Start ============================ */
    if (androidLicenseKey != null) {
      Constant.effectAndroidLicenseKey = androidLicenseKey;
      printLog(
          "effectAndroidLicenseKey :=======> ${Constant.effectAndroidLicenseKey}");
    }

    if (iosLicenseKey != null) {
      Constant.effectIosLicenseKey = iosLicenseKey;
      printLog("effectIosLicenseKey :=======> ${Constant.effectIosLicenseKey}");
    }
    /* ============================ DeepAr End ============================ */
  }

  static Widget backIcon() {
    return Iconify(
      Mdi.keyboard_backspace,
      size: 25,
      color: white,
    );
  }

/*----------------------------------------------------------------- Web Utils Start ------------------------------------------------------------------ */

/* Custom Appbar With SidePanel Start */
  static PreferredSize webAppbarWithSidePanel(
      {required BuildContext context, contentType}) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70.0),
      child:
          Consumer<GeneralProvider>(builder: (context, generalprovider, child) {
        /*generalprovider.isPanel =
            ResponsiveHelper.checkIsWeb(context) ? true : false;*/
        // Load notifications if user is logged in
        if (Constant.userID != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<NotificationProvider>(context, listen: false)
                .getNotification(1);
          });
        }
        return AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: transparent,
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: transparent,
          flexibleSpace: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        hoverColor: colorPrimaryDark,
                        splashColor: colorPrimaryDark,
                        highlightColor: colorPrimaryDark,
                        focusColor: colorPrimaryDark,
                        borderRadius: BorderRadius.circular(50.0),
                        onTap: () {
                          print("Before: ${generalprovider.isPanel}");
                          generalprovider.getOnOffSidePanel();
                          print("After: ${generalprovider.isPanel}");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: MyImage(
                            width: 20,
                            height: 20,
                            imagePath: "ic_menu.png",
                            color: white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Utils().showInterstitalAds(
                              context, Constant.interstialAdType, () async {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        const Feeds(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          });
                        },
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            MyImage(
                              width: 110,
                              height: 45,
                              imagePath: "Fanbae_logo_RGB.png",
                            ),
                            /* MyText(
                                color: white,
                                multilanguage: true,
                                text: Constant.isBuy == "1" ? "premium" : "appname",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textBig,
                                fontsizeWeb: Dimens.textBig,
                                inter: true,
                                maxline: 1,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),*/
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Constant.userID != null
                            ? Consumer<ProfileProvider>(
                                builder: (context, profileProvider, _) {
                                if (profileProvider.profileModel.result?[0].id
                                        .toString() !=
                                    Constant.userID) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 7.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Provider.of<GeneralProvider>(context,
                                              listen: false)
                                          .setCurrentPage("subscription");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return const Subscription();
                                          },
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        MyImage(
                                            width: 40,
                                            height: 30,
                                            fit: BoxFit.cover,
                                            color: Constant.darkMode == "true"
                                                ? colorPrimary
                                                : pureBlack,
                                            imagePath: "crown.png"),
                                        ShaderMask(
                                            shaderCallback: (bounds) =>
                                                LinearGradient(
                                                  colors: [
                                                    Constant.darkMode == "true"
                                                        ? colorPrimary
                                                        : pureBlack,
                                                    Constant.darkMode == "true"
                                                        ? pureWhite
                                                        : gray,
                                                    Constant.darkMode == "true"
                                                        ? colorPrimary
                                                        : pureBlack
                                                  ],
                                                ).createShader(Rect.fromLTWH(
                                                    0,
                                                    0,
                                                    bounds.width,
                                                    bounds.height)),
                                            child: Text(
                                              (() {
                                                final result = profileProvider
                                                    .profileModel.result?[0];
                                                if (result == null ||
                                                    result.isBuy != 1) {
                                                  return 'Subscribe';
                                                }

                                                // Parse expiry date
                                                final expireDate =
                                                    DateTime.tryParse(result
                                                        .expireDate
                                                        .toString());
                                                if (expireDate == null) {
                                                  return 'Subscribe';
                                                }

                                                // Calculate remaining days
                                                final remainingDays = expireDate
                                                    .difference(DateTime.now())
                                                    .inDays;

                                                if (remainingDays <= 7 &&
                                                    remainingDays != 0) {
                                                  return "$remainingDays days left";
                                                } else if (remainingDays == 0) {
                                                  return "Expire Today";
                                                } else {
                                                  return result.packageName ??
                                                      Constant
                                                          .subscriptionPlan ??
                                                      '';
                                                }
                                              })(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                );
                              })
                            : const SizedBox(),
                        Constant.userID != null
                            ? Consumer<ProfileProvider>(
                                builder: (context, profileProvider, _) {
                                if (profileProvider.profileModel.result?[0].id
                                        .toString() !=
                                    Constant.userID) {
                                  return const SizedBox();
                                }
                                return InkWell(
                                  focusColor: transparent,
                                  splashColor: transparent,
                                  highlightColor: transparent,
                                  hoverColor: transparent,
                                  onTap: () {
                                    Provider.of<GeneralProvider>(context,
                                            listen: false)
                                        .setCurrentPage("mywallet");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const AdsPackage();
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 35,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MyImage(
                                            width: 22,
                                            height: 22,
                                            imagePath: "ic_coin.png"),
                                        const SizedBox(width: 5),
                                        MyText(
                                          color: white,
                                          multilanguage: false,
                                          text: Utils.kmbGenerator(
                                            profileProvider.profileModel
                                                    .result?[0].walletBalance ??
                                                0,
                                          ),
                                          textalign: TextAlign.center,
                                          fontsizeNormal: Dimens.textMedium,
                                          inter: true,
                                          maxline: 1,
                                          fontwaight: FontWeight.w700,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              })
                            : const SizedBox(),
                        const SizedBox(width: 5),
                        InkWell(onTap: () async {
                          Utils().showInterstitalAds(
                              context, Constant.interstialAdType, () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          const WebLogin(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            } else {
                              if (generalprovider.isNotification == false) {
                                await generalprovider
                                    .getNotificationSectionShowHide(true);
                              } else {
                                await generalprovider
                                    .getNotificationSectionShowHide(false);
                              }
                            }
                          });
                        }, child: Consumer<NotificationProvider>(
                          builder: (context, notificationProvider, _) {
                            int notificationCount =
                                notificationProvider.notificationList?.length ??
                                    0;
                            return Stack(
                              children: [
                                Icon(
                                  Icons.notifications,
                                  color: notificationCount > 0
                                      ? Colors.amber
                                      : white,
                                  size: 25,
                                ),
                                if (notificationCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        notificationCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        )),
                        MediaQuery.of(context).size.width > 400
                            ? const SizedBox(width: 20)
                            : const SizedBox(width: 15),
                        InkWell(
                          onTap: () {
                            Utils().showInterstitalAds(
                                context, Constant.interstialAdType, () async {
                              if (Constant.userID == null) {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            const WebLogin(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              } else {
                                final profileProvider =
                                    Provider.of<ProfileProvider>(context,
                                        listen: false);
                                profileProvider.clearProvider();
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            WebProfile(
                                      isProfile: true,
                                      channelUserid: Constant.userID.toString(),
                                      channelid: "",
                                    ),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              }
                            });
                          },
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width > 400
                                  ? 30
                                  : 20,
                              height: MediaQuery.of(context).size.width > 400
                                  ? 30
                                  : 20,
                              child: (Constant.userID == null ||
                                      Constant.userImage == "" ||
                                      Constant.userImage == null)
                                  ? MyImage(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      color: colorPrimary,
                                      imagePath: "ic_user.png")
                                  : Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border: Border.all(
                                              width: 0.8, color: colorPrimary)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: MyNetworkImage(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          imagePath: Constant.userImage ?? "",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  static Widget sidePanelWithBody({required Widget myWidget, isProfile}) {
    return Consumer<GeneralProvider>(
        builder: (context, generalprovider, child) {
      return SizedBox(
        height: (html.window.screen?.height as double),
        child: Stack(
          children: [
            Row(
              children: [
                /* Side Panel */
                generalprovider.isPanel == true
                    ? buildOnPanel(context, isProfile)
                    : buildOffPanel(context, isProfile),
                /* All Page Widget */
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // InkWell( // onHover: (value) async { // await generalprovider.clearHover(); // await generalprovider // .getNotificationSectionShowHide(false); // }, // child:
                      Container(
                        alignment: Alignment.topCenter,
                        child: myWidget,
                      ),
                      generalprovider.isNotification == true
                          ? Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                width: MediaQuery.of(context).size.width > 1200
                                    ? 500
                                    : 400,
                                height: 500,
                                margin:
                                    const EdgeInsets.only(left: 20, right: 50),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: colorPrimaryDark),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: const WebNotificationPage(),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
            Utils.buildMusicPanel(context),
          ],
        ),
      );
    });
  }

  static Widget sidePanelWithBody1({required Widget myWidget, isProfile}) {
    return Consumer<GeneralProvider>(
      builder: (context, generalprovider, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        return SizedBox(
          height: (html.window.screen?.height as double),
          child: ResponsiveHelper.isMobile(context)
              ? Stack(
                  children: [
                    // Main content
                    Row(
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Container(
                                alignment: Alignment.topCenter,
                                child: myWidget,
                              ),
                              if (generalprovider.isNotification)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    width: screenWidth > 1200 ? 500 : 400,
                                    height: 500,
                                    margin: const EdgeInsets.only(
                                        left: 20, right: 50),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: colorPrimaryDark,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: const WebNotificationPage(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Music panel
                    Utils.buildMusicPanel(context),

                    // 👉 Drawer + Backdrop wrapper
                    if (generalprovider.isPanel)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            generalprovider.getOnOffSidePanel(); // close drawer
                          },
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),

                    // Drawer itself (always built above backdrop)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      top: 0,
                      bottom: 0,
                      left: generalprovider.isPanel ? 0 : -260,
                      child: Material(
                        elevation: 16,
                        child: Container(
                          width: 250,
                          height: double.infinity,
                          color: colorPrimaryDark,
                          child: buildOnPanel(context, isProfile),
                        ),
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    Row(
                      children: [
                        /* Side Panel */
                        generalprovider.isPanel == true
                            ? buildOnPanel(context, isProfile)
                            : buildOffPanel(context, isProfile),
                        /* All Page Widget */
                        Expanded(
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              // InkWell( // onHover: (value) async { // await generalprovider.clearHover(); // await generalprovider // .getNotificationSectionShowHide(false); // }, // child:
                              Container(
                                alignment: Alignment.topCenter,
                                child: myWidget,
                              ),
                              generalprovider.isNotification == true
                                  ? Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width >
                                                    1200
                                                ? 500
                                                : 400,
                                        height: 500,
                                        margin: const EdgeInsets.only(
                                            left: 20, right: 50),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: colorPrimaryDark),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: const WebNotificationPage(),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Utils.buildMusicPanel(context),
                  ],
                ),
        );
      },
    );
  }

  static Widget buildOnPanel(BuildContext context, isProfile) {
    return Consumer<GeneralProvider>(
        builder: (context, generalprovider, child) {
      return Container(
        width: MediaQuery.of(context).size.width > 1600 ? 250 : 270,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.fromLTRB(15, 5, 15, 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              panelItem("home", "home_web.svg", "home", true, () {
                Provider.of<GeneralProvider>(context, listen: false)
                    .setCurrentPage("home");

                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (ResponsiveHelper.isMobile(context)) {
                    generalprovider.getOnOffSidePanel();
                  }
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const Feeds(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                });
              }),
              panelItem("reels", "shorts_web.svg", "reels", true, () {
                Provider.of<GeneralProvider>(context, listen: false)
                    .setCurrentPage("reels");
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (ResponsiveHelper.isMobile(context)) {
                    generalprovider.getOnOffSidePanel();
                  }
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          ResponsiveHelper.checkIsWeb(context)
                              ? const Shorts(
                                  initialIndex: 0,
                                )
                              : const WebShorts(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                });
              }),
              panelItem("chat", "chat_web.svg", "chat", true, () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    if (ResponsiveHelper.isMobile(context)) {
                      generalprovider.getOnOffSidePanel();
                    }
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("chat");
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const ChatHistoryPage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              }),
              Consumer<ProfileProvider>(
                  builder: (context, profileprovider, child) {
                return panelItem("subscription", "subscription_web.svg",
                    "subscription", true, () async {
                  Utils().showInterstitalAds(context, Constant.interstialAdType,
                      () async {
                    if (Constant.userID == null) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const WebLogin(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    } else {
                      await profileprovider.getprofile(
                          context, Constant.userID.toString());
                      if (!context.mounted) return;
                      Provider.of<GeneralProvider>(context, listen: false)
                          .setCurrentPage("subscription");
                      if (ResponsiveHelper.isMobile(context)) {
                        generalprovider.getOnOffSidePanel();
                      }
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const Subscription(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      ).then((_) {
                        // When user comes back, update current page to "feeds"
                        Provider.of<GeneralProvider>(context, listen: false)
                            .setCurrentPage("subscription");
                      });
                    }
                  });
                });
              }),
              webDivider(context, const EdgeInsets.fromLTRB(0, 10, 0, 10)),
              if (Constant.isCreator == '1')
                panelItem("dashboard", "statistics_web.png", "dashboard", true,
                    () {
                  Utils().showInterstitalAds(context, Constant.interstialAdType,
                      () async {
                    if (Constant.userID == null) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const WebLogin(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    } else {
                      Provider.of<GeneralProvider>(context, listen: false)
                          .setCurrentPage("dashboard");
                      if (ResponsiveHelper.isMobile(context)) {
                        generalprovider.getOnOffSidePanel();
                      }
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const Statistics(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    }
                  });
                }),
              panelItem("history", "history_web.svg", "history", true, () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("history");
                    if (ResponsiveHelper.isMobile(context)) {
                      generalprovider.getOnOffSidePanel();
                    }
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebHistory(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              }),
              Consumer<ProfileProvider>(
                  builder: (context, profileprovider, child) {
                return panelItem("mywallet", "wallet_web.svg", "mywallet", true,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    await profileprovider.getprofile(
                        context, Constant.userID.toString());
                    // ignore: use_build_context_synchronously
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("mywallet");
                    if (ResponsiveHelper.isMobile(context)) {
                      generalprovider.getOnOffSidePanel();
                    }
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            AdsPackage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              }),

              // panelItem("rent", "rent.png", "rent", true, () {
              //   Utils().showInterstitalAds(context, Constant.interstialAdType,
              //       () async {
              //     Navigator.push(
              //       context,
              //       PageRouteBuilder(
              //         pageBuilder: (context, animation1, animation2) =>
              //             const WebRent(),
              //         transitionDuration: Duration.zero,
              //         reverseTransitionDuration: Duration.zero,
              //       ),
              //     );
              //   });
              // }),

              panelItem("ads", "ads_web.svg", "ads", true, () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("ads");
                    if (ResponsiveHelper.isMobile(context)) {
                      generalprovider.getOnOffSidePanel();
                    }
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const ViewAds(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              }),
              panelItem("explore", "explore_web.svg", "explore", true, () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("explore");
                    if (ResponsiveHelper.isMobile(context)) {
                      generalprovider.getOnOffSidePanel();
                    }
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const ExploreChannels(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              }),
              if (Constant.isCreator == '1')
                panelItem("earnings", "earning_web.svg", "earnings", true, () {
                  Utils().showInterstitalAds(context, Constant.interstialAdType,
                      () async {
                    if (Constant.userID == null) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const WebLogin(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    } else {
                      Provider.of<GeneralProvider>(context, listen: false)
                          .setCurrentPage("earnings");
                      if (ResponsiveHelper.isMobile(context)) {
                        generalprovider.getOnOffSidePanel();
                      }
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const Earnings(
                            appBarView: false,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    }
                  });
                }),
              panelItem("following", "following_web.svg", "following", true,
                  () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("following");
                    if (ResponsiveHelper.isMobile(context)) {
                      generalprovider.getOnOffSidePanel();
                    }
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const SubscribedChannel(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              }),
              if (Constant.isCreator == '1')
                panelItem("followers", "followers_web.svg", "followers", true,
                    () {
                  Utils().showInterstitalAds(context, Constant.interstialAdType,
                      () async {
                    if (Constant.userID == null) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const WebLogin(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    } else {
                      Provider.of<GeneralProvider>(context, listen: false)
                          .setCurrentPage("followers");
                      if (ResponsiveHelper.isMobile(context)) {
                        generalprovider.getOnOffSidePanel();
                      }
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const Followers(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    }
                  });
                }),
              panelItem("user_subscribing", "subscriber_web.svg",
                  "user_subscribing", true, () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("user_subscribing");
                    if (ResponsiveHelper.isMobile(context)) {
                      generalprovider.getOnOffSidePanel();
                    }
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const SubscribingChannels(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              }),
              if (Constant.isCreator == '1')
                panelItem(
                    "subscribers", "subscriber2_web.svg", "subscribers", true,
                    () {
                  Utils().showInterstitalAds(context, Constant.interstialAdType,
                      () async {
                    if (Constant.userID == null) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const WebLogin(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    } else {
                      Provider.of<GeneralProvider>(context, listen: false)
                          .setCurrentPage("subscribers");
                      if (ResponsiveHelper.isMobile(context)) {
                        generalprovider.getOnOffSidePanel();
                      }
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const SubscribeChannels(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    }
                  });
                }),
              panelItem(
                  "schedulecall", "schedule_web.svg", "schedulecall", true, () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("schedulecall");
                    if (ResponsiveHelper.isMobile(context)) {
                      generalprovider.getOnOffSidePanel();
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const ScheduleCall(isCreator: true);
                        },
                      ),
                    );
                  }
                });
              }),
              // panelItem("myplaylist", "my_playlist_web.svg", "myplaylist", true,
              //     () {
              //   Utils().showInterstitalAds(context, Constant.interstialAdType,
              //       () async {
              //     if (Constant.userID == null) {
              //       Navigator.push(
              //         context,
              //         PageRouteBuilder(
              //           pageBuilder: (context, animation1, animation2) =>
              //               const WebLogin(),
              //           transitionDuration: Duration.zero,
              //           reverseTransitionDuration: Duration.zero,
              //         ),
              //       );
              //     } else {
              //       Provider.of<GeneralProvider>(context, listen: false)
              //           .setCurrentPage("myplaylist");
              //       if (ResponsiveHelper.isMobile(context)) {
              //         generalprovider.getOnOffSidePanel();
              //       }
              //       Navigator.push(
              //         context,
              //         PageRouteBuilder(
              //           pageBuilder: (context, animation1, animation2) =>
              //               const WebMyPlayList(),
              //           transitionDuration: Duration.zero,
              //           reverseTransitionDuration: Duration.zero,
              //         ),
              //       );
              //     }
              //   });
              // }),
              panelItem("watchlater", "watch_later_web.svg", "watchlater", true,
                  () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("watchlater");
                    if (ResponsiveHelper.isMobile(context)) {
                      generalprovider.getOnOffSidePanel();
                    }
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebWatchLater(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              }),
              panelItem("likevideos", "like_web.svg", "likevideos", true, () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("likevideos");
                    if (ResponsiveHelper.isMobile(context)) {
                      generalprovider.getOnOffSidePanel();
                    }
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLikeVideos(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              }),
              // Consumer<ThemeProvider>(
              //   builder: (context, provider, child) {
              //     return SwitchListTile(
              //       activeColor: colorPrimary,
              //       title: Padding(
              //         padding: const EdgeInsets.only(left: 6.5),
              //         child: MyText(
              //             text: "Dark Mode",
              //             color: white,
              //             multilanguage: false),
              //       ),
              //       value: Constant.darkMode == 'true' ? true : false,
              //       onChanged: (val) {
              //         provider.toggleTheme(val);
              //         Navigator.pushAndRemoveUntil(
              //           context,
              //           MaterialPageRoute(
              //               builder: (_) => ResponsiveHelper.checkIsWeb(context)
              //                   ? const Feeds()
              //                   : const Bottombar()),
              //           (Route<dynamic> route) => false,
              //         );
              //       },
              //     );
              //   },
              // ),
              webDivider(context, const EdgeInsets.fromLTRB(0, 10, 0, 10)),
              /*Constant.userID == null
                ? const SizedBox.shrink()
                : panelItem("userpanel", "userpanel.png", "userpanel", true,
                    () {
                   */ /* Utils().showInterstitalAds(
                        context, Constant.interstialAdType, () async {
                      userPanelActiveDilog(context);
                    });*/ /*
                      html.window.open('https://Fanbae.tv/admin_panel/public/user/login', '_blank');
                  }),*/
              panelItem(
                  "chooselanguage", "language_web.svg", "chooselanguage", true,
                  () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (ResponsiveHelper.isMobile(context)) {
                    generalprovider.getOnOffSidePanel();
                  }
                  _languageChangeDialog(context);
                });
              }),
              panelItem("login_logout", "logout_web.svg",
                  Constant.userID != null ? "logout" : "login", true, () {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  if (ResponsiveHelper.isMobile(context)) {
                    generalprovider.getOnOffSidePanel();
                  }
                  logoutdilog(context, isProfile);
                }
              }),
              panelItem(
                  "deleteaccount", "ic_delete_web.svg", 'deleteaccount', true,
                  () {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  if (ResponsiveHelper.isMobile(context)) {
                    generalprovider.getOnOffSidePanel();
                  }
                  deleteConfirmDialog(context);
                }
              }),
              webDivider(context, const EdgeInsets.fromLTRB(0, 10, 0, 10)),
              buildWebGetPages(),
              buildWebSocialLink(),
            ],
          ),
        ),
      );
    });
  }

  static deleteConfirmDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              color: colorPrimaryDark,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "deleteaccount",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: Dimens.textTitle,
                          fontwaight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        MyText(
                          color: white,
                          text: "are_you_sure_want_to_delete_account?",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: Dimens.textSmall,
                          fontwaight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDialogBtn(
                          title: 'cancel',
                          isPositive: false,
                          isMultilang: true,
                          onClick: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildDialogBtn(
                          title: 'deleteaccount',
                          isPositive: true,
                          isMultilang: true,
                          onClick: () async {
                            final profileProvider =
                                Provider.of<ProfileProvider>(context,
                                    listen: false);
                            try {
                              await Provider.of<SettingProvider>(context,
                                      listen: false)
                                  .deleteAccount(Constant.userID);

                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(Constant.userID.toString())
                                  .delete();

                              // (Optional) Realtime DB if you use it
                              // await FirebaseDatabase.instance.ref("users/${Constant.userID}").remove();

                              final googleSignIn = GoogleSignIn();
                              if (await googleSignIn.isSignedIn()) {
                                await googleSignIn.signOut();
                              }

                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.clear();
                              await profileProvider.clearProvider();
                              Constant.userID = null;

                              audioPlayer.stop();
                              audioPlayer.pause();

                              if (!context.mounted) return;

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ResponsiveHelper.isWeb(context)
                                            ? const WebLogin()
                                            : const Login()),
                                (route) => false,
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              print("Delete account error: $e");
                              Utils().showSnackBar(context,
                                  "Failed to delete account: $e", false);
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildDialogBtn({
    required String title,
    required bool isPositive,
    required bool isMultilang,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Container(
        constraints: const BoxConstraints(minWidth: 75),
        height: 50,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: isPositive ? colorPrimary : transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 0.5, color: white)),
        child: MyText(
          color: isPositive ? colorAccent : white,
          text: title,
          multilanguage: isMultilang,
          textalign: TextAlign.center,
          fontsizeNormal: Dimens.textTitle,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontwaight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  static Widget buildOffPanel(BuildContext context, isProfile) {
    return Container(
      width: 70,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            panelItem("home", "home_web.svg", "home", true, () {
              Provider.of<GeneralProvider>(context, listen: false)
                  .setCurrentPage("home");
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const Feeds(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              });
            }),
            panelItem("reels", "shorts_web.svg", "reels", true, () {
              Provider.of<GeneralProvider>(context, listen: false)
                  .setCurrentPage("reels");
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        ResponsiveHelper.checkIsWeb(context)
                            ? const Shorts(
                                initialIndex: 0,
                              )
                            : const WebShorts(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              });
            }),
            panelItem("chat", "chat_web.svg", "chat", true, () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  Provider.of<GeneralProvider>(context, listen: false)
                      .setCurrentPage("chat");
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const ChatHistoryPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              });
            }),
            Consumer<ProfileProvider>(
                builder: (context, profileprovider, child) {
              return panelItem(
                  "subscription", "subscription_web.svg", "subscription", true,
                  () async {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    await profileprovider.getprofile(
                        context, Constant.userID.toString());
                    if (!context.mounted) return;
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("subscription");
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const Subscription(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              });
            }),
            webDivider(context, const EdgeInsets.fromLTRB(0, 10, 0, 10)),
            if (Constant.isCreator == '1')
              panelItem("dashboard", "statistics_web.png", "dashboard", true,
                  () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("dashboard");

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const Statistics(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              }),
            panelItem("history", "history_web.svg", "history", true, () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  Provider.of<GeneralProvider>(context, listen: false)
                      .setCurrentPage("history");

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebHistory(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              });
            }),
            Consumer<ProfileProvider>(
                builder: (context, profileprovider, child) {
              return panelItem("mywallet", "wallet_web.svg", "mywallet", true,
                  () async {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  await profileprovider.getprofile(
                      context, Constant.userID.toString());
                  // ignore: use_build_context_synchronously
                  Provider.of<GeneralProvider>(context, listen: false)
                      .setCurrentPage("mywallet");

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          AdsPackage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              });
            }),
            /*panelItem("rent", "rent.png", "rent", true, () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const WebRent(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              });
            }),*/
            panelItem("ads", "ads_web.svg", "ads", true, () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  Provider.of<GeneralProvider>(context, listen: false)
                      .setCurrentPage("ads");
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const ViewAds(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              });
            }),
            panelItem("explore", "explore_web.svg", "explore", true, () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  Provider.of<GeneralProvider>(context, listen: false)
                      .setCurrentPage("explore");
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const ExploreChannels(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              });
            }),
            if (Constant.isCreator == '1')
              panelItem("earnings", "earning_web.svg", "earnings", true, () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("earnings");

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const Earnings(
                          appBarView: false,
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              }),
            panelItem("following", "following_web.svg", "following", true, () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  Provider.of<GeneralProvider>(context, listen: false)
                      .setCurrentPage("following");

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const SubscribedChannel(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              });
            }),
            if (Constant.isCreator == '1')
              panelItem("followers", "followers_web.svg", "followers", true,
                  () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("followers");
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const Followers(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              }),
            panelItem("user_subscribing", "subscriber_web.svg",
                "user_subscribing", true, () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  Provider.of<GeneralProvider>(context, listen: false)
                      .setCurrentPage("user_subscribing");

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const SubscribingChannels(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              });
            }),
            if (Constant.isCreator == '1')
              panelItem(
                  "subscribers", "subscriber2_web.png", "subscribers", true,
                  () {
                Utils().showInterstitalAds(context, Constant.interstialAdType,
                    () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    Provider.of<GeneralProvider>(context, listen: false)
                        .setCurrentPage("subscribers");

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const SubscribeChannels(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                });
              }),
            panelItem("schedulecall", "schedule_web.svg", "schedulecall", true,
                () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  Provider.of<GeneralProvider>(context, listen: false)
                      .setCurrentPage("schedulecall");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const ScheduleCall(isCreator: true);
                      },
                    ),
                  );
                }
              });
            }),
            /* panelItem("subscriber", "ic_subscriber.png", "subscriber", true,
                () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  Provider.of<GeneralProvider>(context, listen: false)
                      .setCurrentPage("subscriber");

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebSubscribedChannel(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              });
            }),*/
            // panelItem("myplaylist", "my_playlist_web.svg", "myplaylist", true,
            //     () {
            //   Utils().showInterstitalAds(context, Constant.interstialAdType,
            //       () async {
            //     if (Constant.userID == null) {
            //       Navigator.push(
            //         context,
            //         PageRouteBuilder(
            //           pageBuilder: (context, animation1, animation2) =>
            //               const WebLogin(),
            //           transitionDuration: Duration.zero,
            //           reverseTransitionDuration: Duration.zero,
            //         ),
            //       );
            //     } else {
            //       Provider.of<GeneralProvider>(context, listen: false)
            //           .setCurrentPage("myplaylist");

            //       Navigator.push(
            //         context,
            //         PageRouteBuilder(
            //           pageBuilder: (context, animation1, animation2) =>
            //               const WebMyPlayList(),
            //           transitionDuration: Duration.zero,
            //           reverseTransitionDuration: Duration.zero,
            //         ),
            //       );
            //     }
            //   });
            // }),
            panelItem("watchlater", "watch_later_web.svg", "watchlater", true,
                () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  Provider.of<GeneralProvider>(context, listen: false)
                      .setCurrentPage("watchlater");

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebWatchLater(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              });
            }),
            panelItem("likevideos", "like_web.svg", "likevideos", true, () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLogin(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  Provider.of<GeneralProvider>(context, listen: false)
                      .setCurrentPage("likevideos");

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const WebLikeVideos(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              });
            }),
            webDivider(context, const EdgeInsets.fromLTRB(0, 10, 0, 10)),
            /* Constant.userID == null
              ? const SizedBox.shrink()
              : panelItem("userpanel", "userpanel.png", "userpanel", true,
                  () {
                  Utils().showInterstitalAds(
                      context, Constant.interstialAdType, () async {
                    userPanelActiveDilog(context);
                  });
                }),*/
            panelItem(
                "chooselanguage", "language_web.svg", "chooselanguage", true,
                () {
              Utils().showInterstitalAds(context, Constant.interstialAdType,
                  () async {
                _languageChangeDialog(context);
              });
            }),
            panelItem("login_logout", "logout_web.svg",
                Constant.userID != null ? "logout" : "login", true, () {
              if (Constant.userID == null) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const WebLogin(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              } else {
                logoutdilog(context, isProfile);
              }
            }),
            panelItem("deleteaccount", "ic_delete.png", 'deleteaccount', true,
                () {
              if (Constant.userID == null) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const WebLogin(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              } else {
                deleteConfirmDialog(context);
              }
            }),
            webDivider(context, const EdgeInsets.fromLTRB(0, 10, 0, 10)),
            buildWebGetPages(),
            buildWebSocialLink(),
          ],
        ),
      ),
    );
  }

  static Widget panelItem(
    String type,
    String icon,
    String name,
    bool multilanguage,
    VoidCallback onTap,
  ) {
    return Consumer<GeneralProvider>(
      builder: (context, generalprovider, child) {
        bool isSelected = generalprovider.isSelected(type);

        bool isDesktopPanel = generalprovider.isPanel ==
                true /*&&
            MediaQuery.of(context).size.width > 1200*/
            ;

        return InkWell(
          hoverColor: buttonDisable,
          splashColor: appbgcolor,
          focusColor: appbgcolor,
          highlightColor: appbgcolor,
          onTap: onTap,
          onHover: (value) async {
            await generalprovider.isHoverSideMenu(type, value);
          },
          borderRadius: BorderRadius.circular(isDesktopPanel ? 15 : 50),
          child: Container(
            decoration: BoxDecoration(
              gradient: isSelected ? Constant.gradientColor : null,
              borderRadius: BorderRadius.circular(isDesktopPanel ? 15 : 50),
            ),
            padding: EdgeInsets.fromLTRB(
              isDesktopPanel ? 15 : 15,
              isDesktopPanel ? 12 : 15,
              isDesktopPanel ? 15 : 15,
              isDesktopPanel ? 12 : 15,
            ),
            margin: isDesktopPanel
                ? const EdgeInsets.only(bottom: 5)
                : EdgeInsets.zero,
            child: isDesktopPanel
                ? Row(
                    children: [
                      MyImage(
                        width: 20,
                        height: 20,
                        imagePath: icon,
                        color: isSelected ? pureBlack : white,
                      ),
                      const SizedBox(width: 30),
                      MyText(
                        color: isSelected ? pureBlack : white,
                        multilanguage: multilanguage,
                        text: name,
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        maxline: 1,
                        fontwaight:
                            isSelected ? FontWeight.w500 : FontWeight.w300,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  )
                : MyImage(
                    width: 20,
                    height: 20,
                    imagePath: icon,
                    color: isSelected ? pureBlack : white,
                  ),
          ),
        );
      },
    );
  }

  static logoutdilog(BuildContext context, isProfile) {
    return showDialog(
        context: context,
        barrierColor: transparent,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            insetPadding: const EdgeInsets.fromLTRB(50, 25, 50, 25),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            backgroundColor: colorPrimaryDark,
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(
                minWidth: 230,
                maxWidth: 375,
                minHeight: 130,
                maxHeight: 175,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  /* ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MyImage(
                      imagePath: "appicon.png",
                      width: 130,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),*/
                  MyText(
                    color: white,
                    text: "areyousurewanrtosignout",
                    multilanguage: true,
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textTitle,
                    fontsizeWeb: Dimens.textTitle,
                    fontwaight: FontWeight.w500,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          hoverColor: colorPrimary,
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                            margin: const EdgeInsets.all(1),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: appbgcolor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: MyText(
                              color: white,
                              text: "cancel",
                              multilanguage: true,
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textDesc,
                              fontsizeWeb: Dimens.textDesc,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontwaight: FontWeight.w500,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          hoverColor: colorPrimary,
                          onTap: () async {
                            Navigator.pop(context);

                            // Clear user session immediately
                            Constant.userID = null;
                            await Utils.setUserId(null);

                            // Navigate to login
                            navigatorKey.currentState?.pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const WebLogin(),
                              ),
                              (route) => false,
                            );

                            // Background cleanup (non-blocking)
                            Future.microtask(() async {
                              try {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.clear();
                              } catch (_) {}

                              try {
                                await FirebaseAuth.instance.signOut();
                              } catch (_) {}

                              try {
                                await GoogleSignIn().signOut();
                              } catch (_) {}

                              try {
                                clearUserCreds();
                              } catch (_) {}

                              try {
                                audioPlayer.stop();
                                audioPlayer.pause();
                              } catch (_) {}
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(1),
                            padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: appbgcolor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: MyText(
                              color: white,
                              text: "logout",
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textDesc,
                              fontsizeWeb: Dimens.textDesc,
                              multilanguage: true,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontwaight: FontWeight.w500,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).then((value) {
      if (isProfile == true) {
        Navigator.pop(context);
      }
    });
  }

/* Custom Appbar With SidePanel Start */

  static int crossAxisCount(BuildContext context) {
    if (MediaQuery.of(context).size.width > 1600) {
      return 5;
    } else if (MediaQuery.of(context).size.width > 1200) {
      return 4;
    } else if (MediaQuery.of(context).size.width > 800) {
      return 2;
    } else if (MediaQuery.of(context).size.width > 400) {
      return 1;
    } else {
      return 1;
    }
  }

  static int crossAxisCountShorts(BuildContext context) {
    if (MediaQuery.of(context).size.width > 1600) {
      return 7;
    } else if (MediaQuery.of(context).size.width > 1200) {
      return 6;
    } else {
      return 4;
    }
  }

  static Color generateRendomColor() {
    final Random random = Random();
    final int red = random.nextInt(256);
    final int green = random.nextInt(256);
    final int blue = random.nextInt(256);
    final Color color = Color.fromARGB(255, red, green, blue);
    return color;
  }

  static int customCrossAxisCount(
      {required BuildContext context,
      required int height1600,
      required int height1200,
      required int height800,
      required int height600}) {
    if (MediaQuery.of(context).size.width > 1600) {
      return height1600;
    } else if (MediaQuery.of(context).size.width > 1200) {
      return height1200;
    } else if (MediaQuery.of(context).size.width > 800) {
      return height800;
    } else if (MediaQuery.of(context).size.width > 600) {
      return height600;
    } else {
      return 1;
    }
  }

  static roundTag(width, height) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: gray),
    );
  }

  static _languageChangeDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: colorPrimaryDark,
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: colorPrimaryDark,
            padding: const EdgeInsets.all(20.0),
            constraints: const BoxConstraints(
              minWidth: 400,
              maxWidth: 500,
              minHeight: 450,
              maxHeight: 500,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                      color: white,
                      text: "selectlanguage",
                      multilanguage: true,
                      textalign: TextAlign.start,
                      fontsizeNormal: Dimens.textTitle,
                      fontwaight: FontWeight.bold,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        size: 25,
                        color: white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                /* English */
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "English",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('en');
                            Navigator.pop(context);
                          },
                        ),

                        /* Afrikaans */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "Afrikaans",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('af');
                            Navigator.pop(context);
                          },
                        ),

                        /* Arabic */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "Arabic",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('ar');
                            Navigator.pop(context);
                          },
                        ),

                        /* German */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "German",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('de');
                            Navigator.pop(context);
                          },
                        ),

                        /* Spanish */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "Spanish",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('es');
                            Navigator.pop(context);
                          },
                        ),

                        /* French */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "French",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('fr');
                            Navigator.pop(context);
                          },
                        ),

                        /* Gujarati */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "Gujarati",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('gu');
                            Navigator.pop(context);
                          },
                        ),

                        /* Hindi */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "Hindi",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('hi');
                            Navigator.pop(context);
                          },
                        ),

                        /* Indonesian */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "Indonesian",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('id');
                            Navigator.pop(context);
                          },
                        ),

                        /* Dutch */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "Dutch",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('nl');
                            Navigator.pop(context);
                          },
                        ),

                        /* Portuguese (Brazil) */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "Portuguese (Brazil)",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('pt');
                            Navigator.pop(context);
                          },
                        ),

                        /* Albanian */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "Albanian",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('sq');
                            Navigator.pop(context);
                          },
                        ),

                        /* Turkish */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "Turkish",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('tr');
                            Navigator.pop(context);
                          },
                        ),

                        /* Vietnamese */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "Vietnamese",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('vi');
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildLanguage({
    required BuildContext context,
    required String langName,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: colorPrimary,
            width: .5,
          ),
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(5),
        ),
        child: MyText(
          color: white,
          text: langName,
          textalign: TextAlign.center,
          fontsizeNormal: Dimens.textTitle,
          multilanguage: false,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontwaight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  static userPanelActiveDilog(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return const ActiveUserPanel();
      },
    );
  }

  static Widget buildBackBtnWeb(BuildContext context) {
    return SafeArea(
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        focusColor: gray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: Utils.setBackground(colorPrimaryDark, 8),
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.center,
          child: MyText(
            color: white,
            text: "Back",
            multilanguage: false,
            fontsizeNormal: 15,
            fontsizeWeb: 17,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w700,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }

/* Custom Ads Intastial Start */

  static getCustomAdsStatus() async {
    printLog(">==========get CustomAds Status=======>");
    SharedPre sharePref = SharedPre();

    printLog(">==========get CustomAds Status=======>");

    /* Banner */
    Constant.banneradStatus = await sharePref.read("banner_ads_status") ?? "";
    Constant.banneradCPV = await sharePref.read("banner_ads_cpv") ?? "";
    Constant.banneradCPC = await sharePref.read("banner_ads_cpc") ?? "";

    /* Interstital */
    Constant.interstitaladStatus =
        await sharePref.read("interstital_ads_status") ?? "";
    Constant.interstitaladCPV =
        await sharePref.read("interstital_ads_cpv") ?? "";
    Constant.interstitaladCPC =
        await sharePref.read("interstital_ads_cpc") ?? "";
    /* Reward */
    Constant.rewardadStatus = await sharePref.read("reward_ads_status") ?? "";
    Constant.rewardadCPV = await sharePref.read("reward_ads_cpv") ?? "";
    Constant.rewardadCPC = await sharePref.read("reward_ads_cpc") ?? "";

    printLog("BannerStatus Get Ads===>${Constant.banneradStatus}");
    printLog("Interstial===>${Constant.interstitaladStatus}");
    printLog("Reward===>${Constant.rewardadStatus}");
  }

  showInterstitalAds(context, String adType, VoidCallback callAction) async {
    // Constant.isPremiumCustomAds = await Utils.checkPremiumUser();
    final generalsetting = Provider.of<GeneralProvider>(context, listen: false);
    if (adType == Constant.interstialAdType) {
      await generalsetting.getAds(2);
    }
    if (Constant.isAdsFree == "1") {
      callAction();
      return;
    }
    if (adType == Constant.interstialAdType) {
      if (Constant.interstitaladStatus == "1") {
        if (((Constant.isAdsFree != "1") ||
            (Constant.isAdsFree == null) ||
            (Constant.isAdsFree == ""))) {
          if (generalsetting.getInterstialAdsModel.status == 200 &&
              generalsetting.getInterstialAdsModel.result != null) {
            testDilog(context, callAction);
            // interstitalAd(context, callAction);
          } else {
            callAction();
          }
        }
      } else {
        callAction();
      }
    } else {
      callAction();
    }
    /* Ads View Api Call */
    if (adType == Constant.interstialAdType) {
      await generalsetting.getAdsViewClickCount(
          "2",
          generalsetting.getInterstialAdsModel.result?.id.toString() ?? "",
          "123",
          "1",
          "1" /* "1" CPV & 2 CPC */,
          "");
    }
  }

  void testDilog(BuildContext context, VoidCallback callAction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width > 800
                ? MediaQuery.of(context).size.width * 0.50
                : MediaQuery.of(context).size.width * 0.75,
            height: ResponsiveHelper.checkIsWeb(context) ? 300 : 350,
            margin: ResponsiveHelper.checkIsWeb(context)
                ? const EdgeInsets.all(50)
                : const EdgeInsets.all(15),
            child: Consumer<GeneralProvider>(
                builder: (context, generalprovider, child) {
              return GestureDetector(
                onTap: () async {
                  Navigator.of(context).pop();
                  if (ResponsiveHelper.checkIsWeb(context)) {
                    // lanchAdsUrl('https://www.example.com');
                    lanchAdsLink(generalprovider
                            .getInterstialAdsModel.result?.redirectUri
                            .toString() ??
                        "");
                  } else {
                    lanchAdsUrl(generalprovider
                            .getInterstialAdsModel.result?.redirectUri
                            .toString() ??
                        "");
                  }
                  /* Generate DeviceToken */
                  String? diviceType;
                  String? diviceToken;
                  if (ResponsiveHelper.checkIsWeb(context)) {
                    diviceType = "3";
                    diviceToken = Constant.webToken;
                  } else {
                    if (Platform.isAndroid) {
                      diviceType = "1";
                      diviceToken = await PusherBeamsService().getDeviceToken();
                    } else {
                      diviceType = "2";
                      diviceToken = await PusherBeamsService().getDeviceToken();
                    }
                  }
                  /* Call APi */
                  await generalprovider.getAdsViewClickCount(
                    "2",
                    generalprovider.getInterstialAdsModel.result?.id
                            .toString() ??
                        "",
                    diviceType,
                    diviceToken,
                    "1" /* "1" CPV & 2 CPC */,
                    "",
                  );
                },
                child: ResponsiveHelper.checkIsWeb(context)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: MyNetworkImage(
                                    fit: BoxFit.fill,
                                    width: 400,
                                    height: 300,
                                    imagePath: generalprovider
                                            .getInterstialAdsModel.result?.image
                                            .toString() ??
                                        ""),
                              ),
                              Positioned.fill(
                                right: 15,
                                bottom: 15,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 4, 10, 4),
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: MyText(
                                        color: black,
                                        text: "Ads",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: Dimens.textMedium,
                                        fontsizeWeb: Dimens.textMedium,
                                        inter: false,
                                        multilanguage: false,
                                        maxline: 1,
                                        fontwaight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    callAction();
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    size: 20,
                                    color: white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MusicTitle(
                                    color: white,
                                    text: generalprovider
                                            .getInterstialAdsModel.result?.title
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textExtraBig,
                                    fontsizeWeb:
                                        MediaQuery.of(context).size.width > 800
                                            ? Dimens.textExtraBig
                                            : Dimens.textTitle,
                                    maxline: 5,
                                    multilanguage: false,
                                    fontwaight: FontWeight.w700,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                const SizedBox(height: 30),
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                  decoration: BoxDecoration(
                                    color: white,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: MyText(
                                      color: black,
                                      text: "explorebtn",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      inter: false,
                                      multilanguage: true,
                                      maxline: 1,
                                      fontwaight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: MyNetworkImage(
                                    fit: BoxFit.fill,
                                    width: MediaQuery.of(context).size.width,
                                    height: 200,
                                    imagePath: generalprovider
                                            .getInterstialAdsModel.result?.image
                                            .toString() ??
                                        ""),
                              ),
                              Positioned.fill(
                                right: 15,
                                bottom: 15,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 4, 10, 4),
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: MyText(
                                        color: black,
                                        text: "Ads",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: Dimens.textMedium,
                                        fontsizeWeb: Dimens.textMedium,
                                        inter: false,
                                        multilanguage: false,
                                        maxline: 1,
                                        fontwaight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                  ),
                                ),
                              ),
                              InkWell(
                                hoverColor: transparent,
                                highlightColor: transparent,
                                splashColor: transparent,
                                focusColor: transparent,
                                onTap: () {
                                  Navigator.pop(context);
                                  callAction();
                                },
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: const BoxDecoration(
                                          color: colorPrimary,
                                          shape: BoxShape.circle),
                                      child: Icon(
                                        Icons.close,
                                        size: 20,
                                        color: white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: MusicTitle(
                                color: white,
                                text: generalprovider
                                        .getInterstialAdsModel.result?.title
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textBig,
                                fontsizeWeb:
                                    MediaQuery.of(context).size.width > 800
                                        ? Dimens.textExtraBig
                                        : Dimens.textTitle,
                                maxline: 3,
                                multilanguage: false,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: MyText(
                                color: black,
                                text: "explorebtn",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textMedium,
                                fontsizeWeb: Dimens.textMedium,
                                inter: false,
                                multilanguage: true,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                        ],
                      ),
              );
            }),
          ),
        );
      },
    );
  }

  // Policy filtering slug lists
  static const List<String> _safetySlugs = [
    "complaint-policy",
    "appeal-policy",
    "report-abuse-flow",
    "dmca-takedown-request-form",
    "dmca-takedown-request",
    "dmca-takedown",
    "dmca",
    "takedown-request",
  ];

  static const List<String> _businessPolicySlugs = [
    "platform-to-business-policy",
  ];

  static const List<String> _helpCenterSlugs = [
    "faq-user",
    "faq-creator",
    "community-guidelines",
    "acceptable-use-policy",
  ];

  static const List<String> _policyOnlyPageSlugs = [
    "terms-and-conditions",
    "privacy-policy",
    "cookie-policy",
    "child-safety-csam-policy",
    "anti-trafficking-anti-coercion-policy",
    "global-tax-vat-policy",
  ];

  static const List<Color> _policyColors = [
    Color(0xff2474D0),
    Color(0xff19AFBD),
    Color(0xffE625A6),
    Color(0xffF7AF13),
    Color(0xffB000EA),
    Color(0xff01DED1),
    Color(0xff38A66F),
    Color(0xff771CF6),
  ];

  static Color _colorForIndex(int index) {
    return _policyColors[index % _policyColors.length];
  }

  static bool _isSafetyPage(dynamic page) {
    final url = (page.url ?? "").toString().toLowerCase();
    final pageName = (page.pageName ?? "").toString().toLowerCase();
    final title = (page.title ?? "").toString().toLowerCase();
    final normalizedTitle = title.replaceAll('-', ' ');
    return _safetySlugs.any((slug) =>
            url.contains(slug) ||
            pageName == slug ||
            title.contains(slug.replaceAll('-', ' '))) ||
        normalizedTitle.contains('dmca') ||
        normalizedTitle.contains('takedown');
  }

  static bool _isBusinessPolicyPage(dynamic page) {
    final url = (page.url ?? "").toString().toLowerCase();
    final pageName = (page.pageName ?? "").toString().toLowerCase();
    final title = (page.title ?? "").toString().toLowerCase();
    final normalizedUrl = url.replaceAll(RegExp('[-_]'), ' ');
    final normalizedPageName = pageName.replaceAll(RegExp('[-_]'), ' ');
    final normalizedTitle = title.replaceAll(RegExp('[-_]'), ' ');
    return _businessPolicySlugs.any((slug) =>
            url.contains(slug) ||
            pageName == slug ||
            title.contains(slug.replaceAll('-', ' '))) ||
        normalizedUrl.contains('platform to business') ||
        normalizedPageName.contains('platform to business') ||
        normalizedTitle.contains('platform to business') ||
        normalizedUrl.contains('p2b') ||
        normalizedPageName.contains('p2b') ||
        normalizedTitle.contains('p2b');
  }

  static bool _isHelpCenterPage(dynamic page) {
    final url = (page.url ?? "").toString().toLowerCase();
    final pageName = (page.pageName ?? "").toString().toLowerCase();
    final title = (page.title ?? "").toString().toLowerCase();
    final normalizedUrl = url.replaceAll(RegExp('[-_]'), ' ');
    final normalizedPageName = pageName.replaceAll(RegExp('[-_]'), ' ');
    final normalizedTitle = title.replaceAll(RegExp('[-_]'), ' ');
    return _helpCenterSlugs.any((slug) =>
            url.contains(slug) ||
            pageName == slug ||
            title.contains(slug.replaceAll('-', ' '))) ||
        normalizedUrl.contains('faq') ||
        normalizedPageName.contains('faq') ||
        normalizedTitle.contains('faq') ||
        normalizedUrl.contains('community guidelines') ||
        normalizedPageName.contains('community guidelines') ||
        normalizedTitle.contains('community guidelines') ||
        normalizedUrl.contains('acceptable use') ||
        normalizedPageName.contains('acceptable use') ||
        normalizedTitle.contains('acceptable use');
  }

  static bool _isPolicyPage(dynamic page) {
    final url = (page.url ?? "").toString().toLowerCase();
    final pageName = (page.pageName ?? "").toString().toLowerCase();
    final title = (page.title ?? "").toString().toLowerCase();
    final normalizedUrl = url.replaceAll(RegExp('[-_]'), ' ');
    final normalizedPageName = pageName.replaceAll(RegExp('[-_]'), ' ');
    final normalizedTitle = title.replaceAll(RegExp('[-_]'), ' ');
    return _policyOnlyPageSlugs.any((slug) =>
            url.contains(slug) ||
            pageName == slug ||
            title.contains(slug.replaceAll('-', ' '))) ||
        normalizedUrl.contains('terms') ||
        normalizedPageName.contains('terms') ||
        normalizedTitle.contains('terms') ||
        normalizedUrl.contains('privacy') ||
        normalizedPageName.contains('privacy') ||
        normalizedTitle.contains('privacy') ||
        normalizedUrl.contains('cookie') ||
        normalizedPageName.contains('cookie') ||
        normalizedTitle.contains('cookie') ||
        normalizedUrl.contains('child safety') ||
        normalizedPageName.contains('child safety') ||
        normalizedTitle.contains('child safety') ||
        normalizedUrl.contains('anti-trafficking') ||
        normalizedPageName.contains('anti-trafficking') ||
        normalizedTitle.contains('anti-trafficking') ||
        normalizedUrl.contains('tax') ||
        normalizedPageName.contains('tax') ||
        normalizedTitle.contains('tax');
  }

  static Widget buildWebGetPages() {
    return Consumer<SettingProvider>(
        builder: (context, settingprovider, child) {
      if (settingprovider.getpagesModel.result == null ||
          settingprovider.getpagesModel.result!.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          _buildPolicyAccordion(context, settingprovider),
          _buildSafetyAccordion(context, settingprovider),
          _buildBusinessPoliciesAccordion(context, settingprovider),
          _buildHelpCenterAccordion(context, settingprovider),
        ],
      );
    });
  }

  static Widget _buildPolicyAccordion(
      BuildContext context, SettingProvider settingprovider) {
    final pages = settingprovider.getpagesModel.result ?? [];
    final filteredPages = pages.where((page) => _isPolicyPage(page)).toList();

    if (filteredPages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: colorPrimary.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            Icons.policy,
            color: white,
            size: 20,
          ),
          title: MyText(
            color: white,
            text: "Policy",
            textalign: TextAlign.left,
            fontsizeNormal: Dimens.textMedium,
            fontsizeWeb: Dimens.textMedium,
            multilanguage: false,
            inter: false,
            maxline: 1,
            fontwaight: FontWeight.w300,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
          iconColor: white,
          collapsedIconColor: white,
          children: List.generate(
            filteredPages.length,
            (index) => InkWell(
              onTap: () {
                if (filteredPages[index].url != "") {
                  Utils.lanchAdsLink(filteredPages[index].url);
                }
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorPrimary.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    filteredPages[index].icon != null &&
                            filteredPages[index].icon!.isNotEmpty
                        ? MyNetworkImage(
                            width: 20,
                            height: 20,
                            imagePath: filteredPages[index].icon!,
                            isPagesIcon: true,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Icons.description,
                            color: white,
                            size: 20,
                          ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: MyText(
                        color: white,
                        text: filteredPages[index].title.toString(),
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        multilanguage: false,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w300,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildSafetyAccordion(
      BuildContext context, SettingProvider settingprovider) {
    final pages = settingprovider.getpagesModel.result ?? [];
    final safetyPages = pages.where((page) => _isSafetyPage(page)).toList();

    if (safetyPages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: colorPrimary.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            Icons.safety_check,
            color: white,
            size: 20,
          ),
          title: MyText(
            color: white,
            text: "Safety",
            textalign: TextAlign.left,
            fontsizeNormal: Dimens.textMedium,
            fontsizeWeb: Dimens.textMedium,
            multilanguage: false,
            inter: false,
            maxline: 1,
            fontwaight: FontWeight.w300,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
          iconColor: white,
          collapsedIconColor: white,
          children: List.generate(
            safetyPages.length,
            (index) => InkWell(
              onTap: () {
                if (safetyPages[index].url != "") {
                  Utils.lanchAdsLink(safetyPages[index].url);
                }
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorPrimary.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    safetyPages[index].icon != null &&
                            safetyPages[index].icon!.isNotEmpty
                        ? MyNetworkImage(
                            width: 20,
                            height: 20,
                            imagePath: safetyPages[index].icon!,
                            isPagesIcon: true,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Icons.security,
                            color: white,
                            size: 20,
                          ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: MyText(
                        color: white,
                        text: safetyPages[index].title.toString(),
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        multilanguage: false,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w300,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildBusinessPoliciesAccordion(
      BuildContext context, SettingProvider settingprovider) {
    final pages = settingprovider.getpagesModel.result ?? [];
    final businessPages =
        pages.where((page) => _isBusinessPolicyPage(page)).toList();

    if (businessPages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: colorPrimary.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            Icons.business_center,
            color: white,
            size: 20,
          ),
          title: MyText(
            color: white,
            text: "Business & Platform",
            textalign: TextAlign.left,
            fontsizeNormal: Dimens.textMedium,
            fontsizeWeb: Dimens.textMedium,
            multilanguage: false,
            inter: false,
            maxline: 1,
            fontwaight: FontWeight.w300,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
          iconColor: white,
          collapsedIconColor: white,
          children: List.generate(
            businessPages.length,
            (index) => InkWell(
              onTap: () {
                if (businessPages[index].url != "") {
                  Utils.lanchAdsLink(businessPages[index].url);
                }
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorPrimary.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    businessPages[index].icon != null &&
                            businessPages[index].icon!.isNotEmpty
                        ? MyNetworkImage(
                            width: 20,
                            height: 20,
                            imagePath: businessPages[index].icon!,
                            isPagesIcon: true,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Icons.store,
                            color: white,
                            size: 20,
                          ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: MyText(
                        color: white,
                        text: businessPages[index].title.toString(),
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        multilanguage: false,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w300,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildHelpCenterAccordion(
      BuildContext context, SettingProvider settingprovider) {
    final pages = settingprovider.getpagesModel.result ?? [];
    final helpCenterPages =
        pages.where((page) => _isHelpCenterPage(page)).toList();

    if (helpCenterPages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: colorPrimary.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            Icons.help,
            color: white,
            size: 20,
          ),
          title: MyText(
            color: white,
            text: "Help Center",
            textalign: TextAlign.left,
            fontsizeNormal: Dimens.textMedium,
            fontsizeWeb: Dimens.textMedium,
            multilanguage: false,
            inter: false,
            maxline: 1,
            fontwaight: FontWeight.w300,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
          iconColor: white,
          collapsedIconColor: white,
          children: List.generate(
            helpCenterPages.length,
            (index) => InkWell(
              onTap: () {
                if (helpCenterPages[index].url != "") {
                  Utils.lanchAdsLink(helpCenterPages[index].url);
                }
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorPrimary.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    helpCenterPages[index].icon != null &&
                            helpCenterPages[index].icon!.isNotEmpty
                        ? MyNetworkImage(
                            width: 20,
                            height: 20,
                            imagePath: helpCenterPages[index].icon!,
                            isPagesIcon: true,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Icons.support_agent,
                            color: white,
                            size: 20,
                          ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: MyText(
                        color: white,
                        text: helpCenterPages[index].title.toString(),
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        multilanguage: false,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w300,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildWebSocialLink() {
    return Consumer<SettingProvider>(
        builder: (context, settingprovider, child) {
      return ListView.builder(
          itemCount: settingprovider.socialLinkModel.result?.length ?? 0,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Utils().buildWebGetPagesItem(
                "get_sociallink",
                settingprovider.socialLinkModel.result?[index].image
                        .toString() ??
                    "",
                settingprovider.socialLinkModel.result?[index].name
                        .toString() ??
                    "",
                false, () {
              if (settingprovider.socialLinkModel.result?[index].url != "") {
                Utils.lanchAdsLink(
                    settingprovider.socialLinkModel.result?[index].url);
              }
            });
          });
    });
  }

  Widget buildWebGetPagesItem(type, icon, name, multilanguage, onTap) {
    return Consumer<GeneralProvider>(
        builder: (context, generalprovider, child) {
      return generalprovider.isPanel == true
          ? InkWell(
              onTap: () async {
                onTap();
              },
              borderRadius: BorderRadius.circular(5),
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                margin: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyNetworkImage(
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      imagePath: "$icon",
                      isPagesIcon: true,
                      color: white,
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: MyText(
                          color: white,
                          multilanguage: multilanguage,
                          text: name,
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textMedium,
                          fontsizeWeb: Dimens.textMedium,
                          maxline: 1,
                          fontwaight: FontWeight.w300,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                  ],
                ),
              ),
            )
          : InkWell(
              onTap: () async {
                onTap();
              },
              borderRadius: BorderRadius.circular(50),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: MyNetworkImage(
                  width: 20,
                  height: 20,
                  imagePath: icon,
                  color: white,
                  isPagesIcon: true,
                  fit: BoxFit.contain,
                ),
              ),
            );
    });
  }

  /* Custom Ads Intastial End */

  static String? convertUrlToId(String url, {bool trimWhitespaces = true}) {
    if (!url.contains("http") && (url.length == 11)) return url;
    if (trimWhitespaces) url = url.trim();

    const contentUrlPattern = r'^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?';
    const embedUrlPattern =
        r'^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/';
    const altUrlPattern = r'^https:\/\/youtu\.be\/';
    const shortsUrlPattern = r'^https:\/\/(?:www\.|m\.)?youtube\.com\/shorts\/';
    const musicUrlPattern = r'^https:\/\/(?:music\.)?youtube\.com\/watch\?';
    const idPattern = r'([_\-a-zA-Z0-9]{11}).*$';

    for (var regex in [
      '${contentUrlPattern}v=$idPattern',
      '$embedUrlPattern$idPattern',
      '$altUrlPattern$idPattern',
      '$shortsUrlPattern$idPattern',
      '$musicUrlPattern?v=$idPattern',
    ]) {
      Match? match = RegExp(regex).firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }

  /* Download Button */
  static Future<void> initializeHiveBoxes(BuildContext context) async {
    printLog("initializeHiveBoxes userId =====> ${Constant.userID}");
    if (ResponsiveHelper.checkIsWeb(context)) return;
    if (Constant.userID == null) {
      await Hive.deleteBoxFromDisk(Constant.hiveDownloadBox);
      await Hive.deleteBoxFromDisk(Constant.hiveSeasonDownloadBox);
      await Hive.deleteBoxFromDisk(Constant.hiveEpiDownloadBox);
    }

    printLog("hiveDownloadBox =========> ${Constant.hiveDownloadBox}");
    printLog("hiveSeasonDownloadBox ===> ${Constant.hiveSeasonDownloadBox}");
    printLog("hiveEpiDownloadBox ======> ${Constant.hiveEpiDownloadBox}");
    if (Constant.userID != null) {
      bool? isDownloadBoxExists = await Hive.boxExists(
          '${Constant.hiveDownloadBox}_${Constant.userID}');
      bool? isSeasonBoxExists = await Hive.boxExists(
          '${Constant.hiveSeasonDownloadBox}_${Constant.userID}');
      bool? isEpisodeBoxExists = await Hive.boxExists(
          '${Constant.hiveEpiDownloadBox}_${Constant.userID}');

      printLog("isDownloadBoxExists ========> $isDownloadBoxExists");
      printLog("isSeasonBoxExists ==========> $isSeasonBoxExists");
      printLog("isEpisodeBoxExists =========> $isEpisodeBoxExists");
      await Hive.openBox<DownloadItem>(
          '${Constant.hiveDownloadBox}_${Constant.userID}');
      // await Hive.openBox<SessionItem>(
      //     '${Constant.hiveSeasonDownloadBox}_${Constant.userID}');
      // await Hive.openBox<EpisodeItem>(
      //     '${Constant.hiveEpiDownloadBox}_${Constant.userID}');
    } else {
      await Hive.openBox<DownloadItem>(Constant.hiveDownloadBox);
      // await Hive.openBox<SessionItem>(Constant.hiveSeasonDownloadBox);
      // await Hive.openBox<EpisodeItem>(Constant.hiveEpiDownloadBox);
    }
  }

  /* ***************** Download ***************** */

  static Future<String> prepareSaveDir() async {
    String localPath = (await _getSavedDir())!;
    printLog("localPath ------------> $localPath");
    final savedDir = Directory(localPath);
    printLog("savedDir -------------> $savedDir");
    printLog("is exists ? ----------> ${savedDir.existsSync()}");
    if (!(await savedDir.exists())) {
      await savedDir.create(recursive: true);
    }
    return localPath;
  }

  static Future<String?> _getSavedDir() async {
    String? externalStorageDirPath;

    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      try {
        externalStorageDirPath = "${directory?.absolute.path}/downloads/";
      } catch (err, st) {
        printLog('failed to get downloads path: $err, $st');
        externalStorageDirPath = "${directory?.absolute.path}/downloads/";
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    printLog("externalStorageDirPath ------------> $externalStorageDirPath");
    return externalStorageDirPath;
  }

  static Future<String> prepareShowSaveDir(
      String showName, String seasonName) async {
    printLog("showName -------------> $showName");
    printLog("seasonName -------------> $seasonName");
    String localPath = (await _getShowSavedDir(showName, seasonName))!;
    final savedDir = Directory(localPath);
    printLog("savedDir -------------> $savedDir");
    printLog("savedDir path --------> ${savedDir.path}");
    if (!savedDir.existsSync()) {
      await savedDir.create(recursive: true);
    }
    return localPath;
  }

  static Future<String?> _getShowSavedDir(
      String showName, String seasonName) async {
    String? externalStorageDirPath;

    if (Platform.isAndroid) {
      try {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath =
            "${directory?.path}/downloads/${showName.toLowerCase()}/${seasonName.toLowerCase()}";
      } catch (err, st) {
        printLog('failed to get downloads path: $err, $st');
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath =
            "${directory?.path}/downloads/${showName.toLowerCase()}/${seasonName.toLowerCase()}";
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          "${(await getApplicationDocumentsDirectory()).absolute.path}/downloads/${showName.toLowerCase()}/${seasonName.toLowerCase()}";
    }
    return externalStorageDirPath;
  }

  static String generateRandomKey(int len) {
    final random = Random.secure();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  static String convertToHex(String input) {
    return utf8
        .encode(input)
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static Future<dynamic> encryptUsingFFMPEG(List<dynamic> args) async {
    // File inputFile = args[0] as File;
    // String generateKey = args[1] as String;
    // String generateIVKey = args[2] as String;
    // printLog("encryptUsingFFMPEG generateKey =====> $generateKey");
    // printLog("encryptUsingFFMPEG generateIVKey ===> $generateIVKey");

    // // Get the ProgressProvider
    // final downloadProvider =
    //     Provider.of<VideoDownloadProvider>(args[3], listen: false);

    // final Completer<File?> completer = Completer<File?>();

    // // Create a temporary file for the encrypted output
    // File tempFile =
    //     File((inputFile.path.replaceAll(".mp4", "aes.mp4")).toString());
    // printLog("encryptUsingFFMPEG tempFile ===> $tempFile");

    // try {
    //   /* DURATION FETCHING */
    //   // Get the duration of the input file
    //   String durationCommand = '-i ${inputFile.path} -hide_banner';
    //   final durationSession = await FFmpegKit.execute(durationCommand);
    //   final durationLog = await durationSession.getOutput();

    //   // Check if the log output is not null and has the expected format
    //   double totalDuration = 0;
    //   if (durationLog != null) {
    //     // Extract duration from the log output
    //     final durationMatch =
    //         RegExp(r'Duration:\s+(\d{2}):(\d{2}):(\d{2})\.(\d{2})')
    //             .firstMatch(durationLog);

    //     // Calculate total duration in seconds
    //     if (durationMatch != null) {
    //       final hours = int.parse(durationMatch.group(1)!);
    //       final minutes = int.parse(durationMatch.group(2)!);
    //       final seconds = double.parse(durationMatch.group(3)!);

    //       totalDuration = hours * 3600 + minutes * 60 + seconds;

    //       printLog(
    //           'encryptUsingFFMPEG Encryption totalDuration ====> $totalDuration'); // Duration in seconds
    //     } else {
    //       printLog('Could not find duration in log output');
    //     }
    //   } else {
    //     printLog('No output from duration command');
    //   }
    //   /* DURATION FETCHING */

    //   // FFmpeg command for AES-256-CBC encryption
    //   String command =
    //       '-i ${inputFile.path} -c:v copy -c:a copy -encryption_scheme cenc-aes-ctr -encryption_key $generateKey -encryption_kid $generateIVKey ${tempFile.path}';
    //   downloadProvider.setEncryptProgress(0.0);
    //   await FFmpegKit.executeAsync(
    //     command,
    //     (session) async {
    //       final returnCode = await session.getReturnCode();
    //       printLog('encryptUsingFFMPEG returnCode : $returnCode');
    //       if (ReturnCode.isSuccess(returnCode)) {
    //         // SUCCESS
    //         printLog('encryptUsingFFMPEG Successful tempFile : $tempFile');
    //         // Replace the original file with the encrypted temporary file
    //         await inputFile.delete();
    //         await tempFile.rename(inputFile.path);
    //         printLog('encryptUsingFFMPEG Successful inputFile : $inputFile');
    //         downloadProvider.setEncryptProgress(1.0);
    //         completer.complete(inputFile);
    //       } else {
    //         // ERROR
    //         printLog('encryptUsingFFMPEG Failed!!!');
    //         downloadProvider.setEncryptProgress(0.0);
    //         completer.complete(null);
    //       }
    //     },
    //     (log) {
    //       printLog('encryptUsingFFMPEG getMessage : ${log.getMessage()}');
    //     },
    //     (progress) async {
    //       // Update the progress provider here
    //       if (totalDuration > 0) {
    //         // Update the progress provider here
    //         printLog(
    //             'encryptUsingFFMPEG Decryption progressTime =====> ${progress.getTime()}');
    //         printLog(
    //             'encryptUsingFFMPEG Decryption totalDuration ====> $totalDuration');
    //         // Assuming progress.getTime() returns milliseconds
    //         final progressTimeInSeconds = (progress.getTime() / 1000.0)
    //             .roundToDouble(); // Convert to seconds
    //         printLog(
    //             'encryptUsingFFMPEG Decryption progressTimeInSeconds ====> $progressTimeInSeconds');

    //         double percentage = progressTimeInSeconds / totalDuration;
    //         downloadProvider
    //             .setEncryptProgress(percentage.clamp(0.0, 1.0)); // Clamp to 0-1
    //       }
    //     },
    //   );
    // } catch (e) {
    //   printLog('encryptUsingFFMPEG Error during encryption: $e');
    //   downloadProvider.setEncryptProgress(0.0);
    //   completer.complete(null);
    // }
    // return completer.future;
  }

  static Future<File?> decryptUsingFFMPEG(List<dynamic> args) async {
    // File inFile = args[0] as File;
    // String generateKey = args[1] as String;
    // String generateIVKey = args[2] as String;

    // // Get the ProgressProvider
    // final playerProvider = Provider.of<PlayerProvider>(args[3], listen: false);

    // printLog("decryptUsingFFMPEG generateKey =====> $generateKey");
    // printLog("decryptUsingFFMPEG generateIVKey ===> $generateIVKey");
    // await deleteCacheDir();

    // // Create a temporary decrypted file
    // final tempDir = await getTemporaryDirectory();
    // File decryptedFile = File('${tempDir.path}/${path.basename(inFile.path)}');
    // printLog('decryptUsingFFMPEG inFile ==========> $inFile');
    // printLog('decryptUsingFFMPEG decryptedFile ===> $decryptedFile');

    // final Completer<File?> completer = Completer<File?>();
    // try {
    //   // Check if the encrypted file exists
    //   bool isInFileExists = await inFile.exists();
    //   if (!isInFileExists) {
    //     printLog("decryptUsingFFMPEG Encrypted file does not exist.");
    //     completer.complete(null);
    //     return completer.future;
    //   }

    //   /* DURATION FETCHING */
    //   // Get the duration of the input file
    //   String durationCommand = '-i ${inFile.path} -hide_banner';
    //   final durationSession = await FFmpegKit.execute(durationCommand);
    //   final durationLog = await durationSession.getOutput();

    //   // Check if the log output is not null and has the expected format
    //   double totalDuration = 0;
    //   if (durationLog != null) {
    //     // Extract duration from the log output
    //     final durationMatch =
    //         RegExp(r'Duration:\s+(\d{2}):(\d{2}):(\d{2})\.(\d{2})')
    //             .firstMatch(durationLog);

    //     // Calculate total duration in seconds
    //     if (durationMatch != null) {
    //       final hours = int.parse(durationMatch.group(1)!);
    //       final minutes = int.parse(durationMatch.group(2)!);
    //       final seconds = double.parse(durationMatch.group(3)!);

    //       totalDuration = hours * 3600 + minutes * 60 + seconds;

    //       printLog(
    //           'decryptUsingFFMPEG Decryption totalDuration ====> $totalDuration'); // Duration in seconds
    //     } else {
    //       printLog('Could not find duration in log output');
    //     }
    //   } else {
    //     printLog('No output from duration command');
    //   }
    //   /* DURATION FETCHING */

    //   // FFmpeg command for decryption
    //   String command =
    //       '-decryption_key $generateKey -i ${inFile.path} -c:v copy -c:a copy ${decryptedFile.path}';

    //   await FFmpegKit.executeAsync(
    //     command,
    //     (session) async {
    //       final returnCode = await session.getReturnCode();
    //       printLog('decryptUsingFFMPEG returnCode : $returnCode');
    //       if (ReturnCode.isSuccess(returnCode)) {
    //         // SUCCESS
    //         printLog(
    //             'decryptUsingFFMPEG Decryption successful decryptedFile : $decryptedFile');
    //         completer.complete(decryptedFile);
    //         playerProvider.setDecryptProgress(1.0);
    //       } else {
    //         // ERROR
    //         printLog('decryptUsingFFMPEG Decryption failed!!!');
    //         completer.complete(null);
    //         playerProvider.setDecryptProgress(0.0);
    //       }
    //     },
    //     (log) {
    //       printLog('decryptUsingFFMPEG getMessage : ${log.getMessage()}');
    //     },
    //     (progress) async {
    //       if (totalDuration > 0) {
    //         // Update the progress provider here
    //         printLog(
    //             'decryptUsingFFMPEG Decryption progressTime =====> ${progress.getTime()}');
    //         printLog(
    //             'decryptUsingFFMPEG Decryption totalDuration ====> $totalDuration');
    //         // Assuming progress.getTime() returns milliseconds
    //         final progressTimeInSeconds = (progress.getTime() / 1000.0)
    //             .roundToDouble(); // Convert to seconds
    //         printLog(
    //             'decryptUsingFFMPEG Decryption progressTimeInSeconds ====> $progressTimeInSeconds');

    //         double percentage = progressTimeInSeconds / totalDuration;
    //         playerProvider
    //             .setDecryptProgress(percentage.clamp(0.0, 1.0)); // Clamp to 0-1
    //       }
    //     },
    //   );
    //   printLog('decryptUsingFFMPEG decryptedFile ===> $decryptedFile');
    // } catch (e) {
    //   printLog('decryptUsingFFMPEG Error during decryption: $e');
    //   completer.complete(null);
    //   playerProvider.setDecryptProgress(0.0);
    // }
    // return completer.future;
  }

  static Future<void> deleteCacheDir() async {
    if (Platform.isAndroid) {
      var tempDir = await getTemporaryDirectory();

      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    }
  }

  /* ***************** Download ***************** */

/*----------------------------------------------------------------- Web Utils End ------------------------------------------------------------------ */

/* ======================= Web Device Token Start ============ */

/* Generate Web Device Token Start */

  getDeviceTokenWithPermissionWeb() async {
    // Pusher Beams handles permissions internally
    printLog('Pusher Beams permission handling');
    await getToken();
  }

  getToken() async {
    SharedPre sharedPre = SharedPre();
    Constant.vapId = await sharedPre.read(Constant.vapIdKey) ?? "";

    // For Pusher Beams, we'll store a device identifier
    String? token = await PusherBeamsService().getDeviceToken();

    Constant.webToken = token;
    printLog("Pusher Beams token: ${Constant.webToken}");
  }

/* ======================= Web Device Token End ============ */
}
