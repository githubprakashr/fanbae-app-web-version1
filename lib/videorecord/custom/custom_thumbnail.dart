import 'package:fanbae/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CustomThumbnail {
  static Future<String?> onGet(String videoPath) async {
    try {
      final videoThumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        timeMs: -1,
        maxHeight: 400,
        quality: 100,
      );
      return videoThumbnail;
    } catch (e) {
      printLog("Get Thumbnail Error => $e");
    }
    return null;
  }
}
