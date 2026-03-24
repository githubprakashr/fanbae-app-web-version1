import 'package:fanbae/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class GalleryVideoProvider extends ChangeNotifier {
  VisibilityInfo? visibleInfo;
  bool isLoading = true,
      isRecording = false,
      isRecordDone = false,
      isContestRemoved = false;
  String? selectedAudioPath, selectedAudioId;

  setSelectedAudio({required String audioPath, required String audioId}) {
    selectedAudioPath = audioPath;
    selectedAudioId = audioId;
    printLog("selectedAudioPath =====> $selectedAudioPath");
    printLog("selectedAudioId =======> $selectedAudioId");
    notifyListeners();
  }

  removeContest(bool value) {
    printLog("removeContest value ===> $value");
    isContestRemoved = value;
    notifyListeners();
  }

  setVisibilityInfo(VisibilityInfo? visibleInfo) {
    this.visibleInfo = visibleInfo;
    notifyListeners();
  }

  clearProvider() {
    isLoading = true;
    isRecording = false;
    isRecordDone = false;
    isContestRemoved = false;
    selectedAudioPath = "";
    selectedAudioId = "";
  }
}
