class CreatorAdModel {
  CreatorAdModel({
    required this.status,
    required this.message,
    required this.result,
  });
  late final int status;
  late final String message;
  late final List<Result> result;

  CreatorAdModel.fromJson(Map<String, dynamic> json){
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
    required this.title,
    required this.image,
    required this.redirectUri,
    required this.budget,
    required this.type,
    required this.video,
    required this.videoImage,
    required this.status,
  });
  late final int id;
  late final String title;
  late final String image;
  late final String redirectUri;
  late final int budget;
  late final int type;
  late final String video;
  late final String videoImage;
  late final String status;


  Result.fromJson(Map<String, dynamic> json){
    id = json['id'];
    title = json['title'];
    image = json['image'];
    redirectUri = json['redirect_uri'];
    budget = json['budget'];
    type = json['type'];
    video = json['video'];
    videoImage = json['video_image'] ?? '';
    status = json['status'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['title'] = title;
    _data['image'] = image;
    _data['redirect_uri'] = redirectUri;
    _data['budget'] = budget;
    _data['type'] = type;
    _data['video'] = video;
    _data['video_image'] = videoImage;
    _data['status'] = status;
    return _data;
  }
}