import 'dart:convert';

SuccessModel successModelFromJson(String str) =>
    SuccessModel.fromJson(json.decode(str));

String successModelToJson(SuccessModel data) => json.encode(data.toJson());

class SuccessModel {
  int? status;
  String? message;
  String? success;

  SuccessModel({
    this.status,
    this.message,
    this.success,
  });

  factory SuccessModel.fromJson(Map<String, dynamic> json) => SuccessModel(
        status: json["status"],
        message: json["message"],
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "success": success,
      };
}
