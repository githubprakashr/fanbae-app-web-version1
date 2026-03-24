import 'dart:convert';

AdspackageTransectionModel adspackageTransectionModelFromJson(String str) =>
    AdspackageTransectionModel.fromJson(json.decode(str));

String adspackageTransectionModelToJson(AdspackageTransectionModel data) =>
    json.encode(data.toJson());

class AdspackageTransectionModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  AdspackageTransectionModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory AdspackageTransectionModel.fromJson(Map<String, dynamic> json) =>
      AdspackageTransectionModel(
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
  int? userId;
  int? packageId;
  String? transactionId;
  int? price;
  int? coin;
  String? description;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? channelName;
  String? fullName;
  String? email;
  String? mobileNumber;
  String? image;

  Result({
    this.id,
    this.userId,
    this.packageId,
    this.transactionId,
    this.price,
    this.coin,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.channelName,
    this.fullName,
    this.email,
    this.mobileNumber,
    this.image,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        userId: json["user_id"],
        packageId: json["package_id"],
        transactionId: json["transaction_id"],
        price: json["price"],
        coin: json["coin"],
        description: json["description"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        channelName: json["channel_name"],
        fullName: json["full_name"],
        email: json["email"],
        mobileNumber: json["mobile_number"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "package_id": packageId,
        "transaction_id": transactionId,
        "price": price,
        "coin": coin,
        "description": description,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "channel_name": channelName,
        "full_name": fullName,
        "email": email,
        "mobile_number": mobileNumber,
        "image": image,
      };
}
