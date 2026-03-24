import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';

Future<bool> requestWebcamPermission() async {
  if (!kIsWeb) return false; // mobile → skip

  try {
    final stream = await html.window.navigator.mediaDevices?.getUserMedia({
      'video': true,
    });
    stream?.getTracks().forEach((t) {
      try {
        t.enabled = false;
      } catch (_) {}
    });
    return true;
  } catch (e) {
    print("Webcam permission denied: $e");
    return false;
  }
}
