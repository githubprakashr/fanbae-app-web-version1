class ModifyChannelsModel {
  ModifyChannelsModel({
    required this.status,
    required this.message,
    required this.result,
  });
  late final int status;
  late final String message;
  late final Result result;

  ModifyChannelsModel.fromJson(Map<String, dynamic> json){
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
    required this.limitChannel,
    required this.channels,
  });
  late final int limitChannel;
  late final List<Channels> channels;

  Result.fromJson(Map<String, dynamic> json){
    limitChannel = json['limit_channel'];
    channels = List.from(json['channels']).map((e)=>Channels.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['limit_channel'] = limitChannel;
    _data['channels'] = channels.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Channels {
  Channels({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.countryName,
    required this.type,
    required this.image,
    required this.coverImg,
    required this.description,
    required this.deviceType,
    required this.deviceToken,
    required this.website,
    required this.facebookUrl,
    required this.instagramUrl,
    required this.twitterUrl,
    required this.walletBalance,
    required this.walletEarning,
    required this.bankName,
    required this.bankCode,
    required this.bankAddress,
    required this.ifscNo,
    required this.accountNo,
    required this.idProof,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.userPenalStatus,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isCreater,
    required this.liveAmount,
    required this.chatAmount,
    required this.audioCallAmount,
    required this.videoCallAmount,
    required this.youtubeUrl,
    required this.fcmToken,
    required this.channelStatus,
  });
  late final int id;
  late final String channelId;
  late final String channelName;
  late final String fullName;
  late final String email;
  late final String countryCode;
  late final String mobileNumber;
  late final String countryName;
  late final int type;
  late final String image;
  late final String coverImg;
  late final String description;
  late final int deviceType;
  late final String deviceToken;
  late final String website;
  late final String facebookUrl;
  late final String instagramUrl;
  late final String twitterUrl;
  late final int walletBalance;
  late final int walletEarning;
  late final String bankName;
  late final String bankCode;
  late final String bankAddress;
  late final String ifscNo;
  late final String accountNo;
  late final String idProof;
  late final String address;
  late final String city;
  late final String state;
  late final String country;
  late final int pincode;
  late final int userPenalStatus;
  late final int status;
  late final String createdAt;
  late final String updatedAt;
  late final int isCreater;
  late final int liveAmount;
  late final int chatAmount;
  late final int audioCallAmount;
  late final int videoCallAmount;
  late final String youtubeUrl;
  late final String fcmToken;
  late final String channelStatus;

  Channels.fromJson(Map<String, dynamic> json){
    id = json['id'];
    channelId = json['channel_id'];
    channelName = json['channel_name'];
    fullName = json['full_name'];
    email = json['email'];
    countryCode = json['country_code'];
    mobileNumber = json['mobile_number'];
    countryName = json['country_name'];
    type = json['type'];
    image = json['image'];
    coverImg = json['cover_img'];
    description = json['description'];
    deviceType = json['device_type'];
    deviceToken = json['device_token'];
    website = json['website'];
    facebookUrl = json['facebook_url'] ?? '';
    instagramUrl = json['instagram_url']?? '';
    twitterUrl = json['twitter_url']?? '';
    walletBalance = json['wallet_balance'];
    walletEarning = json['wallet_earning'];
    bankName = json['bank_name'];
    bankCode = json['bank_code'];
    bankAddress = json['bank_address'];
    ifscNo = json['ifsc_no'];
    accountNo = json['account_no'];
    idProof = json['id_proof'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    pincode = json['pincode'];
    userPenalStatus = json['user_penal_status'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isCreater = json['is_creater'];
    liveAmount = json['live_amount'];
    chatAmount = json['chat_amount'];
    audioCallAmount = json['audio_call_amount'];
    videoCallAmount = json['video_call_amount'];
    youtubeUrl = json['youtube_url'];
    fcmToken = json['fcm_token'];
    channelStatus = json['channel_status'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['channel_id'] = channelId;
    _data['channel_name'] = channelName;
    _data['full_name'] = fullName;
    _data['email'] = email;
    _data['country_code'] = countryCode;
    _data['mobile_number'] = mobileNumber;
    _data['country_name'] = countryName;
    _data['type'] = type;
    _data['image'] = image;
    _data['cover_img'] = coverImg;
    _data['description'] = description;
    _data['device_type'] = deviceType;
    _data['device_token'] = deviceToken;
    _data['website'] = website;
    _data['facebook_url'] = facebookUrl;
    _data['instagram_url'] = instagramUrl;
    _data['twitter_url'] = twitterUrl;
    _data['wallet_balance'] = walletBalance;
    _data['wallet_earning'] = walletEarning;
    _data['bank_name'] = bankName;
    _data['bank_code'] = bankCode;
    _data['bank_address'] = bankAddress;
    _data['ifsc_no'] = ifscNo;
    _data['account_no'] = accountNo;
    _data['id_proof'] = idProof;
    _data['address'] = address;
    _data['city'] = city;
    _data['state'] = state;
    _data['country'] = country;
    _data['pincode'] = pincode;
    _data['user_penal_status'] = userPenalStatus;
    _data['status'] = status;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['is_creater'] = isCreater;
    _data['live_amount'] = liveAmount;
    _data['chat_amount'] = chatAmount;
    _data['audio_call_amount'] = audioCallAmount;
    _data['video_call_amount'] = videoCallAmount;
    _data['youtube_url'] = youtubeUrl;
    _data['fcm_token'] = fcmToken;
    _data['channel_status'] = channelStatus;
    return _data;
  }
}