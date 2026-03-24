import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/webservice/apiservice.dart';

class RequestCreatorProvider extends ChangeNotifier {
  SuccessModel requestCreatorModel = SuccessModel();
  bool loading = false;

  getRequestCreator(
    String name,
    String dob,
    String chanelName,
    int category,
    String youtubeChannel,
    String instagramChannel,
    String facebookChannel,
    int govId,
    File? uploadData,
    File? image,
    String paymentName,
    String bankName,
    String accNo,
    String ifscCode,
    String livePrice,
    String chatPrice,
    String audioCallPrice,
    String videoCallPrice, {
    Uint8List? selfieBytes,
    String? selfieName,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    loading = true;
    requestCreatorModel = await ApiService().requestCreator(
        name,
        dob,
        chanelName,
        category,
        youtubeChannel,
        instagramChannel,
        facebookChannel,
        govId,
        uploadData,
        image,
        paymentName,
        bankName,
        accNo,
        ifscCode,
        livePrice,
        chatPrice,
        audioCallPrice,
        videoCallPrice,
        selfieBytes: selfieBytes,
        selfieName: selfieName,
        fileName: fileName,
        fileBytes: fileBytes);
    loading = false;
    notifyListeners();
  }
}
