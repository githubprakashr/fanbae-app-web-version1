import 'dart:convert';

PostContentUploadModel postContentUploadModelFromJson(String str) =>
    PostContentUploadModel.fromJson(json.decode(str));

String postContentUploadModelToJson(PostContentUploadModel data) =>
    json.encode(data.toJson());

class PostContentUploadModel {
  int? status;
  String? message;
  Result? result;

  PostContentUploadModel({
    this.status,
    this.message,
    this.result,
  });

  factory PostContentUploadModel.fromJson(Map<String, dynamic> json) =>
      PostContentUploadModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result?.toJson(),
      };
}

class Result {
  String? contentType;
  String? contentName;
  String? contentUrl;

  Result({
    this.contentType,
    this.contentName,
    this.contentUrl,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        contentType: json["content_type"],
        contentName: json["content_name"],
        contentUrl: json["content_url"],
      );

  Map<String, dynamic> toJson() => {
        "content_type": contentType,
        "content_name": contentName,
        "content_url": contentUrl,
      };
}
