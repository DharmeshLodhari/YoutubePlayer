import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/locator.dart';
import 'package:Slydo/screens/messaging/chat/utils.dart';
import 'package:Slydo/screens/moments/models/attachment_item_model.dart';
import 'package:Slydo/screens/moments/models/create_moment_model.dart';
import 'package:Slydo/screens/moments/screens/pick_attachment_screen.dart';
import 'package:Slydo/screens/moments/screens/select_video_cover_page.dart';
import 'package:Slydo/screens/moments/widgets/corner_radius_image.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/utils/video_player_controller/chewie_player.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../moments_auth.dart';

class PreviewMomentScreen extends StatefulWidget {
  final String filePath;
  final dynamic arguments;

  const PreviewMomentScreen(
      {super.key, required this.filePath, this.arguments});

  @override
  State<PreviewMomentScreen> createState() => _PreviewMomentScreenState();
}

class _PreviewMomentScreenState extends State<PreviewMomentScreen> {
  late UserBloc userBloc;
  bool isText = false;
  bool isTapped = false;
  bool isPublic = true;
  bool enableLikes = true;
  bool enablePayMe = false;
  bool enableCommenting = true;
  bool isPermanent = true;
  List<String> userTags = [];
  String? pickedAttachmentType;
  late String fileType;
  List<AttachmentItemModel>? itemAttachmentList;
  String? attachmentItemName;
  bool showUrlTextField = false;
  bool attachmentItemLoading = false;
  List<String> attachmentList = ['Blog', 'Product', 'Service', 'Url', 'None'];
  List<String> attachmentItemList = [];
  String? selectedImageThumb;

  // Thumbnail that would be generated from the video the user captured.
  String? generatedVideoThumbnail;
  VideoPlayerController? videoPlayerController;
  final TextEditingController payMeCtrl = TextEditingController(text: 'Pay me');
  final TextEditingController urlTextCtrl = TextEditingController();
  final TextEditingController titleOfLinkCtrl = TextEditingController();
  final TextEditingController pickedAttachmentTFCtrl = TextEditingController();

  String momentTitle = '';
  bool isVideoLoading = false;
  Map<String, String>? attachmentMap;
  ChewieController? _chewieController;
  Color pickedColor = navyBlue;
  AttachmentItemModel? attachmentItemModel;
  late FocusNode focusNode;
  String payMeLabel = 'Pay Me';

  bool isMore = false;
  bool isOnMore = false;

  void changeColor(Color color) {
    pickedColor = color;
    // debugPrint('PICKED COLOR ::: $pickedColor');
  }

  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    if (Provider.of<UserBloc>(context, listen: false).user.type == 'User') {
      attachmentList = ['Blog', 'Url', 'None'];
    } else {
      attachmentList = ['Blog', 'Product', 'Service', 'Url', 'None'];
    }
    payMeCtrl.addListener(() {
      setState(() {
        payMeLabel = payMeCtrl.text;
      });
    });
    focusNode = FocusNode();
    super.initState();

    final String? fType = getFileTypeByPath(path: widget.filePath);
    if (fType == null) return;
    fileType = fType;
    /*If the media to be previewed is a video, generate a thumbnail from it (the video)*/
    if (fileType == "video") {
      setUpVideoPlayer();
      generateThumbNailFromVideo(videoPath: widget.filePath).then((thumbnail) {
        if (thumbnail != null) {
          generatedVideoThumbnail = thumbnail;
          // debugPrint('file path gen -> $generatedVideoThumbnail');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return await getExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: appBar() as PreferredSizeWidget?,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            // fit: StackFit.expand,
            children: [
              mediaRenderer(),
              Container(
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Align(
                    //   alignment: Alignment.center,
                    //   child: Container(
                    //     width: 80,
                    //     height: 8,
                    //     decoration: BoxDecoration(
                    //       color: greyBorderColor,
                    //       borderRadius: BorderRadius.circular(50),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 15),
                    TextFormField(
                      maxLength: 255,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hoverColor: white,
                        hintText: 'Enter caption...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: greyBorderColor,
                            width: 1.0,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: greyBorderColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: navyBlue,
                            width: 1.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: greyBorderColor,
                            width: 1.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: greyBorderColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        momentTitle = value;
                        if (value.isNotEmpty) {
                          isText = true;
                        } else {
                          isText = false;
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Visibility(
                            visible: !isMore,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isMore = !isMore;
                                  isOnMore = !isOnMore;
                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: greyBackground,
                                    ),
                                    child: SvgPicture.asset(
                                      "yarn/world".toSVG(),
                                      height: 10,
                                      width: 10,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: greyBackground,
                                    ),
                                    child: SvgPicture.asset(
                                      "yarn/dark_comment".toSVG(),
                                      height: 10,
                                      width: 10,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Container(
                                      padding: const EdgeInsets.all(10.0),
                                      // decoration: BoxDecoration(

                                      // ),
                                      child: SvgPicture.asset(
                                        "yarn/thumbsup".toSVG(),
                                        height: 10,
                                        width: 10,
                                      )),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: greyBackground,
                                    ),
                                    child: SvgPicture.asset(
                                      "yarn/infinity".toSVG(),
                                      height: 6,
                                      width: 6,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: greyBackground,
                                    ),
                                    child: SvgPicture.asset(
                                      "yarn/black_logo".toSVG(),
                                      height: 10,
                                      width: 10,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isMore = !isMore;
                              isOnMore = !isOnMore;
                            });
                          },
                          child: Row(
                            children: [
                              Text(
                                'More option',
                                style: TextStyle(
                                    color: darkGreyYarn,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Icon(
                                isMore
                                    ? Icons.keyboard_arrow_down_sharp
                                    : Icons.keyboard_arrow_up_sharp,
                                color: darkGreyYarn,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: isOnMore,
                      child: Column(
                        children: [
                          previewMomentSwitchOptions(
                            icon: 'yarn/world',
                            title: 'Public',
                            description:
                                'If you make this moment public, it will be available to everyone under slydo network',
                            switchBtn: Switch(
                              value: isPublic,
                              onChanged: (value) {
                                setState(() {
                                  isPublic = !isPublic;
                                  // debugPrint(value.toString());
                                });
                              },
                              thumbIcon:
                                  MaterialStateProperty.all(const Icon(null)),
                              activeTrackColor: navyBlue,
                              activeColor: Colors.white,
                              inactiveTrackColor: darkGreyYarn,
                              inactiveThumbColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),
                          previewMomentSwitchOptions(
                            title: 'Enable likes',
                            icon: 'yarn/dark_comment',
                            description:
                                'Enable this to allow others like your post',
                            switchBtn: Switch(
                              value: enableLikes,
                              onChanged: (value) {
                                setState(() {
                                  enableLikes = !enableLikes;
                                });
                              },
                              thumbIcon:
                                  MaterialStateProperty.all(const Icon(null)),
                              activeTrackColor: navyBlue,
                              activeColor: Colors.white,
                              inactiveTrackColor: darkGreyYarn,
                              inactiveThumbColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),
                          previewMomentSwitchOptions(
                            icon: 'yarn/thumbsup',
                            title: 'Enable Comments',
                            description:
                                'Enable this to allow others comment on your moment',
                            switchBtn: Switch(
                              value: enableCommenting,
                              onChanged: (value) {
                                setState(() {
                                  enableCommenting = !enableCommenting;
                                });
                              },
                              thumbIcon:
                                  MaterialStateProperty.all(const Icon(null)),
                              activeTrackColor: navyBlue,
                              activeColor: Colors.white,
                              inactiveTrackColor: darkGreyYarn,
                              inactiveThumbColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),
                          previewMomentSwitchOptions(
                            title: 'Make Permanent',
                            icon: 'yarn/infinity',
                            description:
                                'If you make a moment Permanent it will stay forever till you delete it',
                            switchBtn: Switch(
                              value: isPermanent,
                              onChanged: (value) {
                                setState(() {
                                  isPermanent = !isPermanent;
                                });
                              },
                              thumbIcon:
                                  MaterialStateProperty.all(const Icon(null)),
                              activeTrackColor: navyBlue,
                              activeColor: Colors.white,
                              inactiveTrackColor: darkGreyYarn,
                              inactiveThumbColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (appConfigurationModel?.enablePayment == true)
                            previewMomentSwitchOptions(
                              icon: 'yarn/black_logo',
                              title: 'Enable Payment',
                              description:
                                  'Enable this to allow other users to support your work by making a donation.',
                              switchBtn: Switch(
                                value: enablePayMe,
                                onChanged: (value) {
                                  setState(() {
                                    enablePayMe = value;
                                  });
                                },
                                thumbIcon:
                                    MaterialStateProperty.all(const Icon(null)),
                                activeTrackColor: navyBlue,
                                activeColor: Colors.white,
                                inactiveTrackColor: darkGreyYarn,
                                inactiveThumbColor: Colors.white,
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          const SizedBox(height: 20),
                          dropDownPickItemWidget(
                            label: 'Pick attachment',
                            selectedItem: pickedAttachmentType,
                            onTap: () => pickAttachmentWidget(),
                          ),
                          Visibility(
                            visible: attachmentItemModel != null,
                            child: CustomizedTextFormField(
                              isReadOnly: true,
                              controller: pickedAttachmentTFCtrl,
                            ),
                          ),
                          Visibility(
                            visible: showUrlTextField,
                            child: Column(
                              children: [
                                CustomizedTextFormField(
                                  hintText: 'Enter Url',
                                  controller: urlTextCtrl,
                                ),
                                CustomizedTextFormField(
                                  hintText: 'Enter a title for your url',
                                  controller: titleOfLinkCtrl,
                                  maxLength: 15,
                                ),
                              ],
                            ),
                          ),
                          Focus(
                            focusNode: focusNode,
                            child: Visibility(
                              visible: enablePayMe,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        const Text('Button Preview'),
                                        const SizedBox(height: 6),
                                        payMeBtn(),
                                      ],
                                    ),
                                  ),
                                  CustomizedTextFormField(
                                    controller: payMeCtrl,
                                    maxLength: 15,
                                    hintText: 'Enter pay me label...',
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Pick button color',
                                      textAlign: TextAlign.left),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Pick a color to display as your payment button color',
                                    style: TextStyle(
                                      color: blackFont.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  InkWell(
                                    onTap: () async {
                                      //This is to dismiss the keyboard first, wait for 200 milliseconds
                                      // for the keyboard to be fully dismissed before showing the dialog.
                                      //To avoid overflow errors on the dialog.
                                      focusNode.unfocus();
                                      await Future.delayed(
                                          const Duration(milliseconds: 200));
                                      final bool? pickColor =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: const Text('Pick your color'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ColorPicker(
                                                onColorChanged: changeColor,
                                                pickerColor: pickedColor,
                                              ),
                                              CurvedButton(
                                                text: 'Select',
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                      if (pickColor != null &&
                                          pickColor == true) {
                                        // Calling setState here so that ONLY if they click the select button
                                        // in the dialog should the color of the container change.

                                        setState(() {});
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/color_picker_image.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: Text(
                                              '#${pickedColor.value.toRadixString(16)}'
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: blackFont,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),

                          ///ToDo TextFieldTags check
                          // TextFieldTags(
                          //   initialTags: userTags,
                          //   tagsStyler: textFieldTagStyler,
                          //   validator: (value) {
                          //     return null;
                          //   },
                          //   textFieldStyler: textFieldStyler,
                          //   onTag: (tag) {
                          //     setState(() {
                          //       userTags.add(tag);
                          //       userTags = userTags.toSet().toList();
                          //     });
                          //     userTags.removeWhere((tag) => tag.isEmpty);
                          //   },
                          //   onDelete: (tag) {
                          //     setState(() {
                          //       userTags.remove(tag);
                          //     });
                          //     userTags.removeWhere((tag) => tag.isEmpty);
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget payMeBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
          color: HexColor('#${pickedColor.value.toRadixString(16)}'),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/slydo_icon_white.png',
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 4),
          Text(
            payMeLabel,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

  Widget previewMomentSwitchOptions({
    required String title,
    required String icon,
    required String description,
    required Switch switchBtn,
  }) {
    return Container(
      // height: 300,
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: icon == 'yarn/infinity'
                ? const EdgeInsets.fromLTRB(14, 18, 12, 18)
                : const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lightGrey,
            ),
            child: SvgPicture.asset(
              icon.toSVG(),
              height: icon == 'yarn/infinity' ? 14 : 20,
              width: icon == 'yarn/infinity' ? 14 : 20,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: SizedBox(
              // width: 200,
              // height: 65.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: blackFont,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                        color: blackFont.withOpacity(0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 30,
            child: FittedBox(fit: BoxFit.fill, child: switchBtn),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () async {
          await getExitDialog(context);
        },
      ),
      title: Text(
        AppLocalization.of(context)!.previewMoment,
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (isText == false)
          const SizedBox.shrink()
        else
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CurvedButton(
              width: 100,
              borderRadius: 20,
              text: 'Submit',
              fontSize: 14,
              onPressed: () async {
                if (enablePayMe && payMeCtrl.text.isEmpty) {
                  showToast(message: 'Payment label cannot be empty');
                  return;
                }

                if (pickedAttachmentType == 'Url' &&
                    (urlTextCtrl.text.isEmpty ||
                        (!await canLaunchUrl(Uri.parse(urlTextCtrl.text))))) {
                  showToast(message: 'Please enter a valid url');
                  return;
                }
                showDialogBox(
                  context: context,
                  actionOneTextColor: blackFont,
                  actionTwoBgColor: navyBlue,
                  actionTwoTextColor: Colors.white,
                  actionOneBgColor: greyBorderColor,
                  title: AppLocalization.of(context)!.post,
                  actionTwoText: AppLocalization.of(context)!.post,
                  actionOneText: AppLocalization.of(context)!.notNow,
                  description:
                      'Are you sure you want to post\nyour moment now?',
                  roundedBackgroundIcon: RoundedBackgroundIcon(
                    enableMargin: false,
                    width: 90,
                    height: 90,
                    image: Image.asset(
                      'assets/images/accept_dialog_icon.png',
                      color: navyBlue,
                    ),
                  ),
                  rightButtonOnPressed: () {
                    postMoment();
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget mediaRenderer() {
    if (fileType == "image") {
      return SizedBox(
        width: 60,
        height: 250,
        child: Center(
          child: CornerRadiusImage(
            imagePath: widget.filePath,
            cornerRadius: 20.0,
          ),
        ),
      );
    }
    if (fileType == "video") {
      if (isVideoLoading) {
        return Center(child: CircularLoadingIndicator());
      }
      // return ClipRRect(
      //   borderRadius: BorderRadius.circular(20),
      //   child: Padding(
      //     padding: const EdgeInsets.fromLTRB(100, 10, 100, 10),
      return SizedBox(
          width: 60,
          height: 250,
          child: Center(
            child: CornerRadiusVideo(
              widget: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isTapped = !isTapped;
                          if (isTapped == true) {
                            videoPlayerController?.play();
                          } else {
                            videoPlayerController?.pause();
                          }
                        });
                      },
                      child: Stack(children: [
                        VideoPlayer(videoPlayerController!),
                        if (selectedImageThumb != null && isTapped == false)
                          Center(
                            child: Image(
                              width: double.infinity,
                              height: 250,
                              image: FileImage(
                                File(selectedImageThumb ?? ""),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (isTapped == false)
                          Align(
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              "yarn/cam_vec".toSVG(),
                              height: 50,
                              width: 50,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                      ]),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final data = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectVideoCoverPage(
                            videoPath: widget.filePath,
                          ),
                        ),
                      );

                      if (data != null) {
                        selectedImageThumb = data;
                        if (mounted) setState(() {});
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      color: greyTagColor,
                      padding: const EdgeInsets.all(7.0),
                      child: Center(
                        child: Text(
                          AppLocalization.of(context)!.selectCover,
                          style: TextStyle(
                            color: blackFont,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
      //   ),
      // );
    }

    return Container();
  }

  void setUpVideoPlayer() async {
    isVideoLoading = true;
    if (mounted) setState(() {});

    // videoPlayerController = VideoPlayerController.file(File(widget.filePath))
    //   ..initialize().then((_) => videoPlayerController?.play())
    //   ..setLooping(false);

    videoPlayerController = VideoPlayerController.file(
      File(widget.filePath),
    );

    await videoPlayerController?.initialize();
    await videoPlayerController?.setLooping(false);

    await videoPlayerController?.pause();

    // debugPrint("path=> ${File(widget.filePath)}");
    // videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    // await videoPlayerController!.initialize();

    // _chewieController = ChewieController(
    //   videoPlayerController: videoPlayerController!,
    //   aspectRatio: videoPlayerController?.value.aspectRatio,
    //   allowedScreenSleep: false,
    //   autoPlay: false,
    //   allowFullScreen: false,
    //   systemOverlaysAfterFullScreen: SystemUiOverlay.values,
    //   // showControls: false,
    //   materialProgressColors: ChewieProgressColors(
    //     playedColor: navyBlue,
    //     handleColor: Colors.white,
    //     backgroundColor: dividerColor,
    //     bufferedColor: Colors.white30,
    //   ),
    //   autoInitialize: true,
    // );

    isVideoLoading = false;
    if (mounted) setState(() {});
  }

  void postMoment() {
    final List<String> newUserTags =
        []; // For replacing the # in a tag with an empty string.

    for (var tag in userTags) {
      if (tag.startsWith('#')) {
        newUserTags.add(tag.replaceAll("#", ''));
      } else {
        newUserTags.add(tag);
      }
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogLoadingContext) => LoadingIndicator());

    MomentsAuthService()
        .createMoment(
      createMomentModel: CreateMomentModel(
        enableLike: enableLikes,
        enableCommenting: enableCommenting,
        isPermanent: isPermanent,
        enablePayMe: enablePayMe,
        isPublic: isPublic,
        userTags: newUserTags,
        // mediaPoster: generatedVideoThumbnail,
        mediaPoster: selectedImageThumb ?? generatedVideoThumbnail,
        filePath: widget.filePath,
        text: momentTitle,
        url: urlTextCtrl.text,
        payMeLabel: enablePayMe
            ? payMeCtrl.text.isEmpty
                ? 'Pay Me'
                : payMeCtrl.text
            : null,
        payMeButtonColor:
            enablePayMe ? pickedColor.value.toRadixString(16) : null,
        attachmentMap: getAttachmentMap(),
        duration: fileType == 'video'
            ? videoPlayerController?.value.duration.inMilliseconds.toString()
            : '',
      ),
      channelUsername:
          widget.arguments == "" ? "" : widget.arguments['channel'],
    )
        .then((momentPosted) {
      if (momentPosted == true) {
        Navigator.pop(context); // Dismiss the loader
        Navigator.pop(context); // Dismiss preview moment screen
        Navigator.pop(context,
            true); // Dis// miss create moment screen and reload moment screen page.
        showToast(message: 'Moment created');
      }
    }).catchError((e) {
      Navigator.pop(context);
      showToast(message: 'Error -> something went wrong');
    });
  }

  Map<String, String>? getAttachmentMap() {
    if (pickedAttachmentType == 'Url' && urlTextCtrl.text.isNotEmpty) {
      return titleOfLinkCtrl.text.isNotEmpty
          ? {'url': '${urlTextCtrl.text}-${titleOfLinkCtrl.text}'}
          : {'url': '${urlTextCtrl.text}-Link'};
    }
    if (pickedAttachmentType == 'Product' &&
        pickedAttachmentTFCtrl.text.isNotEmpty) {
      return {'product': attachmentItemModel!.id};
    }
    if (pickedAttachmentType == 'Service' &&
        pickedAttachmentTFCtrl.text.isNotEmpty) {
      return {'service': attachmentItemModel!.id};
    }
    if (pickedAttachmentType == 'Blog' &&
        pickedAttachmentTFCtrl.text.isNotEmpty) {
      return {'blog': attachmentItemModel!.id};
    }

    return null;
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> pickAttachmentWidget() async {
    final String? pickedAttachmentOption = await showPickItemDialog<String>(
      context: context,
      items: attachmentList,
      selectedItem: pickedAttachmentType,
    );
    if (pickedAttachmentOption != null) {
      showUrlTextField = false;
      pickedAttachmentType = pickedAttachmentOption;
      if (mounted) setState(() {});

      switch (pickedAttachmentOption) {
        case 'Blog':
          final attachmentItemModelResult = await NavigationUtil.push(context,
              screen: const PickAttachmentScreen(
                  attachmentType: AttachmentType.Blog));
          if (attachmentItemModelResult != null) {
            if (mounted) {
              setState(() {
                attachmentItemModel = attachmentItemModelResult;
                pickedAttachmentTFCtrl.text = attachmentItemModel!.title;
              });
            }
          }
          break;
        case 'Product':
          final attachmentItemModelResult = await NavigationUtil.push(context,
              screen: const PickAttachmentScreen(
                  attachmentType: AttachmentType.Product));
          if (attachmentItemModelResult != null) {
            if (mounted) {
              setState(() {
                attachmentItemModel = attachmentItemModelResult;
                pickedAttachmentTFCtrl.text = attachmentItemModel!.title;
              });
            }
          }

          break;
        case 'Service':
          final attachmentItemModelResult = await NavigationUtil.push(context,
              screen: const PickAttachmentScreen(
                  attachmentType: AttachmentType.Service));
          if (attachmentItemModelResult != null) {
            if (mounted) {
              setState(() {
                attachmentItemModel = attachmentItemModelResult;
                pickedAttachmentTFCtrl.text = attachmentItemModel!.title;
              });
            }
          }

          break;
        case 'Url':
          showUrlTextField = true;
          if (mounted) setState(() {});
          break;
        case 'None':
          break;
      }
    }
  }

  void pickAttachmentItemWidget() async {
    final AttachmentItemModel? pickedItemAttachment =
        await showDialog<AttachmentItemModel>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width - 40,
          child: Card(
            elevation: 2,
            shadowColor: Colors.transparent,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SingleChildScrollView(
                child: Column(
                  children: itemAttachmentList!.map<Widget>((attachmentItem) {
                    if (attachmentItem.id == attachmentItem.id) {
                      return Container(
                        color: selectedListItemBackgroundBlue,
                        child: ListTile(
                          dense: true,
                          title: Text(
                            attachmentItem.title,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                                color: navyBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          trailing: Icon(
                            SlydoAppIcon.checked,
                            color: navyBlue,
                            size: 12,
                          ),
                          onTap: () {
                            Navigator.pop(context, attachmentItem);
                          },
                        ),
                      );
                    }
                    return ListTile(
                      title: Text(
                        attachmentItem.title,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            color: blackFont,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      dense: true,
                      onTap: () {
                        Navigator.pop(context, attachmentItem);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (pickedItemAttachment != null) {
      attachmentItemName = pickedItemAttachment.title;
      if (mounted) setState(() {});
    }
  }

  dynamic getExitDialog(BuildContext context) async {
    await showExitDialogBackButton(
      context: context,
      leftButtonOnPressed: () {
        Navigator.pop(context);
      },
      rightButtonOnPressed: () async {
        if (enablePayMe && payMeCtrl.text.isEmpty) {
          showToast(message: 'Payment label cannot be empty');
          return;
        }

        if (pickedAttachmentType == 'Url' &&
            (urlTextCtrl.text.isEmpty ||
                (!await canLaunchUrl(Uri.parse(urlTextCtrl.text))))) {
          showToast(message: 'Please enter a valid url');
          return;
        }
        showDialogBox(
          context: context,
          actionOneTextColor: blackFont,
          actionTwoBgColor: navyBlue,
          actionTwoTextColor: Colors.white,
          actionOneBgColor: greyBorderColor,
          title: AppLocalization.of(context)!.post,
          actionTwoText: AppLocalization.of(context)!.post,
          actionOneText: AppLocalization.of(context)!.notNow,
          description: 'Are you sure you want to post\nyour moment now?',
          roundedBackgroundIcon: RoundedBackgroundIcon(
            enableMargin: false,
            width: 90,
            height: 90,
            image: Image.asset(
              'assets/images/accept_dialog_icon.png',
              color: navyBlue,
            ),
          ),
          rightButtonOnPressed: () {
            postMoment();
          },
        );
      },
    );
    //   if (result != null && result) {
    //     if (userBloc.user != null) {
    //       userBloc.user == null;
    //     }
    //     Navigator.of(context).pop();
    //   }
    //   return false;
    // } else {
    //   Navigator.of(context).pop();
    //   return true;
    // }
  }
}

enum AttachmentType { Blog, Product, Service }
