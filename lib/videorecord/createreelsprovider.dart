import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:deepar_flutter/deepar_flutter.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/videorecord/custom/custom_thumbnail.dart';
import 'package:fanbae/videorecord/custom/custom_video_time.dart';
import 'package:fanbae/videorecord/loadingoverlay.dart';
import 'package:fanbae/videorecord/previewreels.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/js.dart';

class CreateReelsProvider extends ChangeNotifier {
  // >>>>> >>>>> >>>>> Main Variable <<<<< <<<<< <<<<<

  final bool isUseEffects = true;

  bool isFlashOn = false;

  int countTime = 0;
  Timer? timer;
  int selectedDuration = 5;
  final List<int> recordingDurations = [5, 10, 30];

  double? videoTime;
  String? videoImage;

  String isRecording = "stop"; // Recording Types => [start,pause,stop]

  // >>>>> >>>>> >>>>> Camera Controller <<<<< <<<<< <<<<<

  CameraController? cameraController;
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;

  // >>>>> >>>>> >>>>> Camera Controller <<<<< <<<<< <<<<<

  DeepArController deepArController = DeepArController();

  final ImagePicker picker = ImagePicker();

  final List effectsCollection = [
    "None",
    "${Constant.assetsEffectPath}effect_bright-glasses.deepar",
    "${Constant.assetsEffectPath}effect_neon_devil_horns.deepar",
    "${Constant.assetsEffectPath}effect_makeup-kim.deepar",
    "${Constant.assetsEffectPath}effect_burning_effect.deepar",
    "${Constant.assetsEffectPath}effect_spring-fairy.deepar",
    "${Constant.assetsEffectPath}effect_bunny_ears.deepar",
    "${Constant.assetsEffectPath}effect_butterfly_headband.deepar",
    "${Constant.assetsEffectPath}effect_cracked_porcelain_face.deepar",
    "${Constant.assetsEffectPath}effect_face_swap.deepar",
    // "${Constant.assetsEffectPath}effect_nick_shoes.deepar",
    "${Constant.assetsEffectPath}effect_sequin_butterfly.deepar",
    "${Constant.assetsEffectPath}effect_spring_deer.deepar",
    "${Constant.assetsEffectPath}effect_small_flowers.deepar",
  ];

  final List<String> effectImages = [
    "None",
    "${Constant.assetsEffectPath}img_bright_glasses.webp",
    "${Constant.assetsEffectPath}img_neon_devil_horns.webp",
    "${Constant.assetsEffectPath}img_makeup-kim.webp",
    "${Constant.assetsEffectPath}img_burning_effect.webp",
    "${Constant.assetsEffectPath}img_spring_fairy.webp",
    "${Constant.assetsEffectPath}img_bunny_ears.webp",
    "${Constant.assetsEffectPath}img_butterfly_headband.webp",
    "${Constant.assetsEffectPath}img_cracked_porcelain_face.webp",
    "${Constant.assetsEffectPath}img_face_swap.webp",
    // "${Constant.assetsImagesPath}img_nick_shoes.webp",
    "${Constant.assetsEffectPath}img_sequin_butterfly.webp",
    "${Constant.assetsEffectPath}img_small_flowers.webp",
    "${Constant.assetsEffectPath}img_spring_deer.webp",
  ];

  final List<String> effectNames = [
    "None",
    "Bright Glasses",
    "Neon Devil Horns",
    "Makeup Kim",
    "Burning Effect",
    "Spring Fairy",
    "Bunny Ears",
    "Butterfly Headband",
    "Cracked Porcelain Face",
    "Face Swap",
    // "Nick Shoes",
    "Sequin Butterfly",
    "Spring Deer",
    "Small Flowers",
  ];

  final List effectsImageCollection = [];

  bool isShowEffects = false;

  int selectedEffectIndex = 0;

  bool isInitializeEffect = false;

  bool isFrontCamera = false;

  // >>>>> >>>>> >>>>> Initialize Method <<<<< <<<<< <<<<<

  Future<void> onGetPermission() async {
    final camera = await Permission.camera.request();
    final microphone = await Permission.microphone.request();
    if (camera.isGranted && microphone.isGranted) {
      if (isUseEffects) {
        onInitializeEffect();
      } else {
        onInitializeCamera();
      }
    } else {
      Utils().showToast("Please allow permission !!");
    }
  }

  // >>>>> >>>>> >>>>> Camera Controller Method <<<<< <<<<< <<<<<

  Future<void> onInitializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first; // Use the first available camera
      cameraController = CameraController(camera, ResolutionPreset.medium);
      await cameraController!.initialize();
      notifyListeners();
    } catch (e) {
      printLog("Error initializing camera: $e");
    }
  }

  Future<void> onDisposeCamera() async {
    cameraController?.dispose();
    cameraController = null;
    cameraController?.removeListener(cameraControllerListener);

    printLog("Camera Controller Dispose Success");
  }

  Future<void> cameraControllerListener() async {
    printLog("Change Camera Event => ${cameraController?.value}");
  }

  Future<void> onSwitchFlash() async {
    if (cameraLensDirection == CameraLensDirection.back) {
      if (isFlashOn) {
        isFlashOn = false;
        await cameraController?.setFlashMode(FlashMode.off);
      } else {
        isFlashOn = true;
        await cameraController?.setFlashMode(FlashMode.torch);
      }
      notifyListeners();
    }
  }

  Future<void> onSwitchCamera(BuildContext context) async {
    printLog("Switch Normal Camera Method Calling....");

    if (isRecording == "stop") {
      LoadingOverlay().show(context); // Start Loading...

      if (isFlashOn) {
        onSwitchFlash();
      }

      cameraLensDirection = cameraLensDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      final cameras = await availableCameras();
      final camera = cameras
          .firstWhere((camera) => camera.lensDirection == cameraLensDirection);
      cameraController = CameraController(camera, ResolutionPreset.high);
      await cameraController!.initialize();
      notifyListeners();
      LoadingOverlay().hide(); // Stop Loading...
    } else {
      printLog("Please Try After Complete Video Recording...");
    }
  }

  Future<void> onStartRecording(BuildContext context) async {
    try {
      if (cameraController != null && cameraController!.value.isInitialized) {
        LoadingOverlay().show(context); // Start Loading...
        onRestartAudio();
        await cameraController!.startVideoRecording();
        LoadingOverlay().hide(); // Stop Loading...
        if (cameraController!.value.isRecordingVideo) {
          onChangeRecordingEvent("start");
          printLog("Video Recording Starting....");
        }
      }
    } catch (e) {
      onPauseAudio();
      onChangeRecordingEvent("stop");
      printLog("Recording Starting Error => $e");
    }
  }

  Future<void> onPauseRecording(BuildContext context) async {
    try {
      if (cameraController != null && cameraController!.value.isInitialized) {
        LoadingOverlay().show(context); // Start Loading...
        onPauseAudio();
        await cameraController!.pauseVideoRecording();
        LoadingOverlay().hide(); // Stop Loading...
        if (cameraController!.value.isRecordingPaused) {
          onChangeRecordingEvent("pause");
          printLog("Video Recording Pausing....");
        }
      }
    } catch (e) {
      onChangeRecordingEvent("stop");
      printLog("Recording Pausing Error => $e");
    }
  }

  Future<void> onResumeRecording(BuildContext context) async {
    try {
      if (cameraController != null && cameraController!.value.isInitialized) {
        LoadingOverlay().show(context); // Start Loading...
        onResumeAudio();
        await cameraController!.resumeVideoRecording();
        LoadingOverlay().hide(); // Stop Loading...
        if (cameraController!.value.isRecordingPaused) {
          onChangeRecordingEvent("start");
          printLog("Video Recording Resume....");
        }
      }
    } catch (e) {
      onPauseAudio();
      onChangeRecordingEvent("stop");
      printLog("Video Recording Resume Error => $e");
    }
  }

  Future<String?> onStopRecording(BuildContext context) async {
    XFile? videoUrl;
    try {
      if (isFlashOn) {
        onSwitchFlash();
      }
      LoadingOverlay().show(context); // Start Loading...
      onPauseAudio();
      videoUrl = await cameraController!.stopVideoRecording();
      LoadingOverlay().hide(); // Stop Loading...
      onChangeRecordingEvent("stop");
      printLog("Recording Video Path => ${videoUrl.path}");
      return videoUrl.path;
    } catch (e) {
      onChangeRecordingEvent("stop");
      printLog("Recording Stop Failed !! => $e");
      return null;
    }
  }

  Future<void> onClickRecordingButton(BuildContext context) async {
    if (isRecording == "stop") {
      onChangeRecordingEvent("start");
      onChangeTimer(context);
      onStartRecording(context);
    } else if (isRecording == "start") {
      onChangeRecordingEvent("pause");
      onChangeTimer(context);
      onPauseRecording(context);
    } else if (isRecording == "pause") {
      onChangeRecordingEvent("start");
      onChangeTimer(context);
      onResumeRecording(context);
    }
  }

  // >>>>> >>>>> >>>>> Effect Controller Method <<<<< <<<<< <<<<<

  Future<void> onInitializeEffect() async {
    try {
      printLog("Effect Controller Initializing...");

      isInitializeEffect = await deepArController.initialize(
        androidLicenseKey: Constant.effectAndroidLicenseKey,
        iosLicenseKey: Constant.effectIosLicenseKey,
        resolution: Resolution.medium,
      );

      isFrontCamera = true;
      notifyListeners();

      printLog("Effect Controller Initialize => $isInitializeEffect");
    } catch (e) {
      printLog("Effect Controller Initialize Failed => $e");
    }
  }

  Future<void> onDisposeEffect() async {
    deepArController.destroy();
    deepArController = DeepArController();
    isInitializeEffect = false;
    printLog("Effect Controller Dispose Success");
  }

  Future<void> onSwitchEffectFlash() async {
    if (isFrontCamera == false) {
      if (isFlashOn) {
        isFlashOn = false;
        await deepArController.toggleFlash();
      } else {
        isFlashOn = true;
        await deepArController.toggleFlash();
      }
      notifyListeners();
    }
  }

  Future<void> onSwitchEffectCamera(BuildContext context) async {
    if (isRecording == "stop") {
      LoadingOverlay().show(context); // Start Loading...
      if (isFlashOn) {
        onSwitchEffectFlash();
      }

      try {
        await deepArController.flipCamera();
        isFrontCamera = !isFrontCamera;
      } catch (e) {
        printLog("Effect Flip Camera Failed !! =>$e");
      }

      LoadingOverlay().hide(); // Stop Loading...
    } else {
      printLog("Please Try After Complete Video Recording...");
    }
  }

  Future<void> onToggleEffect() async {
    isShowEffects = !isShowEffects;
    notifyListeners();
  }

  Future<void> onChangeEffect(int index) async {
    try {
      selectedEffectIndex = index;
      await deepArController
          .switchEffect(effectsCollection[selectedEffectIndex]);
      notifyListeners();
    } catch (e) {
      printLog("Switch Effect Failed => $e");
    }
  }

  Future<void> onClearEffect(int index) async {
    try {
      if (selectedEffectIndex != 0) {
        selectedEffectIndex = index;
        onDisposeEffect();
        onInitializeEffect();
        notifyListeners();
      }
    } catch (e) {
      printLog("Clear Effect Failed => $e");
    }
  }

  Future<void> onStartEffectRecording() async {
    try {
      if (isInitializeEffect) {
        if (isShowEffects) {
          onToggleEffect();
        }
        onRestartAudio();
        await deepArController.startVideoRecording();
        onChangeRecordingEvent("start");
        printLog("Video Recording Starting....");
      }
    } catch (e) {
      onPauseAudio();
      onChangeRecordingEvent("stop");
      printLog("Recording Starting Error => $e");
    }
  }

  Future<String?> onStopEffectRecording(BuildContext context) async {
    XFile? videoUrl;
    try {
      if (isFlashOn) {
        onSwitchEffectFlash();
      }
      LoadingOverlay().show(context); // Start Loading...

      onPauseAudio();
      final file = await deepArController.stopVideoRecording();
      videoUrl = XFile(file.path);

      LoadingOverlay().hide(); // Stop Loading...

      onChangeRecordingEvent("stop");
      printLog("Recording Video Path => ${videoUrl.path}");

      return videoUrl.path;
    } catch (e) {
      onChangeRecordingEvent("stop");
      printLog("Recording Stop Failed !! => $e");
      return null;
    }
  }

  Future<void> onLongPressStart(
      BuildContext context, LongPressStartDetails details) async {
    onChangeRecordingEvent("start");
    onChangeTimer(context);
    onStartEffectRecording();
  }

  Future<void> onLongPressEnd(
      BuildContext context, LongPressEndDetails details) async {
    onChangeRecordingEvent("stop");
    onChangeTimer(context);
    final videoPath = await onStopEffectRecording(context);
    if (videoPath != null && context.mounted) {
      onPreviewVideo(context, videoPath, '');
    }
  }

  //  >>>>> >>>>> >>>>>  Video Duration Method <<<<< <<<<< <<<<<

  Future<void> onChangeTimer(BuildContext context) async {
    if (isRecording == "start") {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) async {
          if (isRecording == "start" && countTime <= selectedDuration) {
            countTime++;
            notifyListeners();
            if (countTime == selectedDuration) {
              {
                countTime = 0;
                timer.cancel();
                onChangeRecordingEvent("stop");
                if (!context.mounted) return;
                String? videoPath;
                if (isUseEffects) {
                  videoPath = await onStopEffectRecording(context);
                } else {
                  videoPath = await onStopRecording(context);
                }
                if (videoPath != null && context.mounted) {
                  onPreviewVideo(context, videoPath, '');
                }
              }
            }
          }
        },
      );
    } else if (isRecording == "pause") {
      timer?.cancel();
      notifyListeners();
    } else {
      countTime = 0;
      timer?.cancel();
      onChangeRecordingEvent("stop");
      notifyListeners();
    }
  }

  Future<void> onChangeRecordingDuration(int index) async {
    selectedDuration = recordingDurations[index];
    notifyListeners();
  }

  Future<void> onChangeRecordingEvent(String type) async {
    isRecording = type;
    notifyListeners();
  }

  //  >>>>> >>>>> >>>>>  Preview Video Method <<<<< <<<<< <<<<<

  Future<String?> onRemoveAudio(String videoPath) async {
    final String videoWithoutAudioPath =
        '${(await getTemporaryDirectory()).path}/RM_${DateTime.now().millisecondsSinceEpoch}.mp4';
    // final ffmpegRemoveAudioCommand =
    //     '-i $videoPath -c copy -an $videoWithoutAudioPath';
    // final sessionRemoveAudio =
    //     await FFmpegKit.executeAsync(ffmpegRemoveAudioCommand);
    // final returnCodeRemoveAudio = await sessionRemoveAudio.getReturnCode();
    // printLog("Remove Audio Path => $videoWithoutAudioPath");
    // printLog("Return Code => $returnCodeRemoveAudio");
    return videoWithoutAudioPath;
  }

  Future<String?> onMergeAudioWithVideo(
      String videoPath, String audioPath) async {
    // final String path =
    //     '${(await getTemporaryDirectory()).path}/FV_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // videoTime = (await CustomVideoTime.onGet(videoPath) ?? 0).toDouble();

    // final soundTime = (await onGetSoundTime(audioPath) ?? 0);

    // if (soundTime != 0 && videoTime != null && videoTime != 0) {
    //   printLog("Audio Time => $soundTime Video Time => $videoTime");

    //   final minTime = (videoTime! < soundTime) ? videoTime : soundTime;

    //   final command =
    //       '-i $videoPath -i $audioPath -t $minTime -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 $path';
    //   final sessionRemoveAudio = await FFmpegKit.executeAsync(command);
    //   final returnCodeRemoveAudio = await sessionRemoveAudio.getReturnCode();
    //   printLog("Merge Video Path => $path");
    //   printLog("Return Code => $returnCodeRemoveAudio");
    //   return path;
    // } else {
    //   return null;
    // }
  }

  Future<void> onClickPreviewButton(BuildContext context) async {
    LoadingOverlay().show(context); // Start Loading...
    onChangeRecordingEvent("stop");
    onChangeTimer(context);
    final videoPath = await onStopRecording(context);
    LoadingOverlay().hide(); // Stop Loading...
    if (videoPath != null && context.mounted) {
      onPreviewVideo(context, videoPath, '');
    }
  }

  Future<void> pickVideoFromGallery(context) async {
    final XFile? pickedVideo =
        await picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      onPreviewVideo(context, pickedVideo.path, 'gallery');
    }
  }

  Future<void> onPreviewVideo(
      BuildContext context, String videoPath, String type) async {
    LoadingOverlay().show(context); // Start Loading...
    videoImage = await CustomThumbnail.onGet(videoPath);
    if (selectedSound != null) {
      printLog("Removing Audio From Video...");

      Utils().showToast("Please wait sometime...");
      final removeVideoPath = await onRemoveAudio(videoPath);
      await Future.delayed(const Duration(seconds: 2));
      if (removeVideoPath != null) {
        final mergeVideoPath = await onMergeAudioWithVideo(
            removeVideoPath, selectedSound?["link"]);
        await Future.delayed(const Duration(seconds: 5));
        LoadingOverlay().hide(); // Stop Loading...

        if (mergeVideoPath != null && videoTime != null && videoImage != null) {
          printLog("Video Path => $mergeVideoPath");
          printLog("Video Image => $videoImage");
          printLog("Video Time => $videoTime");

          final route = MaterialPageRoute(
            maintainState: false,
            fullscreenDialog: true,
            builder: (_) => PreviewReels(
              filePath: mergeVideoPath,
              videoImageFile: videoImage ?? "",
              fileType: 'video',
              hashtagId: '',
              hashtagName: '',
              type: type,
            ),
          );
          if (!context.mounted) return;
          Navigator.push(context, route);
        } else {
          Utils().showToast("Some thing went wrong !!");
          printLog("Get Video Image/Video Time Failed !!");
        }
      } else {
        LoadingOverlay().hide(); // Stop Loading...
      }
    } else {
      videoTime = (await CustomVideoTime.onGet(videoPath) ?? 0).toDouble();
      LoadingOverlay().hide(); // Stop Loading...

      if (videoTime != null && videoImage != null) {
        printLog("Video Path => $videoPath");
        printLog("Video Image => $videoImage");
        printLog("Video Time => $videoTime");

        printLog("Capture filePath =========> $videoPath");
        final route = MaterialPageRoute(
          maintainState: false,
          fullscreenDialog: true,
          builder: (_) => PreviewReels(
            filePath: videoPath,
            videoImageFile: videoImage ?? "",
            fileType: 'video',
            hashtagId: '',
            hashtagName: '',
            type: type,
          ),
        );
        if (!context.mounted) return;
        Navigator.push(context, route);
      } else {
        Utils().showToast("Some thing went wrong !!");
        printLog("Get Video Image/Video Time Failed !!");
      }
    }
  }

  Future<void> onChangeSound(Map sound) async {
    if (selectedSound?["id"] == sound["id"]) {
      selectedSound = null;
    } else {
      selectedSound = {
        "id": sound["id"],
        "name": sound["name"],
        "image": sound["image"],
        "link": sound["link"],
      };
      initAudio(sound["link"]);
    }
    notifyListeners();
    printLog("--------------- $selectedSound");
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<double?> onGetSoundTime(String audioPath) async {
    await _audioPlayer.setSourceUrl(audioPath);
    Duration? audioDuration = await _audioPlayer.getDuration();
    final audioTime = audioDuration?.inSeconds.toDouble();
    printLog("Selected Audio Time => $audioTime");
    return audioTime;
  }

  // >>>>> >>>>> >>>>> Play Sound Variable <<<<< <<<<< <<<<<

  Map? selectedSound;

  AudioPlayer audioPlayer = AudioPlayer();

  void initAudio(String audio) async {
    try {
      await audioPlayer.setSource(UrlSource(audio));
    } catch (e) {
      printLog("Audio Play Failed !! => $e");
    }
  }

  void onResumeAudio() {
    if (selectedSound != null) {
      try {
        audioPlayer.resume();
      } catch (e) {
        printLog("Audio Resume Error => $e");
      }
    }
  }

  void onRestartAudio() {
    if (selectedSound != null) {
      try {
        audioPlayer.seek(const Duration(milliseconds: 0));
        audioPlayer.resume();
      } catch (e) {
        printLog("Audio Restart Error => $e");
      }
    }
  }

  void onPauseAudio() {
    if (selectedSound != null) {
      try {
        audioPlayer.pause();
      } catch (e) {
        printLog("Audio Pause Error => $e");
      }
    }
  }
}
