class PodcastModel {
  PodcastModel({
    required this.status,
    required this.message,
    required this.result,
  });
  late final int status;
  late final String message;
  late final List<Result> result;

  PodcastModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    message = json['message'] ?? '';
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
    required this.contentType,
    required this.channelId,
    required this.categoryId,
    required this.languageId,
    required this.artistId,
    required this.hashtagId,
    required this.title,
    required this.description,
    required this.portraitImg,
    required this.landscapeImg,
    required this.contentUploadType,
    required this.content,
    required this.contentSize,
    required this.contentDuration,
    required this.isRent,
    required this.rentPrice,
    required this.isComment,
    required this.isDownload,
    required this.isLike,
    required this.totalView,
    required this.totalLike,
    required this.totalDislike,
    required this.playlistType,
    required this.isAdminAdded,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    required this.coin,
    this.channelUser,
    required this.videoType,
    this.episodeName,
    required this.userId,
    required this.channelName,
    required this.channelImage,
    required this.categoryName,
    required this.artistName,
    required this.languageName,
    required this.isSubscribe,
    required this.totalComment,
    required this.isUserLikeDislike,
  });
  late final int id;
  late final int contentType;
  late final String channelId;
  late final int categoryId;
  late final int languageId;
  late final int artistId;
  late final String hashtagId;
  late final String title;
  late final String description;
  late final String portraitImg;
  late final String landscapeImg;
  late final String contentUploadType;
  late final String content;
  late final String contentSize;
  late final int contentDuration;
  late final int isRent;
  late final int rentPrice;
  late final int isComment;
  late final int isDownload;
  late final int isLike;
  late final int totalView;
  late final int totalLike;
  late final int totalDislike;
  late final int playlistType;
  late final int isAdminAdded;
  late final int status;
  late final String createdAt;
  late final String updatedAt;
  late final String type;
  late final int coin;
  late final Null channelUser;
  late final String videoType;
  late final Null episodeName;
  late final int userId;
  late final String channelName;
  late final String channelImage;
  late final String categoryName;
  late final String artistName;
  late final String languageName;
  late final int isSubscribe;
  late final int totalComment;
  late final int isUserLikeDislike;

  Result.fromJson(Map<String, dynamic> json){
    id = json['id'];
    contentType = json['content_type'];
    channelId = json['channel_id'];
    categoryId = json['category_id'];
    languageId = json['language_id'];
    artistId = json['artist_id'];
    hashtagId = json['hashtag_id'];
    title = json['title'];
    description = json['description'];
    portraitImg = json['portrait_img'];
    landscapeImg = json['landscape_img'];
    contentUploadType = json['content_upload_type'];
    content = json['content'];
    contentSize = json['content_size'];
    contentDuration = json['content_duration'] ?? 0;
    isRent = json['is_rent'];
    rentPrice = json['rent_price'];
    isComment = json['is_comment'];
    isDownload = json['is_download'];
    isLike = json['is_like'];
    totalView = json['total_view'];
    totalLike = json['total_like'];
    totalDislike = json['total_dislike'];
    playlistType = json['playlist_type'];
    isAdminAdded = json['is_admin_added'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    type = json['type'] ?? '';
    coin = json['coin'] ?? 0;
    channelUser = null;
    videoType = json['video_type'] ?? '';
    episodeName = null;
    userId = json['user_id'] ?? 0;
    channelName = json['channel_name'] ?? '';
    channelImage = json['channel_image'] ?? '';
    categoryName = json['category_name'] ?? '';
    artistName = json['artist_name'] ?? '';
    languageName = json['language_name'] ?? '';
    isSubscribe = json['is_subscribe'] ?? 0;
    totalComment = json['total_comment'] ?? 0;
    isUserLikeDislike = json['is_user_like_dislike'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['content_type'] = contentType;
    _data['channel_id'] = channelId;
    _data['category_id'] = categoryId;
    _data['language_id'] = languageId;
    _data['artist_id'] = artistId;
    _data['hashtag_id'] = hashtagId;
    _data['title'] = title;
    _data['description'] = description;
    _data['portrait_img'] = portraitImg;
    _data['landscape_img'] = landscapeImg;
    _data['content_upload_type'] = contentUploadType;
    _data['content'] = content;
    _data['content_size'] = contentSize;
    _data['content_duration'] = contentDuration;
    _data['is_rent'] = isRent;
    _data['rent_price'] = rentPrice;
    _data['is_comment'] = isComment;
    _data['is_download'] = isDownload;
    _data['is_like'] = isLike;
    _data['total_view'] = totalView;
    _data['total_like'] = totalLike;
    _data['total_dislike'] = totalDislike;
    _data['playlist_type'] = playlistType;
    _data['is_admin_added'] = isAdminAdded;
    _data['status'] = status;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['type'] = type;
    _data['coin'] = coin;
    _data['channel_user'] = channelUser;
    _data['video_type'] = videoType;
    _data['episode_name'] = episodeName;
    _data['user_id'] = userId;
    _data['channel_name'] = channelName;
    _data['channel_image'] = channelImage;
    _data['category_name'] = categoryName;
    _data['artist_name'] = artistName;
    _data['language_name'] = languageName;
    _data['is_subscribe'] = isSubscribe;
    _data['total_comment'] = totalComment;
    _data['is_user_like_dislike'] = isUserLikeDislike;
    return _data;
  }
}