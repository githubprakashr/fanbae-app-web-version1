import 'dart:convert';

PostModel postModelFromJson(String str) => PostModel.fromJson(json.decode(str));

String postModelToJson(PostModel data) => json.encode(data.toJson());

class PostModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  PostModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(
                json["result"]?.map((x) => Result.fromJson(x)) ?? []),
        totalRows: json["total_rows"],
        totalPage: json["total_page"],
        currentPage: json["current_page"],
        morePage: json["more_page"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
        "total_rows": totalRows,
        "total_page": totalPage,
        "current_page": currentPage,
        "more_page": morePage,
      };
}

class Result {
  int? id;
  String? channelId;
  int? categoryId;
  String? hashtagId;
  String? title;
  String? descripation;
  int? isComment;
  int? view;
  int? status;
  String? createdAt;
  String? updatedAt;
  List<PostContent>? postContent;
  List<Hasteg>? hastegs;
  String? firebaseId;
  String? channelName;
  String? fullName;
  String? email;
  String? countryCode;
  String? mobileNumber;
  String? countryName;
  String? profileImg;
  int? userId;
  int? totalComment;
  int? totalLike;
  int? isLike;
  int? isSubscriber;
  int? isBuy;
  bool? payContent;
  int? payCoin;

  Result({
    this.id,
    this.channelId,
    this.categoryId,
    this.hashtagId,
    this.title,
    this.descripation,
    this.isComment,
    this.view,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.postContent,
    this.hastegs,
    this.firebaseId,
    this.channelName,
    this.fullName,
    this.email,
    this.countryCode,
    this.mobileNumber,
    this.countryName,
    this.profileImg,
    this.userId,
    this.totalComment,
    this.totalLike,
    this.isLike,
    this.isSubscriber,
    this.isBuy,
    this.payContent,
    this.payCoin
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        channelId: json["channel_id"],
        categoryId: json["category_id"],
        hashtagId: json["hashtag_id"],
        title: json["title"],
        descripation: json["descripation"],
        isComment: json["is_comment"],
        view: json["view"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        postContent: json["post_content"] == null
            ? []
            : List<PostContent>.from(
                json["post_content"]?.map((x) => PostContent.fromJson(x)) ??
                    []),
        hastegs: json["hastegs"] == null
            ? []
            : List<Hasteg>.from(
                json["hastegs"]?.map((x) => Hasteg.fromJson(x)) ?? []),
        firebaseId: json["firebase_id"],
        channelName: json["channel_name"],
        fullName: json["full_name"],
        email: json["email"],
        countryCode: json["country_code"],
        mobileNumber: json["mobile_number"],
        countryName: json["country_name"],
        profileImg: json["profile_img"],
        userId: json["user_id"],
        totalComment: json["total_comment"],
        totalLike: json["total_like"],
        isLike: json["is_like"],
        isSubscriber: json["is_subscriber"],
        isBuy: json["is_buy"],
        payContent: json["pay_content"],
        payCoin: json["pay_coin"]
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "channel_id": channelId,
        "category_id": categoryId,
        "hashtag_id": hashtagId,
        "title": title,
        "descripation": descripation,
        "is_comment": isComment,
        "view": view,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "post_content": postContent == null
            ? []
            : List<dynamic>.from(postContent?.map((x) => x.toJson()) ?? []),
        "hastegs": hastegs == null
            ? []
            : List<dynamic>.from(hastegs?.map((x) => x.toJson()) ?? []),
        "firebase_id": firebaseId,
        "channel_name": channelName,
        "full_name": fullName,
        "email": email,
        "country_code": countryCode,
        "mobile_number": mobileNumber,
        "country_name": countryName,
        "profile_img": profileImg,
        "user_id": userId,
        "total_comment": totalComment,
        "total_like": totalLike,
        "is_like": isLike,
        "is_subscriber": isSubscriber,
        "is_buy": isBuy,
        "pay_content": payContent,
        "pay_coin": payCoin
      };
}

class Hasteg {
  int? id;
  String? name;
  int? totalUsed;
  int? status;
  String? createdAt;
  String? updatedAt;

  Hasteg({
    this.id,
    this.name,
    this.totalUsed,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Hasteg.fromJson(Map<String, dynamic> json) => Hasteg(
        id: json["id"],
        name: json["name"],
        totalUsed: json["total_used"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "total_used": totalUsed,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
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

  factory PostContent.fromJson(Map<String, dynamic> json) => PostContent(
        id: json["id"],
        postId: json["post_id"],
        contentType: json["content_type"],
        contentUrl: json["content_url"],
        thumbnailImage: json["thumbnail_image"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "post_id": postId,
        "content_type": contentType,
        "content_url": contentUrl,
        "thumbnail_image": thumbnailImage,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
