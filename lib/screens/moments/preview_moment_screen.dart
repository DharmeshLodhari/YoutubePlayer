import 'dart:io';

import 'package:Slydo/screens/moments/moments_screen.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:video_player/video_player.dart';

import '../../locale/app_localization.dart';
import '../../utils/util.dart';
import '../../widget/LoadingIndicator.dart';
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
  bool isPublic = false;
  late String fileExtension;
  List<String> userTags = [];
  // Thumbnail that would be generated from the video the user captured.
  String? generatedThumbnail;
  VideoPlayerController? videoPlayerController;
  final TextEditingController momentTextCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fileExtension = widget.filePath.split('.').last;
    /*If the media to be previewed is a video, generate a thumbnail from it (the video)*/
    if (videoExtensions.contains(fileExtension)) {
      generateThumbNailFromVideo(videoPath: widget.filePath).then((thumbnail) {
        if (thumbnail != null) {
          generatedThumbnail = thumbnail;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: mediaRenderer(fileType: fileExtension),
                ),
                SizedBox(height: 10),
                CustomizedTextFormField(
                  controller: momentTextCtrl,
                  hintText: 'Enter caption...',
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Make Moment Public'),
                    Switch(
                      value: isPublic,
                      onChanged: (value) {
                        setState(() {
                          isPublic = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'If you make the post public, it will be available to everyone under the Slydo network',
                  style: TextStyle(
                    color: blackFont.withOpacity(0.5),
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
          child: Image.file(File(widget.filePath)));
    }
    if (videoExtensions.contains(fileType)) {
      setUpVideoPlayer();
      return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: VideoPlayer(videoPlayerController!));
    }
    return Container();
  }

  setUpVideoPlayer() async {
    videoPlayerController = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) => videoPlayerController!.play())
      ..setLooping(true);
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
        text: momentTextCtrl.text,
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
    videoPlayerController?.dispose();
    super.dispose();
  }
}
