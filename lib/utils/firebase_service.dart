import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/utils/utils.dart';
import '../firebase_options.dart';
import '../pages/bottombar.dart';
import '../pages/chatpage.dart';
import '../video_audio_call/ScheduleCall.dart';
import 'notification_service.dart';
import 'pusher_beams_service.dart';

class FirebaseService {
  late GlobalKey<NavigatorState> _navigatorKey;
  final notificationService = NotificationService();

  Future<void> initFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase initialized successfully");
    } catch (e) {
      print("Firebase Not initialized");
    }
  }

  // Firebase Messaging handlers removed - now using Pusher Beams
  // All notification handling is done in pusher_beams_service.dart

  void handleFirebaseEvents(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    // Firebase Messaging handlers removed - using Pusher Beams instead
    print('Firebase core initialized (for Auth/Storage only)');
  }

  Future<void> _handleNotificationNavigation(Map<String, dynamic> data) async {
    print("Notification tapped: $data");

    // Wait a frame to ensure navigator context is ready
    await Future.delayed(const Duration(milliseconds: 500));

    if (_navigatorKey.currentContext == null) {
      print("Navigator context still null!");
      return;
    }

    if (data['apptype'] == 'comment') {
      Utils.moveToDetail(
        _navigatorKey.currentContext!,
        0,
        false,
        data['content_id'] ?? "",
        false,
        '1',
      );
    } else if (data['apptype'] == 'chat') {
      final otherUserId = data['receiver_id']?.toString() ?? '';
      final otherUserName = data['receiver_name'] ?? '';
      final otherUserPic = data['receiver_image'] ?? '';
      final creatorId = data['receiver_is_creator'] ?? '0';

      Navigator.push(
        _navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            otherUserId: otherUserId,
            otherUserName: otherUserName,
            otherUserPic: otherUserPic,
            creatorId: creatorId,
          ),
        ),
      );
    } else if (data['apptype'] == 'schedule_reminder' ||
        data['apptype'] == 'schedule_video_call') {
      final otherUserId = data['receiver_id']?.toString() ?? '';
      Navigator.push(
        _navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => const ScheduleCall(
            isCreator: true,
          ),
        ),
      );
    } else {
      Navigator.push(
        _navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => const Bottombar(),
        ),
      );
    }
  }

  /// Get device token/identifier for push notifications
  /// For Pusher Beams, returns a placeholder indicating to use interests
  /// Backend should send to "notifications_{userId}" interest instead of device token
  static Future<String?> getDeviceToken() async {
    try {
      if (kIsWeb) {
        print('⚠️ Device token not available on web platform');
        return null;
      }

      // Pusher Beams uses interests, not tokens
      // Return indicator that interests are being used
      print('📱 Pusher Beams ready - using interest-based notifications');
      return 'pusher_beams'; // Indicate this device uses Pusher Beams
    } catch (e) {
      print('❌ Error initializing Pusher Beams: $e');
      return null;
    }
  }

  /// Setup user notifications (subscribe to user-specific interests)
  static Future<void> setupUserNotifications(String userId) async {
    try {
      if (kIsWeb) {
        print('⚠️ Notifications not available on web platform');
        return;
      }

      final service = PusherBeamsService();
      await service.setUserId(userId);
      print('✅ User notifications setup complete for $userId');
    } catch (e) {
      print('❌ Error setting up user notifications: $e');
    }
  }

  /// Wait for Firebase Auth to be initialized
  static Future<bool> waitForAuth() async {
    try {
      final auth = FirebaseAuth.instance;

      // If user is already signed in, return true immediately
      if (auth.currentUser != null) {
        print('✅ User already authenticated');
        return true;
      }

      // Wait for auth state changes with timeout
      final user = await auth
          .authStateChanges()
          .firstWhere(
            (user) => user != null,
            orElse: () => null,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => auth.currentUser,
          );

      final isReady = user != null;
      print('${isReady ? "✅" : "⚠️"} Auth ready: $isReady');
      return isReady;
    } catch (e) {
      print('❌ Error waiting for auth: $e');
      return false;
    }
  }

// DatabaseReference getDatabaseWithReference(ref) {
//   return FirebaseDatabase.instance.ref("$appEnv/$ref");
// }
}
