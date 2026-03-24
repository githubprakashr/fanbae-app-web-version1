class ScheduleCallModel {
  ScheduleCallModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final Data data;

  ScheduleCallModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    message = json['message'];
    data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.date,
    required this.slots,
    required this.totalSlots,
    required this.availableCount,
    required this.unavailableCount,
    required this.bookedSlots,
  });
  late final String date;
  late final List<Slots> slots;
  late final int totalSlots;
  late final int availableCount;
  late final int unavailableCount;
  late final  List<BookedData> bookedSlots;

  Data.fromJson(Map<String, dynamic> json){
    date = json['date'] ?? '';
    slots = List.from(json['slots'] ?? []).map((e)=>Slots.fromJson(e)).toList();
    totalSlots = json['total_slots'] ?? 0;
    availableCount = json['available_count'] ?? 0;
    unavailableCount = json['unavailable_count'] ?? 0;
    bookedSlots =  List.from(json['booked_slots'] ?? []).map((e)=>BookedData.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['date'] = date;
    _data['slots'] = slots.map((e)=>e.toJson()).toList();
    _data['total_slots'] = totalSlots;
    _data['available_count'] = availableCount;
    _data['unavailable_count'] = unavailableCount;
    _data['booked_slots'] = bookedSlots;
    return _data;
  }
}

class Slots {
  Slots({
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.bookedData,
  });
  late final String startTime;
  late final String endTime;
  late final String status;
  late final BookedData bookedData;

  Slots.fromJson(Map<String, dynamic> json){
    startTime = json['start_time'];
    endTime = json['end_time'];
    status = json['status'];
    bookedData = BookedData.fromJson(json['booked_data'] ?? {});
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['start_time'] = startTime;
    _data['end_time'] = endTime;
    _data['status'] = status;
    _data['booked_data'] = bookedData.toJson();
    return _data;
  }
}

class BookedData {
  BookedData({
    required this.id,
    required this.userId,
    required this.channelId,
    required this.date,
    required this.type,
    required this.userName,
    required this.userImage,
    required this.startTime,
    required this.endTime,
    required this.dateTimeStart,
    required this.dateTimeEnd,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  late final int id;
  late final int userId;
  late final int channelId;
  late final String date;
  late final String type;
  late final String userName;
  late final String userImage;
  late final String startTime;
  late final String endTime;
  late final String dateTimeStart;
  late final String dateTimeEnd;
  late final String message;
  late final String status;
  late final String createdAt;
  late final String updatedAt;

  BookedData.fromJson(Map<String, dynamic> json){
    id = json['id'] ?? 0;
    userId = json['user_id'] ?? 0;
    channelId = json['channel_id'] ?? 0;
    date = json['date'] ?? '';
    type = json['type'] ?? '';
    userName = json['user_name'] ?? '';
    userImage = json['user_image'] ?? '';
    startTime = json['start_time'] ?? '';
    endTime = json['end_time'] ?? '';
    dateTimeStart = json['call_start_time'] ?? '';
    dateTimeEnd = json['call_end_time'] ?? '';
    message = json['message'] ?? '';
    status = json['status'] ?? '';
    createdAt = json['created_at'] ?? '';
    updatedAt = json['updated_at'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['channel_id'] = channelId;
    _data['date'] = date;
    _data['type'] = type;
    _data['user_name'] = userName;
    _data['user_image'] = userImage;
    _data['start_time'] = startTime;
    _data['end_time'] = endTime;
    _data['call_start_time'] = dateTimeStart;
    _data['call_end_time'] = dateTimeEnd;
    _data['message'] = message;
    _data['status'] = status;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    return _data;
  }
}