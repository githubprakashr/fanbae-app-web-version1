import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  int? status;
  String? message;
  List<Result>? result;

  LoginModel({
    this.status,
    this.message,
    this.result,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
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
  String? channelId;
  String? channelName;
  String? fullName;
  String? email;
  String? countryCode;
  String? mobileNumber;
  String? countryName;
  int? type;
  String? image;
  String? coverImg;
  String? description;
  int? deviceType;
  String? deviceToken;
  String? website;
  String? facebookUrl;
  String? instagramUrl;
  String? twitterUrl;
  int? walletBalance;
  int? walletEarning;
  String? bankName;
  String? bankCode;
  String? bankAddress;
  String? ifscNo;
  String? accountNo;
  String? idProof;
  String? address;
  String? city;
  String? state;
  String? country;
  int? pincode;
  int? userPenalStatus;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? isBuy;
  String? packageName;
  int? packagePrice;
  String? packageImage;
  int? adsFree;
  int? isDownload;
  int? veriflyArtist;
  int? veriflyAccount;
  int? isCreator;

  Result({
    this.id,
    this.channelId,
    this.channelName,
    this.fullName,
    this.email,
    this.countryCode,
    this.mobileNumber,
    this.countryName,
    this.type,
    this.image,
    this.coverImg,
    this.description,
    this.deviceType,
    this.deviceToken,
    this.website,
    this.facebookUrl,
    this.instagramUrl,
    this.twitterUrl,
    this.walletBalance,
    this.walletEarning,
    this.bankName,
    this.bankCode,
    this.bankAddress,
    this.ifscNo,
    this.accountNo,
    this.idProof,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.userPenalStatus,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isBuy,
    this.packageName,
    this.packagePrice,
    this.packageImage,
    this.adsFree,
    this.isDownload,
    this.veriflyArtist,
    this.veriflyAccount,
    this.isCreator
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        channelId: json["channel_id"],
        channelName: json["channel_name"],
        fullName: json["full_name"],
        email: json["email"],
        countryCode: json["country_code"],
        mobileNumber: json["mobile_number"],
        countryName: json["country_name"],
        type: json["type"],
        image: json["image"],
        coverImg: json["cover_img"],
        description: json["description"],
        deviceType: json["device_type"],
        deviceToken: json["device_token"],
        website: json["website"],
        facebookUrl: json["facebook_url"],
        instagramUrl: json["instagram_url"],
        twitterUrl: json["twitter_url"],
        walletBalance: json["wallet_balance"],
        walletEarning: json["wallet_earning"],
        bankName: json["bank_name"],
        bankCode: json["bank_code"],
        bankAddress: json["bank_address"],
        ifscNo: json["ifsc_no"],
        accountNo: json["account_no"],
        idProof: json["id_proof"],
        address: json["address"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        pincode: json["pincode"],
        userPenalStatus: json["user_penal_status"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isBuy: json["is_buy"],
        packageName: json["package_name"],
        packagePrice: json["package_price"],
        packageImage: json["package_image"],
        adsFree: json["ads_free"],
        isDownload: json["is_download"],
        veriflyArtist: json["verifly_artist"],
        veriflyAccount: json["verifly_account"],
        isCreator: json["is_creater"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "channel_id": channelId,
        "channel_name": channelName,
        "full_name": fullName,
        "email": email,
        "country_code": countryCode,
        "mobile_number": mobileNumber,
        "country_name": countryName,
        "type": type,
        "image": image,
        "cover_img": coverImg,
        "description": description,
        "device_type": deviceType,
        "device_token": deviceToken,
        "website": website,
        "facebook_url": facebookUrl,
        "instagram_url": instagramUrl,
        "twitter_url": twitterUrl,
        "wallet_balance": walletBalance,
        "wallet_earning": walletEarning,
        "bank_name": bankName,
        "bank_code": bankCode,
        "bank_address": bankAddress,
        "ifsc_no": ifscNo,
        "account_no": accountNo,
        "id_proof": idProof,
        "address": address,
        "city": city,
        "state": state,
        "country": country,
        "pincode": pincode,
        "user_penal_status": userPenalStatus,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_buy": isBuy,
        "package_name": packageName,
        "package_price": packagePrice,
        "package_image": packageImage,
        "ads_free": adsFree,
        "is_download": isDownload,
        "verifly_artist": veriflyArtist,
        "verifly_account": veriflyAccount,
        "is_creater": isCreator
      };
}
