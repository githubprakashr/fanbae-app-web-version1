import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:fanbae/pages/bottombar.dart';
import 'package:fanbae/provider/postvideoprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:fanbae/utils/string.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UploadVideo extends StatefulWidget {
  final String? fileType, hashtagName, hashtagId, type;
  final File videoFile, videoImageFile;
  const UploadVideo({
    required this.videoFile,
    required this.videoImageFile,
    required this.fileType,
    required this.hashtagName,
    required this.hashtagId,
    super.key,
    this.type,
  });

  @override
  State<UploadVideo> createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {
  final ImagePicker imagePicker = ImagePicker();
  late PostVideoProvider postVideoProvider;
  SharedPre sharePref = SharedPre();
  File? finalVideoFile, pickedCoverFile;
  String? imageFromVideo, userProfile;
  final mCommentController = TextEditingController();
  int isLike = 1;
  int isComment = 1;

  @override
  void initState() {
    printLog("fileType ====> ${widget.fileType}");
    postVideoProvider = Provider.of<PostVideoProvider>(context, listen: false);
    finalVideoFile = widget.videoFile;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
    super.initState();
  }

  _getData() async {
    userProfile = await sharePref.read("userimage");
    printLog("_getData userProfile ======> $userProfile");
    printLog("_getData videoFile ========> ${finalVideoFile?.path}");
    printLog("_getData videoImageFile ===> ${widget.videoImageFile.path}");
    pickedCoverFile = widget.videoImageFile;
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.hashtagName ?? "").isNotEmpty) {
      if (mCommentController.text.toString().isEmpty) {
        mCommentController.text = (widget.hashtagName ?? "").contains("#")
            ? (widget.hashtagName ?? "")
            : "#${(widget.hashtagName ?? "")}";
      }
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: appbgcolor,
      appBar: Utils().otherPageAppBar(context, "uploads", true),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Utils.buildGradLine(),
                  const SizedBox(height: 20),
                  /* Profile Image & Video description */
                  _buildUserVideoDesc(),
                  const SizedBox(height: 40),
                  /* Select Cover */
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: MyText(
                      multilanguage: true,
                      color: white,
                      text: "selectcover",
                      fontsizeNormal: 15,
                      fontsizeWeb: 15,
                      fontwaight: FontWeight.w500,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.start,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCovers(),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            /* Post Video Button */
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Consumer<PostVideoProvider>(
                  builder: (context, uploadshortprovider, child) {
                return InkWell(
                  focusColor: transparent,
                  highlightColor: transparent,
                  hoverColor: transparent,
                  splashColor: transparent,
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    if (!uploadshortprovider.uploadLoading) {
                      validateAndUpload();
                    }
                  },
                  child: Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorPrimary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: (postVideoProvider.uploadLoading)
                        ? CircularProgressIndicator(
                            color: colorAccent,
                            strokeWidth: 2,
                          )
                        : MyText(
                            multilanguage: true,
                            color: colorAccent,
                            text: "postvideo",
                            fontsizeNormal: 15,
                            fontsizeWeb: 15,
                            fontwaight: FontWeight.w700,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserVideoDesc() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints(minHeight: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: Utils.setGradTTBBorderWithBG(
                colorPrimaryDark, colorPrimary, transparent, 30, 1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: MyNetworkImage(
                width: 55,
                height: 55,
                imagePath: Constant.userImage ?? "",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 130,
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                decoration: Utils.setBGWithBorder(
                    transparent, gray.withOpacity(0.7), 10, 0.5),
                child: TextFormField(
                  controller: mCommentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: describeVideoHint,
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
          ),
        ],
      ),
    );
  }

  Widget _buildCovers() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.width,
          minWidth: MediaQuery.of(context).size.width),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(15),
        color: colorPrimary.withOpacity(0.7),
        strokeWidth: 0.5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              if (widget.fileType == "video") {
                imagePickDialog();
              }
            },
            child: Container(
              decoration:
                  Utils.setBGWithBorder(colorPrimaryDark, transparent, 15, 0),
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.width,
                  minWidth: MediaQuery.of(context).size.width),
              child: pickedCoverFile != null
                  ? Image.file(
                      pickedCoverFile!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      margin: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MyImage(
                            imagePath: "ic_no_img.png",
                            height: 50,
                            width: 50,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          MyText(
                            color: white,
                            text: "browse_file",
                            multilanguage: true,
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            fontwaight: FontWeight.w400,
                            fontsizeWeb: 12,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> imagePickDialog() async {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /* Gallery */
                  _buildDialogItem(
                    title: "gallery",
                    isMultiLang: true,
                    fontWeight: FontWeight.w400,
                    itemDecoration: Utils.setBGWithRadius(white, 10, 10, 0, 0),
                    onClick: () {
                      if (Navigator.canPop(context)) {
                        if (!mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      }
                      getFromGallery();
                    },
                  ),
                  const SizedBox(height: 1),
                  /* Camera */
                  _buildDialogItem(
                    title: "camera",
                    isMultiLang: true,
                    fontWeight: FontWeight.w400,
                    itemDecoration: Utils.setBGWithRadius(white, 0, 0, 10, 10),
                    onClick: () {
                      if (Navigator.canPop(context)) {
                        if (!mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      }
                      getFromCamera();
                    },
                  ),
                  const SizedBox(height: 10),
                  /* Cancel */
                  _buildDialogItem(
                    title: "cancel",
                    isMultiLang: true,
                    fontWeight: FontWeight.w600,
                    itemDecoration:
                        Utils.setBGWithRadius(white, 10, 10, 10, 10),
                    onClick: () {
                      if (Navigator.canPop(context)) {
                        if (!mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ).then((value) {
      printLog("============= LOGOUT =============");
      if (!mounted) return;
      setState(() {});
    });
  }

  Widget _buildDialogItem({
    required String title,
    required bool isMultiLang,
    required FontWeight fontWeight,
    required Decoration itemDecoration,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Container(
        height: 50,
        decoration: itemDecoration,
        alignment: Alignment.center,
        child: MyText(
          multilanguage: isMultiLang,
          text: title,
          color: black,
          fontsizeNormal: 16,
          fontsizeWeb: 16,
          maxline: 1,
          fontstyle: FontStyle.normal,
          fontwaight: fontWeight,
          textalign: TextAlign.center,
        ),
      ),
    );
  }

  /// Get from gallery
  getFromGallery() async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      setState(() {
        pickedCoverFile = File(pickedFile.path);
        printLog("Gallery pickedCoverFile ==> ${pickedCoverFile?.path}");
      });
    }
  }

  /// Get from Camera
  getFromCamera() async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      setState(() {
        pickedCoverFile = File(pickedFile.path);
        printLog("Camera pickedCoverFile ==> ${pickedCoverFile?.path}");
      });
    }
  }

  validateAndUpload() async {
    String videoDesc = mCommentController.text.toString().trim();
    printLog("videoDesc ==> $videoDesc");
    if (videoDesc.isEmpty) {
      Utils().showSnackBar(context, "enter_post_description", true);
      return;
    }
    if (pickedCoverFile == null) {
      Utils().showSnackBar(context, "pick_cover_img", true);
      return;
    }
    printLog("videoFile ==> ${finalVideoFile?.path}");
    printLog("final pickedCoverFile ===> ${pickedCoverFile?.path ?? ""}");
    await postVideoProvider.uploadNewVideo(videoDesc, finalVideoFile,
        pickedCoverFile, isLike, isComment, widget.type);
    if (!mounted) {
      if (postVideoProvider.successModel.status == 200) {
        Utils().showSnackBar(
            context, postVideoProvider.successModel.message ?? "", false);
      } else {
        Utils().showSnackBar(
            context, postVideoProvider.successModel.message ?? "", false);
      }
    }
    postVideoProvider.clearProvider();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => const Bottombar(
                isShort: true,
              )),
      (Route<dynamic> route) => false,
    ).then(
      (value) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const Bottombar(
                    isShort: true,
                  )),
        );
      },
    );
  }
}
