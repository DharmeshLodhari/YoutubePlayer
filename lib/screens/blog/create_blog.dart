import 'dart:convert';
import 'dart:io';

import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
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
        showDialog(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: Text('Are you sure you want to post your content now?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Not yet'),
                  ),
                  CurvedButton(
                    text: 'Post',
                    width: 80,
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (dialogLoadingContext) =>
                              LoadingIndicator());
                      UserPostAuth()
                          .postUserBlogPost(
                              title: title,
                              tagLine: tagLine,
                              blogBodyText: jsonEncode(_quillBodyTextController
                                  .document
                                  .toDelta()
                                  .toJson()))
                          .then(
                        (posted) {
                          Navigator.pop(context);

                          if (posted) {
                            showToast(message: 'Blog post created');
                            Navigator.pop(
                                context); // To go to the user's profile page.

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
                    },
                  ),
                ],
              );
            });
      } else {
        showToast(message: 'Blog must have a body');
      }
    }
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

//
// Expanded(
// child: SingleChildScrollView(
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.stretch,
// children: [
// SizedBox(height: 20),
// InkWell(
// onTap: () => _pickBlogImage(),
// child: _imageFile != null
// ? ClipRRect(
// borderRadius: BorderRadius.circular(12),
// child: Image.file(File(_imageFile!),
// width: 200, height: 200, fit: BoxFit.cover),
// )
// : Container(
// padding: EdgeInsets.symmetric(vertical: 50),
// decoration: BoxDecoration(
// border: Border.all(color: greyBorderColor),
// borderRadius: BorderRadius.circular(10)),
// child: Icon(SlydoAppIcon.image),
// ),
// ),
// SizedBox(height: 10),
// blogBodyTextCtrl.text.isNotEmpty
// ? Text(
// blogBodyTextCtrl.text,
// style: TextStyle(
// fontSize: 18,
// color: blackFont,
// fontWeight: FontWeight.w600,
// ),
// )
// : Text(
// 'Body text',
// style: TextStyle(color: Colors.grey, fontSize: 24),
// ),
// ],
// ),
// ),
// ),

//
// CustomizedTextFormField(
// hintText: 'Title',
// hasBorder: false,
// maxLength: 150,
// maxLines: 2,
// controller: blogTitleCtrl,
// validator: (value) {
// return value.toString().isEmpty
// ? 'Field cannot be empty'
//     : null;
// },
// ),
// CustomizedTextFormField(
// hintText: 'Tag Line',
// hasBorder: false,
// controller: blogTagLineCtrl,
// validator: (value) {
// return value.toString().isEmpty
// ? 'Field cannot be empty'
//     : null;
// },
// ),

// Padding(
// padding: const EdgeInsets.symmetric(vertical: 12.0),
// child: Row(
// children: [
// Expanded(
// child: CustomizedTextFormField(
// hintText: 'Blog Text',
// hasLabel: false,
// maxLines: null,
// onChanged: (value) {
// //To update the blog body text (with  blogBodyTextCtrl.text), whenever the value changes.
// setState(() {});
// },
// controller: blogBodyTextCtrl,
// validator: (value) {
// return value.toString().isEmpty
// ? 'Field cannot be empty'
//     : null;
// },
// ),
// ),
// SizedBox(width: 10),
// Padding(
// padding: const EdgeInsets.only(top: 4.0),
// child: InkWell(
// onTap: () => submitBlogPost(
// title: blogTitleCtrl.text,
// text: blogBodyTextCtrl.text,
// blogImage:
// _imageFile != null ? File(_imageFile!) : null,
// ),
// child: CircleAvatar(
// backgroundColor: navyBlue,
// child: Icon(Icons.send, color: Colors.white),
// ),
// ),
// ),
// ],
// ),
// ),
