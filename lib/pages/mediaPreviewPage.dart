import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewPage extends StatefulWidget {
  final String mediaType;
  final String mediaUrl;

  const MediaPreviewPage({
    super.key,
    required this.mediaType,
    required this.mediaUrl,
  });

  @override
  State<MediaPreviewPage> createState() => _MediaPreviewPageState();
}

class _MediaPreviewPageState extends State<MediaPreviewPage> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();

    if (widget.mediaType == 'video') {
      _controller = VideoPlayerController.network(widget.mediaUrl)
        ..initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
          });
          _controller.play();
        });
    }
  }

  @override
  void dispose() {
    if (widget.mediaType == 'video') {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: widget.mediaType == 'image'
            ? InteractiveViewer(
          child: Image.network(widget.mediaUrl),
        )
            : _isVideoInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  color: Colors.white70,
                  size: 65,
                ),
              ),
            ],
          ),
        )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
