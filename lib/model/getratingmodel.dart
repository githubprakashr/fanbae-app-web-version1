class GetRatingsModel {
  GetRatingsModel({
    required this.status,
    required this.message,
    required this.result,
  });
  late final int status;
  late final String message;
  late final List<Result> result;

  GetRatingsModel.fromJson(Map<String, dynamic> json){
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
    required this.rating,
    required this.message,
    required this.creatorId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.isReviewed,
    required this.createdAt,
  });
  late final int id;
  late final int rating;
  late final String message;
  late final int creatorId;
  late final int userId;
  late final String userName;
  late final String userImage;
  late final int isReviewed;
  late final String createdAt;

  Result.fromJson(Map<String, dynamic> json){
    id = json['id'];
    rating = json['rating'];
    message = json['message'];
    creatorId = json['creator_id'];
    userId = json['user_id'];
    userName = json['user_name'];
    userImage = json['user_image'];
    isReviewed = json['is_reviewed'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['rating'] = rating;
    _data['message'] = message;
    _data['creator_id'] = creatorId;
    _data['user_id'] = userId;
    _data['user_name'] = userName;
    _data['user_image'] = userImage;
    _data['is_reviewed'] = isReviewed;
    _data['created_at'] = createdAt;
    return _data;
  }
}