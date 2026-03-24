class MembershipPlanModel {
  MembershipPlanModel({
    required this.status,
    required this.message,
    required this.result,
  });
  late final int status;
  late final String message;
  late final List<Result> result;

  MembershipPlanModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    message = json['message'];
    result = List.from(json['result']).map((e)=>Result.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['result'] = result.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Result {
  Result({
    required this.id,
    required this.createrId,
    required this.name,
    required this.price,
    required this.offerPrice,
    required this.planType,
    required this.planValue,
    required this.planFeatures,
    required this.planPurchased,
    required this.createdAt,
    required this.updatedAt,
  });
  late final int id;
  late final int createrId;
  late final String name;
  late final int price;
  late final int offerPrice;
  late final String planType;
  late final String planValue;
  late final PlanFeatures planFeatures;
  late final bool planPurchased;
  late final String createdAt;
  late final String updatedAt;
  late final String? expireDate;


  Result.fromJson(Map<String, dynamic> json){
    id = json['id'];
    createrId = json['creater_id'];
    name = json['name'];
    price = json['price'];
    offerPrice = json['offer_price'];
    planType = json['plan_type'];
    planValue = json['plan_value'];
    planFeatures = PlanFeatures.fromJson(json['plan_features']);
    planPurchased = json['plan_purchased'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    expireDate= json["expire_date"];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['creater_id'] = createrId;
    _data['name'] = name;
    _data['price'] = price;
    _data['offer_price'] = offerPrice;
    _data['plan_type'] = planType;
    _data['plan_value'] = planValue;
    _data['plan_features'] = planFeatures.toJson();
    _data['plan_purchased'] = planPurchased;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    return _data;
  }
}

class PlanFeatures {
  PlanFeatures({
    required this.video,
    required this.image,
    required this.liveStream,
    required this.chat,
  });
  late final int video;
  late final int image;
  late final int liveStream;
  late final int chat;

  PlanFeatures.fromJson(Map<String, dynamic> json){
    video = json['video'] ?? 0;
    image = json['image'] ?? 0;
    liveStream = json['live_stream'] ?? 0;
    chat = json['chat'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['video'] = video;
    data['image'] = image;
    data['live_stream'] = liveStream;
    data['chat'] = chat;
    return data;
  }
}