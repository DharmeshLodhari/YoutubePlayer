import 'dart:convert';
import 'dart:io';

import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutterQuill;
import 'package:intl/intl.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../locale/app_localization.dart';
import '../../utils/colors.dart';
import '../../widget/LoadingIndicator.dart';
import '../../widget/curved_btn.dart';
import '../more_apps/user_post/models/user_post.dart';

class CreatePostScreen extends StatefulWidget {
  final UserPost? userPost;

  const CreatePostScreen({Key? key, this.userPost}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String? _imageFile;
  flutterQuill.QuillController _quillBodyTextController =
      flutterQuill.QuillController.basic();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController blogTitleCtrl = TextEditingController();
  TextEditingController blogTagLineCtrl = TextEditingController();

  DateTime? datePicked;
  TimeOfDay? timePicked;
  bool isPublic = false;
  DateTime? publishedDateTime;
  bool isPublished = false;
  bool enableLikes = false;
  List<String> userTags = [];
  bool enableCommenting = false;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    if (widget.userPost != null) {
      isPublic = widget.userPost!.publicRead!;
      enableLikes = widget.userPost!.enableLike!;
      isPublished = widget.userPost!.isPublished!;
      publishedDateTime = widget.userPost!.publishedDate;
      userTags = List<String>.from(widget.userPost!.tags!);
      enableCommenting = widget.userPost!.enableCommenting!;
      blogTitleCtrl = TextEditingController(text: widget.userPost!.title);
      blogTagLineCtrl = TextEditingController(text: widget.userPost!.tagLine);
      _quillBodyTextController = flutterQuill.QuillController(
        document:
            flutterQuill.Document.fromJson(jsonDecode(widget.userPost!.text!)),
        selection: TextSelection.collapsed(offset: 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar() as PreferredSizeWidget?,
      body: _scaffoldBody(),
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
          if (widget.userPost != null) {
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
                image: Icon(SlydoAppIcon.remove),
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
            : AppLocalization.of(context)!.post,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        SizedBox(
          width: 16,
        ),
        menuIcon()
      ],
    );
  }

  Widget menuIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.menu,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        blogActionSheet();
      },
      backgroundColor: lightGrey.withOpacity(0.1),
      enableMargin: true,
    );
  }

  void blogActionSheet() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    bottomSheetItem(
                      title: widget.userPost != null
                          ? AppLocalization.of(context)!.editPost
                          : AppLocalization.of(context)!.createAPost,
                      icon: Icons.public_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        submitBlogPost();
                      },
                    ),
                    bottomSheetItem(
                      title: 'More Options',
                      icon: Icons.more_rounded,
                      onTap: () {
                        Navigator.pop(context);
                        _showMoreOptionsDialog();
                      },
                    ),
                  ],
                ),
              ));
        });
  }

  _showMoreOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        bool isPublic_dialog = isPublic;
        bool isPublished_dialog = isPublished;
        bool enableLikes_dialog = enableLikes;
        List<String> userTags_dialog = userTags;
        DateTime? finalDateTime_dialog = publishedDateTime;
        bool enableCommenting_dialog = enableCommenting;
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(12),
          content: SingleChildScrollView(
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlogSettingsTitles(
                    addElevation: false,
                    title: 'Make Public',
                    description:
                        'Your post will become public to your friends and everyone',
                    isSwitched: isPublic_dialog,
                    icon: Icon(Icons.public_outlined, color: blackFont),
                    onChanged: (makePostPublic) {
                      isPublic = makePostPublic;
                      setState(() => isPublic_dialog = makePostPublic);
                    },
                  ),
                  BlogSettingsTitles(
                    title: 'Publish',
                    addElevation: false,
                    description: 'Your post will be published',
                    isSwitched: isPublished_dialog,
                    icon: Icon(
                      Icons.published_with_changes_outlined,
                      color: blackFont,
                    ),
                    onChanged: (publishPost) {
                      isPublished = publishPost;
                      setState(() => isPublished_dialog = publishPost);
                    },
                  ),
                  BlogSettingsTitles(
                    title: 'Enable Comments',
                    addElevation: false,
                    description:
                        'Everyone will be able to comment on your post',
                    isSwitched: enableCommenting_dialog,
                    icon: Icon(Icons.message_rounded, color: blackFont),
                    onChanged: (commentingEnabled) {
                      enableCommenting = commentingEnabled;
                      setState(
                          () => enableCommenting_dialog = commentingEnabled);
                    },
                  ),
                  BlogSettingsTitles(
                    title: 'Enable Likes',
                    addElevation: false,
                    description: 'Everyone will be able to like your post',
                    isSwitched: enableLikes_dialog,
                    icon: Icon(Icons.thumb_up, color: blackFont),
                    onChanged: (likeEnabled) {
                      enableLikes = likeEnabled;
                      setState(() => enableLikes_dialog = likeEnabled);
                    },
                  ),
                  BlogSettingsTitles(
                    hasSwitch: false,
                    addElevation: false,
                    trailingWidget: finalDateTime_dialog != null
                        ? Text(DateFormat('yyyy-MM-dd H:m')
                            .format(finalDateTime_dialog!))
                        : Text(''),
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
                      publishedDateTime = DateTime(
                          datePicked!.year,
                          datePicked!.month,
                          datePicked!.day,
                          timePicked!.hour,
                          timePicked!.minute);

                      print(
                          'FINAL DATE TIME -----> ${publishedDateTime.toString()}');
                      setState(() => finalDateTime_dialog = publishedDateTime);
                      // '2022-02-28T13:35:43.590377+01:00'
                      // setState(() {});
                      // _onRefresh();
                    },
                    title: 'Published Date',
                    description: 'Pick a date to publish your post',
                    icon: Icon(Icons.event_outlined, color: blackFont),
                  ),
                  SizedBox(height: 10),
                  TextFieldTags(
                    initialTags: userTags_dialog,
                    tagsStyler: TagsStyler(
                      tagDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: HexColor("#F7F7F9"),
                      ),
                      tagTextStyle: TextStyle(
                          color: darkGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                      tagCancelIconPadding: EdgeInsets.only(left: 12),
                      tagCancelIcon:
                          Icon(SlydoAppIcon.close_2, color: blackFont),
                    ),
                    textFieldStyler: TexusertFieldStyler(),
                    onTag: (tag) {
                      userTags.add(tag);
                      setState(() {
                        userTags_dialog.add(tag);
                      });
                      userTags.removeWhere((tag) => tag.isEmpty);
                    },
                    onDelete: (tag) {
                      userTags.remove(tag);
                      setState(() {
                        userTags_dialog.remove(tag);
                      });
                      userTags.removeWhere((tag) => tag.isEmpty);
                    },
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _scaffoldBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomizedTextFormField(
                      hintText: 'Title',
                      hasBorder: false,
                      maxLength: 150,
                      textStyle: TextStyle(
                        color: blackFont,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      controller: blogTitleCtrl,
                      validator: (value) {
                        return value.toString().isEmpty
                            ? 'Field cannot be empty'
                            : null;
                      },
                    ),
                    Divider(thickness: 1),
                    CustomizedTextFormField(
                      hintText: 'Tag Line',
                      hasBorder: false,
                      textStyle: TextStyle(
                        color: blackFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      controller: blogTagLineCtrl,
                      validator: (value) {
                        return value.toString().isEmpty
                            ? 'Field cannot be empty'
                            : null;
                      },
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () => _pickBlogImage(),
                      child: widget.userPost != null
                          ? blogPostImage(imageFile: _imageFile)
                          : _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(_imageFile!),
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover),
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(vertical: 50),
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: greyBorderColor),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Icon(SlydoAppIcon.image),
                                ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Body of your blog',
                      style: TextStyle(
                        fontSize: 18,
                        color: blackFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: flutterQuill.QuillEditor.basic(
                        controller: _quillBodyTextController,
                        readOnly: false, // true for view only mode
                      ),
                    ),
                  ],
                ),
              ),
            ),
            flutterQuill.QuillToolbar.basic(
              showLink: false,
              showDividers: false,
              showColorButton: false,
              showSmallButton: false,
              showImageButton: false,
              showCameraButton: false,
              showAlignmentButtons: false,
              controller: _quillBodyTextController,
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget blogPostImage({String? imageFile}) {
    return imageFile != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(_imageFile!),
                width: 200, height: 200, fit: BoxFit.cover),
          )
        : Container(
            child: CachedNetworkImage(
              imageUrl: widget.userPost?.image ?? "",
              fit: BoxFit.fill,
              width: 200,
              height: 200,
            ),
          );
  }

  void submitBlogPost() async {
    if (formKey.currentState!.validate()) {
      if (_quillBodyTextController.document.toPlainText().length > 1) {
        showDialogBox(
          context: context,
          actionOneTextColor: blackFont,
          actionTwoBgColor: naturalGreen,
          actionTwoTextColor: Colors.white,
          actionOneBgColor: greyBorderColor,
          title: AppLocalization.of(context)!.post,
          actionTwoText: AppLocalization.of(context)!.post,
          actionOneText: AppLocalization.of(context)!.notNow,
          description: 'Are you sure you want to post\nyour content now?',
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
            widget.userPost == null ? _createBlogPost() : _updateBlog();
          },
        );
      } else {
        showToast(message: 'Blog must have a body');
      }
    }
  }

  _createBlogPost() {
    UserPostAuth()
        .createBlogPost(
            tags: userTags,
            title: blogTitleCtrl.text,
            tagLine: blogTagLineCtrl.text,
            blogImage: _imageFile != null ? File(_imageFile!) : null,
            isPublic: isPublic,
            publishedDate: publishedDateTime.toString(),
            isPublished: isPublished,
            enableLikes: enableLikes,
            enableCommenting: enableCommenting,
            blogPostBody: jsonEncode(
                _quillBodyTextController.document.toDelta().toJson()))
        .then(
      (posted) {
        Navigator.pop(context); // To dismiss loading indicator.
        if (posted) {
          showToast(message: 'Blog post created');
          Navigator.pop(context); // To go to the user's profile page.
        } else {
          showToast(message: 'Something went wrong');
        }
      },
    ).catchError(
      (error) {
        Navigator.pop(context);
        showToast(message: error.toString());
      },
    );
  }

  _updateBlog() {
    UserPostAuth()
        .updateBlogPost(
            tags: userTags,
            isPublic: isPublic,
            isPublished: isPublished,
            enableLikes: enableLikes,
            publishedDate: publishedDateTime.toString(),
            enableCommenting: enableCommenting,
            title: blogTitleCtrl.text,
            tagLine: blogTagLineCtrl.text,
            blogImage: _imageFile != null ? File(_imageFile!) : null,
            blogPostBody: jsonEncode(
                _quillBodyTextController.document.toDelta().toJson()),
            blogId: widget.userPost!.id!)
        .then(
      (posted) {
        Navigator.pop(context); // To dismiss loading indicator.
        if (posted) {
          showToast(message: 'Blog post updated');
          Navigator.pop(context); // To go to the user's profile page.
        } else {
          showToast(message: 'Something went wrong');
        }
      },
    ).catchError(
      (error) {
        Navigator.pop(context);
        showToast(message: error.toString());
      },
    );
  }

  _pickBlogImage() async {
    String? croppedImage = await getCroppedImage(context);
    print('CROPPED IMAGE: $croppedImage');

    if (croppedImage != null) {
      setState(() {
        _imageFile = croppedImage;
      });
    }
  }
}
