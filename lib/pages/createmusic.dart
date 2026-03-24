import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' as found;
import 'package:flutter/material.dart';
import 'package:fanbae/model/musicmodel.dart';
import 'package:fanbae/webservice/apiservice.dart';

import '../model/successmodel.dart' as success;
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/responsive_helper.dart';
import '../utils/utils.dart';
import '../widget/mytext.dart';

class CreateMusic extends StatefulWidget {
  final bool? isAppBar;

  const CreateMusic({super.key, this.isAppBar});

  @override
  State<CreateMusic> createState() => _CreateMusicState();
}

class _CreateMusicState extends State<CreateMusic> {
  late final List<Category> category = [];
  late final List<Language> language = [];
  late final List<Artist> artist = [];
  int? selectCat;
  int? selectLang;
  int? selectArt;
  File? mp3File;
  found.Uint8List? mp3Byte;
  String? mp3Name;
  File? thumbImage;
  found.Uint8List? imageByte;
  String? imageName;
  final TextEditingController descController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  bool isLoad = false;
  int isLike = 1;
  int isComment = 1;

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

  @override
  void initState() {
    getMusicData();
    super.initState();
  }

  getMusicData() async {
    setState(() {
      isLoad = true;
    });
    MusicModel music = await ApiService().getMusicData();
    if (music.status == 200) {
      setState(() {
        category.addAll(music.result.category);
        language.addAll(music.result.language);
        artist.addAll(music.result.artist);
      });
    }
    setState(() {
      isLoad = false;
    });
  }

  Future<void> _pickMp3File() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      //   allowedExtensions: ['mp3', 'wav', 'aac', 'ogg', 'flac', 'm4a'],
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
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        Utils().hideProgress(context);
      },
      child: Scaffold(
        backgroundColor: appbgcolor,
        appBar: widget.isAppBar == false
            ? null
            : AppBar(
                backgroundColor: appBarColor,
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: white,
                  ),
                ),
                title: MyText(
                  text: "uploadmusic",
                  color: white,
                  fontwaight: FontWeight.bold,
                  fontsizeNormal: Dimens.textBig,
                ),
              ),
        bottomNavigationBar: GestureDetector(
          onTap: () async {
            if (mp3Byte == null) {
              return Utils()
                  .showSnackBar(context, "Content field is required", false);
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
              return Utils().showSnackBar(
                  context, "Description field is required", false);
            }
            if (selectCat == null) {
              return Utils()
                  .showSnackBar(context, "Category field is required", false);
            }
            if (selectLang == null) {
              return Utils()
                  .showSnackBar(context, "Language field is required", false);
            }
            if (selectArt == null) {
              return Utils()
                  .showSnackBar(context, "Artist field is required", false);
            }
            Utils.showProgress(context);

            success.SuccessModel music = await ApiService().createMusic(
                Constant.channelID.toString(),
                mp3File,
                thumbImage,
                selectCat!,
                selectLang!,
                selectArt!,
                isLike,
                isComment,
                titleController.text,
                descController.text,
                musicBytes: mp3Byte,
                musicName: mp3Name,
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
        body: isLoad
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Utils().pageBg(
                context,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Utils().titleText("content"),
                        mp3Byte != null
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
                                      width: ResponsiveHelper.checkIsWeb(
                                              context)
                                          ? MediaQuery.of(context).size.width *
                                              0.38
                                          : MediaQuery.of(context).size.width *
                                              0.45,
                                      height:
                                          MediaQuery.of(context).size.height,
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
                                    height: ResponsiveHelper.checkIsWeb(context)
                                        ? 200
                                        : 180,
                                    width: ResponsiveHelper.checkIsWeb(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.38
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
                              ),
                        Utils().titleText("thumbnailimage"),
                        imageByte != null
                            ? InkWell(
                                onTap: () async {
                                  _pickThumbnailImage();
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: SizedBox(
                                      height:
                                          ResponsiveHelper.checkIsWeb(context)
                                              ? 200
                                              : 180,
                                      child:
                                          ResponsiveHelper.checkIsWeb(context)
                                              ? Image.memory(
                                                  imageByte!,
                                                  width: ResponsiveHelper
                                                          .checkIsWeb(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.38
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.45,
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(
                                                  thumbImage!,
                                                  width: ResponsiveHelper
                                                          .checkIsWeb(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.38
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.45,
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
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
                                    height: ResponsiveHelper.checkIsWeb(context)
                                        ? 200
                                        : 180,
                                    width: ResponsiveHelper.checkIsWeb(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.38
                                        : MediaQuery.of(context).size.width *
                                            0.45,
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
                        Utils().myTextField(
                            titleController,
                            TextInputAction.next,
                            TextInputType.text,
                            "title",
                            false),
                        Utils().titleText("description"),
                        Utils().myTextField(
                            descController,
                            TextInputAction.next,
                            TextInputType.text,
                            "description",
                            false),
                        Utils().titleText("category"),
                        DropdownButtonFormField<int>(
                          value: selectCat,
                          dropdownColor: colorPrimaryDark,
                          hint: MyText(
                              text: "select", color: white, fontsizeNormal: 14),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 11, horizontal: 11),
                            filled: true,
                            fillColor: buttonDisable,
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: transparent),
                                borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: transparent),
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          items: category.map((category) {
                            return DropdownMenuItem<int>(
                              value: category.id, // only use ID
                              child: Text(
                                category.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: white),
                              ), // display name
                            );
                          }).toList(),
                          onChanged: (int? newId) {
                            setState(() {
                              selectCat = newId!;
                            });
                          },
                        ),
                        Utils().titleText("language"),
                        DropdownButtonFormField<int>(
                          value: selectLang,
                          dropdownColor: colorPrimaryDark,
                          hint: MyText(
                              text: "select", color: white, fontsizeNormal: 14),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 11, horizontal: 11),
                            filled: true,
                            fillColor: buttonDisable,
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: transparent),
                                borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: transparent),
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          items: language.map((category) {
                            return DropdownMenuItem<int>(
                              value: category.id, // only use ID
                              child: Text(
                                category.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: white),
                              ), // display name
                            );
                          }).toList(),
                          onChanged: (int? newId) {
                            setState(() {
                              selectLang = newId!;
                            });
                          },
                        ),
                        Utils().titleText("artist"),
                        DropdownButtonFormField<int>(
                          value: selectArt,
                          dropdownColor: colorPrimaryDark,
                          hint: MyText(
                              text: "select", color: white, fontsizeNormal: 14),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 11, horizontal: 11),
                            filled: true,
                            fillColor: buttonDisable,
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: transparent),
                                borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: transparent),
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          items: artist.map((category) {
                            return DropdownMenuItem<int>(
                              value: category.id, // only use ID
                              child: Text(
                                category.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: white),
                              ), // display name
                            );
                          }).toList(),
                          onChanged: (int? newId) {
                            setState(() {
                              selectArt = newId!;
                            });
                          },
                        ),
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
                ),
              ),
      ),
    );
  }
}
