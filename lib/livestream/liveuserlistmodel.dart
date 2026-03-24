import 'dart:convert';

LiveUserListModel liveUserListModelFromJson(String str) =>
    LiveUserListModel.fromJson(json.decode(str));

String liveUserListModelToJson(LiveUserListModel data) =>
    json.encode(data.toJson());

class LiveUserListModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  LiveUserListModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory LiveUserListModel.fromJson(Map<String, dynamic> json) =>
      LiveUserListModel(
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
  String? roomId;
  int? userId;
  int? totalView;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? channelId;
  String? channelName;
  String? fullName;
  String? email;
  String? countryCode;
  String? mobileNumber;
  String? countryName;
  String? image;
  int? isFake;
  int? isBuy;
  int? liveAmount;
  int? isViewable;

  Result({
    this.id,
    this.roomId,
    this.userId,
    this.totalView,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.channelId,
    this.channelName,
    this.fullName,
    this.email,
    this.countryCode,
    this.mobileNumber,
    this.countryName,
    this.image,
    this.isFake,
    this.isBuy,
    this.liveAmount,
    this.isViewable,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        roomId: json["room_id"],
        userId: json["user_id"],
        totalView: json["total_view"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        channelId: json["channel_id"],
        channelName: json["channel_name"],
        fullName: json["full_name"],
        email: json["email"],
        countryCode: json["country_code"],
        mobileNumber: json["mobile_number"],
        countryName: json["country_name"],
        image: json["image"],
        isFake: json["is_fake"],
        isBuy: json["is_buy"],
        liveAmount: json["live_amount"],
        isViewable: json["is_viewable"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "room_id": roomId,
        "user_id": userId,
        "total_view": totalView,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "channel_id": channelId,
        "channel_name": channelName,
        "full_name": fullName,
        "email": email,
        "country_code": countryCode,
        "mobile_number": mobileNumber,
        "country_name": countryName,
        "image": image,
        "is_fake": isFake,
        "is_buy": isBuy,
        "live_amount": liveAmount,
        "is_viewable": isViewable,
      };
}
