import 'dart:convert';

GetAdsModel getAdsModelFromJson(String str) =>
    GetAdsModel.fromJson(json.decode(str));

String getAdsModelToJson(GetAdsModel data) => json.encode(data.toJson());

class GetAdsModel {
  int? status;
  String? message;
  Result? result;

  GetAdsModel({
    this.status,
    this.message,
    this.result,
  });

  factory GetAdsModel.fromJson(Map<String, dynamic> json) => GetAdsModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? null
            : Result?.fromJson(json["result"] ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result?.toJson() ?? [],
      };
}

class Result {
  int? id;
  int? type;
  int? userId;
  String? title;
  String? image;
  String? video;
  String? redirectUri;
  int? budget;
  int? status;
  int? isHide;
  String? createdAt;
  String? updatedAt;

  Result({
    this.id,
    this.type,
    this.userId,
    this.title,
    this.image,
    this.video,
    this.redirectUri,
    this.budget,
    this.status,
    this.isHide,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        type: json["type"],
        userId: json["user_id"],
        title: json["title"],
        image: json["image"],
        video: json["video"],
        redirectUri: json["redirect_uri"],
        budget: json["budget"],
        status: json["status"],
        isHide: json["is_hide"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "user_id": userId,
        "title": title,
        "image": image,
        "video": video,
        "redirect_uri": redirectUri,
        "budget": budget,
        "status": status,
        "is_hide": isHide,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
