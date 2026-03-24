import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fanbae/livestream/livestreamprovider.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../main.dart';
import '../utils/color.dart';
import '../utils/dimens.dart';
import '../video_audio_call/incomingcalldialog.dart';
import '../video_audio_call/videocall.dart';
import '../video_audio_call/videocallmanager.dart';
import '../widget/mytext.dart';

class SocketManager {
  static SocketManager? _instance;
  io.Socket? _socket;
  bool _isCallDialogShowing = false;
  bool _isConnected = false;
  String? _currentUserId;
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionController.stream;

  factory SocketManager() {
    _instance ??= SocketManager._internal();
    return _instance!;
  }

  String socketUrl() {
    return Constant.socketUrl;
  }

  SocketManager._internal() {
    if (socketUrl().isEmpty) {
      debugPrint(
          "Socket URL is empty, please set the socket URL in Constant class.");
      return;
    }

    _socket = io.io(socketUrl(), <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': true,
      'timeout': 50000,
      'reconnection': true,
      'reconnectionAttempts': 9999,
      'reconnectionDelay': 1000,
      if (Constant.userID != null) 'query': {'user_id': Constant.userID},
    });

    socket?.on('connect', (_) {
      _isConnected = true;
      debugPrint('✅ Connected to server: ${_socket?.id}');
      _connectionController.add(true);
      if (_currentUserId != null) {
        _socket?.emit('join_user_room', {'user_id': _currentUserId});
        debugPrint('🔄 Re-authenticated user: $_currentUserId');
      }
    });

    socket?.onConnectError((data) {
      debugPrint('Connection Error Socket: $data');
    });

    socket?.onError((data) {
      debugPrint('Error: $data');
    });

    socket?.onDisconnect((_) {
      debugPrint('Disconnected from Socket.io server');
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket?.on('reconnect', (attempt) {
      _isConnected = true;
      debugPrint('🔄 Reconnected after $attempt attempts');
      _connectionController.add(true);
      // ✅ CRITICAL: Re-authenticate after reconnection
      if (_currentUserId != null) {
        _socket?.emit('join_user_room', {'user_id': _currentUserId});
      }
    });
  }

  void connectWithUserId(String userId) async {
    _currentUserId = userId;
    // Update Constant.userID immediately
    Constant.userID = userId;
    debugPrint('🚀 Connecting socket with immediate auth: $userId');
    // Disconnect existing socket if any
    _socket?.disconnect();
    // Connect with user_id immediately in query parameters
    _socket = io.io(
        socketUrl(),
        io.OptionBuilder()
            .setQuery(
                {'user_id': userId}) // ✅ CRITICAL: Send user_id immediately
            .setTransports(['websocket', 'polling'])
            .setTimeout(50)
            .enableAutoConnect()
            .build());
    // ✅ ALSO send quick_auth immediately after connection
    _socket?.onConnect((_) {
      _isConnected = true;
      debugPrint('✅ Connected to server, sending quick_auth: $userId');
      _socket?.emit('quick_auth', {'user_id': userId});
    });
    // Your existing other listeners...
    _socket?.on('disconnect', (_) {
      _isConnected = false;
      debugPrint('🔌 Disconnected from server');
    });
  }

  // ✅ ADD THIS METHOD: When app comes to foreground
  void onAppResume() {
    if (_socket != null && _currentUserId != null) {
      debugPrint('📱 App resumed - reauthenticating: $_currentUserId');
      _socket?.emit('quick_auth', {'user_id': _currentUserId});
    }
  }

/* ================================ Emit Methods ================================ */

  goLive(userId, roomId) async {
    socket?.emit('goLive', {
      "user_id": userId,
      "room_id": roomId,
    });
  }

  addView(userId, roomId) async {
    socket?.emit('addView', {
      "user_id": userId,
      "room_id": roomId,
    });
  }

  endLive(userId, roomId) {
    print('endLive :${socket?.connected}');
    print('endLive userId:$userId');
    print('endLive roomId:$roomId');
    socket?.emit('endLive', {
      "user_id": userId,
      "room_id": roomId,
    });
  }

  lessView(userId, roomId) {
    socket?.emit('lessView', {
      "user_id": userId,
      "room_id": roomId,
    });
  }

  sendGift(userId, roomId, giftId) {
    socket?.emit('sendGift', {
      "user_id": userId,
      "room_id": roomId,
      "gift_id": giftId,
    });
  }

  sendComment(userId, roomId, comment) {
    socket?.emit('liveChat', {
      "user_id": userId,
      "room_id": roomId,
      "comment": comment,
    });
  }

  setupPaymentListeners(VideoCallManager videoCallManager) {
    // Payment system started
    socket?.on('payment_system_started', (data) {
      debugPrint('💳 Payment system started: ${data['message']}');
    });

    // Payment processed
    socket?.on('payment_processed', (data) {
      debugPrint('💰 Payment processed: \$${data['amount']}');
    });

    // Payment failed
    socket?.on('payment_failed', (data) {
      debugPrint('❌ Payment failed: ${data['message']}');
    });
  }

/* ================================ Emit Methods (Send Data in Socket) ================================ */

  void emitVideoCall({
    required String callerId,
    required String callerName,
    required String callerImage,
    required String receiverId,
    required String callId,
  }) {
    socket?.emit('video_call', {
      'caller_id': callerId,
      'caller_name': callerName,
      'caller_image': callerImage,
      'receiver_id': receiverId,
      'call_id': callId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void emitAudioCall({
    required String callerId,
    required String callerName,
    required String callerImage,
    required String receiverId,
    required String callId,
  }) {
    socket?.emit('audio_call', {
      'caller_id': callerId,
      'caller_name': callerName,
      'caller_image': callerImage,
      'receiver_id': receiverId,
      'call_id': callId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void emitCallAccepted(String callId) {
    socket?.emit('call_accepted', {
      'call_id': callId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void emitCallRejected(String callId) {
    socket?.emit('call_rejected', {
      'call_id': callId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void emitCallEnded(String callId) {
    socket?.emit('call_ended', {
      'call_id': callId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

/* ================================ On Methods (Receive SocketData) ================================ */

  receiveGift({
    required LiveStreamProvider livestreamprovider,
  }) async {
    socket?.on('sendGiftToClient', (data) async {
      print("printse==sendGiftToClient");
      livestreamprovider.showGift(data: data, isFake: "0");
    });
  }

  receiveComment({
    required LiveStreamProvider livestreamprovider,
  }) async {
    socket?.on('liveChatToClient', (data) async {
      await livestreamprovider.storeComment(data: data);
    });
  }

  totalUserCount({
    required LiveStreamProvider livestreamprovider,
  }) async {
    socket?.on('addViewCountToClient', (data) async {
      await livestreamprovider.liveCountUpdate(data);
    });
  }

  roomDelete(roomId, callAction) {
    socket?.on('roomDeleted', (data) async {
      if (data["room_id"] == roomId) {
        callAction();
      }
    });
  }

// Add video call listeners
  void setupVideoCallListeners(
      BuildContext context, VideoCallManager videoCallManager) {
    print("aaaxxxxxxxxxxxxxxxxx");
    socket?.on('video_call', (data) {
      print("aaaaaaaadffeasfsef");
      print(data.runtimeType);
      print(data);
      print(data);

      if (data is Map<String, dynamic>) {
        print('object inside');

        videoCallManager.handleIncomingCall(
          callId: data['call_id'],
          callerId: data['caller_id'],
          callerName: data['caller_name'],
          callerImage: data['caller_image'],
          onCallStateChange: (isActive) {
            // Handle call state changes
          },
        );
        // Show incoming call dialog
        if (_isCallDialogShowing) {
          print('🔄 Call dialog already showing, ignoring duplicate');
          return;
        }
        _isCallDialogShowing = true;
        _showIncomingCallDialog(context, data, videoCallManager);
      }
    });
    print('object');
    socket?.on('audio_call', (data) {
      if (data is Map<String, dynamic>) {
        videoCallManager.handleIncomingCall(
          callId: data['call_id'],
          callerId: data['caller_id'],
          callerName: data['caller_name'],
          callerImage: data['caller_image'],
          onCallStateChange: (isActive) {},
          callType: CallType.audio, // ✅ Specify call type
        );
        if (_isCallDialogShowing) {
          print('🔄 Call dialog already showing, ignoring duplicate');
          return;
        }
        _isCallDialogShowing = true;
        _showIncomingCallDialog(context, data, videoCallManager);
      }
    });

    //call_auto_rejected
    _socket?.on('call_auto_rejected', (data) {
      debugPrint('⏰ Call auto-rejected: ${data['message']}');
      debugPrint('⏰ Call auto-rejecteddddddddddddddddddddddddddd');
      videoCallManager.endCall();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Call ended - no answer'),
          backgroundColor: Colors.orange,
        ),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });

    _socket?.on('call_auto_ended', (data) {
      debugPrint('⏰ Call auto-ended: ${data['message']}');
      debugPrint('⏰ Call auto-endeddddddddddddddddddddddddddd');
      videoCallManager.endCall();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });

    // Call accepted
    socket?.on('call_accepted', (data) {
      debugPrint('Call was accepted: $data');
    });

    // Call rejected
    socket?.on('call_rejected', (data) {
      videoCallManager.endCall();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Call was rejected')),
      );
    });

    // Call ended
    socket?.on('call_ended', (data) {
      videoCallManager.endCall();
    });
  }

  void _showIncomingCallDialog(BuildContext context, Map<String, dynamic> data,
      VideoCallManager videoCallManager) {
    final context = navigatorKey.currentContext; // use safe global context
    if (context == null) return;
    !ResponsiveHelper.isWeb(context)
        ? showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return IncomingCallDialog(
                callerName: data['caller_name'],
                callerImage: data['caller_image'],
                callType: data['call_type'],
                onAccept: () {
                  videoCallManager.acceptCall(
                    Constant.userID ?? '',
                    Constant.fullname ?? '',
                  );
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCall(
                            isCaller: false,
                            targetUserName: data['caller_name'],
                            targetUserImage: data['caller_image']),
                      ));
                },
                onReject: () {
                  Navigator.pop(context);
                  videoCallManager.rejectCall();
                },
              );
            },
          ).then((_) {
            _isCallDialogShowing = false;
          })
        : showDialog(
            context: context,
            barrierColor: transparent,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                insetPadding: const EdgeInsets.fromLTRB(50, 25, 50, 25),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                backgroundColor: colorPrimaryDark,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  constraints: const BoxConstraints(
                    minWidth: 230,
                    maxWidth: 375,
                    minHeight: 130,
                    maxHeight: 175,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MyText(
                        color: white,
                        text:
                            '${data['caller_name']} trying to call you please install/use mobile app for calls.',
                        multilanguage: false,
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textTitle,
                        fontsizeWeb: Dimens.textTitle,
                        fontwaight: FontWeight.w500,
                        maxline: 3,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          hoverColor: colorPrimary,
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                            margin: const EdgeInsets.all(1),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: buttonDisable,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: MyText(
                              color: white,
                              text: "Ok",
                              multilanguage: false,
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textDesc,
                              fontsizeWeb: Dimens.textDesc,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontwaight: FontWeight.w500,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
  }

  void setUserId(String userId) {
    _currentUserId = userId;
    debugPrint('👤 User ID set: $userId');
    if (_isConnected) {
      _socket?.emit('join_user_room', {'user_id': userId});
      _socket?.emit('quick_auth', {'user_id': userId});
    }
  }

/* ================================ Clear Socket ================================ */

  removeListner() async {
    socket?.off("liveChatToClient");
    socket?.off("liveChat");
    socket?.off("addViewCountToClient");
    socket?.off("sendGiftToClient");
  }

  /* ================================ Video Call Remove Listeners ================================ */
  removeIncomingCallListener(Function(dynamic) handler) {
    socket?.off('incomingCall', handler);
  }

  removeCallAcceptedListener(Function(dynamic) handler) {
    socket?.off('callAccepted', handler);
  }

  removeCallRejectedListener(Function(dynamic) handler) {
    socket?.off('callRejected', handler);
  }

  removeCallEndedListener(Function(dynamic) handler) {
    socket?.off('callEnded', handler);
  }

/* ================================ Clear Socket ================================ */

  io.Socket? get socket => _socket;

  bool get isConnected => _isConnected;
}
