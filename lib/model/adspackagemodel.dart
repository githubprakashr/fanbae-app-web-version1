// To parse this JSON data, do
//
//     final adsPackageModel = adsPackageModelFromJson(jsonString);

import 'dart:convert';

AdsPackageModel adsPackageModelFromJson(String str) =>
    AdsPackageModel.fromJson(json.decode(str));

String adsPackageModelToJson(AdsPackageModel data) =>
    json.encode(data.toJson());

class AdsPackageModel {
  int? status;
  String? message;
  List<Result>? result;

  AdsPackageModel({
    this.status,
    this.message,
    this.result,
  });

  factory AdsPackageModel.fromJson(Map<String, dynamic> json) =>
      AdsPackageModel(
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
  int? id;
  String? name;
  String? image;
  int? price;
  int? coin;
  String? androidProductPackage;
  String? iosProductPackage;
  int? status;
  int? expireDate;
  String? dataType;
  String? createdAt;
  String? updatedAt;

  Result({
    this.id,
    this.name,
    this.image,
    this.price,
    this.coin,
    this.androidProductPackage,
    this.iosProductPackage,
    this.expireDate,
    this.dataType,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        price: json["price"],
        coin: json["coin"],
        androidProductPackage: json["android_product_package"],
        iosProductPackage: json["ios_product_package"],
        status: json["status"],
        dataType: json["date_type"],
        expireDate: json["expire_date"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "price": price,
        "coin": coin,
        "android_product_package": androidProductPackage,
        "ios_product_package": iosProductPackage,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
