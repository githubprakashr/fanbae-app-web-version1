import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:fanbae/livestream/fetchgiftmodel.dart' as fetchgift;
import 'package:fanbae/model/profilemodel.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class LiveStreamProvider extends ChangeNotifier {
  bool isFrontCamera = true;
  bool isFlashOn = false;
  bool isMicOn = true;
  bool isFollow = false;

  int countTime = 0;
  bool isLivePage = false;
  int? totalViewCount = 0;

  ScrollController scrollController = ScrollController();
  List<ChatModel>? commentList = [];
  Timer? timer;

  bool isShowGift = false;
  String? giftUrl;

  int? status;
  int? deletedRoomId;

  fetchgift.FetchGiftModel fetchGiftModel = fetchgift.FetchGiftModel();
  List<fetchgift.Result>? giftList = [];
  bool giftloadMore = false, giftloading = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;
  final List<String> _gifts = [];

  List<String> get gifts => _gifts;

  /* Profile Api  */
  ProfileModel profileModel = ProfileModel();

  Future<void> onSwitchMic() async {
    isMicOn = !isMicOn;
    ZegoExpressEngine.instance.enableAudioCaptureDevice(isMicOn);
    notifyListeners();
  }

  Future<void> onSwitchCamera() async {
    if (isFrontCamera) {
      ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
      isFrontCamera = !isFrontCamera;
      ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
    } else {
      ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
      isFrontCamera = !isFrontCamera;
      ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
    }
  }

  void onChangeTime() {
    isLivePage = true;

    Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (isLivePage) {
          countTime++;
          printLog("Live Streaming Time => ${onConvertSecondToHMS(countTime)}");
          notifyListeners();
        } else {
          timer.cancel();
          countTime = 0;
          notifyListeners();
        }
      },
    );
  }

  String onConvertSecondToHMS(int totalSeconds) {
    Duration duration = Duration(seconds: totalSeconds);

    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    String time = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return time;
  }

  liveCountUpdate(int viewCount) async {
    totalViewCount = viewCount;
    notifyListeners();
  }

  storeComment({required data}) async {
    ChatModel newComment = ChatModel.fromJson(data);
    commentList?.add(newComment);
    log("Length Comment==> ${commentList?.length}");
    notifyListeners();
    onScrollDown();
  }

  List<ChatModel> fakeComment = [
    ChatModel(
      comment: "This is a great live stream!",
      fullName: "John Doe",
      userName: "John Doe",
      image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
    ),
    ChatModel(
      comment: "Loving the content ❤️",
      fullName: "Jane Smith",
      userName: "Jane Smith",
      image: "https://randomuser.me/api/portraits/men/1.jpg",
    ),
    ChatModel(
      comment: "Keep it up!",
      fullName: "Chris Brown",
      userName: "Chris Brown",
      image: "https://randomuser.me/api/portraits/women/2.jpg",
    ),
    ChatModel(
      comment: "Amazing vibes! 🎉",
      fullName: "Emily Davis",
      userName: "Emily Davis",
      image: "https://randomuser.me/api/portraits/men/3.jpg",
    ),
    ChatModel(
      comment: "Hello everyone 👋",
      fullName: "Michael Scott",
      userName: "Michael Scott",
      image: "https://randomuser.me/api/portraits/women/4.jpg",
    ),
    ChatModel(
      comment: "What a performance!",
      fullName: "Pam Beesly",
      userName: "Pam Beesly",
      image: "https://randomuser.me/api/portraits/men/5.jpg",
    ),
    ChatModel(
      comment: "I'm learning a lot!",
      fullName: "Jim Halpert",
      userName: "Jim Halpert",
      image: "https://randomuser.me/api/portraits/men/7.jpg",
    ),
    ChatModel(
      comment: "Can't wait for the next part!",
      fullName: "Dwight Schrute",
      userName: "Dwight Schrute",
      image: "https://randomuser.me/api/portraits/women/6.jpg",
    ),
    ChatModel(
      comment: "Greetings from New York 🌆",
      fullName: "Oscar Martinez",
      userName: "Oscar Martinez",
      image: "https://randomuser.me/api/portraits/men/9.jpg",
    ),
    ChatModel(
      comment: "This is so engaging!",
      fullName: "Stanley Hudson",
      userName: "Stanley Hudson",
      image: "https://randomuser.me/api/portraits/women/10.jpg",
    ),
  ];

  /* Fake Comment Added  */

  addFakeComment({isFake}) {
    int currentIndex = 0;
    if (Constant.isFake == "1" && isFake == "1") {
      timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        commentList?.add(fakeComment[currentIndex]);
        printLog("Call==> Fake Comment");
        notifyListeners(); // Notify listeners to update the UI
        currentIndex = (currentIndex + 1) % fakeComment.length;
        onScrollDown();
      });
    }
  }

  void showGift(
      {required dynamic data, String? imageUrl, required String isFake}) {
    final String url = isFake == "0" ? (data["image"] ?? "") : (imageUrl ?? "");
    print('url :$url');
    if (url.isEmpty) return;

    gifts.add(url);
    notifyListeners();

    Future.delayed(const Duration(seconds: 15), () {
      gifts.remove(url);
      notifyListeners();
    });
  }

  clearImage() {
    giftUrl = null;
    notifyListeners();
  }

  clearCount() {
    totalViewCount = 0;
  }

  clearComment() {
    commentList = [];
    commentList?.clear();
    fetchGiftModel = fetchgift.FetchGiftModel();
    totalViewCount = 0;
    giftList = [];
    giftList?.clear();
    giftloadMore = false;
    giftloading = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    timer?.cancel();
  }

  Future<void> onScrollDown() async {
    try {
      await Future.delayed(const Duration(milliseconds: 10));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
      await Future.delayed(const Duration(milliseconds: 10));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    } catch (e) {
      printLog("Scroll Error ==> ${e.toString()}");
    }
  }

  Future<void> getProfile(BuildContext context, touserid) async {
    giftloading = true;
    profileModel = await ApiService().profile(touserid);
    giftloading = false;
    notifyListeners();
  }

  Future<void> fetchGift(pageNo) async {
    giftloading = true;
    fetchGiftModel = await ApiService().getGift(pageNo);
    if (fetchGiftModel.status == 200) {
      setPaginationData(fetchGiftModel.totalRows, fetchGiftModel.totalPage,
          fetchGiftModel.currentPage, fetchGiftModel.morePage);
      if (fetchGiftModel.result != null &&
          (fetchGiftModel.result?.length ?? 0) > 0) {
        printLog(
            "followingModel length :==> ${(fetchGiftModel.result?.length ?? 0)}");
        if (fetchGiftModel.result != null &&
            (fetchGiftModel.result?.length ?? 0) > 0) {
          printLog(
              "followingModel length :==> ${(fetchGiftModel.result?.length ?? 0)}");
          for (var i = 0; i < (fetchGiftModel.result?.length ?? 0); i++) {
            giftList?.add(fetchGiftModel.result?[i] ?? fetchgift.Result());
          }
          final Map<int, fetchgift.Result> postMap = {};
          giftList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          giftList = postMap.values.toList();
          printLog("categoryList length :==> ${(giftList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    giftloading = false;
    notifyListeners();
  }

  setPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }

  setLoadMore(giftloadMore) {
    this.giftloadMore = giftloadMore;
    notifyListeners();
  }
}

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  String? userName;
  String? fullName;
  String? image;
  String? comment;

  ChatModel({
    this.userName,
    this.fullName,
    this.image,
    this.comment,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        userName: json["user_name"],
        fullName: json["full_name"],
        image: json["image"],
        comment: json["comment"],
      );

  Map<String, dynamic> toJson() => {
        "user_name": userName,
        "full_name": fullName,
        "image": image,
        "comment": comment,
      };
}
