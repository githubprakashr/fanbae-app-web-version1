import 'dart:convert';

GetNotificationModel getNotificationModelFromJson(String str) =>
    GetNotificationModel.fromJson(json.decode(str));

String getNotificationModelToJson(GetNotificationModel data) =>
    json.encode(data.toJson());

class GetNotificationModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  GetNotificationModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory GetNotificationModel.fromJson(Map<String, dynamic> json) {
    // ✅ Handle type conversions for API inconsistencies
    bool? parseMorePage(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return GetNotificationModel(
      status: parseInt(json["status"]),
      message: json["message"],
      result: List<Result>.from(
          json["result"]?.map((x) => Result.fromJson(x)) ?? []),
      totalRows: parseInt(json["total_rows"]),
      totalPage: parseInt(json["total_page"]),
      currentPage: parseInt(json["current_page"]),
      morePage: parseMorePage(json["more_page"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
        "total_rows": totalRows,
        "total_page": totalPage,
        "current_page": currentPage,
        "more_page": morePage,
      };
}

class Result {
  int? id;
  int? type;
  String? title;
  String? message;
  String? image;
  int? userId;
  int? fromUserId;
  int? contentId;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? userName;
  String? userImage;
  String? contentName;
  String? contentImage;

  Result({
    this.id,
    this.type,
    this.title,
    this.message,
    this.image,
    this.userId,
    this.fromUserId,
    this.contentId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.userImage,
    this.contentName,
    this.contentImage,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    // ✅ Safe type conversion for API inconsistencies
    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    String? parseString(dynamic value) {
      if (value is String) return value;
      if (value == null) return null;
      return value.toString();
    }

    return Result(
      id: parseInt(json["id"]),
      type: parseInt(json["type"]),
      title: parseString(json["title"]),
      message: parseString(json["message"]),
      image: parseString(json["image"]),
      userId: parseInt(json["user_id"]),
      fromUserId: parseInt(json["from_user_id"]),
      contentId: parseInt(json["content_id"]),
      status: parseInt(json["status"]),
      createdAt: parseString(json["created_at"]),
      updatedAt: parseString(json["updated_at"]),
      userName: parseString(json["user_name"]),
      userImage: parseString(json["user_image"]),
      contentName: parseString(json["content_name"]),
      contentImage: parseString(json["content_image"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "title": title,
        "message": message,
        "image": image,
        "user_id": userId,
        "from_user_id": fromUserId,
        "content_id": contentId,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user_name": userName,
        "user_image": userImage,
        "content_name": contentName,
        "content_image": contentImage,
      };
}
