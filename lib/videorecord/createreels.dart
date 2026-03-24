import 'package:camera/camera.dart';
import 'package:deepar_flutter/deepar_flutter.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/videorecord/circle_icon_button_ui.dart';
import 'package:fanbae/videorecord/createreelsprovider.dart';
import 'package:fanbae/videorecord/loading_ui.dart';
import 'package:fanbae/videorecord/preview_network_image_ui.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CreateReels extends StatefulWidget {
  const CreateReels({super.key});

  @override
  State<CreateReels> createState() => _CreateReelsState();
}

class _CreateReelsState extends State<CreateReels> {
  late CreateReelsProvider createReelsProvider;

  @override
  void initState() {
    createReelsProvider =
        Provider.of<CreateReelsProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      createReelsProvider.onGetPermission();
    });
  }

  @override
  void dispose() {
    if (createReelsProvider.isUseEffects) {
      createReelsProvider.onDisposeEffect();
    } else {
      createReelsProvider.onDisposeCamera();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: appbgcolor,
      body: createReelsProvider.isUseEffects
          ? const EffectUi()
          : const WithOutEffectUi(),
    );
  }
}

class EffectUi extends StatelessWidget {
  const EffectUi({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      //  color: colorPrimary,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Consumer<CreateReelsProvider>(
            builder: (context, createReelsProvider, child) {
              if (createReelsProvider.isInitializeEffect) {
                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 9, // base aspect ratio
                      height: 16, // base aspect ratio
                      child:
                          DeepArPreview(createReelsProvider.deepArController),
                    ),
                  ),
                );
              } else {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: black,
                  child: const LoadingUi(),
                );
              }
            },
          ),
          Positioned(
            top: 0,
            child: Container(
              height: 100,
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [black.withOpacity(0.7), transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 350,
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    transparent,
                    black.withOpacity(0.6),
                    black.withOpacity(0.8)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 35,
            child: Consumer<CreateReelsProvider>(
              builder: (context, createReelsProvider, child) {
                return Visibility(
                  visible: createReelsProvider.isRecording != "stop",
                  child: Container(
                    height: 6,
                    width: MediaQuery.sizeOf(context).width,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: white.withOpacity(0.6),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        height: 6,
                        width: createReelsProvider.countTime *
                            ((MediaQuery.sizeOf(context).width - 30) /
                                createReelsProvider.selectedDuration),
                        child: Container(
                          decoration: Utils.setGradientBG(
                              colorPrimary, colorPrimaryDark, 10),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 60,
            child: Consumer<CreateReelsProvider>(
              builder: (context, createReelsProvider, child) {
                return Visibility(
                  visible: createReelsProvider.selectedSound != null,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width / 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: white,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                  "${Constant.imageFolderPath}no_image_port.png",
                                  height: 25),
                              AspectRatio(
                                aspectRatio: 1,
                                child: PreviewNetworkImageUi(
                                    image: createReelsProvider
                                        .selectedSound?["image"]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            createReelsProvider.selectedSound?["name"] ?? "",
                            maxLines: 2,
                            style: TextStyle(
                              color: white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 65,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleIconButtonUi(
                    circleSize: 40,
                    iconSize: 20,
                    gradient: Constant.buttonGradient,
                    icon: "ic_close.webp",
                    iconColor: pureWhite,
                    callback: () {
                      if (!context.mounted) return;
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer<CreateReelsProvider>(
                    builder: (context, createReelsProvider, child) =>
                        CircleIconButtonUi(
                      circleSize: 40,
                      iconSize: 20,
                      gradient: Constant.buttonGradient,
                      icon: createReelsProvider.isFlashOn
                          ? "ic_flash_on.webp"
                          : "ic_flash_off.webp",
                      iconColor: pureWhite,
                      callback: createReelsProvider.onSwitchEffectFlash,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<CreateReelsProvider>(
                    builder: (context, createReelsProvider, child) =>
                        CircleIconButtonUi(
                      circleSize: 40,
                      iconSize: 20,
                      gradient: Constant.buttonGradient,
                      icon: "ic_rotate_camera.webp",
                      iconColor: pureWhite,
                      callback: () {
                        createReelsProvider.onSwitchEffectCamera(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // CircleIconButtonUi(
                  //   circleSize: 40,
                  //   iconSize: 17,
                  //   gradient: primaryLinearGradient,
                  //   padding: const EdgeInsets.only(right: 2),
                  //   icon: "ic_music.webp",
                  //   iconcolor: white,
                  //   callback: () {
                  //     // AddMusicBottomSheet.show(context: context);
                  //   },
                  // ),
                  // const SizedBox(height: 20),
                  Consumer<CreateReelsProvider>(
                    builder: (context, createReelsProvider, child) =>
                        CircleIconButtonUi(
                      circleSize: 40,
                      iconSize: 20,
                      gradient: Constant.buttonGradient,
                      icon: "ic_effect.webp",
                      iconColor: pureWhite,
                      callback: () {
                        createReelsProvider.onToggleEffect();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<CreateReelsProvider>(
                    builder: (context, createReelsProvider, child) =>
                        CircleIconButtonUi(
                      circleSize: 40,
                      iconSize: 20,
                      gradient: Constant.buttonGradient,
                      icon: "ic_gallery.png",
                      iconColor: pureWhite,
                      callback: () {
                        createReelsProvider.pickVideoFromGallery(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 185,
            child: Consumer<CreateReelsProvider>(
              builder: (context, createReelsProvider, child) {
                return Visibility(
                  visible: createReelsProvider.isShowEffects,
                  child: Container(
                    height: 100,
                    width: MediaQuery.sizeOf(context).width,
                    color: transparent,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 15),
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              createReelsProvider.effectsCollection.length,
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: (index == 0)
                                ? GestureDetector(
                                    onTap: () => createReelsProvider
                                        .onClearEffect(index),
                                    child: SizedBox(
                                      width: 90,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(1.2),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: transparent,
                                              border: Border.all(
                                                  color: createReelsProvider
                                                              .selectedEffectIndex ==
                                                          index
                                                      ? colorAccent
                                                      : white,
                                                  width: 1),
                                            ),
                                            child: Container(
                                              height: 60,
                                              alignment: Alignment.center,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: black,
                                              ),
                                              child: Image.asset(
                                                  "${Constant.videoImagePath}ic_none.webp",
                                                  color: white,
                                                  width: 30),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: 90,
                                            child: Text(
                                              "None",
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.clip,
                                              style: TextStyle(
                                                color: createReelsProvider
                                                            .selectedEffectIndex ==
                                                        index
                                                    ? colorPrimary
                                                    : white,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () => createReelsProvider
                                        .onChangeEffect(index),
                                    child: SizedBox(
                                      width: 90,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: transparent,
                                              border: Border.all(
                                                  color: createReelsProvider
                                                              .selectedEffectIndex ==
                                                          index
                                                      ? colorPrimary
                                                      : white,
                                                  width: 1),
                                            ),
                                            child: Container(
                                              height: 60,
                                              alignment: Alignment.center,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: transparent,
                                              ),
                                              child: Image.asset(
                                                  createReelsProvider
                                                      .effectImages[index],
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: 90,
                                            child: MyText(
                                              text: createReelsProvider
                                                  .effectNames[index],
                                              color: createReelsProvider
                                                          .selectedEffectIndex ==
                                                      index
                                                  ? colorPrimary
                                                  : white,
                                              fontsizeNormal: 12,
                                              fontsizeWeb: 17,
                                              fontwaight: FontWeight.w400,
                                              maxline: 1,
                                              multilanguage: false,
                                              overflow: TextOverflow.clip,
                                              textalign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 125,
            child: Consumer<CreateReelsProvider>(
              builder: (context, createReelsProvider, child) => Visibility(
                visible: createReelsProvider.isRecording == "stop",
                child: Container(
                  height: 43,
                  width: MediaQuery.sizeOf(context).width,
                  color: transparent,
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 15),
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            createReelsProvider.recordingDurations.length,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: GestureDetector(
                            onTap: () => createReelsProvider
                                .onChangeRecordingDuration(index),
                            child: Container(
                              height: 20,
                              width: 65,
                              decoration: (createReelsProvider
                                          .selectedDuration ==
                                      createReelsProvider
                                          .recordingDurations[index])
                                  ? Utils.setGradientBG(white, white, 100)
                                  : BoxDecoration(
                                      color: createReelsProvider
                                                  .selectedDuration ==
                                              createReelsProvider
                                                  .recordingDurations[index]
                                          ? null
                                          : white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                              child: Center(
                                child: MyText(
                                  text:
                                      "${createReelsProvider.recordingDurations[index]}s",
                                  color: createReelsProvider.selectedDuration ==
                                          createReelsProvider
                                              .recordingDurations[index]
                                      ? black
                                      : white,
                                  fontsizeNormal: 15,
                                  fontsizeWeb: 17,
                                  fontwaight: FontWeight.w500,
                                  maxline: 1,
                                  multilanguage: false,
                                  overflow: TextOverflow.ellipsis,
                                  textalign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              color: transparent,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Expanded(child: Offstage()),
                  Expanded(
                    child: Consumer<CreateReelsProvider>(
                      builder: (context, createReelsProvider, child) =>
                          GestureDetector(
                        onLongPressStart: (details) {
                          createReelsProvider.onLongPressStart(
                              context, details);
                        },
                        onLongPressEnd: (details) {
                          createReelsProvider.onLongPressEnd(context, details);
                        },
                        child: Container(
                          height: 100,
                          width: 100,
                          color: transparent,
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 68,
                                  width: 68,
                                  child: CircularProgressIndicator(
                                    value: createReelsProvider.isRecording ==
                                            "stop"
                                        ? 1
                                        : createReelsProvider.countTime *
                                            (1 /
                                                createReelsProvider
                                                    .selectedDuration),
                                    backgroundColor: white.withOpacity(0.2),
                                    color: createReelsProvider.isRecording ==
                                            "stop"
                                        ? white
                                        : colorPrimary,
                                    strokeWidth: 8,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Container(
                                  height: 65,
                                  width: 65,
                                  decoration:
                                      (createReelsProvider.isRecording ==
                                              "stop")
                                          ? BoxDecoration(
                                              gradient: Constant.buttonGradient,
                                              shape: BoxShape.circle,
                                            )
                                          : BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: white,
                                            ),
                                  child: Center(
                                    child: Image.asset(
                                      "${Constant.videoImagePath}ic_pause.webp",
                                      height: 30,
                                      width: 30,
                                      color: transparent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(child: Offstage()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WithOutEffectUi extends StatelessWidget {
  const WithOutEffectUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      color: lightgray,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Consumer<CreateReelsProvider>(
            builder: (context, createReelsProvider, child) {
              if (createReelsProvider.cameraController != null &&
                  (createReelsProvider.cameraController?.value.isInitialized ??
                      false)) {
                final mediaSize = MediaQuery.of(context).size;
                final scale = 1 /
                    (createReelsProvider.cameraController!.value.aspectRatio *
                        mediaSize.aspectRatio);
                printLog(
                    "mediaSize.aspectRatio:::::::${mediaSize.aspectRatio}");
                printLog(
                    "createReelsProvider.cameraController!.value.aspectRatio:::::::${createReelsProvider.cameraController!.value.aspectRatio}");
                printLog("mediaSize:::::::$mediaSize");
                printLog("scale:::::::$scale");
                return ClipRect(
                  clipper: _MediaSizeClipper(mediaSize),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: CameraPreview(createReelsProvider.cameraController!),
                  ),
                );
              } else {
                return const LoadingUi();
              }
            },
          ),
          Positioned(
            top: 0,
            child: Container(
              height: 100,
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [black.withOpacity(0.7), transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 350,
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    transparent,
                    black.withOpacity(0.6),
                    black.withOpacity(0.8)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 35,
            child: Consumer<CreateReelsProvider>(
              builder: (context, createReelsProvider, child) {
                return Visibility(
                  visible: createReelsProvider.isRecording != "stop",
                  child: Container(
                    height: 6,
                    width: MediaQuery.sizeOf(context).width,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: white.withOpacity(0.6),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 6,
                        width: createReelsProvider.countTime *
                            ((MediaQuery.sizeOf(context).width - 30) /
                                createReelsProvider.selectedDuration),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [colorPrimary, colorAccent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 60,
            child: Consumer<CreateReelsProvider>(
              builder: (context, createReelsProvider, child) {
                return Visibility(
                  visible: createReelsProvider.selectedSound != null,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width / 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: white,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                  "${Constant.imageFolderPath}no_image_port.png",
                                  height: 25),
                              AspectRatio(
                                aspectRatio: 1,
                                child: PreviewNetworkImageUi(
                                    image: createReelsProvider
                                        .selectedSound?["image"]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            createReelsProvider.selectedSound?["name"] ?? "",
                            maxLines: 2,
                            style: TextStyle(
                              color: white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 65,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircleIconButtonUi(
                      circleSize: 40,
                      iconSize: 20,
                      color: white.withOpacity(0.15),
                      icon: "ic_close.webp",
                      iconColor: white,
                      callback: () {
                        if (!context.mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Consumer<CreateReelsProvider>(
                      builder: (context, createReelsProvider, child) =>
                          CircleIconButtonUi(
                        circleSize: 40,
                        iconSize: 20,
                        gradient: LinearGradient(
                          colors: [colorPrimary, colorAccent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        icon: createReelsProvider.isFlashOn
                            ? "ic_flash_on.webp"
                            : "ic_flash_off.webp",
                        iconColor: white,
                        callback: createReelsProvider.onSwitchFlash,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Consumer<CreateReelsProvider>(
                      builder: (context, createReelsProvider, child) =>
                          CircleIconButtonUi(
                        circleSize: 40,
                        iconSize: 20,
                        gradient: LinearGradient(
                          colors: [colorPrimary, colorAccent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        icon: "ic_rotate_camera.webp",
                        iconColor: white,
                        callback: () {
                          createReelsProvider.onSwitchCamera(context);
                        },
                      ),
                    ),
                    // const SizedBox(height: 20),
                    // CircleIconButtonUi(
                    //   circleSize: 40,
                    //   iconSize: 17,
                    //   gradient: primaryLinearGradient,
                    //   padding: const EdgeInsets.only(right: 2),
                    //   icon: "ic_music.webp",
                    //   iconcolor: white,
                    //   callback: () {
                    //     // AddMusicBottomSheet.show(context: context);
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 125,
            child: Consumer<CreateReelsProvider>(
              builder: (context, createReelsProvider, child) {
                return Visibility(
                  visible: createReelsProvider.isRecording == "stop",
                  child: Container(
                    height: 43,
                    width: MediaQuery.sizeOf(context).width,
                    color: transparent,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 15),
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              createReelsProvider.recordingDurations.length,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: GestureDetector(
                              onTap: () => createReelsProvider
                                  .onChangeRecordingDuration(index),
                              child: Container(
                                height: 20,
                                width: 65,
                                decoration: BoxDecoration(
                                  gradient: createReelsProvider
                                              .selectedDuration ==
                                          createReelsProvider
                                              .recordingDurations[index]
                                      ? LinearGradient(
                                          colors: [colorPrimary, colorAccent],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        )
                                      : null,
                                  color: createReelsProvider.selectedDuration ==
                                          createReelsProvider
                                              .recordingDurations[index]
                                      ? null
                                      : white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Text(
                                    "${createReelsProvider.recordingDurations[index]}s",
                                    style: TextStyle(
                                      color: white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              color: transparent,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Expanded(child: Offstage()),
                  Expanded(
                    child: Container(
                      height: 100,
                      width: 100,
                      color: transparent,
                      child: Center(
                        child: Consumer<CreateReelsProvider>(
                          builder: (context, createReelsProvider, child) =>
                              Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 73,
                                width: 73,
                                child: CircularProgressIndicator(
                                  value:
                                      createReelsProvider.isRecording == "stop"
                                          ? 1
                                          : createReelsProvider.countTime *
                                              (1 /
                                                  createReelsProvider
                                                      .selectedDuration),
                                  backgroundColor: white.withOpacity(0.2),
                                  color:
                                      createReelsProvider.isRecording == "stop"
                                          ? white
                                          : colorPrimaryDark,
                                  strokeWidth: 8,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              createReelsProvider.isRecording == "start"
                                  ? CircleIconButtonUi(
                                      circleSize: 65,
                                      icon: "ic_pause.webp",
                                      iconSize: 35,
                                      color: white,
                                      callback: () {
                                        createReelsProvider
                                            .onClickRecordingButton(context);
                                      },
                                    )
                                  : createReelsProvider.isRecording == "pause"
                                      ? CircleIconButtonUi(
                                          circleSize: 65,
                                          padding:
                                              const EdgeInsets.only(left: 2),
                                          icon: "ic_play.webp",
                                          iconSize: 30,
                                          color: white,
                                          callback: () => createReelsProvider
                                              .onClickRecordingButton(context),
                                        )
                                      : CircleIconButtonUi(
                                          circleSize: 65,
                                          padding:
                                              const EdgeInsets.only(left: 2),
                                          icon: "ic_play.webp",
                                          iconColor: transparent,
                                          iconSize: 30,
                                          gradient: LinearGradient(
                                            colors: [colorPrimary, colorAccent],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          color: white,
                                          callback: () => createReelsProvider
                                              .onClickRecordingButton(context),
                                        ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Consumer<CreateReelsProvider>(
                      builder: (context, createReelsProvider, child) =>
                          Visibility(
                        visible: createReelsProvider.isRecording != "stop",
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => createReelsProvider
                                .onClickPreviewButton(context),
                            child: Container(
                              height: 43,
                              width: 111,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [colorPrimary, colorAccent],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Text(
                                  "Preview",
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
