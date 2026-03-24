import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fanbae/pages/createmusic.dart';
import 'package:fanbae/pages/createvideo.dart';
import 'package:fanbae/pages/login.dart';
import 'package:fanbae/provider/uploadfeedprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'createpodcast.dart';

class UploadFeed extends StatefulWidget {
  final bool? isAppBar;
  final bool? fromDialog;

  const UploadFeed({super.key, this.isAppBar, this.fromDialog});

  @override
  State<UploadFeed> createState() => _UploadFeedState();
}

class _UploadFeedState extends State<UploadFeed> {
  late UploadfeedProvider uploadfeedProvider;
  final captionController = TextEditingController();
  final descriptionController = TextEditingController();
  VideoPlayerController? _videoPlayerController;
  String type = 'free';
  final TextEditingController coinController = TextEditingController();
  File? attachment;
  Uint8List? attachmentByte;
  String? attachmentName;

  final ImagePicker picker = ImagePicker();
  List<String> contentTypes = ["post", "video", "music", "podcast"];
  String? selectedContentType = "post";

  @override
  void initState() {
    uploadfeedProvider =
        Provider.of<UploadfeedProvider>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    uploadfeedProvider.clearProvider();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'txt',
        'ppt',
        'pptx',
        'csv'
      ],
      withData: true,
    );

    if (result != null) {
      PlatformFile pickedFile = result.files.first;

      if (kIsWeb) {
        setState(() {
          attachmentByte = pickedFile.bytes;
          attachmentName = pickedFile.name;
          print(attachmentName);
          print(attachmentByte);
        });
      } else {
        setState(() {
          attachment = File(pickedFile.path!);
          attachmentByte = pickedFile.bytes;
          attachmentName = pickedFile.name;
          print(attachment);
          print(attachmentByte);
          print(attachmentName);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        Utils().hideProgress(context);
      },
      child: Scaffold(
        backgroundColor: appbgcolor,
        appBar: AppBar(
          backgroundColor: appBarColor,
          leading: widget.fromDialog == true
              ? const SizedBox()
              : GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: white,
                  ),
                ),
          title: MyText(
            text: "uploadfeed",
            color: white,
            fontsizeNormal: Dimens.textBig,
            fontwaight: FontWeight.bold,
          ),
          bottom: widget.isAppBar == false
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(0), //
                  child: SizedBox(),
                )
              : PreferredSize(
                  preferredSize:
                      const Size.fromHeight(80), // Adjust height as needed
                  child: Padding(
                    padding: const EdgeInsets.only(left: 17, right: 24),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        // border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedContentType,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 11, horizontal: 11),
                          filled: true,
                          fillColor: buttonDisable,
                          enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: transparent),
                              borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: transparent),
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        dropdownColor: Colors.grey[900],
                        // Match your dark theme
                        items: contentTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                type, // Ensure proper capitalization
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedContentType = newValue;
                            // Optional: Update provider if needed
                            // uploadfeedprovider.setContentType(newValue);
                          });
                        },
                        hint: Text(
                          "Select content type",
                          style: GoogleFonts.inter(
                            color: colorAccent,
                            fontSize: 14,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ),
                  ),
                ),
        ),
        body: selectedContentType == "video"
            ? const CreateVideo(isAppBar: false)
            : selectedContentType == "music"
                ? const CreateMusic(
                    isAppBar: false,
                  )
                : selectedContentType == "podcast"
                    ? const CreatePodcast(
                        isAppBar: false,
                      )
                    : Utils().pageBg(
                        context,
                        child: Consumer<UploadfeedProvider>(
                            builder: (context, uploadfeedprovider, child) {
                          return Padding(
                            padding: const EdgeInsets.all(0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 15, 15, 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        buildSelectedContent(),
                                        const SizedBox(
                                          height: 18,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            MyText(
                                                color: white,
                                                multilanguage: true,
                                                text: "attachment",
                                                textalign: TextAlign.center,
                                                fontsizeNormal: Dimens.textBig,
                                                inter: false,
                                                maxline: 1,
                                                fontwaight: FontWeight.w700,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            MyText(
                                                color: white,
                                                multilanguage: true,
                                                text: "optional",
                                                textalign: TextAlign.center,
                                                fontsizeNormal:
                                                    Dimens.textSmall,
                                                inter: false,
                                                maxline: 1,
                                                fontwaight: FontWeight.w500,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        attachmentByte != null
                                            ? InkWell(
                                                onTap: () async {
                                                  pickFile();
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  child: SizedBox(
                                                    height: kIsWeb ? 200 : 175,
                                                    child: Container(
                                                      color: colorPrimaryDark,
                                                      width: kIsWeb
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.38
                                                          : 160,
                                                      height:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                              Icons.file_copy,
                                                              size: 60,
                                                              color:
                                                                  Colors.blue),
                                                          const SizedBox(
                                                            height: 15,
                                                          ),
                                                          MyText(
                                                            text:
                                                                attachmentName!
                                                                    .split('/')
                                                                    .last,
                                                            color: Colors.white,
                                                            multilanguage:
                                                                false,
                                                            fontsizeNormal:
                                                                13.5,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : DottedBorder(
                                                dashPattern: const [3, 3],
                                                radius:
                                                    const Radius.circular(5),
                                                color: colorAccent,
                                                child: InkWell(
                                                  onTap: () async {
                                                    pickFile();
                                                  },
                                                  child: Container(
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: transparent,
                                                    ),
                                                    height: kIsWeb ? 200 : 180,
                                                    width: kIsWeb
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.38
                                                        : 175,
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.add,
                                                        color: white,
                                                        size: 35,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        /* Caption Button */
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 15, 0, 15),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 15),
                                              MyText(
                                                  color: white,
                                                  multilanguage: true,
                                                  text: "caption",
                                                  textalign: TextAlign.center,
                                                  fontsizeNormal:
                                                      Dimens.textBig,
                                                  inter: false,
                                                  maxline: 1,
                                                  fontwaight: FontWeight.w700,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal),
                                              const SizedBox(height: 10),
                                              TextFormField(
                                                textAlign: TextAlign.left,
                                                obscureText: false,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                minLines: 3,
                                                maxLines: 10,
                                                controller: captionController,
                                                textInputAction:
                                                    TextInputAction.done,
                                                cursorColor: white,
                                                style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontStyle: FontStyle.normal,
                                                    color: white,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                decoration: InputDecoration(
                                                  isCollapsed: true,
                                                  isDense: true,
                                                  filled: true,
                                                  fillColor: buttonDisable,
                                                  hintText: Locales.string(
                                                      context,
                                                      "enteryourtextwithhashtag"),
                                                  hintStyle: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      color: colorAccent,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 11,
                                                          horizontal: 11),
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                    borderSide: BorderSide(
                                                        color: transparent),
                                                  ),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                    borderSide: BorderSide(
                                                        color: transparent),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  MyText(
                                                      color: white,
                                                      multilanguage: true,
                                                      text: "discription",
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsizeNormal:
                                                          Dimens.textBig,
                                                      inter: false,
                                                      maxline: 1,
                                                      fontwaight:
                                                          FontWeight.w700,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  MyText(
                                                      color: white,
                                                      multilanguage: true,
                                                      text: "optional",
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsizeNormal:
                                                          Dimens.textSmall,
                                                      inter: false,
                                                      maxline: 1,
                                                      fontwaight:
                                                          FontWeight.w500,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              TextFormField(
                                                textAlign: TextAlign.left,
                                                obscureText: false,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                minLines: 5,
                                                maxLines: 10,
                                                controller:
                                                    descriptionController,
                                                textInputAction:
                                                    TextInputAction.done,
                                                cursorColor: white,
                                                style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontStyle: FontStyle.normal,
                                                    color: white,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                decoration: InputDecoration(
                                                    isCollapsed: true,
                                                    isDense: true,
                                                    filled: true,
                                                    fillColor: buttonDisable,
                                                    hintText: Locales.string(
                                                        context,
                                                        "enteryourpostdiscription"),
                                                    hintStyle:
                                                        GoogleFonts.inter(
                                                            fontSize: 14,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            color: colorAccent,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 11,
                                                            horizontal: 11),
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8.0)),
                                                      borderSide: BorderSide(
                                                          color: transparent),
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8.0)),
                                                      borderSide: BorderSide(
                                                          color: transparent),
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            MyText(
                                                color: white,
                                                multilanguage: true,
                                                text: "comment",
                                                textalign: TextAlign.center,
                                                fontsizeNormal: Dimens.textBig,
                                                inter: false,
                                                maxline: 1,
                                                fontwaight: FontWeight.w700,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal),
                                            Switch(
                                              value: uploadfeedprovider
                                                          .isComment ==
                                                      1
                                                  ? true
                                                  : false,
                                              onChanged: (value) {
                                                uploadfeedProvider
                                                    .toggleComment();

                                                printLog(
                                                    "iscomment===>${uploadfeedprovider.isComment}");
                                              },
                                            )
                                          ],
                                        ),
                                        Utils().titleText("type"),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Radio<String>(
                                                  value: 'free',
                                                  groupValue: type,
                                                  activeColor: colorPrimary,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      type = value!;
                                                    });
                                                  },
                                                ),
                                                MyText(
                                                  text: 'free',
                                                  color: white,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 20),
                                            Row(
                                              children: [
                                                Radio<String>(
                                                  value: 'pay',
                                                  groupValue: type,
                                                  activeColor: colorPrimary,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      type = value!;
                                                    });
                                                  },
                                                ),
                                                MyText(
                                                  text: 'pay',
                                                  color: white,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (type == "pay") ...[
                                          Utils().titleText("price"),
                                          Utils().myTextField(
                                              coinController,
                                              TextInputAction.next,
                                              TextInputType.number,
                                              'price',
                                              false),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                /* Upload Button */
                                uploadButton(),
                              ],
                            ),
                          );
                        }),
                      ),
      ),
    );
  }

  Widget buildSelectedContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (uploadfeedProvider.selectedContent != null &&
                  (uploadfeedProvider.selectedContent?.length ?? 0) > 0)
              ? SizedBox(
                  height: 175,
                  child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemCount: uploadfeedProvider.selectedContent?.length ?? 0,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: MyNetworkImage(
                              imagePath:
                                  uploadfeedProvider.selectedContent?[index] ??
                                      "",
                              width: 155,
                              height: MediaQuery.of(context).size.height,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            top: 5,
                            left: 5,
                            right: 5,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () async {
                                  await uploadfeedProvider.addRemoveContent(
                                      index: index, isAdd: false);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colorPrimaryDark),
                                  child: Icon(
                                    Icons.close,
                                    color: white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: DottedBorder(
              dashPattern: const [3, 3],
              radius: const Radius.circular(5),
              color: colorAccent,
              child: InkWell(
                onTap: () async {
                  showCustomBottomSheet(context);
                },
                child: Container(
                  height: 173,
                  width: 165,
                  color: transparent,
                  child: Icon(
                    Icons.add,
                    color: white,
                    size: 35,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget uploadButton() {
    return InkWell(
      focusColor: transparent,
      hoverColor: transparent,
      highlightColor: transparent,
      splashColor: transparent,
      borderRadius: BorderRadius.circular(50),
      onTap: () async {
        if (Constant.userID == null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Login();
              },
            ),
          );
        } else {
          if (!uploadfeedProvider.loading) {
            await convertToJson();
            await prepareSelectedFile();
            await uploadApi();
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: Constant.gradientColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: uploadfeedProvider.uploadLoading
            ? CircularProgressIndicator(
                color: colorAccent,
                strokeWidth: 2,
              )
            : MyText(
                color: pureBlack,
                multilanguage: true,
                text: "upload",
                textalign: TextAlign.center,
                fontsizeNormal: Dimens.textTitle,
                inter: false,
                maxline: 1,
                fontwaight: FontWeight.w700,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
      ),
    );
  }

/* ========================= Pic And Capture Image ========================= */

  _pickImageFromGallery() async {
    FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true);

    if (pickedImage != null) {
      PlatformFile pickedFile = pickedImage.files.first;

      if (kIsWeb) {
        await contentUploadApi(
          null,
          "1",
          fileBytes: pickedFile.bytes,
          filename: pickedFile.name,
        );
      } else {
        File file = File(pickedFile.path!);
        await contentUploadApi(
          file,
          "1",
          fileBytes: pickedFile.bytes, // optional
          filename: pickedFile.name,
        );
      }
    }
  }

  Future<bool> ensureCameraPermission() async {
    if (kIsWeb) {
      // Web does NOT need runtime permissions
      return true;
    }

    bool isAndroid13Plus = false;

    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        isAndroid13Plus = androidInfo.version.sdkInt >= 33;
      } catch (e) {
        print("DeviceInfo not available: $e");
        isAndroid13Plus = false; // fallback
      }
    }

    Map<Permission, PermissionStatus> statuses;

    if (isAndroid13Plus) {
      statuses = await [
        Permission.camera,
        Permission.photos,
      ].request();
    } else {
      statuses = await [
        Permission.camera,
        Permission.storage,
      ].request();
    }

    final granted = statuses.values.every((s) => s.isGranted);

    if (!granted) print("Permissions denied");

    return granted;
  }

  _pickImageFromCamera() async {
    try {
      if (!await ensureCameraPermission()) return;

      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );

      if (picked == null) return;

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        await contentUploadApi(null, "1",
            fileBytes: bytes, filename: picked.name);
        return;
      }

      final file = File(picked.path);
      if (!await file.exists()) return;

      await contentUploadApi(file, "1", filename: picked.name);
    } catch (e) {
      print("pickImage error: $e");
    }
  }

  _pickVideoFromCamera() async {
    try {
      if (!await ensureCameraPermission()) return;

      final picked = await ImagePicker().pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );

      if (picked == null) return;

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        await contentUploadApi(null, "2",
            fileBytes: bytes, filename: picked.name);
        return;
      }

      final file = File(picked.path);
      if (!await file.exists()) return;

      await contentUploadApi(file, "2", filename: picked.name);
    } catch (e) {
      print("pickVideo error: $e");
    }
  }

  _pickVideoFromGallery() async {
    FilePickerResult? pickedVideo = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi', 'webm', 'mkv'],
        withData: true);

    if (pickedVideo != null) {
      PlatformFile pickedFile = pickedVideo.files.first;

      if (kIsWeb) {
        await contentUploadApi(
          null,
          "2",
          fileBytes: pickedFile.bytes,
          filename: pickedFile.name,
        );
      } else {
        File file = File(pickedFile.path!);
        await contentUploadApi(
          file,
          "2",
          fileBytes: pickedFile.bytes, // optional
          filename: pickedFile.name,
        );
      }
    }
  }

  /*_pickVideoFromCamera() async {
    final XFile? pickedVideo = await ImagePicker().pickVideo(
      source: ImageSource.camera,
    );

    if (pickedVideo != null) {
      final bytes = await pickedVideo.readAsBytes();
      if (kIsWeb) {
        await contentUploadApi(
          null,
          "2",
          fileBytes: bytes,
          filename: pickedVideo.name,
        );
      } else {
        File file = File(pickedVideo.path);
        await contentUploadApi(
          file,
          "2",
          fileBytes: bytes, // optional
          filename: pickedVideo.name,
        );
      }
    }
  }*/

/* ========================= Pic And Capture Image ========================= */

/* ========================= Pic And Capture Video ========================= */
/* ========================= Pic And Capture Video ========================= */

  contentUploadApi(File? content, contentType,
      {Uint8List? fileBytes, String? filename}) async {
    /* contentType 1 ===> image */
    /* contentType 2 ===> video */
    Utils.showProgress(context);
    await uploadfeedProvider.postContentUpload(
        contentType, content, fileBytes, filename);
    if (!mounted) return;
    Utils().hideProgress(context);
    if (!uploadfeedProvider.loading) {
      if (uploadfeedProvider.postContentUploadModel.status == 200) {
        await uploadfeedProvider.addRemoveContent(
            content: uploadfeedProvider
                        .postContentUploadModel.result?.contentType ==
                    "1"
                ? uploadfeedProvider.postContentUploadModel.result?.contentUrl
                        .toString() ??
                    ""
                : uploadfeedProvider
                        .postContentUploadModel.result?.thumbnailImageUrl
                        .toString() ??
                    "",
            contentType: uploadfeedProvider
                    .postContentUploadModel.result?.contentType
                    .toString() ??
                "",
            contentName: uploadfeedProvider
                    .postContentUploadModel.result?.contentName
                    .toString() ??
                "",
            thambnailImage: uploadfeedProvider
                    .postContentUploadModel.result?.thumbnailImage
                    .toString() ??
                "",
            index: 0,
            isAdd: true);
      } else {
        //  if (!mounted) return;
        if (mounted) {
          Utils().showSnackBar(
              context,
              uploadfeedProvider.postContentUploadModel.message.toString(),
              false);
        }
      }
    }
  }

  Future<void> prepareSelectedFile() async {
    String? url = kIsWeb
        ? (uploadfeedProvider.selectContentName?[0])
        : uploadfeedProvider.selectedContent?[0];
    if (url == null) return;

    final response = await http.get(Uri.parse(url));

    if (kIsWeb) {
      attachmentByte = response.bodyBytes;
      attachmentName = url.split('/').last;
      attachment = null;
    } else {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/${url.split('/').last}';
      attachment = File(tempPath);
      await attachment!.writeAsBytes(response.bodyBytes);

      attachmentByte = null;
      attachmentName = null;
    }
  }

  convertToJson() async {
    uploadfeedProvider.combinedList = [];
    uploadfeedProvider.combinedList?.clear();
    for (int i = 0;
        i < (uploadfeedProvider.selectContentType?.length ?? 0);
        i++) {
      uploadfeedProvider.combinedList?.add({
        'content_type': uploadfeedProvider.selectContentType?[i],
        'content_url': uploadfeedProvider.selectContentName?[i],
        'thumbnail_image': uploadfeedProvider.selectThambnailImage?[i],
      });
    }
  }

  uploadApi() async {
    if ((uploadfeedProvider.selectedContent?.length ?? 0) == 0) {
      Utils().showSnackBar(context, "pleaseselectcontent", true);
    } else if (captionController.text.isEmpty) {
      Utils().showSnackBar(context, "addacaptionyourpost", true);
    } else if (type == "pay" && coinController.text.isEmpty) {
      return Utils().showSnackBar(context, "Price is required.", false);
    } else {
      Utils.showProgress(context);
      try {
        print("===== Starting Upload =====");
        print(
            "Selected Content: ${uploadfeedProvider.selectedContent?.length}");
        print("Caption: ${captionController.text}");
        print("Type: $type");

        await uploadfeedProvider.uploadPost(
            captionController.text,
            uploadfeedProvider.isComment,
            descriptionController.text,
            uploadfeedProvider.combinedList,
            type,
            coinController.text,
            attachment,
            fileBytes: attachmentByte,
            fileName: attachmentName);

        print("===== Upload API Response =====");
        print("Status: ${uploadfeedProvider.successModel.status}");
        print("Message: ${uploadfeedProvider.successModel.message}");

        String displayMessage = uploadfeedProvider.successModel.message ??
            "Error uploading feed post.";
        // Friendly mapping for known server-side watermark missing error
        if (displayMessage.toLowerCase().contains('watermark.png') ||
            displayMessage.toLowerCase().contains('watermark')) {
          displayMessage =
              "Server error: watermark missing on server. Please contact admin.";
        }

        if (mounted) {
          Utils().showSnackBar(context, displayMessage, false);
        }

        if (uploadfeedProvider.successModel.status == 200) {
          print("===== Upload Success =====");
          uploadfeedProvider.clearProvider();
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          print("===== Upload Failed =====");
          print("Error: ${uploadfeedProvider.successModel.message}");
        }
      } catch (e) {
        print("===== Upload Exception =====");
        print("Error: $e");
        if (mounted) {
          Utils().showSnackBar(context, "Error: $e", false);
        }
      } finally {
        if (mounted) {
          Utils().hideProgress(context);
        }
      }
    }
  }

  void showCustomBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorPrimaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyText(
                      color: white,
                      multilanguage: true,
                      text: "selectimage",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textBig,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  ListTile(
                    leading: Icon(Icons.photo_library, color: white),
                    title: MyText(
                        color: white,
                        multilanguage: true,
                        text: "gallery",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textTitle,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      _pickImageFromGallery();
                    },
                  ),
                  kIsWeb
                      ? const SizedBox()
                      : ListTile(
                          leading: Icon(Icons.camera, color: white),
                          title: MyText(
                              color: white,
                              multilanguage: true,
                              text: "takeaphoto",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textTitle,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            _pickImageFromCamera();
                          },
                        ),
                  ListTile(
                    leading: Icon(Icons.video_call_outlined, color: white),
                    title: MyText(
                        color: white,
                        multilanguage: true,
                        text: "picvideofromgallary",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textTitle,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      _pickVideoFromGallery();
                    },
                  ),
                  kIsWeb
                      ? const SizedBox()
                      : ListTile(
                          leading:
                              Icon(Icons.video_call_outlined, color: white),
                          title: MyText(
                              color: white,
                              multilanguage: true,
                              text: "takeavideo",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textTitle,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            _pickVideoFromCamera();
                          },
                        ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
