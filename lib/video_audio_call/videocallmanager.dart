import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import '../utils/constant.dart';
import '../webservice/socketmanager.dart';
import 'incomingcalldialog.dart';

class VideoCallManager extends ChangeNotifier {
  static final VideoCallManager _instance = VideoCallManager._internal();
  factory VideoCallManager() => _instance;
  VideoCallManager._internal() {
    initializeEngine();
  }

  // ✅ NEW: Call type variable
  CallType _currentCallType = CallType.video;

  // Existing call state variables
  String? _currentCallId;
  String? _callerId;
  String? _callerName;
  String? _callerImage;
  bool _isIncomingCall = false;
  Function(bool)? _onCallStateChange;
  bool _cameraEnabled = true;
  bool _isMinimized = false;
  bool get isMinimized => _isMinimized;
  bool _usingFrontCamera = true;
  String? _rejectReason;

  // Zego variables
  Widget? localView;
  int? localViewID;
  Widget? remoteView;
  int? remoteViewID;
  String roomId = "";
  String? _localUserID;
  String? _localStreamID;

  // Stream tracking
  final StreamController<bool> _remoteVideoController =
      StreamController<bool>.broadcast();
  Stream<bool> get remoteVideoAvailable => _remoteVideoController.stream;
  bool _isRemoteVideoReady = false;
  String? _remoteStreamID;
  Timer? _streamCheckTimer;
  bool isMuted = false;

  // Payment system variables
  double _currentBalance = 0.0;
  double _totalSpent = 0.0;
  int _callDurationMinutes = 0;
  final StreamController<Map<String, dynamic>> _paymentController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get paymentUpdates => _paymentController.stream;
  Timer? _paymentTimer;
  int _paymentRate = 2;

  bool _isSpeakerOn = false;

  // Engine initialization (same)
  Future<void> initializeEngine() async {
    if (kIsWeb) {
      debugPrint('⚠️ Zego Engine skipped on web platform');
      return;
    }

    final appId = Constant.liveAppId;
    final appSign = Constant.liveAppSign;
    if (appId == null || appSign == null || appSign.isEmpty) {
      debugPrint('⚠️ Zego Engine skipped due to missing credentials');
      return;
    }
    try {
      await ZegoExpressEngine.createEngineWithProfile(
        ZegoEngineProfile(
          appId,
          ZegoScenario.Default,
          appSign: appSign,
          enablePlatformView: true,
        ),
      );
      _setupEngineEventHandlers();
      debugPrint('✅ Zego Engine initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Zego Engine: $e');
    }
  }

  // ✅ NEW: Modified makeCall with call type parameter
  Future<void> makeCall({
    required String targetUserId,
    required String targetUserName,
    required String currentUserId,
    required String currentUserName,
    required String currentUserImage,
    required CallType callType,
  }) async {
    try {
      _currentCallType = callType;
      _currentCallId =
          '${callType.name}_call_${currentUserId}_${DateTime.now().millisecondsSinceEpoch}';
      roomId = _currentCallId!;
      _isIncomingCall = false;
      _localUserID = currentUserId;
      _localStreamID = 'stream_$currentUserId';

      debugPrint('📞 Making ${callType.name} call with roomId: $roomId');

      await initializeEngine();

      await _loginRoom(currentUserId, currentUserName);

      if (_currentCallType == CallType.video) {
        await _setupVideoCall();
      } else {
        await _setupAudioCall();
      }

      await _startPublishing();
      _startPaymentTimer();
      //setupPaymentListeners();
      if (_currentCallType == CallType.video) {
        print('callerId: $currentUserId');
        print('callerName: $currentUserName');
        print('callerImage: $currentUserImage');
        print('receiverId: $targetUserId');
        print('callId: $_currentCallId,');
        SocketManager().emitVideoCall(
          callerId: currentUserId,
          callerName: currentUserName,
          callerImage: currentUserImage,
          receiverId: targetUserId,
          callId: _currentCallId!,
        );
      } else {
        SocketManager().emitAudioCall(
          callerId: currentUserId,
          callerName: currentUserName,
          callerImage: currentUserImage,
          receiverId: targetUserId,
          callId: _currentCallId!,
        );
      }

      debugPrint('✅ ${callType.name} call setup completed');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error making ${_currentCallType.name} call: $e');
    }
  }

  Future<void> _setupVideoCall() async {
    await ZegoExpressEngine.instance.enableCamera(true);
    await Future.delayed(const Duration(milliseconds: 300));
    await _startPreview();
  }

  Future<void> _setupAudioCall() async {
    await ZegoExpressEngine.instance.enableCamera(false);
  }

  void handleIncomingCall({
    required String callId,
    required String callerId,
    required String callerName,
    required String callerImage,
    required Function(bool) onCallStateChange,
    CallType callType = CallType.video,
  }) {
    _currentCallId = callId;
    _callerId = callerId;
    _callerName = callerName;
    _callerImage = callerImage;
    _isIncomingCall = true;
    _currentCallType = callType;
    _onCallStateChange = onCallStateChange;
    roomId = callId;

    setupPaymentListeners();
    debugPrint('📞 Incoming ${callType.name} call with roomId: $roomId');
    notifyListeners();
  }

  Future<void> acceptCall(String userId, String userName) async {
    try {
      _localUserID = userId;
      _localStreamID = 'stream_$userId';

      await initializeEngine();

      await _loginRoom(userId, userName);
      if (_currentCallType == CallType.video) {
        await _setupVideoCall();
      } else {
        await _setupAudioCall();
      }

      await _startPublishing();
      _startPaymentTimer();

      _onCallStateChange?.call(true);
      SocketManager().emitCallAccepted(_currentCallId!);

      debugPrint('✅ ${_currentCallType.name} call accepted successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error accepting ${_currentCallType.name} call: $e');
    }
  }

  Future<void> toggleSpeaker() async {
    try {
      _isSpeakerOn = !_isSpeakerOn;
      await ZegoExpressEngine.instance.setAudioRouteToSpeaker(_isSpeakerOn);

      debugPrint('🔊 Speaker ${_isSpeakerOn ? 'ON' : 'OFF'}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error toggling speaker: $e');
    }
  }

  void _setupCallEndListeners() {
    final socket = SocketManager().socket;

    // 📴 Handle "call_ended" event
    socket?.on('call_ended', (data) {
      debugPrint('📴 call_ended received: ${data.runtimeType}');
      debugPrint('Data: $data');

      Map<String, dynamic>? callData;

      // Handle both Map and List formats
      if (data is List && data.isNotEmpty && data.first is Map) {
        callData = Map<String, dynamic>.from(data.first as Map);
      } else if (data is Map) {
        callData = Map<String, dynamic>.from(data);
      }

      if (callData != null) {
        final endedCallId = callData['call_id'];
        final message = callData['message'] ?? 'Call ended';
        debugPrint('📞 Remote call ended for: $endedCallId');

        _rejectReason = message;

        if (endedCallId == _currentCallId) {
          debugPrint('✅ This call was ended by remote user, cleaning up...');
          _cleanUpCall();
        }
      } else {
        debugPrint('⚠️ Unexpected call_ended data format: ${data.runtimeType}');
      }
    });

    // ❌ Handle "call_rejected" event
    socket?.on('call_rejected', (data) {
      debugPrint('📴 call_rejected received: ${data.runtimeType}');
      debugPrint('Data: $data');

      Map<String, dynamic>? callData;

      if (data is List && data.isNotEmpty && data.first is Map) {
        callData = Map<String, dynamic>.from(data.first as Map);
      } else if (data is Map) {
        callData = Map<String, dynamic>.from(data);
      }

      if (callData != null) {
        final rejectedCallId = callData['call_id'];
        final message = callData['message'] ?? 'Call rejected';
        debugPrint('📞 Call rejected by remote user for: $rejectedCallId');

        if (rejectedCallId == _currentCallId) {
          debugPrint('✅ This call was rejected by remote user, cleaning up...');
          _rejectReason = message;
          _cleanUpCall();
        }
      } else {
        debugPrint(
            '⚠️ Unexpected call_rejected data format: ${data.runtimeType}');
      }
    });
  }

  void setupConnectionListeners() {
    SocketManager().connectionStatus.listen((isConnected) {
      if (!isConnected) {
        debugPrint('⚠️ Connection lost during call');
      } else {
        debugPrint('✅ Connection restored during call');
      }
    });

    SocketManager().socket?.on('call_ended_ack', (data) {
      debugPrint('Call end acknowledgment: ${data['status']}');
      if (data['status'] == 'unauthorized') {
        debugPrint('❌ Need to reauthenticate socket');
        if (Constant.userID != null) {
          SocketManager().setUserId(Constant.userID!);
        }
      }
    });
  }

  void setupPaymentListeners() {
    _setupCallEndListeners();
    SocketManager().socket?.on('payment_system_started', (data) {
      final callType =
          data['call_type'] == 'audio' ? CallType.audio : CallType.video;
      _currentCallType = callType;

      _paymentRate = data['rate_per_minute'] ?? 2;
      _paymentController.add({
        'type': 'system_started',
        'message': data['message'],
        'rate': _paymentRate,
        'callType': callType,
      });
      notifyListeners();
    });

    // Payment processed
    SocketManager().socket?.on('payment_processed', (data) {
      print('eqwefnksjvcayfsfvcy');
      final callType =
          data['call_type'] == 'audio' ? CallType.audio : CallType.video;

      print('aadfdssfdfdsfsfsdass');
      print(data['balance']);
      print(data['total_amount']);
      print(data['minute']);
      print('aadfdssfdfdsfsfsdass');

      print('data[balance]: ${data['balance']}');
      print(data['total_amount']);
      print(data['minute']);

      _currentBalance = (data['balance'] as num).toDouble();
      _totalSpent = (data['total_amount'] as num).toDouble();
      _callDurationMinutes = data['minute'];

      _paymentController.add({
        'type': 'payment_processed',
        'amount': data['amount'],
        'type_detail': data['type'],
        'totalSpent': _totalSpent,
        'currentBalance': _currentBalance,
        'durationMinutes': _callDurationMinutes,
        'minute': data['minute'],
        'callType': callType, // ✅ Pass call type to UI
      });

      notifyListeners();
    });

    // Payment failed (same as before)
    SocketManager().socket?.on('payment_failed', (data) {
      _paymentController.add({
        'type': 'payment_failed',
        'reason': data['reason'],
        'message': data['message'],
        'currentBalance': data['current_balance'],
        'requiredAmount': data['required_amount']
      });
      notifyListeners();
    });
  }

  Future<void> _cleanUpCall() async {
    try {
      debugPrint('🧹 Cleaning up ${_currentCallType.name} call resources');

      _stopStreamCheckTimer();
      _stopPaymentTimer();

      if (_currentCallType == CallType.video) {
        await _stopPreview();
      }

      await _stopPublishing();

      if (_remoteStreamID != null) {
        await _stopPlayingStream(_remoteStreamID!);
      }

      if (roomId.isNotEmpty) {
        await ZegoExpressEngine.instance.logoutRoom(roomId);
      }

      _remoteStreamID = null;
      _localStreamID = null;
      _updateRemoteVideoReady(false);
      _currentCallId = null;
      _callerId = null;
      _callerName = null;
      _callerImage = null;
      _isIncomingCall = false;
      roomId = "";
      _localUserID = null;

      _currentBalance = 0.0;
      _totalSpent = 0.0;
      _callDurationMinutes = 0;

      _currentCallType = CallType.video;
      notifyListeners();
      debugPrint('✅ ${_currentCallType.name} call cleanup completed');
    } catch (e) {
      debugPrint('❌ Error during cleanup: $e');
    }
  }

  CallType get currentCallType => _currentCallType;
  bool get isVideoCall => _currentCallType == CallType.video;
  bool get isAudioCall => _currentCallType == CallType.audio;
  bool get isSpeakerOn => _isSpeakerOn;

  void _setupEngineEventHandlers() {
    ZegoExpressEngine.onRoomStateUpdate =
        (roomID, state, errorCode, extendedData) {
      debugPrint('Room state: $state, error: $errorCode, room: $roomID');

      if (state == ZegoRoomState.Connected) {
        debugPrint('✅ Successfully connected to room: $roomID');
        _startStreamCheckTimer();

        if (_currentCallType == CallType.audio) {
          ZegoExpressEngine.instance.setAudioRouteToSpeaker(true);
        }
      } else if (state == ZegoRoomState.Disconnected) {
        debugPrint('❌ Disconnected from room: $roomID');
        _stopStreamCheckTimer();
        _handleRoomDisconnected();
      }
    };

    ZegoExpressEngine.onAudioRouteChange = (audioRoute) {
      debugPrint('🎧 Audio route changed to: $audioRoute');
      if (_currentCallType == CallType.audio && audioRoute == 'Receiver') {
        ZegoExpressEngine.instance.setAudioRouteToSpeaker(true);
      }
    };

    ZegoExpressEngine.onCapturedSoundLevelUpdate = (soundLevel) {
      if (soundLevel > 0.1) {
        debugPrint('🎤 Microphone level: $soundLevel');
      }
    };

    ZegoExpressEngine.onRemoteSoundLevelUpdate = (soundLevelMap) {
      soundLevelMap.forEach((streamID, soundLevel) {
        if (soundLevel > 0.1) {
          debugPrint('🔊 Remote audio level for $streamID: $soundLevel');
        }
      });
    };

    ZegoExpressEngine.onRoomStreamUpdate =
        (roomID, updateType, List<ZegoStream> streamList, extendedData) {
      debugPrint(
          '🎥 Stream Update - room: $roomID, type: ${updateType.name}, streams: ${streamList.length}');

      for (final stream in streamList) {
        if (updateType == ZegoUpdateType.Add) {
          debugPrint(
              '✅ Stream added: ${stream.streamID} from user: ${stream.user.userID}');
          if (stream.user.userID != _localUserID) {
            _remoteStreamID = stream.streamID;
            _startPlayingStream(stream.streamID);
          }
        } else {
          debugPrint('❌ Stream removed: ${stream.streamID}');
          if (stream.streamID == _remoteStreamID) {
            _stopPlayingStream(stream.streamID);
            _remoteStreamID = null;
            _updateRemoteVideoReady(false);
          }
        }
      }
    };

    ZegoExpressEngine.onPlayerStateUpdate =
        (streamID, state, errorCode, extendedData) {
      debugPrint(
          '🎬 Player State - stream: $streamID, state: ${state.name}, error: $errorCode');

      if (state == ZegoPlayerState.Playing) {
        debugPrint('✅ Stream is now PLAYING');
        _updateRemoteVideoReady(true);

        if (_currentCallType == CallType.audio) {
          ZegoExpressEngine.instance.mutePlayStreamAudio(streamID, false);
        }
      } else if (state == ZegoPlayerState.NoPlay) {
        debugPrint('❌ Stream stopped');
        _updateRemoteVideoReady(false);
      }
    };
  }

  void _startPaymentTimer() {
    _paymentTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _callDurationMinutes = _totalSpent ~/ _paymentRate;
      notifyListeners();
    });
  }

  void _stopPaymentTimer() {
    _paymentTimer?.cancel();
    _paymentTimer = null;
  }

  void _updateRemoteVideoReady(bool isReady) {
    if (_isRemoteVideoReady != isReady) {
      _isRemoteVideoReady = isReady;
      _remoteVideoController.add(isReady);
      notifyListeners();
    }
  }

  void _startStreamCheckTimer() {
    _stopStreamCheckTimer();
    _streamCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_remoteStreamID != null && !_isRemoteVideoReady) {
        _updateRemoteVideoReady(true);
      }
    });
  }

  void _stopStreamCheckTimer() {
    _streamCheckTimer?.cancel();
    _streamCheckTimer = null;
  }

  void _handleRoomDisconnected() {
    _updateRemoteVideoReady(false);
    _remoteStreamID = null;
  }

  Future<void> rejectCall() async {
    try {
      SocketManager().emitCallRejected(_currentCallId!);
      _onCallStateChange?.call(false);
      await _cleanUpCall();
    } catch (e) {
      debugPrint('❌ Error rejecting call: $e');
    }
  }

  Future<void> endCall() async {
    try {
      SocketManager().emitCallEnded(_currentCallId!);
      _onCallStateChange?.call(false);
      await _cleanUpCall();
    } catch (e) {
      debugPrint('❌ Error ending call: $e');
    }
  }

  Future<ZegoRoomLoginResult> _loginRoom(String userId, String userName) async {
    try {
      final user = ZegoUser(userId, userName);
      final roomConfig = ZegoRoomConfig.defaultConfig()
        ..isUserStatusNotify = true;

      final loginResult = await ZegoExpressEngine.instance
          .loginRoom(roomId, user, config: roomConfig);
      return loginResult;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _startPreview() async {
    try {
      if (localViewID != null) return;

      // ✅ Add a small delay to ensure engine is fully initialized
      await Future.delayed(const Duration(milliseconds: 100));

      await ZegoExpressEngine.instance.createCanvasView((viewID) {
        localViewID = viewID;
        ZegoCanvas previewCanvas =
            ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);

        // ✅ Ensure camera is enabled before starting preview
        ZegoExpressEngine.instance.enableCamera(true).then((_) {
          ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
        });
      }).then((canvasViewWidget) {
        localView = canvasViewWidget;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('❌ Error starting preview: $e');
      // ✅ Retry once on failure
      await _retryStartPreview();
    }
  }

  Future<void> _retryStartPreview() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (localViewID == null) {
        await _startPreview();
      }
    } catch (e) {
      debugPrint('❌ Retry start preview failed: $e');
    }
  }

  Future<void> _stopPreview() async {
    try {
      ZegoExpressEngine.instance.stopPreview();
      if (localViewID != null) {
        await ZegoExpressEngine.instance.destroyCanvasView(localViewID!);
        localViewID = null;
        localView = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error stopping preview: $e');
    }
  }

  Future<void> _startPublishing() async {
    try {
      String streamID = _localStreamID ?? 'stream_${_localUserID}';

      // ✅ First ensure audio devices
      await ZegoExpressEngine.instance.muteMicrophone(false);
      await ZegoExpressEngine.instance.enableAudioCaptureDevice(true);

      // ✅ Handle camera state more carefully
      if (_currentCallType == CallType.audio) {
        await ZegoExpressEngine.instance.enableCamera(false);
      } else {
        // ✅ For video calls, ensure camera is properly enabled
        await ZegoExpressEngine.instance.enableCamera(true);

        // ✅ Add small delay before starting preview
        await Future.delayed(const Duration(milliseconds: 200));

        // ✅ Ensure preview is started before publishing
        if (localViewID == null) {
          await _startPreview();
        }
      }

      await ZegoExpressEngine.instance.startPublishingStream(streamID);

      // ✅ Post-publishing camera check for video calls
      if (_currentCallType == CallType.video) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(milliseconds: 1000));
          _checkAndFixCamera();
        });
      }
    } catch (e) {
      debugPrint('❌ Error starting publishing: $e');
    }
  }

  Future<void> _checkAndFixCamera() async {
    try {
      // ✅ Check if camera is working by toggling it
      await ZegoExpressEngine.instance.enableCamera(false);
      await Future.delayed(const Duration(milliseconds: 100));
      await ZegoExpressEngine.instance.enableCamera(true);
    } catch (e) {
      debugPrint('❌ Error checking/fixing camera: $e');
    }
  }

  Future<void> _stopPublishing() async {
    try {
      await ZegoExpressEngine.instance.stopPublishingStream();
    } catch (e) {
      debugPrint('❌ Error stopping publishing: $e');
    }
  }

  Future<void> _startPlayingStream(String streamID) async {
    try {
      debugPrint('🎬 Starting to play stream: $streamID');

      if (remoteViewID != null) {
        await _stopPlayingStream(streamID);
      }

      if (_currentCallType == CallType.video) {
        await ZegoExpressEngine.instance.createCanvasView((viewID) {
          remoteViewID = viewID;
          final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
          ZegoExpressEngine.instance
              .startPlayingStream(streamID, canvas: canvas);
        }).then((canvasViewWidget) {
          remoteView = canvasViewWidget;
          notifyListeners();
        });
      } else {
        await ZegoExpressEngine.instance.startPlayingStream(streamID);
        debugPrint('✅ Audio stream playing started');
      }

      await ZegoExpressEngine.instance.mutePlayStreamAudio(streamID, false);
    } catch (e) {
      debugPrint('❌ Error starting to play stream: $streamID - $e');
    }
  }

  Future<void> _stopPlayingStream(String streamID) async {
    try {
      if (streamID.isNotEmpty) {
        await ZegoExpressEngine.instance.stopPlayingStream(streamID);
      }
      if (remoteViewID != null) {
        await ZegoExpressEngine.instance.destroyCanvasView(remoteViewID!);
        remoteViewID = null;
        remoteView = null;
        _updateRemoteVideoReady(false);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error stopping playing stream: $e');
    }
  }

  Future<void> toggleCamera() async {
    try {
      _cameraEnabled = !_cameraEnabled;
      await ZegoExpressEngine.instance.enableCamera(_cameraEnabled);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error toggling camera: $e');
    }
  }

  void minimizeCall() {
    debugPrint("📱 Call minimized — keeping stream active.");
    // You can store a flag to indicate minimized state if needed
    _isMinimized = true;
    notifyListeners();
  }

  Future<void> toggleMicrophone() async {
    try {
      bool currentlyMuted =
          await ZegoExpressEngine.instance.isMicrophoneMuted();
      await ZegoExpressEngine.instance.muteMicrophone(!currentlyMuted);
      isMuted = !currentlyMuted;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error toggling microphone: $e');
    }
  }

  Future<void> switchCamera() async {
/*    if (_usingFrontCamera) {
      ZegoExpressEngine.instance.useFrontCamera(_usingFrontCamera);
      _usingFrontCamera = !_usingFrontCamera;
      ZegoExpressEngine.instance.useFrontCamera(_usingFrontCamera);
    } else {
      ZegoExpressEngine.instance.useFrontCamera(_usingFrontCamera);
      _usingFrontCamera = !_usingFrontCamera;
      ZegoExpressEngine.instance.useFrontCamera(_usingFrontCamera);
    }*/
    try {
      _usingFrontCamera = !_usingFrontCamera;
      await ZegoExpressEngine.instance.useFrontCamera(_usingFrontCamera);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error switching camera: $e');
    }
  }

  double get currentBalance => _currentBalance;
  double get totalSpent => _totalSpent;
  int get callDurationMinutes => _callDurationMinutes;
  int get paymentRate => _paymentRate;
  bool get isIncomingCall => _isIncomingCall;
  String? get callerId => _callerId;
  String? get callerName => _callerName;
  String? get callerImage => _callerImage;
  String? get currentCallId => _currentCallId;
  String? get rejectReason => _rejectReason;
  bool get isRemoteVideoReady => _isRemoteVideoReady;
}
