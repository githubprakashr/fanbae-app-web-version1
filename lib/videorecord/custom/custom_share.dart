import 'dart:async';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/videorecord/loadingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CustomShare {
  static Future onShare(
      {required BuildContext context,
      required String title,
      required String filePath}) async {
    printLog("Share Method Called Success...");
    LoadingOverlay().show(context); // Start Loading...

    Share.share(title);

    // await FlutterShare.share(title: title, linkUrl: "https://play.google.com/store/apps/details?id=AppPackageName");
    LoadingOverlay().hide(); // Stop Loading...
  }

  static Future onShareLink({required String link}) async {
    try {
      Share.share(link);
      printLog("Share Link Method Called Success...");
    } catch (e) {
      printLog("Share Link Method Error => $e");
    }
  }

  static Future onShareFile(
      {required String title, required String filePath}) async {
    try {
      Share.shareXFiles([XFile(filePath)], text: title);
      printLog("Share File Method Called Success...");
    } catch (e) {
      printLog("Share File Method Error => $e");
    }
  }
}
