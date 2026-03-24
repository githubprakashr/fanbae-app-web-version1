import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/model/creatoradmodel.dart' as ads;
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:image_picker/image_picker.dart';

import '../model/postcontentuploadmodel.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/responsive_helper.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';

class CreateAd extends StatefulWidget {
  final ads.Result? ad;

  const CreateAd({super.key, this.ad});

  @override
  State<CreateAd> createState() => _CreateAdState();
}

class _CreateAdState extends State<CreateAd> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  List<Map<String, dynamic>> types = [
    {"id": 1, "name": "Banner Ads"},
    {"id": 2, "name": "Interstital Ads"},
    {"id": 3, "name": "Reward Ads"},
  ];
  int type = 1;

  ImagePicker picker = ImagePicker();
  PostContentUploadModel postContentModel = PostContentUploadModel();
  Result? image;
  Result? video;

  @override
  void initState() {
    if (widget.ad != null) {
      titleController.text = widget.ad!.title;
      priceController.text = widget.ad!.budget.toString();
      urlController.text = widget.ad!.redirectUri;
      type = widget.ad!.type;
    }
    super.initState();
  }

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
          fileBytes: pickedFile.bytes,
          filename: pickedFile.name,
        );
      }
    }
  }

  contentUploadApi(File? content, contentType,
      {Uint8List? fileBytes, String? filename}) async {
    Utils.showProgress(context);

    try {
      postContentModel = await ApiService().postContentUpload(
        contentType,
        content,
        fileBytes: fileBytes,
        filename: filename,
      );

      if (postContentModel.status == 200) {
        setState(() {
          contentType == '1'
              ? image = postContentModel.result
              : video = postContentModel.result;
        });
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      Utils().showSnackBar(context, "Upload failed. Please try again.", false);
    } finally {
      if (mounted) Utils().hideProgress(context);
    }
  }

  Widget buildContent1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Utils().titleText("title"),
        Utils().myTextField(titleController, TextInputAction.next,
            TextInputType.text, 'title', false),
        Utils().titleText("budget"),
        Utils().myTextField(priceController, TextInputAction.next,
            TextInputType.number, 'budget', false),
      ],
    );
  }

  Widget buildContent2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Utils().titleText("redirecturl"),
        Utils().myTextField(urlController, TextInputAction.next,
            TextInputType.text, 'redirecturl', false),
        Utils().titleText("type"),
        DropdownButtonFormField<int>(
          value: type,
          dropdownColor: colorPrimaryDark,
          hint: MyText(text: "select", color: white, fontsizeNormal: 14),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 11, horizontal: 11),
            filled: true,
            fillColor: buttonDisable,
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: transparent),
                borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: transparent),
                borderRadius: BorderRadius.circular(8)),
          ),
          items: types.map((item) {
            return DropdownMenuItem<int>(
              value: item['id'],
              child: Text(
                item['name'],
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: white),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              type = value!;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: ResponsiveHelper.checkIsWeb(context)
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
                  text: widget.ad != null ? "editad" : "createad",
                  color: white),
            ),
      body: Utils().pageBg(
        context,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(
                      ResponsiveHelper.isDesktop(context) ? 20 : 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Utils().titleText("image"),
                      widget.ad?.image != null || image != null
                          ? InkWell(
                              onTap: () async {
                                _pickImageFromGallery();
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: SizedBox(
                                  height: kIsWeb ? 200 : 180,
                                  child: MyNetworkImage(
                                    imagePath: image != null
                                        ? image!.contentUrl!
                                        : widget.ad!.image,
                                    width: kIsWeb
                                        ? MediaQuery.of(context).size.width *
                                            0.38
                                        : MediaQuery.of(context).size.width *
                                            0.45,
                                    height: MediaQuery.of(context).size.height,
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
                                  _pickImageFromGallery();
                                },
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: transparent,
                                  ),
                                  height: kIsWeb ? 200 : 180,
                                  width: kIsWeb
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
                            ),
                      buildContent1(),
                      buildContent2(),
                      if (type == 3) ...[
                        Utils().titleText("video"),
                        widget.ad?.video != null || video != null
                            ? InkWell(
                                onTap: () async {
                                  _pickVideoFromGallery();
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: SizedBox(
                                    height: kIsWeb ? 200 : 180,
                                    child: MyNetworkImage(
                                      imagePath: video != null
                                          ? video!.thumbnailImageUrl!
                                          : widget.ad!.videoImage,
                                      width: kIsWeb
                                          ? MediaQuery.of(context).size.width *
                                              0.38
                                          : MediaQuery.of(context).size.width *
                                              0.45,
                                      height:
                                          MediaQuery.of(context).size.height,
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
                                      borderRadius: BorderRadius.circular(5),
                                      color: transparent,
                                    ),
                                    height: kIsWeb ? 200 : 180,
                                    width: kIsWeb
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
                      ]
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (widget.ad == null && image == null) {
                  return Utils()
                      .showSnackBar(context, "Image field is required", false);
                }
                if (titleController.text.isEmpty) {
                  return Utils()
                      .showSnackBar(context, "Title field is required", false);
                }
                if (priceController.text.isEmpty) {
                  return Utils()
                      .showSnackBar(context, "Budget field is required", false);
                }
                if (urlController.text.isEmpty) {
                  return Utils().showSnackBar(
                      context, "Redirect Url field is required", false);
                }
                if (type == 3 &&
                    (widget.ad != null &&
                        widget.ad!.video.isEmpty &&
                        video == null)) {
                  return Utils()
                      .showSnackBar(context, "Video field is required", false);
                }
                Utils.showProgress(context);

                SuccessModel ad = await ApiService().createAds(
                  widget.ad?.id,
                  Constant.userID.toString(),
                  titleController.text,
                  int.parse(priceController.text),
                  type,
                  urlController.text,
                  image != null ? image!.contentUrl! : widget.ad!.image,
                  type == 3
                      ? video != null
                          ? video!.contentUrl!
                          : widget.ad!.video
                      : null,
                  type == 3
                      ? video != null
                          ? video!.thumbnailImageUrl!
                          : widget.ad!.videoImage
                      : null,
                );

                if (!mounted) return;
                Utils().hideProgress(context);
                if (mounted) {
                  Utils().showSnackBar(context, "${ad.message}", false);
                }
                if (ad.status == 200) {
                  Navigator.pop(context);
                }
              },
              child: Container(
                height: 48,
                margin: const EdgeInsets.only(
                    left: 15, right: 15, top: 15, bottom: 15),
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
                    fontwaight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
              ),
            )
          ],
        ),
      ),
    );
  }
}
