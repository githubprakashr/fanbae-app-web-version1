import 'package:camera/camera.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class GoLivePreviewProvider extends ChangeNotifier {
  CameraController? cameraController;
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;

  bool isFlashOn = false;

  Future<void> onRequestPermissions() async {
    final camera = await Permission.camera.request();
    final microphone = await Permission.microphone.request();
    if (camera.isGranted && microphone.isGranted) {
      onInitializeCamera();
    } else {
      printLog("Permission Dinied!!!!");
    }
  }

  Future<void> onInitializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.last; // Use the first available camera
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
    printLog("Camera Controller Dispose Success");
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

  Future<void> onSwitchCamera() async {
    printLog("Switch Normal Camera Method Calling....");

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
    // Get.back(); // Stop Loading...
  }
}
