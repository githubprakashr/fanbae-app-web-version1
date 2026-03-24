import 'dart:developer';
import 'dart:io';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:fanbae/pages/bottombar.dart';
import 'package:fanbae/pages/login.dart';
import 'package:fanbae/provider/contentdetailprovider.dart';
import 'package:fanbae/provider/musicdetailprovider.dart';
import 'package:fanbae/provider/musicprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customwidget.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/musicmanager.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/webwidget/interactivecontainer.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/musicutils.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mymarqueetext.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bx.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:rxdart/rxdart.dart';

import '../utils/responsive_helper.dart';

AudioPlayer audioPlayer = AudioPlayer();

Stream<PositionData> get positionDataStream {
  return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          audioPlayer.positionStream,
          audioPlayer.bufferedPositionStream,
          audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero))
      .asBroadcastStream();
}

final ValueNotifier<double> playerExpandProgress =
    ValueNotifier(playerMinHeight);

final MiniplayerController controller = MiniplayerController();

class MusicDetails extends StatefulWidget {
  final bool ishomepage;
  final String contentid, episodeid, contenttype, stoptime;

  const MusicDetails({
    Key? key,
    required this.ishomepage,
    required this.contenttype,
    required this.contentid,
    required this.episodeid,
    required this.stoptime,
  }) : super(key: key);

  @override
  State<MusicDetails> createState() => _MusicDetailsState();
}

class _MusicDetailsState extends State<MusicDetails> {
  final MusicManager _musicManager = MusicManager();
  late ScrollController _scrollcontroller;
  late MusicDetailProvider musicDetailProvider;
  int currentstoptime = 0;

  @override
  void initState() {
    musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    _scrollcontroller = ScrollController();
    _scrollcontroller.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollcontroller.hasClients) return;
    if (_scrollcontroller.offset >=
            _scrollcontroller.position.maxScrollExtent &&
        !_scrollcontroller.position.outOfRange) {
      /* Related Music  */
      if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.genre ==
          "2") {
        if ((musicDetailProvider.relatedMusiccurrentPage ?? 0) <
            (musicDetailProvider.relatedMusictotalPage ?? 0)) {
          await musicDetailProvider.setLoadMore(true);
          _fetchDataRelatedMusic(
              musicDetailProvider.relatedMusiccurrentPage ?? 0);
        }
      } else if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.genre ==
          "4") {
        if ((musicDetailProvider.podcastcurrentPage ?? 0) <
            (musicDetailProvider.podcasttotalPage ?? 0)) {
          await musicDetailProvider.setLoadMore(true);
          _fetchDataPodcast(
              (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.album
                      .toString() ??
                  "",
              musicDetailProvider.podcastcurrentPage ?? 0);
        }
      } else if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.genre ==
          "5") {
        if ((musicDetailProvider.playlistcurrentPage ?? 0) <
            (musicDetailProvider.playlisttotalPage ?? 0)) {
          await musicDetailProvider.setLoadMore(true);
          _fetchDataPlaylist(
              (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.album
                      .toString() ??
                  "",
              "5",
              musicDetailProvider.playlistcurrentPage ?? 0);
        }
      } else if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.genre ==
          "6") {
        if ((musicDetailProvider.radiocurrentPage ?? 0) <
            (musicDetailProvider.radiototalPage ?? 0)) {
          await musicDetailProvider.setLoadMore(true);
          _fetchDataRadio(
              (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.album
                      .toString() ??
                  "",
              musicDetailProvider.radiocurrentPage ?? 0);
        }
      }
    }
  }

  Future<void> _fetchDataPodcast(podcastId, int? nextPage) async {
    await musicDetailProvider.getEpisodeByPodcast(
        podcastId, (nextPage ?? 0) + 1);
    await musicDetailProvider.setLoadMore(false);
  }

  Future<void> _fetchDataPlaylist(
      playlistId, contentType, int? nextPage) async {
    await musicDetailProvider.getEpisodeByPlaylist(
        playlistId, contentType, (nextPage ?? 0) + 1);
    await musicDetailProvider.setLoadMore(false);
  }

  Future<void> _fetchDataRadio(radioId, int? nextPage) async {
    await musicDetailProvider.getEpisodeByRadio(radioId, (nextPage ?? 0) + 1);
    await musicDetailProvider.setLoadMore(false);
  }

  Future<void> _fetchDataRelatedMusic(int? nextPage) async {
    await musicDetailProvider.getRelatedMusic(
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre,
        (nextPage ?? 0) + 1);
    await musicDetailProvider.setLoadMore(false);
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PositionData>(
        stream: positionDataStream,
        builder: (context, snapshot) {
          final positionData = snapshot.data;
          currentstoptime = positionData?.position.inMilliseconds ?? 0;
          return Miniplayer(
            valueNotifier: playerExpandProgress,
            minHeight: playerMinHeight,
            duration: const Duration(seconds: 1),
            maxHeight: MediaQuery.of(context).size.height,
            controller: controller,
            elevation: 4,
            backgroundColor: colorPrimaryDark,
            onDismissed: () async {
              printLog(
                  "is Contiue Watching=>${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.playable}");
              currentlyPlaying.value = null;
              printLog("contentType=>${widget.contenttype}");
              printLog("contentId=>${widget.contentid}");
              printLog("episodeid=>${widget.episodeid}");
              printLog("stopTime=>${widget.stoptime}");

              if (Constant.userID != null) {
                await musicDetailProvider.addContentHistory(widget.contenttype,
                    widget.contentid, currentstoptime, widget.episodeid);
              }

              currentlyPlaying.value = null;
              await audioPlayer.pause();
              await audioPlayer.stop();
              if (mounted) {
                setState(() {});
              }
              _musicManager.clearMusicPlayer();
              musicDetailProvider.clearProvider();
            },
            curve: Curves.easeInOutCubicEmphasized,
            builder: (height, percentage) {
              final bool miniplayer =
                  percentage < miniplayerPercentageDeclaration;

              if (!miniplayer) {
                return Scaffold(
                  backgroundColor: appbgcolor,
                  body: Container(
                    decoration: BoxDecoration(
                      color: appbgcolor,
                    ),
                    child: Column(
                      children: [
                        _buildAppBar(),
                        Expanded(child: buildMusicPage()),
                      ],
                    ),
                  ),
                );
              }
              //Miniplayer
              final percentageMiniplayer = percentageFromValueInRange(
                  min: playerMinHeight,
                  max: MediaQuery.of(context).size.height,
                  value: height);
              final elementOpacity = 1 - 1 * percentageMiniplayer;
              final progressIndicatorHeight = 2 - 2 * percentageMiniplayer;

              return Scaffold(
                body: _buildMusicPanel(
                    height, elementOpacity, progressIndicatorHeight),
              );
            },
          );
        });
  }

/* Music Detail AppBar */

  Widget _buildAppBar() {
    if (!kIsWeb) {
      return SafeArea(
        child: Container(
          height: 50,
          color: colorPrimaryDark,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FittedBox(
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      angle: 11,
                      child: Utils.backIcon(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: MyText(
                  color: white,
                  text: "playingstart",
                  maxline: 1,
                  fontsizeNormal: 16,
                  multilanguage: true,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                ),
              ),
              const SizedBox(width: 45),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

/* Music Page Full Width And Height */

  Widget buildMusicPage() {
    /* App Side Layouts */
    if (!kIsWeb) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),
            StreamBuilder<SequenceState?>(
                stream: audioPlayer.sequenceStateStream,
                builder: (context, snapshot) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 3.0, color: white),
                        bottom: BorderSide(width: 3.0, color: white),
                      ),
                    ),
                    child: MyNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.30,
                      imagePath: ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.artUri)
                          .toString(),
                      fit: BoxFit.cover,
                    ),
                  );
                }),
            const SizedBox(height: 15),
            StreamBuilder<SequenceState?>(
                stream: audioPlayer.sequenceStateStream,
                builder: (context, snapshot) {
                  return Container(
                    height: 35,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: MyMarqueeText(
                        text: ((audioPlayer.sequenceState?.currentSource?.tag
                                    as MediaItem?)
                                ?.title)
                            .toString(),
                        fontsize: Dimens.textBig,
                        color: white),
                  );
                }),
            const SizedBox(height: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (audioPlayer.sequenceState?.currentSource?.tag
                                        as MediaItem?)
                                    ?.genre ==
                                "5" ||
                            (audioPlayer.sequenceState?.currentSource?.tag
                                        as MediaItem?)
                                    ?.genre ==
                                "6"
                        ? const SizedBox.shrink()
                        : (audioPlayer.sequenceState?.currentSource?.tag
                                        as MediaItem?)
                                    ?.extras?['is_like'] ==
                                1
                            ? Container(
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.fromLTRB(15, 7, 15, 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: colorPrimaryDark,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        if (Constant.userID == null) {
                                          if (ResponsiveHelper.checkIsWeb(
                                              context)) {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation1,
                                                        animation2) =>
                                                    const WebLogin(),
                                                transitionDuration:
                                                    Duration.zero,
                                                reverseTransitionDuration:
                                                    Duration.zero,
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return const Login();
                                                },
                                              ),
                                            );
                                          }
                                        } else {
                                          if ((audioPlayer
                                                      .sequenceState
                                                      ?.currentSource
                                                      ?.tag as MediaItem?)
                                                  ?.extras?['is_like'] ==
                                              0) {
                                            Utils().showSnackBar(
                                                context,
                                                "youcannotlikethiscontent",
                                                true);
                                          } else {
                                            like();
                                          }
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            transitionBuilder: (Widget child,
                                                Animation<double> animation) {
                                              return ScaleTransition(
                                                  scale: animation,
                                                  child: child);
                                            },
                                            child: (audioPlayer
                                                                .sequenceState
                                                                ?.currentSource
                                                                ?.tag as MediaItem?)
                                                            ?.extras?[
                                                        'is_user_like_dislike'] ==
                                                    1
                                                ? const Iconify(
                                                    Bx.bxs_like,
                                                    size: 18,
                                                    color: colorPrimary,
                                                    key: ValueKey<int>(1),
                                                  )
                                                : Iconify(
                                                    Bx.like,
                                                    size: 18,
                                                    key: ValueKey<int>(2),
                                                    color: white,
                                                  ),
                                          ),
                                          const SizedBox(width: 8),
                                          MyText(
                                              color: white,
                                              text: Utils.kmbGenerator(
                                                  int.parse(((audioPlayer
                                                                  .sequenceState
                                                                  ?.currentSource
                                                                  ?.tag
                                                              as MediaItem?)
                                                          ?.extras?['total_like'])
                                                      .toString())),
                                              multilanguage: false,
                                              textalign: TextAlign.center,
                                              fontsizeNormal: Dimens.textSmall,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        String contentId = widget.contentid;
                        print(contentId);
                        final shareUrl =
                            "Hey! I'm watching ${((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title).toString()} on ${Constant.appName}! 🎬\n"
                            "Watch here 👉 https://Fanbae.tv/music?m=$contentId/${widget.contenttype}\n";
                        print(contentId);
                        print(shareUrl);
                        Utils.shareApp(shareUrl);
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: colorPrimaryDark,
                        ),
                        child: Row(
                          children: [
                            MyImage(
                              width: 18,
                              height: 18,
                              imagePath: "ic_share.png",
                              color: white,
                            ),
                            const SizedBox(width: 8),
                            MyText(
                                color: white,
                                text: "share",
                                multilanguage: true,
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textSmall,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: StreamBuilder<PositionData>(
                      stream: positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return ProgressBar(
                          progress: positionData?.position ?? Duration.zero,
                          buffered:
                              positionData?.bufferedPosition ?? Duration.zero,
                          total: positionData?.duration ?? Duration.zero,
                          progressBarColor: white,
                          baseBarColor: colorPrimary,
                          bufferedBarColor: gray,
                          thumbColor: white,
                          barHeight: 2.0,
                          thumbRadius: 5.0,
                          timeLabelPadding: 5.0,
                          timeLabelType: TimeLabelType.totalTime,
                          timeLabelTextStyle: GoogleFonts.inter(
                            fontSize: 12,
                            fontStyle: FontStyle.normal,
                            color: white,
                            fontWeight: FontWeight.w700,
                          ),
                          onSeek: (duration) {
                            audioPlayer.seek(duration);
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<SequenceState?>(
                        stream: audioPlayer.sequenceStateStream,
                        builder: (context, snapshot) => IconButton(
                          iconSize: 40,
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            color: white,
                          ),
                          onPressed: audioPlayer.hasPrevious
                              ? audioPlayer.seekToPrevious
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      // 10 Second Privious
                      StreamBuilder<PositionData>(
                        stream: positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data;
                          return InkWell(
                              onTap: () {
                                tenSecNextOrPrevious(
                                    positionData?.position.inSeconds
                                            .toString() ??
                                        "",
                                    false);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_tenprevious.png"),
                              ));
                        },
                      ),
                      const SizedBox(width: 15),
                      // Pause and Play Controll
                      StreamBuilder<PlayerState>(
                        stream: audioPlayer.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;
                          if (processingState == ProcessingState.loading ||
                              processingState == ProcessingState.buffering) {
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              width: 50.0,
                              height: 50.0,
                              child: const CircularProgressIndicator(
                                color: colorPrimary,
                              ),
                            );
                          } else if (playing != true) {
                            return Container(
                              decoration: BoxDecoration(
                                color: colorPrimary,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.play_arrow_rounded,
                                  color: colorAccent,
                                ),
                                color: colorAccent,
                                iconSize: 50.0,
                                onPressed: audioPlayer.play,
                              ),
                            );
                          } else if (processingState !=
                              ProcessingState.completed) {
                            return Container(
                              decoration: BoxDecoration(
                                color: colorPrimary,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.pause_rounded,
                                  color: colorAccent,
                                ),
                                iconSize: 50.0,
                                color: colorAccent,
                                onPressed: audioPlayer.pause,
                              ),
                            );
                          } else {
                            return IconButton(
                              icon: Icon(
                                Icons.replay_rounded,
                                color: colorAccent,
                              ),
                              iconSize: 60.0,
                              onPressed: () => audioPlayer.seek(Duration.zero,
                                  index: audioPlayer.effectiveIndices!.first),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 15),
                      StreamBuilder<PositionData>(
                        stream: positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data;

                          return InkWell(
                              onTap: () {
                                tenSecNextOrPrevious(
                                    positionData?.position.inSeconds
                                            .toString() ??
                                        "",
                                    true);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_tennext.png"),
                              ));
                        },
                      ),
                      const SizedBox(width: 15),
                      // Next Audio Play
                      StreamBuilder<SequenceState?>(
                        stream: audioPlayer.sequenceStateStream,
                        builder: (context, snapshot) => IconButton(
                          iconSize: 40.0,
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: white,
                          ),
                          onPressed: audioPlayer.hasNext
                              ? audioPlayer.seekToNext
                              : null,
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 55,
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Volumn Costome Set
                        IconButton(
                          iconSize: 30.0,
                          icon: const Icon(Icons.volume_up),
                          color: white,
                          onPressed: () {
                            showSliderDialog(
                              context: context,
                              title: "Adjust volume",
                              divisions: 10,
                              min: 0.0,
                              max: 2.0,
                              value: audioPlayer.volume,
                              stream: audioPlayer.volumeStream,
                              onChanged: audioPlayer.setVolume,
                            );
                          },
                        ),
                        // Audio Speed Costomized
                        StreamBuilder<double>(
                          stream: audioPlayer.speedStream,
                          builder: (context, snapshot) => IconButton(
                            icon: Text(
                              overflow: TextOverflow.ellipsis,
                              "${snapshot.data?.toStringAsFixed(1)}x",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: white,
                                  fontSize: 14),
                            ),
                            onPressed: () {
                              showSliderDialog(
                                context: context,
                                title: "Adjust speed",
                                divisions: 16,
                                min: 0.5,
                                max: 2.0,
                                value: audioPlayer.speed,
                                stream: audioPlayer.speedStream,
                                onChanged: audioPlayer.setSpeed,
                              );
                            },
                          ),
                        ),
                        StreamBuilder<LoopMode>(
                          stream: audioPlayer.loopModeStream,
                          builder: (context, snapshot) {
                            final loopMode = snapshot.data ?? LoopMode.off;
                            final icons = [
                              Icon(Icons.repeat, color: white, size: 30.0),
                              const Icon(Icons.repeat,
                                  color: colorPrimary, size: 30.0),
                              const Icon(Icons.repeat_one,
                                  color: colorPrimary, size: 30.0),
                            ];
                            const cycleModes = [
                              LoopMode.off,
                              LoopMode.all,
                              LoopMode.one,
                            ];
                            final index = cycleModes.indexOf(loopMode);
                            return IconButton(
                              icon: icons[index],
                              onPressed: () {
                                audioPlayer.setLoopMode(cycleModes[
                                    (cycleModes.indexOf(loopMode) + 1) %
                                        cycleModes.length]);
                              },
                            );
                          },
                        ),
                        // Suffle Button
                        StreamBuilder<bool>(
                          stream: audioPlayer.shuffleModeEnabledStream,
                          builder: (context, snapshot) {
                            final shuffleModeEnabled = snapshot.data ?? false;
                            return IconButton(
                              iconSize: 30.0,
                              icon: shuffleModeEnabled
                                  ? const Icon(Icons.shuffle,
                                      color: colorPrimary)
                                  : Icon(Icons.shuffle, color: white),
                              onPressed: () async {
                                final enable = !shuffleModeEnabled;
                                if (enable) {
                                  await audioPlayer.shuffle();
                                }
                                await audioPlayer.setShuffleModeEnabled(enable);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 15),
            ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                            ?.genre)
                        .toString() ==
                    "2"
                ? const SizedBox.shrink()
                : Consumer<MusicDetailProvider>(
                    builder: (context, seactionprovider, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: colorPrimaryDark,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 60,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      seactionprovider
                                          .changeMusicTab("episode");
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      // height: 50,
                                      alignment: Alignment.center,
                                      // color: colorAccent,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          MyText(
                                              color: white,
                                              text: "episodes",
                                              multilanguage: true,
                                              textalign: TextAlign.center,
                                              fontsizeNormal: Dimens.textDesc,
                                              inter: false,
                                              maxline: 6,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                          seactionprovider.istype == "episode"
                                              ? Container(
                                                  width: 100,
                                                  height: 1,
                                                  color: colorPrimary,
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      seactionprovider
                                          .changeMusicTab("details");
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      alignment: Alignment.center,
                                      // height: 50,
                                      // color: colorAccent,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          MyText(
                                              color: white,
                                              text: "details",
                                              multilanguage: true,
                                              textalign: TextAlign.center,
                                              fontsizeNormal: Dimens.textDesc,
                                              inter: false,
                                              maxline: 6,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                          seactionprovider.istype == "details"
                                              ? Container(
                                                  width: 100,
                                                  height: 1,
                                                  color: colorPrimary,
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if ((audioPlayer.sequenceState?.currentSource?.tag
                                      as MediaItem?)
                                  ?.genre ==
                              "4")
                            seactionprovider.istype == "episode"
                                ? buildPodcastEpisode()
                                : detailItemPodcast()
                          else if ((audioPlayer.sequenceState?.currentSource
                                      ?.tag as MediaItem?)
                                  ?.genre ==
                              "6")
                            seactionprovider.istype == "episode"
                                ? buildRadioEpisode()
                                : detailItemMusicRadioPlaylist()
                          else if ((audioPlayer.sequenceState?.currentSource
                                      ?.tag as MediaItem?)
                                  ?.genre ==
                              "5")
                            seactionprovider.istype == "episode"
                                ? buildPlaylistEpisode()
                                : detailItemMusicRadioPlaylist()
                        ],
                      ),
                    );
                  }),
          ],
        ),
      );
      /* Web Side Layouts */
    } else {
      if (MediaQuery.of(context).size.width > 1050) {
        return webFullScreenDetail();
      } else {
        return webMobileScreenDetail();
      }
    }
  }

  Widget webFullScreenDetail() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      // physics: const NeverScrollableScrollPhysics(),
      controller: _scrollcontroller,
      child: StreamBuilder<SequenceState?>(
        stream: audioPlayer.sequenceStateStream,
        builder: (context, snapshot) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(80, 25, 0, 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 22,
                            color: white,
                          ),
                          const SizedBox(width: 15),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MusicTitle(
                                  text: "nowplaying",
                                  fontsizeNormal: Dimens.textExtraBig,
                                  maxline: 1,
                                  fontstyle: FontStyle.normal,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  multilanguage: true,
                                  textalign: TextAlign.center,
                                  fontsizeWeb: Dimens.textExtraBig,
                                  color: white),
                              const SizedBox(height: 10),
                              MusicTitle(
                                  text: "playingfrom",
                                  fontsizeNormal: Dimens.textMedium,
                                  fontsizeWeb: Dimens.textMedium,
                                  maxline: 1,
                                  fontstyle: FontStyle.normal,
                                  fontwaight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  multilanguage: true,
                                  textalign: TextAlign.center,
                                  color: gray),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: MyNetworkImage(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.42,
                          imagePath: ((audioPlayer.sequenceState?.currentSource
                                      ?.tag as MediaItem?)
                                  ?.artUri)
                              .toString(),
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      MyText(
                          text: ((audioPlayer.sequenceState?.currentSource?.tag
                                      as MediaItem?)
                                  ?.title)
                              .toString(),
                          fontsizeNormal: Dimens.textBig,
                          maxline: 2,
                          fontstyle: FontStyle.normal,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          multilanguage: false,
                          textalign: TextAlign.left,
                          fontsizeWeb: Dimens.textBig,
                          color: white),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /* Like Dislike Buttons */
                          (audioPlayer.sequenceState?.currentSource?.tag
                                              as MediaItem?)
                                          ?.genre ==
                                      "5" ||
                                  (audioPlayer.sequenceState?.currentSource?.tag
                                              as MediaItem?)
                                          ?.genre ==
                                      "6"
                              ? const SizedBox.shrink()
                              : (audioPlayer.sequenceState?.currentSource?.tag
                                              as MediaItem?)
                                          ?.extras?['is_like'] ==
                                      1
                                  ? Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 8, 20, 8),
                                      decoration: BoxDecoration(
                                        color: colorPrimaryDark,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              if (Constant.userID == null) {
                                                if (ResponsiveHelper.checkIsWeb(
                                                    context)) {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (context,
                                                              animation1,
                                                              animation2) =>
                                                          const WebLogin(),
                                                      transitionDuration:
                                                          Duration.zero,
                                                      reverseTransitionDuration:
                                                          Duration.zero,
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return const Login();
                                                      },
                                                    ),
                                                  );
                                                }
                                              } else {
                                                if ((audioPlayer
                                                            .sequenceState
                                                            ?.currentSource
                                                            ?.tag as MediaItem?)
                                                        ?.extras?['is_like'] ==
                                                    0) {
                                                  Utils().showSnackBar(
                                                      context,
                                                      "youcannotlikethiscontent",
                                                      true);
                                                } else {
                                                  like();
                                                }
                                              }
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                AnimatedSwitcher(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  transitionBuilder:
                                                      (Widget child,
                                                          Animation<double>
                                                              animation) {
                                                    return ScaleTransition(
                                                        scale: animation,
                                                        child: child);
                                                  },
                                                  child: (audioPlayer
                                                                  .sequenceState
                                                                  ?.currentSource
                                                                  ?.tag as MediaItem?)
                                                              ?.extras?['is_user_like_dislike'] ==
                                                          1
                                                      ? const Iconify(
                                                          Bx.bxs_like,
                                                          size: 18,
                                                          color: colorPrimary,
                                                          key: ValueKey<int>(1),
                                                        )
                                                      : Iconify(
                                                          Bx.like,
                                                          size: 18,
                                                          key: ValueKey<int>(2),
                                                          color: white,
                                                        ),
                                                ),
                                                const SizedBox(width: 8),
                                                MyText(
                                                    color: white,
                                                    text: Utils.kmbGenerator(
                                                        int.parse(((audioPlayer
                                                                            .sequenceState
                                                                            ?.currentSource
                                                                            ?.tag
                                                                        as MediaItem?)
                                                                    ?.extras?[
                                                                'total_like'])
                                                            .toString())),
                                                    multilanguage: false,
                                                    textalign: TextAlign.center,
                                                    fontsizeNormal:
                                                        Dimens.textTitle,
                                                    inter: false,
                                                    maxline: 6,
                                                    fontwaight: FontWeight.w600,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontstyle:
                                                        FontStyle.normal),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                            decoration: BoxDecoration(
                              color: colorPrimaryDark,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                    onTap: () {
                                      showSliderDialog(
                                        context: context,
                                        title: "Adjust volume",
                                        divisions: 10,
                                        min: 0.0,
                                        max: 2.0,
                                        value: audioPlayer.volume,
                                        stream: audioPlayer.volumeStream,
                                        onChanged: audioPlayer.setVolume,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: MyImage(
                                          width: 20,
                                          color: white,
                                          height: 20,
                                          imagePath: "ic_volum.png"),
                                    )),
                                const SizedBox(width: 20),
                                StreamBuilder<double>(
                                  stream: audioPlayer.speedStream,
                                  builder: (context, snapshot) => Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: InkWell(
                                      onTap: () {
                                        showSliderDialog(
                                          context: context,
                                          title: "Adjust speed",
                                          divisions: 10,
                                          min: 0.5,
                                          max: 2.0,
                                          value: audioPlayer.speed,
                                          stream: audioPlayer.speedStream,
                                          onChanged: audioPlayer.setSpeed,
                                        );
                                      },
                                      child: MyImage(
                                          width: 20,
                                          height: 20,
                                          color: white,
                                          imagePath: "ic_speed.png"),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Loop Node Button
                                StreamBuilder<LoopMode>(
                                  stream: audioPlayer.loopModeStream,
                                  builder: (context, snapshot) {
                                    final loopMode =
                                        snapshot.data ?? LoopMode.off;
                                    final icons = [
                                      Icon(Icons.repeat,
                                          color: white, size: 20.0),
                                      const Icon(Icons.repeat,
                                          color: colorPrimary, size: 20.0),
                                      const Icon(Icons.repeat_one,
                                          color: colorPrimary, size: 20.0),
                                    ];
                                    const cycleModes = [
                                      LoopMode.off,
                                      LoopMode.all,
                                      LoopMode.one,
                                    ];
                                    final index = cycleModes.indexOf(loopMode);
                                    return IconButton(
                                      icon: icons[index],
                                      onPressed: () {
                                        audioPlayer.setLoopMode(cycleModes[
                                            (cycleModes.indexOf(loopMode) + 1) %
                                                cycleModes.length]);
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(width: 15),
                                StreamBuilder<bool>(
                                  stream: audioPlayer.shuffleModeEnabledStream,
                                  builder: (context, snapshot) {
                                    final shuffleModeEnabled =
                                        snapshot.data ?? false;
                                    return IconButton(
                                      iconSize: 20.0,
                                      icon: shuffleModeEnabled
                                          ? const Icon(Icons.shuffle,
                                              color: colorPrimary)
                                          : Icon(Icons.shuffle, color: white),
                                      onPressed: () async {
                                        final enable = !shuffleModeEnabled;
                                        if (enable) {
                                          await audioPlayer.shuffle();
                                        }
                                        await audioPlayer
                                            .setShuffleModeEnabled(enable);
                                      },
                                    );
                                  },
                                ),
                                // const SizedBox(width: 15),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      StreamBuilder<PositionData>(
                        stream: positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data;
                          return ProgressBar(
                            progress: positionData?.position ?? Duration.zero,
                            buffered:
                                positionData?.bufferedPosition ?? Duration.zero,
                            total: positionData?.duration ?? Duration.zero,
                            progressBarColor: colorPrimary,
                            baseBarColor: white,
                            bufferedBarColor: gray,
                            thumbColor: colorPrimary,
                            barHeight: 2.0,
                            thumbRadius: 5.0,
                            timeLabelPadding: 5.0,
                            timeLabelType: TimeLabelType.totalTime,
                            timeLabelTextStyle: GoogleFonts.inter(
                              fontSize: 12,
                              fontStyle: FontStyle.normal,
                              color: white,
                              fontWeight: FontWeight.w700,
                            ),
                            onSeek: (duration) {
                              audioPlayer.seek(duration);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 40,
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              color: white,
                            ),
                            onPressed: audioPlayer.hasPrevious
                                ? audioPlayer.seekToPrevious
                                : null,
                          ),
                          const SizedBox(width: 18),
                          StreamBuilder<PositionData>(
                            stream: positionDataStream,
                            builder: (context, snapshot) {
                              final positionData = snapshot.data;
                              return InkWell(
                                  onTap: () {
                                    tenSecNextOrPrevious(
                                        positionData?.position.inSeconds
                                                .toString() ??
                                            "",
                                        false);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: MyImage(
                                        width: 30,
                                        height: 30,
                                        imagePath: "ic_tenprevious.png"),
                                  ));
                            },
                          ),
                          // Pause and Play Controll
                          const SizedBox(width: 18),
                          StreamBuilder<PlayerState>(
                            stream: audioPlayer.playerStateStream,
                            builder: (context, snapshot) {
                              final playerState = snapshot.data;
                              final processingState =
                                  playerState?.processingState;
                              final playing = playerState?.playing;
                              if (processingState == ProcessingState.loading ||
                                  processingState ==
                                      ProcessingState.buffering) {
                                return Container(
                                  margin: const EdgeInsets.all(8.0),
                                  width: 50.0,
                                  height: 50.0,
                                  child: const CircularProgressIndicator(
                                    color: colorPrimary,
                                  ),
                                );
                              } else if (playing != true) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: colorPrimary,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.play_arrow_rounded,
                                      color: white,
                                    ),
                                    color: white,
                                    iconSize: 50.0,
                                    onPressed: audioPlayer.play,
                                  ),
                                );
                              } else if (processingState !=
                                  ProcessingState.completed) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: colorPrimary,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.pause_rounded,
                                      color: white,
                                    ),
                                    iconSize: 50.0,
                                    color: white,
                                    onPressed: audioPlayer.pause,
                                  ),
                                );
                              } else {
                                return IconButton(
                                  icon: Icon(
                                    Icons.replay_rounded,
                                    color: white,
                                  ),
                                  iconSize: 60.0,
                                  onPressed: () => audioPlayer.seek(
                                      Duration.zero,
                                      index:
                                          audioPlayer.effectiveIndices!.first),
                                );
                              }
                            },
                          ),
                          // 10 Second Next
                          const SizedBox(width: 18),
                          StreamBuilder<PositionData>(
                            stream: positionDataStream,
                            builder: (context, snapshot) {
                              final positionData = snapshot.data;

                              return InkWell(
                                  onTap: () {
                                    tenSecNextOrPrevious(
                                        positionData?.position.inSeconds
                                                .toString() ??
                                            "",
                                        true);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: MyImage(
                                        width: 30,
                                        height: 30,
                                        imagePath: "ic_tennext.png"),
                                  ));
                            },
                          ),
                          // Next Audio Play
                          const SizedBox(width: 18),
                          IconButton(
                            iconSize: 40.0,
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: white,
                            ),
                            onPressed: audioPlayer.hasNext
                                ? audioPlayer.seekToNext
                                : null,
                          ),
                        ],
                      ),
                      // const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.fromLTRB(30, 25, 30, 30),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MusicTitle(
                              text: ((audioPlayer.sequenceState?.currentSource
                                              ?.tag as MediaItem?)
                                          ?.genre ==
                                      "4")
                                  ? "relatedepisode"
                                  : "relatedmusic",
                              fontsizeNormal: Dimens.textExtraBig,
                              fontsizeWeb: Dimens.textExtraBig,
                              maxline: 1,
                              fontstyle: FontStyle.normal,
                              fontwaight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              multilanguage: true,
                              textalign: TextAlign.center,
                              color: white),
                          InkWell(
                            onTap: () async {
                              printLog(
                                  "is Contiue Watching=>${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.playable}");
                              currentlyPlaying.value = null;
                              printLog("contentType=>${widget.contenttype}");
                              printLog("contentId=>${widget.contentid}");
                              printLog("episodeid=>${widget.episodeid}");
                              printLog("stopTime=>${widget.stoptime}");

                              if (Constant.userID != null) {
                                await musicDetailProvider.addContentHistory(
                                    widget.contenttype,
                                    widget.contentid,
                                    currentstoptime,
                                    widget.episodeid);
                              }

                              currentlyPlaying.value = null;
                              await audioPlayer.pause();
                              await audioPlayer.stop();
                              if (mounted) {
                                setState(() {});
                              }

                              _musicManager.clearMusicPlayer();
                              musicDetailProvider.clearProvider();
                            },
                            child: Icon(
                              Icons.close,
                              size: 22,
                              color: white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ((audioPlayer.sequenceState?.currentSource?.tag
                                      as MediaItem?)
                                  ?.genre ==
                              "2")
                          ? buildRelatedMusic()
                          : ((audioPlayer.sequenceState?.currentSource?.tag
                                          as MediaItem?)
                                      ?.genre ==
                                  "4")
                              ? buildPodcastEpisode()
                              : ((audioPlayer.sequenceState?.currentSource?.tag
                                              as MediaItem?)
                                          ?.genre ==
                                      "5")
                                  ? buildPlaylistEpisode()
                                  : buildRadioEpisode(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget webMobileScreenDetail() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: _scrollcontroller,
      physics: const AlwaysScrollableScrollPhysics(),
      child: StreamBuilder<SequenceState?>(
        stream: audioPlayer.sequenceStateStream,
        builder: (context, snapshot) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* Music Title With Image And All Buttons */
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 22,
                                color: white,
                              ),
                              const SizedBox(width: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MusicTitle(
                                      text: "nowplaying",
                                      fontsizeNormal: Dimens.textExtraBig,
                                      maxline: 1,
                                      fontstyle: FontStyle.normal,
                                      fontwaight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      multilanguage: true,
                                      textalign: TextAlign.center,
                                      fontsizeWeb: Dimens.textExtraBig,
                                      color: white),
                                  const SizedBox(height: 10),
                                  MusicTitle(
                                      text: "playingfrom",
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      maxline: 1,
                                      fontstyle: FontStyle.normal,
                                      fontwaight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      multilanguage: true,
                                      textalign: TextAlign.center,
                                      color: gray),
                                ],
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            printLog(
                                "is Contiue Watching=>${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.playable}");
                            currentlyPlaying.value = null;
                            printLog("contentType=>${widget.contenttype}");
                            printLog("contentId=>${widget.contentid}");
                            printLog("episodeid=>${widget.episodeid}");
                            printLog("stopTime=>${widget.stoptime}");

                            if (Constant.userID != null) {
                              await musicDetailProvider.addContentHistory(
                                  widget.contenttype,
                                  widget.contentid,
                                  currentstoptime,
                                  widget.episodeid);
                            }

                            currentlyPlaying.value = null;
                            await audioPlayer.pause();
                            await audioPlayer.stop();
                            if (mounted) {
                              setState(() {});
                            }

                            _musicManager.clearMusicPlayer();
                            musicDetailProvider.clearProvider();
                          },
                          child: Icon(
                            Icons.close,
                            size: 22,
                            color: white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.50,
                        imagePath: ((audioPlayer.sequenceState?.currentSource
                                    ?.tag as MediaItem?)
                                ?.artUri)
                            .toString(),
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MyText(
                        text: ((audioPlayer.sequenceState?.currentSource?.tag
                                    as MediaItem?)
                                ?.title)
                            .toString(),
                        fontsizeNormal: Dimens.textBig,
                        maxline: 2,
                        fontstyle: FontStyle.normal,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        multilanguage: false,
                        textalign: TextAlign.left,
                        fontsizeWeb: Dimens.textBig,
                        color: white),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /* Like Dislike Buttons */
                        (audioPlayer.sequenceState?.currentSource?.tag
                                            as MediaItem?)
                                        ?.genre ==
                                    "5" ||
                                (audioPlayer.sequenceState?.currentSource?.tag
                                            as MediaItem?)
                                        ?.genre ==
                                    "6"
                            ? const SizedBox.shrink()
                            : (audioPlayer.sequenceState?.currentSource?.tag
                                            as MediaItem?)
                                        ?.extras?['is_like'] ==
                                    1
                                ? Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 8, 20, 8),
                                    decoration: BoxDecoration(
                                      color: colorPrimaryDark,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            if (Constant.userID == null) {
                                              if (kIsWeb) {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context,
                                                            animation1,
                                                            animation2) =>
                                                        const WebLogin(),
                                                    transitionDuration:
                                                        Duration.zero,
                                                    reverseTransitionDuration:
                                                        Duration.zero,
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return const Login();
                                                    },
                                                  ),
                                                );
                                              }
                                            } else {
                                              if ((audioPlayer
                                                          .sequenceState
                                                          ?.currentSource
                                                          ?.tag as MediaItem?)
                                                      ?.extras?['is_like'] ==
                                                  0) {
                                                Utils().showSnackBar(
                                                    context,
                                                    "youcannotlikethiscontent",
                                                    true);
                                              } else {
                                                like();
                                              }
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              (audioPlayer.sequenceState?.currentSource
                                                                      ?.tag
                                                                  as MediaItem?)
                                                              ?.extras?[
                                                          'is_user_like_dislike'] ==
                                                      1
                                                  ? MyImage(
                                                      width: 20,
                                                      height: 20,
                                                      fit: BoxFit.cover,
                                                      color: colorPrimary,
                                                      imagePath:
                                                          "ic_likefill.png",
                                                    )
                                                  : MyImage(
                                                      width: 20,
                                                      height: 20,
                                                      imagePath: "ic_like.png",
                                                    ),
                                              const SizedBox(width: 8),
                                              MyText(
                                                  color: white,
                                                  text: Utils.kmbGenerator(
                                                      int.parse(((audioPlayer
                                                                  .sequenceState
                                                                  ?.currentSource
                                                                  ?.tag as MediaItem?)
                                                              ?.extras?['total_like'])
                                                          .toString())),
                                                  multilanguage: false,
                                                  textalign: TextAlign.center,
                                                  fontsizeNormal: Dimens.textTitle,
                                                  inter: false,
                                                  maxline: 6,
                                                  fontwaight: FontWeight.w600,
                                                  overflow: TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        /* Container(
                                          color: white,
                                          width: 0.5,
                                          height: 15,
                                        ),
                                        const SizedBox(width: 10),*/
                                        /*InkWell(
                                          onTap: () async {
                                            if ((audioPlayer
                                                        .sequenceState
                                                        ?.currentSource
                                                        ?.tag as MediaItem?)
                                                    ?.extras?['is_like'] ==
                                                0) {
                                              Utils().showSnackbar(
                                                  context,
                                                  "youcannotlikethiscontent",
                                                  true);
                                            } else {
                                              dislike();
                                            }
                                          },
                                          child: (audioPlayer
                                                              .sequenceState
                                                              ?.currentSource
                                                              ?.tag as MediaItem?)
                                                          ?.extras?[
                                                      'is_user_like_dislike'] ==
                                                  2
                                              ? MyImage(
                                                  width: 22,
                                                  height: 22,
                                                  color: colorPrimary,
                                                  imagePath:
                                                      "ic_dislikefill.png",
                                                )
                                              : MyImage(
                                                  width: 22,
                                                  height: 22,
                                                  imagePath: "ic_dislike.png",
                                                ),
                                        ),*/
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),

                        /* Other Buttons */
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                          decoration: BoxDecoration(
                            color: colorPrimaryDark,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            children: [
                              // Volumn
                              InkWell(
                                  onTap: () {
                                    showSliderDialog(
                                      context: context,
                                      title: "Adjust volume",
                                      divisions: 10,
                                      min: 0.0,
                                      max: 2.0,
                                      value: audioPlayer.volume,
                                      stream: audioPlayer.volumeStream,
                                      onChanged: audioPlayer.setVolume,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: MyImage(
                                        width: 20,
                                        color: white,
                                        height: 20,
                                        imagePath: "ic_volum.png"),
                                  )),
                              const SizedBox(width: 20),
                              StreamBuilder<double>(
                                stream: audioPlayer.speedStream,
                                builder: (context, snapshot) => Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: InkWell(
                                    onTap: () {
                                      showSliderDialog(
                                        context: context,
                                        title: "Adjust speed",
                                        divisions: 10,
                                        min: 0.5,
                                        max: 2.0,
                                        value: audioPlayer.speed,
                                        stream: audioPlayer.speedStream,
                                        onChanged: audioPlayer.setSpeed,
                                      );
                                    },
                                    child: MyImage(
                                        width: 20,
                                        height: 20,
                                        color: white,
                                        imagePath: "ic_speed.png"),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Loop Node Button
                              StreamBuilder<LoopMode>(
                                stream: audioPlayer.loopModeStream,
                                builder: (context, snapshot) {
                                  final loopMode =
                                      snapshot.data ?? LoopMode.off;
                                  final icons = [
                                    Icon(Icons.repeat,
                                        color: white, size: 20.0),
                                    const Icon(Icons.repeat,
                                        color: colorPrimary, size: 20.0),
                                    const Icon(Icons.repeat_one,
                                        color: colorPrimary, size: 20.0),
                                  ];
                                  const cycleModes = [
                                    LoopMode.off,
                                    LoopMode.all,
                                    LoopMode.one,
                                  ];
                                  final index = cycleModes.indexOf(loopMode);
                                  return IconButton(
                                    icon: icons[index],
                                    onPressed: () {
                                      audioPlayer.setLoopMode(cycleModes[
                                          (cycleModes.indexOf(loopMode) + 1) %
                                              cycleModes.length]);
                                    },
                                  );
                                },
                              ),
                              const SizedBox(width: 15),
                              // Suffle Button
                              StreamBuilder<bool>(
                                stream: audioPlayer.shuffleModeEnabledStream,
                                builder: (context, snapshot) {
                                  final shuffleModeEnabled =
                                      snapshot.data ?? false;
                                  return IconButton(
                                    iconSize: 20.0,
                                    icon: shuffleModeEnabled
                                        ? const Icon(Icons.shuffle,
                                            color: colorPrimary)
                                        : Icon(Icons.shuffle, color: white),
                                    onPressed: () async {
                                      final enable = !shuffleModeEnabled;
                                      if (enable) {
                                        await audioPlayer.shuffle();
                                      }
                                      await audioPlayer
                                          .setShuffleModeEnabled(enable);
                                    },
                                  );
                                },
                              ),
                              // const SizedBox(width: 15),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    StreamBuilder<PositionData>(
                      stream: positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return ProgressBar(
                          progress: positionData?.position ?? Duration.zero,
                          buffered:
                              positionData?.bufferedPosition ?? Duration.zero,
                          total: positionData?.duration ?? Duration.zero,
                          progressBarColor: colorPrimary,
                          baseBarColor: white,
                          bufferedBarColor: gray,
                          thumbColor: colorPrimary,
                          barHeight: 2.0,
                          thumbRadius: 5.0,
                          timeLabelPadding: 5.0,
                          timeLabelType: TimeLabelType.totalTime,
                          timeLabelTextStyle: GoogleFonts.inter(
                            fontSize: 12,
                            fontStyle: FontStyle.normal,
                            color: white,
                            fontWeight: FontWeight.w700,
                          ),
                          onSeek: (duration) {
                            audioPlayer.seek(duration);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Privious Audio Setup
                        IconButton(
                          iconSize: 40,
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            color: white,
                          ),
                          onPressed: audioPlayer.hasPrevious
                              ? audioPlayer.seekToPrevious
                              : null,
                        ),
                        const SizedBox(width: 18),
                        // 10 Second Privious
                        StreamBuilder<PositionData>(
                          stream: positionDataStream,
                          builder: (context, snapshot) {
                            final positionData = snapshot.data;
                            return InkWell(
                                onTap: () {
                                  tenSecNextOrPrevious(
                                      positionData?.position.inSeconds
                                              .toString() ??
                                          "",
                                      false);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: MyImage(
                                      width: 30,
                                      height: 30,
                                      imagePath: "ic_tenprevious.png"),
                                ));
                          },
                        ),
                        // Pause and Play Controll
                        const SizedBox(width: 18),
                        StreamBuilder<PlayerState>(
                          stream: audioPlayer.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final processingState =
                                playerState?.processingState;
                            final playing = playerState?.playing;
                            if (processingState == ProcessingState.loading ||
                                processingState == ProcessingState.buffering) {
                              return Container(
                                margin: const EdgeInsets.all(8.0),
                                width: 50.0,
                                height: 50.0,
                                child: const CircularProgressIndicator(
                                  color: colorPrimary,
                                ),
                              );
                            } else if (playing != true) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: colorPrimary,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.play_arrow_rounded,
                                    color: white,
                                  ),
                                  color: white,
                                  iconSize: 50.0,
                                  onPressed: audioPlayer.play,
                                ),
                              );
                            } else if (processingState !=
                                ProcessingState.completed) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: colorPrimary,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.pause_rounded,
                                    color: white,
                                  ),
                                  iconSize: 50.0,
                                  color: white,
                                  onPressed: audioPlayer.pause,
                                ),
                              );
                            } else {
                              return IconButton(
                                icon: Icon(
                                  Icons.replay_rounded,
                                  color: white,
                                ),
                                iconSize: 60.0,
                                onPressed: () => audioPlayer.seek(Duration.zero,
                                    index: audioPlayer.effectiveIndices!.first),
                              );
                            }
                          },
                        ),
                        // 10 Second Next
                        const SizedBox(width: 18),
                        StreamBuilder<PositionData>(
                          stream: positionDataStream,
                          builder: (context, snapshot) {
                            final positionData = snapshot.data;

                            return InkWell(
                                onTap: () {
                                  tenSecNextOrPrevious(
                                      positionData?.position.inSeconds
                                              .toString() ??
                                          "",
                                      true);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: MyImage(
                                      width: 30,
                                      height: 30,
                                      imagePath: "ic_tennext.png"),
                                ));
                          },
                        ),
                        // Next Audio Play
                        const SizedBox(width: 18),
                        IconButton(
                          iconSize: 40.0,
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: white,
                          ),
                          onPressed: audioPlayer.hasNext
                              ? audioPlayer.seekToNext
                              : null,
                        ),
                      ],
                    ),
                    // const SizedBox(height: 25),
                  ],
                ),
              ),
              /* Related All Content Items */
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    MusicTitle(
                        text: ((audioPlayer.sequenceState?.currentSource?.tag
                                        as MediaItem?)
                                    ?.genre ==
                                "4")
                            ? "relatedepisode"
                            : "relatedmusic",
                        fontsizeNormal: Dimens.textExtraBig,
                        fontsizeWeb: Dimens.textExtraBig,
                        maxline: 1,
                        fontstyle: FontStyle.normal,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        multilanguage: true,
                        textalign: TextAlign.center,
                        color: white),
                    const SizedBox(height: 10),
                    ((audioPlayer.sequenceState?.currentSource?.tag
                                    as MediaItem?)
                                ?.genre ==
                            "2")
                        ? buildRelatedMusic()
                        : ((audioPlayer.sequenceState?.currentSource?.tag
                                        as MediaItem?)
                                    ?.genre ==
                                "4")
                            ? buildPodcastEpisode()
                            : ((audioPlayer.sequenceState?.currentSource?.tag
                                            as MediaItem?)
                                        ?.genre ==
                                    "5")
                                ? buildPlaylistEpisode()
                                : buildRadioEpisode(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

/* Music Penal Bottom Show */

  Widget _buildMusicPanel(
      dynamicPanelHeight, elementOpacity, progressIndicatorHeight) {
    if (!kIsWeb) {
      return Container(
        decoration: BoxDecoration(
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            Expanded(
              child: Opacity(
                opacity: elementOpacity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /* Music Image */
                    StreamBuilder<SequenceState?>(
                      stream: audioPlayer.sequenceStateStream,
                      builder: (context, snapshot) {
                        return Container(
                          width: 80,
                          height: dynamicPanelHeight,
                          padding: const EdgeInsets.fromLTRB(10, 3, 5, 3),
                          margin: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: MyNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              imagePath: ((audioPlayer.sequenceState
                                          ?.currentSource?.tag as MediaItem?)
                                      ?.artUri)
                                  .toString(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: StreamBuilder<SequenceState?>(
                          stream: audioPlayer.sequenceStateStream,
                          builder: (context, snapshot) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                  child: MyMarqueeText(
                                      text: ((audioPlayer
                                                  .sequenceState
                                                  ?.currentSource
                                                  ?.tag as MediaItem?)
                                              ?.title)
                                          .toString(),
                                      fontsize: Dimens.textBig,
                                      color: white),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                MyText(
                                    color: white,
                                    text: ((audioPlayer
                                                .sequenceState
                                                ?.currentSource
                                                ?.tag as MediaItem?)
                                            ?.displaySubtitle)
                                        .toString(),
                                    textalign: TextAlign.left,
                                    fontsizeNormal: 12,
                                    multilanguage: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            );
                          }),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          StreamBuilder<SequenceState?>(
                            stream: audioPlayer.sequenceStateStream,
                            builder: (context, snapshot) {
                              if (dynamicPanelHeight <= playerMinHeight) {
                                if (audioPlayer.hasPrevious) {
                                  return IconButton(
                                    iconSize: 25.0,
                                    icon: Icon(
                                      Icons.skip_previous_rounded,
                                      color: white,
                                    ),
                                    onPressed: audioPlayer.hasPrevious
                                        ? audioPlayer.seekToPrevious
                                        : null,
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          /* Play/Pause */
                          StreamBuilder<PlayerState>(
                            stream: audioPlayer.playerStateStream,
                            builder: (context, snapshot) {
                              if (dynamicPanelHeight <= playerMinHeight) {
                                final playerState = snapshot.data;
                                final processingState =
                                    playerState?.processingState;
                                final playing = playerState?.playing;
                                if (processingState ==
                                        ProcessingState.loading ||
                                    processingState ==
                                        ProcessingState.buffering) {
                                  return Container(
                                    margin: const EdgeInsets.all(8.0),
                                    width: 35.0,
                                    height: 35.0,
                                    child: Utils.pageLoader(context),
                                  );
                                } else if (playing != true) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.play_arrow_rounded,
                                        color: colorAccent,
                                      ),
                                      color: colorAccent,
                                      iconSize: 25.0,
                                      onPressed: audioPlayer.play,
                                    ),
                                  );
                                } else if (processingState !=
                                    ProcessingState.completed) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.pause_rounded,
                                        color: colorAccent,
                                      ),
                                      iconSize: 25.0,
                                      color: colorAccent,
                                      onPressed: audioPlayer.pause,
                                    ),
                                  );
                                } else {
                                  return IconButton(
                                    icon: Icon(
                                      Icons.replay_rounded,
                                      color: colorAccent,
                                    ),
                                    iconSize: 35.0,
                                    onPressed: () => audioPlayer.seek(
                                        Duration.zero,
                                        index: audioPlayer
                                            .effectiveIndices!.first),
                                  );
                                }
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          /* Next */
                          StreamBuilder<SequenceState?>(
                            stream: audioPlayer.sequenceStateStream,
                            builder: (context, snapshot) {
                              if (dynamicPanelHeight <= playerMinHeight) {
                                if (audioPlayer.hasNext) {
                                  return IconButton(
                                    iconSize: 25.0,
                                    icon: Icon(
                                      Icons.skip_next_rounded,
                                      color: white,
                                    ),
                                    onPressed: audioPlayer.hasNext
                                        ? audioPlayer.seekToNext
                                        : null,
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          /* Close */
                          InkWell(
                            onTap: () async {
                              printLog(
                                  "is Contiue Watching=>${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.playable}");
                              currentlyPlaying.value = null;
                              printLog("contentType=>${widget.contenttype}");
                              printLog("contentId=>${widget.contentid}");
                              printLog("episodeid=>${widget.episodeid}");
                              printLog("stopTime=>${widget.stoptime}");

                              if (Constant.userID != null) {
                                await musicDetailProvider.addContentHistory(
                                    widget.contenttype,
                                    widget.contentid,
                                    currentstoptime,
                                    widget.episodeid);
                              }

                              currentlyPlaying.value = null;
                              await audioPlayer.pause();
                              await audioPlayer.stop();
                              if (mounted) {
                                setState(() {});
                              }

                              _musicManager.clearMusicPlayer();
                              musicDetailProvider.clearProvider();
                            },
                            child: Icon(
                              Icons.close,
                              color: white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    /* Previous */
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: elementOpacity,
              child: StreamBuilder<PositionData>(
                stream: positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return ProgressBar(
                    progress: positionData?.position ?? Duration.zero,
                    buffered: positionData?.bufferedPosition ?? Duration.zero,
                    total: positionData?.duration ?? Duration.zero,
                    progressBarColor: white,
                    baseBarColor: colorPrimary,
                    bufferedBarColor: white.withOpacity(0.24),
                    barCapShape: BarCapShape.square,
                    barHeight: progressIndicatorHeight,
                    thumbRadius: 0.0,
                    timeLabelLocation: TimeLabelLocation.none,
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      if (MediaQuery.of(context).size.width > 1200) {
        return ClipRRect(
          //    borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              color: colorPrimaryDark,
              //     borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Opacity(
                  opacity: elementOpacity,
                  child: StreamBuilder<PositionData>(
                    stream: positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return ProgressBar(
                        progress: positionData?.position ?? Duration.zero,
                        buffered:
                            positionData?.bufferedPosition ?? Duration.zero,
                        total: positionData?.duration ?? Duration.zero,
                        progressBarColor: colorPrimary,
                        baseBarColor: white,
                        bufferedBarColor: gray,
                        thumbColor: colorPrimary,
                        barCapShape: BarCapShape.square,
                        barHeight: 2.0,
                        thumbRadius: 4.0,
                        timeLabelLocation: TimeLabelLocation.none,
                        onSeek: (duration) {
                          audioPlayer.seek(duration);
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Opacity(
                    opacity: elementOpacity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Row(
                        children: [
                          /* Music Details */
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                StreamBuilder<SequenceState?>(
                                  stream: audioPlayer.sequenceStateStream,
                                  builder: (context, snapshot) {
                                    return Container(
                                      width: 90,
                                      height: dynamicPanelHeight,
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: MyNetworkImage(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          imagePath: ((audioPlayer
                                                      .sequenceState
                                                      ?.currentSource
                                                      ?.tag as MediaItem?)
                                                  ?.artUri)
                                              .toString(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: MyText(
                                      color: white,
                                      text: ((audioPlayer
                                                  .sequenceState
                                                  ?.currentSource
                                                  ?.tag as MediaItem?)
                                              ?.title)
                                          .toString(),
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textTitle,
                                      multilanguage: false,
                                      maxline: 2,
                                      fontwaight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              ],
                            ),
                          ),
                          /* Play, Pause Buttons */
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                StreamBuilder<SequenceState?>(
                                  stream: audioPlayer.sequenceStateStream,
                                  builder: (context, snapshot) {
                                    if (dynamicPanelHeight <= playerMinHeight) {
                                      if (audioPlayer.hasPrevious) {
                                        return IconButton(
                                          iconSize: 25.0,
                                          icon: Icon(
                                            Icons.skip_previous_rounded,
                                            color: white,
                                          ),
                                          onPressed: audioPlayer.hasPrevious
                                              ? audioPlayer.seekToPrevious
                                              : null,
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                                const SizedBox(width: 10),
                                /* Play/Pause */
                                StreamBuilder<PlayerState>(
                                  stream: audioPlayer.playerStateStream,
                                  builder: (context, snapshot) {
                                    if (dynamicPanelHeight <= playerMinHeight) {
                                      final playerState = snapshot.data;
                                      final processingState =
                                          playerState?.processingState;
                                      final playing = playerState?.playing;
                                      if (processingState ==
                                              ProcessingState.loading ||
                                          processingState ==
                                              ProcessingState.buffering) {
                                        return Container(
                                          margin: const EdgeInsets.all(8.0),
                                          width: 35.0,
                                          height: 35.0,
                                          child: Utils.pageLoader(context),
                                        );
                                      } else if (playing != true) {
                                        return Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: white,
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.play_arrow_rounded,
                                              color: black,
                                            ),
                                            color: white,
                                            iconSize: 30.0,
                                            onPressed: audioPlayer.play,
                                          ),
                                        );
                                      } else if (processingState !=
                                          ProcessingState.completed) {
                                        return Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.pause_rounded,
                                              color: black,
                                            ),
                                            iconSize: 30.0,
                                            color: white,
                                            onPressed: audioPlayer.pause,
                                          ),
                                        );
                                      } else {
                                        return IconButton(
                                          icon: Icon(
                                            Icons.replay_rounded,
                                            color: white,
                                          ),
                                          iconSize: 35.0,
                                          onPressed: () => audioPlayer.seek(
                                              Duration.zero,
                                              index: audioPlayer
                                                  .effectiveIndices!.first),
                                        );
                                      }
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                                const SizedBox(width: 10),
                                /* Next */
                                StreamBuilder<SequenceState?>(
                                  stream: audioPlayer.sequenceStateStream,
                                  builder: (context, snapshot) {
                                    if (dynamicPanelHeight <= playerMinHeight) {
                                      if (audioPlayer.hasNext) {
                                        return IconButton(
                                          iconSize: 25.0,
                                          icon: Icon(
                                            Icons.skip_next_rounded,
                                            color: white,
                                          ),
                                          onPressed: audioPlayer.hasNext
                                              ? audioPlayer.seekToNext
                                              : null,
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          /* Other Buttons */
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                StreamBuilder<PositionData>(
                                  stream: positionDataStream,
                                  builder: (context, snapshot) {
                                    final positionData = snapshot.data;
                                    return InkWell(
                                        onTap: () {
                                          tenSecNextOrPrevious(
                                              positionData?.position.inSeconds
                                                      .toString() ??
                                                  "",
                                              false);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: MyImage(
                                              width: 25,
                                              height: 25,
                                              imagePath: "ic_tenprevious.png"),
                                        ));
                                  },
                                ),
                                const SizedBox(width: 20),
                                StreamBuilder<PositionData>(
                                  stream: positionDataStream,
                                  builder: (context, snapshot) {
                                    final positionData = snapshot.data;

                                    return InkWell(
                                        onTap: () {
                                          tenSecNextOrPrevious(
                                              positionData?.position.inSeconds
                                                      .toString() ??
                                                  "",
                                              true);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: MyImage(
                                              width: 25,
                                              height: 25,
                                              imagePath: "ic_tennext.png"),
                                        ));
                                  },
                                ),
                                const SizedBox(width: 20),

                                /* Like Dislike  */
                                (audioPlayer.sequenceState?.currentSource?.tag
                                                    as MediaItem?)
                                                ?.genre ==
                                            "5" ||
                                        (audioPlayer
                                                    .sequenceState
                                                    ?.currentSource
                                                    ?.tag as MediaItem?)
                                                ?.genre ==
                                            "6"
                                    ? const SizedBox.shrink()
                                    : (audioPlayer.sequenceState?.currentSource
                                                    ?.tag as MediaItem?)
                                                ?.extras?['is_like'] ==
                                            1
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  if (Constant.userID == null) {
                                                    if (kIsWeb) {
                                                      Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          pageBuilder: (context,
                                                                  animation1,
                                                                  animation2) =>
                                                              const WebLogin(),
                                                          transitionDuration:
                                                              Duration.zero,
                                                          reverseTransitionDuration:
                                                              Duration.zero,
                                                        ),
                                                      );
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return const Login();
                                                          },
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    if ((audioPlayer
                                                                .sequenceState
                                                                ?.currentSource
                                                                ?.tag as MediaItem?)
                                                            ?.extras?['is_like'] ==
                                                        0) {
                                                      Utils().showSnackBar(
                                                          context,
                                                          "youcannotlikethiscontent",
                                                          true);
                                                    } else {
                                                      like();
                                                    }
                                                  }
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    (audioPlayer.sequenceState?.currentSource
                                                                            ?.tag
                                                                        as MediaItem?)
                                                                    ?.extras?[
                                                                'is_user_like_dislike'] ==
                                                            1
                                                        ? MyImage(
                                                            width: 20,
                                                            height: 20,
                                                            fit: BoxFit.cover,
                                                            color: colorPrimary,
                                                            imagePath:
                                                                "ic_likefill.png",
                                                          )
                                                        : MyImage(
                                                            width: 20,
                                                            height: 20,
                                                            imagePath:
                                                                "ic_like.png",
                                                          ),
                                                    const SizedBox(width: 8),
                                                    MyText(
                                                        color: white,
                                                        text: Utils.kmbGenerator(int.parse(((audioPlayer
                                                                            .sequenceState
                                                                            ?.currentSource
                                                                            ?.tag
                                                                        as MediaItem?)
                                                                    ?.extras?[
                                                                'total_like'])
                                                            .toString())),
                                                        multilanguage: false,
                                                        textalign:
                                                            TextAlign.center,
                                                        fontsizeNormal:
                                                            Dimens.textTitle,
                                                        inter: false,
                                                        maxline: 6,
                                                        fontwaight:
                                                            FontWeight.w600,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontstyle:
                                                            FontStyle.normal),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                const SizedBox(width: 20),
                                /* Close Audio Player */
                                InkWell(
                                  onTap: () async {
                                    printLog(
                                        "is Contiue Watching=>${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.playable}");
                                    currentlyPlaying.value = null;
                                    printLog(
                                        "contentType=>${widget.contenttype}");
                                    printLog("contentId=>${widget.contentid}");
                                    printLog("episodeid=>${widget.episodeid}");
                                    printLog("stopTime=>${widget.stoptime}");

                                    if (Constant.userID != null) {
                                      await musicDetailProvider
                                          .addContentHistory(
                                              widget.contenttype,
                                              widget.contentid,
                                              currentstoptime,
                                              widget.episodeid);
                                    }

                                    currentlyPlaying.value = null;
                                    await audioPlayer.pause();
                                    await audioPlayer.stop();
                                    if (mounted) {
                                      setState(() {});
                                    }

                                    _musicManager.clearMusicPlayer();
                                    musicDetailProvider.clearProvider();
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return ClipRRect(
          //     borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              color: colorPrimaryDark,
              //       borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Opacity(
                  opacity: elementOpacity,
                  child: StreamBuilder<PositionData>(
                    stream: positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return ProgressBar(
                        progress: positionData?.position ?? Duration.zero,
                        buffered:
                            positionData?.bufferedPosition ?? Duration.zero,
                        total: positionData?.duration ?? Duration.zero,
                        progressBarColor: colorPrimary,
                        baseBarColor: white,
                        bufferedBarColor: gray,
                        thumbColor: colorPrimary,
                        barCapShape: BarCapShape.square,
                        barHeight: 2.0,
                        thumbRadius: 4.0,
                        timeLabelLocation: TimeLabelLocation.none,
                        onSeek: (duration) {
                          audioPlayer.seek(duration);
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Opacity(
                    opacity: elementOpacity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /* Music Details */
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                StreamBuilder<SequenceState?>(
                                  stream: audioPlayer.sequenceStateStream,
                                  builder: (context, snapshot) {
                                    return Container(
                                      width: 90,
                                      height: dynamicPanelHeight,
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: MyNetworkImage(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          imagePath: ((audioPlayer
                                                      .sequenceState
                                                      ?.currentSource
                                                      ?.tag as MediaItem?)
                                                  ?.artUri)
                                              .toString(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: MyText(
                                      color: white,
                                      text: ((audioPlayer
                                                  .sequenceState
                                                  ?.currentSource
                                                  ?.tag as MediaItem?)
                                              ?.title)
                                          .toString(),
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textTitle,
                                      multilanguage: false,
                                      maxline: 2,
                                      fontwaight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              ],
                            ),
                          ),
                          /* Play, Pause Buttons */
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              StreamBuilder<SequenceState?>(
                                stream: audioPlayer.sequenceStateStream,
                                builder: (context, snapshot) {
                                  if (dynamicPanelHeight <= playerMinHeight) {
                                    if (audioPlayer.hasPrevious) {
                                      return IconButton(
                                        iconSize: 25.0,
                                        icon: Icon(
                                          Icons.skip_previous_rounded,
                                          color: white,
                                        ),
                                        onPressed: audioPlayer.hasPrevious
                                            ? audioPlayer.seekToPrevious
                                            : null,
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                              const SizedBox(width: 10),
                              StreamBuilder<PlayerState>(
                                stream: audioPlayer.playerStateStream,
                                builder: (context, snapshot) {
                                  if (dynamicPanelHeight <= playerMinHeight) {
                                    final playerState = snapshot.data;
                                    final processingState =
                                        playerState?.processingState;
                                    final playing = playerState?.playing;
                                    if (processingState ==
                                            ProcessingState.loading ||
                                        processingState ==
                                            ProcessingState.buffering) {
                                      return Container(
                                        margin: const EdgeInsets.all(8.0),
                                        width: 35.0,
                                        height: 35.0,
                                        child: Utils.pageLoader(context),
                                      );
                                    } else if (playing != true) {
                                      return Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: white,
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.play_arrow_rounded,
                                            color: black,
                                          ),
                                          color: white,
                                          iconSize: 30.0,
                                          onPressed: audioPlayer.play,
                                        ),
                                      );
                                    } else if (processingState !=
                                        ProcessingState.completed) {
                                      return Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.pause_rounded,
                                            color: black,
                                          ),
                                          iconSize: 30.0,
                                          color: white,
                                          onPressed: audioPlayer.pause,
                                        ),
                                      );
                                    } else {
                                      return IconButton(
                                        icon: Icon(
                                          Icons.replay_rounded,
                                          color: white,
                                        ),
                                        iconSize: 35.0,
                                        onPressed: () => audioPlayer.seek(
                                            Duration.zero,
                                            index: audioPlayer
                                                .effectiveIndices!.first),
                                      );
                                    }
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                              const SizedBox(width: 10),
                              /* Next */
                              StreamBuilder<SequenceState?>(
                                stream: audioPlayer.sequenceStateStream,
                                builder: (context, snapshot) {
                                  if (dynamicPanelHeight <= playerMinHeight) {
                                    if (audioPlayer.hasNext) {
                                      return IconButton(
                                        iconSize: 25.0,
                                        icon: Icon(
                                          Icons.skip_next_rounded,
                                          color: white,
                                        ),
                                        onPressed: audioPlayer.hasNext
                                            ? audioPlayer.seekToNext
                                            : null,
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                              const SizedBox(width: 10),
                              /* Close Audio Player */
                              InkWell(
                                onTap: () async {
                                  printLog(
                                      "is Contiue Watching=>${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.playable}");
                                  currentlyPlaying.value = null;
                                  printLog(
                                      "contentType=>${widget.contenttype}");
                                  printLog("contentId=>${widget.contentid}");
                                  printLog("episodeid=>${widget.episodeid}");
                                  printLog("stopTime=>${widget.stoptime}");

                                  if (Constant.userID != null) {
                                    await musicDetailProvider.addContentHistory(
                                        widget.contenttype,
                                        widget.contentid,
                                        currentstoptime,
                                        widget.episodeid);
                                  }

                                  currentlyPlaying.value = null;
                                  await audioPlayer.pause();
                                  await audioPlayer.stop();
                                  if (mounted) {
                                    setState(() {});
                                  }

                                  _musicManager.clearMusicPlayer();
                                  musicDetailProvider.clearProvider();
                                },
                                child: Icon(
                                  Icons.close,
                                  color: white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  Widget buildPodcastEpisode() {
    return Consumer<MusicDetailProvider>(
        builder: (context, episodeprovider, child) {
      if (episodeprovider.epidoseByPodcastModel.status == 200 &&
          episodeprovider.podcastEpisodeList != null) {
        if ((episodeprovider.podcastEpisodeList?.length ?? 0) > 0) {
          print('episodeprovider.podcastEpisodeList?.length');
          print(episodeprovider.podcastEpisodeList?.length);
          return ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 1,
            maxItemsPerRow: 1,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(
                episodeprovider.podcastEpisodeList?.length ?? 0, (index) {
              return InkWell(
                hoverColor: transparent,
                highlightColor: transparent,
                splashColor: transparent,
                focusColor: transparent,
                onTap: () async {
                  _musicManager.setInitialPodcast(
                    context,
                    ((audioPlayer.sequenceState?.currentSource?.tag
                                as MediaItem?)
                            ?.id)
                        .toString(),
                    index,
                    ((audioPlayer.sequenceState?.currentSource?.tag
                                as MediaItem?)
                            ?.genre)
                        .toString(),
                    episodeprovider.podcastEpisodeList,
                    ((audioPlayer.sequenceState?.currentSource?.tag
                                as MediaItem?)
                            ?.album)
                        .toString(),
                    addView(
                      ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.genre)
                          .toString(),
                      ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.album)
                          .toString(),
                    ),
                    false,
                    0,
                    ((audioPlayer.sequenceState?.currentSource?.tag
                                as MediaItem?)
                            ?.extras?['is_buy'])
                        .toString(),
                    "podcast",
                  );
                },
                child: kIsWeb
                    ? InteractiveContainer(child: (isHovered) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: Row(
                            children: [
                              MusicTitle(
                                  color: white,
                                  text: "${index + 1}",
                                  fontsizeNormal: Dimens.textSmall,
                                  fontsizeWeb: Dimens.textSmall,
                                  fontwaight: FontWeight.w400,
                                  multilanguage: false,
                                  maxline: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textalign: TextAlign.left,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(width: 12),
                              Stack(
                                children: [
                                  Container(
                                    width: 55,
                                    height: 55,
                                    alignment: Alignment.center,
                                    foregroundDecoration: isHovered
                                        ? BoxDecoration(
                                            gradient: LinearGradient(
                                            colors: [
                                              appbgcolor.withOpacity(0.50),
                                              appbgcolor.withOpacity(0.50)
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ))
                                        : null,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: MyNetworkImage(
                                          fit: BoxFit.cover,
                                          imagePath: episodeprovider
                                                  .podcastEpisodeList?[index]
                                                  .portraitImg
                                                  .toString() ??
                                              ""),
                                    ),
                                  ),
                                  isHovered
                                      ? Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.play_arrow,
                                              color: white,
                                              size: 25,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MusicTitle(
                                        color: white,
                                        text: episodeprovider
                                                .podcastEpisodeList?[index].name
                                                .toString() ??
                                            "",
                                        fontsizeNormal: Dimens.textSmall,
                                        fontsizeWeb: Dimens.textSmall,
                                        fontwaight: FontWeight.w600,
                                        multilanguage: false,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textalign: TextAlign.left,
                                        fontstyle: FontStyle.normal),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            MyText(
                                                color: gray,
                                                text: Utils.kmbGenerator(
                                                  episodeprovider
                                                          .podcastEpisodeList?[
                                                              index]
                                                          .totalView ??
                                                      0,
                                                ),
                                                fontsizeNormal:
                                                    Dimens.textSmall,
                                                fontsizeWeb: Dimens.textSmall,
                                                fontwaight: FontWeight.w400,
                                                multilanguage: false,
                                                maxline: 1,
                                                overflow: TextOverflow.ellipsis,
                                                inter: false,
                                                textalign: TextAlign.left,
                                                fontstyle: FontStyle.normal),
                                            const SizedBox(width: 5),
                                            MyText(
                                                color: gray,
                                                text: "views",
                                                fontsizeNormal:
                                                    Dimens.textSmall,
                                                fontsizeWeb: Dimens.textSmall,
                                                fontwaight: FontWeight.w400,
                                                multilanguage: true,
                                                maxline: 1,
                                                overflow: TextOverflow.ellipsis,
                                                inter: false,
                                                textalign: TextAlign.left,
                                                fontstyle: FontStyle.normal),
                                          ],
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: MyText(
                                              color: gray,
                                              text: Utils.timeAgoCustom(
                                                DateTime.parse(
                                                  episodeprovider
                                                          .podcastEpisodeList?[
                                                              index]
                                                          .createdAt ??
                                                      "",
                                                ),
                                              ),
                                              fontsizeNormal: Dimens.textSmall,
                                              fontsizeWeb: Dimens.textSmall,
                                              fontwaight: FontWeight.w400,
                                              multilanguage: false,
                                              maxline: 1,
                                              overflow: TextOverflow.ellipsis,
                                              inter: false,
                                              textalign: TextAlign.left,
                                              fontstyle: FontStyle.normal),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    : Container(
                        color: ((audioPlayer.sequenceState?.currentSource?.tag
                                            as MediaItem?)
                                        ?.id)
                                    .toString() ==
                                episodeprovider.podcastEpisodeList?[index].id
                                    .toString()
                            ? colorPrimary.withOpacity(0.10)
                            : colorPrimaryDark,
                        height: 75,
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: Row(children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: colorPrimary),
                                ),
                                child: MyNetworkImage(
                                    fit: BoxFit.cover,
                                    width: 70,
                                    imagePath: episodeprovider
                                            .podcastEpisodeList?[index]
                                            .portraitImg
                                            .toString() ??
                                        ""),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: ((audioPlayer
                                                      .sequenceState
                                                      ?.currentSource
                                                      ?.tag as MediaItem?)
                                                  ?.id)
                                              .toString() ==
                                          episodeprovider
                                              .podcastEpisodeList?[index].id
                                              .toString()
                                      ? MyImage(
                                          width: 30,
                                          height: 30,
                                          imagePath: "music.gif")
                                      : const SizedBox.shrink(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                    color: white,
                                    multilanguage: false,
                                    text: episodeprovider
                                            .podcastEpisodeList?[index].name
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textMedium,
                                    inter: false,
                                    maxline: 2,
                                    fontwaight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                MyText(
                                    color: white,
                                    multilanguage: false,
                                    text: episodeprovider
                                            .podcastEpisodeList?[index]
                                            .description
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textSmall,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ),
                        ]),
                      ),
              );
            }),
          );
        } else {
          return const NoData(title: "", subTitle: "");
        }
      } else {
        return const NoData(title: "", subTitle: "");
      }
    });
  }

  Widget buildRadioEpisode() {
    return Consumer<MusicDetailProvider>(
        builder: (context, episodeprovider, child) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 1,
          maxItemsPerRow: 1,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 10,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
              episodeprovider.epidoseByRadioModel.result?.length ?? 0, (index) {
            return InkWell(
              onTap: () {
                _musicManager.setInitialRadio(
                    index,
                    ((audioPlayer.sequenceState?.currentSource?.tag
                                as MediaItem?)
                            ?.genre)
                        .toString(),
                    episodeprovider.epidoseByPodcastModel.result,
                    ((audioPlayer.sequenceState?.currentSource?.tag
                                as MediaItem?)
                            ?.album)
                        .toString(),
                    addView(
                      ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.genre)
                          .toString(),
                      ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.album)
                          .toString(),
                    ),
                    (audioPlayer.sequenceState?.currentSource?.tag
                            as MediaItem?)
                        ?.extras?['is_buy']);
              },
              child: kIsWeb
                  ? InteractiveContainer(child: (isHovered) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Row(
                          children: [
                            MusicTitle(
                                color: white,
                                text: "${index + 1}",
                                fontsizeNormal: Dimens.textSmall,
                                fontsizeWeb: Dimens.textSmall,
                                fontwaight: FontWeight.w400,
                                multilanguage: false,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.left,
                                fontstyle: FontStyle.normal),
                            const SizedBox(width: 12),
                            Stack(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  alignment: Alignment.center,
                                  foregroundDecoration: isHovered
                                      ? BoxDecoration(
                                          gradient: LinearGradient(
                                          colors: [
                                            appbgcolor.withOpacity(0.50),
                                            appbgcolor.withOpacity(0.50)
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ))
                                      : null,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: MyNetworkImage(
                                      fit: BoxFit.cover,
                                      imagePath: episodeprovider
                                              .epidoseByRadioModel
                                              .result?[index]
                                              .landscapeImg
                                              .toString() ??
                                          "",
                                    ),
                                  ),
                                ),
                                isHovered
                                    ? Positioned.fill(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.play_arrow,
                                            color: white,
                                            size: 25,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink()
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MusicTitle(
                                      color: white,
                                      text: episodeprovider.epidoseByRadioModel
                                              .result?[index].title
                                              .toString() ??
                                          "",
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      fontwaight: FontWeight.w400,
                                      multilanguage: false,
                                      maxline: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          MyText(
                                              color: gray,
                                              text: Utils.kmbGenerator(
                                                  episodeprovider
                                                          .epidoseByRadioModel
                                                          .result?[index]
                                                          .totalView ??
                                                      0),
                                              fontsizeNormal: Dimens.textSmall,
                                              fontsizeWeb: Dimens.textSmall,
                                              fontwaight: FontWeight.w400,
                                              multilanguage: false,
                                              maxline: 1,
                                              overflow: TextOverflow.ellipsis,
                                              inter: false,
                                              textalign: TextAlign.left,
                                              fontstyle: FontStyle.normal),
                                          const SizedBox(width: 5),
                                          MyText(
                                              color: gray,
                                              text: "views",
                                              fontsizeNormal: Dimens.textSmall,
                                              fontsizeWeb: Dimens.textSmall,
                                              fontwaight: FontWeight.w400,
                                              multilanguage: true,
                                              maxline: 1,
                                              overflow: TextOverflow.ellipsis,
                                              inter: false,
                                              textalign: TextAlign.left,
                                              fontstyle: FontStyle.normal),
                                        ],
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: MyText(
                                            color: gray,
                                            text: Utils.timeAgoCustom(
                                              DateTime.parse(episodeprovider
                                                      .epidoseByRadioModel
                                                      .result?[index]
                                                      .createdAt
                                                      .toString() ??
                                                  ""),
                                            ),
                                            fontsizeNormal: Dimens.textSmall,
                                            fontsizeWeb: Dimens.textSmall,
                                            fontwaight: FontWeight.w400,
                                            multilanguage: false,
                                            maxline: 1,
                                            overflow: TextOverflow.ellipsis,
                                            inter: false,
                                            textalign: TextAlign.left,
                                            fontstyle: FontStyle.normal),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                  : Container(
                      color: ((audioPlayer.sequenceState?.currentSource?.tag
                                          as MediaItem?)
                                      ?.id)
                                  .toString() ==
                              episodeprovider
                                  .epidoseByRadioModel.result?[index].id
                                  .toString()
                          ? colorPrimary.withOpacity(0.10)
                          : colorPrimaryDark,
                      height: 85,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: colorPrimary),
                              ),
                              child: MyNetworkImage(
                                  fit: BoxFit.cover,
                                  width: 70,
                                  imagePath: episodeprovider.epidoseByRadioModel
                                          .result?[index].portraitImg
                                          .toString() ??
                                      ""),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: ((audioPlayer
                                                    .sequenceState
                                                    ?.currentSource
                                                    ?.tag as MediaItem?)
                                                ?.id)
                                            .toString() ==
                                        episodeprovider.epidoseByRadioModel
                                            .result?[index].id
                                            .toString()
                                    ? MyImage(
                                        width: 30,
                                        height: 30,
                                        imagePath: "music.gif")
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  color: white,
                                  multilanguage: false,
                                  text: episodeprovider.epidoseByRadioModel
                                          .result?[index].title
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textMedium,
                                  inter: false,
                                  maxline: 2,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 8),
                              MyText(
                                  color: white,
                                  multilanguage: false,
                                  text: episodeprovider.epidoseByRadioModel
                                          .result?[index].description
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textSmall,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          ),
                        )
                      ]),
                    ),
            );
          }),
        ),
      );
    });
  }

  Widget buildPlaylistEpisode() {
    return Consumer<MusicDetailProvider>(
        builder: (context, episodeprovider, child) {
      if (episodeprovider.episodebyplaylistModel.status == 200 &&
          episodeprovider.playlistEpisodeList != null) {
        if ((episodeprovider.playlistEpisodeList?.length ?? 0) > 0) {
          return ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 1,
            maxItemsPerRow: 1,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(
                episodeprovider.playlistEpisodeList?.length ?? 0, (index) {
              return InkWell(
                onTap: () {
                  _musicManager.setInitialPlayList(
                      index,
                      ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.genre)
                          .toString(),
                      episodeprovider.playlistEpisodeList,
                      ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.album)
                          .toString(),
                      addView(
                        ((audioPlayer.sequenceState?.currentSource?.tag
                                    as MediaItem?)
                                ?.genre)
                            .toString(),
                        ((audioPlayer.sequenceState?.currentSource?.tag
                                    as MediaItem?)
                                ?.album)
                            .toString(),
                      ),
                      (audioPlayer.sequenceState?.currentSource?.tag
                              as MediaItem?)
                          ?.extras?['is_buy']);
                },
                child: kIsWeb
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Row(
                          children: [
                            MusicTitle(
                                color: white,
                                text: "${index + 1}",
                                fontsizeNormal: Dimens.textSmall,
                                fontsizeWeb: Dimens.textSmall,
                                fontwaight: FontWeight.w400,
                                multilanguage: false,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.left,
                                fontstyle: FontStyle.normal),
                            const SizedBox(width: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: MyNetworkImage(
                                  width: 55,
                                  height: 55,
                                  imagePath: episodeprovider
                                          .playlistEpisodeList?[index]
                                          .portraitImg
                                          .toString() ??
                                      "",
                                  fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MusicTitle(
                                      color: white,
                                      text: episodeprovider
                                              .playlistEpisodeList?[index].title
                                              .toString() ??
                                          "",
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      fontwaight: FontWeight.w400,
                                      multilanguage: false,
                                      maxline: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          MyText(
                                              color: gray,
                                              text: Utils.kmbGenerator(
                                                  episodeprovider
                                                          .playlistEpisodeList?[
                                                              index]
                                                          .totalView ??
                                                      0),
                                              fontsizeNormal: Dimens.textSmall,
                                              fontsizeWeb: Dimens.textSmall,
                                              fontwaight: FontWeight.w400,
                                              multilanguage: false,
                                              maxline: 1,
                                              overflow: TextOverflow.ellipsis,
                                              inter: false,
                                              textalign: TextAlign.left,
                                              fontstyle: FontStyle.normal),
                                          const SizedBox(width: 5),
                                          MyText(
                                              color: gray,
                                              text: "views",
                                              fontsizeNormal: Dimens.textSmall,
                                              fontsizeWeb: Dimens.textSmall,
                                              fontwaight: FontWeight.w400,
                                              multilanguage: true,
                                              maxline: 1,
                                              overflow: TextOverflow.ellipsis,
                                              inter: false,
                                              textalign: TextAlign.left,
                                              fontstyle: FontStyle.normal),
                                        ],
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: MyText(
                                            color: gray,
                                            text: Utils.timeAgoCustom(
                                              DateTime.parse(episodeprovider
                                                      .playlistEpisodeList?[
                                                          index]
                                                      .createdAt
                                                      .toString() ??
                                                  ""),
                                            ),
                                            fontsizeNormal: Dimens.textSmall,
                                            fontsizeWeb: Dimens.textSmall,
                                            fontwaight: FontWeight.w400,
                                            multilanguage: false,
                                            maxline: 1,
                                            overflow: TextOverflow.ellipsis,
                                            inter: false,
                                            textalign: TextAlign.left,
                                            fontstyle: FontStyle.normal),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        color: ((audioPlayer.sequenceState?.currentSource?.tag
                                            as MediaItem?)
                                        ?.id)
                                    .toString() ==
                                episodeprovider.playlistEpisodeList?[index].id
                                    .toString()
                            ? colorPrimary.withOpacity(0.10)
                            : colorPrimaryDark,
                        height: 85,
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: Row(children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: colorPrimary),
                                ),
                                child: MyNetworkImage(
                                    fit: BoxFit.cover,
                                    width: 70,
                                    imagePath: episodeprovider
                                            .playlistEpisodeList?[index]
                                            .portraitImg
                                            .toString() ??
                                        ""),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: ((audioPlayer
                                                      .sequenceState
                                                      ?.currentSource
                                                      ?.tag as MediaItem?)
                                                  ?.id)
                                              .toString() ==
                                          episodeprovider
                                              .playlistEpisodeList?[index].id
                                              .toString()
                                      ? MyImage(
                                          width: 30,
                                          height: 30,
                                          imagePath: "music.gif")
                                      : const SizedBox.shrink(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                    color: white,
                                    multilanguage: false,
                                    text: episodeprovider
                                            .playlistEpisodeList?[index].title
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textMedium,
                                    inter: false,
                                    maxline: 2,
                                    fontwaight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                const SizedBox(height: 8),
                                MyText(
                                    color: white,
                                    multilanguage: false,
                                    text: episodeprovider
                                            .playlistEpisodeList?[index]
                                            .description
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textSmall,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          )
                        ]),
                      ),
              );
            }),
          );
        } else {
          return const NoData(title: "", subTitle: "");
        }
      } else {
        return const NoData(title: "", subTitle: "");
      }
    });
  }

  Widget detailItemPodcast() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['name'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textBig,
              inter: false,
              maxline: 5,
              fontwaight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          const SizedBox(height: 20),
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['description'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textMedium,
              inter: false,
              maxline: 100,
              fontwaight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          const SizedBox(height: 20),
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['podcasts_name'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textTitle,
              inter: false,
              maxline: 2,
              fontwaight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
        ],
      ),
    );
  }

  Widget detailItemMusicRadioPlaylist() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['title'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textBig,
              inter: false,
              maxline: 5,
              fontwaight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          const SizedBox(height: 20),
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['description'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textMedium,
              inter: false,
              maxline: 100,
              fontwaight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre)
                      .toString() ==
                  "playlist"
              ? MyText(
                  color: white,
                  text: (audioPlayer.sequenceState?.currentSource?.tag
                          as MediaItem?)
                      ?.extras?['channel_name'],
                  multilanguage: false,
                  textalign: TextAlign.left,
                  fontsizeNormal: Dimens.textMedium,
                  inter: false,
                  maxline: 100,
                  fontwaight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget buildRelatedMusic() {
    return Consumer<MusicDetailProvider>(
        builder: (context, musicdetailprovider, child) {
      if (musicdetailprovider.loading && !musicdetailprovider.loadmore) {
        return relatedMusicShimmer();
      } else {
        if (musicdetailprovider.relatedMusicModel.status == 200 &&
            musicdetailprovider.relatedMusicList != null) {
          if ((musicdetailprovider.relatedMusicList?.length ?? 0) > 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                relatedMusicList(),
                if (musicdetailprovider.loadmore)
                  SizedBox(height: 50, child: Utils.pageLoader(context))
                else
                  const SizedBox.shrink(),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return const SizedBox.shrink();
        }
      }
    });
  }

  Widget relatedMusicList() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 1,
          maxItemsPerRow: 1,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 10,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
              musicDetailProvider.relatedMusicList?.length ?? 0, (index) {
            return InkWell(
              onTap: () async {
                _musicManager.setInitialMusic(
                  index,
                  musicDetailProvider.relatedMusicList?[index].contentType
                          .toString() ??
                      "",
                  musicDetailProvider.relatedMusicList ?? [],
                  musicDetailProvider.relatedMusicList?[index].id.toString() ??
                      "",
                  addView(
                    musicDetailProvider.relatedMusicList?[index].contentType
                            .toString() ??
                        "",
                    musicDetailProvider.relatedMusicList?[index].id
                            .toString() ??
                        "",
                  ),
                  false,
                  0,
                  musicDetailProvider.relatedMusicList?[index].isBuy
                          .toString() ??
                      "",
                );
              },
              child: InteractiveContainer(child: (isHovered) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                  child: Row(
                    children: [
                      MusicTitle(
                          color: white,
                          text: "${index + 1}",
                          fontsizeNormal: Dimens.textSmall,
                          fontsizeWeb: Dimens.textSmall,
                          fontwaight: FontWeight.w400,
                          multilanguage: false,
                          maxline: 2,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.left,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 12),
                      Stack(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            foregroundDecoration: isHovered
                                ? BoxDecoration(
                                    gradient: LinearGradient(
                                    colors: [
                                      appbgcolor.withOpacity(0.50),
                                      appbgcolor.withOpacity(0.50)
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ))
                                : null,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: MyNetworkImage(
                                fit: BoxFit.cover,
                                imagePath: musicDetailProvider
                                        .relatedMusicList?[index].landscapeImg
                                        .toString() ??
                                    "",
                              ),
                            ),
                          ),
                          isHovered
                              ? Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: white,
                                      size: 25,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MusicTitle(
                                color: white,
                                text: musicDetailProvider
                                        .relatedMusicList?[index].title
                                        .toString() ??
                                    "",
                                fontsizeNormal: Dimens.textMedium,
                                fontsizeWeb: Dimens.textMedium,
                                fontwaight: FontWeight.w400,
                                multilanguage: false,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.left,
                                fontstyle: FontStyle.normal),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    MyText(
                                        color: gray,
                                        text: Utils.kmbGenerator(
                                            musicDetailProvider
                                                    .relatedMusicList?[0]
                                                    .totalView ??
                                                0),
                                        fontsizeNormal: Dimens.textSmall,
                                        fontsizeWeb: Dimens.textSmall,
                                        fontwaight: FontWeight.w400,
                                        multilanguage: false,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        inter: false,
                                        textalign: TextAlign.left,
                                        fontstyle: FontStyle.normal),
                                    const SizedBox(width: 5),
                                    MyText(
                                        color: gray,
                                        text: "views",
                                        fontsizeNormal: Dimens.textSmall,
                                        fontsizeWeb: Dimens.textSmall,
                                        fontwaight: FontWeight.w400,
                                        multilanguage: true,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        inter: false,
                                        textalign: TextAlign.left,
                                        fontstyle: FontStyle.normal),
                                  ],
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: MyText(
                                      color: gray,
                                      text: Utils.timeAgoCustom(
                                        DateTime.parse(
                                          musicDetailProvider
                                                  .relatedMusicList?[index]
                                                  .createdAt ??
                                              "",
                                        ),
                                      ),
                                      fontsizeNormal: Dimens.textSmall,
                                      fontsizeWeb: Dimens.textSmall,
                                      fontwaight: FontWeight.w400,
                                      multilanguage: false,
                                      maxline: 1,
                                      overflow: TextOverflow.ellipsis,
                                      inter: false,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          })),
    );
  }

  Widget relatedMusicShimmer() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (BuildContext ctx, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Row(
            children: [
              CustomWidget.roundrectborder(
                width: MediaQuery.of(context).size.width > 1200 ? 120 : 200,
                height: MediaQuery.of(context).size.width > 1200 ? 75 : 105,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(
                      height: 10,
                    ),
                    SizedBox(height: 5),
                    CustomWidget.roundrectborder(
                      height: 10,
                    ),
                    SizedBox(height: 5),
                    CustomWidget.roundrectborder(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  tenSecNextOrPrevious(String audioposition, bool isnext) {
    dynamic firstHalf = Duration(seconds: int.parse(audioposition));
    const secondHalf = Duration(seconds: 10);
    Duration movePosition;
    if (isnext == true) {
      movePosition = firstHalf + secondHalf;
    } else {
      movePosition = firstHalf - secondHalf;
    }

    _musicManager.seek(movePosition);
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
  }

  like() async {
    final musicprovider = Provider.of<MusicProvider>(context, listen: false);
    final contentDetailprovider =
        Provider.of<ContentDetailProvider>(context, listen: false);

    String songid = (audioPlayer
                    .sequenceState?.currentSource?.tag as MediaItem?)
                ?.genre ==
            "4"
        ? ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album)
            .toString()
        : ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.id)
            .toString();

    log("is_user_like_dislike==> ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.extras?['is_user_like_dislike']}");
    log("contentType==> ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre}");

    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.extras?['is_user_like_dislike'] ==
        0) {
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
          ?.extras?['is_user_like_dislike'] = 1;
      log("is_user_like_dislike1==> ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.extras?['is_user_like_dislike']}");
      log("Like Succsessfully");
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_like'] =
          ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.extras?['total_like']) +
              1;

      await musicDetailProvider.addLikeDislike(
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre,
          songid,
          "1",
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.genre ==
                  "4"
              ? (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.id
              : "0");
    } else if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.extras?['is_user_like_dislike'] ==
        2) {
      log("Call This APi");
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
          ?.extras?['is_user_like_dislike'] = 1;
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_like'] =
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.extras?['total_like'] +
              1;
      if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_dislike'] >
          0) {
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.extras?['total_dislike'] =
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['total_dislike'] -
                1;
      }

      await musicDetailProvider.addLikeDislike(
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre,
          songid,
          "1",
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.genre ==
                  "4"
              ? (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.id
              : "0");
    } else {
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
          ?.extras?['is_user_like_dislike'] = 0;
      if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_like'] >
          0) {
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.extras?['total_like'] =
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['total_like'] -
                1;
        log("Dislike Succsessfully");
        await musicDetailProvider.addLikeDislike(
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.genre,
            songid,
            "0",
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.genre ==
                    "4"
                ? (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.id
                : "0");
      }
    }

    if (!mounted) return;
    setState(() {});

    /* Update Music Section */
    await musicprovider.getSeactionList("1", "0", "1");
    await contentDetailprovider.getEpisodeByPodcast(
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album,
        "1");

    await contentDetailprovider.getEpisodeByRadio(
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album,
        "1");

    await contentDetailprovider.getEpisodeByPlaylist(
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album,
        "2",
        "1");
  }

  dislike() async {
    final musicprovider = Provider.of<MusicProvider>(context, listen: false);

    final contentDetailprovider =
        Provider.of<ContentDetailProvider>(context, listen: false);

    String songid = (audioPlayer
                    .sequenceState?.currentSource?.tag as MediaItem?)
                ?.genre ==
            "4"
        ? ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album)
            .toString()
        : ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.id)
            .toString();

    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.extras?['is_user_like_dislike'] ==
        0) {
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
          ?.extras?['is_user_like_dislike'] = 2;
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_dislike'] =
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.extras?['total_dislike'] +
              1;
    } else if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.extras?['is_user_like_dislike'] ==
        1) {
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
          ?.extras?['is_user_like_dislike'] = 2;
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_dislike'] =
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.extras?['total_dislike'] +
              1;
      if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_like'] >
          0) {
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.extras?['total_like'] =
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['total_like'] -
                1;
      }
    } else {
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
          ?.extras?['is_user_like_dislike'] = 0;
      if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_dislike'] >
          0) {
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.extras?['total_dislike'] =
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['total_dislike'] -
                1;
      }
    }

    if (!mounted) return;
    setState(() {});

    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.extras?['is_user_like_dislike'] ==
        0) {
      log("Remove Dislike");
      await musicDetailProvider.addLikeDislike(
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre,
          songid,
          "0",
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.genre ==
                  "4"
              ? (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.id
              : "0");
    } else {
      log("ADD Dislike");
      await musicDetailProvider.addLikeDislike(
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre,
          songid,
          "2",
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.genre ==
                  "4"
              ? (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.id
              : "0");
    }

    await musicprovider.getSeactionList("1", "0", "1");

    await contentDetailprovider.getEpisodeByPodcast(
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album,
        "1");

    await contentDetailprovider.getEpisodeByRadio(
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album,
        "1");

    await contentDetailprovider.getEpisodeByPlaylist(
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album,
        "2",
        "1");
  }
}
