import 'package:hive/hive.dart';

part 'download_item.g.dart'; // Generated file will be here

@HiveType(typeId: 0) // Assign a unique typeId for the class
class DownloadItem extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int? contentType;

  @HiveField(2)
  String? channelId;

  @HiveField(3)
  int? categoryId;

  @HiveField(4)
  int? languageId;

  @HiveField(5)
  int? artistId;

  @HiveField(6)
  String? hashtagId;

  @HiveField(7)
  String? title;

  @HiveField(8)
  String? description;

  @HiveField(9)
  String? portraitImg;

  @HiveField(10)
  String? landscapeImg;

  @HiveField(11)
  String? contentUploadType;

  @HiveField(12)
  String? content;

  @HiveField(13)
  String? contentSize;

  @HiveField(14)
  int? isRent;

  @HiveField(15)
  int? rentPrice;

  @HiveField(16)
  int? isComment;

  @HiveField(17)
  int? isDownload;

  @HiveField(18)
  int? isLike;

  @HiveField(19)
  int? totalView;

  @HiveField(20)
  int? totalLike;

  @HiveField(21)
  int? totalDislike;

  @HiveField(22)
  int? playlistType;

  @HiveField(23)
  int? isAdminAdded;

  @HiveField(24)
  int? status;

  @HiveField(25)
  String? createdAt;

  @HiveField(26)
  String? updatedAt;

  @HiveField(27)
  String? channelName;

  @HiveField(28)
  String? channelImage;

  @HiveField(29)
  int? userId;

  @HiveField(30)
  int? isSubscribe;

  @HiveField(31)
  String? categoryName;

  @HiveField(32)
  String? artistName;

  @HiveField(33)
  String? languageName;

  @HiveField(34)
  int? totalComment;

  @HiveField(35)
  int? isUserLikeDislike;

  @HiveField(36)
  int? totalSubscriber;

  @HiveField(37)
  int? isBuy;

  @HiveField(38)
  int? stopTime;

  @HiveField(39)
  int? isUserDownload;

  @HiveField(40)
  String? securityKey;

  @HiveField(41)
  String? securityIVKey;

  @HiveField(42)
  String? savedDir;

  @HiveField(43)
  String? savedFile;

  DownloadItem({
    this.id,
    this.contentType,
    this.channelId,
    this.categoryId,
    this.languageId,
    this.artistId,
    this.hashtagId,
    this.title,
    this.description,
    this.portraitImg,
    this.landscapeImg,
    this.contentUploadType,
    this.content,
    this.contentSize,
    this.isRent,
    this.rentPrice,
    this.isComment,
    this.isDownload,
    this.isLike,
    this.totalView,
    this.totalLike,
    this.totalDislike,
    this.playlistType,
    this.isAdminAdded,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.channelName,
    this.channelImage,
    this.userId,
    this.isSubscribe,
    this.categoryName,
    this.artistName,
    this.languageName,
    this.totalComment,
    this.isUserLikeDislike,
    this.totalSubscriber,
    this.isBuy,
    this.stopTime,
    this.isUserDownload,
    this.securityKey,
    this.securityIVKey,
    this.savedDir,
    this.savedFile,
  });

  factory DownloadItem.fromJson(Map<String, dynamic> json) => DownloadItem(
        id: json["id"],
        contentType: json["content_type"],
        channelId: json["channel_id"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        artistId: json["artist_id"],
        hashtagId: json["hashtag_id"],
        title: json["title"],
        description: json["description"],
        portraitImg: json["portrait_img"],
        landscapeImg: json["landscape_img"],
        contentUploadType: json["content_upload_type"],
        content: json["content"],
        contentSize: json["content_size"],
        isRent: json["is_rent"],
        rentPrice: json["rent_price"],
        isComment: json["is_comment"],
        isDownload: json["is_download"],
        isLike: json["is_like"],
        totalView: json["total_view"],
        totalLike: json["total_like"],
        totalDislike: json["total_dislike"],
        playlistType: json["playlist_type"],
        isAdminAdded: json["is_admin_added"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        channelName: json["channel_name"],
        channelImage: json["channel_image"],
        userId: json["user_id"],
        isSubscribe: json["is_subscribe"],
        categoryName: json["category_name"],
        artistName: json["artist_name"],
        languageName: json["language_name"],
        totalComment: json["total_comment"],
        isUserLikeDislike: json["is_user_like_dislike"],
        totalSubscriber: json["total_subscriber"],
        isBuy: json["is_buy"],
        stopTime: json["stop_time"],
        securityKey: json["securityKey"],
        securityIVKey: json["securityIVKey"],
        isUserDownload: json["is_user_download"],
        savedDir: json["savedDir"],
        savedFile: json["savedFile"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "content_type": contentType,
        "channel_id": channelId,
        "category_id": categoryId,
        "language_id": languageId,
        "artist_id": artistId,
        "hashtag_id": hashtagId,
        "title": title,
        "description": description,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "content_upload_type": contentUploadType,
        "content": content,
        "content_size": contentSize,
        "is_rent": isRent,
        "rent_price": rentPrice,
        "is_comment": isComment,
        "is_download": isDownload,
        "is_like": isLike,
        "total_view": totalView,
        "total_like": totalLike,
        "total_dislike": totalDislike,
        "playlist_type": playlistType,
        "is_admin_added": isAdminAdded,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "channel_name": channelName,
        "channel_image": channelImage,
        "user_id": userId,
        "is_subscribe": isSubscribe,
        "category_name": categoryName,
        "artist_name": artistName,
        "language_name": languageName,
        "total_comment": totalComment,
        "is_user_like_dislike": isUserLikeDislike,
        "total_subscriber": totalSubscriber,
        "is_buy": isBuy,
        "stop_time": stopTime,
        "is_user_download": isUserDownload,
        "securityKey": securityKey,
        "securityIVKey": securityIVKey,
        "savedDir": savedDir,
        "savedFile": savedFile,
      };
}
