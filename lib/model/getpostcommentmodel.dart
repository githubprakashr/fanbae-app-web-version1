import 'dart:convert';

GetPostCommentModel getPostCommentModelFromJson(String str) =>
    GetPostCommentModel.fromJson(json.decode(str));

String getPostCommentModelToJson(GetPostCommentModel data) =>
    json.encode(data.toJson());

class GetPostCommentModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  GetPostCommentModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory GetPostCommentModel.fromJson(Map<String, dynamic> json) =>
      GetPostCommentModel(
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
  int? commentId;
  int? userId;
  int? postId;
  String? comment;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? channelName;
  String? fullName;
  String? email;
  String? image;
  int? isReply;
  int? totalReply;

  Result({
    this.id,
    this.commentId,
    this.userId,
    this.postId,
    this.comment,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.channelName,
    this.fullName,
    this.email,
    this.image,
    this.isReply,
    this.totalReply,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        commentId: json["comment_id"],
        userId: json["user_id"],
        postId: json["post_id"],
        comment: json["comment"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        channelName: json["channel_name"],
        fullName: json["full_name"],
        email: json["email"],
        image: json["image"],
        isReply: json["is_reply"],
        totalReply: json["total_reply"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "comment_id": commentId,
        "user_id": userId,
        "post_id": postId,
        "comment": comment,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "channel_name": channelName,
        "full_name": fullName,
        "email": email,
        "image": image,
        "is_reply": isReply,
        "total_reply": totalReply,
      };
}
