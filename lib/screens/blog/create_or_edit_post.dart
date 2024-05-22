import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/blog/quill/custom_quill_embed.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutterQuill;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../locale/app_localization.dart';
import '../../utils/video_player_controller/chewie_player.dart';
import '../../utils/video_player_controller/chewie_progress_colors.dart';
import '../../widget/loading_indicator.dart';
import '../more_apps/user_post/models/user_post.dart';
import '../more_apps/yarn/utils/utils.dart';
import '../more_apps/yarn/widgets/ask_mention_view.dart';

class CreateOrEditPostScreen extends StatefulWidget {
  final UserPost? userPost;
  final String? channel;

  CreateOrEditPostScreen({Key? key, this.userPost, this.channel})
      : super(key: key);

  @override
  State<CreateOrEditPostScreen> createState() => _CreateOrEditPostScreenState();
}

class _CreateOrEditPostScreenState extends State<CreateOrEditPostScreen> {
  String? blogId;
  String? _imagePath;
  String? _videoPath;
  bool showMoreOptions = false;
  late FocusNode titleFocusNode;
  bool _userUpdatingPost = false;
  double moreOptionsHeight = 200;
  bool headerMediaIsVisible = true;
  bool showScrollToTopArrow = false;
  bool showAddInlineMediaIcon = false;
  late FocusNode textFieldTagFocusNode;
  VideoPlayerController? _mainVideoController;
  late FocusNode textEditorTextFieldFocusNode;
  late ScrollController _textEditorScrollController;
  flutterQuill.QuillController _quillBodyTextController =
      flutterQuill.QuillController.basic();
  ChewieController? pickedVideoChewieMainController;
  ChewieController? videoFromServerChewieMainController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController blogTitleCtrl = TextEditingController();

  DateTime? datePicked;
  TimeOfDay? timePicked;
  bool isPublic = true;
  bool isPublished = true;
  bool enableLikes = false;
  dynamic blogBodyTextJson;
  bool isImagePicked = false;
  List<String> userTags = [];
  DateTime? publishedDateTime;
  bool enableCommenting = false;
  List<String> blogPostInlineMediaIds = [];
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  late StreamSubscription<bool> keyboardSubscription;
  bool isMentionName = false;
  String? searchString;

  @override
  void initState() {
    super.initState();
    _textEditorScrollController = ScrollController();

    //   debugPrint('fola channel:::: ${widget.channel}');

    _initializeFocusNodes();
    _userUpdatingPost = widget.userPost != null;
    if (_userUpdatingPost) {
      initializeUserPostVariables();
    }
  }

  @override
  void dispose() {
    titleFocusNode.dispose();
    keyboardSubscription.cancel();
    _mainVideoController?.dispose();
    _textEditorScrollController.dispose();
    textEditorTextFieldFocusNode.dispose();
    pickedVideoChewieMainController?.dispose();
    videoFromServerChewieMainController?.dispose();

    super.dispose();
  }

  initializeUserPostVariables() {
    isImagePicked = _imagePath != null;
    _imagePath = widget.userPost!.image;
    _videoPath = widget.userPost!.video;

    if (_videoPath != null && _videoPath!.isNotEmpty) {
      _mainVideoController = VideoPlayerController.network(_videoPath!,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));

      videoFromServerChewieMainController = ChewieController(
        videoPlayerController: _mainVideoController!,
        aspectRatio: 16 / 9,
        allowedScreenSleep: false,
        allowFullScreen: true,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        systemOverlaysAfterFullScreen: SystemUiOverlay.values,
        materialProgressColors: ChewieProgressColors(
          playedColor: navyBlue,
          handleColor: Colors.white,
          backgroundColor: dividerColor,
          bufferedColor: Colors.white30,
        ),
        autoInitialize: true,
      );
    }
    blogId = widget.userPost!.id!;
    isPublic = widget.userPost!.publicRead!;
    enableLikes = widget.userPost!.enableLike!;
    isPublished = widget.userPost!.isPublished!;
    publishedDateTime = widget.userPost!.publishedDate;
    userTags = List<String>.from(widget.userPost!.tags!);
    // enableCommenting = widget.userPost!.enableCommenting!;
    blogTitleCtrl = TextEditingController(
        text: messageDecoderWithEmoji(widget.userPost!.title));

    try {
      blogBodyTextJson =
          jsonDecode(messageDecoderWithEmoji(widget.userPost!.text!)!);
      _quillBodyTextController = flutterQuill.QuillController(
          document: flutterQuill.Document.fromJson(blogBodyTextJson),
          selection: const TextSelection.collapsed(offset: 0));
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_userUpdatingPost) {
          showDialogBox(
            context: context,
            actionOneTextColor: white,
            actionOneBgColor: mateRed,
            actionTwoTextColor: blackFont,
            actionTwoBgColor: greyBorderColor,
            title: 'Exit editing post',
            actionTwoText: AppLocalization.of(context)!.cancel,
            actionOneText: AppLocalization.of(context)!.exit,
            description: 'Are you sure you want to exit editing this post?',
            roundedBackgroundIcon: RoundedBackgroundIcon(
              enableMargin: false,
              width: 90,
              height: 90,
              image: const Icon(SlydoAppIcon.remove),
            ),
            leftButtonOnPressed: () {
              Navigator.pop(context);
            },
          );
        } else if (_quillBodyTextController.document.toPlainText().length > 1) {
          showDialogBox(
            context: context,
            actionOneTextColor: white,
            actionOneBgColor: mateRed,
            actionTwoTextColor: blackFont,
            actionTwoBgColor: greyBorderColor,
            title: 'Exit creating post',
            actionTwoText: AppLocalization.of(context)!.cancel,
            actionOneText: AppLocalization.of(context)!.exit,
            description: 'Are you sure you want to exit creating this post?',
            roundedBackgroundIcon: RoundedBackgroundIcon(
              enableMargin: false,
              width: 90,
              height: 90,
              image: Icon(SlydoAppIcon.remove, color: mateRed),
            ),
            leftButtonOnPressed: () {
              Navigator.pop(context);
            },
          );
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: _scaffoldBody(),
      ),
    );
  }

  _scaffoldBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 5),
            Visibility(
                visible: headerMediaIsVisible,
                child: _videoPath != null && _videoPath!.isNotEmpty
                    ? getHeaderVideo()
                    : getHeaderImage()),
            const SizedBox(height: 8),
            CustomizedTextFormField(
              hintText: 'Title',
              hasBorder: false,
              hasLabel: false,
              focusNode: titleFocusNode,
              maxLength: 150,
              showLabelOrPassword: false,
              textStyle: TextStyle(
                color: blackFont,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              contentPadding: EdgeInsets.zero,
              controller: blogTitleCtrl,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getMoreOptionTrigger(),
                  Row(
                    children: [
                      Visibility(
                        visible: showAddInlineMediaIcon,
                        child: InkWell(
                          onTap: () {
                            _showPickMediaDialogBox();
                          },
                          child: Icon(
                            Icons.add_circle_outlined,
                            size: 20,
                            color: navyBlue,
                          ),
                        ),
                      ),
                      if (_imagePath != null && _imagePath!.isNotEmpty)
                        InkWell(
                          onTap: () {
                            _pickBlogImage();
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              Icons.image,
                              size: 20,
                              color: navyBlue,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      if (_videoPath != null && _videoPath!.isNotEmpty)
                        InkWell(
                          onTap: () {
                            _pickBlogVideo();
                          },
                          child: Icon(
                            Icons.video_call,
                            size: 24,
                            color: navyBlue,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
            ),
            Visibility(
              visible: showMoreOptions,
              child: moreOptions(),
            ),
            const SizedBox(height: 3),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 30),
                child: getTextEditorWidget(),
              ),
            ),
            getEditor(),
            if (isMentionName) ...[
              _buildUserNameContainer(),
            ],
          ],
        ),
      ),
    );
  }

  void onValueChange(String value) {
    final List<String> listOfWords = value.split(" ");

    if (listOfWords.isNotEmpty) {
      if ((listOfWords.last.contains("@") &&
          !value.endsWith(" ") &&
          !value.endsWith("@"))) {
        isMentionName = true;
        final List<String> mentionString = getAllMentions(value);

        if (mentionString.isNotEmpty) {
          searchString = mentionString.last.substring(1);
        }
      } else if (value.endsWith("@")) {
        isMentionName = true;

        searchString = "";
      } else {
        isMentionName = false;
      }
    }
    if (mounted) setState(() {});
  }

  Widget _buildUserNameContainer() {
    return AskMentionView(
      searchText: searchString,
      key: UniqueKey(),
      onTap: (String? tappedUser) {
        if (tappedUser != null) {
          // textController!.text = textController!.text.replaceRange(
          //   (textController!.text.length - (searchString?.length ?? 0)),
          //   textController!.text.length,
          //   tappedUser,
          // ) +
          //     " ";
          // textController!.selection = TextSelection.fromPosition(TextPosition(
          //   offset: textController!.text.length,
          // ));
          searchString = "";
          if (mounted) setState(() {});
        }
      },
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          if (_userUpdatingPost) {
            showDialogBox(
              context: context,
              actionOneTextColor: white,
              actionOneBgColor: mateRed,
              actionTwoTextColor: blackFont,
              actionTwoBgColor: greyBorderColor,
              title: 'Exit editing post',
              actionTwoText: AppLocalization.of(context)!.cancel,
              actionOneText: AppLocalization.of(context)!.exit,
              description: 'Are you sure you want to exit editing this post?',
              roundedBackgroundIcon: RoundedBackgroundIcon(
                enableMargin: false,
                width: 90,
                height: 90,
                image: const Icon(SlydoAppIcon.remove),
              ),
              leftButtonOnPressed: () {
                Navigator.pop(context);
              },
            );
          } else if (_quillBodyTextController.document.toPlainText().length >
              1) {
            showDialogBox(
              context: context,
              actionOneTextColor: white,
              actionOneBgColor: mateRed,
              actionTwoTextColor: blackFont,
              actionTwoBgColor: greyBorderColor,
              title: 'Exit creating post',
              actionTwoText: AppLocalization.of(context)!.cancel,
              actionOneText: AppLocalization.of(context)!.exit,
              description: 'Are you sure you want to exit creating this post?',
              roundedBackgroundIcon: RoundedBackgroundIcon(
                enableMargin: false,
                width: 90,
                height: 90,
                image: const Icon(SlydoAppIcon.remove),
              ),
              leftButtonOnPressed: () {
                Navigator.pop(context);
              },
            );
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        widget.userPost == null
            ? AppLocalization.of(context)!.createPost
            : AppLocalization.of(context)!.editPost,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: showScrollToTopArrow ? () => _scrollToTop() : null,
          icon: Icon(Icons.arrow_upward_rounded,
              color: showScrollToTopArrow ? navyBlue : greyBorderColor),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: showSubmitButton() ? () => submitBlogPost() : null,
          icon: Icon(Icons.send,
              color: showSubmitButton() ? navyBlue : greyBorderColor),
        ),
      ],
    );
  }

  Widget getEditor() {
    final Widget editorWidget = flutterQuill.QuillToolbar.basic(
      showDirection: false,
      showHeaderStyle: false,
      showInlineCode: false,
      showCodeBlock: false,
      showStrikeThrough: false,
      showJustifyAlignment: false,
      showBackgroundColorButton: false,
      showClearFormat: false,
      showDividers: false,
      showIndent: false,
      showListCheck: false,
      showRedo: false,
      showListBullets: false,
      showListNumbers: false,
      showAlignmentButtons: true,
      controller: _quillBodyTextController,
    );

    if (widget.userPost != null) {
      if (blogBodyTextJson != null) {
        return editorWidget;
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return editorWidget;
    }
  }

  void submitBlogPost() async {
    if (formKey.currentState!.validate()) {
      showDialogBox(
        context: context,
        actionOneTextColor: blackFont,
        actionTwoBgColor: naturalGreen,
        actionTwoTextColor: Colors.white,
        actionOneBgColor: greyBorderColor,
        title: AppLocalization.of(context)!.post,
        actionTwoText: AppLocalization.of(context)!.post,
        actionOneText: AppLocalization.of(context)!.notNow,
        description: _userUpdatingPost
            ? 'Are you sure you want to update post'
            : 'Are you sure you want to post\nyour content now?',
        roundedBackgroundIcon: RoundedBackgroundIcon(
          enableMargin: false,
          width: 90,
          height: 90,
          image: Image.asset('assets/images/accept_dialog_icon.png'),
        ),
        rightButtonOnPressed: () {
          showDialog(
              context: context,
              builder: (dialogLoadingContext) => LoadingIndicator());
          createOrUpdateBlogPost();
        },
      );
    }
  }

  File? getVideoFileToUpload() {
    if (_videoPath != null && _videoPath!.isNotEmpty) {
      if (_videoPath!.startsWith('http')) {
        return null;
      } else {
        return File(_videoPath!);
      }
    } else {
      return null;
    }
  }

  File? getImageFileToUpload() {
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      if (_imagePath!.startsWith('http')) {
        return null;
      } else {
        return File(_imagePath!);
      }
    } else {
      return null;
    }
  }

  createOrUpdateBlogPost() {
    final List<String>? newUserTags =
        []; // For replacing the # in a tag with an empty string.

    userTags.forEach((tag) {
      if (tag.startsWith('#')) {
        newUserTags?.add(tag.replaceAll("#", ''));
      } else {
        newUserTags?.add(tag);
      }
    });

    final userBloc = Provider.of<UserBloc>(context, listen: false);
    UserPostAuth()
        .createOrUpdateBlogPost(
            blogId: blogId,
            tags: newUserTags,
            isPublic: isPublic,
            isPublished: isPublished,
            enableLikes: enableLikes,
            title: blogTitleCtrl.text,
            isUpdating: _userUpdatingPost,
            blogImage: getImageFileToUpload(),
            blogVideo: getVideoFileToUpload(),
            enableCommenting: enableCommenting,
            inLineMediaIds: blogPostInlineMediaIds,
            authorUserName: userBloc.user.userName!,
            publishedDate: publishedDateTime.toString(),
            blogPostBody: jsonEncode(
                _quillBodyTextController.document.toDelta().toJson()),
            channelUsername: widget.channel ?? "")
        .then(
      (posted) {
        Navigator.pop(context); // To dismiss loading indicator.
        if (posted) {
          if (_userUpdatingPost) {
            showToast(message: 'Blog post updated');
          } else {
            showToast(message: 'Blog post created');
          }
          Navigator.pop(context, true); // Go to user details page.
        } else {
          showToast(message: 'Something went wrong');
        }
      },
    ).catchError(
      (error) {
        Navigator.pop(context);
        if (error.toString().contains('must make a unique set')) {
          showToast(
              message: 'You already have a similar post with the same title.');
        } else {
          showToast(message: error.toString());
        }
      },
    );
  }

  // Future<File> urlToFile(String imageUrl) async {
  //   var rng = new Random();
  //   Directory tempDir = await getTemporaryDirectory();
  //   String tempPath = tempDir.path;
  //   File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
  //   http.Response response = await http.get(Uri.parse(imageUrl));
  //   await file.writeAsBytes(response.bodyBytes);
  //
  //   _imageFile = file.path;
  //   return file;
  // }

  _pickBlogImage({Function(String image)? imagePickedCallBack}) async {
    final String? croppedImage = await getFile(context);

    if (imagePickedCallBack != null && croppedImage != null) {
      imagePickedCallBack(croppedImage);
    } else {
      if (croppedImage != null) {
        setState(() {
          _imagePath = croppedImage;
          isImagePicked = true;
          debugPrint('Fola cropped:::: ${croppedImage}');
          debugPrint('Fola cropped 000:::: ${_imagePath}');
        });
      }
    }
  }

  _pickBlogVideo({Function(String video)? videoPickedCallBack}) async {
    final String? videoPath = await getFile(context, fileType: MediaType.video);

    if (videoPath != null) {
      final int sizeInBytes = File(videoPath).lengthSync();

      final int sizeInMb = (sizeInBytes ~/ (1024 * 1024)).toInt();

      debugPrint('SIZE IN MB --> $sizeInMb');

      if (sizeInMb <= maxVideoFileSize) {
        if (videoPickedCallBack != null) {
          videoPickedCallBack(videoPath);
        } else {
          setState(() {
            _videoPath = videoPath;
          });
        }
      } else {
        showToast(message: 'File is too large');
      }
    }
  }

  Widget getHeaderImage() {
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      return Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _imagePath!.startsWith('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: widget.userPost?.image ?? "",
                        fit: BoxFit.fill,
                        width: 200,
                        height: 200,
                        errorWidget: imageErrorWidget,
                      ),
                    )
                  : Image.file(
                      File(_imagePath!),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Positioned(
            top: 15,
            right: 10,
            child: CircleAvatar(
              backgroundColor: navyBlue,
              child: InkWell(
                  onTap: () => _pickBlogVideo(),
                  child: const Icon(Icons.video_call)),
            ),
          ),
        ],
      );
    } else {
      return InkWell(
        onTap: () => _pickBlogImage(),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: greyBorderColor,
              border: Border.all(color: greyBorderColor),
              borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(
                //   Icons.add_circle,
                //   size: 40,
                // ),
                const Text('Tap here to add blog post header image')
              ],
            ),
          ),
        ),
      );
    }
  }

  bool showSubmitButton() {
    return _imagePath != null &&
        _imagePath!.isNotEmpty &&
        blogTitleCtrl.text.isNotEmpty &&
        _quillBodyTextController.document.toPlainText().length > 10;
  }

  Widget getHeaderVideo() {
    final bool videoFromServer = _videoPath!.startsWith('http');

    if (_videoPath != null && _videoPath!.isNotEmpty) {
      if (!videoFromServer) {
        final mainVideoController = VideoPlayerController.file(
            File(_videoPath!),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));

        pickedVideoChewieMainController = ChewieController(
          videoPlayerController: mainVideoController,
          aspectRatio: 16 / 9,
          allowedScreenSleep: false,
          allowFullScreen: false,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
          systemOverlaysAfterFullScreen: SystemUiOverlay.values,
          materialProgressColors: ChewieProgressColors(
            playedColor: navyBlue,
            handleColor: Colors.white,
            backgroundColor: dividerColor,
            bufferedColor: Colors.white30,
          ),
          autoInitialize: true,
        );
      }
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Chewie(
            titleName: videoFromServer ? widget.userPost!.title : '',
            posterUrl: videoFromServer ? widget.userPost!.image : _imagePath,
            controller: videoFromServer
                ? videoFromServerChewieMainController!
                : pickedVideoChewieMainController!,
          ),
        ),
        InkWell(
          onTap: () {
            showDialogBox(
              context: context,
              title: 'Delete your video',
              actionTwoTextColor: white,
              actionTwoBgColor: mateRed,
              actionOneTextColor: blackFont,
              actionOneBgColor: greyBorderColor,
              actionOneText: AppLocalization.of(context)!.cancel,
              actionTwoText: AppLocalization.of(context)!.delete,
              description: 'Are you sure you want to delete your video?',
              roundedBackgroundIcon: RoundedBackgroundIcon(
                width: 90,
                height: 90,
                enableMargin: false,
                image: const Icon(SlydoAppIcon.remove),
              ),
              rightButtonOnPressed: () {
                if (videoFromServer) {
                  videoFromServerChewieMainController?.pause();
                } else {
                  pickedVideoChewieMainController?.pause();
                }
                setState(() => _videoPath = null);
              },
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(Icons.close, color: Colors.red, size: 25),
            ),
          ),
        ),
      ],
    );
  }

  void _scrollToTop() {
    _textEditorScrollController.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.linear);
    textEditorTextFieldFocusNode.unfocus();
    setState(() {
      headerMediaIsVisible = true;
    });
  }

  Widget getTextEditorWidget() {
    final flutterQuill.QuillEditor quillEditor = flutterQuill.QuillEditor(
      autoFocus: false,
      controller: _quillBodyTextController,
      readOnly: false,
      scrollable: true,
      expands: false,
      padding: EdgeInsets.zero,
      placeholder: 'Tell your story...',
      scrollController: _textEditorScrollController,
      focusNode: textEditorTextFieldFocusNode,
      scrollBottomInset: 20,
      embedBuilders: CustomQuillEmbed.builders(),
    );
    if (widget.userPost != null) {
      if (blogBodyTextJson != null) {
        return quillEditor;
      } else {
        return Text(widget.userPost!.text!);
      }
    } else {
      return quillEditor;
    }
  }

  Widget getMoreOptionTrigger() {
    return GestureDetector(
      onTap: () {
        showMoreOptions = !showMoreOptions;
        print('SHOW MORE OPTIONS ::: $showMoreOptions');
        if (showMoreOptions == true) {
          titleFocusNode.unfocus();
          headerMediaIsVisible = false;
          textEditorTextFieldFocusNode.unfocus();
        } else {
          headerMediaIsVisible = true;
        }
        print('HEADER IS VISIBLE :::: $headerMediaIsVisible');
        if (mounted) setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Text(
              showMoreOptions ? "Less options" : "More options",
              style: TextStyle(
                  color: darkGrey, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              width: 4,
            ),
            Icon(
              showMoreOptions
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: darkGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget moreOptions() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.30,
      child: ScrollConfiguration(
        behavior: MyScrollBehaviour(),
        child: ListView(
          children: [
            BlogSettingsTitles(
              addElevation: false,
              title: 'Make Public',
              description:
                  'Your post will become public to your friends and everyone',
              isSwitched: isPublic,
              icon: Icon(Icons.public_outlined, color: blackFont),
              onChanged: (makePostPublic) {
                isPublic = makePostPublic;
                setState(() => isPublic = makePostPublic);
              },
            ),
            BlogSettingsTitles(
              title: 'Publish',
              addElevation: false,
              description: 'Your post will be published',
              isSwitched: isPublished,
              icon: Icon(
                Icons.published_with_changes_outlined,
                color: blackFont,
              ),
              onChanged: (publishPost) {
                isPublished = publishPost;
                setState(() => isPublished = publishPost);
              },
            ),
            BlogSettingsTitles(
              title: 'Enable Comments',
              addElevation: false,
              isEnabled: false,
              description: 'Everyone will be able to comment on your post',
              isSwitched: enableCommenting,
              icon: Icon(Icons.message_rounded, color: blackFont),
              onChanged: (commentingEnabled) {
                // enableCommenting = commentingEnabled;
                // setState(() => enableCommenting = commentingEnabled);
              },
            ),
            BlogSettingsTitles(
              title: 'Enable Likes',
              addElevation: false,
              description: 'Everyone will be able to like your post',
              isSwitched: enableLikes,
              icon: Icon(Icons.thumb_up, color: blackFont),
              onChanged: (likeEnabled) {
                enableLikes = likeEnabled;
                setState(() => enableLikes = likeEnabled);
              },
            ),
            BlogSettingsTitles(
              hasSwitch: false,
              addElevation: false,
              trailingWidget: publishedDateTime != null
                  ? Text(
                      DateFormat('yyyy-MM-dd H:m').format(publishedDateTime!))
                  : const Text(''),
              onTap: () async {
                datePicked = await showDatePicker(
                    builder: customThemeBuilder,
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030));

                timePicked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (datePicked != null && timePicked != null) {
                  publishedDateTime = DateTime(
                      datePicked!.year,
                      datePicked!.month,
                      datePicked!.day,
                      timePicked!.hour,
                      timePicked!.minute);
                }

                print('FINAL DATE TIME -----> ${publishedDateTime.toString()}');
                setState(() => publishedDateTime = publishedDateTime);
                // '2022-02-28T13:35:43.590377+01:00'
              },
              title: 'Published Date',
              description: 'Pick a date to publish your post',
              icon: Icon(Icons.event_outlined, color: blackFont),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Focus(
                focusNode: textFieldTagFocusNode,
                child: Container(),

                ///ToDo TextFieldTags check
                // child: TextFieldTags(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initializeFocusNodes() {
    titleFocusNode = FocusNode();
    textFieldTagFocusNode = FocusNode();
    bool shouldSetStateForBlogTitle = false;

    bool shouldSetStateForBlogMainText = false;

    textEditorTextFieldFocusNode = FocusNode();

    textFieldTagFocusNode.addListener(() {
      if (textFieldTagFocusNode.hasFocus) {
        setState(() {
          headerMediaIsVisible = false;
        });
      } else {
        setState(() {
          headerMediaIsVisible = true;
        });
      }
    });
    titleFocusNode.addListener(() {
      if (titleFocusNode.hasFocus) {
        setState(() {
          showMoreOptions = false;
          headerMediaIsVisible = true;
        });
      }
    });

    // _textEditorScrollController.addListener(() {
    //   if (_textEditorScrollController.position.atEdge) {
    //     bool isTop = _textEditorScrollController.position.pixels == 0;
    //     if (isTop) {
    //       setState(() {
    //         headerMediaIsVisible = true;
    //       });
    //     }
    //   }
    // });

    textEditorTextFieldFocusNode.addListener(() {
      if (textEditorTextFieldFocusNode.hasFocus) {
        setState(() {
          showMoreOptions = false;
          showScrollToTopArrow = true;
          headerMediaIsVisible = false;
          showAddInlineMediaIcon = true;
        });
      } else {
        setState(() {
          showScrollToTopArrow = false;
          showAddInlineMediaIcon = false;
        });
      }
    });
    blogTitleCtrl.addListener(() {
      if (blogTitleCtrl.text.isNotEmpty) {
        if (shouldSetStateForBlogTitle == true) {
          setState(() {
            shouldSetStateForBlogTitle = false;
          });
        }
      } else {
        setState(() {
          shouldSetStateForBlogTitle = true;
        });
      }
    });
    _quillBodyTextController.addListener(() {
      if (_quillBodyTextController.document.toPlainText().length > 10) {
        if (shouldSetStateForBlogMainText == true) {
          setState(() {
            shouldSetStateForBlogMainText = false;
          });
        }
      } else {
        setState(() {
          shouldSetStateForBlogMainText = true;
        });
      }
    });
  }

  _showPickMediaDialogBox() {
    showDialogBox(
      context: context,
      actionOneText: 'VIDEO',
      actionTwoText: 'IMAGE',
      title: 'Add media',
      description: 'Insert an inline image/video to add to the blog content',
      actionOneBgColor: navyBlue,
      actionTwoBgColor: navyBlue,
      isOverlayTapDismiss: true,
      actionOneTextColor: Colors.white,
      actionTwoTextColor: Colors.white,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Icon(SlydoAppIcon.add, color: navyBlue),
      ),
      leftButtonOnPressed: () {
        _pickBlogVideo(
          videoPickedCallBack: (videoPicked) =>
              sendMediaToServerAndAddToBlogPost(
            mediaFile: videoPicked,
            mediaType: MediaType.video,
          ),
        );
      },
      rightButtonOnPressed: () {
        _pickBlogImage(
            imagePickedCallBack: (imagePicked) =>
                sendMediaToServerAndAddToBlogPost(
                  mediaFile: imagePicked,
                  mediaType: MediaType.picture,
                ));
      },
    );

    return true;
  }

  sendMediaToServerAndAddToBlogPost(
      {required MediaType mediaType, required String mediaFile}) {
    final index = _quillBodyTextController.selection.baseOffset;
    final length = _quillBodyTextController.selection.extentOffset - index;
    showDialog(
        context: context,
        builder: (dialogLoadingContext) => LoadingIndicator());

    UserPostAuth()
        .uploadPickedMediaForPostBody(mediaFile: mediaFile)
        .then((response) {
      if (response != null) {
        Navigator.pop(context);

        showToast(message: 'Media uploaded');

        if (mounted) setState(() {});

        _quillBodyTextController.replaceText(
          index,
          length,
          mediaType == MediaType.picture
              ? flutterQuill.BlockEmbed.image(response['media'])
              : flutterQuill.BlockEmbed.video(response['media']),
          null,
        );
        blogPostInlineMediaIds.add(response['id']);

        _quillBodyTextController.replaceText(index + 1, length, '\n', null);
      } else {
        Navigator.pop(context);

        showToast(message: 'Something went wrong');
      }
    }).catchError(
      (error) {
        Navigator.pop(context);
        showToast(message: error.toString());
      },
    );
  }
}

class ChooseOptionsCard extends StatelessWidget {
  final Function() onTap;
  final IconData iconData;

  const ChooseOptionsCard(
      {Key? key, required this.iconData, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
            border: Border.all(color: greyBorderColor),
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(5),
        child: Icon(iconData, size: 30),
      ),
    );
  }
}

class MyScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
