import 'dart:convert';

FeedsListModel feedsListModelFromJson(String str) => FeedsListModel.fromJson(json.decode(str));

String feedsListModelToJson(FeedsListModel data) =>
    json.encode(data.toJson());


class FeedsListModel {
  int? status;
  String? message;
  List<Result>? result;

  FeedsListModel({this.status, this.message, this.result});

  factory FeedsListModel.fromJson(Map<String, dynamic> json) =>
      FeedsListModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(
            json["result"]?.map((x) => Result.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "result": result == null
        ? []
        : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
  };
}

class Result {
  String? feedType;
  String? episodeName;
  String? portraitImg;
  String? landscapeImg;
  String? title;
  int? userId;
  String? channelName;
  String? channelImage;
  String? categoryName;
  String? artistName;
  List<dynamic>? episodes;
  int? totalView;
  int? id;
  String? channelId;
  int? categoryId;
  String? hashtagId;
  String? descripation;
  int? isComment;
  int? view;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? type;
  int? contentDuration;
  int? coin;
  dynamic channelUser; // You can later define this properly
  bool? payContent;
  int? payCoin;
  List<dynamic>? postContent;
  List<dynamic>? hastegs; // Placeholder until you define what it actually contains
  String? firebaseId;
  String? fullName;
  String? email;
  String? countryCode;
  String? mobileNumber;
  String? countryName;
  String? profileImg;
  int? totalComment;
  int? totalLike;
  int? isLike;
  int? isSubscriber;
  int? purchasePackage;
  int? isBuy;
  int? contentType;
  int? languageId;
  int? artistId;
  String? description;
  String? contentUploadType;
  String? content;
  String? contentSize;
  String? videoType;
  String? attachment;
  int? isRent;
  int? rentPrice;
  int? isDownload;
  int? totalDislike;
  int? playlistType;
  int? isAdminAdded;
  String? languageName;
  int? isSubscribe;
  int? isUserLikeDislike;
  int? totalSubscriber;
  int? stopTime;

  Result({
    this.feedType,
    this.episodeName,
    this.portraitImg,
    this.landscapeImg,
    this.title,
    this.userId,
    this.channelName,
    this.channelImage,
    this.categoryName,
    this.artistName,
    this.episodes,
    this.totalView,
    this.id,
    this.channelId,
    this.categoryId,
    this.hashtagId,
    this.descripation,
    this.isComment,
    this.view,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.type,
    this.contentDuration,
    this.coin,
    this.channelUser,
    this.payContent,
    this.payCoin,
    this.postContent,
    this.hastegs,
    this.firebaseId,
    this.fullName,
    this.email,
    this.countryCode,
    this.mobileNumber,
    this.countryName,
    this.profileImg,
    this.totalComment,
    this.totalLike,
    this.isLike,
    this.isSubscriber,
    this.isBuy,
    this.contentType,
    this.languageId,
    this.artistId,
    this.description,
    this.contentUploadType,
    this.content,
    this.contentSize,
    this.purchasePackage,
    this.videoType,
    this.attachment,
    this.isRent,
    this.rentPrice,
    this.isDownload,
    this.totalDislike,
    this.playlistType,
    this.isAdminAdded,
    this.languageName,
    this.isSubscribe,
    this.isUserLikeDislike,
    this.totalSubscriber,
    this.stopTime,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    feedType : json['feed_type'],
    episodeName : json['episode_name'],
    portraitImg : json['portrait_img'],
    landscapeImg : json['landscape_img'],
    title : json['title'],
    userId : json['user_id'],
    channelName : json['channel_name'],
    channelImage : json['channel_image'],
    categoryName : json['category_name'],
    artistName : json['artist_name'],
      episodes : json["episodes"] == null ? []
          : List<dynamic>.from(json["episodes"]?.map((x) => x) ?? []),
    totalView : json['total_view'],
    id : json['id'],
    channelId : json['channel_id'],
    categoryId : json['category_id'],
    hashtagId : json['hashtag_id'],
    descripation : json['descripation'],
    isComment : json['is_comment'],
    view : json['view'],
    status : json['status'],
    createdAt : json['created_at'],
    updatedAt : json['updated_at'],
    type : json['type'],
    contentDuration : json['content_duration'],
    coin : json['coin'],
    channelUser : json['channel_user'],
    payContent : json['pay_content'],
    payCoin : json['pay_coin'],
    postContent : json["post_content"] == null ? []
    : List<dynamic>.from(json["post_content"]?.map((x) => x) ?? []),
    hastegs : json["hastegs"] == null ? []
    : List<dynamic>.from(json["hastegs"]?.map((x) => x) ?? []),
    firebaseId : json['firebase_id'],
    fullName : json['full_name'],
    email : json['email'],
    countryCode : json['country_code'],
    mobileNumber : json['mobile_number'],
    countryName : json['country_name'],
    profileImg : json['profile_img'],
    totalComment : json['total_comment'],
    totalLike : json['total_like'],
    isLike : json['is_like'],
    isSubscriber : json['is_subscriber'],
    isBuy : json['is_buy'],
    contentType : json['content_type'],
    languageId : json['language_id'],
    artistId : json['artist_id'],
    description : json['description'],
    contentUploadType : json['content_upload_type'],
    content : json['content'],
    contentSize : json['content_size'],
    videoType : json['video_type'],
    attachment : json['attachment'],
    isRent : json['is_rent'],
    rentPrice : json['rent_price'],
    isDownload : json['is_download'],
    totalDislike : json['total_dislike'],
    playlistType : json['playlist_type'],
    isAdminAdded : json['is_admin_added'],
    languageName : json['language_name'],
    isSubscribe : json['is_subscribe'],
    purchasePackage : json['purchase_package'],
    isUserLikeDislike : json['is_user_like_dislike'],
    totalSubscriber : json['total_subscriber'],
    stopTime : json['stop_time'],
    );

  Map<String, dynamic> toJson() {
    return {
      'feed_type': feedType,
      'episode_name': episodeName,
      'portrait_img': portraitImg,
      'landscape_img': landscapeImg,
      'title': title,
      'user_id': userId,
      'channel_name': channelName,
      'channel_image': channelImage,
      'category_name': categoryName,
      'artist_name': artistName,
      "episodes": episodes == null
          ? []
          : List<dynamic>.from(episodes?.map((x) => x) ?? []),
      'total_view': totalView,
      'id': id,
      'channel_id': channelId,
      'category_id': categoryId,
      'hashtag_id': hashtagId,
      'descripation': descripation,
      'is_comment': isComment,
      'view': view,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'type': type,
      'content_duration': contentDuration,
      'coin': coin,
      'channel_user': channelUser,
      'pay_content': payContent,
      'pay_coin': payCoin,
      "post_content": postContent == null
          ? []
          : List<dynamic>.from(postContent?.map((x) => x) ?? []),
      'hastegs': hastegs,
      'firebase_id': firebaseId,
      'full_name': fullName,
      'email': email,
      'country_code': countryCode,
      'mobile_number': mobileNumber,
      'country_name': countryName,
      'profile_img': profileImg,
      'total_comment': totalComment,
      'total_like': totalLike,
      'is_like': isLike,
      'is_subscriber': isSubscriber,
      'is_buy': isBuy,
      'content_type': contentType,
      'language_id': languageId,
      'artist_id': artistId,
      'description': description,
      'content_upload_type': contentUploadType,
      'content': content,
      'content_size': contentSize,
      'video_type': videoType,
      'attachment': attachment,
      'is_rent': isRent,
      'rent_price': rentPrice,
      'is_download': isDownload,
      'total_dislike': totalDislike,
      'playlist_type': playlistType,
      'is_admin_added': isAdminAdded,
      'language_name': languageName,
      'is_subscribe': isSubscribe,
      'is_user_like_dislike': isUserLikeDislike,
      'total_subscriber': totalSubscriber,
      'purchase_package': purchasePackage,
      'stop_time': stopTime,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'feed_type': feedType,
      'episode_name': episodeName,
      'portrait_img': portraitImg,
      'landscape_img': landscapeImg,
      'title': title,
      'user_id': userId,
      'channel_name': channelName,
      'channel_image': channelImage,
      'category_name': categoryName,
      'artist_name': artistName,
      "episodes": episodes == null
          ? []
          : List<dynamic>.from(episodes?.map((x) => x) ?? []),
      'total_view': totalView,
      'id': id,
      'channel_id': channelId,
      'category_id': categoryId,
      'hashtag_id': hashtagId,
      'descripation': descripation,
      'is_comment': isComment,
      'view': view,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'type': type,
      'content_duration': contentDuration,
      'coin': coin,
      'channel_user': channelUser,
      'pay_content': payContent,
      'pay_coin': payCoin,
      "post_content": postContent == null
          ? []
          : List<dynamic>.from(postContent?.map((x) => x) ?? []),
      'hastegs': hastegs,
      'firebase_id': firebaseId,
      'full_name': fullName,
      'email': email,
      'country_code': countryCode,
      'mobile_number': mobileNumber,
      'country_name': countryName,
      'profile_img': profileImg,
      'total_comment': totalComment,
      'total_like': totalLike,
      'is_like': isLike,
      'is_subscriber': isSubscriber,
      'is_buy': isBuy,
      'content_type': contentType,
      'language_id': languageId,
      'artist_id': artistId,
      'description': description,
      'content_upload_type': contentUploadType,
      'content': content,
      'content_size': contentSize,
      'is_rent': isRent,
      'rent_price': rentPrice,
      'is_download': isDownload,
      'total_dislike': totalDislike,
      'playlist_type': playlistType,
      'is_admin_added': isAdminAdded,
      'language_name': languageName,
      'is_subscribe': isSubscribe,
      'is_user_like_dislike': isUserLikeDislike,
      'total_subscriber': totalSubscriber,
      'stop_time': stopTime,
      'attachment': attachment
    };
  }
}

class Episodes {
  int? id;
  String? title;
  int? contentType;
  String? portraitImg;
  String? landscapeImg;
  int? totalView;

  Episodes({
    this.id,
    this.title,
    this.contentType,
    this.portraitImg,
    this.landscapeImg,
    this.totalView,
  });

  Episodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    contentType = json['content_type'];
    portraitImg = json['portrait_img'];
    landscapeImg = json['landscape_img'];
    totalView = json['total_view'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content_type': contentType,
      'portrait_img': portraitImg,
      'landscape_img': landscapeImg,
      'total_view': totalView,
    };
  }
}

class PostContent {
  int? id;
  int? postId;
  int? contentType;
  String? contentUrl;
  String? thumbnailImage;
  int? status;
  String? createdAt;
  String? updatedAt;

  PostContent({
    this.id,
    this.postId,
    this.contentType,
    this.contentUrl,
    this.thumbnailImage,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  PostContent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['post_id'];
    contentType = json['content_type'];
    contentUrl = json['content_url'];
    thumbnailImage = json['thumbnail_image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'content_type': contentType,
      'content_url': contentUrl,
      'thumbnail_image': thumbnailImage,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
