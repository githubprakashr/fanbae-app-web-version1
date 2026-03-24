class PackageChannelsModel {
  PackageChannelsModel({
    required this.status,
    required this.message,
    required this.result,
  });
  late final int status;
  late final String message;
  late final Result result;

  PackageChannelsModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    message = json['message'];
    result = Result.fromJson(json['result']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['result'] = result.toJson();
    return _data;
  }
}

class Result {
  Result({
    required this.channelUsers,
    required this.total,
    required this.limit,
  });
  late final List<ChannelUsers> channelUsers;
  late final int total;
  late final int limit;

  Result.fromJson(Map<String, dynamic> json){
    channelUsers = List.from(json['channel_users']).map((e)=>ChannelUsers.fromJson(e)).toList();
    total = json['total'];
    limit = json['limit'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['channel_users'] = channelUsers.map((e)=>e.toJson()).toList();
    _data['total'] = total;
    _data['limit'] = limit;
    return _data;
  }
}

class ChannelUsers {
  ChannelUsers({
    required this.id,
    required this.fullName,
    required this.channelId,
    required this.channelName,
    required this.description,
    required this.image,
  });
  late final int id;
  late final String fullName;
  late final String channelId;
  late final String channelName;
  late final String description;
  late final String image;
  late final int subscribers;
  late final int contents;

  ChannelUsers.fromJson(Map<String, dynamic> json){
    id = json['id'];
    fullName = json['full_name'] ?? '';
    channelId = json['channel_id'];
    channelName = json['channel_name'];
    description = json['description'];
    image = json['image'];
    subscribers = json['followers_count'];
    contents = json['video_count'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['full_name'] = fullName;
    _data['channel_id'] = channelId;
    _data['channel_name'] = channelName;
    _data['description'] = description;
    _data['image'] = image;
    _data['followers_count'] = subscribers;
    _data['video_count'] = contents;
    return _data;
  }
}