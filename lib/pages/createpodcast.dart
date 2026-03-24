import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' as found;
import 'package:flutter/material.dart';
import 'package:fanbae/pages/podcastepisode.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:fanbae/utils/utils.dart';

import '../model/musicmodel.dart';
import '../model/podcastmodel.dart' as pod;
import '../model/successmodel.dart' as success;
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../webservice/apiservice.dart';
import '../widget/mytext.dart';

class CreatePodcast extends StatefulWidget {
  final bool? isAppBar;
  const CreatePodcast({super.key, this.isAppBar});

  @override
  State<CreatePodcast> createState() => _CreatePodcastState();
}

class _CreatePodcastState extends State<CreatePodcast> {
  List type = ["New", "Already Exists"];
  String selectedType = "New";
  late final List<Category> category = [];
  late final List<Language> language = [];
  final TextEditingController descController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  int? selectCat;
  int? selectLang;
  bool isLoad = false;
  File? thumbImage;
  found.Uint8List? imageByte;
  String? imageName;
  late List<pod.Result> podcast = [];
  int? selectPod;

  @override
  void initState() {
    getMusicData();
    super.initState();
  }

  getMusicData() async {
    setState(() {
      isLoad = true;
    });
    pod.PodcastModel data = await ApiService().getPodcasts();
    if (data.status == 200) {
      setState(() {
        podcast = data.result;
      });
    }
    MusicModel music = await ApiService().getMusicData();
    if (music.status == 200) {
      setState(() {
        category.addAll(music.result.category);
        language.addAll(music.result.language);
      });
    }
    setState(() {
      isLoad = false;
    });
  }

  Future<void> _pickThumbnailImage() async {
    FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true);

    if (pickedImage != null) {
      PlatformFile pickedFile = pickedImage.files.first;
      if (found.kIsWeb) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          ResponsiveHelper.checkIsWeb(context) ? colorPrimaryDark : appbgcolor,
      appBar: ResponsiveHelper.checkIsWeb(context) || widget.isAppBar == false
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
                text: "podcast",
                color: white,
                fontwaight: FontWeight.bold,
                fontsizeNormal: Dimens.textBig,
              ),
            ),
      bottomNavigationBar: GestureDetector(
        onTap: selectedType == "Already Exists"
            ? () {
                if (selectPod == null) {
                  return Utils().showSnackBar(
                      context, "Podcast field is required", false);
                }
                Navigator.pop(context);
                ResponsiveHelper.checkIsWeb(context)
                    ? buildCreatePostDialog()
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return PodcastEpisode(
                              id: selectPod!,
                            );
                          },
                        ),
                      );
              }
            : () async {
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
                  return Utils().showSnackBar(
                      context, "Category field is required", false);
                }
                if (selectLang == null) {
                  return Utils().showSnackBar(
                      context, "Language field is required", false);
                }
                Utils.showProgress(context);

                pod.PodcastModel music = await ApiService().createPodcast(
                    null,
                    titleController.text,
                    descController.text,
                    thumbImage,
                    selectCat!,
                    selectLang!,
                    imageBytes: imageByte,
                    imageName: imageName);
                Utils().hideProgress(context);
                Utils().showSnackBar(context, music.message, false);
                debugPrint(music.message);
                if (music.status == 200) {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PodcastEpisode(id: music.result[0].id),
                      ));
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
              text: "continue",
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
          child: isLoad
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Utils().titleText("type"),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: type.map((type) {
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
                                  style: TextStyle(
                                      color: white), // customize as needed
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        if (selectedType != "New") ...[
                          Utils().titleText("podcast"),
                          DropdownButtonFormField<int>(
                            value: selectPod,
                            dropdownColor: colorPrimaryDark,
                            hint: MyText(
                                text: "select",
                                color: white,
                                fontsizeNormal: 14),
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
                            items: podcast.map((podcast) {
                              return DropdownMenuItem<int>(
                                value: podcast.id, // only use ID
                                child: Text(
                                  podcast.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: white),
                                ), // display name
                              );
                            }).toList(),
                            onChanged: (int? newId) {
                              setState(() {
                                selectPod = newId!;
                              });
                            },
                          ),
                        ],
                        if (selectedType == "New") ...[
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
                                        child: ResponsiveHelper.checkIsWeb(
                                                context)
                                            ? Image.memory(
                                                imageByte!,
                                                width:
                                                    ResponsiveHelper.checkIsWeb(
                                                            context)
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
                                                width:
                                                    ResponsiveHelper.checkIsWeb(
                                                            context)
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
                                      height:
                                          ResponsiveHelper.checkIsWeb(context)
                                              ? 200
                                              : 180,
                                      width: ResponsiveHelper.checkIsWeb(
                                              context)
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
                                text: "select",
                                color: white,
                                fontsizeNormal: 14),
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
                                value: category.id,
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
                                text: "select",
                                color: white,
                                fontsizeNormal: 14),
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
                                ),
                              );
                            }).toList(),
                            onChanged: (int? newId) {
                              setState(() {
                                selectLang = newId!;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                )),
    );
  }

  buildCreatePostDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: transparent,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 115, vertical: 70),
          backgroundColor: colorPrimaryDark,
          child: Stack(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: colorPrimaryDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: PodcastEpisode(
                  id: selectPod!,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: white.withOpacity(0.3), shape: BoxShape.circle),
                    child: const Icon(
                      Icons.close,
                      size: 23,
                      color: Colors.white, // or any color that suits your theme
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
