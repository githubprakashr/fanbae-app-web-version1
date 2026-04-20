import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fanbae/pages/reelsplayer.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/model/feedslistmodel.dart' as feedpost;
import 'package:fanbae/model/getchannelfeedmodel.dart' as feedpostprofile;
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../model/successmodel.dart';
import '../provider/feedprovider.dart';
import '../utils/constant.dart';
import '../webpages/weblogin.dart';
import '../webservice/apiservice.dart';
import '../widget/myimage.dart';
import 'login.dart';

class ShowPostContent extends StatefulWidget {
  final dynamic postContent;
  final String type, title;
  String? description, attachment;
  bool? payContent;
  final int clickPos;
  int? userId, id, payCoin;
  ShowPostContent({
    super.key,
    required this.postContent,
    required this.clickPos,
    required this.type,
    this.description,
    this.userId,
    this.payContent,
    this.attachment,
    required this.title,
    this.id,
    this.payCoin,
  });

  @override
  State<ShowPostContent> createState() => _ShowPostContentState();
}

class _ShowPostContentState extends State<ShowPostContent> {
  List<dynamic>? feedPost;
  List<feedpostprofile.PostContent>? feedPostProfile;
  late PageController pageController;
  late FeedProvider feedProvider;
  String title = '';
  String description = '';
  String attachment = '';

  @override
  void initState() {
    super.initState();
    feedProvider = Provider.of<FeedProvider>(context, listen: false);
    pageController =
        PageController(initialPage: widget.clickPos, viewportFraction: 1);
    if (widget.type == "feed") {
      feedPost = widget.postContent;
    } else {
      feedPostProfile = widget.postContent;
    }
    title = widget.title;
    description = widget.description ?? '';
    attachment = widget.attachment ?? '';
  }

  bool get _hasPostContent =>
      widget.postContent is List && (widget.postContent as List).isNotEmpty;

  dynamic get _firstPostContent =>
      _hasPostContent ? widget.postContent[0] : null;

  bool get _firstPostContentIsVideo =>
      _firstPostContent != null && _firstPostContent["content_type"] == 1;

  String get _firstPostContentImagePath {
    if (!_hasPostContent) return "";
    if (_firstPostContentIsVideo) {
      return _firstPostContent["content_url"]?.toString() ?? "";
    }
    return _firstPostContent["thumbnail_image"]?.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      //   appBar: Utils().otherPageAppBar(context, widget.title, false),
      body: Utils().pageBg(
        context,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, kIsWeb ? 25 : 0, 0, 50),
            child: (Constant.userID != widget.userId.toString() &&
                    widget.payContent == true)
                ? payPostApi(widget.clickPos)
                : buildBody(),
          ),
        ),
      ),
    );
  }

  payPostApi(index) {
    return Center(
      child: Container(
        height: 210,
        width: MediaQuery.of(context).size.width,
        color: black,
        child: Stack(
          children: [
            GestureDetector(
                onTap: () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ResponsiveHelper.isWeb(context)
                              ? const WebLogin()
                              : const Login();
                        },
                      ),
                    );
                  } else {
                    Utils().conformDialog(
                        context,
                        () async {
                          Utils.showProgress(context);
                          SuccessModel video = await ApiService().payVideoPost(
                              Constant.userID ?? '', 'post', widget.id ?? 0);
                          if (!mounted) return;
                          Utils().hideProgress(context);
                          if (video.status == 200) {
                            setState(() {
                              Utils().showSnackBar(
                                  context, video.message ?? '', false);
                              widget.payContent = false;
                            });
                            /*await feedProvider.clearProvider();
                            _fetchAllFeed(0);*/
                          } else {
                            Utils().showSnackBar(
                                context, video.message ?? '', false);
                          }
                        },
                        "wanttobuy",
                        () {
                          Navigator.pop(context);
                        });
                  }
                },
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  // adjust blur strength
                  child: MyNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                    imagePath: _firstPostContentImagePath,
                  ),
                )),
            // 🔹 Pay button overlay (bottom left)
            Positioned(
              bottom: 12,
              left: 12,
              child: GestureDetector(
                onTap: () async {
                  Utils().conformDialog(
                      context,
                      () async {
                        Utils.showProgress(context);
                        SuccessModel video = await ApiService().payVideoPost(
                            Constant.userID ?? '', 'post', widget.id ?? 0);
                        if (!mounted) return;
                        Utils().hideProgress(context);
                        if (video.status == 200) {
                          setState(() {
                            Utils().showSnackBar(
                                context, video.message ?? '', false);
                          });
                          await feedProvider.clearProvider();
                          fetchAllFeed(0);
                        } else {
                          Utils().showSnackBar(
                              context, video.message ?? '', false);
                        }
                      },
                      "wanttobuy",
                      () {
                        Navigator.pop(context);
                      });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        multilanguage: false,
                        color: pureWhite,
                        fontwaight: FontWeight.w600,
                        text: "Pay ",
                      ),
                      MyImage(
                        width: 18,
                        height: 18,
                        imagePath: "ic_coin.png",
                      ),
                      MyText(
                        multilanguage: false,
                        color: pureWhite,
                        fontwaight: FontWeight.w600,
                        text: " ${widget.payCoin} to view",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _firstPostContentIsVideo
                ? const SizedBox.shrink()
                : Positioned.fill(
                    child: Align(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: white,
                        size: 35,
                      ),
                    ),
                  ),
            Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: black.withOpacity(0.7)),
                  child: MyImage(
                    width: 20,
                    height: 20,
                    imagePath: 'ic_shorts.png',
                    color: white,
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Future<void> fetchAllFeed(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await feedProvider.getAllFeed((nextPage ?? 0) + 1);
    await feedProvider.getFeeds('for_you');
    await feedProvider.setLoadMore(false);
  }

  Future<void> downloadFileToFolder(String url, String folderPath) async {
    // Ensure directory exists
    Directory directory = Directory(folderPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    // Extract original file extension
    String originalName = url.split('/').last;
    String ext = "";
    if (originalName.contains(".")) {
      ext = ".${originalName.split('.').last}";
    }

    // Base name without extension
    String baseName = originalName.replaceAll(ext, "");

    // Generate auto-increment file name
    int i = 0;
    String finalName = i == 0 ? "$baseName$ext" : "$baseName($i)$ext";
    String fullPath = "${directory.path}/$finalName";

    while (File(fullPath).existsSync()) {
      i++;
      finalName = "$baseName($i)$ext";
      fullPath = "${directory.path}/$finalName";
    }

    try {
      Dio dio = Dio();

      await dio.download(
        url,
        fullPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            //  print("Downloading ${(received / total * 100).toStringAsFixed(0)}%");
          }
        },
      );

      print("Download complete: $fullPath");
      Utils().showSnackBar(context, 'Saved to $fullPath', false);
    } catch (e) {
      print("Error: $e");
    }
  }

  Widget buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            SizedBox(
              height: 320,
              width: MediaQuery.of(context).size.width,
              child: PageView.builder(
                pageSnapping: true,
                physics: const AlwaysScrollableScrollPhysics(),
                controller: pageController,
                itemCount: widget.type == "feed"
                    ? feedPost?.length ?? 0
                    : feedPostProfile?.length ?? 0,
                scrollDirection: Axis.horizontal,
                allowImplicitScrolling: true,
                itemBuilder: (context, index) {
                  return postContentItem(index: index);
                },
              ),
            ),
            Positioned(
                top: 35,
                left: 25,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: white.withOpacity(0.3), shape: BoxShape.circle),
                    child: Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: white,
                    ),
                  ),
                ))
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: SmoothPageIndicator(
            controller: pageController,
            count: widget.type == "feed"
                ? feedPost?.length ?? 0
                : feedPostProfile?.length ?? 0,
            effect: ExpandingDotsEffect(
              dotWidth: 10,
              dotHeight: 8,
              dotColor: colorPrimaryDark,
              expansionFactor: 4,
              offset: 1,
              activeDotColor: colorPrimary,
              radius: 100,
              strokeWidth: 1,
              spacing: 8,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils().titleText("title"),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: white,
                    fontSize: 14,
                    letterSpacing: 0.3,
                    wordSpacing: 1),
              ),
              description == ''
                  ? const SizedBox()
                  : Utils().titleText("description"),
              description == ''
                  ? const SizedBox()
                  : Text(
                      description ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: white,
                          fontSize: 13.8,
                          letterSpacing: 0.3,
                          wordSpacing: 1),
                    ),
              attachment == ''
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Utils().titleText("attachment"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.65,
                              child: MyText(
                                text: attachment!.split('/').last.toString(),
                                multilanguage: false,
                                color: white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await downloadFileToFolder(
                                  attachment.toString(),
                                  "/storage/emulated/0/Download/",
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11, vertical: 7),
                                decoration: BoxDecoration(
                                  border: Border.all(color: textColor),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: MyText(
                                    text: "download",
                                    color: textColor,
                                    fontsizeNormal: 12),
                              ),
                            )
                          ],
                        ),
                      ],
                    )
            ],
          ),
        )
      ],
    );
  }

  Widget postContentItem({required int index}) {
    final imageUrl = widget.type == "feed"
        ? (feedPost?[index]["content_url"].toString() ?? "")
        : (feedPostProfile?[index].contentUrl.toString() ?? "");

    final videoUrl = widget.type == "feed"
        ? (feedPost?[index]["content_url"].toString() ?? "")
        : (feedPostProfile?[index].contentUrl.toString() ?? "");

    final thumbnail = widget.type == "feed"
        ? (feedPost?[index]["thumbnail_image"].toString() ?? "")
        : (feedPostProfile?[index].thumbnailImage.toString() ?? "");

    final contentType = widget.type == "feed"
        ? (feedPost?[index]["content_type"])
        : (feedPostProfile?[index].contentType);
    /*  (Constant.userID !=
        feedPostProfile?[index].userId.toString() &&
        feedPostProfile?[index].payContent == true)
        ? null */
    if (contentType == 1) {
      return SizedBox(
        height: 320,
        width: MediaQuery.of(context).size.width,
        child: MyNetworkImage(
          imagePath: imageUrl,
          fit: BoxFit.fitHeight,
        ),
      );
    } else {
      return ReelsPlayer(
        isLiveStream: false,
        index: index,
        pagePos: index,
        videoUrl: videoUrl,
        thumbnailImg: thumbnail,
      );
    }
  }
}
