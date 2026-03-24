import 'dart:async';

import 'package:fanbae/main.dart';
import 'package:fanbae/pages/app_update_screen.dart';
import 'package:fanbae/pages/feeds.dart';
import 'package:fanbae/pages/maintenance.dart';
import 'package:fanbae/provider/homeprovider.dart';
import 'package:fanbae/utils/adhelper.dart';
import 'package:fanbae/utils/app_gate_service.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/pages/bottombar.dart';
import 'package:fanbae/pages/intro.dart';
import 'package:fanbae/provider/generalprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../webservice/socketmanager.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  SharedPre sharedpre = SharedPre();
  late HomeProvider homeProvider;
  late GeneralProvider splashdata;
  late SocketManager socketManager;

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    splashdata = Provider.of<GeneralProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isCheckFirstTime();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      backgroundColor: appbgcolor,
      body: Center(
        child: Image.asset(
          'assets/images/loading.gif',
          height: 150,
          width: 150,
        ),
      ),
    );
  }

  void socketIO() {
    socketManager = SocketManager();

    if (Constant.userID != null) {
      debugPrint("✅ Socket connected, joining user room: ${Constant.userID}");
      socketManager.connectWithUserId(Constant.userID!);
      socketManager.setUserId(Constant.userID!); // Use the new method
    } else {
      debugPrint("❌ Socket disconnectedddddddddddddddd");
    }
  }

  Future isCheckFirstTime() async {
    await splashdata.getGeneralsetting();

    if (!splashdata.loading) {
      final generalSettings = splashdata.generalsettingModel.result ?? [];

      for (var i = 0; i < generalSettings.length; i++) {
        sharedpre.save(
          generalSettings[i].key ?? "",
          generalSettings[i].value ?? "",
        );
      }
      Utils.getCurrencySymbol();
      Constant.userID = await sharedpre.read('userid');
      Constant.userName = await sharedpre.read('fulname');
      Constant.isAdsFree = await sharedpre.read('isAdsFree');
      Constant.isDownload = await sharedpre.read('isDownload');
      Constant.channelID = await sharedpre.read('channelid');
      Constant.channelName = await sharedpre.read('channelname');
      Constant.userImage = await sharedpre.read('image');
      Constant.isBuy = await sharedpre.read('userIsBuy');
      Constant.isCreator = await sharedpre.read('isCreator');

      printLog("Userid===>${Constant.userID}");
      printLog("Channalid===>${Constant.channelID}");
      printLog("isAdsfree===>${Constant.isAdsFree}");
      printLog("isDownload===>${Constant.isDownload}");

      Utils.saveLiveStreamARKey();
      socketIO();

      String? seen = await sharedpre.read("seen") ?? "";
      /* Get Ads Init */
      if (mounted && !kIsWeb) {
        AdHelper.getAds(context);
        Utils.getCustomAdsStatus();
      }

      final appGateDecision = await AppGateService.evaluate(generalSettings);
      if (!mounted) return;

      if (appGateDecision.isMaintenance) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return MaintenanceScreen(decision: appGateDecision);
            },
          ),
        );
        return;
      }

      if (appGateDecision.isForceUpdate) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AppUpdateScreen(decision: appGateDecision);
            },
          ),
        );
        return;
      }

      if (kIsWeb) {
        final Widget webLandingPage = ResponsiveHelper.checkIsWeb(context)
            ? const Feeds()
            : const Bottombar();
        await _navigateToNextScreen(
          webLandingPage,
          appGateDecision: appGateDecision,
        );
      } else if (seen == "1") {
        await homeProvider.setLoading(true);
        await _navigateToNextScreen(
          const Bottombar(),
          appGateDecision: appGateDecision,
        );
      } else {
        await splashdata.getIntroPages();
        if (!splashdata.loading) {
          if ((splashdata.introScreenModel.status == 200) &&
              splashdata.introScreenModel.result != null &&
              (splashdata.introScreenModel.result?.length ?? 0) > 0) {
            await _navigateToNextScreen(
              Intro(
                introList: splashdata.introScreenModel.result ?? [],
              ),
              appGateDecision: appGateDecision,
            );
          } else {
            await homeProvider.setLoading(true);
            await _navigateToNextScreen(
              const Bottombar(),
              appGateDecision: appGateDecision,
              delay: const Duration(seconds: 5),
            );
          }
        }
      }
    }
  }

  Future<void> _navigateToNextScreen(
    Widget nextScreen, {
    required AppGateDecision appGateDecision,
    Duration delay = Duration.zero,
  }) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    if (!mounted) return;

    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return nextScreen;
        },
      ),
    );

    if (!appGateDecision.isOptionalUpdate) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dialogContext = navigatorKey.currentContext;
      if (dialogContext == null) return;
      unawaited(
        AppGateService.showOptionalUpdateDialog(dialogContext, appGateDecision),
      );
    });
  }
}
