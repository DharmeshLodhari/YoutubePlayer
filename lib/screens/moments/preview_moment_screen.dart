import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:video_player/video_player.dart';

import '../../locale/app_localization.dart';
import '../../utils/slydo_app_icon_icons.dart';
import '../../utils/util.dart';
import '../../utils/video_player_controller/chewie_player.dart';
import '../../utils/video_player_controller/chewie_progress_colors.dart';
import '../../widget/LoadingIndicator.dart';
import '../../widget/dialog.dart';
import '../more_apps/shopping/shopping_auth.dart';
import 'models/create_moment_model.dart';
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
  bool enableLike = false;
  bool enableCommenting = false;
  late String fileExtension;
  List<String> userTags = [];
  String? pickedAttachmentType;
  List<AttachmentItemModel>? itemAttachmentList;
  String? attachmentItemName;
  bool showUrlTextField = false;
  bool attachmentItemLoading = false;
  List<String> attachmentList = ['Blog', 'Product', 'Service', 'Url'];
  List<String> attachmentItemList = [];

  // Thumbnail that would be generated from the video the user captured.
  String? generatedThumbnail;
  VideoPlayerController? videoPlayerController;
  // final TextEditingController momentTextCtrl = TextEditingController();
  final TextEditingController urlTextCtrl = TextEditingController();

  String? momentTitle;
  bool isVideoLoading = false;

  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    fileExtension = widget.filePath.split('.').last;
    /*If the media to be previewed is a video, generate a thumbnail from it (the video)*/
    if (videoExtensions.contains(fileExtension)) {
      setUpVideoPlayer();
      generateThumbNailFromVideo(videoPath: widget.filePath).then((thumbnail) {
        if (thumbnail != null) {
          generatedThumbnail = thumbnail;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('SET STATE CALLED');
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      appBar: appBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  width: 400,
                  child: mediaRenderer(fileType: fileExtension),
                ),
                SizedBox(height: 20),
                TextFormField(
                  maxLength: 99,
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
                SizedBox(height: 10),
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
                previewMomentSwitchOptions(
                  title: 'Enable likes',
                  description: 'Enable this to allow others like your post',
                  switchBtn: Switch(
                    value: enableLike,
                    onChanged: (value) {
                      setState(() {
                        enableLike = value;
                      });
                    },
                  ),
                ),
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
                // SizedBox(height: 15),
                // dropDownPickItemWidget(
                //   label: 'Pick attachment',
                //   selectedItem: pickedAttachmentType,
                //   onTap: () => pickAttachmentWidget(),
                // ),
                SizedBox(height: 8),
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
                SizedBox(height: 15),
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
                CurvedButton(
                  text: 'Submit',
                  onPressed: () {
                    postMoment();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget previewMomentSwitchOptions({
    required String title,
    required String description,
    required Switch switchBtn,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title),
              switchBtn,
            ],
          ),
          Text(
            description,
            style: TextStyle(
              color: blackFont.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  appBar() {
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
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(widget.filePath),
          fit: BoxFit.cover,
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
        builder: (dialogLoadingContext) => LoadingIndicator());

    MomentsService()
        .createMoment(
      createMomentModel: CreateMomentModel(
        isPublic: isPublic,
        userTags: newUserTags,
        mediaPoster: generatedThumbnail,
        filePath: widget.filePath,
        text: momentTitle!,
        url: urlTextCtrl.text,
      ),
    )
        .then((momentPosted) {
      if (momentPosted == true) {
        Navigator.pop(context); // Dismiss the loader
        Navigator.pop(context); // Dismiss preview moment screen
        Navigator.pop(context,
            true); // Dismiss create moment screen and reload moment screen page.
      }
    }).catchError((e) {
      Navigator.pop(context);
      debugPrint('SUBMIT MOMENT ERROR -> $e');
      showToast(message: 'Error -> $e');
    });
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
          getUserBlogPost();
          break;
        case 'Product':
          // getUsersProduct();
          break;
        case 'Service':
          // getUsersService();
          break;
        case 'Url':
          showUrlTextField = true;
          if (mounted) setState(() {});
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
                            attachmentItem.name,
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
                        attachmentItem.name,
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
      attachmentItemName = pickedItemAttachment.name;
      if (mounted) setState(() {});
    }
  }

  getUserBlogPost() async {
    if (mounted) {
      setState(() {
        attachmentItemLoading = true;
      });
    }
    Map<String, dynamic>? result =
        await UserPostAuth().listUserPosts(userName: userBloc.user.userName);
    if (mounted) {
      setState(() {
        attachmentItemLoading = true;
      });
    }
    debugPrint('RESULT ::: $result');
    if (result != null) {
      List resultList = result['results'] as List;
      itemAttachmentList =
          resultList.map((e) => AttachmentItemModel.fromJson(e)).toList();
    } else {
      if (mounted) {
        setState(() {
          attachmentItemLoading = false;
        });
      }
    }
  }

  getUsersProduct() async {
    if (mounted) {
      setState(() {
        attachmentItemLoading = true;
      });
    }
    Map<String, dynamic>? result = await ShoppingAuthService()
        .listOfProduct("", "", userName: userBloc.user.userName);
    if (mounted) {
      setState(() {
        attachmentItemLoading = true;
      });
    }
    debugPrint('RESULT ::: $result');
    if (result != null) {
      List resultList = result['results'] as List;
      itemAttachmentList =
          resultList.map((e) => AttachmentItemModel.fromJson(e)).toList();
    } else {
      if (mounted) {
        setState(() {
          attachmentItemLoading = false;
        });
      }
    }
  }

  getUsersService() async {
    if (mounted) {
      setState(() {
        attachmentItemLoading = true;
      });
    }
    Map<String, dynamic>? result = await ShoppingAuthService()
        .listServicesByProvider("", "", userName: userBloc.user.userName);
    if (mounted) {
      setState(() {
        attachmentItemLoading = true;
      });
    }
    debugPrint('RESULT ::: $result');
    if (result != null) {
      List resultList = result['results'] as List;
      itemAttachmentList =
          resultList.map((e) => AttachmentItemModel.fromJson(e)).toList();
    } else {
      if (mounted) {
        setState(() {
          attachmentItemLoading = false;
        });
      }
    }
  }
}

class AttachmentItemModel {
  int id;
  String name;

  AttachmentItemModel({required this.id, required this.name});

  factory AttachmentItemModel.fromJson(Map<String, dynamic> json) {
    return AttachmentItemModel(id: json['id'], name: json['name']);
  }
}
