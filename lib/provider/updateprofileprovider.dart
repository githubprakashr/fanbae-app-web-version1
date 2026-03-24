import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fanbae/model/profilemodel.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/webservice/apiservice.dart';

class UpdateprofileProvider extends ChangeNotifier {
  SuccessModel updateprofileModel = SuccessModel();
  ProfileModel profileModel = ProfileModel();
  bool loading = false;

  getupdateprofile(
    String userid,
    String fullname,
    String channelName,
    String email,
    String description,
    String number,
    String countrycode,
    String countryName,
    File image,
    File coverImage,
    int liveAmount,
    int chatAmount,
    int audioCallAmount,
    int videoCallAmount,
  ) async {
    loading = true;
    updateprofileModel = await ApiService().updateprofile(
      userid,
      fullname,
      channelName,
      email,
      description,
      number,
      countrycode,
      countryName,
      image,
      coverImage,
      liveAmount,
      chatAmount,
      audioCallAmount,
      videoCallAmount,
    );
    loading = false;
    notifyListeners();
  }
}
