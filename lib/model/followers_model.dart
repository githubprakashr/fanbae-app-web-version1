class FollowersModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  FollowersModel(
      {this.status,
        this.message,
        this.result,
        this.totalRows,
        this.totalPage,
        this.currentPage,
        this.morePage});

  FollowersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
    }
    totalRows = json['total_rows'];
    totalPage = json['total_page'];
    currentPage = json['current_page'];
    morePage = json['more_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
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
  String? channelId;
  String? channelName;
  String? fullName;
  String? email;
  String? countryCode;
  String? mobileNumber;
  String? countryName;
  int? type;
  String? image;
  String? coverImg;
  String? description;
  int? deviceType;
  String? deviceToken;
  String? website;
  String? facebookUrl;
  String? instagramUrl;
  String? twitterUrl;
  int? walletBalance;
  int? walletEarning;
  String? bankName;
  String? bankCode;
  String? bankAddress;
  String? ifscNo;
  String? accountNo;
  String? idProof;
  String? address;
  String? city;
  String? state;
  String? country;
  int? pincode;
  int? userPenalStatus;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? isCreater;
  int? liveAmount;
  int? chatAmount;
  int? audioCallAmount;
  int? videoCallAmount;
  String? youtubeUrl;
  String? fcmToken;
  int? isBuy;
  int? totalSubscriber;

  Result(
      {this.id,
        this.channelId,
        this.channelName,
        this.fullName,
        this.email,
        this.countryCode,
        this.mobileNumber,
        this.countryName,
        this.type,
        this.image,
        this.coverImg,
        this.description,
        this.deviceType,
        this.deviceToken,
        this.website,
        this.facebookUrl,
        this.instagramUrl,
        this.twitterUrl,
        this.walletBalance,
        this.walletEarning,
        this.bankName,
        this.bankCode,
        this.bankAddress,
        this.ifscNo,
        this.accountNo,
        this.idProof,
        this.address,
        this.city,
        this.state,
        this.country,
        this.pincode,
        this.userPenalStatus,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.isCreater,
        this.liveAmount,
        this.chatAmount,
        this.audioCallAmount,
        this.videoCallAmount,
        this.youtubeUrl,
        this.fcmToken,
        this.isBuy,
        this.totalSubscriber});

  Result.fromJson(Map<String, dynamic> json) {
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
    facebookUrl = json['facebook_url'];
    instagramUrl = json['instagram_url'];
    twitterUrl = json['twitter_url'];
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
    isBuy = json['is_buy'];
    totalSubscriber = json['total_subscriber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['channel_id'] = channelId;
    data['channel_name'] = channelName;
    data['full_name'] = fullName;
    data['email'] = email;
    data['country_code'] = countryCode;
    data['mobile_number'] = mobileNumber;
    data['country_name'] = countryName;
    data['type'] = type;
    data['image'] = image;
    data['cover_img'] = coverImg;
    data['description'] = description;
    data['device_type'] = deviceType;
    data['device_token'] = deviceToken;
    data['website'] = website;
    data['facebook_url'] = facebookUrl;
    data['instagram_url'] = instagramUrl;
    data['twitter_url'] = twitterUrl;
    data['wallet_balance'] = walletBalance;
    data['wallet_earning'] = walletEarning;
    data['bank_name'] = bankName;
    data['bank_code'] = bankCode;
    data['bank_address'] = bankAddress;
    data['ifsc_no'] = ifscNo;
    data['account_no'] = accountNo;
    data['id_proof'] = idProof;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['pincode'] = pincode;
    data['user_penal_status'] = userPenalStatus;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_creater'] = isCreater;
    data['live_amount'] = liveAmount;
    data['chat_amount'] = chatAmount;
    data['audio_call_amount'] = audioCallAmount;
    data['video_call_amount'] = videoCallAmount;
    data['youtube_url'] = youtubeUrl;
    data['fcm_token'] = fcmToken;
    data['is_buy'] = isBuy;
    data['total_subscriber'] = totalSubscriber;
    return data;
  }
}
