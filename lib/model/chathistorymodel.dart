class ChatHistoryData {
  ChatHistoryData({
    required this.status,
    required this.message,
    required this.result,
  });
  late final int status;
  late final String message;
  late final List<Result> result;

  ChatHistoryData.fromJson(Map<String, dynamic> json){
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
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    required this.lastMessage,
    required this.timestamp,
  });
  late final String chatId;
  late final String receiverId;
  late final String receiverName;
    int? creatorId;
  late final String? receiverImage;
  late final String lastMessage;
  late final String? timestamp;
  late final int unReadCount;

  Result.fromJson(Map<String, dynamic> json){
    chatId = json['chat_id'];
    receiverId = json['receiver_id'];
    receiverName = json['receiver_name'];
    creatorId = json['receiver_is_creator'] ??'';
    receiverImage = json['receiver_image'];
    lastMessage = json['last_message'];
    timestamp = json['timestamp'];
    unReadCount = json['count_message'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['chat_id'] = chatId;
    _data['receiver_id'] = receiverId;
    _data['receiver_name'] = receiverName;
    _data['receiver_image'] = receiverImage;
    _data['receiver_is_creator'] = creatorId;
    _data['last_message'] = lastMessage;
    _data['timestamp'] = timestamp;
    _data['count_message'] = unReadCount;
    return _data;
  }
}