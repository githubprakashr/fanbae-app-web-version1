import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' as found;
import 'package:flutter/material.dart';
import 'package:fanbae/utils/utils.dart';

import '../model/successmodel.dart' as success;
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/responsive_helper.dart';
import '../webservice/apiservice.dart';
import '../widget/mytext.dart';

class PodcastEpisode extends StatefulWidget {
  final int id;
  final bool? isAppBar;
  final bool? fromDialog;
  const PodcastEpisode(
      {super.key, required this.id, this.isAppBar, this.fromDialog});

  @override
  State<PodcastEpisode> createState() => _PodcastEpisodeState();
}

class _PodcastEpisodeState extends State<PodcastEpisode> {
  final TextEditingController descController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  bool isLoad = false;
  int isLike = 1;
  int isComment = 1;
  File? mp3File;
  found.Uint8List? mp3Byte;
  String? mp3Name;
  File? thumbImage;
  found.Uint8List? imageByte;
  String? imageName;
  List uploadTypes = ["Audio", "External URL"];
  String selectedType = "Audio";

  Future<void> _pickThumbnailImage() async {
    FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true);

    if (pickedImage != null) {
      PlatformFile pickedFile = pickedImage.files.first;
      if (ResponsiveHelper.checkIsWeb(context)) {
        setState(() {
          imageByte = pickedFile.bytes;
          imageName = pickedFile.name;
        });
      } else {
        setState(() {
          thumbImage = File(pickedFile.path!);
          imageByte = pickedFile.bytes;
          imageName = pickedFile.name;
        });
      }
    }
  }

  Future<void> _pickMp3File() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      //allowedExtensions: ['mp3', 'wav', 'aac', 'ogg', 'flac', 'm4a'],
      withData: true,
    );

    if (result != null) {
      PlatformFile pickedFile = result.files.first;
      if (ResponsiveHelper.checkIsWeb(context)) {
        setState(() {
          mp3Byte = pickedFile.bytes;
          mp3Name = pickedFile.name;
        });
      } else {
        setState(() {
          mp3File = File(pickedFile.path!);
          mp3Byte = pickedFile.bytes;
          mp3Name = pickedFile.name;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          ResponsiveHelper.checkIsWeb(context) ? colorPrimaryDark : appbgcolor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        automaticallyImplyLeading: false,
        leading: ResponsiveHelper.checkIsWeb(context)
            ? null
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
          text: "episodes",
          color: white,
          fontwaight: FontWeight.bold,
          fontsizeNormal: Dimens.textBig,
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          if (selectedType == "Audio") {
            if (mp3Byte == null) {
              return Utils()
                  .showSnackBar(context, "Music field is required", false);
            }
          }
          if (selectedType != "Audio") {
            if (urlController.text.isEmpty) {
              return Utils()
                  .showSnackBar(context, "URL field is required", false);
            }
          }
          if (imageByte == null) {
            return Utils().showSnackBar(
                context, "Thumbnail Image field is required", false);
          }
          if (titleController.text.isEmpty) {
            return Utils()
                .showSnackBar(context, "Title field is required", false);
          }
          if (descController.text.isEmpty) {
            return Utils()
                .showSnackBar(context, "Description field is required", false);
          }
          Utils.showProgress(context);

          success.SuccessModel music = await ApiService().createPodcastEpisode(
              widget.id,
              null,
              selectedType == "Audio" ? "server_video" : "external_url",
              selectedType == "Audio" ? null : urlController.text,
              selectedType == "Audio" ? mp3File : null,
              thumbImage,
              isLike,
              isComment,
              titleController.text,
              descController.text,
              musicBytes: selectedType == "Audio" ? mp3Byte : null,
              musicName: selectedType == "Audio" ? mp3Name : null,
              imageBytes: imageByte,
              imageName: imageName);
          if (!mounted) return;
          Utils().hideProgress(context);
          if (mounted) {
            Utils().showSnackBar(context, "${music.message}", false);
          }
          if (music.status == 200) {
            Navigator.pop(context);
          }
        },
        child: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              gradient: Constant.gradientColor),
          child: MyText(
              color: pureBlack,
              text: "submit",
              multilanguage: true,
              textalign: TextAlign.center,
              fontsizeNormal: Dimens.textMedium,
              maxline: 1,
              fontwaight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
        ),
      ),
      body: Utils().pageBg(context,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Utils().titleText("type"),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: uploadTypes.map((type) {
                      return Row(
                        children: [
                          Radio<String>(
                            value: type,
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                              });
                            },
                            activeColor: colorPrimary, // optional
                          ),
                          Text(
                            type,
                            style: const TextStyle(
                                color: Colors.white), // customize as needed
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  Utils().titleText(selectedType == "Audio" ? "music" : "URL"),
                  selectedType == "Audio"
                      ? mp3Byte != null
                          ? InkWell(
                              onTap: () async {
                                _pickMp3File();
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: SizedBox(
                                  height: ResponsiveHelper.checkIsWeb(context)
                                      ? 200
                                      : 180,
                                  child: Container(
                                    color: colorPrimaryDark,
                                    width: ResponsiveHelper.checkIsWeb(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.38
                                        : MediaQuery.of(context).size.width *
                                            0.45,
                                    height: MediaQuery.of(context).size.height,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.music_note,
                                            size: 60, color: colorPrimary),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        MyText(
                                          text: mp3Name ?? "MP3 File",
                                          color: Colors.white,
                                          multilanguage: false,
                                          fontsizeNormal: 13.5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : DottedBorder(
                              dashPattern: const [3, 3],
                              radius: const Radius.circular(5),
                              color: colorAccent,
                              child: InkWell(
                                onTap: () async {
                                  _pickMp3File();
                                },
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: transparent,
                                  ),
                                  height: found.kIsWeb ? 200 : 180,
                                  width: found.kIsWeb
                                      ? MediaQuery.of(context).size.width * 0.38
                                      : MediaQuery.of(context).size.width *
                                          0.45,
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: white,
                                      size: 35,
                                    ),
                                  ),
                                ),
                              ),
                            )
                      : Utils().myTextField(urlController, TextInputAction.next,
                          TextInputType.text, "url", false),
                  Utils().titleText("thumbnailimage"),
                  imageByte != null
                      ? InkWell(
                          onTap: () async {
                            _pickThumbnailImage();
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: SizedBox(
                                height: found.kIsWeb ? 200 : 180,
                                child: found.kIsWeb
                                    ? Image.memory(
                                        imageByte!,
                                        width: found.kIsWeb
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.38
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.45,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        thumbImage!,
                                        width: found.kIsWeb
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.38
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.45,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        fit: BoxFit.cover,
                                      )),
                          ),
                        )
                      : DottedBorder(
                          dashPattern: const [3, 3],
                          radius: const Radius.circular(5),
                          color: colorAccent,
                          child: InkWell(
                            onTap: () async {
                              _pickThumbnailImage();
                            },
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: transparent,
                              ),
                              height: found.kIsWeb ? 200 : 180,
                              width: found.kIsWeb
                                  ? MediaQuery.of(context).size.width * 0.38
                                  : MediaQuery.of(context).size.width * 0.45,
                              child: Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: white,
                                  size: 35,
                                ),
                              ),
                            ),
                          ),
                        ),
                  Utils().titleText("title"),
                  Utils().myTextField(titleController, TextInputAction.next,
                      TextInputType.text, "title", false),
                  Utils().titleText("description"),
                  Utils().myTextField(descController, TextInputAction.next,
                      TextInputType.text, "description", false),
                  Utils().titleText("like"),
                  Row(
                    children: [
                      Row(
                        children: [
                          Radio<int>(
                            value: 1,
                            groupValue: isLike,
                            activeColor: colorPrimary,
                            onChanged: (value) {
                              setState(() {
                                isLike = value!;
                              });
                            },
                          ),
                          MyText(
                            text: 'on',
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Row(
                        children: [
                          Radio<int>(
                            value: 0,
                            groupValue: isLike,
                            activeColor: colorPrimary,
                            onChanged: (value) {
                              setState(() {
                                isLike = value!;
                              });
                            },
                          ),
                          MyText(
                            text: 'off',
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Utils().titleText("comment"),
                  Row(
                    children: [
                      Row(
                        children: [
                          Radio<int>(
                            value: 1,
                            groupValue: isComment,
                            activeColor: colorPrimary,
                            onChanged: (value) {
                              setState(() {
                                isComment = value!;
                              });
                            },
                          ),
                          MyText(
                            text: 'on',
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Row(
                        children: [
                          Radio<int>(
                            value: 0,
                            groupValue: isComment,
                            activeColor: colorPrimary,
                            onChanged: (value) {
                              setState(() {
                                isComment = value!;
                              });
                            },
                          ),
                          MyText(
                            text: 'off',
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
