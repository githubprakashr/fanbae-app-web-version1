import 'package:fanbae/provider/playerprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';

class PlayerVimeo extends StatefulWidget {
  final String? videoId, videoUrl, vUploadType, videoThumb;
  const PlayerVimeo(
      this.videoId, this.videoUrl, this.vUploadType, this.videoThumb,
      {Key? key})
      : super(key: key);

  @override
  State<PlayerVimeo> createState() => PlayerVimeoState();
}

class PlayerVimeoState extends State<PlayerVimeo> {
  late PlayerProvider playerProvider;
  String? vUrl;
  int? playerCPosition, videoDuration;

  @override
  void initState() {
    playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    super.initState();
    vUrl = widget.videoUrl;
    if (!(vUrl ?? "").contains("https://vimeo.com/")) {
      vUrl = "https://vimeo.com/$vUrl";
    }
    printLog("vUrl===> $vUrl");
    _addVideoView();
  }

  _addVideoView() async {
    await playerProvider.addVideoView("1", widget.videoId);
  }

  @override
  void dispose() {
    if (!(kIsWeb)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: onBackPressed,
      child: Scaffold(
        backgroundColor: black,
        body: Stack(
          children: [
            VimeoVideoPlayer(
              url: vUrl ?? "",
              autoPlay: true,
              systemUiOverlay: const [],
              deviceOrientation: const [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ],
              startAt: Duration.zero,
              onProgress: (timePoint) {
                playerCPosition = timePoint.inMilliseconds;
                printLog("playerCPosition :===> $playerCPosition");
              },
              onFinished: () async {
                /* Remove From Continue */
                await playerProvider.removeContentHistory(
                    "1", "${widget.videoId}", "0");
              },
            ),
            if (!kIsWeb)
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

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    if (!(kIsWeb)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
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
