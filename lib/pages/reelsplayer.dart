import 'package:flutter/material.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReelsPlayer extends StatefulWidget {
  final int index, pagePos;
  final String videoUrl, thumbnailImg;
  final bool isLiveStream;

  const ReelsPlayer({
    super.key,
    required this.index,
    required this.pagePos,
    required this.videoUrl,
    required this.thumbnailImg,
    required this.isLiveStream,
  });

  @override
  State<ReelsPlayer> createState() => _ReelsPlayerState();
}

class _ReelsPlayerState extends State<ReelsPlayer> {
  VideoPlayerController? videoController;
  bool isVisible = false;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    initController();
  }

  Future<void> initController() async {
    videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..initialize().then((_) {
            setState(() {
              if (isVisible) {
                videoController!.play();
                videoController!.setLooping(true);
              }
            });

            videoController!.addListener(() {
              if (videoController!.value.position ==
                  videoController!.value.duration) {
                resetVideo();
              }
            });
          });
  }

  void playVideo() {
    if (videoController != null && isVisible) {
      videoController!.play();
    }
  }

  void pauseVideo() {
    if (videoController != null) {
      videoController!.pause();
    }
  }

  void resetVideo() {
    if (videoController != null) {
      videoController!.seekTo(Duration.zero);
      playVideo();
    }
  }

  void seekVideo(Duration position) {
    videoController?.seekTo(position);
    playVideo();
  }

  @override
  void dispose() {
    videoController?.pause();
    videoController?.dispose();
    videoController = null;
    super.dispose();
  }

  void togglePlayPause() {
    if (videoController!.value.isPlaying) {
      videoController!.pause();
    } else {
      videoController!.play();
    }
    setState(() {
      _showOverlay = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showOverlay = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video_screen_${widget.index}'),
      onVisibilityChanged: (visibilityInfo) {
        final visiblePercentage = visibilityInfo.visibleFraction * 100;
        isVisible = visiblePercentage > 80;
        if (isVisible) {
          playVideo();
        } else {
          pauseVideo();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child:
                videoController != null && videoController!.value.isInitialized
                    ? FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: videoController?.value.size.width,
                          height: videoController?.value.size.height,
                          child: AspectRatio(
                            aspectRatio:
                                videoController?.value.aspectRatio ?? 16 / 9,
                            child: VideoPlayer(videoController!),
                          ),
                        ),
                      )
                    : (widget.isLiveStream == false)
                        ? _buildImage()
                        : Container(),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                print("Tapped!");
                if (!widget.isLiveStream) {
                  togglePlayPause();
                }
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          if (_showOverlay)
            Icon(
              videoController?.value.isPlaying == true
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          MyNetworkImage(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            imagePath: widget.thumbnailImg,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
