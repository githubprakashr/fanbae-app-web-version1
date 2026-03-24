import 'dart:async';
import 'dart:math' as math;

import 'dart:developer';
import 'package:fanbae/livestream/comment.dart';
import 'package:fanbae/livestream/livestreamimage.dart';
import 'package:fanbae/livestream/livestreamprovider.dart';
import 'package:fanbae/pages/bottombar.dart';
import 'package:fanbae/pages/reelsplayer.dart';
import 'package:fanbae/subscription/adspackage.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/socketmanager.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class LiveStream extends StatefulWidget {
  final String? userId, image, name, userName, roomId, isFake, videoUrl;
  final bool isHost;

  const LiveStream({
    super.key,
    required this.isFake,
    required this.videoUrl,
    required this.userId,
    required this.roomId,
    required this.image,
    required this.name,
    required this.userName,
    required this.isHost,
  });

  @override
  State<LiveStream> createState() => LiveStreamState();
}

class LiveStreamState extends State<LiveStream> with WidgetsBindingObserver {
  late LiveStreamProvider liveStreamProvider;
  SocketManager socketManager = SocketManager();
  io.Socket? socket;
  bool isHost = false;
  Widget? localView;
  int? localViewID;
  Widget? remoteView;
  int? remoteViewID;
  String roomId = "";
  final FocusNode _focusNode = FocusNode();
  TextEditingController commentController = TextEditingController();
  late ScrollController _giftScrollController;
  final List<String> _gifts = [];

  List<String> get gifts => _gifts;

  // Logo-related variables
  Map<String, dynamic>? _logoConfig;
  final bool _showLogo = true;
  final String _defaultLogoUrl =
      'https://Fanbae.tv/admin_panel/storage/app/public/app/30_07_2025_13_6889a1011d37d.png';

  @override
  void initState() {
    log("isFake========> ${widget.isFake}");
    WidgetsBinding.instance.addObserver(this);
    liveStreamProvider =
        Provider.of<LiveStreamProvider>(context, listen: false);
    _giftScrollController = ScrollController();
    _giftScrollController.addListener(_scrollListener);
    isHost = widget.isHost;
    if (isHost) {
      roomId = Utils.generateRoomId();

      log("===> roomId:$roomId ==> isHost:$isHost");
    } else {
      roomId = widget.roomId ?? "";
      log("===> roomIdelse:$roomId ==> isHost:$isHost");
    }

    // Initialize logo config
    _logoConfig = {
      'url': _defaultLogoUrl,
      'position': 'center',
      'width': 100.0,
      'opacity': 0.8,
    };

    if (isHost || widget.isFake == "0") {
      startListenEvent();
      loginRoom();
    }
    socketIO();

    if (isHost) {
      liveStreamProvider.onChangeTime();
    } else {
      liveStreamProvider.commentList?.clear();
      if (widget.isFake == "0") {
        Timer(
          const Duration(seconds: 5),
          () {
            if (remoteView == null) {
              if (!mounted) return;
              if (Navigator.canPop(context)) {
                printLog("CallBack");
                Navigator.pop(context);
              }
            }
          },
        );
      }
    }
    super.initState();
    if (widget.isFake == "1") {
      liveStreamProvider.addFakeComment(isFake: widget.isFake);
    }
  }

  destroyEngine() async {
    await ZegoExpressEngine.destroyEngine();
  }

  void _setupLogoListeners() {
    socket?.on('streamConfig', (data) {
      if (mounted) {
        setState(() {
          _logoConfig = {
            'url': data['logo'] ?? _defaultLogoUrl,
            'position': data['position'] ?? 'center',
            'width': (data['width'] != null)
                ? double.tryParse(
                        data['width'].toString().replaceAll('%', '')) ??
                    100.0
                : 100.0,
            'opacity': data['opacity'] ?? 0.8,
          };
        });
      }
    });
  }

  void socketIO() {
    SocketManager socketManager = SocketManager();
    socket = socketManager.socket;

    if (socket?.connected == true) {
      /* On Methods */
      _setupLogoListeners();
      socketManager.removeListner();
      socketManager.totalUserCount(livestreamprovider: liveStreamProvider);
      socketManager.receiveComment(livestreamprovider: liveStreamProvider);
      socketManager.receiveGift(livestreamprovider: liveStreamProvider);

      socketManager.roomDelete(widget.roomId, () {
        logoutRoom();
        liveStreamProvider.clearComment();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const Bottombar(
                    isLiveStream: true,
                  )),
          (Route<dynamic> route) => false,
        ).then(
          (value) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const Bottombar(
                        isLiveStream: true,
                      )),
            );
          },
        );
      });

      // Setup logo listeners after socket is confirmed connected

      /* Emit Methods */
      if (isHost) {
        socketManager.goLive(widget.userId, roomId);
      } else {
        socketManager.addView(widget.userId, roomId);
        // socket?.on('forceDisconnect', (data) {
        //   Navigator.pop(context); // or go back
        // });
      }
    } else {
      log("=====================Socket Not Connect====================");
    }
  }

  /* ======= Fetch All Gift Start ============ */

  _scrollListener() async {
    if (!_giftScrollController.hasClients) return;
    if (_giftScrollController.offset >=
            _giftScrollController.position.maxScrollExtent &&
        !_giftScrollController.position.outOfRange &&
        (liveStreamProvider.currentPage ?? 0) <
            (liveStreamProvider.totalPage ?? 0)) {
      await liveStreamProvider.setLoadMore(true);
      _fetchGift(liveStreamProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchGift(int? nextPage) async {
    printLog("isMorePage  ======> ${liveStreamProvider.isMorePage}");
    printLog("currentPage ======> ${liveStreamProvider.currentPage}");
    printLog("totalPage   ======> ${liveStreamProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await liveStreamProvider.getProfile(context, widget.userId);
    await liveStreamProvider.fetchGift((nextPage ?? 0) + 1);
    await liveStreamProvider.setLoadMore(false);
  }

  /* ======= Fetch All Gift Stop ============ */

  @override
  void dispose() {
    log("======>Call Dispose===>");
    if (isHost == false) {
      stopListenEvent();
    }
    WidgetsBinding.instance.removeObserver(this);
    if (isHost) {
      if (socket?.connected == true) {
        socketManager.endLive(widget.userId, roomId);
        liveStreamProvider.clearCount();
        liveStreamProvider.clearComment();
        destroyEngine();
      }
    } else {
      logoutRoom();
    }
    liveStreamProvider.clearComment();
    liveStreamProvider.isLivePage = false;

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("App lifecycle state: $state");

    if (state == AppLifecycleState.paused ||
        /*state == AppLifecycleState.inactive ||*/
        state == AppLifecycleState.detached) {
      debugPrint("App backgrounded or screen off — ending live...");

      if (isHost) {
        debugPrint('-------------------isHost--------------------------------');
        if (socket?.connected == true) {
          debugPrint(
              '-------------------isHost socket?.connected == true--------------------------------');
          socketManager.endLive(widget.userId, roomId);
        } else {
          debugPrint(
              '-------------------isHost socket?.connected == false--------------------------------');
          logoutRoom();
        }

        liveStreamProvider.clearCount();
        liveStreamProvider.clearComment();
        destroyEngine();
      } else {
        debugPrint('-------------------isHost--------------------------------');
        logoutRoom();
      }
    }
  }

  void _showGiftPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              MyText(
                text: 'Send Gift',
                color: Colors.white,
                fontsizeNormal: 18,
                fontwaight: FontWeight.bold,
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Consumer<LiveStreamProvider>(
                  builder: (context, provider, _) {
                    return GridView.builder(
                      controller: _giftScrollController,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: provider.giftList?.length ?? 0,
                      itemBuilder: (context, index) {
                        final gift = provider.giftList?[index];
                        return GestureDetector(
                          onTap: () {
                            socket?.emit('sendGift', {
                              'user_id': widget.userId,
                              'room_id': roomId,
                              'gift_id': gift?.id,
                            });
                            Navigator.pop(context);
                          },
                          child: Column(
                            children: [
                              MyNetworkImage(
                                imagePath: gift?.image ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(height: 5),
                              MyText(
                                text: gift?.name ?? '',
                                color: Colors.white,
                                fontsizeNormal: 12,
                              ),
                              MyText(
                                text: '${gift?.price} coins',
                                color: Colors.yellow,
                                fontsizeNormal: 10,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: colorPrimary,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: black,
        child: Stack(
          children: [
            isHost
                ? hostUI(liveScreen: localView ?? const SizedBox.shrink())
                : audienceUI(
                    liveScreen: remoteView ?? Utils.pageLoader(context),
                    liveRoomId: roomId,
                    liveUserId: widget.userId,
                  ),
            if (_showLogo && _logoConfig != null)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.1,
                left: MediaQuery.of(context).size.width * 0.05,
                child: Opacity(
                  opacity: _logoConfig!['opacity'],
                  child: MyNetworkImage(
                    imagePath: _logoConfig!['url'],
                    width: _logoConfig!['width'] * 1,
                    height: _logoConfig!['width'] * 1,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<ZegoRoomLoginResult> loginRoom() async {
    if (kIsWeb) {
      log('Zego login skipped on web platform');
      return ZegoRoomLoginResult(1, {});
    }

    final appId = Constant.liveAppId;
    final appSign = Constant.liveAppSign;
    if (appId == null || appSign == null || appSign.isEmpty) {
      log('Zego login skipped due to missing credentials');
      return ZegoRoomLoginResult(1, {});
    }
    try {
      await ZegoExpressEngine.destroyEngine();

      await ZegoExpressEngine.createEngineWithProfile(
        ZegoEngineProfile(
          appId,
          ZegoScenario.General,
          appSign: appSign,
          enablePlatformView: true,
        ),
      );

      final user = ZegoUser(widget.userId ?? "", widget.userName ?? "");

      ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()
        ..isUserStatusNotify = true;

      log("Attempting to login to room: $roomId");
      return await ZegoExpressEngine.instance
          .loginRoom(roomId, user, config: roomConfig)
          .then((ZegoRoomLoginResult loginRoomResult) {
        debugPrint('loginRoom result: ${loginRoomResult.errorCode}');
        if (loginRoomResult.errorCode == 0) {
          log("Login successful");
          if (isHost) {
            startPreview();
            startPublish();
          }
        } else {
          log("Login failed with error: ${loginRoomResult.errorCode}");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Login failed: ${loginRoomResult.errorCode}')));
        }
        return loginRoomResult;
      });
    } catch (e) {
      log("Exception in loginRoom: $e");
      return ZegoRoomLoginResult(1, {}); // Return error result
    }
  }

  Future<ZegoRoomLogoutResult> logoutRoom() async {
    stopPreview();
    stopPublish();
    return ZegoExpressEngine.instance.logoutRoom(roomId);
  }

  void startListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate =
        (roomID, updateType, List<ZegoUser> userList) {
      debugPrint(
          'onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}');
    };

    ZegoExpressEngine.onRoomStreamUpdate =
        (roomID, updateType, List<ZegoStream> streamList, extendedData) {
      debugPrint(
          'onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}, extendedData: $extendedData');
      if (updateType == ZegoUpdateType.Add) {
        for (final stream in streamList) {
          startPlayStream(stream.streamID);
        }
      } else {
        for (final stream in streamList) {
          stopPlayStream(stream.streamID);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const Bottombar(
                      isLiveStream: true,
                    )),
            (Route<dynamic> route) => false,
          ).then(
            (value) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const Bottombar(
                          isLiveStream: true,
                        )),
              );
            },
          );
        }
      }
    };
    ZegoExpressEngine.onRoomStateUpdate =
        (roomID, state, errorCode, extendedData) {
      debugPrint(
          'onRoomStateUpdate: roomID: $roomID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };

    ZegoExpressEngine.onPublisherStateUpdate =
        (streamID, state, errorCode, extendedData) {
      debugPrint(
          'onPublisherStateUpdate: streamID: $streamID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };
  }

  void stopListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
  }

  Future<void> startPreview() async {
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      localViewID = viewID;

      ZegoCanvas previewCanvas = ZegoCanvas(
        viewID,
        viewMode: ZegoViewMode.AspectFill,
      );

      ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
    }).then((canvasViewWidget) {
      setState(() {
        localView = canvasViewWidget;
      });
    });
  }

  Future<void> stopPreview() async {
    ZegoExpressEngine.instance.stopPreview();
    if (localViewID != null) {
      await ZegoExpressEngine.instance.destroyCanvasView(localViewID!);
      localViewID = null;
      localView = null;
    }
  }

  Future<void> startPublish() async {
    String streamID = '${roomId}_${widget.userId}_call';
    return ZegoExpressEngine.instance.startPublishingStream(streamID);
  }

  Future<void> stopPublish() async {
    return ZegoExpressEngine.instance.stopPublishingStream();
  }

  Future<void> startPlayStream(String streamID) async {
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      remoteViewID = viewID;
      ZegoCanvas canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoPlayerConfig config = ZegoPlayerConfig.defaultConfig();
      config.resourceMode = ZegoStreamResourceMode.Default;
      ZegoExpressEngine.instance
          .enableCamera(true, channel: ZegoPublishChannel.Main);
      ZegoExpressEngine.instance
          .startPlayingStream(streamID, canvas: canvas, config: config);
    }).then((canvasViewWidget) {
      setState(() => remoteView = canvasViewWidget);
    });
  }

  Future<void> stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
    if (remoteViewID != null) {
      ZegoExpressEngine.instance.destroyCanvasView(remoteViewID!);
      setState(() {
        remoteViewID = null;
        remoteView = null;
      });
    }
  }

/* ================= UI Start ===============  */

  Widget hostUI({required liveScreen}) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        showExitDialog(context);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          liveScreen,
          Positioned(
            bottom: 0,
            child: Container(
              height: 400,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(color: transparent),
            ),
          ),
          Positioned(
            top: 45,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<LiveStreamProvider>(
                            builder: (context, livestreamprovider, child) {
                          return Container(
                            height: 30,
                            width: 76,
                            decoration: BoxDecoration(
                              gradient: Constant.buttonGradient,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.visibility,
                                  size: 20,
                                  color: pureWhite,
                                ),
                                const SizedBox(width: 8),
                                MyText(
                                    color: pureWhite,
                                    multilanguage: false,
                                    text: livestreamprovider.totalViewCount
                                        .toString(),
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w700,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          );
                        }),
                        Consumer<LiveStreamProvider>(
                            builder: (context, livestreamprovider, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timer,
                                size: 20,
                                color: white,
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 2, right: 35),
                                child: MyText(
                                    color: white,
                                    multilanguage: false,
                                    text:
                                        livestreamprovider.onConvertSecondToHMS(
                                            livestreamprovider.countTime),
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textDesc,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            ],
                          );
                        }),
                        circleIconWithButton(
                          color: Color(0xff0241dd),
                          icon: "ic_close.webp",
                          padding: const EdgeInsets.all(8),
                          circleSize: 38,
                          iconColor: pureWhite,
                          onTap: () {
                            showExitDialog(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Consumer<LiveStreamProvider>(
                        builder: (context, livestreamprovider, child) {
                      return circleIconWithButton(
                        circleSize: 40,
                        iconSize: 20,
                        color: Color(0xff0fe3ef),
                        icon: livestreamprovider.isMicOn
                            ? "ic_mic_on.webp"
                            : "ic_mic_off.webp",
                        iconColor: pureWhite,
                        onTap: livestreamprovider.onSwitchMic,
                      );
                    }),
                    const SizedBox(height: 20),
                    Consumer<LiveStreamProvider>(
                        builder: (context, livestreamprovider, child) {
                      return circleIconWithButton(
                        circleSize: 40,
                        iconSize: 20,
                        color: Color(0xff0f3caa),
                        icon: "ic_rotate_camera.webp",
                        iconColor: pureWhite,
                        onTap: livestreamprovider.onSwitchCamera,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: sendComment(
                  controller: commentController,
                  onTap: () {
                    if (commentController.text.trim().isNotEmpty) {
                      if (socket?.connected == true) {
                        socketManager.sendComment(
                            widget.userId, roomId, commentController.text);
                      } else {
                        log("=====================Socket Not Connect====================");
                      }
                      commentController.clear();
                    }
                  },
                ),
              ),
            ),
          ),
          Consumer<LiveStreamProvider>(
              builder: (context, livestreamprovider, child) {
            return Positioned(
              left: 0,
              bottom: 70,
              child: Container(
                height: 300,
                width: MediaQuery.of(context).size.width / 1.8,
                color: transparent,
                child: SingleChildScrollView(
                  controller: livestreamprovider.scrollController,
                  child: ListView.builder(
                    itemCount: livestreamprovider.commentList?.length ?? 0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return Comment(
                        userName: livestreamprovider
                                .commentList?[index].userName
                                .toString() ??
                            "",
                        comment: livestreamprovider.commentList?[index].comment
                                .toString() ??
                            "",
                        userImage: livestreamprovider.commentList?[index].image
                                .toString() ??
                            "",
                      );
                    },
                  ),
                ),
              ),
            );
          }),
          Positioned(right: 10, bottom: 70, child: showGift()),
          /* ==============Comment Show Live Stream =================== */
        ],
      ),
    );
  }

  Widget audienceUI({required liveScreen, required liveRoomId, liveUserId}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.isFake == "0"
            ? liveScreen
            : ReelsPlayer(
                index: 0,
                pagePos: 0,
                isLiveStream: true,
                videoUrl: widget.videoUrl ?? "",
                thumbnailImg: ""),
        Positioned(
          top: 50,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Consumer<LiveStreamProvider>(
                      builder: (context, livestreamprovider, child) {
                    return Container(
                      height: 45,
                      width: 160,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(56),
                        gradient: Constant.buttonGradient,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: MyNetworkImage(
                                width: 35,
                                height: 35,
                                imagePath: widget.image.toString(),
                                fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MyText(
                                color: colorAccent,
                                multilanguage: false,
                                text: widget.userName ?? "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textMedium,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                        ],
                      ),
                    );
                  }),
                  circleIconWithButton(
                      color: buttonDisable,
                      icon: "ic_close.webp",
                      circleSize: 38,
                      padding: const EdgeInsets.all(8),
                      iconColor: pureWhite,
                      onTap: () {
                        if (socket?.connected == true) {
                          socketManager.lessView(widget.userId, roomId);
                        }
                        liveStreamProvider.clearComment();
                        if (!mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: 400,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [transparent, black.withOpacity(0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: sendComment(
                      controller: commentController,
                      onTap: () {
                        if (commentController.text.trim().isNotEmpty) {
                          if (socket?.connected == true) {
                            socketManager.sendComment(
                                widget.userId, roomId, commentController.text);
                          } else {
                            log("=====================Socket Not Connect====================");
                          }
                          commentController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  circleIconWithButton(
                    circleSize: 50,
                    iconSize: 48,
                    color: white.withOpacity(0.20),
                    icon: "ic_gift.webp",
                    onTap: () {
                      openGift();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        /* ==============Comment Show Live Stream =================== */
        Consumer<LiveStreamProvider>(
            builder: (context, livestreamprovider, child) {
          return Positioned(
            left: 0,
            bottom: 70,
            child: Container(
              height: 300,
              width: MediaQuery.of(context).size.width / 1.8,
              color: transparent,
              child: SingleChildScrollView(
                controller: livestreamprovider.scrollController,
                child: ListView.builder(
                  itemCount: livestreamprovider.commentList?.length ?? 0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return Comment(
                      userName: livestreamprovider.commentList?[index].userName
                              .toString() ??
                          "",
                      comment: livestreamprovider.commentList?[index].comment
                              .toString() ??
                          "",
                      userImage: livestreamprovider.commentList?[index].image
                              .toString() ??
                          "",
                    );
                  },
                ),
              ),
            ),
          );
        }),
        Positioned(right: 10, bottom: 70, child: showGift()),
      ],
    );
  }

  showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: black.withOpacity(0.9),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: transparent,
          elevation: 0,
          child: Container(
            height: 385,
            width: 310,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(45),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Image.asset("${Constant.assetsEffectPath}ic_logout.webp",
                      height: 90, width: 90),
                  const SizedBox(height: 10),
                  MyText(
                      color: black,
                      multilanguage: true,
                      text: "stoplive",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textExtraBig,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 10),
                  MyText(
                      color: gray,
                      multilanguage: true,
                      text: "stoplivedisc",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textSmall,
                      inter: false,
                      maxline: 4,
                      fontwaight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      if (socket?.connected == true) {
                        socketManager.endLive(widget.userId, roomId);
                        liveStreamProvider.clearCount();
                        liveStreamProvider.clearComment();
                        destroyEngine();
                      }

                      if (!mounted) return;
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => const Bottombar(
                                  isLiveStream: true,
                                )),
                        (Route<dynamic> route) => false,
                      ).then(
                        (value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const Bottombar(
                                      isLiveStream: true,
                                    )),
                          );
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: gray.withOpacity(0.20),
                      ),
                      alignment: Alignment.center,
                      height: 52,
                      width: MediaQuery.of(context).size.width,
                      child: MyText(
                          color: black,
                          multilanguage: true,
                          text: "stop",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textTitle,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w700,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      if (!mounted) return;
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: gray.withOpacity(0.20),
                      ),
                      height: 52,
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: MyText(
                          color: gray,
                          multilanguage: true,
                          text: "cancel",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textTitle,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w700,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  sendComment({onTap, controller}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 15, right: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.comment_rounded, color: pureBlack, size: 20),
          const SizedBox(width: 5),
          VerticalDivider(
            indent: 12,
            endIndent: 12,
            color: gray.withOpacity(0.3),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              controller: controller,
              cursorColor: gray,
              maxLines: 1,
              onChanged: (value) {
                if (value.isEmpty) {
                  _focusNode.unfocus();
                }
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(bottom: 3),
                  hintText: "Type Comment...",
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: Dimens.textDesc,
                  )),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 40,
              width: 40,
              color: transparent,
              child: const Center(
                  child: Icon(
                Icons.send,
                size: 20,
                color: gray,
              )),
            ),
          ),
        ],
      ),
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
            shape: BoxShape.circle,
            gradient: Constant.buttonGradient,
            border: border),
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

  void openGift() {
    _fetchGift(0);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(25),
          topStart: Radius.circular(25),
        ),
      ),
      builder: (context) => Container(
        height: 550,
        width: MediaQuery.of(context).size.width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorPrimaryDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 65,
              decoration: const BoxDecoration(color: colorPrimary),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  Consumer<LiveStreamProvider>(
                      builder: (context, livestreamprovider, child) {
                    return Container(
                      height: 34,
                      padding: const EdgeInsets.only(left: 5, right: 10),
                      decoration: BoxDecoration(
                        color: white,
                        border: Border.all(color: black.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyImage(
                              width: 22, height: 22, imagePath: "ic_coin.png"),
                          const SizedBox(width: 5),
                          MyText(
                              color: black,
                              multilanguage: false,
                              text: Utils.kmbGenerator(livestreamprovider
                                      .profileModel.result?[0].walletBalance ??
                                  0),
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textSmall,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      ),
                    );
                  }),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 4,
                          width: 35,
                          decoration: BoxDecoration(
                            color: black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 15),
                        MyText(
                            color: white,
                            multilanguage: true,
                            text: "gifttitle",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textTitle,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!mounted) return;
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: transparent,
                        border: Border.all(color: white),
                      ),
                      child: Center(
                          child: MyImage(
                              width: 15,
                              color: white,
                              height: 15,
                              imagePath: "ic_close.png")),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Consumer<LiveStreamProvider>(
                builder: (context, livestreamprovider, child) {
              if (livestreamprovider.giftloading) {
                return giftShimmer();
              } else {
                if (livestreamprovider.fetchGiftModel.result != null &&
                    livestreamprovider.giftList != null &&
                    (livestreamprovider.giftList?.length ?? 0) > 0) {
                  return Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      scrollDirection: Axis.vertical,
                      controller: _giftScrollController,
                      child: Column(
                        children: [
                          ResponsiveGridList(
                            minItemWidth: 120,
                            minItemsPerRow: 3,
                            maxItemsPerRow: 3,
                            horizontalGridSpacing: 10,
                            verticalGridSpacing: 10,
                            listViewBuilderOptions: ListViewBuilderOptions(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                            ),
                            children: List.generate(
                                livestreamprovider.giftList?.length ?? 0,
                                (index) {
                              return GestureDetector(
                                onTap: () async {
                                  if (widget.isFake == "1") {
                                    livestreamprovider.showGift(
                                      isFake: "1",
                                      data: "",
                                      imageUrl: livestreamprovider
                                              .giftList?[index].image
                                              .toString() ??
                                          "",
                                    );
                                    if (!mounted) return;
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  } else {
                                    if (socket?.connected == true) {
                                      if (((livestreamprovider
                                                      .giftList?[index].price ??
                                                  0) ==
                                              (livestreamprovider
                                                      .profileModel
                                                      .result?[0]
                                                      .walletBalance ??
                                                  0)) ||
                                          ((livestreamprovider
                                                      .giftList?[index].price ??
                                                  0)) <
                                              (livestreamprovider
                                                      .profileModel
                                                      .result?[0]
                                                      .walletBalance ??
                                                  0)) {
                                        socketManager.sendGift(
                                            widget.userId,
                                            roomId,
                                            livestreamprovider
                                                    .giftList?[index].id
                                                    .toString() ??
                                                "");

                                        log("=====================Send Gift====================");

                                        if (!mounted) return;
                                        if (Navigator.canPop(context)) {
                                          Navigator.pop(context);
                                        }
                                        showGeneralDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          barrierLabel: '',
                                          transitionDuration:
                                              const Duration(milliseconds: 500),
                                          // animation duration
                                          pageBuilder: (context, anim1, anim2) {
                                            // Auto close after 3 seconds
                                            Future.delayed(
                                                const Duration(seconds: 3), () {
                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              }
                                            });

                                            return Align(
                                              alignment:
                                                  const Alignment(0, 0.4),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: ScaleTransition(
                                                  scale: CurvedAnimation(
                                                    parent: anim1,
                                                    curve: Curves.easeOutBack,
                                                    reverseCurve:
                                                        Curves.easeInBack,
                                                  ),
                                                  child: Dialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                    child: AspectRatio(
                                                      aspectRatio: 1.8,
                                                      child: Container(
                                                        decoration: ShapeDecoration(
                                                            shape: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            color:
                                                                Colors.white),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            MyNetworkImage(
                                                              width: 45,
                                                              height: 45,
                                                              imagePath: livestreamprovider
                                                                      .giftList?[
                                                                          index]
                                                                      .image
                                                                      .toString() ??
                                                                  "",
                                                              fit: BoxFit.cover,
                                                            ),
                                                            MyText(
                                                              text:
                                                                  'Your Gift has been sent',
                                                              color: pureBlack,
                                                              multilanguage:
                                                                  false,
                                                            ),
                                                            ShaderMask(
                                                              shaderCallback: (bounds) =>
                                                                  const LinearGradient(
                                                                colors: [
                                                                  Colors.green,
                                                                  Colors.green
                                                                ],
                                                              ).createShader(Rect
                                                                      .fromLTWH(
                                                                          0,
                                                                          0,
                                                                          bounds
                                                                              .width,
                                                                          bounds
                                                                              .height)),
                                                              child: MyText(
                                                                text:
                                                                    'Successfully',
                                                                multilanguage:
                                                                    false,
                                                                color: white,
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
                                          },
                                          transitionBuilder:
                                              (context, anim1, anim2, child) {
                                            return FadeTransition(
                                              opacity: CurvedAnimation(
                                                parent: anim1,
                                                curve: Curves.easeInOut,
                                              ),
                                              child: child,
                                            );
                                          },
                                        );
                                      } else {
                                        /* Move TO Recharge Page */
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return const AdsPackage();
                                            },
                                          ),
                                        );
                                      }
                                    } else {
                                      Utils().showSnackBar(
                                          context,
                                          "Socket Connection Faild Please Check Connection!!!",
                                          false);
                                    }
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color: colorPrimary,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: colorPrimary),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: MyNetworkImage(
                                            width: 45,
                                            height: 45,
                                            imagePath: livestreamprovider
                                                    .giftList?[index].image
                                                    .toString() ??
                                                "",
                                            fit: BoxFit.cover),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: gray.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: MyText(
                                            color: white,
                                            multilanguage: false,
                                            text:
                                                "${livestreamprovider.giftList?[index].price.toString() ?? ""} Coins",
                                            textalign: TextAlign.center,
                                            fontsizeNormal: Dimens.textSmall,
                                            inter: false,
                                            maxline: 1,
                                            fontwaight: FontWeight.w700,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal),
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        child: Container(
                                          height: 35,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                            color: colorPrimary,
                                            borderRadius: BorderRadius.vertical(
                                                bottom: Radius.circular(15)),
                                          ),
                                          child: MyText(
                                              color: colorAccent,
                                              multilanguage: true,
                                              text: "send",
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
                              );
                            }),
                          ),
                          if (livestreamprovider.giftloadMore)
                            SizedBox(
                              height: 50,
                              child: Utils.pageLoader(context),
                            )
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const NoData();
                }
              }
            }),
            const SizedBox(height: 10),
            /* Recharge Button */
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const AdsPackage();
                          },
                        ),
                      );
                    },
                    child: Container(
                      height: 45,
                      width: 130,
                      decoration: BoxDecoration(
                        color: colorPrimary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 5),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: white, width: 1.5),
                              ),
                              child: MyImage(
                                  width: 22,
                                  height: 22,
                                  imagePath: "ic_coin.png"),
                            ),
                            const SizedBox(width: 5),
                            MyText(
                                color: white,
                                multilanguage: true,
                                text: "addcoins",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textDesc,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
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
  }

  Widget showGift() {
    return Consumer<LiveStreamProvider>(
      builder: (context, livestreamprovider, child) {
        if (livestreamprovider.gifts.isEmpty) {
          print('show gift empty');
          return const SizedBox.shrink();
        }
        print('show gift without empty');

        return Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: livestreamprovider.gifts.map((gift) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: _GiftAnimation(
                    giftUrl: gift,
                    isHost: isHost,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget giftShimmer() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 3,
              maxItemsPerRow: 3,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 10,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(9, (index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: gray.withOpacity(0.20)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: SizedBox(
                            height: 55,
                            width: 65,
                          )),
                      SizedBox(height: 8),
                      CustomWidget.roundcorner(height: 35),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftAnimation extends StatefulWidget {
  final String giftUrl;
  final bool isHost; // 👈 Add this

  const _GiftAnimation({
    required this.giftUrl,
    required this.isHost,
  });

  @override
  State<_GiftAnimation> createState() => _GiftAnimationState();
}

class _GiftAnimationState extends State<_GiftAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _riseUp;
  late Animation<double> _boxShake;
  late Animation<double> _lidBlast;
  late Animation<double> _boxFade;
  late Animation<double> _giftScale;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _riseUp = Tween<double>(begin: 1.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOutBack),
      ),
    );

    _boxShake = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.35, curve: Curves.elasticIn),
      ),
    );

    _lidBlast = Tween<double>(begin: 0.0, end: -2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
      ),
    );

    _boxFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.7, curve: Curves.easeOut),
      ),
    );

    _giftScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.8),
      ),
    );

    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boxImage = Image.asset(
      "${Constant.videoImagePath}ic_gift.webp",
      height: 60,
      width: 60,
    );

    final lidImage = Image.asset(
      "${Constant.videoImagePath}ic_gift_lid.png",
      height: 60,
      width: 60,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeOut.value,
          child: Transform.translate(
            offset: Offset(
              0,
              MediaQuery.of(context).size.height * _riseUp.value,
            ),
            child: Transform.translate(
              offset: Offset(
                _controller.value > 0.25 && _controller.value < 0.35
                    ? _boxShake.value * math.sin(_controller.value * 40)
                    : 0,
                0,
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 🧱 Only show box and lid if user is host
                  if (widget.isHost) ...[
                    Opacity(
                      opacity: _boxFade.value,
                      child: boxImage,
                    ),
                    Positioned(
                      top: -5,
                      child: Transform.translate(
                        offset: Offset(0, _lidBlast.value * -30),
                        child: Transform.rotate(
                          angle: _lidBlast.value * math.pi / 3,
                          alignment: Alignment.bottomCenter,
                          child: lidImage,
                        ),
                      ),
                    ),
                  ],

                  // 🎁 Gift image (always shown)
                  Positioned(
                    bottom: 8,
                    child: ScaleTransition(
                      scale: _giftScale,
                      child: Image.network(
                        widget.giftUrl,
                        height: 45,
                        width: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
