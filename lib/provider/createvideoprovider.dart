import 'package:flutter/cupertino.dart';
import '../model/successmodel.dart';
import '../webservice/apiservice.dart';

class CreateVideoProvider extends ChangeNotifier {
  SuccessModel createVideoModel = SuccessModel();
  bool loading = false;

  createVideo(
    String channelId,
    String video,
    String contentType,
    String portraitImg,
    String title,
    String description,
    int categoryId,
    int isRent,
      int rentprice,
    int isLike,
    int isComment,
    String type,
    int coin,
    String videoType,
    String episodeName
  ) async {
    loading = true;
    notifyListeners();

    createVideoModel = await ApiService().createVideo(
        channelId,
        video,
        contentType,
        portraitImg,
        title,
        description,
        categoryId,
        isRent,
        rentprice,
        isLike,
        isComment,
        type,
        coin,
        videoType,
      episodeName
    );

    loading = false;
    notifyListeners();
  }
}
