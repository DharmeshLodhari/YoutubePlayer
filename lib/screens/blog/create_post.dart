import 'dart:convert';
import 'dart:io';

import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutterQuill;

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

  @override
  void initState() {
    super.initState();
    if (widget.userPost != null) {
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
            : AppLocalization.of(context)!.editPost,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        SizedBox(
          width: 16,
        ),
        TextButton(
          child: Text(AppLocalization.of(context)!.post),
          onPressed: () {
            submitBlogPost(
              title: blogTitleCtrl.text,
              tagLine: blogTagLineCtrl.text,
              blogImage: _imageFile != null ? File(_imageFile!) : null,
              blogBodyText: _quillBodyTextController.document.toPlainText(),
            );
          },
        ),
      ],
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
                          ? postImage()
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
                      style: TextStyle(fontSize: 18),
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

  Widget postImage() {
    return Container(
      child: CachedNetworkImage(
        imageUrl: widget.userPost?.authorAvatar ?? "",
        fit: BoxFit.fill,
        width: 200,
        height: 200,
      ),
    );
  }

  void submitBlogPost({
    required title,
    required tagLine,
    required String blogBodyText,
    File? blogImage,
    List<String>? tags,
  }) async {
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
            _postBlog(
                title: title,
                tagLine: tagLine,
                blogImage: blogImage,
                tags: tags);
          },
        );
      } else {
        showToast(message: 'Blog must have a body');
      }
    }
  }

  _postBlog(
      {required String title,
      required List<String>? tags,
      required String tagLine,
      File? blogImage}) {
    UserPostAuth()
        .postUserBlogPost(
            tags: tags,
            title: title,
            tagLine: tagLine,
            blogImage: blogImage,
            blogBodyText: jsonEncode(
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
