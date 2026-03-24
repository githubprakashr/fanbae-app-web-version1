import 'dart:io';
import 'package:fanbae/main.dart';
import 'package:fanbae/provider/videopreviewprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/videorecord/custom/app_button_ui.dart';
import 'package:fanbae/videorecord/uploadvideo.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PreviewReels extends StatefulWidget {
  final String filePath, fileType, videoImageFile, hashtagName, hashtagId, type;

  const PreviewReels({
    super.key,
    required this.filePath,
    required this.fileType,
    required this.videoImageFile,
    required this.hashtagName,
    required this.hashtagId,
    required this.type,
  });

  @override
  State<PreviewReels> createState() => _PreviewReelsState();
}

class _PreviewReelsState extends State<PreviewReels> with RouteAware {
  late VideoPreviewProvider videoPreviewProvider;
  VideoPlayerController? _controller;

  @override
  void initState() {
    printLog("filePath ====> ${widget.filePath}");
    printLog("fileType ====> ${widget.fileType}");
    printLog("videoImage ==> ${widget.videoImageFile}");
    videoPreviewProvider =
        Provider.of<VideoPreviewProvider>(context, listen: false);
    initController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  @override
  void didPop() {
    printLog("========= didPop =========");
    super.didPop();
  }

  @override
  void didPopNext() {
    printLog("========= didPopNext =========");
    if (_controller == null) {
      initController();
    }
    super.didPopNext();
  }

  initController() async {
    if (widget.fileType == "video") {
      try {
        _controller = VideoPlayerController.file(
          File(widget.filePath),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        )..initialize().then((value) {
            if (!mounted) return;
            setState(() {
              printLog(
                  "visibleInfo visibleFraction =========> ${videoPreviewProvider.visibleInfo?.visibleFraction}");
              if (videoPreviewProvider.visibleInfo?.visibleFraction == 0.0) {
                if (_controller != null) _controller?.pause();
              } else {
                if (_controller != null) _controller?.play();
              }
            });
          });
        _controller?.seekTo(Duration.zero);
        _controller?.setLooping(true);
      } catch (e) {
        printLog("videoScreen initController Exception ==> $e");
      }
    }
  }

  @override
  void didPush() {
    if (videoPreviewProvider.visibleInfo?.visibleFraction == 0.0) {
      _controller?.dispose();
      _controller = null;
    }
    printLog("========= didPush =========");
    super.didPush();
  }

  @override
  void didPushNext() {
    printLog(
        "visibleInfo =====didPushNext====> ${videoPreviewProvider.visibleInfo?.visibleFraction}");
    if (videoPreviewProvider.visibleInfo?.visibleFraction == 0.0) {
      _controller?.dispose();
      _controller = null;
    }
    printLog("========= didPushNext =========");
    super.didPushNext();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    printLog("========= dispose =========");
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('Preview'),
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted) return;
        videoPreviewProvider.setVisibilityInfo(visibilityInfo);
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        printLog(
            '=========== Widget ${visibilityInfo.key} is $visiblePercentage% visible ===========');
        if (widget.fileType == "video") {
          if (videoPreviewProvider.visibleInfo?.visibleFraction == 0.0) {
            if (_controller != null) {
              _controller?.dispose();
              _controller = null;
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: appbgcolor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appbgcolor,
          title: MyText(
            multilanguage: false,
            color: white,
            text: "Preview",
            fontsizeNormal: 18,
            fontsizeWeb: 18,
            fontwaight: FontWeight.w600,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: white,
            onPressed: () async {
              if (Navigator.canPop(context)) {
                if (!mounted) return;
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ),
        extendBodyBehindAppBar: true,
        body: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return Stack(
      children: [
        (widget.fileType == "video") ? _buildPlayer() : _buildImage(),
        Positioned(
          bottom: 40,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 5),
              child: AppButtonUi(
                fontSize: 18,
                color: colorPrimary,
                fontColor: colorAccent,
                title: "Next",
                callback: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadVideo(
                        videoFile: File(widget.filePath),
                        fileType: widget.fileType,
                        videoImageFile: File(widget.videoImageFile),
                        hashtagId: widget.hashtagId,
                        hashtagName: widget.hashtagName,
                        type: widget.type,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayer() {
    if (!(_controller?.value.isInitialized ?? false)) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return GestureDetector(
        onTap: () {
          if (_controller!.value.isPlaying) {
            if (_controller != null) _controller?.pause();
          } else {
            if (_controller != null) _controller?.play();
          }
        },
        child: SizedBox.expand(
          child: FittedBox(
            // fit: BoxFit.fill,
            child: SizedBox(
              width: _controller?.value.size.width,
              height: _controller?.value.size.height,
              child: AspectRatio(
                aspectRatio: _controller?.value.aspectRatio ?? 16 / 9,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildImage() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Image.file(
        File(widget.filePath),
        fit: BoxFit.contain,
      ),
    );
  }
}
