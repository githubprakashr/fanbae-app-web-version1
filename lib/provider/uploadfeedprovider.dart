import 'dart:io';
import 'dart:typed_data';
import 'package:fanbae/model/postcontentuploadmodel.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class UploadfeedProvider extends ChangeNotifier {
  List<String>? selectedContent = [];
  List<String>? selectContentType = [];
  List<String>? selectContentName = [];
  List<String>? selectThambnailImage = [];
  List<Map<String, dynamic>>? combinedList = [];
  int _isComment = 0; // Default is 0 (button off)
  int get isComment => _isComment;

  /* Post Content Upload Api */
  // bool loading = false;
  PostContentUploadModel postContentUploadModel = PostContentUploadModel();
  bool loading = false;

  /* Upload Post Api */
  SuccessModel successModel = SuccessModel();
  bool uploadLoading = false;

/* ============================== Upload End ============================== */

  uploadPost(
    title,
    isComment,
    discription,
    dynamic postContent,
    type,
    coin,
    file, {
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    setFeedUploadLoading(true);
    successModel = await ApiService().uploadFeedPost(
        title, isComment, discription, postContent, type, coin, file,
        fileName: fileName, fileBytes: fileBytes);
    setFeedUploadLoading(false);
    notifyListeners();
  }

  setFeedUploadLoading(isSending) {
    printLog("isSending ==> $isSending");
    uploadLoading = isSending;
    notifyListeners();
  }

  /* ============================== Upload End ============================== */

  /* Post Content Upload  */
  postContentUpload(
      String contentType, File? content, fileBytes, fileName) async {
    loading = true;
    postContentUploadModel = await ApiService().postContentUpload(
        contentType, content,
        filename: fileName, fileBytes: fileBytes);
    loading = false;
    notifyListeners();
  }

  /* Save And Remove Multiple Image */
  addRemoveContent({
    String? content,
    String? contentType,
    String? contentName,
    String? thambnailImage,
    required int index,
    required bool isAdd,
  }) {
    if (isAdd == true) {
      selectedContent?.add(content ?? "");
      selectContentType?.add(contentType ?? "");
      selectContentName?.add(contentName ?? "");
      selectThambnailImage?.add(thambnailImage ?? "");
    } else {
      selectedContent?.removeAt(index);
      selectContentType?.removeAt(index);
      selectContentName?.removeAt(index);
      selectThambnailImage?.removeAt(index);
    }
    notifyListeners();
    printLog("selectedComtent==>$selectedContent");
    printLog("selectContentType==>$selectContentType");
    printLog("selectContentName==>$selectContentName");
    printLog("selectContentName==>$selectThambnailImage");
  }

  /* Set Comment ON / OFF */
  void toggleComment() {
    _isComment = _isComment == 0 ? 1 : 0; // Toggle between 1 and 0
    notifyListeners();
  }

  clearProvider() {
    selectedContent = [];
    selectContentType = [];
    selectContentName = [];
    selectThambnailImage = [];
    combinedList = [];
    _isComment = 0; // Default is 0 (button off)
    /* Post Content Upload Api */
    postContentUploadModel = PostContentUploadModel();
    /* Upload Post Api */
    successModel = SuccessModel();
    loading = false;
    /* Upload Post Api */
    uploadLoading = false;
  }
}
