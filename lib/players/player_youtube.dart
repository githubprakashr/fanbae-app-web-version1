import 'package:fanbae/provider/playerprovider.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:fanbae/utils/color.dart';

class PlayerYoutube extends StatefulWidget {
  final String? videoId, videoUrl, vUploadType, videoThumb;
  final bool? iscontinueWatching;
  final double? stoptime;
  const PlayerYoutube(this.videoId, this.videoUrl, this.vUploadType,
      this.videoThumb, this.stoptime, this.iscontinueWatching,
      {Key? key})
      : super(key: key);

  @override
  State<PlayerYoutube> createState() => PlayerYoutubeState();
}

class PlayerYoutubeState extends State<PlayerYoutube> {
  late PlayerProvider playerProvider;
  YoutubePlayerController? controller;
  bool fullScreen = false;
  int? playerCPosition, videoDuration;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    _initPlayer();
  }

  _initPlayer() async {
    controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );
    var videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl ?? "");
    controller = YoutubePlayerController.fromVideoId(
      videoId: videoId ?? '',
      autoPlay: true,
      startSeconds:
          widget.iscontinueWatching == true ? (widget.stoptime ?? 0) : 0,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );
    printLog("Start Playing :====> $videoId");
    // Api Call CourseView
    await playerProvider.addVideoView("1", widget.videoId);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
    /* Add Video view */
    await playerProvider.addVideoView("1", widget.videoId);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return PopScope(
      canPop: false,
      onPopInvoked: onBackPressed,
      child: Scaffold(
        backgroundColor: black,
        body: Stack(
          children: [
            _buildPlayer(),
            Positioned(
              top: 15,
              left: 15,
              child: SafeArea(
                child: InkWell(
                  onTap: () {
                    onBackPressed(false);
                  },
                  focusColor: gray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  child: Utils.buildBackBtnDesign(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    if (controller == null) {
      return Utils.pageLoader(context);
    } else {
      return YoutubePlayerScaffold(
        backgroundColor: black,
        controller: controller!,
        autoFullScreen: true,
        defaultOrientations: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        builder: (context, player) {
          return Scaffold(
            backgroundColor: black,
            body: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return player;
                },
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    controller?.close();
    if (!(kIsWeb)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    if (!(kIsWeb)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    double? curPos = await controller?.currentTime;
    double? duration = await controller?.duration;
    Duration curPosDuration = Duration(seconds: (curPos ?? 0).round());
    int? currentPosition = curPosDuration.inMilliseconds;
    Duration totalDuration = Duration(seconds: (duration ?? 0).round());
    int? totalvidoeDuration = totalDuration.inMilliseconds;
    printLog("cpos :===> $curPos");
    printLog("Duration :===> $duration");
    playerCPosition = (currentPosition).round();
    videoDuration = (totalvidoeDuration).round();
    printLog("onBackPressed playerCPosition :===> $playerCPosition");
    printLog("onBackPressed videoDuration :===> $videoDuration");

    if ((playerCPosition ?? 0) > 0 &&
        (playerCPosition == videoDuration ||
            (playerCPosition ?? 0) > (videoDuration ?? 0))) {
      playerProvider.removeContentHistory("1", "${widget.videoId}", "0");
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } else if ((playerCPosition ?? 0) > 0) {
      playerProvider.addContentHistory(
          "1", widget.videoId, "$playerCPosition", "0");
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } else {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, false);
      }
    }
  }
}
