import 'dart:convert';

FetchGiftModel fetchGiftModelFromJson(String str) => FetchGiftModel.fromJson(json.decode(str));

String fetchGiftModelToJson(FetchGiftModel data) => json.encode(data.toJson());

class FetchGiftModel {
    int? status;
    String? message;
    List<Result>? result;
    int? totalRows;
    int? totalPage;
    int? currentPage;
    bool? morePage;

    FetchGiftModel({
        this.status,
        this.message,
        this.result,
        this.totalRows,
        this.totalPage,
        this.currentPage,
        this.morePage,
    });

    factory FetchGiftModel.fromJson(Map<String, dynamic> json) => FetchGiftModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null ? [] : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
        totalRows: json["total_rows"],
        totalPage: json["total_page"],
        currentPage: json["current_page"],
        morePage: json["more_page"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
        "total_rows": totalRows,
        "total_page": totalPage,
        "current_page": currentPage,
        "more_page": morePage,
    };
}

class Result {
    int? id;
    String? name;
    String? image;
    int? price;
    int? status;
    String? createdAt;
    String? updatedAt;
    int? isBuy;

    Result({
        this.id,
        this.name,
        this.image,
        this.price,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.isBuy,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        price: json["price"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isBuy: json["is_buy"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "price": price,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_buy": isBuy,
    };
}
