// incoming_call_dialog.dart
import 'package:flutter/material.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/video_audio_call/videocallmanager.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';

enum CallType { video, audio }

class IncomingCallDialog extends StatelessWidget {
  final String callerName;
  final String callerImage;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final String callType;

  const IncomingCallDialog({
    super.key,
    required this.callerName,
    required this.callerImage,
    required this.onAccept,
    required this.onReject,
    required this.callType,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyNetworkImage(
              imagePath: callerImage,
              width: 85,
              height: 85,
              fit: BoxFit.cover,
              shape: BoxShape.circle,
            ),
            const SizedBox(height: 16),
            MyText(
              text: 'Incoming ${callType == 'audio' ? 'Audio' : "Video"} Call',
              color: Colors.white,
              fontsizeNormal: 18,
              fontwaight: FontWeight.bold,
              multilanguage: false,
            ),
            const SizedBox(height: 8),
            MyText(
              text: callerName,
              color: Colors.white70,
              fontsizeNormal: 16,
              multilanguage: false,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reject button
                GestureDetector(
                  onTap: onReject,
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.call_end, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text('Reject',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                // Accept button
                GestureDetector(
                  onTap: onAccept,
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                            callType == 'audio' ? Icons.call : Icons.videocam,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text('Accept',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
