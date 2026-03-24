class SubscribeChannelsModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  SubscribeChannelsModel(
      {this.status,
        this.message,
        this.result,
        this.totalRows,
        this.totalPage,
        this.currentPage,
        this.morePage});

  SubscribeChannelsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add( Result.fromJson(v));
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
  String? image;
  String? channelId;
  String? channelName;
  String? fullName;

  Result(
      {this.id, this.image, this.channelId, this.channelName, this.fullName});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    channelId = json['channel_id'];
    channelName = json['channel_name'];
    fullName = json['full_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['channel_id'] = channelId;
    data['channel_name'] = channelName;
    data['full_name'] = fullName;
    return data;
  }
}
