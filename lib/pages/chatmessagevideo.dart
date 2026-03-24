import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/utils.dart';

class VideoMessagePlayer extends StatefulWidget {
  final String videoUrl;
  final int timeStamp;
  final bool isRead;
  final bool isMe;
  const VideoMessagePlayer({super.key, required this.videoUrl,
    required this.timeStamp, required this.isRead, required this.isMe});

  @override
  State<VideoMessagePlayer> createState() => _VideoMessagePlayerState();
}

class _VideoMessagePlayerState extends State<VideoMessagePlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return Stack(
      children: [
        Container(
          width: 220,
          height: 136,
          clipBehavior: Clip.hardEdge,
          margin: const EdgeInsets.all(4.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8)),
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        const Positioned.fill(
          child: Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white70,
              size: 45,
            ),
          ),
        ),
        Positioned(
          bottom: 5,
          right: 8,
          child: Row(
            children: [
              Text(
                Utils().formatTimestamp(widget.timeStamp),
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffD2D2D2),
                ),
              ),
              const SizedBox(width: 3),
              if (widget.isMe)
                Icon(
                  widget.isRead ? Icons.done_all : Icons.done,
                  size: 13.6,
                  color: widget.isRead ? pureWhite : Colors.grey,
                ),
            ],
          ),)
      ],
    );
  }
}
