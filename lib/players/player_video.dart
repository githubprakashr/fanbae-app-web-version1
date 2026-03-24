import 'dart:developer';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:fanbae/provider/playerprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/mytext.dart';
import '../utils/responsive_helper.dart';

class PlayerVideo extends StatefulWidget {
  final String? videoId, videoUrl, vUploadType, videoThumb;
  final double? stoptime;
  final bool? iscontinueWatching, isDownloadVideo;

  const PlayerVideo({
    super.key,
    this.videoId,
    this.videoUrl,
    this.vUploadType,
    this.videoThumb,
    this.stoptime,
    this.iscontinueWatching,
    this.isDownloadVideo,
  });

  @override
  State<PlayerVideo> createState() => _PlayerVideoState();
}

class _PlayerVideoState extends State<PlayerVideo> {
  late PlayerProvider playerProvider;
  int? playerCPosition, videoDuration;
  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _playerInit());
  }

  Future<void> _playerInit() async {
    try {
      if (widget.videoUrl == null || widget.videoUrl!.isEmpty) return;

      if (widget.isDownloadVideo == true) {
        final videoFile = File(widget.videoUrl!);
        if (!videoFile.existsSync()) {
          printLog("❌ Video file not found: ${videoFile.path}");
          return;
        }
        _videoPlayerController = VideoPlayerController.file(videoFile);
      } else {
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      }

      await _videoPlayerController!.initialize();
      _setupChewieController();
      setState(() {});
    } catch (e, st) {
      printLog("❌ Player init exception: $e\n$st");
    }
  }

  void _setupChewieController() {
    final stoptime = (widget.iscontinueWatching == true)
        ? (widget.stoptime ?? 0).round()
        : 0;

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      autoInitialize: true,
      looping: false,
      fullScreenByDefault: false,
      allowFullScreen: true,
      allowMuting: true,
      hideControlsTimer: const Duration(seconds: 1),
      showControls: true,
      allowedScreenSleep: false,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      cupertinoProgressColors: ChewieProgressColors(
        playedColor: colorPrimary,
        handleColor: colorPrimary,
        backgroundColor: gray,
        bufferedColor: white,
      ),
      materialProgressColors: ChewieProgressColors(
        playedColor: colorPrimary,
        handleColor: colorPrimary,
        backgroundColor: gray,
        bufferedColor: white,
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: MyText(
            color: white,
            text: errorMessage,
            textalign: TextAlign.center,
            fontsizeNormal: Dimens.textMedium,
            fontwaight: FontWeight.w600,
            multilanguage: false,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        );
      },
    );

    _videoPlayerController!.addListener(() {
      playerCPosition = _videoPlayerController!.value.position.inMilliseconds;
      videoDuration = _videoPlayerController!.value.duration.inMilliseconds;
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    playerProvider.clearProvider();
    if (!mounted) return;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
        body: SafeArea(
          child: Stack(
            children: [
              Center(child: _buildPage()),
              Positioned(
                top: 15,
                left: 15,
                child: InkWell(
                  onTap: () => onBackPressed(false),
                  child: Utils.buildBackBtnDesign(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage() {
    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 70, width: 70, child: Utils.pageLoader(context)),
          const SizedBox(height: 20),
          MyText(
            color: white,
            text: "Loading...",
            textalign: TextAlign.center,
            fontwaight: FontWeight.w600,
            fontsizeNormal: Dimens.textTitle,
            multilanguage: false,
          ),
        ],
      );
    }
  }

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;

    if ((playerCPosition ?? 0) > 0) {
      playerProvider.addContentHistory(
          "1", widget.videoId, "$playerCPosition", "0");
    }

    if (Navigator.canPop(context)) Navigator.pop(context, true);
  }
}
