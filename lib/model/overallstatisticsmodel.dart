class OverallStatisticsModel {
  OverallStatisticsModel({
    required this.status,
    required this.message,
    required this.result,
  });

  late final int status;
  late final String message;
  late final Result result;

  OverallStatisticsModel.fromJson(Map<String, dynamic> json) {
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
    required this.earningAmount,
    required this.coinValue,
    required this.engagementRate,
    required this.totalContentCount,
    required this.overallSubscribers,
    required this.monthSubscribers,
    required this.todaySubscribers,
    required this.contentViews,
    required this.contentLike,
    required this.contentComment,
    required this.postLike,
    required this.postComment,
    required this.postView,
    required this.totalView,
    required this.totalLike,
    required this.totalDislike,
    required this.totalComment,
    required this.overallWithdrawalCoin,
    required this.overallWithdrawalAmount,
    required this.monthWithdrawalCoin,
    required this.monthWithdrawalAmount,
    required this.overallEarningCoin,
    required this.monthEarningCoin,
    required this.monthlyChartViews,
    required this.yearChartViews,
    required this.videoList,
    required this.withdrawalHistory,
  });

  late final String earningAmount;
  late final double coinValue;
  late final double engagementRate;
  late final String totalContentCount;
  late final int overallSubscribers;
  late final int monthSubscribers;
  late final int todaySubscribers;
  late final int contentViews;
  late final int contentLike;
  late final int contentComment;
  late final int postLike;
  late final int postComment;
  late final int postView;
  late final String totalView;
  late final String totalLike;
  late final int totalDislike;
  late final int totalComment;
  late final int overallWithdrawalCoin;
  late final int overallWithdrawalAmount;
  late final int monthWithdrawalCoin;
  late final int monthWithdrawalAmount;
  late final int overallEarningCoin;
  late final int monthEarningCoin;
  late final MonthlyChartViews monthlyChartViews;
  late final YearChartViews yearChartViews;
  late final List<VideoList> videoList;
  late final List<WithdrawalHistory> withdrawalHistory;

  Result.fromJson(Map<String, dynamic> json) {
    earningAmount = json['earning_amount'] ?? '0';
    coinValue = (json['coin_value'] is int)
        ? (json['coin_value'] as int).toDouble()
        : (json['coin_value'] ?? 0.0);
    engagementRate = (json['engagement_rate'] is int)
        ? (json['engagement_rate'] as int).toDouble()
        : (json['engagement_rate'] ?? 0.0);
    totalContentCount = json['total_content_count'] ?? '0';
    overallSubscribers = json['overall_subscribers'] ?? 0;
    monthSubscribers = json['month_subscribers'] ?? 0;
    todaySubscribers = json['today_subscribers'] ?? 0;
    contentViews = json['content_views'] ?? 0;
    contentLike = json['content_like'] ?? 0;
    contentComment = json['content_comment'] ?? 0;
    postLike = json['post_like'] ?? 0;
    postComment = json['post_comment'] ?? 0;
    postView = json['post_view'] ?? 0;
    totalView = json['total_view'] ?? '0';
    totalLike = json['total_like'] ?? '0';
    totalDislike = json['total_dislike'] ?? 0;
    totalComment = json['total_comment'] ?? 0;
    overallWithdrawalCoin = json['overall_withdrawal_coin'] ?? 0;
    overallWithdrawalAmount = json['overall_withdrawal_amount'] ?? 0;
    monthWithdrawalCoin = json['month_withdrawal_coin'] ?? 0;
    monthWithdrawalAmount = json['month_withdrawal_amount'] ?? 0;
    overallEarningCoin = json['overall_earning_coin'] ?? 0;
    monthEarningCoin = json['month_earning_coin'] ?? 0;
    monthlyChartViews = MonthlyChartViews.fromJson(json['monthly_chart_views']);
    yearChartViews = YearChartViews.fromJson(json['year_chart_views']);
    videoList = List.from(json['video_list'] ?? [])
        .map((e) => VideoList.fromJson(e))
        .toList();
    withdrawalHistory = List.from(json['withdrawal_history'] ?? [])
        .map((e) => WithdrawalHistory.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['earning_amount'] = earningAmount;
    _data['coin_value'] = coinValue;
    _data['engagement_rate'] = engagementRate;
    _data['total_content_count'] = totalContentCount;
    _data['overall_subscribers'] = overallSubscribers;
    _data['month_subscribers'] = monthSubscribers;
    _data['today_subscribers'] = todaySubscribers;
    _data['content_views'] = contentViews;
    _data['content_like'] = contentLike;
    _data['content_comment'] = contentComment;
    _data['post_like'] = postLike;
    _data['post_comment'] = postComment;
    _data['post_view'] = postView;
    _data['total_view'] = totalView;
    _data['total_like'] = totalLike;
    _data['total_dislike'] = totalDislike;
    _data['total_comment'] = totalComment;
    _data['overall_withdrawal_coin'] = overallWithdrawalCoin;
    _data['overall_withdrawal_amount'] = overallWithdrawalAmount;
    _data['month_withdrawal_coin'] = monthWithdrawalCoin;
    _data['month_withdrawal_amount'] = monthWithdrawalAmount;
    _data['overall_earning_coin'] = overallEarningCoin;
    _data['month_earning_coin'] = monthEarningCoin;
    _data['monthly_chart_views'] = monthlyChartViews.toJson();
    _data['year_chart_views'] = yearChartViews.toJson();
    _data['video_list'] = videoList.map((e) => e.toJson()).toList();
    _data['withdrawal_history'] =
        withdrawalHistory.map((e) => e.toJson()).toList();
    return _data;
  }
}

class MonthlyChartViews {
  MonthlyChartViews({
    required this.january,
    required this.february,
    required this.march,
    required this.april,
    required this.may,
    required this.june,
    required this.july,
    required this.august,
    required this.september,
    required this.october,
    required this.november,
    required this.december,
  });

  late final int january;
  late final int february;
  late final int march;
  late final int april;
  late final int may;
  late final int june;
  late final int july;
  late final int august;
  late final int september;
  late final int october;
  late final int november;
  late final int december;

  MonthlyChartViews.fromJson(Map<String, dynamic> json) {
    january = json['1'] ?? 0;
    february = json['2'] ?? 0;
    march = json['3'] ?? 0;
    april = json['4'] ?? 0;
    may = json['5'] ?? 0;
    june = json['6'] ?? 0;
    july = json['7'] ?? 0;
    august = json['8'] ?? 0;
    september = json['9'] ?? 0;
    october = json['10'] ?? 0;
    november = json['11'] ?? 0;
    december = json['12'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['1'] = january;
    data['2'] = february;
    data['3'] = march;
    data['4'] = april;
    data['5'] = may;
    data['6'] = june;
    data['7'] = july;
    data['8'] = august;
    data['9'] = september;
    data['10'] = october;
    data['11'] = november;
    data['12'] = december;
    return data;
  }
}

class YearChartViews {
  YearChartViews({
    required this.one,
    required this.two,
    required this.three,
    required this.four,
    required this.five,
    required this.six,
    required this.seven,
    required this.eight,
    required this.nine,
    required this.ten,
  });

  late final int one;
  late final int two;
  late final int three;
  late final int four;
  late final int five;
  late final int six;
  late final int seven;
  late final int eight;
  late final int nine;
  late final int ten;

  YearChartViews.fromJson(Map<String, dynamic> json) {
    one = json['1'] ?? 0;
    two = json['2'] ?? 0;
    three = json['3'] ?? 0;
    four = json['4'] ?? 0;
    five = json['5'] ?? 0;
    six = json['6'] ?? 0;
    seven = json['7'] ?? 0;
    eight = json['8'] ?? 0;
    nine = json['9'] ?? 0;
    ten = json['10'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['1'] = one;
    data['2'] = two;
    data['3'] = three;
    data['4'] = four;
    data['5'] = five;
    data['6'] = six;
    data['7'] = seven;
    data['8'] = eight;
    data['9'] = nine;
    data['10'] = ten;
    return data;
  }
}

class VideoList {
  VideoList({
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
    this.coin,
    this.channelUser,
    required this.videoType,
    this.episodeName,
    required this.shortCode,
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
  late final Null coin;
  late final Null channelUser;
  late final String videoType;
  late final Null episodeName;
  late final String shortCode;

  VideoList.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    contentType = json['content_type'] ?? 0;
    channelId = json['channel_id'] ?? '';
    categoryId = json['category_id'] ?? 0;
    languageId = json['language_id'] ?? 0;
    artistId = json['artist_id'] ?? 0;
    hashtagId = json['hashtag_id'] ?? '';
    title = json['title'] ?? '';
    description = json['description'] ?? '';
    portraitImg = json['portrait_img'] ?? '';
    landscapeImg = json['landscape_img'] ?? '';
    contentUploadType = json['content_upload_type'] ?? '';
    content = json['content'] ?? '';
    contentSize = json['content_size'] ?? '';
    contentDuration = json['content_duration'] ?? 0;
    isRent = json['is_rent'] ?? 0;
    rentPrice = json['rent_price'] ?? 0;
    isComment = json['is_comment'] ?? 0;
    isDownload = json['is_download'] ?? 0;
    isLike = json['is_like'] ?? 0;
    totalView = json['total_view'] ?? 0;
    totalLike = json['total_like'] ?? 0;
    totalDislike = json['total_dislike'] ?? 0;
    playlistType = json['playlist_type'] ?? 0;
    isAdminAdded = json['is_admin_added'] ?? 0;
    status = json['status'] ?? 0;
    createdAt = json['created_at'] ?? '';
    updatedAt = json['updated_at'] ?? '';
    type = json['type'] ?? '';
    coin = null;
    channelUser = null;
    videoType = json['video_type'] ?? '';
    episodeName = null;
    shortCode = json['short_code'] ?? '';
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
    _data['short_code'] = shortCode;
    return _data;
  }
}

class WithdrawalHistory {
  WithdrawalHistory({
    required this.id,
    required this.date,
    required this.amount,
    required this.paymentType,
    required this.status,
  });

  late final int id;
  late final String date;
  late final String amount;
  late final String paymentType;
  late final String status;

  WithdrawalHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    date = json['date'] ?? '';
    amount = json['amount'] ?? '';
    paymentType = json['payment_type'] ?? '';
    status = json['status'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['date'] = date;
    _data['amount'] = amount;
    _data['payment_type'] = paymentType;
    _data['status'] = status;
    return _data;
  }
}
