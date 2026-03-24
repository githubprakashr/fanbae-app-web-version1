class GetEpisodeList {
  GetEpisodeList({
    required this.status,
    required this.message,
    required this.result,
  });
  late final int status;
  late final String message;
  late final List<Result> result;

  GetEpisodeList.fromJson(Map<String, dynamic> json){
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
    required this.episodeName,
  });
  late final String episodeName;

  Result.fromJson(Map<String, dynamic> json){
    episodeName = json['episode_name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['episode_name'] = episodeName;
    return _data;
  }
}