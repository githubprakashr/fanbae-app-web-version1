class GetChatData {
  GetChatData({
    required this.status,
    required this.message,
    required this.result,
  });
  late final int status;
  late final String message;
  late final Result result;

  GetChatData.fromJson(Map<String, dynamic> json){
    status = json['status'];
    message = json['message'];
    result = Result.fromJson(json['result'] ?? []);
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
    required this.balance,
    required this.chatAmount,
    required this.channelId,
    required this.receiverChannelId
  });
  late final int balance;
  late final int chatAmount;
  late final String channelId;
  late final String receiverChannelId;

  Result.fromJson(Map<String, dynamic> json){
    balance = json['balance'];
    chatAmount = json['chat_amount'];
    channelId = json['channel_id'];
    receiverChannelId = json['receiver_channel_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['balance'] = balance;
    _data['chat_amount'] = chatAmount;
    _data['channel_id'] = channelId;
    _data['receiver_channel_id'] = receiverChannelId;
    return _data;
  }
}