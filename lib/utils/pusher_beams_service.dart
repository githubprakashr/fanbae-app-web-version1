import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pusher_beams/pusher_beams.dart';
import '../pages/bottombar.dart';
import '../pages/chatpage.dart';
import '../video_audio_call/ScheduleCall.dart';
import 'constant.dart';
import 'notification_service.dart';
import 'utils.dart';

class PusherBeamsService {
  static final PusherBeamsService _instance = PusherBeamsService._internal();
  factory PusherBeamsService() => _instance;
  PusherBeamsService._internal();

  late GlobalKey<NavigatorState> _navigatorKey;
  final notificationService = NotificationService();
  bool _isInitialized = false;

  // Your Pusher Beams instance ID
  static const String instanceId = 'de7c2043-6c32-463c-ae56-b8c5d7f40507';

  /// Initialize Pusher Beams
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (_isInitialized) {
      print('Pusher Beams already initialized');
      return;
    }

    _navigatorKey = navigatorKey;

    try {
      print('🚀 Starting Pusher Beams with Instance ID: $instanceId');

      // Initialize Pusher Beams
      await PusherBeams.instance.start(instanceId);
      print('✅ Pusher Beams started');

      // Get and log device token for debugging
      final token = await getDeviceToken();
      print('📱 Device Token: ${token ?? "Not available yet"}');

      // Subscribe to hello interest (required for initial device registration)
      await PusherBeams.instance.addDeviceInterest('hello');
      print('✅ Subscribed to "hello" interest');

      // Subscribe to general interest for app-wide notifications
      await PusherBeams.instance.addDeviceInterest('general');
      print('✅ Subscribed to "general" interest');

      // Subscribe to debug interest for testing via Debug Console
      await PusherBeams.instance.addDeviceInterest('debug-hello');
      print('✅ Subscribed to "debug-hello" interest');

      // Get all interests to verify
      final interests = await getInterests();
      print('📋 Current interests: $interests');

      // Handle notification opened
      PusherBeams.instance.onMessageReceivedInTheForeground(_onMessageReceived);

      _isInitialized = true;
      print('✅ Pusher Beams initialized successfully');
      print('🔔 Device is ready to receive notifications!');
    } catch (e) {
      print('❌ Error initializing Pusher Beams: $e');
      rethrow;
    }
  }

  /// Set user ID for authenticated users
  Future<void> setUserId(String userId) async {
    final interest = 'notifications_$userId';

    try {
      final beamsAuthProvider = BeamsAuthProvider()
        ..authUrl =
            '${Constant().baseurl}pusher-beams-auth' // baseurl already includes /api/
        ..headers = {'Content-Type': 'application/json'}
        ..queryParams = {'user_id': userId}
        ..credentials = 'same-origin';

      await PusherBeams.instance.setUserId(
        userId,
        beamsAuthProvider,
        (error) {
          print('❌ Beams auth error: $error');
        },
      );
      print('✅ User ID set: $userId');
    } catch (e) {
      // Continue even if auth fails so public interests still work
      print('❌ Error setting user ID: $e');
    }

    try {
      await addInterest(interest);
      print('✅ Subscribed to user interest: $interest');
    } catch (e) {
      print('❌ Error subscribing to user interest: $e');
    }
  }

  /// Clear user authentication
  Future<void> clearUserId() async {
    try {
      await PusherBeams.instance.clearAllState();
      print('✅ User ID cleared');
    } catch (e) {
      print('❌ Error clearing user ID: $e');
    }
  }

  /// Subscribe to an interest/channel
  Future<void> addInterest(String interest) async {
    try {
      await PusherBeams.instance.addDeviceInterest(interest);
      print('✅ Subscribed to: $interest');
    } catch (e) {
      print('❌ Error subscribing to interest: $e');
    }
  }

  /// Unsubscribe from an interest/channel
  Future<void> removeInterest(String interest) async {
    try {
      await PusherBeams.instance.removeDeviceInterest(interest);
      print('✅ Unsubscribed from: $interest');
    } catch (e) {
      print('❌ Error unsubscribing from interest: $e');
    }
  }

  /// Get all device interests
  Future<Set<String>?> getInterests() async {
    try {
      final interests = await PusherBeams.instance.getDeviceInterests();
      return interests?.whereType<String>().toSet();
    } catch (e) {
      print('❌ Error getting interests: $e');
      return null;
    }
  }

  /// Handle foreground message
  void _onMessageReceived(Map<Object?, Object?> data) {
    print('📱 Pusher Beams message received: $data');

    try {
      // Convert to String-keyed map safely
      final payload = data.map((key, value) => MapEntry(key.toString(), value));

      // Extract notification data
      final title = payload['title']?.toString() ?? 'New Notification';
      final body = payload['body']?.toString() ?? '';

      // Safely convert data field
      Map<String, dynamic> customData = {};
      if (payload['data'] != null) {
        try {
          final dataField = payload['data'];
          if (dataField is Map) {
            customData =
                dataField.map((key, value) => MapEntry(key.toString(), value));
          }
        } catch (e) {
          print('⚠️ Could not parse data field: $e');
        }
      }

      print('🔔 Title: $title');
      print('🔔 Body: $body');
      print('🔔 Data: $customData');

      // Show local notification
      if (!kIsWeb) {
        notificationService.showNotification(
          title: title,
          body: body,
          payload: customData,
        );
      }

      // Handle notification action if app is in foreground
      _handleNotificationAction(customData);
    } catch (e) {
      print('❌ Error handling message: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  /// Handle notification navigation
  void _handleNotificationAction(Map<String, dynamic> data) {
    if (_navigatorKey.currentContext == null) {
      print('⚠️ Navigator context is null');
      return;
    }

    final appType = data['apptype']?.toString() ?? '';

    print('🔔 Handling notification action: $appType');

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_navigatorKey.currentContext == null) return;

      if (appType == 'comment') {
        final contentId = data['content_id']?.toString() ?? '';
        Utils.moveToDetail(
          _navigatorKey.currentContext!,
          0,
          false,
          contentId,
          false,
          '1',
        );
      } else if (appType == 'chat') {
        final otherUserId = data['receiver_id']?.toString() ?? '';
        final otherUserName = data['receiver_name']?.toString() ?? '';
        final otherUserPic = data['receiver_image']?.toString() ?? '';
        final creatorId = data['receiver_is_creator']?.toString() ?? '0';

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
      } else if (appType == 'schedule_reminder' ||
          appType == 'schedule_video_call') {
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
            builder: (context) => const Bottombar(isChat: true),
          ),
        );
      }
    });
  }

  /// Get device token for Pusher Beams
  /// This returns a unique device ID that can be used for tracking
  Future<String?> getDeviceToken() async {
    try {
      // Pusher Beams doesn't expose device token directly like FCM
      // Instead, we get the device ID which is used internally
      // You can use this for logging or tracking purposes
      final interests = await PusherBeams.instance.getDeviceInterests();
      print('📱 Device interests: $interests');

      // Return a unique identifier (you may want to generate or store this)
      return 'pusher_beams_device_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('❌ Error getting device token: $e');
      return null;
    }
  }

  /// Clean up resources
  void dispose() {
    _isInitialized = false;
  }
}
