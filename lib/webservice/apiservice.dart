import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:fanbae/livestream/fetchgiftmodel.dart';
import 'package:fanbae/livestream/liveuserlistmodel.dart';
import 'package:fanbae/model/addcommentmodel.dart';
import 'package:fanbae/model/addcontentreportmodel.dart';
import 'package:fanbae/model/addcontenttohistorymodel.dart';
import 'package:fanbae/model/addremoveblockchannelmodel.dart';
import 'package:fanbae/model/choosecategorymodel.dart';
import 'package:fanbae/model/download_item.dart';
import 'package:fanbae/model/feedslistmodel.dart';
import 'package:fanbae/model/getchannelfeedmodel.dart';
import 'package:fanbae/model/getchatdata.dart';
import 'package:fanbae/model/getepisodelist.dart';
import 'package:fanbae/model/getpostcommentmodel.dart';
import 'package:fanbae/model/getratingmodel.dart';
import 'package:fanbae/model/introscreenmodel.dart';
import 'package:fanbae/model/modifychannelmodel.dart';
import 'package:fanbae/model/musicmodel.dart';
import 'package:fanbae/model/postcontentuploadmodel.dart';
import 'package:fanbae/model/postmodel.dart';
import 'package:fanbae/model/schedulecallmodel.dart';
import 'package:fanbae/model/sociallinkmodel.dart';
import 'package:fanbae/model/subscriberlistmodel.dart';
import 'package:fanbae/provider/videodownloadprovider.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/model/addremovelikedislikemodel.dart';
import 'package:fanbae/model/addremovesubscribemodel.dart';
import 'package:fanbae/model/addremovewatchlatermodel.dart';
import 'package:fanbae/model/addviewmodel.dart';
import 'package:fanbae/model/adspackagemodel.dart';
import 'package:fanbae/model/adspackagetransectionmodel.dart';
import 'package:fanbae/model/deletecommentmodel.dart';
import 'package:fanbae/model/deleteplaylistmodel.dart';
import 'package:fanbae/model/editplaylistmodel.dart';
import 'package:fanbae/model/episodebyplaylistmodel.dart';
import 'package:fanbae/model/episodebypodcastmodel.dart';
import 'package:fanbae/model/episodebyradio.dart';
import 'package:fanbae/model/getadsmodel.dart';
import 'package:fanbae/model/getcontentbychannelmodel.dart';
import 'package:fanbae/model/getcontentbyplaylistmodel.dart';
import 'package:fanbae/model/gethistorymodel.dart';
import 'package:fanbae/model/getmusicbycategorymodel.dart';
import 'package:fanbae/model/getmusicbylanguagemodel.dart';
import 'package:fanbae/model/getnotificationmodel.dart';
import 'package:fanbae/model/getpagesmodel.dart';
import 'package:fanbae/model/getplaylistcontentmodel.dart';
import 'package:fanbae/model/getrelatedmusicmodel.dart';
import 'package:fanbae/model/getrentcontentbychannelmodel.dart';
import 'package:fanbae/model/getreportreasonmodel.dart';
import 'package:fanbae/model/getuserbyrentcontentmodel.dart';
import 'package:fanbae/model/likevideosmodel.dart';
import 'package:fanbae/model/packagemodel.dart';
import 'package:fanbae/model/paymentoptionmodel.dart';
import 'package:fanbae/model/relatedvideomodel.dart';
import 'package:fanbae/model/removecontenttohistorymodel.dart';
import 'package:fanbae/model/rentsectiondetailmodel.dart';
import 'package:fanbae/model/rentsectionmodel.dart';
import 'package:fanbae/model/replaycommentmodel.dart';
import 'package:fanbae/model/sectiondetailmodel.dart';
import 'package:fanbae/model/sectionlistmodel.dart';
import 'package:fanbae/model/shortmodel.dart';
import 'package:fanbae/model/usagehistorymodel.dart';
import 'package:fanbae/model/watchlatermodel.dart';
import 'package:fanbae/model/withdrawalrequestmodel.dart';
import 'package:fanbae/model/categorymodel.dart';
import 'package:fanbae/model/commentmodel.dart';
import 'package:fanbae/model/generalsettingmodel.dart';
import 'package:fanbae/model/loginmodel.dart';
import 'package:fanbae/model/profilemodel.dart';
import 'package:fanbae/model/searchhistorymodel.dart';
import 'package:fanbae/model/searchmodel.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/model/detailmodel.dart';
import 'package:fanbae/model/videolistmodel.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../model/ExploreChannelsModel.dart';
import '../model/addremovecontenttoplaylistmodel.dart';
import 'package:fanbae/model/detailmodel.dart' as contentdetails;
import 'package:path/path.dart' as path;

import '../model/chathistorymodel.dart';
import '../model/creatoradmodel.dart';
import '../model/creatorlistmodel.dart';
import '../model/earningmodel.dart';
import '../model/followers_model.dart';
import '../model/governmentdocumentmodel.dart';
import '../model/membership_plan_model.dart';
import '../model/overallstatisticsmodel.dart';
import '../model/packagechannelsmodel.dart';
import '../model/planfeaturesmodel.dart';

import '../model/podcastmodel.dart';
import '../model/subscribeChannelModel.dart';
import '../model/subscribingChannels.dart';

class ApiService {
  String baseurl = Constant().baseurl;
  late Dio dio;

  ApiService() {
    dio = Dio();
    // dio.interceptors.add(
    //   PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseBody: true,
    //     responseHeader: false,
    //     compact: false,
    //   ),
    // );
  }

  Future<GeneralsettingModel> generalsetting() async {
    GeneralsettingModel generalsettingModel;
    String apiname = "general_setting";
    Response response = await dio.post('$baseurl$apiname');
    generalsettingModel = GeneralsettingModel.fromJson(response.data);
    return generalsettingModel;
  }

  Future<SuccessModel> sendGift(creatorId, giftId) async {
    SuccessModel successModel;
    String apiname = "send-creator-gift";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID,
          'creator_id': creatorId,
          "gift_id": giftId
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<IntroScreenModel> getOnboardingScreen() async {
    IntroScreenModel introScreenModel;
    String apiName = "get_onboarding_screen";
    Response response = await dio.post(
      '$baseurl$apiName',
    );
    introScreenModel = IntroScreenModel.fromJson(response.data);
    return introScreenModel;
  }

  Future<LoginModel> login(
      String type,
      String email,
      String mobile,
      String devicetype,
      String devicetoken,
      String countrycode,
      String countryName) async {
    LoginModel loginModel;
    String apiname = "login";
    Map<String, dynamic> data = {
      'type': type,
      'email': email,
      'mobile_number': mobile,
      'device_type': devicetype,
      'device_token': devicetoken,
      'country_code': countrycode,
      'country_name': countryName,
    };
    Response response = await dio.post('$baseurl$apiname', data: data);

    loginModel = LoginModel.fromJson(response.data);
    return loginModel;
  }

  Future<LoginModel> otpLogin(
    String type,
    String mobile,
  ) async {
    LoginModel loginModel;
    String apiname = "login";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'type': type,
          'mobile_number': mobile,
        }));

    loginModel = LoginModel.fromJson(response.data);
    return loginModel;
  }

  Future<CategoryModel> videoCategory(pageNo) async {
    CategoryModel categoryModel;
    String apiname = "get_video_category";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'page_no': pageNo,
        }));
    categoryModel = CategoryModel.fromJson(response.data);
    return categoryModel;
  }

  Future<SuccessModel> removesearchhistory(id) async {
    SuccessModel removesearchhistoryModel;
    String apiname = "remove_search_history";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'id': id,
        }));
    removesearchhistoryModel = SuccessModel.fromJson(response.data);
    return removesearchhistoryModel;
  }

  Future<VideoListModel> videolist(ishomePage, categoryid, pageNo) async {
    VideoListModel videolistModel;
    String getvideolist = "get_video_list";
    Response response = await dio.post('$baseurl$getvideolist',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'is_home_page': ishomePage,
          'category_id': categoryid,
          'page_no': pageNo,
        }));
    videolistModel = VideoListModel.fromJson(response.data);
    return videolistModel;
  }

  Future<ShortModel> shrotslist(pageNo, viewType) async {
    ShortModel shortModel;
    String apiname = "get_reels_list";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
          'view_type': viewType
        }));
    shortModel = ShortModel.fromJson(response.data);
    return shortModel;
  }

  Future<DetailsModel> videodetails(contentid, contenttype) async {
    printLog("contentid===>$contentid");
    printLog("contenttype===>$contenttype");
    printLog("contenttype===>${Constant.userID}");
    DetailsModel detailsModel;
    String apiname = "get_content_detail";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_id': contentid,
          'content_type': contenttype,
        }));
    detailsModel = DetailsModel.fromJson(response.data);
    return detailsModel;
  }

  Future<RelatedVideoModel> relatedVideo(contentId, pageNo) async {
    RelatedVideoModel relatedVideoModel;
    String apiname = "get_releted_video";
    Map<String, dynamic> data = {
      'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      'content_id': contentId,
      'page_no': pageNo,
    };
    Response response = await dio.post('$baseurl$apiname', data: data);
    relatedVideoModel = RelatedVideoModel.fromJson(response.data);
    return relatedVideoModel;
  }

  Future<SearchHistoryModel> searchvideohistory(userid) async {
    SearchHistoryModel searchvideohistoryModel;
    String apiname = "get_search_history";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        }));
    searchvideohistoryModel = SearchHistoryModel.fromJson(response.data);
    return searchvideohistoryModel;
  }

  Future<SearchModel> searchvideo(userid, String title) async {
    SearchModel searchvideoModel;
    String apiname = "search_video";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'title': title,
        }));
    searchvideoModel = SearchModel.fromJson(response.data);
    return searchvideoModel;
  }

  Future<AddCommentModel> addcomment(
      contenttype, contentid, episodeid, comment, commentid) async {
    AddCommentModel addCommentModel;
    String apiname = "add_comment";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': contentid,
          'episode_id': episodeid,
          'comment': comment,
          'comment_id': commentid,
        }));
    addCommentModel = AddCommentModel.fromJson(response.data);
    return addCommentModel;
  }

  Future<DeleteCommentModel> deleteComment(commentid) async {
    DeleteCommentModel deleteCommentModel;
    String apiname = "delete_comment";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'comment_id': commentid,
        }));
    deleteCommentModel = DeleteCommentModel.fromJson(response.data);
    return deleteCommentModel;
  }

  Future<CommentModel> getcomment(contenttype, videoid, pageNo) async {
    CommentModel getcommentModel;
    String apiname = "get_comment";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': videoid,
          'page_no': pageNo,
        }));
    getcommentModel = CommentModel.fromJson(response.data);
    return getcommentModel;
  }

  Future<SubscribingChannelsModel> getSubscribingChannels() async {
    SubscribingChannelsModel getSubscribingChannels;
    String apiname = "get-user-subscribed-list";
    Response response = await dio.get('$baseurl$apiname',
        queryParameters: {
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        },
        options: Options(headers: {"Accept": "application/json"}));
    getSubscribingChannels = SubscribingChannelsModel.fromJson(response.data);
    return getSubscribingChannels;
  }

  Future<SubscribeChannelsModel> getSubscribeChannels() async {
    SubscribeChannelsModel getSubscribingChannels;
    String apiname = "get-channel-subscribed-user-list";
    Response response = await dio.get('$baseurl$apiname',
        queryParameters: {
          'creator_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        },
        options: Options(headers: {"Accept": "application/json"}));
    getSubscribingChannels = SubscribeChannelsModel.fromJson(response.data);
    return getSubscribingChannels;
  }

  Future<FollowersModel> getFollowers(pageNo) async {
    FollowersModel followersModel;
    String apiName = "get_subscriber_list";
    Response response = await dio.post('$baseurl$apiName',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    followersModel = FollowersModel.fromJson(response.data);
    return followersModel;
  }

  Future<ExploreChannelsModel> getExploringChannels() async {
    ExploreChannelsModel getExploringChannels;
    String apiname = "explore_creators";
    Response response = await dio.get('$baseurl$apiname',
        queryParameters: {
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        },
        options: Options(headers: {"Accept": "application/json"}));
    getExploringChannels = ExploreChannelsModel.fromJson(response.data);
    return getExploringChannels;
  }

  Future<ReplayCommentModel> replayComment(commentid, pageNo) async {
    ReplayCommentModel replayCommentModel;
    String apiname = "get_reply_comment";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'comment_id': commentid,
          'page_no': pageNo,
        }));
    replayCommentModel = ReplayCommentModel.fromJson(response.data);
    return replayCommentModel;
  }

  Future<ProfileModel> profile(touserid) async {
    ProfileModel profileModel;
    String apiname = "get_profile";
    Map<String, dynamic> data = {
      'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      'to_user_id': touserid,
    };
    Response response = await dio.post('$baseurl$apiname', data: data);
    profileModel = ProfileModel.fromJson(response.data);
    return profileModel;
  }

  Future<SuccessModel> updateprofile(
    String userid,
    String fullname,
    String channelName,
    String email,
    String description,
    String number,
    String countrycode,
    String countryName,
    File image,
    File coverImage,
    int liveAmount,
    int chatAmount,
    int audioCallAmount,
    int videoCallAmount,
  ) async {
    SuccessModel updateprofileModel;
    String apiname = "update_profile";
    print(number);
    print(number);
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': userid.isEmpty || userid == "" ? "0" : userid,
          'full_name': fullname,
          'channel_name': channelName,
          'email': email,
          'description': description,
          'mobile_number': number,
          'country_code': countrycode,
          'country_name': countryName,
          "image": (image.path.isNotEmpty)
              ? MultipartFile.fromFileSync(
                  image.path,
                  filename: (image.path),
                )
              : "",
          "cover_img": (coverImage.path.isNotEmpty)
              ? MultipartFile.fromFileSync(
                  coverImage.path,
                  filename: (coverImage.path),
                )
              : "",
          "live_amount": liveAmount,
          "chat_amount": chatAmount,
          "audio_call_amount": audioCallAmount,
          "video_call_amount": videoCallAmount,
        }));
    updateprofileModel = SuccessModel.fromJson(response.data);
    return updateprofileModel;
  }

  Future<SuccessModel> requestCreator(
    String name,
    String dob,
    String chanelName,
    int category,
    String youtubeChannel,
    String instagramChannel,
    String facebookChannel,
    int govId,
    File? uploadData,
    File? image,
    String paymentName,
    String bankName,
    String accNo,
    String ifscCode,
    String livePrice,
    String chatPrice,
    String audioCallPrice,
    String videoCallPrice, {
    Uint8List? selfieBytes,
    String? selfieName,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    SuccessModel requestCreatorModel;
    String apiname = "request-creator";

    MultipartFile multipartFile;

    if (fileBytes != null && fileName != null) {
      multipartFile = MultipartFile.fromBytes(fileBytes, filename: fileName);
    } else if (uploadData != null) {
      multipartFile = MultipartFile.fromFileSync(uploadData.path,
          filename: uploadData.path.split('/').last);
    } else {
      throw Exception("No valid file data provided");
    }

    MultipartFile multipartSelfie;

    if (selfieBytes != null && selfieName != null) {
      multipartSelfie =
          MultipartFile.fromBytes(selfieBytes, filename: selfieName);
    } else if (image != null) {
      multipartSelfie = MultipartFile.fromFileSync(image.path,
          filename: image.path.split('/').last);
    } else {
      throw Exception("No valid file data provided");
    }

    FormData formData = FormData.fromMap({
      'user_id': Constant.userID,
      'creator_name': name,
      'creator_dob': dob,
      'channel_name': chanelName,
      'category': category,
      'youtube_url': youtubeChannel,
      'instagram_url': instagramChannel,
      'facebook_url': facebookChannel,
      'gid': govId,
      'upload_data': multipartFile,
      'live_photo': multipartSelfie,
      'payment_name': paymentName,
      "bank_name": bankName,
      "account_no": accNo,
      "ifsc_code": ifscCode,
      "live_amount": livePrice,
      "chat_amount": chatPrice,
      "audio_call_amount": audioCallPrice,
      "video_call_amount": videoCallPrice,
    });
    Response response = await dio.post('$baseurl$apiname', data: formData);
    print(response.data);
    requestCreatorModel = SuccessModel.fromJson(response.data);
    return requestCreatorModel;
  }

  Future<SuccessModel> updateMembershipPlan(
    String? id,
    String creatorid,
    String name,
    int price,
    int offerPrice,
    String planValue,
    String planType,
    Map<String, dynamic> planFeatures,
  ) async {
    SuccessModel membershipModel;
    String apiname = "update_creater_subscription_plan";

    Map<String, dynamic> data = {
      'id': id,
      'creater_id': creatorid,
      'name': name,
      'price': price,
      'offer_price': offerPrice,
      'plan_value': planValue,
      'plan_type': planType,
      'plan_features': planFeatures, // should be a list of maps
    };

    print(data);

    Response response = await dio.post('$baseurl$apiname', data: data);
    membershipModel = SuccessModel.fromJson(response.data);
    return membershipModel;
  }

  Future<SuccessModel> createAds(
      int? id,
      String userId,
      String title,
      int budget,
      int type,
      String redirectUrl,
      String image,
      String? video,
      String? videoImage) async {
    SuccessModel adModel;
    String apiname = "create_ads";

    Map<String, dynamic> data = {
      'id': id,
      'user_id': userId,
      'title': title,
      'budget': budget,
      'redirect_uri': redirectUrl,
      'type': type,
      "image": image,
    };

    if (type == 3) {
      data.addAll({"video": video, "video_image": videoImage});
    }

    print(data);

    Response response = await dio.post('$baseurl$apiname', data: data);
    adModel = SuccessModel.fromJson(response.data);
    return adModel;
  }

  Future<SuccessModel> createMusic(
    String channelId,
    File? music,
    File? portraitImg,
    int categoryId,
    int languageId,
    int artistId,
    int isLike,
    int isComment,
    String title,
    String description, {
    Uint8List? musicBytes,
    String? musicName,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    SuccessModel adModel;
    String apiname = "create_music";

    MultipartFile multipartFile;

    if (musicBytes != null && musicName != null) {
      multipartFile = MultipartFile.fromBytes(musicBytes, filename: musicName);
    } else if (music != null) {
      multipartFile = MultipartFile.fromFileSync(music.path,
          filename: music.path.split('/').last);
    } else {
      throw Exception("No valid file data provided");
    }

    MultipartFile portraitMultipartImage;
    MultipartFile landscapeMultipartImage;

    if (imageBytes != null && imageName != null) {
      portraitMultipartImage =
          MultipartFile.fromBytes(imageBytes, filename: imageName);
      landscapeMultipartImage = MultipartFile.fromBytes(imageBytes,
          filename: imageName); // new instance
    } else if (portraitImg != null) {
      portraitMultipartImage = MultipartFile.fromFileSync(portraitImg.path,
          filename: portraitImg.path.split('/').last);
      landscapeMultipartImage = MultipartFile.fromFileSync(portraitImg.path,
          filename: portraitImg.path.split('/').last); // new instance
    } else {
      throw Exception("No valid image file provided");
    }

    FormData formData = FormData.fromMap({
      'channel_id': channelId,
      "id": null,
      "music": multipartFile,
      "content_upload_type": 'server_video',
      'portrait_img': portraitMultipartImage,
      'landscape_img': landscapeMultipartImage,
      'category_id': categoryId,
      'language_id': languageId,
      'artist_id': artistId,
      "is_like": isLike,
      "is_comment": isComment,
      "title": title,
      "description": description
    });
    Response response = await dio.post('$baseurl$apiname', data: formData);
    adModel = SuccessModel.fromJson(response.data);
    return adModel;
  }

  Future<PodcastModel> createPodcast(
    int? id,
    String title,
    String description,
    File? portraitImg,
    int categoryId,
    int languageId, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    PodcastModel podcast;
    String apiname = "create_podcast";

    MultipartFile portraitMultipartImage;
    MultipartFile landscapeMultipartImage;

    if (imageBytes != null && imageName != null) {
      portraitMultipartImage =
          MultipartFile.fromBytes(imageBytes, filename: imageName);
      landscapeMultipartImage = MultipartFile.fromBytes(imageBytes,
          filename: imageName); // new instance
    } else if (portraitImg != null) {
      portraitMultipartImage = MultipartFile.fromFileSync(portraitImg.path,
          filename: portraitImg.path.split('/').last);
      landscapeMultipartImage = MultipartFile.fromFileSync(portraitImg.path,
          filename: portraitImg.path.split('/').last); // new instance
    } else {
      throw Exception("No valid image file provided");
    }

    FormData formData = FormData.fromMap({
      "id": id,
      "user_id": Constant.userID,
      'portrait_img': portraitMultipartImage,
      'landscape_img': landscapeMultipartImage,
      'category_id': categoryId,
      'language_id': languageId,
      "title": title,
      "description": description
    });
    Response response = await dio.post('$baseurl$apiname', data: formData);
    podcast = PodcastModel.fromJson(response.data);
    return podcast;
  }

  Future<SuccessModel> createPodcastEpisode(
    int podcastId,
    int? id,
    String uploadType,
    String? url,
    File? music,
    File? portraitImg,
    int isLike,
    int isComment,
    String title,
    String description, {
    Uint8List? musicBytes,
    String? musicName,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    SuccessModel adModel;
    String apiname = "podcastsepisode/create";

    MultipartFile? multipartFile;

    if (musicBytes != null && musicName != null) {
      multipartFile = MultipartFile.fromBytes(musicBytes, filename: musicName);
    } else if (music != null) {
      multipartFile = MultipartFile.fromFileSync(music.path,
          filename: music.path.split('/').last);
    }

    MultipartFile portraitMultipartImage;
    MultipartFile landscapeMultipartImage;

    if (imageBytes != null && imageName != null) {
      portraitMultipartImage =
          MultipartFile.fromBytes(imageBytes, filename: imageName);
      landscapeMultipartImage = MultipartFile.fromBytes(imageBytes,
          filename: imageName); // new instance
    } else if (portraitImg != null) {
      portraitMultipartImage = MultipartFile.fromFileSync(portraitImg.path,
          filename: portraitImg.path.split('/').last);
      landscapeMultipartImage = MultipartFile.fromFileSync(portraitImg.path,
          filename: portraitImg.path.split('/').last); // new instance
    } else {
      throw Exception("No valid image file provided");
    }

    FormData formData = FormData.fromMap({
      'user_id': Constant.userID,
      "podcasts_id": podcastId,
      "id": id,
      "episode_upload_type": uploadType,
      "music": multipartFile,
      "url": url,
      'portrait_img': portraitMultipartImage,
      'landscape_img': landscapeMultipartImage,
      "is_like": isLike,
      "is_comment": isComment,
      "name": title,
      "description": description
    });
    Response response = await dio.post('$baseurl$apiname', data: formData);
    adModel = SuccessModel.fromJson(response.data);
    return adModel;
  }

  Future<SuccessModel> deleteMembershipPlan(
    int? id,
  ) async {
    SuccessModel membershipModel;
    String apiname = "delete_creater_subscription_plan";
    Map<String, dynamic> data = {
      'id': id,
    };

    Response response = await dio.post('$baseurl$apiname', data: data);
    membershipModel = SuccessModel.fromJson(response.data);
    return membershipModel;
  }

  Future<SuccessModel> sendChatMessage(String? senderId, String? receiverId,
      String token, String message, String type) async {
    SuccessModel membershipModel;
    String apiname = "send-chat";
    Map<String, dynamic> data = {
      'sender_id': senderId,
      "receiver_id": receiverId,
      "fcm_token": token,
      'message': message,
      "type": type
    };

    try {
      debugPrint('📤 API Call: $baseurl$apiname');
      debugPrint(
          '📦 Payload: ${data.toString().replaceAll(token, '***TOKEN***')}');

      Response response = await dio.post('$baseurl$apiname', data: data);

      debugPrint('📬 Response status: ${response.statusCode}');
      debugPrint('📬 Response data: ${response.data}');

      membershipModel = SuccessModel.fromJson(response.data);
      return membershipModel;
    } catch (e) {
      debugPrint('❌ API Error in sendChatMessage: $e');
      // Return error model to handle gracefully
      return SuccessModel(
        status: 0,
        message: e.toString().contains('DioException')
            ? 'Network error. Please check your connection.'
            : 'Failed to send message: $e',
      );
    }
  }

  Future<SuccessModel> approveChatMessage(
      String? senderId, String? receiverId, int status, String? message) async {
    SuccessModel membershipModel;
    String apiname = "check-valid-chat";
    Map<String, dynamic> data = {
      'sender_id': senderId,
      "receiver_id": receiverId,
      "status": status,
      "message_content": message
    };
    Response response = await dio.post('$baseurl$apiname', data: data);
    print({
      'sender_id': senderId,
      "receiver_id": receiverId,
      "status": status,
    });
    print(response.realUri);
    print(response.data);
    membershipModel = SuccessModel.fromJson(response.data);
    return membershipModel;
  }

  Future<GetChatData> getChatData(String? senderId, String? receiverId) async {
    GetChatData chatData;
    String apiname = "get-coin-balance";
    Map<String, dynamic> data = {
      'sender_id': senderId,
      "receiver_id": receiverId
    };
    Response response = await dio.post('$baseurl$apiname', data: data);
    chatData = GetChatData.fromJson(response.data);
    return chatData;
  }

  Future<ChatHistoryData> chatHistory() async {
    ChatHistoryData chatData;
    String apiname = "get-chat-data";
    Map<String, dynamic> data = {
      'user_id': Constant.userID,
    };
    Response response = await dio.post('$baseurl$apiname', data: data);
    chatData = ChatHistoryData.fromJson(response.data);
    return chatData;
  }

  Future<CreatorListModel> getCreatorList() async {
    CreatorListModel creatorData;
    String apiname = "chat_creator_list";
    Response response =
        await dio.get('$baseurl$apiname?user_id=${Constant.userID}');
    print(response.realUri);
    creatorData = CreatorListModel.fromJson(response.data);
    return creatorData;
  }

  Future<OverallStatisticsModel> getOverallStatistics() async {
    OverallStatisticsModel statistics;
    String apiname = "view-overall-statics";
    Map<String, dynamic> data = {
      'user_id': Constant.userID,
    };
    Response response = await dio.post('$baseurl$apiname', data: data);
    statistics = OverallStatisticsModel.fromJson(response.data);
    return statistics;
  }

  Future<FeedsListModel> getFeedList(viewType) async {
    FeedsListModel feedData;
    String apiname = "get_feed_list";
    Map<String, dynamic> data = {
      'user_id': viewType == 'following' && Constant.userID == null
          ? Constant.userID
          : Constant.userID ?? '0',
      'is_home_page': 1,
      'view_type': viewType
    };
    Response response = await dio.post('$baseurl$apiname', data: data);
    feedData = FeedsListModel.fromJson(response.data);
    return feedData;
  }

  Future<SuccessModel> deleteCreatorAd(
    int? id,
  ) async {
    SuccessModel deleteAd;
    String apiname = "delete_ads";
    Map<String, dynamic> data = {
      'id': id,
    };
    Response response = await dio.post('$baseurl$apiname', data: data);
    deleteAd = SuccessModel.fromJson(response.data);
    return deleteAd;
  }

  Future<SuccessModel> callRequest(
      String channelId, String date, String slot, String type) async {
    SuccessModel callRequest;
    String apiname = "schedule_video_call_request";
    Map<String, dynamic> data = {
      'user_id': Constant.userID,
      'channel_id': channelId,
      'date': date,
      'slot': slot,
      'type': type
    };
    print(data);
    print('ddddddddddddddd');
    Response response = await dio.post('$baseurl$apiname', data: data);
    callRequest = SuccessModel.fromJson(response.data);
    return callRequest;
  }

  Future<MembershipPlanModel> getMembershipPlans(creatorId, userId) async {
    MembershipPlanModel membershipPlanModel;
    String apiname = "creater_subscription_plans";
    Response response =
        await dio.get('$baseurl$apiname?creater_id=$creatorId&user_id=$userId');
    membershipPlanModel = MembershipPlanModel.fromJson(response.data);
    print(response.data);
    print(response.realUri);
    return membershipPlanModel;
  }

  Future<EarningModel> getEarnings(selectedDate, type) async {
    EarningModel earningModel;
    String apiname = "view-creator-earning";
    Response response = await dio.get(
        '$baseurl$apiname?user_id=${Constant.userID}&selective_date=$selectedDate&type=$type');
    earningModel = EarningModel.fromJson(response.data);
    print(response.data);
    print(response.realUri);
    return earningModel;
  }

  Future<PodcastModel> getPodcasts() async {
    PodcastModel podcastModel;
    String apiname = "podcasts";
    Response response =
        await dio.get('$baseurl$apiname?user_id=${Constant.userID}');
    print(response);
    podcastModel = PodcastModel.fromJson(response.data);
    return podcastModel;
  }

  Future<PodcastModel> getPodcastEpisodes(id) async {
    PodcastModel podcastModel;
    String apiname = "podcasts";
    Response response =
        await dio.get('$baseurl$apiname/$id?user_id=${Constant.userID}');
    print(response);
    podcastModel = PodcastModel.fromJson(response.data);
    return podcastModel;
  }

  Future<MusicModel> getMusicData() async {
    MusicModel musicModel;
    String apiname = "get_music_data";
    Response response = await dio.get('$baseurl$apiname');
    musicModel = MusicModel.fromJson(response.data);
    return musicModel;
  }

  Future<ScheduleCallModel> getScheduleCallData(
      String? creatorId, date, status, month, year) async {
    ScheduleCallModel scheduleModel;
    String apiname = "schedule_video_calls";
    Response response = Constant.isCreator == "0" && creatorId != null
        ? await dio.get(
            '$baseurl$apiname?user_id=${Constant.userID}&channel_id=$creatorId'
            '&date=$date&status=$status${month != null ? '&month=$month&year=$year' : ''}')
        : await dio.get(
            '$baseurl$apiname?user_id=${Constant.userID}&date=$date&status=$status${month != null ? '&month=$month&year=$year' : ''}');
    scheduleModel = ScheduleCallModel.fromJson(response.data);
    print(response.realUri);
    print(scheduleModel.data.bookedSlots);
    return scheduleModel;
  }

  Future<CreatorAdModel> getCreatorAds(userId) async {
    CreatorAdModel getAdsModel;
    String apiname = "get_creator_ads";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': userId,
        }));
    getAdsModel = CreatorAdModel.fromJson(response.data);
    return getAdsModel;
  }

  Future<GetRatingsModel> getRatings(id) async {
    GetRatingsModel getRatingsModel;
    String apiname = "show-rating-creator";
    Response response = await dio.get('$baseurl$apiname/$id');
    getRatingsModel = GetRatingsModel.fromJson(response.data);
    return getRatingsModel;
  }

  Future<ChooseCategoryModel> getCategories(packageId) async {
    ChooseCategoryModel chooseCategoryModel;
    String apiname = "choose-category";
    Map<String, dynamic> data = {'package_id': packageId};
    Response response = await dio.post('$baseurl$apiname', data: data);
    chooseCategoryModel = ChooseCategoryModel.fromJson(response.data);
    return chooseCategoryModel;
  }

  Future<PackageChannelsModel?> getPackageChannels(
      int packageId, List<int> categoryId, BuildContext context) async {
    String apiname = "package-channel-list";
    Map<String, dynamic> data = {
      'package_id': packageId,
      'category_id': categoryId,
      'user_id': Constant.userID,
    };

    Response response = await dio.post('$baseurl$apiname', data: data);

    if (response.data['status'] == 200) {
      return PackageChannelsModel.fromJson(response.data);
    } else {
      Utils().showSnackBar(
        context, // or context if available
        response.data['message'] ?? "Something went wrong",
        false,
      );
      return null;
    }
  }

  Future<PlanFeaturesModel> getPlanFeatures() async {
    PlanFeaturesModel planFeaturesModel;
    String apiname = "plan_features";
    Response response = await dio.post('$baseurl$apiname');
    planFeaturesModel = PlanFeaturesModel.fromJson(response.data);
    return planFeaturesModel;
  }

  Future<GovernmentDocumentModel> getGovernmentDocuments() async {
    GovernmentDocumentModel governmentDocModel;
    String apiname = "government_documents";
    Response response = await dio.post('$baseurl$apiname');
    governmentDocModel = GovernmentDocumentModel.fromJson(response.data);
    return governmentDocModel;
  }

  Future<SuccessModel> createVideo(
      String channelId,
      String video,
      String contentType,
      String portraitImg,
      String title,
      String description,
      int categoryId,
      int isRent,
      int rentPrice,
      int isLike,
      int isComment,
      String type,
      int coin,
      String videoType,
      String episodeName) async {
    SuccessModel createVideoModel;
    String apiname = "create_video";

    Map<String, dynamic> data = {
      'channel_id': channelId,
      'video': video,
      'content_upload_type': contentType,
      'portrait_img': portraitImg,
      'landscape_img': portraitImg,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'is_rent': isRent,
      'rent_price': rentPrice,
      'is_like': isLike,
      'is_comment': isComment,
      'type': type,
      'coin': coin,
      'video_type': videoType,
      'episode_name': episodeName
    };
    Response response = await dio.post('$baseurl$apiname', data: data);
    createVideoModel = SuccessModel.fromJson(response.data);
    return createVideoModel;
  }

  Future<SuccessModel> ratingCreator(
    double rating,
    String message,
    String userId,
    String creatorId,
  ) async {
    SuccessModel ratingCreatorModel;
    String apiname = "rating-creator";

    Map<String, dynamic> data = {
      'rating': rating,
      'message': message,
      'user_id': userId,
      'creator_id': creatorId,
    };
    Response response = await dio.post('$baseurl$apiname', data: data);
    ratingCreatorModel = SuccessModel.fromJson(response.data);
    return ratingCreatorModel;
  }

  Future<SuccessModel> scheduleCallAction(
    int scheduleId,
    String action,
  ) async {
    SuccessModel ratingCreatorModel;
    String apiname = "schedule-videocall-action";

    Map<String, dynamic> data = {
      'schedule_id': scheduleId,
      'action': action,
    };
    Response response = await dio.post('$baseurl$apiname', data: data);
    ratingCreatorModel = SuccessModel.fromJson(response.data);
    return ratingCreatorModel;
  }

  Future<SuccessModel> payVideoPost(
    String userId,
    String contentType,
    int id,
  ) async {
    SuccessModel ratingCreatorModel;
    String apiname = "paid_video_post";

    Map<String, dynamic> data = {
      'user_id': userId,
      'type': contentType,
      'id': id,
    };
    print(data);
    Response response = await dio.post('$baseurl$apiname', data: data);
    print(response.data);
    ratingCreatorModel = SuccessModel.fromJson(response.data);
    return ratingCreatorModel;
  }

  Future<SuccessModel> withdrawRequest(
    String userId,
    int amount,
  ) async {
    SuccessModel ratingCreatorModel;
    String apiname = "withdraw-request";

    Map<String, dynamic> data = {
      'user_id': userId,
      'amount': amount,
    };

    print(data);
    Response response = await dio.post('$baseurl$apiname', data: data);
    print(response.realUri);
    print(response.data);
    print(response.statusMessage);
    ratingCreatorModel = SuccessModel.fromJson(response.data);
    return ratingCreatorModel;
  }

  Future<SuccessModel> subscribeMembership(
      String userId, int packageId, int price) async {
    SuccessModel subscribeMembershipModel;
    String apiname = "subscribe_membership_plan";

    Map<String, dynamic> data = {
      'user_id': userId,
      'package_id': packageId,
      'price': price
    };
    print(data);
    Response response = await dio.post('$baseurl$apiname', data: data);
    print(response.data);
    subscribeMembershipModel = SuccessModel.fromJson(response.data);
    return subscribeMembershipModel;
  }

  Future<PackageModel> package() async {
    PackageModel getpackageModel;
    String apiname = "get_package";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        }));
    getpackageModel = PackageModel.fromJson(response.data);
    return getpackageModel;
  }

  Future<SuccessModel> updateAutoRenew(
      int packageId, String packageType) async {
    SuccessModel successModel;
    String apiname = "switch_auto_renewal_package";
    Response response = await dio.get(
        '$baseurl$apiname?user_id=${Constant.userID}&package_id=$packageId&package_type=$packageType');
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<ModifyChannelsModel> getModifyChannels() async {
    ModifyChannelsModel getChannelModel;
    String apiname = "get_modify_channel";
    Response response =
        await dio.get('$baseurl$apiname?user_id=${Constant.userID}');
    getChannelModel = ModifyChannelsModel.fromJson(response.data);
    return getChannelModel;
  }

  Future<ModifyChannelsModel> updateModifyChannels(
      List<int> channelIds, int autoRenewal) async {
    ModifyChannelsModel getChannelModel;
    String apiname = "update_modify_channel";
    Map<String, dynamic> body = {
      'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      'channel_ids': channelIds,
      'auto_renewal': autoRenewal,
    };
    Response response = await dio.post('$baseurl$apiname', data: body);
    getChannelModel = ModifyChannelsModel.fromJson(response.data);
    return getChannelModel;
  }

  Future<AddViewModel> addView(contenttype, contentid) async {
    AddViewModel addViewModel;
    String apiname = "add_view";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': contentid,
        }));
    print({
      'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      'content_type': contenttype,
      'content_id': contentid,
    });
    print(response.realUri);
    print(response.data);
    addViewModel = AddViewModel.fromJson(response.data);
    return addViewModel;
  }

  Future<SectionListModel> sectionList(
      ishomescreen, contenttype, pageNo) async {
    //log("UserId==> ${Constant.userID}");
    SectionListModel sectionListModel;
    String apiname = "get_music_section";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'is_home_screen': ishomescreen,
          'content_type': contenttype,
          'page_no': pageNo,
        }));

    sectionListModel = SectionListModel.fromJson(response.data);
    return sectionListModel;
  }

  Future<SuccessModel> createPlayList(chennelId, title, playlistType) async {
    SuccessModel successModel;
    String apiname = "create_playlist";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'channel_id': chennelId,
          'title': title,
          'playlist_type': playlistType,
        }));
    print(response);
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<AddremoveContentToPlaylistModel> addremoveContenttoPlaylist(
      chennelId, playlistId, contenttype, contentid, episodeid, type) async {
    AddremoveContentToPlaylistModel addremoveContentToPlaylistModel;
    String apiname = "add_remove_content_to_playlist";
    Map<String, dynamic> body = {
      'channel_id': chennelId,
      'playlist_id': playlistId,
      'content_type': contenttype,
      'content_id': contentid,
      'episode_id': episodeid,
      'type': type,
    };
    Response response = await dio.post('$baseurl$apiname', data: body);
    print(response.data);
    addremoveContentToPlaylistModel =
        AddremoveContentToPlaylistModel.fromJson(response.data);
    return addremoveContentToPlaylistModel;
  }

  Future<GetContentbyChannelModel> contentbyChannel(
      userid, chennelId, contenttype, pageNo) async {
    GetContentbyChannelModel getContentbyChannelModel;
    String apiname = "get_content_by_channel";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'channel_id': chennelId,
          'content_type': contenttype,
          'page_no': pageNo,
        }));
    print({
      'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      'channel_id': chennelId,
      'content_type': contenttype,
      'page_no': pageNo,
    });
    print(response.realUri);
    print(response.data);
    getContentbyChannelModel = GetContentbyChannelModel.fromJson(response.data);
    return getContentbyChannelModel;
  }

  Future<EditPlaylistModel> editPlaylist(
      playlistId, title, playlistType) async {
    EditPlaylistModel editPlaylistModel;
    String apiname = "edit_playlist";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'content_id': playlistId,
          'title': title,
          'playlist_type': playlistType,
        }));
    editPlaylistModel = EditPlaylistModel.fromJson(response.data);
    return editPlaylistModel;
  }

  Future<DeletePlaylistModel> deletePlaylist(playlistId) async {
    DeletePlaylistModel deletePlaylistModel;
    String apiname = "delete_playlist";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'content_id': playlistId,
        }));
    deletePlaylistModel = DeletePlaylistModel.fromJson(response.data);
    return deletePlaylistModel;
  }

  Future<AddRemoveLikeDislikeModel> addRemoveLikeDislike(
      contenttype, contentid, status, episodeId) async {
    //log("UserId==> ${Constant.userID}");
    AddRemoveLikeDislikeModel addRemoveLikeDislikeModel;
    String apiname = "add_remove_like_dislike";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': contentid,
          'status': status,
          'episode_id': episodeId,
        }));
    addRemoveLikeDislikeModel =
        AddRemoveLikeDislikeModel.fromJson(response.data);
    return addRemoveLikeDislikeModel;
  }

  Future<GetRepostReasonModel> reportReason(type, pageNo) async {
    GetRepostReasonModel getRepostReasonModel;
    String apiname = "get_report_reason";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'type': type,
          'page_no': pageNo,
        }));
    getRepostReasonModel = GetRepostReasonModel.fromJson(response.data);
    return getRepostReasonModel;
  }

  Future<AddContentReportModel> addContentReport(
      reportUserid, contentid, message, contenttype) async {
    AddContentReportModel addContentReportModel;
    String apiname = "add_content_report";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'report_user_id': reportUserid,
          'content_id': contentid,
          'message': message,
          'content_type': contenttype,
        }));
    addContentReportModel = AddContentReportModel.fromJson(response.data);
    return addContentReportModel;
  }

  Future<GetWatchlaterModel> watchLaterList(contentType, pageNo) async {
    GetWatchlaterModel watchlaterModel;
    String apiname = "get_watch_later_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contentType,
          'page_no': pageNo,
        }));
    watchlaterModel = GetWatchlaterModel.fromJson(response.data);
    return watchlaterModel;
  }

  Future<LikeContentModel> likeVideos(contentType, pageNo) async {
    //log("pageNo========>$pageNo");
    LikeContentModel likeContentModel;
    String apiname = "get_like_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contentType,
          'page_no': pageNo,
        }));
    likeContentModel = LikeContentModel.fromJson(response.data);
    return likeContentModel;
  }

  Future<AddremoveWatchlaterModel> addremoveWatchLater(
      contenttype, contentid, episodeid, type) async {
    AddremoveWatchlaterModel addremoveWatchlaterModel;
    String apiname = "add_remove_watch_later";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': contentid,
          'episode_id': episodeid,
          'type': type,
        }));
    ;
    ;
    ;
    print(response.realUri);
    print({
      'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      'content_type': contenttype,
      'content_id': contentid,
      'episode_id': episodeid,
      'type': type,
    });
    addremoveWatchlaterModel = AddremoveWatchlaterModel.fromJson(response.data);
    return addremoveWatchlaterModel;
  }

  Future<AddremoveSubscribeModel> addremoveSubscribe(touserid, type) async {
    AddremoveSubscribeModel addremoveSubscribeModel;
    String apiname = "add_remove_subscribe";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'to_user_id': touserid,
          'type': type,
        }));
    addremoveSubscribeModel = AddremoveSubscribeModel.fromJson(response.data);
    return addremoveSubscribeModel;
  }

  Future<AddcontenttoHistoryModel> addContentToHistory(
      contenttype, contentid, stoptime, episodeid) async {
    AddcontenttoHistoryModel addcontenttoHistoryModel;
    String apiname = "add_content_to_history";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': contentid,
          'stop_time': stoptime,
          'episode_id': episodeid,
        }));
    addcontenttoHistoryModel = AddcontenttoHistoryModel.fromJson(response.data);
    return addcontenttoHistoryModel;
  }

  Future<RemoveContentHistoryModel> removeContentToHistory(
      contenttype, contentid, episodeid) async {
    RemoveContentHistoryModel removeContentHistoryModel;
    String apiname = "remove_content_to_history";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': contentid,
          'episode_id': episodeid,
        }));
    removeContentHistoryModel =
        RemoveContentHistoryModel.fromJson(response.data);
    return removeContentHistoryModel;
  }

  Future<GetHistoryModel> historyList(contentType, pageNo) async {
    //log("pageNo========>$pageNo");
    GetHistoryModel getHistoryModel;
    String apiname = "get_content_to_history";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contentType,
          'page_no': pageNo,
        }));
    print(response.realUri);
    print({
      'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      'content_type': contentType,
      'page_no': pageNo,
    });
    print(response.data);
    getHistoryModel = GetHistoryModel.fromJson(response.data);
    return getHistoryModel;
  }

  Future<AddremoveblockchannelModel> addremoveBlockChannel(
      blockUserId, blockChannelId) async {
    AddremoveblockchannelModel addremoveblockchannelModel;
    String apiname = "add_remove_block_channel";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'block_user_id': blockUserId,
          'block_channel_id': blockChannelId,
        }));
    addremoveblockchannelModel =
        AddremoveblockchannelModel.fromJson(response.data);
    return addremoveblockchannelModel;
  }

  Future<EpidoseByPodcastModel> episodeByPodcast(podcastId, pageNo) async {
    EpidoseByPodcastModel epidoseByPodcastModel;
    String apiname = "get_episode_by_podcasts";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'podcasts_id': podcastId,
          'page_no': pageNo,
        }));
    epidoseByPodcastModel = EpidoseByPodcastModel.fromJson(response.data);
    return epidoseByPodcastModel;
  }

  Future<EpidoseByRadioModel> episodeByRadio(radioId, pageNo) async {
    EpidoseByRadioModel epidoseByRadioModel;
    String apiname = "get_radio_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'radio_id': radioId,
          'page_no': pageNo,
        }));
    epidoseByRadioModel = EpidoseByRadioModel.fromJson(response.data);
    return epidoseByRadioModel;
  }

  Future<SearchModel> search(name, type) async {
    SearchModel searchModel;
    String apiname = "search_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'name': name,
          'type': type,
        }));
    searchModel = SearchModel.fromJson(response.data);
    return searchModel;
  }

  Future<GetEpisodeList> getEpisodeList() async {
    GetEpisodeList episodeModel;
    String apiname = "get_episode_name";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'channel_id':
              Constant.channelID == null ? "0" : (Constant.channelID ?? ""),
        }));
    episodeModel = GetEpisodeList.fromJson(response.data);
    return episodeModel;
  }

  Future<SuccessModel> addTransaction({
    int? packageId,
    int? price,
    String? description,
    String? paymentType,
    String? transactionId,
    String? userId,
    List<int>? channelId,
    List<int>? categoryId,
    int? autoRenewal,
  }) async {
    SuccessModel successModel;
    String apiname = "add_transaction";
    bool isOnlinePayment = paymentType != null && paymentType != 'coin';
    Map<String, dynamic> data = {
      'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      'package_id': packageId,
      'price': price,
      'description': description,
      'payment_type': paymentType,
      'is_online': isOnlinePayment ? 1 : 0,
      'payment_method': isOnlinePayment ? 'online' : 'coin',
      'use_coin': isOnlinePayment ? 0 : 1,
      'coin': 0,
      'skip_coin_check': isOnlinePayment ? 1 : 0,
      'no_coin_deduction': isOnlinePayment ? 1 : 0,
      'transaction_id': transactionId,
      // additional redundant fields for backend compatibility
      'payment_id': transactionId,
      'payment_reference': transactionId,
      'payment_gateway': paymentType,
      'category_id': categoryId,
      'channel_id': channelId,
      'auto_renewal': autoRenewal
    };
    print(data);
    Response response = await dio.post('$baseurl$apiname', data: data);
    print(response.realUri);
    print(response.data);
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<PaymentOptionModel> getPaymentOption() async {
    PaymentOptionModel paymentOptionModel;
    String apiname = "get_payment_option";
    Response response = await dio.post('$baseurl$apiname');
    paymentOptionModel = PaymentOptionModel.fromJson(response.data);
    return paymentOptionModel;
  }

  Future<EpisodebyplaylistModel> episodeByPlaylist(
      playlistId, contentType, pageNo) async {
    EpisodebyplaylistModel episodebyplaylistModel;
    String apiname = "get_playlist_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'playlist_id': playlistId,
          'content_type': contentType,
          'page_no': pageNo,
        }));
    episodebyplaylistModel = EpisodebyplaylistModel.fromJson(response.data);
    return episodebyplaylistModel;
  }

  Future<SectionDetailModel> sectionDetail(sectionId, pageNo) async {
    SectionDetailModel sectionDetailModel;
    String apiname = "get_music_section_detail";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'section_id': sectionId,
          'page_no': pageNo,
        }));
    print({
      'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      'section_id': sectionId,
      'page_no': pageNo,
    });
    print(response.realUri);
    print(response.data);
    sectionDetailModel = SectionDetailModel.fromJson(response.data);
    return sectionDetailModel;
  }

  Future<GetMusicByCategoryModel> getMusicbyCategory(categoryId, pageNo) async {
    GetMusicByCategoryModel getMusicByCategoryModel;
    String apiname = "get_music_by_category";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'category_id': categoryId,
          'page_no': pageNo,
        }));
    getMusicByCategoryModel = GetMusicByCategoryModel.fromJson(response.data);
    return getMusicByCategoryModel;
  }

  Future<GetMusicByLanguageModel> getMusicbyLanguage(languageId, pageNo) async {
    GetMusicByLanguageModel getMusicByLanguageModel;
    String apiname = "get_music_by_language";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'language_id': languageId,
          'page_no': pageNo,
        }));
    getMusicByLanguageModel = GetMusicByLanguageModel.fromJson(response.data);
    return getMusicByLanguageModel;
  }

  Future<GetNotificationModel> notification(pageNo) async {
    GetNotificationModel getNotificationModel;
    String apiname = "get_notification";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    getNotificationModel = GetNotificationModel.fromJson(response.data);
    print(response.realUri);
    print(response.data);
    return getNotificationModel;
  }

  Future<SuccessModel> readNotification(notificationId) async {
    SuccessModel successModel;
    String apiname = "read_notification";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'notification_id': notificationId,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> deleteContent(contentType, contentId, episodeId) async {
    SuccessModel successModel;
    String apiname = "delete_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contentType,
          'content_id': contentId,
          'episode_id': episodeId,
        }));
    print({
      'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      'content_type': contentType,
      'content_id': contentId,
      'episode_id': episodeId,
    });
    print(response.realUri);
    print(response.data);
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> activeUserPanel(password, userpanelStatus) async {
    // log("Password====>$password");
    //log("userpanalType====>$userpanelStatus");
    SuccessModel updateprofileModel;
    String apiname = "update_profile";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'password': password,
          'user_penal_status': userpanelStatus,
        }));
    updateprofileModel = SuccessModel.fromJson(response.data);
    return updateprofileModel;
  }

  Future<RentSectionModel> rentSection(pageNo) async {
    RentSectionModel rentSectionModel;
    String apiname = "get_rent_section";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    rentSectionModel = RentSectionModel.fromJson(response.data);
    return rentSectionModel;
  }

  Future<GetRentContentbyChannel> getRentContentByChannel(
      userId, channelId, pageNo) async {
    GetRentContentbyChannel getRentContentbyChannel;
    String apiname = "get_rent_content_by_channel";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'channel_id': channelId,
          'page_no': pageNo,
        }));
    getRentContentbyChannel = GetRentContentbyChannel.fromJson(response.data);
    return getRentContentbyChannel;
  }

  Future<RentSectionDetailModel> rentSectionDetail(sectionId, pageNo) async {
    RentSectionDetailModel rentSectionModel;
    String apiname = "get_rent_section_detail";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'section_id': sectionId,
          'page_no': pageNo,
        }));
    rentSectionModel = RentSectionDetailModel.fromJson(response.data);
    return rentSectionModel;
  }

  Future<SuccessModel> rentTransection(
      contentId, price, discription, transectionId) async {
    SuccessModel successModel;
    String apiname = "add_rent_transaction";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_id': contentId,
          'price': price,
          'description': discription,
          'transaction_id': transectionId,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<GetUserRentContentModel> rentContenetByUser(userId, pageNo) async {
    GetUserRentContentModel getUserRentContentModel;
    String apiname = "get_user_rent_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': userId == null || userId == "" ? "0" : userId,
          'page_no': pageNo,
        }));
    getUserRentContentModel = GetUserRentContentModel.fromJson(response.data);
    return getUserRentContentModel;
  }

  Future<GetContentByPlaylistModel> contentByPlaylist(
      contentType, pageNo) async {
    GetContentByPlaylistModel getContentByPlaylistModel;
    String apiname = "get_content_to_playlist";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contentType,
          'page_no': pageNo,
        }));
    getContentByPlaylistModel =
        GetContentByPlaylistModel.fromJson(response.data);
    return getContentByPlaylistModel;
  }

  Future<SuccessModel> addMultipleContentToPlaylist(
      playlistId, contentType, contentIds) async {
    SuccessModel successModel;
    String apiname = "add_multipal_content_to_playlist";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'playlist_id': playlistId,
          'content_type': contentType,
          'content_id': contentIds,
          'channel_id': Constant.channelID,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<GetPlaylistContentModel> getPlaylistContent(
      playlistId, contentType, pageNo) async {
    GetPlaylistContentModel getPlaylistContentModel;
    String apiname = "get_playlist_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'playlist_id': playlistId,
          'content_type': contentType,
          'page_no': pageNo,
        }));
    getPlaylistContentModel = GetPlaylistContentModel.fromJson(response.data);
    return getPlaylistContentModel;
  }

  Future<GetpagesModel> getPages() async {
    GetpagesModel getpagesModel;
    String apiname = "get_pages";
    Response response = await dio.post('$baseurl$apiname');
    getpagesModel = GetpagesModel.fromJson(response.data);
    return getpagesModel;
  }

  Future<SocialLinkModel> getSocialLink() async {
    SocialLinkModel socialLinkModel;
    String apiname = "get_social_links";
    Response response = await dio.post('$baseurl$apiname');
    socialLinkModel = SocialLinkModel.fromJson(response.data);
    return socialLinkModel;
  }

  Future<SuccessModel> updateDataForPayment(
      fullName, email, mobileNumber, countryCode, countryName) async {
    printLog("updateDataForPayment userID :====> ${Constant.userID}");
    printLog("updateDataForPayment fullName :==> $fullName");
    printLog("updateDataForPayment email :=====> $email");
    printLog("updateProfile mobileNumber :=====> $mobileNumber");
    SuccessModel responseModel;
    String apiName = "update_profile";
    Response response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'full_name': fullName,
        'email': email,
        'mobile_number': mobileNumber,
        'country_code': countryCode,
        'country_name': countryName,
      }),
    );

    responseModel = SuccessModel.fromJson(response.data);
    return responseModel;
  }

  Future<SuccessModel> uploadVideo(
      title, video, portraitImage, isLike, isComment, type) async {
    printLog("Title:=========> $title");
    printLog("Image path to upload: ${portraitImage?.path}");
    printLog("Video path to upload: ${video?.path}");
    printLog("Image:=======> ${MultipartFile.fromFileSync(
      video?.path ?? "",
      filename: video?.path.split('/').last ?? "",
    )}");
    SuccessModel successModel;
    String uploadVideo = "upload_reels";
    Response response = await dio.post(
      '$baseurl$uploadVideo',
      data: FormData.fromMap({
        'channel_id': Constant.channelID,
        'title': title,
        "video": (video?.path ?? "") != ""
            ? (MultipartFile.fromFileSync(
                video?.path ?? "",
                filename: video?.path.split('/').last ?? "",
              ))
            : "",
        "portrait_img": (portraitImage?.path ?? "") != ""
            ? (MultipartFile.fromFileSync(
                portraitImage?.path ?? "",
                filename: portraitImage?.path.split('/').last ?? "",
              ))
            : "",
        "is_like": isLike,
        "is_comment": isComment,
        "upload_type": type
      }),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> logout() async {
    SuccessModel successModel;
    String apiname = "logout";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({'user_id': Constant.userID}));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> deleteAccount(String? id) async {
    SuccessModel successModel;
    String apiname = "delete-user";
    Response response = await dio.post('$baseurl$apiname/$id');
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<UsageHistoryModel> usageHistory(pageNo) async {
    UsageHistoryModel usageHistoryModel;
    String apiname = "get_coin_history";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    print(response.realUri);
    print(response.data);
    usageHistoryModel = UsageHistoryModel.fromJson(response.data);
    return usageHistoryModel;
  }

  Future<UsageHistoryModel> getUsageHistory(pageNo) async {
    UsageHistoryModel usageHistoryModel;
    String apiname = "get_ads_coin_history";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    usageHistoryModel = UsageHistoryModel.fromJson(response.data);
    return usageHistoryModel;
  }

  Future<AdspackageTransectionModel> adsPackageTransection(pageNo) async {
    AdspackageTransectionModel adspackageTransectionModel;
    String apiname = "get_ads_transaction_list";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    adspackageTransectionModel =
        AdspackageTransectionModel.fromJson(response.data);
    return adspackageTransectionModel;
  }

  Future<WithdrawalrequestModel> withdrawalRequestList(pageNo) async {
    WithdrawalrequestModel withdrawalrequestModel;
    String apiname = "get_withdrawal_request_list";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    print(pageNo);
    print(Constant.userID == null ? "0" : (Constant.userID ?? ""));
    print(response.realUri);
    print(response.statusMessage);
    print(response.data);
    withdrawalrequestModel = WithdrawalrequestModel.fromJson(response.data);
    return withdrawalrequestModel;
  }

  Future<AdsPackageModel> adsPackage() async {
    AdsPackageModel adsPackageModel;
    String apiname = "get_ads_package";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        }));
    adsPackageModel = AdsPackageModel.fromJson(response.data);
    return adsPackageModel;
  }

  Future<SuccessModel> adsTransection(
      packageId, price, coin, transectionId, description) async {
    SuccessModel successModel;
    String apiname = "add_ads_transaction";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'package_id': packageId,
          'price': price,
          'coin': coin,
          'transaction_id': transectionId,
          'description': description,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> livePost(contentId, payable, amount) async {
    SuccessModel successModel;
    String apiname = "update_live_video";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': 'live',
          'content_id': contentId,
          'status': 1,
          'is_pay': payable,
          'pay_amount': amount,
        }));
    print({
      'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      'content_type': 'live',
      'content_id': contentId,
      'status': 1,
      'is_pay': payable,
      'pay_amount': amount,
    });
    print(response.realUri);
    print(response.statusMessage);
    print(response.data);
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<GetAdsModel> getAds(type) async {
    GetAdsModel getAdsModel;
    String apiname = "get_ads";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'type': type,
        }));
    print('response.data print(response.data);print(response.data);');
    print(type);
    print(response.data);
    print('response.data print(response.data);print(response.data);');
    getAdsModel = GetAdsModel.fromJson(response.data);
    return getAdsModel;
  }

  Future<SuccessModel> saveLive(status) async {
    SuccessModel successModel;
    String apiname = "toggle-live-recording";
    Response response = await dio.get(
      '$baseurl$apiname',
      queryParameters: {
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'status': status,
      },
    );
    print(response.realUri);
    print(response.data);
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> adsViewClickCount(
      adsType, adsId, diviceType, diviceToken, type, contentId) async {
    SuccessModel successModel;
    String apiname = "add_ads_view_click_count";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'ads_type': adsType,
          'ads_id': adsId,
          'device_type': diviceType,
          'device_token': diviceToken,
          'type': type,
          'content_id': contentId,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<RelatedMusicModel> getRelatedMusic(contentId, pageNo) async {
    RelatedMusicModel relatedMusicModel;
    String apiname = "get_releted_music";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_id': contentId,
          'page_no': pageNo,
        }));
    relatedMusicModel = RelatedMusicModel.fromJson(response.data);
    return relatedMusicModel;
  }

  Future<SubscriberlistModel> getSubcriberList(pageNo) async {
    SubscriberlistModel subscriberlistModel;
    String apiname = "get_subscribe_list";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    subscriberlistModel = SubscriberlistModel.fromJson(response.data);
    return subscriberlistModel;
  }

  /* ************************* Live Streaming & Gift APIs START ************************* */
  Future<LiveUserListModel> listOfLiveUsers(pageNo) async {
    LiveUserListModel liveStreamModel;
    String apiname = "list_of_live_users";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: {
        'user_id': Constant.userID,
        'page_no': pageNo,
      },
    );
    print(Constant.userID);
    print(pageNo);
    liveStreamModel = LiveUserListModel.fromJson(response.data);

    return liveStreamModel;
  }

  Future<LiveUserListModel> listOfSubscribedLiveUsers(pageNo) async {
    LiveUserListModel liveStreamModel;
    String apiname = "list_of_Subscribed_live_users";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: {
        'user_id': Constant.userID,
        'page_no': pageNo,
      },
    );
    print(Constant.userID);
    print(pageNo);
    liveStreamModel = LiveUserListModel.fromJson(response.data);

    return liveStreamModel;
  }

  Future<FetchGiftModel> getGift(pageNo) async {
    FetchGiftModel fetchGiftModel;
    String apiname = "get_gift";
    Response response = await dio.post('$baseurl$apiname', data: {
      'user_id': Constant.userID,
      'page_no': pageNo,
    });
    fetchGiftModel = FetchGiftModel.fromJson(response.data);
    return fetchGiftModel;
  }

  /* ************************* Live Streaming & Gift APIs START ************************* */

  /* **************************** Feed Api ************************************** */

  Future<PostModel> getFeedPost(pageNo) async {
    PostModel postModel;
    String apiname = "get_post";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    postModel = PostModel.fromJson(response.data);
    return postModel;
  }

  Future<SuccessModel> deleteFeedPost(postId) async {
    SuccessModel uploadMarketPlace;
    String apiname = "delete_post";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'channel_id': Constant.channelID,
          'post_id': postId,
        }));
    uploadMarketPlace = SuccessModel.fromJson(response.data);
    return uploadMarketPlace;
  }

  Future<PostContentUploadModel> postContentUpload(
    contentType,
    File? content, {
    Uint8List? fileBytes,
    String? filename,
  }) async {
    PostContentUploadModel postContentUploadModel;
    String apiname = "post_content_upload";

    MultipartFile multipartFile;

    if (fileBytes != null && filename != null) {
      multipartFile = MultipartFile.fromBytes(fileBytes, filename: filename);
    } else if (content != null) {
      multipartFile = MultipartFile.fromFileSync(content.path,
          filename: content.path.split('/').last);
    } else {
      throw Exception("No valid file data provided");
    }

    FormData formData = FormData.fromMap({
      'content_type': contentType,
      'content': multipartFile,
    });

    Response response = await dio.post('$baseurl$apiname', data: formData);

    postContentUploadModel = PostContentUploadModel.fromJson(response.data);
    return postContentUploadModel;
  }

  Future<PostContentUploadModel> contentUpload(
    contentType,
    File? content, {
    Uint8List? fileBytes,
    String? filename,
  }) async {
    PostContentUploadModel postContentUploadModel;
    String apiname = "content_upload";

    try {
      MultipartFile multipartFile;

      if (fileBytes != null && filename != null) {
        multipartFile = MultipartFile.fromBytes(fileBytes, filename: filename);
        printLog("Uploading file from bytes: $filename");
      } else if (content != null) {
        multipartFile = MultipartFile.fromFileSync(content.path,
            filename: content.path.split('/').last);
        printLog("Uploading file from path: ${content.path}");
      } else {
        throw Exception("No valid file data provided");
      }

      FormData formData = FormData.fromMap({
        'content_type': contentType,
        'content': multipartFile,
      });

      printLog("Starting upload to: $baseurl$apiname");
      Response response = await dio.post('$baseurl$apiname', data: formData);

      printLog("Upload response status: ${response.statusCode}");
      printLog("Upload response URL: ${response.realUri}");
      printLog("Upload response data: ${response.data}");

      postContentUploadModel = PostContentUploadModel.fromJson(response.data);
      return postContentUploadModel;
    } catch (e) {
      printLog("❌ Content upload error: $e");
      if (e is DioException) {
        printLog("DioException type: ${e.type}");
        printLog("DioException message: ${e.message}");
        printLog("DioException response: ${e.response?.data}");
        printLog("DioException status code: ${e.response?.statusCode}");
      }
      rethrow;
    }
  }

  Future<SuccessModel> uploadFeedPost(
    title,
    isComment,
    description,
    dynamic postContent,
    type,
    coin,
    File? file, {
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    SuccessModel successModel;
    String apiname = "upload_post";

    MultipartFile? multipartFile;
    print('fileNamevvvvvvvvvvvvvvvvv');
    print(file);
    print(fileBytes);
    print(fileName);
    print('fileNamevvvvvvvvvvvvvvvvv');

    try {
      // WEB
      if (fileBytes != null && fileName != null) {
        multipartFile = MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        );
        print(fileBytes);
        print(fileName);
      }
      // MOBILE
      else if (file != null) {
        multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        );
        print(file);
        print(file.path);
        print(file.path.split('/').last);
      } else {
        successModel = SuccessModel(
          status: 400,
          message: "No file selected",
          success: "0",
        );
        return successModel;
      }

      FormData formData = FormData.fromMap({
        'channel_id': Constant.channelID,
        'title': title,
        'is_comment': isComment.toString(),
        'descripation': description,
        'post_content': jsonEncode(postContent),
        'type': type,
        'coin': coin,
        'attachment': multipartFile,
      });

      print("===== Sending Upload Request =====");

      Response response = await dio
          .post(
        "$baseurl$apiname",
        data: formData,
        options: Options(
          sendTimeout:
              const Duration(minutes: 5), // 5 minutes for large uploads
          receiveTimeout:
              const Duration(minutes: 5), // 5 minutes for large uploads
        ),
      )
          .timeout(
        const Duration(minutes: 6), // 6 minutes total timeout
        onTimeout: () {
          print("===== Upload Timeout =====");
          throw DioException(
            requestOptions: RequestOptions(path: "$baseurl$apiname"),
            error: "Upload timeout - request took too long (6 minutes)",
            type: DioExceptionType.unknown,
          );
        },
      );

      print("===== Upload Response Received =====");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      // Normalize server response to SuccessModel, handling various error shapes
      var data = response.data;
      int respStatus = 500;
      String? respMessage;
      String? respSuccess;

      try {
        if (data is Map<String, dynamic>) {
          respStatus = (data['status'] is int)
              ? data['status']
              : int.tryParse(data['status']?.toString() ?? '') ??
                  (response.statusCode ?? 500);

          if (data['message'] != null) {
            respMessage = data['message'].toString();
          } else if (data['errors'] != null) {
            var errs = data['errors'];
            if (errs is List) {
              respMessage = errs.map((e) => e.toString()).join(', ');
            } else if (errs is Map) {
              respMessage = errs.values.map((e) => e.toString()).join(', ');
            } else {
              respMessage = errs.toString();
            }
          }

          respSuccess = data['success']?.toString();
        } else {
          // Fallback for non-map responses
          respStatus = response.statusCode ?? 500;
          respMessage = data?.toString();
        }
      } catch (e) {
        respStatus = response.statusCode ?? 500;
        respMessage = data?.toString() ?? 'Unexpected response format';
      }

      successModel = SuccessModel(
        status: respStatus,
        message: respMessage,
        success: respSuccess ?? '0',
      );
      return successModel;
    } on DioException catch (e) {
      print("===== Dio Exception =====");
      print("DioException: ${e.message}");
      print("Error Type: ${e.type}");
      print("Response Status: ${e.response?.statusCode}");

      // Create error response
      successModel = SuccessModel(
        status: e.response?.statusCode ?? 500,
        message: e.message ?? "Upload failed - please check your connection",
        success: "0",
      );
      return successModel;
    } catch (e) {
      print("===== General Exception =====");
      print("Exception: $e");

      successModel = SuccessModel(
        status: 500,
        message: "Error: $e",
        success: "0",
      );
      return successModel;
    }
  }

  Future<AddRemoveLikeDislikeModel> likeUnlikePost(postId) async {
    AddRemoveLikeDislikeModel addRemoveLikeDislikeModel;
    String apiname = "like_unlike_post";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID,
          "post_id": postId,
        }));
    addRemoveLikeDislikeModel =
        AddRemoveLikeDislikeModel.fromJson(response.data);
    return addRemoveLikeDislikeModel;
  }

  Future<AddCommentModel> addPostComment(postId, comment, int commentId) async {
    AddCommentModel addCommentModel;
    String apiname = "add_post_comment";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID,
          "post_id": postId,
          "comment": comment,
          /* Replya Perticuler Comment Then Pass Comment ID */
          "comment_id": commentId,
        }));
    addCommentModel = AddCommentModel.fromJson(response.data);
    return addCommentModel;
  }

  Future<GetPostCommentModel> getPostComment(postId, pageNo) async {
    GetPostCommentModel getPostCommentModel;
    String apiname = "get_post_comment";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          "post_id": postId,
          'page_no': pageNo,
        }));
    getPostCommentModel = GetPostCommentModel.fromJson(response.data);
    return getPostCommentModel;
  }

  Future<GetPostCommentModel> getPostReplayComment(commentId, pageNo) async {
    GetPostCommentModel getPostReplayCommentModel;
    String apiname = "get_post_reply_comment";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          "comment_id": commentId,
          'page_no': pageNo,
        }));
    getPostReplayCommentModel = GetPostCommentModel.fromJson(response.data);
    return getPostReplayCommentModel;
  }

  Future<SuccessModel> postDeleteComment(commentId) async {
    SuccessModel successModel;
    String apiname = "delete_post_comment";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          "comment_id": commentId,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<AddContentReportModel> addPostReport(postId, reason) async {
    AddContentReportModel addContentReportModel;
    String apiname = "add_post_report";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'report_user_id': Constant.userID,
          'post_id': postId,
          'message': reason,
        }));
    addContentReportModel = AddContentReportModel.fromJson(response.data);
    return addContentReportModel;
  }

  Future<GetChannelFeedModel> getChennalFeed(userId, channelId, pageNo) async {
    GetChannelFeedModel getChannelFeedModel;
    String apiname = "get_channel_post";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': userId,
          'channel_id': channelId,
          'page_no': pageNo,
        }));
    getChannelFeedModel = GetChannelFeedModel.fromJson(response.data);
    return getChannelFeedModel;
  }

  Future<SuccessModel> deletePost(postId, channelId) async {
    SuccessModel successModel;
    String apiname = "delete_post";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'post_id': postId,
          'channel_id': channelId,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<String?> convertM3U8ToMP4(
    String m3u8Url,
    Function(double)? onProgress,
    BuildContext context,
  ) async {
    final dio = Dio();
    final downloadProvider =
        Provider.of<VideoDownloadProvider>(context, listen: false);

    try {
      downloadProvider.setConverting(true);
      downloadProvider.setConvertProgress(0.0);

      String apiUrl = "${baseurl}convert-video";
      int retryCount = 0;
      const maxRetries = 10;
      const interval = Duration(seconds: 3);

      String? mp4Url;
      double percentComplete = 0.0;

      while (retryCount < maxRetries && percentComplete < 100) {
        final response = await dio.post(apiUrl, data: {"video_url": m3u8Url});

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          percentComplete = (data["percentComplete"] ?? 0).toDouble();
          mp4Url = data["video_url"];

          if (onProgress != null) onProgress(percentComplete / 100);
          downloadProvider.setConvertProgress(percentComplete / 100);

          if (percentComplete >= 100 && mp4Url != null) {
            downloadProvider.setConverting(false);
            return mp4Url;
          }
        }

        retryCount++;
        await Future.delayed(interval);
      }

      downloadProvider.setConverting(false);
      return null;
    } catch (e, st) {
      downloadProvider.setConverting(false);
      return null;
    }
  }

/* **************************** Feed Api ************************************** */
}

/* ========================== Download Videos ========================== */
Future<void> prepareVideoDownload(
  BuildContext context,
  contentdetails.Result? contentDetails,
) async {
  if (contentDetails == null) return;

  final downloadProvider =
      Provider.of<VideoDownloadProvider>(context, listen: false);
  final dio = Dio();
  final sectionDetails = contentDetails;
  final itemId = sectionDetails.id ?? 0;

  final downloadBox = Hive.box<DownloadItem>(
    '${Constant.hiveDownloadBox}_${Constant.userID}',
  );

  downloadProvider.setCurrentDownload(itemId);
  downloadProvider.setLoading(true);

  String localPath;
  try {
    localPath = await Utils.prepareSaveDir();
    printLog("📁 Local path: $localPath");
  } catch (e) {
    printLog("❌ prepareSaveDir Exception: $e");
    Utils().showSnackBar(context, "Failed to access storage directory.", false);
    return;
  }

  final now = DateTime.now();
  final timestamp = now.millisecondsSinceEpoch.abs().toString();
  final cleanTitle =
      (sectionDetails.title ?? "").replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  final fileName = '$cleanTitle${sectionDetails.id}${Constant.userID}';

  final videoFile = File(path.join(localPath, '$fileName.mp4'));
  final portraitImageFile = File(path.join(localPath, 'port_$timestamp.png'));
  final landscapeImageFile = File(path.join(localPath, 'land_$timestamp.png'));

  try {
    Utils().showSnackBar(context, "Starting download...", false);

    final downloadedItem = DownloadItem(
      id: sectionDetails.id,
      title: sectionDetails.title,
      channelName: sectionDetails.channelName,
      totalView: sectionDetails.totalView,
      createdAt: sectionDetails.createdAt,
      updatedAt: sectionDetails.updatedAt,
      description: sectionDetails.description,
      content: sectionDetails.content,
      savedDir: localPath,
      savedFile: videoFile.path,
      contentUploadType: sectionDetails.contentUploadType.toString(),
      isBuy: sectionDetails.isBuy,
      isRent: sectionDetails.isRent,
      isDownload: 1,
      stopTime: sectionDetails.stopTime ?? 0,
      portraitImg: portraitImageFile.path,
      landscapeImg: landscapeImageFile.path,
      artistId: sectionDetails.artistId,
      artistName: sectionDetails.artistName,
      categoryId: sectionDetails.categoryId,
      categoryName: sectionDetails.categoryName,
      channelId: sectionDetails.channelId,
      channelImage: sectionDetails.channelImage,
      contentSize: sectionDetails.contentSize,
      contentType: sectionDetails.contentType,
      hashtagId: sectionDetails.hashtagId,
      isAdminAdded: sectionDetails.isAdminAdded,
      isComment: sectionDetails.isComment,
      isLike: sectionDetails.isLike,
      isSubscribe: sectionDetails.isSubscribe,
      isUserDownload: sectionDetails.isUserDownload,
      isUserLikeDislike: sectionDetails.isUserLikeDislike,
      languageId: sectionDetails.languageId,
      languageName: sectionDetails.languageName,
      playlistType: sectionDetails.playlistType,
      rentPrice: sectionDetails.rentPrice,
      status: sectionDetails.status,
      totalComment: sectionDetails.totalComment,
      totalDislike: sectionDetails.totalDislike,
      totalLike: sectionDetails.totalLike,
      totalSubscriber: sectionDetails.totalSubscriber,
      userId: sectionDetails.userId,
    );

    await downloadBox.add(downloadedItem);

    // Download thumbnails
    if (sectionDetails.portraitImg?.isNotEmpty ?? false) {
      await dio.download(sectionDetails.portraitImg!, portraitImageFile.path);
    }
    if (sectionDetails.landscapeImg?.isNotEmpty ?? false) {
      await dio.download(sectionDetails.landscapeImg!, landscapeImageFile.path);
    }

    // Download video
    await dio.download(
      sectionDetails.content ?? "",
      videoFile.path,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          int progress = ((received / total) * 100).clamp(0, 100).round();
          downloadProvider.setDownloadProgress(itemId, progress);
        }
      },
    );

    downloadProvider.setDownloadProgress(itemId, 100);
    downloadProvider.setCurrentDownload(null);
    downloadProvider.setLoading(false);
    Utils().showSnackBar(context, "Download complete!", false);
  } catch (e, st) {
    printLog("❌ Download exception: $e\n$st");
    Utils().showSnackBar(context, "Download failed.", false);
    downloadProvider.setDownloadProgress(itemId, 0);
    downloadProvider.setCurrentDownload(null);
    downloadProvider.setLoading(false);

    for (int i = 0; i < downloadBox.length; i++) {
      final item = downloadBox.getAt(i);
      if (item?.id == itemId) {
        await downloadBox.deleteAt(i);
        break;
      }
    }

    if (videoFile.existsSync()) await videoFile.delete();
  }
}
