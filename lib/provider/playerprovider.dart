import 'package:fanbae/model/addcontenttohistorymodel.dart';
import 'package:fanbae/model/addviewmodel.dart';
import 'package:fanbae/model/removecontenttohistorymodel.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/webservice/apiservice.dart';

class PlayerProvider extends ChangeNotifier {
  AddViewModel addViewModel = AddViewModel();

  AddcontenttoHistoryModel addcontenttoHistoryModel =
      AddcontenttoHistoryModel();

  RemoveContentHistoryModel removeContentHistoryModel =
      RemoveContentHistoryModel();
  bool loading = false;

  double _progress = 0.0;
  double get progress => _progress;

  void setDecryptProgress(double newProgress) {
    _progress = newProgress;
    notifyListeners(); // Notify listeners of the change
  }

  Future<void> addVideoView(contenttype, contentid) async {
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

  Future<void> removeContentHistory(contenttype, contentid, episodeid) async {
    loading = true;
    removeContentHistoryModel = await ApiService()
        .removeContentToHistory(contenttype, contentid, episodeid);
    loading = false;
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    addViewModel = AddViewModel();
    addcontenttoHistoryModel = AddcontenttoHistoryModel();
    removeContentHistoryModel = RemoveContentHistoryModel();
    loading = false;
  }
}
