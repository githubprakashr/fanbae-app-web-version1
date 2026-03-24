import 'dart:io';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:fanbae/utils/utils.dart';

class PostVideoProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();

  bool loading = false,
      isComment = false,
      isSaveGallery = false,
      uploadLoading = false;

  String? coverTick = "tick1",
      thumbnail1 = "",
      thumbnail2 = "",
      thumbnail3 = "",
      finalThumb = "";
  File? watermarkedFile, videoThumb;

  Future<void> uploadNewVideo(
      title, video, portraitImage, isLike, isComment, type) async {
    finalThumb = portraitImage?.path ?? "";
    setShortUploadLoading(true);
    successModel = await ApiService()
        .uploadVideo(title, video, portraitImage, isLike, isComment, type);
    setShortUploadLoading(false);
    notifyListeners();
  }

  setShortUploadLoading(isSending) {
    printLog("isSending ==> $isSending");
    uploadLoading = isSending;
    notifyListeners();
  }

  getThumbnailCovers(File? watermarkFile) async {
    loading = true;
    printLog('getThumbnailCovers watermarkFile ===> $watermarkFile');
    thumbnail1 = await VideoThumbnail.thumbnailFile(
      video: watermarkFile?.path ?? "",
      thumbnailPath: (await getApplicationDocumentsDirectory()).path,
      imageFormat: ImageFormat.PNG,
      quality: 10,
    );
    printLog('getThumbnailCovers thumbnail1 ===> $thumbnail1');

    thumbnail2 = await VideoThumbnail.thumbnailFile(
      video: watermarkFile?.path ?? "",
      thumbnailPath: (await getApplicationDocumentsDirectory()).path,
      imageFormat: ImageFormat.PNG,
      quality: 50,
    );
    printLog('getThumbnailCovers thumbnail2 ===> $thumbnail2');

    thumbnail3 = await VideoThumbnail.thumbnailFile(
      video: watermarkFile?.path ?? "",
      thumbnailPath: (await getApplicationDocumentsDirectory()).path,
      imageFormat: ImageFormat.PNG,
      quality: 100,
    );
    printLog('getThumbnailCovers thumbnail3 ===> $thumbnail3');
    loading = false;
    notifyListeners();
  }

  void saveInGallery(String videoPath) async {
    await GallerySaver.saveVideo(videoPath).then((success) {
      printLog("saveInGallery success ===> $success");
    });
  }

  setCoverTick(String tick) {
    coverTick = tick;
    printLog("coverTick ===> $coverTick");
    notifyListeners();
  }

  toggleComment(bool value) async {
    if (isComment == false) {
      isComment = true;
    } else {
      isComment = false;
    }
    printLog('toggleSwitch isComment ==> $isComment');
    notifyListeners();
  }

  void toggleGallery(bool value) async {
    if (isSaveGallery == false) {
      isSaveGallery = true;
    } else {
      isSaveGallery = false;
    }
    printLog('toggleSwitch isSaveGallery ==> $isSaveGallery');
    notifyListeners();
  }

  clearProvider() {
    successModel = SuccessModel();
    loading = false;
    isComment = false;
    isSaveGallery = false;
    coverTick = "tick1";
    thumbnail1 = "";
    thumbnail2 = "";
    thumbnail3 = "";
    finalThumb = "";
    watermarkedFile;
    videoThumb;
  }
}
