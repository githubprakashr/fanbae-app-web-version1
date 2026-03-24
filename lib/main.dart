// main.dart
// Import web helper — resolves to web_real.dart on web, web_compat.dart otherwise
import 'package:fanbae/pages/contentdetail.dart';
import 'package:fanbae/pages/showpostcontent.dart';
import 'package:fanbae/utils/adhelper.dart';
import 'package:fanbae/utils/musicmanager.dart';
import 'package:fanbae/webpages/web_compat.dart'
    if (dart.library.html) 'package:fanbae/webpages/web_real.dart';
import 'dart:developer';
import 'dart:ui';
import 'package:app_links/app_links.dart';
import 'package:fanbae/model/feedslistmodel.dart';
import 'package:fanbae/livestream/golivepreviewprovider.dart';
import 'package:fanbae/model/feedslistmodel.dart' as feeds;

import 'package:fanbae/livestream/livestreamprovider.dart';
import 'package:fanbae/livestream/liveuserlistprovider.dart';
import 'package:fanbae/model/download_item.dart';
import 'package:fanbae/pages/bottombar.dart';
import 'package:fanbae/pages/shorts.dart';
import 'package:fanbae/provider/allcontentprovider.dart';
import 'package:fanbae/provider/contentdetailprovider.dart';
import 'package:fanbae/provider/createvideoprovider.dart';
import 'package:fanbae/provider/feedprovider.dart';
import 'package:fanbae/provider/membershipplanprovider.dart';
import 'package:fanbae/provider/networkProvider.dart';
import 'package:fanbae/provider/requestcreatorprovider.dart';
import 'package:fanbae/provider/subscribedchannelprovider.dart';
import 'package:fanbae/provider/themeprovider.dart';
import 'package:fanbae/provider/uploadfeedprovider.dart';
import 'package:fanbae/provider/videodownloadprovider.dart';
import 'package:fanbae/provider/withdrawalrequestprovider.dart';
import 'package:fanbae/provider/galleryvideoprovider.dart';
import 'package:fanbae/provider/getmusicbycategoryprovider.dart';
import 'package:fanbae/provider/getmusicbylanguageprovider.dart';
import 'package:fanbae/provider/historyprovider.dart';
import 'package:fanbae/provider/likevideosprovider.dart';
import 'package:fanbae/provider/musicdetailprovider.dart';
import 'package:fanbae/provider/notificationprovider.dart';
import 'package:fanbae/provider/playerprovider.dart';
import 'package:fanbae/provider/playlistcontentprovider.dart';
import 'package:fanbae/provider/playlistprovider.dart';
import 'package:fanbae/provider/postvideoprovider.dart';
import 'package:fanbae/provider/rentprovider.dart';
import 'package:fanbae/provider/seeallprovider.dart';
import 'package:fanbae/provider/settingprovider.dart';
import 'package:fanbae/provider/subscriptionprovider.dart';
import 'package:fanbae/provider/videopreviewprovider.dart';
import 'package:fanbae/provider/videorecordprovider.dart';
import 'package:fanbae/provider/videoscreenprovider.dart';
import 'package:fanbae/provider/walletprovider.dart';
import 'package:fanbae/provider/watchlaterprovider.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/firebase_service.dart';
import 'package:fanbae/utils/notification_service.dart';
import 'package:fanbae/utils/pusher_beams_service.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/video_audio_call/videocallmanager.dart';
import 'package:fanbae/videorecord/createreelsprovider.dart';
import 'package:fanbae/webservice/socketmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:fanbae/pages/splash.dart';
import 'package:fanbae/provider/detailsprovider.dart';
import 'package:fanbae/provider/generalprovider.dart';
import 'package:fanbae/provider/homeprovider.dart';
import 'package:fanbae/provider/searchprovider.dart';
import 'package:fanbae/provider/profileprovider.dart';
import 'package:fanbae/provider/musicprovider.dart';
import 'package:fanbae/provider/updateprofileprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/widget/noNetworkPage.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'app_theme.dart';
import 'provider/shortprovider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final FirebaseService firebaseService = FirebaseService();

// Top-level to capture initial web link before runApp
String? _initialWebDeepLink;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Capture web deep link injected by index.html BEFORE runApp
  if (kIsWeb) {
    try {
      _initialWebDeepLink = getDeepLinkWeb();
      // normalize empty -> null
      if (_initialWebDeepLink != null && _initialWebDeepLink!.trim().isEmpty) {
        _initialWebDeepLink = null;
      }
      print(
          "Captured initial web deep link (pre-runApp): $_initialWebDeepLink");
    } catch (e) {
      _initialWebDeepLink = null;
    }
  }

  VideoCallManager().initializeEngine();

  if (!kIsWeb) {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(DownloadItemAdapter());
  }

  await firebaseService.initFirebase();
  // MOVED: Notification init after UI loads to prevent black screen
  // await NotificationService().initLocalNotification(navigatorKey);

  // MOVED: Pusher Beams init after UI loads
  // await PusherBeamsService().initialize(navigatorKey);

  await JustAudioBackground.init(
    androidNotificationChannelId: Constant.appPackageName,
    androidNotificationChannelName: Constant.appName,
    androidNotificationOngoing: true,
    notificationColor: appbgcolor,
  );

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  /* Multilanguage Support */
  await Locales.init([
    'en',
    'hi',
    'af',
    'ar',
    'de',
    'es',
    'fr',
    'gu',
    'id',
    'nl',
    'pt',
    'sq',
    'tr',
    'vi'
  ]);
  /* Multilanguage Support */

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NetworkProvider()),
          ChangeNotifierProvider(create: (_) => GeneralProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => DetailsProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => SearchProvider()),
          ChangeNotifierProvider(create: (_) => UpdateprofileProvider()),
          ChangeNotifierProvider(create: (_) => MusicProvider()),
          ChangeNotifierProvider(create: (_) => ShortProvider()),
          ChangeNotifierProvider(create: (_) => VideoScreenProvider()),
          ChangeNotifierProvider(create: (_) => MusicDetailProvider()),
          ChangeNotifierProvider(create: (_) => PlaylistProvider()),
          ChangeNotifierProvider(create: (_) => WatchLaterProvider()),
          ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
          ChangeNotifierProvider(create: (_) => LikeVideosProvider()),
          ChangeNotifierProvider(create: (_) => HistoryProvider()),
          ChangeNotifierProvider(create: (_) => ContentDetailProvider()),
          ChangeNotifierProvider(create: (_) => SeeAllProvider()),
          ChangeNotifierProvider(create: (_) => GetMusicByCategoryProvider()),
          ChangeNotifierProvider(create: (_) => GetMusicByLanguageProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => SettingProvider()),
          ChangeNotifierProvider(create: (_) => RentProvider()),
          ChangeNotifierProvider(create: (_) => AllContentProvider()),
          ChangeNotifierProvider(create: (_) => PlayerProvider()),
          ChangeNotifierProvider(create: (_) => PlaylistContentProvider()),
          ChangeNotifierProvider(create: (_) => VideoRecordProvider()),
          ChangeNotifierProvider(create: (_) => VideoPreviewProvider()),
          ChangeNotifierProvider(create: (_) => PostVideoProvider()),
          ChangeNotifierProvider(create: (_) => GalleryVideoProvider()),
          ChangeNotifierProvider(create: (_) => WithdrawalRequestProvider()),
          ChangeNotifierProvider(create: (_) => WalletProvider()),
          ChangeNotifierProvider(create: (_) => SubscribedChannelProvider()),
          ChangeNotifierProvider(create: (_) => VideoDownloadProvider()),
          ChangeNotifierProvider(create: (_) => UploadfeedProvider()),
          ChangeNotifierProvider(create: (_) => GoLivePreviewProvider()),
          ChangeNotifierProvider(create: (_) => LiveStreamProvider()),
          ChangeNotifierProvider(create: (_) => LiveUserListProvider()),
          ChangeNotifierProvider(create: (_) => CreateReelsProvider()),
          ChangeNotifierProvider(create: (_) => VideoPreviewProvider()),
          ChangeNotifierProvider(create: (_) => FeedProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => RequestCreatorProvider()),
          ChangeNotifierProvider(create: (_) => MembershipPlanProvider()),
          ChangeNotifierProvider(create: (_) => CreateVideoProvider()),
          ChangeNotifierProvider(create: (_) => VideoCallManager()),
          ChangeNotifierProvider(create: (_) => LiveStreamProvider()),
        ],
        child: const MyApp(),
      ),
    );
  });

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: black,
      statusBarColor: appbgcolor,
    ),
  );
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late io.Socket socket;
  late SocketManager socketManager;
  final SocketManager _socketManager = SocketManager();
  final VideoCallManager _videoCallManager = VideoCallManager();
  final _appLinks = AppLinks();
  final NoScreenshot _noScreenshot = NoScreenshot();
  final MusicManager musicManager = MusicManager();
  bool _isScreenshotDisabled = true;

  @override
  void initState() {
    super.initState();

    _processInitialWebLinkIfAny();

    getApi();
    socketIO();
    _initializeScreenshotProtection();

    // Initialize notifications AFTER first frame to prevent black screen
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService().initLocalNotification(navigatorKey);

      // Pusher Beams is mobile-only
      if (!kIsWeb) {
        await PusherBeamsService().initialize(navigatorKey);
      }
    });

    // 3) Mobile deep link listener
    _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingUri(uri);
    }, onError: (err) {
      print("Error listening to uriLinkStream: $err");
    });

    // 4) Also check initial mobile link (if app launched from deep link)
    _checkInitialMobileLink(_appLinks);

    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _processInitialWebLinkIfAny() async {
    if (!kIsWeb) return;
    try {
      if (_initialWebDeepLink != null) {
        final raw = _initialWebDeepLink!;
        final uri = Uri.tryParse(raw);
        if (uri != null) {
          // schedule after first frame so Navigator is available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleIncomingUri(uri);
          });
        }
        // clear to avoid double processing
        _initialWebDeepLink = null;
      } else {
        // fallback: if server forwarded path to Uri.base
        final fallback = Uri.base;
        if (fallback.path != '/' || fallback.queryParameters.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleIncomingUri(fallback);
          });
        }
      }
    } catch (e) {
      print("Error processing initial web deep link: $e");
    }
  }

// Get initial mobile deep link (if app launched via link)
  Future<void> _checkInitialMobileLink(AppLinks appLinks) async {
    try {
      final initial = await appLinks.getInitialLink();
      if (initial != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleIncomingUri(initial);
        });
      }
    } catch (e) {
      print("Error getting initial mobile link: $e");
    }
  }

  void _handleIncomingUri(Uri uri) {
    try {
      print("DEEP LINK RECEIVED -> $uri");
      // We reuse the same logic you used previously
      if (uri.path == '/shorts') {
        final vParam = uri.queryParameters['s'];
        if (vParam != null && vParam.isNotEmpty) {
          final parts = vParam.split('/');
          if (parts.length >= 3) {
            final channelId = parts[0];
            final userId = parts[1];
            final index = parts[2];
            final uniqueId = parts.length > 3 ? parts[3] : null;

            Future.delayed(const Duration(milliseconds: 500), () {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => Shorts(
                    channelId: channelId,
                    userId: userId,
                    initialIndex: int.tryParse(index) ?? 0,
                    shortType: "profile",
                  ),
                ),
              );
            });
          }
        }
      } else if (uri.path == '/video') {
        final vParam = uri.queryParameters['v'];
        if (vParam != null && vParam.isNotEmpty) {
          final parts = vParam.split('/');
          if (parts.length >= 2) {
            final id = parts[0];
            final isComment = parts[1];
            Future.delayed(const Duration(milliseconds: 500), () {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => const Scaffold(
                    backgroundColor: Colors.black,
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Utils.moveToDetail(
                  navigatorKey.currentContext!,
                  0,
                  false,
                  id,
                  false,
                  '1',
                  int.tryParse(isComment),
                );
              });
            });
          }
        }
      } else if (uri.path == '/live') {
        final vParam = uri.queryParameters['l'];
        if (vParam != null && vParam.isNotEmpty) {
          final parts = vParam.split('/');
          if (parts.length >= 2) {
            final id = parts[0];
            final isComment = parts[1];
            Future.delayed(const Duration(milliseconds: 500), () {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => const Scaffold(
                    backgroundColor: Colors.black,
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Utils.moveToDetail(
                  navigatorKey.currentContext!,
                  0,
                  false,
                  id,
                  false,
                  '7',
                  int.tryParse(isComment),
                );
              });
            });
          }
        }
      } else if (uri.path == '/post') {
        final pParam = uri.queryParameters['p']; // example → "3/5"

        if (pParam != null && pParam.isNotEmpty) {
          final parts = pParam.split('/');

          final postId = parts[0]; // "3"
          // final index = parts.length > 1 ? parts[1] : ""; // optional

          Future.delayed(const Duration(milliseconds: 500), () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(child: CircularProgressIndicator()),
                ),
              ),
            );

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final feedProvider = Provider.of<FeedProvider>(
                  navigatorKey.currentContext!,
                  listen: false);

              // FETCH FEEDS
              await feedProvider.getFeeds('for_you');

              // FIND FEED BY ID (after filter applied)
              final int matchedIndex = feedProvider.feeds!.indexWhere(
                (element) => element.id.toString() == postId,
              );

              if (matchedIndex != -1) {
                final feed = feedProvider.feeds![matchedIndex];

                Navigator.push(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (_) => ShowPostContent(
                      clickPos: matchedIndex,
                      title: feed.title ?? "",
                      type: "feed",
                      description: feed.descripation,
                      attachment: feed.attachment,
                      userId: feed.userId,
                      id: feed.id,
                      payCoin: feed.payCoin,
                      payContent: feed.payContent,
                      postContent: feed.postContent ?? [],
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                  const SnackBar(content: Text("Post not found")),
                );
              }
            });
          });
        }
      } else if (uri.path == '/music') {
        final pParam = uri.queryParameters['m'];

        if (pParam != null && pParam.isNotEmpty) {
          final parts = pParam.split('/');

          final postId = parts[0];

          Future.delayed(const Duration(milliseconds: 500), () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(child: CircularProgressIndicator()),
                ),
              ),
            );

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final feedProvider = Provider.of<FeedProvider>(
                  navigatorKey.currentContext!,
                  listen: false);

              // FETCH FEEDS
              await feedProvider.getFeeds('for_you');

              // FIND FEED BY ID (after filter applied)
              final int matchedIndex = feedProvider.feeds!.indexWhere(
                (element) => element.id.toString() == postId,
              );

              print(
                  'value : ${feedProvider.feeds!.indexWhere((element) => element.id.toString() == postId)}');

              print('matchedIndex: $matchedIndex');
              if (matchedIndex != -1) {
                final feed = feedProvider.feeds![matchedIndex];
                print(feed.contentType.toString());

                List<feeds.Result> allMusicFeed = feedProvider.feeds!
                    .where((item) => item.feedType?.toLowerCase() == 'music')
                    .toList();

                print('allPodcastFeed: $allMusicFeed');
                AdHelper.showFullscreenAd(
                    navigatorKey.currentContext!, Constant.rewardAdType, () {
                  playAudio(
                    playingType: feed.contentType.toString(),
                    episodeid: feed.id.toString(),
                    contentid: feed.id.toString(),
                    position: matchedIndex,
                    sectionBannerList: allMusicFeed,
                    contentName: feed.title.toString(),
                    isBuy: feed.isBuy.toString(),
                  );
                });
                navigatorKey.currentState?.push(
                  MaterialPageRoute(builder: (context) => const Bottombar()),
                );
              } else {
                ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                  const SnackBar(content: Text("Post not found")),
                );
              }
            });
          });
        }
      } else {
        print("Unhandled deep link path: ${uri.path}");
      }
    } catch (e, st) {
      print("Error handling incoming uri: $e\n$st");
    }
  }

  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    String? podcastimage,
    String? contentUserid,
    required int position,
    dynamic sectionBannerList,
    dynamic playlistImages,
    required String contentName,
    required String? isBuy,
  }) async {
    if (playingType == "2") {
      print('b vnfnh');
      musicManager.setInitialMusic(position, playingType, sectionBannerList,
          contentid, addView(playingType, contentid), false, 0, isBuy ?? "");
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ContentDetail(
              contentType: playingType,
              contentUserid: contentUserid ?? "",
              contentImage: podcastimage ?? "",
              contentName: contentName,
              playlistImage: playlistImages ?? [],
              contentId: contentid,
              isBuy: isBuy ?? "",
            );
          },
        ),
      );
    }
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      socketManager.onAppResume();
    }
  }

  Future<void> _initializeScreenshotProtection() async {
    try {
      bool status = await _noScreenshot.screenshotOff();
      setState(() {
        _isScreenshotDisabled = status;
      });
    } catch (e) {
      print('Error initializing screenshot protection: $e');
    }
  }

  getApi() async {
    final settingProvider =
        Provider.of<SettingProvider>(context, listen: false);
    await settingProvider.getSocialLink();
    await settingProvider.getPages();

    /* Initialize Hive */
    if (!kIsWeb) {
      await Utils.initializeHiveBoxes(context);
    }
  }

  void socketIO() {
    socketManager = SocketManager();
    socket = socketManager.socket!;

    if (Constant.userID != null) {
      print("✅ Socket connected, joining user room: ${Constant.userID}");
      socketManager.setUserId(Constant.userID!);
      socketManager.setupVideoCallListeners(context, _videoCallManager);
    } else {
      print("❌ Socket disconnected");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor:
            Constant.darkMode == "true" ? const Color(0xff05060F) : pureWhite,
        statusBarIconBrightness:
            Constant.darkMode == "true" ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            Constant.darkMode == "true" ? Brightness.dark : Brightness.light,
      ),
      child: LocaleBuilder(
        builder: (locale) => MaterialApp(
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          localizationsDelegates: Locales.delegates,
          supportedLocales: Locales.supportedLocales,
          locale: locale,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.lightTheme(),
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return Consumer<NetworkProvider>(
              builder: (context, networkProvider, _) {
                final route = ModalRoute.of(context)?.settings.name ?? '';
                final isOnDownloadsPage = route == 'MyDownloads';

                return Stack(
                  children: [
                    ResponsiveBreakpoints.builder(
                      child: child!,
                      breakpoints: const [
                        Breakpoint(start: 0, end: 450, name: MOBILE),
                        Breakpoint(start: 451, end: 800, name: TABLET),
                        Breakpoint(start: 801, end: 1920, name: DESKTOP),
                        Breakpoint(
                            start: 1921, end: double.infinity, name: '4K'),
                      ],
                    ),
                    if (!networkProvider.isConnected &&
                        !isOnDownloadsPage &&
                        !networkProvider.isNavigatingToDownloads)
                      const NoInternetSheet(),
                  ],
                );
              },
            );
          },
          home: const Splash(),
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown,
              PointerDeviceKind.trackpad
            },
          ),
        ),
      ),
    );
  }
}
