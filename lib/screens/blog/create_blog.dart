import 'dart:convert';
import 'dart:io';

import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutterQuill;

import '../../locale/app_localization.dart';
import '../../utils/colors.dart';
import '../../widget/LoadingIndicator.dart';
import '../../widget/curved_btn.dart';

class CreateBlogScreen extends StatefulWidget {
  const CreateBlogScreen({Key? key}) : super(key: key);

  @override
  State<CreateBlogScreen> createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  String? _imageFile;
  flutterQuill.QuillController _quillBodyTextController =
      flutterQuill.QuillController.basic();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController blogTitleCtrl = TextEditingController();
  TextEditingController blogTagLineCtrl = TextEditingController();

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
          Navigator.pop(context);
        },
      ),
      title: Text(
        AppLocalization.of(context)!.createBlog,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        SizedBox(
          width: 16,
        ),
        TextButton(
          child: Text('POST'),
          onPressed: () {
            submitBlogPost(
              title: blogTitleCtrl.text,
              tagLine: blogTagLineCtrl.text,
              blogBodyText: _quillBodyTextController.document.toPlainText(),
              blogImage: _imageFile != null ? File(_imageFile!) : null,
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
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(_imageFile!),
                                  width: 200, height: 200, fit: BoxFit.cover),
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(vertical: 50),
                              decoration: BoxDecoration(
                                  border: Border.all(color: greyBorderColor),
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

  void submitBlogPost(
      {required title,
      required tagLine,
      required String blogBodyText,
      File? blogImage}) async {
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
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (dialogLoadingContext) => LoadingIndicator());
            _postBlog(title: title, tagLine: tagLine);
          },
        );
      } else {
        showToast(message: 'Blog must have a body');
      }
    }
  }

  _postBlog({required String title, required String tagLine}) {
    UserPostAuth()
        .postUserBlogPost(
            title: title,
            tagLine: tagLine,
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

    if (croppedImage != null) {
      setState(() {
        _imageFile = croppedImage;
      });
    }
  }
}
