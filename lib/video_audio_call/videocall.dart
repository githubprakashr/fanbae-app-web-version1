import 'package:flutter/material.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/video_audio_call/videocallmanager.dart';
import 'dart:async';
import 'package:pip/pip.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../livestream/golivepreviewprovider.dart';
import 'incomingcalldialog.dart';

class VideoCall extends StatefulWidget {
  final bool isCaller;
  final String targetUserName;
  final String targetUserImage;
  final CallType callType;

  const VideoCall({
    Key? key,
    required this.isCaller,
    required this.targetUserName,
    required this.targetUserImage,
    this.callType = CallType.video,
  }) : super(key: key);

  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late VideoCallManager _videoCallManager;
  StreamSubscription<bool>? _remoteVideoSubscription;
  StreamSubscription<Map<String, dynamic>>? _paymentSubscription;
  bool _isRemoteVideoAvailable = false;
  bool isLocalVideoAvailable = false;

  // Payment UI states
  String paymentStatus = 'Payment system active';
  Color paymentStatusColor = Colors.green;
  bool showPaymentWarning = false;
  late GoLivePreviewProvider goLivePreviewProvider;

  // Animation controllers
  late AnimationController _balanceAnimationController;
  late Animation<double> _balanceAnimation;
  String? _balanceChangeText;
  Color? _balanceChangeColor;
  bool _showBalanceChange = false;
  final _pip = Pip();
  bool _isPipActive = false;

// 🔥 Handle app lifecycle (background / foreground)
/*  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      debugPrint("🔕 App minimized, keeping call active...");
      // Don’t end call, just hide UI
    }
    if (state == AppLifecycleState.resumed) {
      debugPrint("📲 App resumed — call still active");
    }
  }*/
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint('📱 App lifecycle changed: $state');

    switch (state) {
      // App goes to background (home button or app switcher)
      case AppLifecycleState.paused:
        debugPrint('🟥 App moved to background → ending call');
        _videoCallManager.endCall();
        break;

      // App is being killed
      case AppLifecycleState.detached:
        debugPrint('💀 App is being terminated → ending call');
        _videoCallManager.endCall();
        break;

      // Foreground
      case AppLifecycleState.resumed:
        debugPrint('🟩 App resumed → continue call');
        break;

      // Temporary interruptions like PiP, notification overlay, etc.
      case AppLifecycleState.inactive:
        debugPrint('🟨 App inactive → do nothing');
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    WidgetsBinding.instance.addObserver(this);
    _videoCallManager = Provider.of<VideoCallManager>(context, listen: false);
    goLivePreviewProvider =
        Provider.of<GoLivePreviewProvider>(context, listen: false);

    _balanceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _balanceAnimation = CurvedAnimation(
      parent: _balanceAnimationController,
      curve: Curves.easeInOut,
    );
    _pip.registerStateChangedObserver(
      PipStateChangedObserver(
        onPipStateChanged: (state, error) {
          setState(() {
            _isPipActive = (state == PipState.pipStateStarted);
          });
        },
      ),
    );

    _initializeVideoCall();
    _setupPaymentListeners();
    _setupCallEndListener();
  }

  void _setupCallEndListener() {
    _videoCallManager.addListener(() {
      if (_videoCallManager.currentCallId == null && mounted) {
        if (_videoCallManager.rejectReason != null) {
          Utils().showSnackBar(context, _videoCallManager.rejectReason!, false);
        }
        debugPrint('📞 Call ended, navigating back...');
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });
  }

  void _initializeVideoCall() {
    goLivePreviewProvider.onRequestPermissions();
    debugPrint('Initializing ${widget.callType.name} call UI');

    _remoteVideoSubscription =
        _videoCallManager.remoteVideoAvailable.listen((isAvailable) {
      if (mounted) {
        setState(() {
          _isRemoteVideoAvailable = isAvailable;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isRemoteVideoAvailable = _videoCallManager.isRemoteVideoReady;
        });
      }
    });
  }

  void _setupPaymentListeners() {
    _paymentSubscription =
        _videoCallManager.paymentUpdates.listen((paymentData) {
      if (mounted) {
        setState(() {
          _handlePaymentUpdate(paymentData);
        });
      }
    });
  }

  void _handlePaymentUpdate(Map<String, dynamic> paymentData) {
    final callType =
        paymentData['callType'] == CallType.audio ? 'audio' : 'video';

    switch (paymentData['type']) {
      case 'payment_processed':
        final amount = paymentData['amount']?.toDouble() ?? 0.0;
        final paymentType = paymentData['type_detail'];

        _showBalanceChangeAnimation(amount, paymentType);

        paymentStatus =
            'Paid \$${amount.toStringAsFixed(2)} for $callType call minute ${paymentData['minute']}';
        paymentStatusColor = Colors.green;
        showPaymentWarning = false;
        break;

      case 'payment_failed':
        paymentStatus =
            '${callType.capitalize()} call payment failed: ${paymentData['message']}';
        paymentStatusColor = Colors.red;
        showPaymentWarning = true;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${callType.capitalize()} call payment failed: ${paymentData['message']}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        break;

      case 'system_started':
        paymentStatus =
            '${callType.capitalize()} call payment active - \$${paymentData['rate']}/min';
        paymentStatusColor = Colors.blue;
        showPaymentWarning = false;
        break;
    }
  }

  void _showBalanceChangeAnimation(double amount, String type) {
    if (type == 'deduction') {
      _balanceChangeText = '-${amount.toStringAsFixed(2)}';
      _balanceChangeColor = Colors.red;
    } else if (type == 'addition') {
      _balanceChangeText = '+${amount.toStringAsFixed(2)}';
      _balanceChangeColor = Colors.green;
    } else {
      _balanceChangeText = '';
      _balanceChangeColor = Colors.transparent;
    }

    _balanceAnimationController.reset();
    if (type == 'deduction' || type == 'addition') {
      setState(() {
        _showBalanceChange = true;
      });
    }

    _balanceAnimationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showBalanceChange = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _remoteVideoSubscription?.cancel();
    _paymentSubscription?.cancel();
    _balanceAnimationController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _videoCallManager.isAudioCall
                ? _buildAudioCallBackground()
                : _buildRemoteVideo(),

            if (_videoCallManager.isVideoCall) _buildLocalPreview(),

            if (!_isPipActive) _buildCallControls(),

            _buildPaymentInfo(),

            /* _buildCallControls(),*/

            // Balance change animation
            if (_showBalanceChange) _buildBalanceChangeAnimation(),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioCallBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple[800]!, Colors.black],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(widget.targetUserImage),
            ),
            const SizedBox(height: 20),
            Text(
              widget.targetUserName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Audio Call',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<bool>(
              stream: _videoCallManager.remoteVideoAvailable,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data == true ? 'Connected' : 'Connecting...',
                  style: TextStyle(
                    color: snapshot.data == true ? Colors.green : Colors.orange,
                    fontSize: 16,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: _videoCallManager.isAudioCall
          ? _buildAudioControls()
          : _buildVideoControls(),
    );
  }

  Widget _buildAudioControls() {
    return Column(
      children: [
        Text(
          '${_videoCallManager.callDurationMinutes} min',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),

        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Microphone
            _buildControlButton(
              icon: _videoCallManager.isMuted ? Icons.mic_off : Icons.mic,
              label: _videoCallManager.isMuted ? 'Unmute' : 'Mute',
              backgroundColor: Colors.black.withOpacity(0.4),
              onPressed: () async {
                // If toggleMicrophone is async, await it. If not, this still works.
                final result = _videoCallManager.toggleMicrophone();
                await result;
                setState(() {});
              },
            ),

            // End call
            _buildControlButton(
              icon: Icons.call_end,
              label: 'End',
              backgroundColor: Colors.red,
              isLarge: true,
              onPressed: () {
                _videoCallManager.endCall();
                // Navigator.pop(context);
              },
            ),

            // Speaker
            _buildControlButton(
              icon: _videoCallManager.isSpeakerOn
                  ? Icons.volume_up
                  : Icons.volume_off,
              label: _videoCallManager.isSpeakerOn ? 'Speaker' : 'Earpiece',
              backgroundColor: Colors.black.withOpacity(0.4),
              onPressed: () async {
                final result = _videoCallManager.toggleSpeaker();
                await result;
                setState(() {});
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _buildVideoControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: _videoCallManager.isMuted ? Icons.mic_off : Icons.mic,
          label: _videoCallManager.isMuted ? 'Unmute' : 'Mute',
          backgroundColor: Colors.black.withOpacity(0.4),
          onPressed: () async {
            // If toggleMicrophone is async, await it. If not, this still works.
            final result = _videoCallManager.toggleMicrophone();
            await result;
            setState(() {});
          },
        ),

        // End call
        _buildControlButton(
          icon: Icons.call_end,
          label: 'End',
          backgroundColor: Colors.red,
          isLarge: true,
          onPressed: () {
            _videoCallManager.endCall();
            Navigator.pop(context);
          },
        ),
        /*_buildControlButton(
          icon: _videoCallManager.isMuted ? Icons.mic_off : Icons.mic,
          backgroundColor: Colors.black.withOpacity(0.4),
          onPressed: () {
            setState(() {
              _videoCallManager.toggleMicrophone();
            });
          },
        ),
        _buildControlButton(
          icon: Icons.call_end,
          backgroundColor: Colors.red,
          isLarge: true,
          onPressed: () {
            _videoCallManager.endCall();
            Navigator.pop(context);
          },
        ),*/
        Consumer<VideoCallManager>(builder: (context, videoManager, child) {
          return _buildControlButton(
            icon: Icons.cameraswitch,
            backgroundColor: Colors.black.withOpacity(0.4),
            onPressed: () async {
              final result = _videoCallManager.switchCamera();
              await result;
              setState(() {});
            },
          );
        }),

        _buildControlButton(
          icon: _videoCallManager.isSpeakerOn
              ? Icons.volume_up
              : Icons.volume_off,
          label: _videoCallManager.isSpeakerOn ? 'Speaker' : 'Earpiece',
          backgroundColor: Colors.black.withOpacity(0.4),
          onPressed: () async {
            final result = _videoCallManager.toggleSpeaker();
            await result;
            setState(() {});
          },
        )
        // ✅ New minimize button (manual PiP)
/*        _buildControlButton(
          icon: Icons.picture_in_picture_alt,
          backgroundColor: Colors.black.withOpacity(0.4),
          onPressed: () async {
            final canPip = await _pip.isSupported();
            if (canPip) {
              const options = PipOptions(
                autoEnterEnabled: true,
                aspectRatioX: 16,
                aspectRatioY: 9,
              );
              await _pip.setup(options);
              await _pip.start();
              setState(() => _isVideoPaused = true);
            }
          },
        )*/
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    Color backgroundColor = Colors.white24,
    required VoidCallback onPressed,
    String? label, // ✅ NEW: Optional label for audio calls
    bool isLarge = false,
  }) {
    if (_videoCallManager.isAudioCall && label != null) {
      // Audio call layout with label
      return Column(
        children: [
          GestureDetector(
            onTap: onPressed,
            child: CircleAvatar(
              radius: isLarge ? 35 : 30,
              backgroundColor: backgroundColor,
              child: Icon(icon, color: Colors.white, size: isLarge ? 30 : 25),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      );
    } else {
      return GestureDetector(
        onTap: onPressed,
        child: CircleAvatar(
          radius: isLarge ? 35 : 30,
          backgroundColor: backgroundColor,
          child: Icon(icon, color: Colors.white, size: isLarge ? 30 : 25),
        ),
      );
    }
  }

  Widget _buildBalanceChangeAnimation() {
    return Positioned(
      top: 140, // Adjust position as needed
      left: 20,
      child: AnimatedBuilder(
        animation: _balanceAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _balanceAnimation.value,
            child: Transform.translate(
              offset: Offset(0, -20 * (1 - _balanceAnimation.value)),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyImage(
                        width: 17,
                        height: 17,
                        imagePath: "ic_coin.png",
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _balanceChangeText ?? '',
                        style: TextStyle(
                          color: _balanceChangeColor ?? Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRemoteVideo() {
    if (_isRemoteVideoAvailable && _videoCallManager.remoteView != null) {
      return Positioned.fill(child: _videoCallManager.remoteView!);
    } else {
      return Positioned.fill(
        child: Container(
          color: Colors.grey[900],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(widget.targetUserImage),
              ),
              const SizedBox(height: 20),
              Text(
                widget.targetUserName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _isRemoteVideoAvailable ? 'Connected' : 'Waiting for video...',
                style: const TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 20),
              if (!_isRemoteVideoAvailable) ...[
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  'Establishing connection...',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      );
    }
  }

  Widget _buildLocalPreview() {
    if (_videoCallManager.localView != null) {
      return Positioned(
        top: 60,
        right: 20,
        width: 120,
        height: 160,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 8,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _videoCallManager.localView!,
          ),
        ),
      );
    } else {
      return Positioned(
        top: 60,
        right: 20,
        width: 120,
        height: 160,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white54, width: 1),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, color: Colors.white54, size: 40),
              SizedBox(height: 8),
              Text('No Camera',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildPaymentInfo() {
    return Positioned(
      top: 70,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Information
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyImage(width: 16, height: 16, imagePath: "ic_coin.png"),
                  const SizedBox(width: 6),
                  Text(
                    _videoCallManager.currentBalance.toStringAsFixed(2),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            _buildPaymentRow(
              Icons.timer,
              '${_videoCallManager.callDurationMinutes} min',
              Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
