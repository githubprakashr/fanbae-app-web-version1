class EarningModel {
  int? status;
  String? message;
  Result? result;

  EarningModel({this.status, this.message, this.result});

  EarningModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] is String
        ? int.tryParse(json['status'])
        : json['status'];
    message = json['message']?.toString();
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class Result {
  int? earningCoin;
  String? withdrawalCoin;
  String? withdrawalAmount;

  Result({this.earningCoin, this.withdrawalCoin, this.withdrawalAmount});

  Result.fromJson(Map<String, dynamic> json) {
    earningCoin = json['earning_coin'] is String
        ? int.tryParse(json['earning_coin'])
        : json['earning_coin'];

    withdrawalCoin = json['withdrawal_coin']?.toString();
    withdrawalAmount = json['withdrawal_amount']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['earning_coin'] = earningCoin;
    data['withdrawal_coin'] = withdrawalCoin;
    data['withdrawal_amount'] = withdrawalAmount;
    return data;
  }
}
