import 'package:fanbae/model/addcontenttohistorymodel.dart';
import 'package:fanbae/model/addviewmodel.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoScreenProvider extends ChangeNotifier {
  AddViewModel addViewModel = AddViewModel();
  AddcontenttoHistoryModel addcontenttoHistoryModel =
      AddcontenttoHistoryModel();

  VisibilityInfo? visibleInfo;
  bool loading = false;

  Future<void> addShortView(contenttype, contentid) async {
    printLog("addPostView postId :==> $contentid");
    loading = true;
    addViewModel = await ApiService().addView(contenttype, contentid);
    printLog("addPostView status :==> ${addViewModel.status}");
    printLog("addPostView message :==> ${addViewModel.message}");
    loading = false;
  }

  Future<void> addContentHistory(
      contenttype, contentid, stoptime, episodeid) async {
    loading = true;
    addcontenttoHistoryModel = await ApiService()
        .addContentToHistory(contenttype, contentid, stoptime, episodeid);
    loading = false;
  }

  setVisibilityInfo(VisibilityInfo? visibleInfo) {
    this.visibleInfo = visibleInfo;
    notifyListeners();
  }

  clearProvider() {
    addViewModel = AddViewModel();
    visibleInfo = null;
    loading = false;
  }
}
