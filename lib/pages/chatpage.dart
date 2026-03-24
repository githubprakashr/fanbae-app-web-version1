import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fanbae/pages/profile.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:fanbae/video_audio_call/ScheduleCall.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fanbae/model/getchatdata.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:visibility_detector/visibility_detector.dart';

import '../provider/detailsprovider.dart';
import '../subscription/adspackage.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/firebase_service.dart';
import '../utils/utils.dart';
import '../webpages/webprofile.dart';
import '../widget/myimage.dart';
import 'chatmessagevideo.dart';
import 'mediaPreviewPage.dart';

enum ChatApprovalStatus { pending, approved, blocked }

class ChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String otherUserPic;
  final String creatorId;

  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPic,
    required this.creatorId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final _realtimeDB = FirebaseDatabase.instance;
  final ScrollController _scrollController = ScrollController();
  late String currentUserId;
  late String chatId;
  late DetailsProvider detailsProvider;
  Result? chatData;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final VoiceRecorder _voiceRecorder = VoiceRecorder();
  StreamSubscription<RecordingState>? _recordingSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<DatabaseEvent>? _metaSubscription;
  bool loading = false;

  late String receiverToken = '';
  bool isInitial = true;
  ChatApprovalStatus chatStatus = ChatApprovalStatus.pending;
  String? blockedBy;
  String? lastMessage;

  @override
  void initState() {
    _initAudioPlayer();
    detailsProvider = Provider.of<DetailsProvider>(context, listen: false);

    _recordingSubscription = _voiceRecorder.recordingState.listen((state) {
      if (mounted) {
        setState(() {});
      }
    });
    currentUserId = Constant.userID ?? '';

    if (currentUserId.isEmpty) {
      debugPrint('⚠️ ERROR: currentUserId is empty!');
    }

    debugPrint('UserId :${Constant.userID}');
    debugPrint('currentUserId :$currentUserId');
    debugPrint('widget.otherUserId :${widget.otherUserId}');
    chatId = _getChatId(currentUserId, widget.otherUserId);
    debugPrint('chatID after :$chatId');

    // Wait for Firebase Auth before accessing database
    _initializeChat();

    super.initState();
  }

  Future<void> _initializeChat() async {
    debugPrint('⏳ Waiting for Firebase Auth...');
    final authReady = await FirebaseService.waitForAuth();

    if (!authReady) {
      debugPrint('⚠️ Firebase Auth not ready yet, proceeding anyway...');
    } else {
      debugPrint('✅ Firebase Auth ready, initializing chat');
    }

    _getUserFCMToken(widget.otherUserId);
    getChatData();
  }

  void _initAudioPlayer() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _recordingSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _metaSubscription?.cancel();
    _voiceRecorder.dispose();
    super.dispose();
  }

  Future<void> _uploadAndSendVoiceNote(String filePath) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
      final ref =
          FirebaseStorage.instance.ref().child('voice_notes/$chatId/$fileName');

      final uploadTask = ref.putFile(File(filePath));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await sendMessage(
        mediaUrl: downloadUrl,
        mediaType: "audio",
      );
    } catch (e) {
      debugPrint('Error uploading voice note: $e');
      if (mounted) {
        Utils().showSnackBar(context, 'Failed to upload voice note.', false);
      }
    }
  }

  Future<void> _playVoiceNote(String url) async {
    try {
      await _audioPlayer.stop();

      final mediaItem = MediaItem(
        id: url,
        album: "Voice Notes",
        title: "Voice Message",
      );

      final tempDir = await getTemporaryDirectory();
      final fileName = url.split('/').last;
      final cacheFile = File('${tempDir.path}/$fileName');

      if (await cacheFile.exists() && await cacheFile.length() > 0) {
        debugPrint('Playing from cache: ${cacheFile.path}');
        await _audioPlayer.setAudioSource(
          AudioSource.uri(
            Uri.file(cacheFile.path),
            tag: mediaItem,
          ),
        );
      } else {
        debugPrint('Downloading audio file: $url');
        if (!await cacheFile.parent.exists()) {
          await cacheFile.parent.create(recursive: true);
        }

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await cacheFile.writeAsBytes(response.bodyBytes);
          debugPrint('File saved to: ${cacheFile.path}');

          await _audioPlayer.setAudioSource(
            AudioSource.uri(
              Uri.file(cacheFile.path),
              tag: mediaItem,
            ),
          );
        } else {
          throw Exception('Failed to download audio file');
        }
      }

      await _audioPlayer.play();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Audio Playback Error: $e');
      if (mounted) {
        Utils().showSnackBar(context, 'Failed to play voice note', false);
      }
      if (!_audioPlayer.playing) {
        await _playFromUrlDirectly(url);
      }
    }
  }

  Future<void> _playFromUrlDirectly(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            album: "Voice Notes",
            title: "Voice Message",
          ),
        ),
      );
      await _audioPlayer.play();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Direct URL playback failed: $e');
      if (mounted) {
        Utils().showSnackBar(context, 'Unable to play audio.', false);
      }
    }
  }

  _getUserFCMToken(String receiverId) async {
    try {
      final tokenSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .get();

      if (tokenSnap.exists && tokenSnap.data() != null) {
        receiverToken = tokenSnap.data()?['fcmToken'] ?? '';
        debugPrint(
            '✅ Receiver FCM Token: ${receiverToken.isNotEmpty ? "Found" : "Empty"}');
      } else {
        debugPrint('⚠️ No user document found for receiverId: $receiverId');
        receiverToken = '';
      }
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      receiverToken = '';
    }
  }

  Future<void> _sendVoiceNote() async {
    final path = await _voiceRecorder.stopRecording();
    if (path != null) {
      await _uploadAndSendVoiceNote(path);
    }
    setState(() {});
  }

  void _scrollToBottom() {
    if (isInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        setState(() {
          isInitial = false;
        });
      });
    }
  }

  String _getChatId(String user1, String user2) {
    try {
      final sorted = [int.parse(user1), int.parse(user2)]..sort();
      return 'chat_${sorted[0]}_${sorted[1]}';
    } catch (e) {
      debugPrint('❌ Error generating chatId: $e');
      // Fallback to string-based sorting if IDs are not integers
      final sorted = [user1, user2]..sort();
      return 'chat_${sorted[0]}_${sorted[1]}';
    }
  }

  Future<void> getChatData() async {
    try {
      setState(() {
        loading = true;
      });
      GetChatData data =
          await ApiService().getChatData(currentUserId, widget.otherUserId);

      if (mounted && data.status == 200) {
        setState(() {
          chatData = data.result;
        });
      }

      await _metaSubscription?.cancel();

      _metaSubscription =
          _realtimeDB.ref('chats/$chatId/meta').onValue.listen((event) {
        if (!mounted) return; // Prevent setState after dispose

        if (event.snapshot.value != null) {
          final meta = Map<String, dynamic>.from(event.snapshot.value as Map);

          setState(() {
            final statusStr = meta['status']?.toString() ?? 'pending';

            chatStatus = ChatApprovalStatus.values.firstWhere(
              (e) => e.toString().split('.').last == statusStr,
              orElse: () => ChatApprovalStatus.pending,
            );

            blockedBy = meta['blockedBy']?.toString();
          });
        }
      });
      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint("getChatData error: $e");
    }
  }

  Future<void> sendMessage({
    String? text,
    String? mediaUrl,
    String? mediaType,
  }) async {
    // Validate message before processing
    if ((text == null || text.trim().isEmpty) && mediaUrl == null) return;

    // Validate user IDs
    if (currentUserId.isEmpty || widget.otherUserId.isEmpty) {
      debugPrint('❌ Cannot send message: Invalid user IDs');
      if (mounted) {
        Utils().showSnackBar(
            context, 'Cannot send message: User not logged in', false);
      }
      return;
    }

    final messageText = text?.trim() ?? '';
    final messageRef = _realtimeDB.ref('chats/$chatId/messages').push();

    // Clear the text field immediately for better UX
    _controller.clear();

    try {
      debugPrint(
          '📤 Sending message from $currentUserId to ${widget.otherUserId}');

      // Send to Firebase RTDB first (faster, immediate feedback)
      try {
        await messageRef.set({
          'senderId': currentUserId,
          'receiverId': widget.otherUserId,
          'message': messageText,
          'mediaUrl': mediaUrl,
          'mediaType': mediaType ?? "text",
          'is_read': 0,
          'timestamp': ServerValue.timestamp,
        });
        debugPrint('✅ Message saved to Firebase RTDB');
      } catch (dbError) {
        debugPrint('❌ Firebase RTDB write error: $dbError');
        if (mounted) {
          Utils().showSnackBar(
            context,
            dbError.toString().contains('permission')
                ? 'Permission denied. Check Firebase database rules.'
                : 'Failed to save message to database',
            false,
          );
        }
        return;
      }

      // Update metadata
      try {
        final chatMetaRef = _realtimeDB.ref('chats/$chatId/meta');
        final metaSnap = await chatMetaRef.get();

        if (!metaSnap.exists) {
          await chatMetaRef.set({
            'status': 'pending',
            'createdBy': currentUserId,
            'otherUser': widget.otherUserId,
            'lastMessage':
                messageText.isEmpty ? (mediaType ?? "media") : messageText,
            'lastTimestamp': ServerValue.timestamp,
            'blockedBy': null,
          });
        } else {
          await chatMetaRef.update({
            'lastMessage':
                messageText.isEmpty ? (mediaType ?? "media") : messageText,
            'lastTimestamp': ServerValue.timestamp,
          });
        }
        debugPrint('✅ Chat metadata updated');
      } catch (metaError) {
        debugPrint('⚠️ Failed to update metadata: $metaError');
        // Don't fail the whole operation if metadata update fails
      }

      // Call API in background without blocking UI
      ApiService()
          .sendChatMessage(
        currentUserId,
        widget.otherUserId,
        receiverToken,
        messageText,
        mediaType ?? "text",
      )
          .then((sent) {
        debugPrint('📬 API Response: ${sent.status} - ${sent.message}');
        if (sent.status != 200) {
          debugPrint('⚠️ API returned status ${sent.status}: ${sent.message}');
        }
      }).catchError((e) {
        debugPrint("⚠️ API error (non-blocking): $e");
      });

      debugPrint('✅ Message sent successfully');
    } catch (e) {
      debugPrint("❌ Error sending message: $e");
      debugPrint("Stack trace: ${StackTrace.current}");
      if (mounted) {
        String errorMsg = 'Failed to send message';
        if (e.toString().contains('permission')) {
          errorMsg = 'Permission denied. Check Firebase rules.';
        } else if (e.toString().contains('network')) {
          errorMsg = 'Network error. Check your connection.';
        } else if (e.toString().contains('DioException') ||
            e.toString().contains('DioError')) {
          errorMsg = 'Server error. Please try again.';
        }
        Utils().showSnackBar(context, errorMsg, false);
      }
    }
  }

  Future<void> pickAndUploadMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'mp4',
        'mov',
        'avi',
        'mkv'
      ],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final ref =
        FirebaseStorage.instance.ref().child('chat_media/$chatId/$fileName');

    final isImage = ['.jpg', '.jpeg', '.png', '.gif', '.webp']
        .any((ext) => file.name.toLowerCase().endsWith(ext));

    UploadTask uploadTask;
    if (file.bytes != null) {
      uploadTask = ref.putData(file.bytes!);
    } else {
      uploadTask = ref.putFile(File(file.path!));
    }

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    await sendMessage(
      mediaUrl: downloadUrl,
      mediaType: isImage ? "image" : "video",
    );
  }

  Future<void> _toggleRecording() async {
    if (_voiceRecorder.isRecording) {
      await _sendVoiceNote();
    } else {
      await _voiceRecorder.startRecording();
    }
  }

  Widget _buildMessageItem(Map msg, String messageId) {
    final isMe = msg['senderId'] == currentUserId;
    final isRead = msg['is_read'] == 1;
    final message = msg['message'] ?? '';
    final mediaUrl = msg['mediaUrl'];
    final mediaType = msg['mediaType'];
    final isCurrentAudio = _audioPlayer.currentIndex != null &&
        (_audioPlayer.sequence?[_audioPlayer.currentIndex!].tag as MediaItem?)
                ?.id ==
            mediaUrl;

    double maxBubbleWidth = MediaQuery.of(context).size.width * 0.65;
    final textDirection = Directionality.of(context);
    // --- Measure text width ---
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: message,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      maxLines: 10,
      textDirection: textDirection,
    )..layout(maxWidth: maxBubbleWidth);

    bool isOneLine = textPainter.didExceedMaxLines == false &&
        textPainter.size.height <= 25; // approx 1 line height

    return VisibilityDetector(
      key: Key(messageId),
      onVisibilityChanged: (info) {
        if (!isMe && !isRead && info.visibleFraction > 0.5) {
          final Map<String, Object?> update = {'is_read': 1};
          _realtimeDB
              .ref()
              .child('chats/$chatId/messages/$messageId')
              .update(update);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.73,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xff2662D3)
                      : Constant.darkMode == "true"
                          ? const Color(0xff343142)
                          : const Color(0xffD8D8DB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (mediaUrl != null)
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: mediaType == 'image'
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MediaPreviewPage(
                                          mediaType: mediaType,
                                          mediaUrl: mediaUrl,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        clipBehavior: Clip.hardEdge,
                                        margin: const EdgeInsets.all(4.5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Image.network(
                                          mediaUrl,
                                          width: 220,
                                          height: 136,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        right: 13,
                                        child: Row(
                                          children: [
                                            Text(
                                              Utils().formatTimestamp(
                                                  msg["timestamp"]),
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xffD2D2D2),
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            if (isMe)
                                              Icon(
                                                isRead
                                                    ? Icons.done_all
                                                    : Icons.done,
                                                size: 13.6,
                                                color: isRead
                                                    ? pureWhite
                                                    : Colors.grey,
                                              ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : mediaType == 'video'
                                  ? GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MediaPreviewPage(
                                              mediaType: mediaType,
                                              mediaUrl: mediaUrl,
                                            ),
                                          ),
                                        );
                                      },
                                      child: VideoMessagePlayer(
                                        videoUrl: mediaUrl,
                                        timeStamp: msg["timestamp"],
                                        isRead: isRead,
                                        isMe: isMe,
                                      ))
                                  : mediaType == 'audio'
                                      ? GestureDetector(
                                          onTap: () {
                                            if (_audioPlayer.playing) {
                                              _audioPlayer.stop();
                                            } else {
                                              _playVoiceNote(mediaUrl);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    StreamBuilder<PlayerState>(
                                                      stream: _audioPlayer
                                                          .playerStateStream,
                                                      builder:
                                                          (context, snapshot) {
                                                        final playerState =
                                                            snapshot.data;
                                                        final isPlaying =
                                                            playerState
                                                                    ?.playing ??
                                                                false;
                                                        return Icon(
                                                          isPlaying &&
                                                                  isCurrentAudio
                                                              ? Icons.pause
                                                              : Icons
                                                                  .play_arrow,
                                                          color: !isMe &&
                                                                  Constant.darkMode !=
                                                                      "true"
                                                              ? pureBlack
                                                              : pureWhite,
                                                          size: 20,
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    MyText(
                                                      text: 'Voice message',
                                                      color: !isMe &&
                                                              Constant.darkMode !=
                                                                  "true"
                                                          ? pureBlack
                                                          : pureWhite,
                                                      multilanguage: false,
                                                      fontwaight:
                                                          FontWeight.w500,
                                                    ),
                                                    if (isCurrentAudio)
                                                      StreamBuilder<Duration>(
                                                        stream: _audioPlayer
                                                            .positionStream,
                                                        builder: (context,
                                                            snapshot) {
                                                          final position =
                                                              snapshot.data ??
                                                                  Duration.zero;
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8.0),
                                                            child: MyText(
                                                              text:
                                                                  '${position.inSeconds}s',
                                                              color: Colors
                                                                  .white70,
                                                              multilanguage:
                                                                  false,
                                                              fontsizeNormal:
                                                                  12,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      Utils().formatTimestamp(
                                                          msg["timestamp"]),
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xffD2D2D2),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    if (isMe)
                                                      Icon(
                                                        isRead
                                                            ? Icons.done_all
                                                            : Icons.done,
                                                        size: 13.6,
                                                        color: isRead
                                                            ? pureWhite
                                                            : Colors.grey,
                                                      ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                        ),
                      ),
                    if (message.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          10,
                          mediaUrl != null ? 0 : 10,
                          10,
                          10,
                        ),
                        child: isOneLine
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(
                                      message,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: !isMe &&
                                                  Constant.darkMode != "true"
                                              ? pureBlack
                                              : pureWhite),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Row(
                                    children: [
                                      Text(
                                        Utils()
                                            .formatTimestamp(msg["timestamp"]),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: !isMe &&
                                                  Constant.darkMode != "true"
                                              ? const Color(0xff5E5E5E)
                                              : const Color(0xffD2D2D2),
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      if (isMe)
                                        Icon(
                                          isRead ? Icons.done_all : Icons.done,
                                          size: 13.6,
                                          color:
                                              isRead ? pureWhite : Colors.grey,
                                        ),
                                    ],
                                  ),
                                ],
                              )
                            : Text(
                                message,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: !isMe && Constant.darkMode != "true"
                                        ? pureBlack
                                        : pureWhite),
                              ),
                      ),
                    if (!isOneLine)
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 3, right: 11, bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              Utils().formatTimestamp(msg["timestamp"]),
                              style: TextStyle(
                                fontSize: 10,
                                color: !isMe && Constant.darkMode != "true"
                                    ? const Color(0xff5E5E5E)
                                    : const Color(0xffD2D2D2),
                              ),
                            ),
                            const SizedBox(width: 3),
                            if (isMe)
                              Icon(
                                isRead ? Icons.done_all : Icons.done,
                                size: 13.6,
                                color: isRead ? pureWhite : Colors.grey,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        automaticallyImplyLeading: false,
        leading: ResponsiveHelper.checkIsWeb(context)
            ? null
            : GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back,
                  color: white,
                  size: 22,
                ),
              ),
        title: InkWell(
          onTap: ResponsiveHelper.checkIsWeb(context)
              ? () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          WebProfile(
                        isProfile: false,
                        channelUserid: widget.otherUserId,
                        channelid: chatData?.receiverChannelId ?? '',
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              : () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        debugPrint('channel user Id :${widget.otherUserId}');
                        debugPrint(
                            'channel  Id :${detailsProvider.detailsModel.result?[0].channelId.toString() ?? ""}');
                        return Profile(
                          isProfile: false,
                          channelUserid: widget.otherUserId,
                          channelid: chatData?.receiverChannelId ?? '',
                        );
                      },
                    ),
                  );
                },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Row(
                    children: [
                      Container(
                          width: 30,
                          height: 30,
                          clipBehavior: Clip.antiAlias,
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          child: MyNetworkImage(
                              imagePath: widget.otherUserPic,
                              fit: BoxFit.cover)),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: MyText(
                          text: widget.otherUserName,
                          color: white,
                          multilanguage: false,
                          maxline: 1,
                          textalign: TextAlign.left,
                          inter: false,
                          overflow: TextOverflow.ellipsis,
                          fontwaight: FontWeight.w600,
                          fontsizeNormal: Dimens.textBig,
                        ),
                      ),
                    ],
                  ),
                  widget.creatorId == "1"
                      ? Positioned(
                          top: 3,
                          left: 20,
                          child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                width: 13,
                                height: 13,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: Constant.gradientColor),
                                child: MyImage(
                                    width: 50,
                                    height: 30,
                                    fit: BoxFit.cover,
                                    color: black,
                                    imagePath: "crown.png"),
                              )),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              const SizedBox(height: 3),
              if (chatData?.chatAmount != 0)
                Row(
                  children: [
                    MyImage(
                        width: 15.5, height: 15.5, imagePath: "ic_coin.png"),
                    const SizedBox(width: 3),
                    MyText(
                        color: white,
                        multilanguage: false,
                        text: '${chatData?.chatAmount.toString() ?? ' '}/chat',
                        textalign: TextAlign.center,
                        fontsizeNormal: 12,
                        fontsizeWeb: 13,
                        inter: true,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const AdsPackage();
                        },
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      MyImage(width: 21, height: 21, imagePath: "ic_coin.png"),
                      const SizedBox(width: 5),
                      MyText(
                          color: white,
                          multilanguage: false,
                          text: chatData?.balance.toString() ?? '',
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textMedium,
                          inter: true,
                          maxline: 1,
                          fontwaight: FontWeight.w700,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                ),
                if (Constant.isCreator == '0') ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ScheduleCall(
                                      isCreator: false,
                                      creatorId: widget.otherUserId,
                                    )));
                      },
                      child: Icon(
                        Icons.phone,
                        color: white,
                      )),
                ],
                const SizedBox(
                  width: 5,
                ),
                chatStatus == ChatApprovalStatus.approved
                    ? StreamBuilder(
                        stream: _realtimeDB
                            .ref('chats/$chatId/meta/blockedBy')
                            .onValue,
                        builder: (context, snapshot) {
                          String? currentBlockedBy;
                          if (snapshot.hasData &&
                              snapshot.data!.snapshot.value != null) {
                            currentBlockedBy =
                                snapshot.data!.snapshot.value.toString();
                          }

                          final amIBlocked = currentBlockedBy != null &&
                              currentBlockedBy != currentUserId;

                          if (!amIBlocked) {
                            return PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: white,
                              ),
                              onSelected: (value) {
                                if (value == 'block') blockChat();
                                if (value == 'unblock') unblockChat();
                              },
                              itemBuilder: (context) {
                                final isBlocked = currentBlockedBy != null &&
                                    currentBlockedBy == currentUserId;
                                return [
                                  PopupMenuItem(
                                    value: isBlocked ? 'unblock' : 'block',
                                    child:
                                        Text(isBlocked ? "Unblock" : "Block"),
                                  ),
                                ];
                              },
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      )
                    : const SizedBox(),
              ],
            ),
          )
        ],
      ),
      body: Utils().pageBg(
        context,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: StreamBuilder<DatabaseEvent>(
                      stream: _realtimeDB
                          .ref('chats/$chatId/messages')
                          .orderByChild('timestamp')
                          .onValue,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          debugPrint('❌ Chat stream error: ${snapshot.error}');
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyText(
                                  text: "Unable to load messages",
                                  color: white,
                                  multilanguage: false,
                                ),
                                const SizedBox(height: 8),
                                MyText(
                                  text: snapshot.error
                                          .toString()
                                          .contains('permission')
                                      ? 'Permission denied. Check Firebase rules.'
                                      : 'Check your connection',
                                  color: Colors.grey,
                                  multilanguage: false,
                                  fontsizeNormal: 12,
                                ),
                              ],
                            ),
                          );
                        }

                        if (!snapshot.hasData ||
                            snapshot.data?.snapshot.value == null) {
                          return Center(
                            child: MyText(
                              text: "No messages yet",
                              color: white,
                              multilanguage: false,
                            ),
                          );
                        }

                        _scrollToBottom();

                        final map = snapshot.data!.snapshot.value
                            as Map<dynamic, dynamic>;

                        final List<MapEntry<String, Map<String, dynamic>>>
                            messages = map.entries
                                .map((e) => MapEntry(e.key.toString(),
                                    Map<String, dynamic>.from(e.value)))
                                .toList()
                              ..sort((a, b) => (a.value['timestamp'] ?? 0)
                                  .compareTo(b.value['timestamp'] ?? 0));
                        lastMessage = messages.last.value['message'];
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 15, top: 8),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageItem(
                                messages[index].value, messages[index].key);
                          },
                        );
                      },
                    ),
                  ),
                  StreamBuilder<DatabaseEvent>(
                    stream: _realtimeDB.ref('chats/$chatId/meta').onValue,
                    builder: (context, snapshot) {
                      bool hasMessages = false;
                      String? lastMessageSenderId;
                      if (snapshot.hasData &&
                          snapshot.data?.snapshot.value != null) {
                        final meta = Map<String, dynamic>.from(
                          snapshot.data!.snapshot.value as Map,
                        );

                        final statusStr =
                            meta['status']?.toString() ?? 'pending';
                        final blockedStr = meta['blockedBy']?.toString();

                        chatStatus = ChatApprovalStatus.values.firstWhere(
                          (e) => e.toString().split('.').last == statusStr,
                          orElse: () => ChatApprovalStatus.pending,
                        );

                        blockedBy = blockedStr;
                      }
                      return StreamBuilder<DatabaseEvent>(
                        stream: _realtimeDB
                            .ref('chats/$chatId/messages')
                            .orderByChild('timestamp')
                            .onValue,
                        builder: (context, msgSnap) {
                          if (msgSnap.hasData &&
                              msgSnap.data?.snapshot.value != null) {
                            final map = Map<dynamic, dynamic>.from(
                                msgSnap.data!.snapshot.value as Map);
                            final messages = map.entries
                                .map((e) => Map<String, dynamic>.from(e.value))
                                .toList()
                              ..sort((a, b) => (a['timestamp'] ?? 0)
                                  .compareTo(b['timestamp'] ?? 0));

                            hasMessages = messages.isNotEmpty;
                            if (hasMessages) {
                              lastMessageSenderId =
                                  messages.last['senderId']?.toString();
                            }
                          }
                          final isReceiver = (lastMessageSenderId != null &&
                              lastMessageSenderId != currentUserId);

                          return buildChatInput(
                            hasMessages: hasMessages,
                            lastMessageSenderId: lastMessageSenderId,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildMessageInputContainer() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            margin: const EdgeInsets.only(left: 8, right: 5, bottom: 55),
            decoration: BoxDecoration(
                color: Constant.darkMode == "true"
                    ? const Color(0xff434343)
                    : const Color(0xff949494).withOpacity(0.3),
                borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: white),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: transparent)),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: transparent)),
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: white),
                  ),
                ),
                StreamBuilder<RecordingState>(
                  stream: _voiceRecorder.recordingState,
                  builder: (context, snapshot) {
                    final state = snapshot.data ??
                        RecordingState(
                            isRecording: false, duration: Duration.zero);

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _toggleRecording,
                          child: Icon(
                            state.isRecording ? Icons.stop : Icons.mic,
                            color: state.isRecording
                                ? Colors.red
                                : Constant.darkMode == 'true'
                                    ? Colors.grey.shade400
                                    : Colors.black,
                          ),
                        ),
                        if (state.isRecording)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '${state.duration.inSeconds}s',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        if (!state.isRecording)
                          const SizedBox(
                            width: 10,
                          ),
                      ],
                    );
                  },
                ),
                GestureDetector(
                  child: Icon(Icons.attach_file,
                      color: Constant.darkMode == 'true'
                          ? Colors.grey.shade400
                          : Colors.black),
                  onTap: () => pickAndUploadMedia(),
                ),
                const SizedBox(
                  width: 5,
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => sendMessage(text: _controller.text),
          child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 13.0, horizontal: 8),
              margin: const EdgeInsets.only(left: 8, right: 12, bottom: 55),
              decoration: const BoxDecoration(
                  color: Color(0xff2662D3), shape: BoxShape.circle),
              child: const Icon(Icons.send, color: pureWhite)),
        ),
      ],
    );
  }

  Future<void> approveChat() async {
    try {
      SuccessModel sent = await ApiService().approveChatMessage(
          currentUserId, widget.otherUserId, 1, lastMessage);

      if (sent.status == 200) {
        await _realtimeDB.ref('chats/$chatId/meta').update({
          'status': 'approved',
          'blockedBy': null,
        });

        if (mounted) {
          setState(() {
            chatStatus = ChatApprovalStatus.approved;
            blockedBy = null;
          });
        }
      }
    } catch (e) {
      debugPrint("Error approving chat: $e");
    }
  }

  Future<void> blockChat() async {
    try {
      SuccessModel sent = await ApiService()
          .approveChatMessage(currentUserId, widget.otherUserId, 0, null);

      if (sent.status == 200) {
        await _realtimeDB.ref('chats/$chatId/meta').update({
          'blockedBy': currentUserId,
          'status': 'blocked',
        });

        if (mounted) {
          setState(() {
            chatStatus = ChatApprovalStatus.blocked;
            blockedBy = currentUserId;
          });
        }
      }
    } catch (e) {
      debugPrint("Error blocking chat: $e");
    }
  }

  Future<void> unblockChat() async {
    try {
      SuccessModel sent = await ApiService().approveChatMessage(
          currentUserId, widget.otherUserId, 1, lastMessage);

      if (sent.status == 200) {
        await _realtimeDB.ref('chats/$chatId/meta').update({
          'blockedBy': null,
          'status': 'approved',
        });

        if (mounted) {
          setState(() {
            chatStatus = ChatApprovalStatus.approved;
            blockedBy = null;
          });
        }
      }
    } catch (e) {
      debugPrint("Error unblocking chat: $e");
    }
  }

  /// 🧠 Main chat input logic
  Widget buildChatInput({
    required bool hasMessages,
    required String? lastMessageSenderId,
  }) {
    final isReceiver =
        lastMessageSenderId != null && lastMessageSenderId != currentUserId;

    if (blockedBy != null) {
      final amIBlocked = blockedBy != currentUserId;
      if (amIBlocked) {
        return noteBox("You are blocked by the receiver.");
      } else {
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "You blocked this user.",
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () => unblockChat(),
                child: const Text(
                  "Unblock",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        );
      }
    }

    if (!hasMessages) {
      return buildMessageInputContainer();
    }

    if (chatStatus == ChatApprovalStatus.pending) {
      if (isReceiver) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => approveChat(),
                child: const Text("Approve"),
              ),
              OutlinedButton(
                onPressed: () => blockChat(),
                child: Text(
                  "Block",
                  style: TextStyle(color: white),
                ),
              ),
            ],
          ),
        );
      } else {
        return noteBox("Request sent. Waiting for receiver approval...");
      }
    }

    if (chatStatus == ChatApprovalStatus.approved) {
      return buildMessageInputContainer();
    }

    return const SizedBox();
  }
}

Widget noteBox(String text) {
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.grey.shade800,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white70),
    ),
  );
}

class VoiceRecorder {
  final Record _audioRecord = Record();
  bool _isRecording = false;
  String? _currentRecordingPath;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  final StreamController<RecordingState> _stateController =
      StreamController<RecordingState>.broadcast();

  Future<bool> _checkPermissions() async {
    final micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return true;
  }

  Future<void> startRecording() async {
    try {
      final hasPermission = await _checkPermissions();
      if (!hasPermission) return;

      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecord.start(
        path: path,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );

      _currentRecordingPath = path;
      _isRecording = true;
      _recordingDuration = Duration.zero;

      _stateController.add(RecordingState(
        isRecording: true,
        duration: Duration.zero,
      ));

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration += const Duration(seconds: 1);
        _stateController.add(RecordingState(
          isRecording: true,
          duration: _recordingDuration,
        ));
      });
    } catch (e) {
      debugPrint('Recording error: $e');
      _stateController.add(RecordingState(
        isRecording: false,
        duration: Duration.zero,
        error: e.toString(),
      ));
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      _recordingTimer?.cancel();
      final path = await _audioRecord.stop();
      _isRecording = false;

      _stateController.add(RecordingState(
        isRecording: false,
        duration: _recordingDuration,
      ));

      return path;
    } catch (e) {
      debugPrint('Stop recording error: $e');
      _stateController.add(RecordingState(
        isRecording: false,
        duration: Duration.zero,
        error: e.toString(),
      ));
      return null;
    }
  }

  Future<void> dispose() async {
    _recordingTimer?.cancel();
    await _audioRecord.dispose();
    await _stateController.close();
  }

  Stream<RecordingState> get recordingState => _stateController.stream;

  bool get isRecording => _isRecording;

  Duration get recordingDuration => _recordingDuration;

  String? get currentRecordingPath => _currentRecordingPath;
}

class RecordingState {
  final bool isRecording;
  final Duration duration;
  final String? error;

  RecordingState({
    required this.isRecording,
    required this.duration,
    this.error,
  });
}
