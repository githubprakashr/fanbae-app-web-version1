import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/model/getepisodelist.dart' as epi;
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../model/postcontentuploadmodel.dart';
import '../provider/createvideoprovider.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/responsive_helper.dart';
import '../widget/mynetworkimg.dart';
import 'package:fanbae/model/categorymodel.dart' as cat;

class CreateVideo extends StatefulWidget {
  final bool? isAppBar;

  const CreateVideo({super.key, this.isAppBar});

  @override
  State<CreateVideo> createState() => _CreateVideoState();
}

class _CreateVideoState extends State<CreateVideo> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController coinController = TextEditingController();
  final TextEditingController rentPriceController = TextEditingController();
  final TextEditingController episodeController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  PostContentUploadModel postContentModel = PostContentUploadModel();
  Result? postContent;
  late List<cat.Result> categories;
  cat.Result? selectedCategory;
  int isRent = 0;
  int isLike = 1;
  int isComment = 1;
  String type = 'free';
  bool isLoad = false;
  List<epi.Result> episode = [];
  String? selectedEpisode;
  List videoType = ["Standard Alone", "Episode"];
  String selectedVideoType = "Standard Alone";

  @override
  void initState() {
    fetchAllData(pageNo: 0);
    super.initState();
  }

  fetchAllData({required int pageNo}) async {
    setState(() {
      isLoad = true;
    });
    cat.CategoryModel categoryModel = await ApiService().videoCategory(pageNo);
    setState(() {
      categories = categoryModel.result!;
    });
    if (categoryModel.morePage == true) {
      fetchAllData(pageNo: pageNo + 1);
    }
    if (pageNo == 0) {
      epi.GetEpisodeList episodeModel = await ApiService().getEpisodeList();
      if (episodeModel.status == 200) {
        episode = episodeModel.result;
      }
    }
    setState(() {
      isLoad = false;
    });
  }

  _pickVideoFromGallery() async {
    try {
      FilePickerResult? pickedVideo = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi', 'webm', 'mkv'],
        withData: kIsWeb,
      );

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
            filename: pickedFile.name,
          );
        }
      }
    } catch (e) {
      debugPrint("File picking error: $e");
      Utils().showSnackBar(context, "Failed to pick video.", false);
    }
  }

  /// ✅ Upload API optimized for large files
  Future<void> contentUploadApi(
    File? content,
    String contentType, {
    Uint8List? fileBytes,
    String? filename,
  }) async {
    Utils.showProgress(context);

    try {
      postContentModel = await ApiService().contentUpload(
        contentType,
        content,
        fileBytes: fileBytes,
        filename: filename,
      );

      if (!mounted) return;
      Utils().hideProgress(context);

      if (postContentModel.status == 200) {
        setState(() {
          postContent = postContentModel.result;
        });
        Utils().showSnackBar(context, "Upload successful!", false);
      } else {
        String errorMsg =
            postContentModel.message ?? "Upload failed. Try again.";
        Utils().showSnackBar(context, errorMsg, false);
        debugPrint(
            "Upload failed with status: ${postContentModel.status}, message: $errorMsg");
      }
    } catch (e) {
      debugPrint("❌ Upload error: $e");
      if (!mounted) return;
      Utils().hideProgress(context);

      String errorMsg = "Upload failed. Please try again.";
      if (e.toString().contains("SocketException") ||
          e.toString().contains("network")) {
        errorMsg = "Network error. Please check your connection.";
      } else if (e.toString().contains("TimeoutException")) {
        errorMsg = "Upload timeout. File may be too large.";
      }

      Utils().showSnackBar(context, errorMsg, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        Utils().hideProgress(context);
      },
      child: Scaffold(
        backgroundColor: ResponsiveHelper.checkIsWeb(context)
            ? colorPrimaryDark
            : appbgcolor,
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
                  text: "uploadvideo",
                  color: white,
                  fontwaight: FontWeight.bold,
                  fontsizeNormal: Dimens.textBig,
                ),
              ),
        body: isLoad
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Utils().pageBg(
                context,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Utils().titleText("content")),
                              postContent != null
                                  ? InkWell(
                                      onTap: () async {
                                        _pickVideoFromGallery();
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: SizedBox(
                                          height: ResponsiveHelper.checkIsWeb(
                                                  context)
                                              ? 200
                                              : 180,
                                          child: MyNetworkImage(
                                            imagePath: postContent
                                                    ?.thumbnailImageUrl ??
                                                "",
                                            width: ResponsiveHelper.checkIsWeb(
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
                                          _pickVideoFromGallery();
                                        },
                                        child: Container(
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: transparent,
                                          ),
                                          height: ResponsiveHelper.checkIsWeb(
                                                  context)
                                              ? 200
                                              : 180,
                                          width: ResponsiveHelper.checkIsWeb(
                                                  context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.38
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
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
                              Utils().titleText("title"),
                              Utils().myTextField(
                                  titleController,
                                  TextInputAction.next,
                                  TextInputType.text,
                                  'title',
                                  false),
                              Utils().titleText("description"),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: 130,
                                  minWidth: MediaQuery.of(context).size.width,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  decoration: Utils.setBGWithBorder(transparent,
                                      gray.withOpacity(0.7), 10, 0.5),
                                  child: TextFormField(
                                    controller: descriptionController,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      hintText: 'Enter the description here...',
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 15,
                                        color: white,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FontStyle.normal,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    style: GoogleFonts.inter(
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        color: white,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DropdownButtonFormField<cat.Result>(
                                value: selectedCategory,
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
                                          BorderSide(color: transparent),
                                      borderRadius: BorderRadius.circular(8)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: transparent),
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                items: categories.map((item) {
                                  return DropdownMenuItem<cat.Result>(
                                    value: item,
                                    child: Text(
                                      item.name ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: white),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                },
                              ),
                              Utils().titleText("videotype"),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: videoType.map((type) {
                                  return Row(
                                    children: [
                                      Radio<String>(
                                        value: type,
                                        groupValue: selectedVideoType,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedVideoType = value!;
                                          });
                                        },
                                        activeColor: colorPrimary, // optional
                                      ),
                                      Text(
                                        type,
                                        style: TextStyle(
                                            color:
                                                white), // customize as needed
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              selectedVideoType == "Episode"
                                  ? Utils().titleText("episodename")
                                  : const SizedBox(),
                              if (selectedVideoType == "Episode" &&
                                  episode.isNotEmpty) ...[
                                DropdownButtonFormField<String>(
                                  value: selectedEpisode,
                                  dropdownColor: colorPrimaryDark,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 12),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white))),
                                  items: [
                                    ...episode.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item.episodeName,
                                        child: Text(
                                          item.episodeName ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: white),
                                        ),
                                      );
                                    }).toList(),
                                    if (episode.isNotEmpty)
                                      DropdownMenuItem<String>(
                                        value: "Other",
                                        child: Text(
                                          "Other",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: white),
                                        ),
                                      ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedEpisode = value;
                                      selectedEpisode == "Other"
                                          ? episodeController.text = ''
                                          : episodeController.text =
                                              selectedEpisode!;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                )
                              ],
                              (selectedVideoType == "Episode" &&
                                      (episode.isEmpty ||
                                          selectedEpisode == "Other"))
                                  ? Utils().myTextField(
                                      episodeController,
                                      TextInputAction.next,
                                      TextInputType.text,
                                      'title',
                                      false)
                                  : const SizedBox(),
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
                                        color: white,
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
                                        color: white,
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
                                        color: white,
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
                                        color: white,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (isRent == 1) ...[
                                Utils().titleText("rentprice"),
                                Utils().myTextField(
                                    rentPriceController,
                                    TextInputAction.next,
                                    TextInputType.number,
                                    'Rent price',
                                    false),
                              ],
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
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (postContent?.contentUrl == null) {
                          return Utils().showSnackBar(
                              context, "Content field is required", false);
                        }
                        if (titleController.text.isEmpty) {
                          return Utils().showSnackBar(
                              context, "Title field is required", false);
                        }

                        if (descriptionController.text.isEmpty) {
                          return Utils().showSnackBar(
                              context, "Description field is required", false);
                        }

                        if (selectedCategory == null) {
                          return Utils().showSnackBar(
                              context, "Category field is required", false);
                        }
                        if (type == "pay" && coinController.text.isEmpty) {
                          return Utils().showSnackBar(
                              context, "Price is required.", false);
                        }
                        if (isRent == 1 && rentPriceController.text.isEmpty) {
                          return Utils().showSnackBar(
                              context, "Rent price is required.", false);
                        }
                        if (selectedVideoType == "Episode" &&
                            episodeController.text.isEmpty) {
                          return Utils().showSnackBar(
                              context, "Episode Name is required.", false);
                        }

                        Utils.showProgress(context);
                        final createVideoProvider =
                            Provider.of<CreateVideoProvider>(context,
                                listen: false);

                        await createVideoProvider.createVideo(
                            Constant.channelID ?? '',
                            postContent!.contentUrl!,
                            '2',
                            postContent!.thumbnailImage!,
                            titleController.text,
                            descriptionController.text,
                            selectedCategory!.id!,
                            isRent,
                            rentPriceController.text.isNotEmpty
                                ? int.parse(rentPriceController.text)
                                : 0,
                            isLike,
                            isComment,
                            type,
                            coinController.text.isNotEmpty
                                ? int.parse(coinController.text)
                                : 0,
                            selectedVideoType == "Episode"
                                ? "episode"
                                : "standard_alone",
                            episodeController.text);
                        if (!mounted) return;
                        Utils().hideProgress(context);
                        Utils().showSnackBar(
                            context,
                            "${createVideoProvider.createVideoModel.message}",
                            false);

                        if (!createVideoProvider.loading &&
                            createVideoProvider.createVideoModel.status ==
                                200) {
                          Future.delayed(const Duration(milliseconds: 600), () {
                            if (mounted) Navigator.pop(context);
                          });
                        }
                      },
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.only(
                            top: 15, bottom: 25, left: 15, right: 15),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7)),
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
                  ],
                ),
              ),
      ),
    );
  }
}
