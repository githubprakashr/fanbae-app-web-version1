import 'package:fanbae/model/getadsmodel.dart';
import 'package:fanbae/model/introscreenmodel.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/model/generalsettingmodel.dart';
import 'package:fanbae/model/loginmodel.dart';
import 'package:fanbae/webservice/apiservice.dart';

class GeneralProvider extends ChangeNotifier {
  SharedPre sharedPre = SharedPre();
  GeneralsettingModel generalsettingModel = GeneralsettingModel();
  IntroScreenModel introScreenModel = IntroScreenModel();
  LoginModel loginModel = LoginModel();
  bool socoalLoading = false;
  GetAdsModel getBannerAdsModel = GetAdsModel();
  GetAdsModel getInterstialAdsModel = GetAdsModel();
  GetAdsModel getRewardAdsModel = GetAdsModel();
  SuccessModel successModel = SuccessModel();
  bool loading = false;
  bool isProgressLoading = false;
  int duration = 0;
  /* Side Panel */
  bool isPanel = true;
  bool isNotification = false;
  bool isHover = false;
  String isHoverType = "";
  bool isSelect = false;
  String isSelectType = "";
  // bool isSelect = false;
  // String isSelectType = "";

  bool _isMobileMenuOpen = false;

  bool get isMobileMenuOpen => _isMobileMenuOpen;

  /* CustomAds Fields */
  bool showSkip = false;
  bool isCloseRewardAds = false;

  bool isLiteMode = false;
  String _currentPage = "home";
  String get currentPage => _currentPage;
  bool get isDarkMode => isLiteMode;

  getGeneralsetting() async {
    loading = true;
    generalsettingModel = await ApiService().generalsetting();
    loading = false;
    notifyListeners();
  }

  void toggleMobileMenu() {
    _isMobileMenuOpen = !_isMobileMenuOpen;
    notifyListeners();
  }

  void closeMobileMenu() {
    _isMobileMenuOpen = false;
    notifyListeners();
  }

  getIntroPages() async {
    loading = true;
    introScreenModel = await ApiService().getOnboardingScreen();
    loading = false;
    notifyListeners();
  }

  login(String type, String email, String mobile, String devicetype,
      String devicetoken, String countrycode, String countryName) async {
    loading = true;
    loginModel = await ApiService().login(
        type, email, mobile, devicetype, devicetoken, countrycode, countryName);
    loading = false;
    notifyListeners();
  }

  setLoading(loading) {
    isProgressLoading = loading;
    notifyListeners();
  }

  /* get All Custom Ads Start */

  getAds(type) async {
    loading = true;
    if (type == 1) {
      getBannerAdsModel = await ApiService().getAds(type);
    } else if (type == 2) {
      getInterstialAdsModel = await ApiService().getAds(type);
    } else if (type == 3) {
      getRewardAdsModel = await ApiService().getAds(type);
    } else {
      printLog("Invalid Type");
    }

    loading = false;
    notifyListeners();
  }

  /* Ads Click And View Count APi Start */
  getAdsViewClickCount(
      adsType, adsId, diviceType, diviceToken, type, contentId) async {
    loading = true;
    successModel = await ApiService().adsViewClickCount(
        adsType, adsId, diviceType, diviceToken, type, contentId);
    loading = false;
    notifyListeners();
  }

  /* Web App Methods */

  Future<void> getWebGeneralsetting(context) async {
    generalsettingModel = await ApiService().generalsetting();
    if (generalsettingModel.status == 200) {
      if (generalsettingModel.result != null) {
        for (var i = 0; i < (generalsettingModel.result?.length ?? 0); i++) {
          await sharedPre.save(
            generalsettingModel.result?[i].key.toString() ?? "",
            generalsettingModel.result?[i].value.toString() ?? "",
          );
        }
        /* Get Ads Init */
        if (context.mounted) {
          Utils.getCustomAdsStatus();
          Utils.getCurrencySymbol();
          Constant.userID = await sharedPre.read('userid');
          Constant.isAdsFree = await sharedPre.read('isAdsFree');
          Constant.isDownload = await sharedPre.read('isDownload');
          Constant.channelID = await sharedPre.read('channelid');
          Constant.channelName = await sharedPre.read('channelname');
          Constant.userImage = await sharedPre.read('image');
          Constant.isBuy = await sharedPre.read('userIsBuy');
          Constant.isCreator = await sharedPre.read('isCreator');
          printLog("***********userId==> ${Constant.userID}");
          printLog("***********channelID==> ${Constant.channelID}");
          printLog("***********channelName==> ${Constant.channelName}");
        }
      }
    }

    /* Live Streaming END */
    notifyListeners();
  }

  getOnOffSidePanel() {
    isPanel = !isPanel;
    notifyListeners();
  }

  isHoverSideMenu(String type, bool hover) {
    isHoverType = type;
    isHover = hover;
    notifyListeners();
  }

  void setCurrentPage(String page) {
    print('currentPage : $currentPage');
    print('newPage : $page');
    _currentPage = page;
    notifyListeners();
  }

  bool isSelected(String page) => _currentPage == page;

  clearHover() {
    isHover = false;
    isHoverType = "";
    notifyListeners();
  }

  getNotificationSectionShowHide(notification) {
    isNotification = notification;
    notifyListeners();
  }

  /* Reward Ads Methods */

  getSetRewardAds({close, skip}) {
    isCloseRewardAds = close;
    showSkip = skip;
    notifyListeners();
  }

  clearProvider() {
    isCloseRewardAds = false;
    showSkip = false;
  }
}
