import 'package:flutter/cupertino.dart';
import 'package:fanbae/utils/color.dart';

class Constant {
  final String baseurl = "https://fanbae.com/adminpanel/public/api/";
  // final String baseurl = "http://adminpanelmain.local/public/api/";lu

  static String userPanelUrl = "";

  static String socketUrl = "wss://fanbae.com:3000";

  /* Set Your Server IP Address With Specific Port */

  static String appName = "Fanbae";
  static String appPackageName = "com.fanbae.tv";

  static String appleAppId = "";
  static String initialCountryCode = "US";

  /* SherdPrefrence OneSignal App ID keyId */
  static const String oneSignalAppIdKey = "onesignal_apid";
  static const String vapIdKey = "vap_id_key";

  /* LiveStream START */
  static String? fakeVideoUrl =
      "https://diceyk6a7voy4.cloudfront.net/e78752a1-2e83-43fa-85ae-3d508be29366/hls/fitfest-sample-1_Ott_Hls_Ts_Avc_Aac_16x9_1280x720p_30Hz_6.0Mbps_qvbr.m3u8";
  static String? isFake;
  static int? liveAppId;
  static String? liveAppSign;
  static String? liveServerSecret;

  /* LiveStream END */

  /* DeepAR START */
  static String? effectAndroidLicenseKey;
  static String? effectIosLicenseKey;

  /* DeepAR END */

  /* Share */
  static String androidAppUrl =
      "https://play.google.com/store/apps/details?id=$appPackageName";

  static String iosAppUrl = "https://apps.apple.com/us/app/id$appleAppId";

// TabList Music Page
  static List tabList = [
    "home",
    "music",
    "radio",
    "podcast",
  ];

  static List tabIconList = [
    "ic_homeTab.png",
    "ic_musicTab.png",
    "ic_radioTab.png",
    "livestream.png",
  ];

  static String musicType = "1";
  static String podcastType = "2";
  static String radioType = "3";

// Profile Tab List
  static List profileTabList = [
    "video",
    // "music",
    // "podcast",
    // "playlist",
    "short",
    'Live',
    "feeds",
    //  "rent"
  ];

  static List profileTabIconList = [
    "profilevideo.png",
    // "profilemusic.png",
    // "profilepodcast.png",
    // "profileplaylist.png",
    "profileshorts.png",
    "live_profile.png",
    "profilefeeds.png",
  ];

// SubscriberList Tab List
  static List subscriberTabList = [
    "video",
    "podcast",
    "playlist",
    "short",
  ];

  // History Tab List
  static List historyTabList = [
    "video",
    "music",
    "podcast",
  ];

  static List historyTabIconList = [
    "ic_homeTab.png",
    "ic_musicTab.png",
    "ic_podcastTab.png",
  ];

  // Profile Tab List
  static List selectContentTabList = ["video", "music", "podcast", "Live"];

  static List watchlaterTabList = [
    "video",
    "Music",
    "Short",
    "Podcast",
    "Live"
  ];

  static List watchlaterTabIconList = [
    "ic_homeTab.png",
    "ic_musicTab.png",
    "ic_shorts.png",
    "ic_podcastTab.png",
    "livestream.png",
  ];

  List<String> getTransectionTabs() {
    if (Constant.isCreator == "1") {
      return [
        "Usage history",
        "Purchase history",
        "Withdrawal history",
      ];
    } else {
      return [
        "Usage history",
        "Purchase history",
      ];
    }
  }

  static int fixFourDigit = 1317;
  static int fixSixDigit = 161613;

  static String? userID;
  static String? userName;
  static String? channelID;
  static String? subscriptionPlan;
  static String? userPanelStatus;
  static String? channelName;
  static String? isCreator;
  static String? isDownload;
  static String? isAdsFree;
  static String? isBuy;
  static String? walletBalance;
  static String? userImage;
  static String currencySymbol = "";
  static String currency = "USD";
  static String? webToken;
  static String? vapId;
  static String? themeMode;

  static String fullname = "FullName";
  static String channelname = "Channel Name";
  static String email = "Email";
  static String password = "Password";
  static String mobile = "Mobile";

  /* Show Ad By Type */
  static String bannerAdType = "bannerAd";
  static String rewardAdType = "rewardAd";
  static String interstialAdType = "interstialAd";

  /* Search ContentType */
  static String videoSearch = "1";
  static String musicSearch = "2";

  /*  ============================================== Custom Ads Helper Fields Start ============================================== */
  static String totalBalance = "";

  // static bool? isPremiumBuy;
  static String? diviceToken;
  static String? diviceType;

  /* Banner */
  static String? banneradStatus;
  static String? banneradCPV;
  static String? banneradCPC;

  /* Interstital */
  static String? interstitaladStatus;
  static String? interstitaladCPV;
  static String? interstitaladCPC;

  /* Reward */
  static String? rewardadStatus;
  static String? rewardadCPV;
  static String? rewardadCPC;

  /* Assets Folder Image Path */
  static String? imageFolderPath = "assets/images/";
  static String? videoImagePath = "assets/videoicon/";
  static const assetsEffectPath = "assets/effects/";

  /* yourappname ContentType */
  static String? videoType = "1";
  static String? shortType = "3";

  static String darkMode = 'true';
  static LinearGradient gradientColor =
      const LinearGradient(colors: [button1color, button2color]);
  static LinearGradient buttonGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xff0fe3ef), Color(0xff0f3caa)]);
  static SweepGradient sweepGradient =
      const SweepGradient(startAngle: 0.0, endAngle: 3.14 * 2, colors: [
    Color(0xff09c6f1),
    Color(0xFF01DED1),
    Color(0xffd64ea3),
    Color(0xff5500ff),
  ]);

  static SweepGradient sweepGradientpack =
      const SweepGradient(startAngle: 0.0, endAngle: 3.14 * 2, colors: [
    Color(0xFF150D26),
    Color(0xFFE67025),
    Color(0xFFE93276),
    Color(0xFF2D00F7),
  ]);

  /*  ============================================== Custom Ads Helper Fields End ============================================== */

  /* Download config */
  static String bgEncryptDecryptTask = 'encrypt_decrypt_task';
  static String hiveDownloadBox = 'DOWNLOADS';
  static String hiveSeasonDownloadBox = 'DOWNLOAD_SEASON';
  static String hiveEpiDownloadBox = 'DOWNLOAD_EPISODE';
  static String videoDownloadPort = 'video_downloader_send_port';
  static String showDownloadPort = 'show_downloader_send_port';
  static String hawkVIDEOList = "myVideoList_";
  static String hawkKIDSVIDEOList = "myKidsVideoList_";
  static String hawkSHOWList = "myShowList_";
  static String hawkSEASONList = "mySeasonList_";
  static String hawkEPISODEList = "myEpisodeList_";
/* Download config */
}
