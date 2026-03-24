import 'dart:convert';

UsageHistoryModel usageHistoryModelFromJson(String str) =>
    UsageHistoryModel.fromJson(json.decode(str));

String usageHistoryModelToJson(UsageHistoryModel data) =>
    json.encode(data.toJson());

class UsageHistoryModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  UsageHistoryModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory UsageHistoryModel.fromJson(Map<String, dynamic> json) =>
      UsageHistoryModel(
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
  int? adsId;
  int? totalCoin;
  String? title;
  String? message;
  String? createdAt;
  String? amountType;

  Result({
    this.adsId,
    this.totalCoin,
    this.title,
    this.message,
    this.createdAt,
    this.amountType,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        adsId: json["ads_id"],
        totalCoin: json["total_coin"],
        title: json["title"],
        message: json["message"],
        createdAt: json["created_at"],
        amountType: json["amount_type"],
      );

  Map<String, dynamic> toJson() => {
        "ads_id": adsId,
        "total_coin": totalCoin,
        "title": title,
        "message": message,
        "created_at": createdAt,
        "amount_type": amountType,
      };
}
