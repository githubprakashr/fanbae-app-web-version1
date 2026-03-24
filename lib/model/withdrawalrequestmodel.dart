import 'dart:convert';

WithdrawalrequestModel withdrawalrequestModelFromJson(String str) =>
    WithdrawalrequestModel.fromJson(json.decode(str));

String withdrawalrequestModelToJson(WithdrawalrequestModel data) =>
    json.encode(data.toJson());

class WithdrawalrequestModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  WithdrawalrequestModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory WithdrawalrequestModel.fromJson(Map<String, dynamic> json) =>
      WithdrawalrequestModel(
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
  int? amount;
  int? coin;
  String? paymentType;
  String? paymentDetail;
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
    this.amount,
    this.coin,
    this.paymentType,
    this.paymentDetail,
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
        amount: json["amount"],
        coin: json["coins"],
        paymentType: json["payment_type"],
        paymentDetail: json["payment_detail"],
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
        "amount": amount,
        "coins": coin,
        "payment_type": paymentType,
        "payment_detail": paymentDetail,
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
