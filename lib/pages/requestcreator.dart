import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fanbae/model/governmentdocumentmodel.dart' as doc;
import 'package:fanbae/pages/successpage.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../model/categorymodel.dart';
import '../provider/requestcreatorprovider.dart';
import '../utils/dimens.dart';
import '../utils/responsive_helper.dart';
import '../utils/utils.dart';
import '../webwidget/webcam.dart';
import '../widget/mytext.dart';

class RequestCreator extends StatefulWidget {
  final String email;

  const RequestCreator({super.key, required this.email});

  @override
  State<RequestCreator> createState() => _RequestCreatorState();
}

class _RequestCreatorState extends State<RequestCreator> {
  // Price controllers for step 1
  final TextEditingController liveAmtController = TextEditingController();
  final TextEditingController chatAmtController = TextEditingController();
  final TextEditingController audioCallAmtController = TextEditingController();
  final TextEditingController videoCallAmtController = TextEditingController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Show popup only once when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_popupShown) {
        _showIntroPopup(context);
        _popupShown = true;
      }
    });
  }

  bool _popupShown = false;

  void _showIntroPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF150D26),
                  Color(0xFF2C0C53),
                  Color(0xFF150F27),
                  Color(0xFF591D47)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/intro_popup_image.jpeg',
                    width: 300,
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE67025), Color(0xFFE93276)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                            color: const Color(0xFF8F03FF), width: 1.5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController channelNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController fbController = TextEditingController();
  final TextEditingController name2Controller = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accNoController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  VideoPlayerController? _videoPlayerController;
  List<Result>? categories;
  bool isLoad = false;
  int? selectedCategory;
  bool isAgreed = false;
  bool isAgreed2 = false;
  int step = 1;
  List<doc.Result>? govDoc;
  int? selectedDoc;
  File? file;
  String? fileType;
  Uint8List? fileByte;
  String? fileName;
  File? selfieImage;
  Uint8List? selfieByte;
  String? selfieName;
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;

  Future<void> captureSelfie(BuildContext context) async {
    print(selfieByte);
    try {
      if (ResponsiveHelper.checkIsWeb(context)) {
        // Step 1: Ask permission
        bool granted = await requestWebcamPermission();
        if (!granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Camera permission denied.")),
          );
          return;
        }

        // Step 2: Initialize front camera
        final cameras = await availableCameras();
        final frontCamera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        // Step 3: Open a dialog with live preview + capture button
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AlertDialog(
              title: const Text("Take a Selfie Video"),
              content: AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final image = await _cameraController!.takePicture();
                    final bytes = await image.readAsBytes();

                    selfieByte = bytes;
                    selfieImage = File(image.path);
                    selfieName = image.name;

                    Navigator.pop(context, true);
                  },
                  child: const Text("Capture"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        ).then((_) {
          // Dispose on next frame so CameraPreview is fully gone
          Future.delayed(const Duration(milliseconds: 100), () async {
            await _cameraController?.dispose();
            _cameraController = null;
          });
        });
      } else {
        // --- Mobile: use image_picker ---
        final XFile? image = await _picker.pickVideo(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
        );

        if (image != null) {
          final bytes = await image.readAsBytes();
          setState(() {
            selfieByte = bytes;
            selfieImage = File(image.path);
            selfieName = image.name;
          });
          _videoPlayerController = VideoPlayerController.file(selfieImage!)
            ..initialize()
            ..play();
        }
      }
    } catch (e) {
      debugPrint("Camera error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Camera not available or permission denied.")),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime eighteenYearsAgo =
        DateTime(today.year - 18, today.month, today.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo,
      firstDate: DateTime(1900),
      lastDate: eighteenYearsAgo,
    );

    if (picked != null) {
      dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    } else {}
  }

  @override
  void initState() {
    fetchAllData(pageNo: 0);
    super.initState();
  }

  Future<void> _openCreatorTermsAndConditions() async {
    // Extract base URL from Constant.baseurl (removes only '/api')
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/creator-terms-and-conditions');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(
            context, "Could not open creator terms and conditions", false);
      }
    }
  }

  Future<void> _openCreatorOnboardingAttestation() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/creator-onboard-attestation');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(
            context, "Could not open creator onboarding attestation", false);
      }
    }
  }

  Future<void> _openAntiTraffickingConsent() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/anti-trafficking-consent');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(context,
            "Could not open anti-trafficking consent declaration", false);
      }
    }
  }

  Future<void> _openChildSafetyAndCSAM() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/child-safety-csam');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(
            context, "Could not open child safety and CSAM policy", false);
      }
    }
  }

  Future<void> _openAcceptableUsePolicy() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/acceptable-use-policy');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(
            context, "Could not open acceptable use policy", false);
      }
    }
  }

  Future<void> _openCommunityGuidelines() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/community-guidelines');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(
            context, "Could not open community guidelines", false);
      }
    }
  }

  Future<void> _openCreatorPayoutPolicy() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/creator-payout');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(
            context, "Could not open creator payout policy", false);
      }
    }
  }

  fetchAllData({required int pageNo}) async {
    setState(() {
      isLoad = true;
    });
    CategoryModel categoryModel = await ApiService().videoCategory(pageNo);
    setState(() {
      categories = categoryModel.result;
    });
    if (categoryModel.morePage == true) {
      fetchAllData(pageNo: pageNo + 1);
    }
    doc.GovernmentDocumentModel document =
        await ApiService().getGovernmentDocuments();
    setState(() {
      govDoc = document.result;
    });
    setState(() {
      isLoad = false;
    });
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true);

    if (result != null) {
      PlatformFile pickedFile = result.files.first;
      final extension = pickedFile.name.split('.').last.toLowerCase();

      setState(() {
        fileType = (extension == 'pdf') ? 'pdf' : 'image';
      });
      if (kIsWeb) {
        setState(() {
          fileByte = pickedFile.bytes;
          fileName = pickedFile.name;
        });
      } else {
        setState(() {
          file = File(pickedFile.path!);
          fileByte = pickedFile.bytes;
          fileName = pickedFile.name;
        });
      }
    }
  }

  Widget stepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Utils().titleText("name"),
        Utils().myTextField(nameController, TextInputAction.next,
            TextInputType.text, 'Name', false),
        Utils().titleText("dateofbirth"),
        Utils().myTextField(
          dateController,
          TextInputAction.next,
          TextInputType.text,
          'Date of Birth',
          true,
          onTap: () {
            _selectDate(context);
          },
        ),
        Utils().titleText("channelname"),
        Utils().myTextField(channelNameController, TextInputAction.next,
            TextInputType.text, 'Channel Name', false),
        Utils().titleText("category"),
        DropdownButtonFormField<int>(
          value: selectedCategory,
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
          items: categories?.map((category) {
            return DropdownMenuItem<int>(
              value: category.id, // only use ID
              child: Text(
                category.name!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: white),
              ), // display name
            );
          }).toList(),
          onChanged: (int? newId) {
            setState(() {
              selectedCategory = newId!;
            });
          },
        ),
        Utils().titleText("youtubelink"),
        Utils().myTextField(youtubeController, TextInputAction.next,
            TextInputType.text, 'Youtube Link', false),
        Utils().titleText("instagramlink"),
        Utils().myTextField(instagramController, TextInputAction.next,
            TextInputType.text, 'Instagram Link', false),
        Utils().titleText("fblink"),
        Utils().myTextField(fbController, TextInputAction.next,
            TextInputType.text, 'Facebook Link', false),

        // New price fields
        Utils().titleText("liveprice"),
        Utils().myTextField(liveAmtController, TextInputAction.next,
            TextInputType.number, "Coins per Live Stream", false),
        Utils().titleText("chatprice"),
        Utils().myTextField(chatAmtController, TextInputAction.next,
            TextInputType.number, "Coins per chat", false),
        Utils().titleText("audiocallprice"),
        Utils().myTextField(audioCallAmtController, TextInputAction.next,
            TextInputType.number, "Coins per Audio Call", false),
        Utils().titleText("videocallprice"),
        Utils().myTextField(videoCallAmtController, TextInputAction.next,
            TextInputType.number, "Coins per Video Call", false),

        const SizedBox(height: 10),
        CheckboxListTile(
          contentPadding: const EdgeInsets.all(0),
          activeColor: colorPrimary,
          title: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              children: [
                const TextSpan(text: "I agree I am 18+ and accept "),
                TextSpan(
                  text: "Creator Terms & Conditions",
                  style: TextStyle(
                    color: colorPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _openCreatorTermsAndConditions,
                ),
                const TextSpan(text: ", "),
                TextSpan(
                  text: "Creator Onboarding Attestation",
                  style: TextStyle(
                    color: colorPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _openCreatorOnboardingAttestation,
                ),
                const TextSpan(text: ", "),
                TextSpan(
                  text: "Anti-Trafficking & Consent Declaration",
                  style: TextStyle(
                    color: colorPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _openAntiTraffickingConsent,
                ),
                const TextSpan(text: ", "),
                TextSpan(
                  text: "Child Safety & CSAM Policy",
                  style: TextStyle(
                    color: colorPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _openChildSafetyAndCSAM,
                ),
                const TextSpan(text: ", "),
                TextSpan(
                  text: "Acceptable Use Policy",
                  style: TextStyle(
                    color: colorPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _openAcceptableUsePolicy,
                ),
                const TextSpan(text: ", "),
                TextSpan(
                  text: "Community Guidelines",
                  style: TextStyle(
                    color: colorPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _openCommunityGuidelines,
                ),
                const TextSpan(text: ", and "),
                TextSpan(
                  text: "Creator Payout Policy",
                  style: TextStyle(
                    color: colorPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _openCreatorPayoutPolicy,
                ),
              ],
            ),
          ),
          value: isAgreed,
          onChanged: (bool? value) {
            setState(() {
              isAgreed = value ?? false;
            });
          },
          controlAffinity:
              ListTileControlAffinity.leading, // checkbox on the left
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget stepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Utils().titleText("governmentid"),
        const SizedBox(
          height: 8,
        ),
        DropdownButtonFormField<int>(
          value: selectedDoc,
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
          items: govDoc?.map((category) {
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
              selectedDoc = newId!;
            });
          },
        ),
        const SizedBox(
          height: 15,
        ),
        Utils().titleText("uploadid"),
        const SizedBox(
          height: 8,
        ),
        fileByte != null
            ? InkWell(
                onTap: () async {
                  pickFile();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: SizedBox(
                    height: kIsWeb ? 200 : 180,
                    child: fileType == 'image'
                        ? kIsWeb
                            ? Image.memory(
                                fileByte!,
                                width: kIsWeb
                                    ? MediaQuery.of(context).size.width * 0.38
                                    : MediaQuery.of(context).size.width * 0.45,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                file!,
                                width: kIsWeb
                                    ? MediaQuery.of(context).size.width * 0.38
                                    : MediaQuery.of(context).size.width * 0.45,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                              )
                        : Container(
                            color: colorPrimaryDark,
                            width: kIsWeb
                                ? MediaQuery.of(context).size.width * 0.38
                                : MediaQuery.of(context).size.width * 0.45,
                            height: MediaQuery.of(context).size.height,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.picture_as_pdf,
                                    size: 60, color: Colors.red),
                                const SizedBox(
                                  height: 15,
                                ),
                                MyText(
                                  text: fileName!.split('/').last,
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
                    pickFile();
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
                        : MediaQuery.of(context).size.width * 0.45,
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
        const SizedBox(
          height: 8,
        ),
        CheckboxListTile(
          contentPadding: const EdgeInsets.all(0),
          activeColor: colorPrimary,
          title: MyText(
            text: "agreeterms",
            color: Colors.white,
            fontsizeNormal: 12.5,
          ),
          value: isAgreed2,
          onChanged: (bool? value) {
            setState(() {
              isAgreed2 = value ?? false;
            });
          },
          controlAffinity:
              ListTileControlAffinity.leading, // checkbox on the left
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget stepThree() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.025,
        ),
        selfieByte != null
            ? InkWell(
                onTap: () async {
                  captureSelfie(context);
                },
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(
                      height: ResponsiveHelper.checkIsWeb(context)
                          ? 200
                          : MediaQuery.of(context).size.height * 0.24,
                      child: ResponsiveHelper.checkIsWeb(context)
                          ? Image.memory(
                              selfieByte!,
                              width: ResponsiveHelper.checkIsWeb(context)
                                  ? MediaQuery.of(context).size.width * 0.38
                                  : MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.height,
                              fit: BoxFit.cover,
                            )
                          : AspectRatio(
                              aspectRatio: 9 / 16,
                              child: VideoPlayer(_videoPlayerController!),
                            ),
                    ),
                  ),
                ))
            : Center(
                child: DottedBorder(
                  dashPattern: const [3, 3],
                  radius: const Radius.circular(5),
                  color: colorAccent,
                  child: InkWell(
                    onTap: () async {
                      captureSelfie(context);
                    },
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: transparent,
                      ),
                      height: ResponsiveHelper.checkIsWeb(context)
                          ? 200
                          : MediaQuery.of(context).size.height * 0.24,
                      width: ResponsiveHelper.checkIsWeb(context)
                          ? MediaQuery.of(context).size.width * 0.38
                          : MediaQuery.of(context).size.width * 0.6,
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
              ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.04,
        ),
        GestureDetector(
          onTap: () async {
            captureSelfie(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 11),
            decoration: BoxDecoration(
              gradient: Constant.gradientColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: MyText(
              text: "takeselfie",
              color: black,
              fontwaight: FontWeight.w700,
              fontsizeNormal: 15,
            ),
          ),
        )
      ],
    );
  }

  Widget stepFour() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Utils().titleText("name"),
        Utils().myTextField(name2Controller, TextInputAction.next,
            TextInputType.text, 'Name', false),
        Utils().titleText("bankname"),
        Utils().myTextField(bankNameController, TextInputAction.next,
            TextInputType.text, 'Bank Name', false),
        Utils().titleText("accountno"),
        Utils().myTextField(accNoController, TextInputAction.next,
            TextInputType.text, 'Account Number', false),
        Utils().titleText("ifsccode"),
        Utils().myTextField(ifscCodeController, TextInputAction.next,
            TextInputType.text, 'IFSC Code', false),
      ],
    );
  }

  Widget bottomOne() {
    return InkWell(
      onTap: () async {
        if (nameController.text.isEmpty) {
          return Utils().showSnackBar(context, "Name is required", false);
        }
        if (dateController.text.isEmpty) {
          return Utils().showSnackBar(context, "Date is required", false);
        }
        if (channelNameController.text.isEmpty) {
          return Utils()
              .showSnackBar(context, "Channel Name is required", false);
        }
        if (selectedCategory == null) {
          return Utils().showSnackBar(context, "Category is required", false);
        }
        if (youtubeController.text.isEmpty &&
            instagramController.text.isEmpty &&
            fbController.text.isEmpty) {
          return Utils().showSnackBar(
              context, "need at least 1 social media link", false);
        }
        if (isAgreed == false) {
          return Utils()
              .showSnackBar(context, "Agree our terms and conditions", false);
        }
        setState(() {
          step = 2;
        });
      },
      child: Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(7)),
            gradient: Constant.gradientColor),
        child: MyText(
            color: pureBlack,
            text: "next",
            multilanguage: true,
            textalign: TextAlign.center,
            fontsizeNormal: Dimens.textMedium,
            maxline: 1,
            fontwaight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal),
      ),
    );
  }

  Widget bottomTwo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  step = 1;
                });
              },
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                    gradient: Constant.gradientColor),
                child: MyText(
                    color: pureBlack,
                    text: "previous",
                    multilanguage: true,
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textMedium,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (selectedDoc == null) {
                  return Utils().showSnackBar(
                      context, "Government ID field is required", false);
                }
                if (fileByte == null) {
                  return Utils().showSnackBar(
                      context, "Upload ID field is required", false);
                }
                if (isAgreed2 == false) {
                  return Utils().showSnackBar(
                      context, "Agree our terms and conditions", false);
                }
                setState(() {
                  step = 3;
                });
              },
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                    gradient: Constant.gradientColor),
                child: MyText(
                    color: pureBlack,
                    text: "next",
                    multilanguage: true,
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textMedium,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget bottomThree() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _videoPlayerController?.pause();
                  step = 2;
                });
              },
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                    gradient: Constant.gradientColor),
                child: MyText(
                    color: pureBlack,
                    text: "previous",
                    multilanguage: true,
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textMedium,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (selfieByte == null) {
                  return Utils()
                      .showSnackBar(context, "Selfie Image is required", false);
                }
                setState(() {
                  _videoPlayerController?.pause();
                  step = 4;
                });
              },
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                    gradient: Constant.gradientColor),
                child: MyText(
                    color: pureBlack,
                    text: "next",
                    multilanguage: true,
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textMedium,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
              ),
            ),
          )
        ],
      ),
    );
  }

  void callApi() async {
    Utils.showProgress(context);

    final requestCreatorProvider =
        Provider.of<RequestCreatorProvider>(context, listen: false);

    await requestCreatorProvider.getRequestCreator(
        nameController.text,
        dateController.text,
        channelNameController.text,
        selectedCategory!,
        youtubeController.text,
        instagramController.text,
        fbController.text,
        selectedDoc!,
        file,
        selfieImage,
        name2Controller.text,
        bankNameController.text,
        accNoController.text,
        ifscCodeController.text,
        liveAmtController.text,
        chatAmtController.text,
        audioCallAmtController.text,
        videoCallAmtController.text,
        fileBytes: fileByte,
        fileName: fileName,
        selfieName: selfieName,
        selfieBytes: selfieByte);

    if (!mounted) return;
    Utils().hideProgress(context);

    if (!requestCreatorProvider.loading) {
      if (requestCreatorProvider.requestCreatorModel.status == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const SuccessPage(
                isRequestCreator: true,
              );
            },
          ),
        );
      } else {
        if (mounted) {
          Utils().showSnackBar(context,
              "${requestCreatorProvider.requestCreatorModel.message}", false);
        }
      }
    }
  }

  Widget bottomFour() {
    return GestureDetector(
      onTap: () async {
        if (name2Controller.text.isEmpty) {
          return Utils().showSnackBar(context, "Name is required.", false);
        }
        if (bankNameController.text.isEmpty) {
          return Utils().showSnackBar(context, "Bank Name is required.", false);
        }
        if (accNoController.text.isEmpty) {
          return Utils()
              .showSnackBar(context, "Account Number is required.", false);
        }
        if (ifscCodeController.text.isEmpty) {
          return Utils().showSnackBar(context, "IFSC Code is required.", false);
        }
        callApi();
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
    );
  }

  Future<bool> _onWillPop() async {
    if (step == 1) {
      return true; // allow pop (screen will close)
    } else {
      setState(() {
        step--; // go to previous step
      });
      return false; // prevent pop
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: kIsWeb ? colorPrimaryDark : appbgcolor,
        appBar: ResponsiveHelper.checkIsWeb(context)
            ? null
            : AppBar(
                backgroundColor: appBarColor,
                automaticallyImplyLeading: false,
                title: MyText(
                  text: "requestforcreator",
                  color: white,
                  fontsizeNormal: Dimens.textBig,
                  fontwaight: FontWeight.bold,
                ),
                leading: GestureDetector(
                    onTap: () {
                      step == 1
                          ? Navigator.pop(context)
                          : setState(() {
                              step--;
                            });
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: white,
                    )),
                actions: [
                  step == 4
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              name2Controller.clear();
                              bankNameController.clear();
                              accNoController.clear();
                              ifscCodeController.clear();
                            });
                            callApi();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 7.5, horizontal: 14),
                            margin: const EdgeInsets.only(right: 15),
                            decoration: BoxDecoration(
                              color: buttonDisable,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: MyText(
                              text: 'skip',
                              fontsizeNormal: Dimens.textSmall,
                              color: white,
                              fontwaight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const SizedBox()
                ],
              ),
        bottomNavigationBar: step == 1
            ? bottomOne()
            : step == 2
                ? bottomTwo()
                : step == 3
                    ? bottomThree()
                    : bottomFour(),
        body: isLoad
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Utils().pageBg(
                context,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: 17.0,
                        left: kIsWeb
                            ? MediaQuery.of(context).size.width * 0.046
                            : 15,
                        right: kIsWeb
                            ? MediaQuery.of(context).size.width * 0.046
                            : 15),
                    child: Column(
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                          tween: Tween<double>(
                            begin: 0,
                            end: step == 1
                                ? 0
                                : step == 2
                                    ? 0.25
                                    : step == 3
                                        ? 0.5
                                        : 0.75,
                          ),
                          builder: (context, value, _) {
                            return Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              margin:
                                  const EdgeInsets.only(top: 25, bottom: 30),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Stack(
                                children: [
                                  // Background
                                  Container(
                                    height: 7.5,
                                    color: Colors.grey.shade800,
                                  ),
                                  // Progress with gradient
                                  FractionallySizedBox(
                                    widthFactor: value,
                                    child: Container(
                                      height: 7.5,
                                      decoration: BoxDecoration(
                                        gradient: Constant.gradientColor,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        step == 4
                            ? RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Payment Details ',
                                      style: TextStyle(
                                        color: white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '(Optional)',
                                      style: TextStyle(
                                        color: white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : MyText(
                                text: step == 1
                                    ? "creatoraccdetails"
                                    : step == 2
                                        ? "kycverify"
                                        : 'facialverify',
                                color: white,
                                fontsizeNormal: 22,
                                fontwaight: FontWeight.bold,
                              ),
                        const SizedBox(
                          height: 3,
                        ),
                        MyText(
                          text: step == 1
                              ? "enterdetailstosetupaccount"
                              : step == 2
                                  ? "verifyidentifyforpayouts"
                                  : step == 3
                                      ? 'selfieforfacialverify'
                                      : 'addpaymentaccounttoreceive',
                          color: white,
                          fontsizeNormal: 13.5,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        step == 1
                            ? stepOne()
                            : step == 2
                                ? stepTwo()
                                : step == 3
                                    ? stepThree()
                                    : stepFour(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
