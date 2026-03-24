class SubscribingChannelsModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  SubscribingChannelsModel(
      {this.status,
        this.message,
        this.result,
        this.totalRows,
        this.totalPage,
        this.currentPage,
        this.morePage});

  SubscribingChannelsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
    }
    totalRows = json['total_rows'];
    totalPage = json['total_page'];
    currentPage = json['current_page'];
    morePage = json['more_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    data['total_rows'] = totalRows;
    data['total_page'] = totalPage;
    data['current_page'] = currentPage;
    data['more_page'] = morePage;
    return data;
  }
}

class Result {
  int? id;
  int? creatorId;
  String? name;
  int? price;
  int? offerPrice;
  String? planValue;
  String? planType;
  String? planFeatures;
  String? createdAt;
  String? updatedAt;
  String? expireDate;
  String? status;
  String? image;
  String? channelId;
  String? channelName;
  String? fullName;
  int? isAutoRenew;

  Result(
      {this.id,
        this.creatorId,
        this.name,
        this.price,
        this.offerPrice,
        this.planValue,
        this.planType,
        this.planFeatures,
        this.createdAt,
        this.updatedAt,
        this.expireDate,
        this.status,
        this.image,
        this.channelId,
        this.channelName,
        this.fullName,
        this.isAutoRenew,
      });

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    creatorId = json['creator_id'];
    name = json['name'];
    price = json['price'];
    offerPrice = json['offer_price'];
    planValue = json['plan_value'];
    planType = json['plan_type'];
    planFeatures = json['plan_features'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    expireDate = json['expire_date'];
    status = json['status'];
    image = json['image'];
    channelId = json['channel_id'];
    channelName = json['channel_name'];
    fullName = json['full_name'];
    isAutoRenew = json['creator_auto_renewal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['creator_id'] = creatorId;
    data['name'] = name;
    data['price'] = price;
    data['offer_price'] = offerPrice;
    data['plan_value'] = planValue;
    data['plan_type'] = planType;
    data['plan_features'] = planFeatures;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['expire_date'] = expireDate;
    data['status'] = status;
    data['creator_auto_renewal'] = isAutoRenew;
    return data;
  }
}
