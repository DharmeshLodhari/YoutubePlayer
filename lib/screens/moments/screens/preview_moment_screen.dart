import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/moments/screens/pick_attachment_screen.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../locale/app_localization.dart';
import '../../../locator.dart';
import '../../../services/app_config_bloc.dart';
import '../../../utils/slydo_app_icon_icons.dart';
import '../../../utils/util.dart';
import '../../../utils/video_player_controller/chewie_player.dart';
import '../../../utils/video_player_controller/chewie_progress_colors.dart';
import '../../../widget/LoadingIndicator.dart';
import '../../../widget/dialog.dart';
import '../../../widget/rounded_background_icon.dart';
import '../models/attachment_item_model.dart';
import '../models/create_moment_model.dart';
import 'moments_service.dart';

class PreviewMomentScreen extends StatefulWidget {
  final String filePath;

  const PreviewMomentScreen({Key? key, required this.filePath})
      : super(key: key);

  @override
  State<PreviewMomentScreen> createState() => _PreviewMomentScreenState();
}

class _PreviewMomentScreenState extends State<PreviewMomentScreen> {
  late UserBloc userBloc;
  bool isPublic = false;
  bool enableLikes = false;
  bool enablePayMe = false;
  bool enableCommenting = false;
  late String fileExtension;
  List<String> userTags = [];
  String? pickedAttachmentType;
  List<AttachmentItemModel>? itemAttachmentList;
  String? attachmentItemName;
  bool showUrlTextField = false;
  bool attachmentItemLoading = false;
  List<String> attachmentList = ['Blog', 'Product', 'Service', 'Url', 'None'];
  List<String> attachmentItemList = [];

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
  void changeColor(Color color) {
    pickedColor = color;
    debugPrint('PICKED COLOR ::: $pickedColor');
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
    fileExtension = widget.filePath.split('.').last;
    /*If the media to be previewed is a video, generate a thumbnail from it (the video)*/
    if (videoExtensions.contains(fileExtension)) {
      setUpVideoPlayer();
      generateThumbNailFromVideo(videoPath: widget.filePath).then((thumbnail) {
        if (thumbnail != null) {
          generatedVideoThumbnail = thumbnail;
          debugPrint('file path gen -> ${generatedVideoThumbnail}');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      appBar: appBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          mediaRenderer(fileType: fileExtension),
          DraggableScrollableSheet(
              minChildSize: 0.2,
              maxChildSize: 1,
              initialChildSize: 0.2,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 80,
                              height: 8,
                              decoration: BoxDecoration(
                                color: greyBorderColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            maxLength: 255,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Enter caption...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
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
                            },
                          ),
                          previewMomentSwitchOptions(
                            title: 'Make Moment Public',
                            description:
                                'If you make the post public, it will be available to everyone under the Slydo network',
                            switchBtn: Switch(
                              value: isPublic,
                              onChanged: (value) {
                                setState(() {
                                  isPublic = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 30),
                          previewMomentSwitchOptions(
                            title: 'Enable likes',
                            description:
                                'Enable this to allow others like your post',
                            switchBtn: Switch(
                              value: enableLikes,
                              onChanged: (value) {
                                setState(() {
                                  enableLikes = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 30),
                          previewMomentSwitchOptions(
                            title: 'Enable Commenting',
                            description:
                                'Enable this to allow others comment on your post',
                            switchBtn: Switch(
                              value: enableCommenting,
                              onChanged: (value) {
                                setState(() {
                                  enableCommenting = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 30),
                          TextFieldTags(
                            initialTags: userTags,
                            tagsStyler: textFieldTagStyler,
                            validator: (value) {
                              return null;
                            },
                            textFieldStyler: textFieldStyler,
                            onTag: (tag) {
                              setState(() {
                                userTags.add(tag);
                                userTags = userTags.toSet().toList();
                              });
                              userTags.removeWhere((tag) => tag.isEmpty);
                            },
                            onDelete: (tag) {
                              setState(() {
                                userTags.remove(tag);
                              });
                              userTags.removeWhere((tag) => tag.isEmpty);
                            },
                          ),
                          appConfigurationModel?.enablePayment == true
                              ? previewMomentSwitchOptions(
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
                                  ),
                                )
                              : SizedBox.shrink(),
                          SizedBox(height: 20),
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
                                  SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Text('Button Preview'),
                                        SizedBox(height: 6),
                                        payMeBtn(),
                                      ],
                                    ),
                                  ),
                                  CustomizedTextFormField(
                                    controller: payMeCtrl,
                                    maxLength: 15,
                                    hintText: 'Enter pay me label...',
                                  ),
                                  SizedBox(height: 8),
                                  Text('Pick button color',
                                      textAlign: TextAlign.left),
                                  SizedBox(height: 2),
                                  Text(
                                    'Pick a color to display as your payment button color',
                                    style: TextStyle(
                                      color: blackFont.withOpacity(0.5),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  InkWell(
                                    onTap: () async {
                                      //This is to dismiss the keyboard first, wait for 200 milliseconds
                                      // for the keyboard to be fully dismissed before showing the dialog.
                                      //To avoid overflow errors on the dialog.
                                      focusNode.unfocus();
                                      await Future.delayed(
                                          Duration(milliseconds: 200));
                                      bool? _pickedColor =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Pick your color'),
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
                                      if (_pickedColor != null &&
                                          _pickedColor == true) {
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
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
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
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 80),
                          CurvedButton(
                            text: 'Submit',
                            onPressed: () async {
                              if (enablePayMe && payMeCtrl.text.isEmpty) {
                                showToast(
                                    message: 'Payment label cannot be empty');
                                return;
                              }

                              if (pickedAttachmentType == 'Url' &&
                                  (urlTextCtrl.text.isEmpty ||
                                      (!await canLaunchUrl(
                                          Uri.parse(urlTextCtrl.text))))) {
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
                                actionTwoText:
                                    AppLocalization.of(context)!.post,
                                actionOneText:
                                    AppLocalization.of(context)!.notNow,
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
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
    return Scaffold(
      appBar: appBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  child: mediaRenderer(fileType: fileExtension),
                ),
                SizedBox(height: 20),
                TextFormField(
                  maxLength: 255,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Enter caption...',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                  },
                ),
                previewMomentSwitchOptions(
                  title: 'Make Moment Public',
                  description:
                      'If you make the post public, it will be available to everyone under the Slydo network',
                  switchBtn: Switch(
                    value: isPublic,
                    onChanged: (value) {
                      setState(() {
                        isPublic = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 30),

                previewMomentSwitchOptions(
                  title: 'Enable likes',
                  description: 'Enable this to allow others like your post',
                  switchBtn: Switch(
                    value: enableLikes,
                    onChanged: (value) {
                      setState(() {
                        enableLikes = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 30),

                previewMomentSwitchOptions(
                  title: 'Enable Commenting',
                  description:
                      'Enable this to allow others comment on your post',
                  switchBtn: Switch(
                    value: enableCommenting,
                    onChanged: (value) {
                      setState(() {
                        enableCommenting = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 30),

                TextFieldTags(
                  initialTags: userTags,
                  tagsStyler: textFieldTagStyler,
                  validator: (value) {
                    return null;
                  },
                  textFieldStyler: textFieldStyler,
                  onTag: (tag) {
                    setState(() {
                      userTags.add(tag);
                      userTags = userTags.toSet().toList();
                    });
                    userTags.removeWhere((tag) => tag.isEmpty);
                  },
                  onDelete: (tag) {
                    setState(() {
                      userTags.remove(tag);
                    });
                    userTags.removeWhere((tag) => tag.isEmpty);
                  },
                ),

                previewMomentSwitchOptions(
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
                  ),
                ),
                // SizedBox(height: 15),
                // dropDownPickItemWidget(
                //   label: 'Pick attachment',
                //   selectedItem: pickedAttachmentType,
                //   onTap: () => pickAttachmentWidget(),
                // ),

                attachmentItemLoading
                    ? Center(child: CircularLoadingIndicator())
                    : Visibility(
                        visible: attachmentItemList.isNotEmpty,
                        child: dropDownPickItemWidget(
                          label: 'Attachment Item',
                          selectedItem: attachmentItemName,
                          onTap: () => pickAttachmentItemWidget(),
                        ),
                      ),
                Visibility(
                  visible: showUrlTextField,
                  child: CustomizedTextFormField(
                    hintText: 'Enter Url',
                    controller: urlTextCtrl,
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
                        SizedBox(height: 12),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text('Button Preview'),
                              SizedBox(height: 6),
                              payMeBtn(),
                            ],
                          ),
                        ),
                        CustomizedTextFormField(
                          controller: payMeCtrl,
                          maxLength: 15,
                          hintText: 'Enter pay me label...',
                        ),
                        SizedBox(height: 8),
                        Text('Pick button color', textAlign: TextAlign.left),
                        SizedBox(height: 2),
                        Text(
                          'Pick a color to display as your payment button color',
                          style: TextStyle(
                            color: blackFont.withOpacity(0.5),
                          ),
                        ),
                        SizedBox(height: 20),
                        InkWell(
                          onTap: () async {
                            //This is to dismiss the keyboard first, wait for 200 milliseconds
                            // for the keyboard to be fully dismissed before showing the dialog.
                            //To avoid overflow errors on the dialog.
                            focusNode.unfocus();
                            await Future.delayed(Duration(milliseconds: 200));
                            bool? _pickedColor = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Pick your color'),
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
                            if (_pickedColor != null && _pickedColor == true) {
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
                              SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
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
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 80),
                CurvedButton(
                  text: 'Submit',
                  onPressed: () {
                    if (enablePayMe && payMeCtrl.text.isEmpty) {
                      showToast(message: 'Payment label cannot be empty');
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget payMeBtn() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
          SizedBox(width: 4),
          Text(
            payMeLabel,
            style: TextStyle(
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
    required String description,
    required Switch switchBtn,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title),
            SizedBox(height: 30, child: switchBtn),
          ],
        ),
        Text(
          description,
          style: TextStyle(
            color: blackFont.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
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
    );
  }

  Widget mediaRenderer({required String fileType}) {
    if (imageExtensions.contains(fileType)) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Image.file(
          File(widget.filePath),
          fit: BoxFit.cover,
          cacheHeight: (MediaQuery.of(context).size.height * 0.8).toInt(),
        ),
      );
    }
    if (videoExtensions.contains(fileType)) {
      if (isVideoLoading) {
        return Center(child: CircularLoadingIndicator());
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: VideoPlayer(videoPlayerController!),
      );
    }
    // Chewie(
    //   controller: _chewieController!,
    //   posterUrl: "",
    //   titleName: "",
    // )
    return Container();
  }

  setUpVideoPlayer() async {
    videoPlayerController = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) => videoPlayerController!.play())
      ..setLooping(false);

    isVideoLoading = true;
    if (mounted) setState(() {});
    // debugPrint("path=> ${File(widget.filePath)}");
    // videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    // await videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      aspectRatio: videoPlayerController!.value.aspectRatio,
      allowedScreenSleep: false,
      autoPlay: false,
      allowFullScreen: false,
      systemOverlaysAfterFullScreen: SystemUiOverlay.values,
      // showControls: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: navyBlue,
        handleColor: Colors.white,
        backgroundColor: dividerColor,
        bufferedColor: Colors.white30,
      ),
      autoInitialize: true,
    );

    isVideoLoading = false;
    if (mounted) setState(() {});
  }

  void postMoment() {
    List<String> newUserTags =
        []; // For replacing the # in a tag with an empty string.

    userTags.forEach((tag) {
      if (tag.startsWith('#')) {
        newUserTags.add(tag.replaceAll("#", ''));
      } else {
        newUserTags.add(tag);
      }
    });

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogLoadingContext) => LoadingIndicator());

    MomentsService()
        .createMoment(
      createMomentModel: CreateMomentModel(
        enableLike: enableLikes,
        enableCommenting: enableCommenting,
        enablePayMe: enablePayMe,
        isPublic: isPublic,
        userTags: newUserTags,
        mediaPoster: generatedVideoThumbnail,
        filePath: widget.filePath,
        text: momentTitle,
        url: urlTextCtrl.text,
        payMeLabel: enablePayMe
            ? payMeCtrl.text.isEmpty
                ? 'Pay Me'
                : payMeCtrl.text
            : null,
        payMeButtonColor:
            enablePayMe ? '${pickedColor.value.toRadixString(16)}' : null,
        attachmentMap: getAttachmentMap(),
      ),
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

  pickAttachmentWidget() async {
    String? pickedAttachmentOption = await showPickItemDialog<String>(
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
          var attachmentItemModelResult = await NavigationUtil.push(context,
              screen:
                  PickAttachmentScreen(attachmentType: AttachmentType.Blog));
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
          var attachmentItemModelResult = await NavigationUtil.push(context,
              screen:
                  PickAttachmentScreen(attachmentType: AttachmentType.Product));
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
          var attachmentItemModelResult = await NavigationUtil.push(context,
              screen:
                  PickAttachmentScreen(attachmentType: AttachmentType.Service));
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

  pickAttachmentItemWidget() async {
    AttachmentItemModel? pickedItemAttachment =
        await showDialog<AttachmentItemModel>(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Container(
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
}

enum AttachmentType { Blog, Product, Service }
