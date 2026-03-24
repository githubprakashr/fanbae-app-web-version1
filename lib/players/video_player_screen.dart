import 'package:flutter/material.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../model/successmodel.dart';
import '../provider/profileprovider.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/utils.dart';
import '../widget/mytext.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final String title;
  final String contentId;

  const VideoPlayerScreen({
    super.key,
    required this.url,
    required this.title,
    required this.contentId,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  String type = 'free';
  final TextEditingController coinController = TextEditingController();
  SuccessModel successModel = SuccessModel();

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      aspectRatio: _videoController.value.aspectRatio,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        Utils().hideProgress(context);
      },
      child: Scaffold(
        backgroundColor: black,
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: white),
          ),
          backgroundColor: black,
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: white,
              )),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _chewieController != null &&
                      _chewieController!
                          .videoPlayerController.value.isInitialized
                  ? SizedBox(
                      height: 400,
                      width: MediaQuery.of(context).size.width,
                      child: Chewie(controller: _chewieController!),
                    )
                  : const SizedBox(
                      height: 230,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Utils().titleText("type"),
                      Row(
                        children: [
                          Row(
                            children: [
                              Radio<String>(
                                value: 'free',
                                groupValue: type,
                                activeColor: colorPrimary,
                                onChanged: (value) {
                                  setState(() {
                                    type = value!;
                                  });
                                },
                              ),
                              MyText(
                                text: 'free',
                                color: white,
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'pay',
                                groupValue: type,
                                activeColor: colorPrimary,
                                onChanged: (value) {
                                  setState(() {
                                    type = value!;
                                  });
                                },
                              ),
                              MyText(
                                text: 'pay',
                                color: white,
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (type == "pay") ...[
                        Utils().titleText("price"),
                        Utils().myTextField(
                            coinController,
                            TextInputAction.next,
                            TextInputType.number,
                            'price',
                            false),
                      ],
                      const SizedBox(height: 15),
                    ]),
              ),
              GestureDetector(
                onTap: () async {
                  if (type == "pay" && coinController.text.isEmpty) {
                    return Utils().showSnackBar(
                        context, "Price field is required", false);
                  }

                  Utils.showProgress(context);

                  successModel = await ApiService().livePost(
                      widget.contentId,
                      type == 'free' ? 0 : 1,
                      type == 'free' ? 0 : coinController.text);

                  if (!mounted) return;
                  Utils().hideProgress(context);
                  Utils()
                      .showSnackBar(context, "${successModel.message}", false);

                  if (successModel.status == 200) {
                    Future.delayed(const Duration(milliseconds: 600), () async {
                      await Provider.of<ProfileProvider>(context, listen: false)
                          .getcontentbyChannel(Constant.userID,
                              Constant.channelID, '7', (0) + 1);
                      if (mounted) Navigator.pop(context);
                    });
                  }
                },
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.only(
                      top: 15, bottom: 25, left: 15, right: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(7)),
                      gradient: Constant.gradientColor),
                  child: MyText(
                      color: pureBlack,
                      text: "submit",
                      multilanguage: true,
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textMedium,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
