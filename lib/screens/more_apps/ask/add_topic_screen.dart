import 'dart:io';
import 'package:Slydo/screens/more_apps/ask/ask_auth.dart';
import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:Slydo/screens/more_apps/ask/models/ask_categories_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../../data/state_notifier.dart';
import '../../../locale/app_localization.dart';
import '../../../utils/slydo_app_icon_icons.dart';
import '../../../utils/util.dart';
import '../../../widget/CustomBoxShadow.dart';
import '../../../widget/curved_btn.dart';
import '../../../widget/customized_dropdown_field.dart';
import '../../../widget/customized_textform_field.dart';
import '../../../widget/image_crop.dart';
import 'ask_viewmodel.dart';

class AddTopicScreen extends StatefulWidget {
  List<AskCategories>? askCategories;
  bool? isYarn = false;
  AddTopicScreen({this.askCategories, this.isYarn});

  @override
  State<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final yarnController = TextEditingController();

  final textController = TextEditingController();
  late FocusNode textFieldTagFocusNode;
  ScrollController _scrollController = ScrollController();
  List<PickedFile> selectedImages = [];
  int imageCount = 5;
  AskCategories? selectedAskCategory;
  AskCategories? pressedAskCategory;
  List<AskCategories>? askCategoriesCopy;
  String askCategory = "";
  List<String> userTags = [];
  late UserBloc userBloc;

  @override
  void initState() {
    Future.microtask(() => context.read<AskViewModel>().init());
    textFieldTagFocusNode = FocusNode();
    askCategoriesCopy = widget.askCategories;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Consumer<AskViewModel>(builder: (context, model, child) {
        return ListView(
          padding: EdgeInsets.all(15),
          children: [
            _buildYarnOrQuestionForm(model)
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        widget.isYarn! ? "Create Yarn" : "Ask Question",
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: blackFont,
        ),
      ),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 26,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.add_photo_alternate_rounded,
            color: HexColor("#000000"),
            size: 26,
          ),
          onPressed: () {
            pickImage();
          },
        ),
      ],
    );
  }
  
  Widget _buildYarnOrQuestionForm(AskViewModel model) {
    if (widget.isYarn!) {
      return _buildYarnForm(model);
    }
    return _buildQuestionForm(model);
  }
  
  Widget _buildYarnForm(AskViewModel model) {
    return Column(
      children: [
        _buildAddImages(),
        SizedBox(height: 20,),
        _buildYarnField(),
        SizedBox(height: 20,),
        _buildTags(model),
        SizedBox(height: 20,),
        getCategoryField(),
        SizedBox(height: 50,),
        _buildSubmitButton(),
      ],
    );
  }
  
  Widget _buildQuestionForm(AskViewModel model) {
    return Column(
      children: [
        _buildAddImages(),
        SizedBox(height: 20,),
        _buildYarnField(),
        SizedBox(height: 20,),
        _buildTextFiled(),
        SizedBox(height: 20,),
        _buildTags(model),
        SizedBox(height: 20,),
        getCategoryField(),
        // SizedBox(height: 20,),
        // getAmountField(),
        // SizedBox(height: 20,),
        // _buildExpiresField(),
        SizedBox(height: 50,),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildAddImages() {
    return Container(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: selectedImages.length + 1,
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(right: 6),
          child: index != selectedImages.length
              ? showImage(index)
              : selectedImages.length != imageCount
              ? addImageButton()
              : null,
        ),
      ),
    );
  }

  Widget addImageButton() {
    return CustomBoxShadow(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: boxShadowTwo,
        margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  SlydoAppIcon.add_image,
                  color: darkGrey,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  AppLocalization.of(context)!.addImage,
                  style: TextStyle(color: darkGrey, fontSize: 14),
                ),
              ],
            ),
            onTap: () {
              pickImage();
            },
          ),
        ),
      ),
    );
  }

  Widget showImage(int index) {
    return Container(
      height: 100,
      child: Stack(
        children: <Widget>[
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: dividerColor,
            margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: FileImage(
                      File(selectedImages[index].path),
                    ),
                    fit: BoxFit.fill),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              padding: EdgeInsets.only(right: 6, top: 6),
              alignment: Alignment.topRight,
              icon: Container(
                padding: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: iconBtnGrey,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  SlydoAppIcon.remove,
                  color: blackFont,
                  size: 15,
                ),
              ),
              onPressed: () {
                setState(() {
                  selectedImages.removeAt(index);
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildYarnField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isYarn! ? 'Yarn' : 'Question',
          style: TextStyle(
            fontSize: 14,
            color: darkGrey,
          ),
        ),
        SizedBox(
          height: 7,
        ),
        TopicTextField(
          height: 140,
          controller: yarnController,
          hint: widget.isYarn! ? "Yarn Something" : 'Ask Something',
        ),
      ],
    );
  }

  Widget _buildTextFiled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text',
          style: TextStyle(
            fontSize: 14,
            color: darkGrey,
          ),
        ),
        SizedBox(
          height: 7,
        ),
        TopicTextField(
          height: 140,
          controller: textController,
        ),
      ],
    );
  }

  Widget _buildTags(AskViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: TextStyle(
            fontSize: 14,
            color: darkGrey,
          ),
        ),
        SizedBox(height: 7,),
        Focus(
          focusNode: textFieldTagFocusNode,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: blackFont.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: TextFieldTags(
              initialTags: userTags,
              tagsStyler: textFieldTagStyler,
              validator: (value) {
                return null;
              },
              textFieldStyler: TextFieldStyler(
                helperText: '',
                hintText: '',
                textFieldBorder: InputBorder.none,
              ),
              onTag: (tag) {
                setState(() {
                  model.userTags.add(tag);
                  model.userTags = model.userTags.toSet().toList();
                  userTags = model.userTags;
                });
                model.userTags.removeWhere((tag) => tag.isEmpty);
                userTags.removeWhere((tag) => tag.isEmpty);
              },
              onDelete: (tag) {
                setState(() {
                  model.userTags.remove(tag);
                  userTags.remove(tag);
                });
                model.userTags.removeWhere((tag) => tag.isEmpty);
                userTags.removeWhere((tag) => tag.isEmpty);
              },
            ),
          ),
        )
      ],
    );
  }

  Widget getCategoryField() {
    return CustomizedDropDownField(
      title: "Categories",
      borderWidth: 2.0,
      child: ListTile(
        dense: true,
        title: Text(
          selectedAskCategory != null ? selectedAskCategory!.name! : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          categoryAndroidSheet();
          // selectItemCategory();
        },
      ),
    );
  }

  // Widget getAmountField() {
  //   return CustomizedTextFormField(
  //     labelText: "Amount",
  //     keyboardType: Platform.isIOS
  //         ? TextInputType.numberWithOptions(decimal: true)
  //         : TextInputType.number,
  //     isAmountField: true,
  //     borderWidth: 2.0,
  //     onChanged: (val) {
  //       if (val.isNotEmpty) {
  //         try {
  //           // productPrice = double.parse(val.replaceAll(',', '')).toString();
  //         } catch (e) {
  //           showToast(message: e.toString());
  //         }
  //       }
  //     },
  //     validator: (val) {
  //       // if (val.isNotEmpty) {
  //       //   try {
  //       //     double.parse(val.replaceAll(',', ''));
  //       //     return null;
  //       //   } catch (e) {
  //       //     return AppLocalization.of(context)!.invalidAmount;
  //       //   }
  //       // }
  //       // return AppLocalization.of(context)!.pleaseEnterValidAmout;
  //     },
  //   );
  // }
  //
  // Widget _buildExpiresField() {
  //   return CustomizedDropDownField(
  //     title: "Expire",
  //     borderWidth: 2.0,
  //     child: ListTile(
  //       dense: true,
  //       title: Text(
  //         selectedAskCategory != null ? selectedAskCategory!.name! : "",
  //         style: TextStyle(
  //             color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
  //       ),
  //       trailing: Icon(
  //         Icons.keyboard_arrow_down,
  //         color: darkGrey,
  //       ),
  //       onTap: () {
  //         expiresAndroidSheet();
  //       },
  //     ),
  //   );
  // }

  Widget _buildSubmitButton() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24),
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 60),
      child: CurvedButton(
        height: 56,
        textColor: Colors.white,
        backgroundColor: navyBlue,
        text: "Submit",
        onPressed: () async {
          addYarnAndQuestion();
        },
      ),
    );
  }

  void pickImage() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalization.of(context)!.selectTheImageSource),
          actions: <Widget>[
            MaterialButton(
              child: Text(AppLocalization.of(context)!.camera),
              onPressed: () => Navigator.pop(context, ImageSource.camera),
            ),
            MaterialButton(
              child: Text(AppLocalization.of(context)!.gallery),
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
            )
          ],
        ));

    if (imageSource != null) {
      ImagePicker().pickImage(source: imageSource).then((value) async {
        if (value != null) {
          /// for cropping the image
          String? croppedImage = await ImageCrop().cropImage(value.path);
          if (croppedImage == null) {
            return;
          }

          selectedImages.add(PickedFile(croppedImage));
          if (mounted) setState(() {});
        }
      });
    }
  }

  void categoryAndroidSheet() {
    widget.askCategories = askCategoriesCopy;
    debugPrint("CATEGORIES:- ${widget.askCategories}");
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Search category',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      widget.askCategories = askCategoriesCopy!
                          .where((element) => element.name!
                          .toLowerCase()
                          .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                              () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      widget.askCategories = askCategoriesCopy;
                      changeState(() {});
                    }
                  },
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.askCategories!.length,
                    itemBuilder: (context, index) {
                      AskCategories category = widget.askCategories![index];
                      if (selectedAskCategory == category) {
                        return Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              category.name!,
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
                              pressedAskCategory = category;
                              Navigator.pop(context);
                              if (pressedAskCategory != null) {
                                selectedAskCategory = pressedAskCategory;
                                askCategory = selectedAskCategory!.name!;
                                setState(() {});
                              }
                            },
                          ),
                        );
                      }
                      return ListTile(
                        title: Text(
                          category.name!,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          pressedAskCategory = category;
                          Navigator.pop(context);
                          if (pressedAskCategory != null) {
                            selectedAskCategory = pressedAskCategory;
                            askCategory = selectedAskCategory!.name!;
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void expiresAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.17,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: expiresList.length,
              itemBuilder: (context, index) {
                // if (selectedAskCategory == category) {
                //   return Container(
                //     color: selectedListItemBackgroundBlue,
                //     child: ListTile(
                //       dense: true,
                //       title: Text(
                //         category.name!,
                //         overflow: TextOverflow.fade,
                //         softWrap: false,
                //         style: TextStyle(
                //             color: navyBlue,
                //             fontSize: 16,
                //             fontWeight: FontWeight.w600),
                //       ),
                //       trailing: Icon(
                //         SlydoAppIcon.checked,
                //         color: navyBlue,
                //         size: 12,
                //       ),
                //       onTap: () {
                //         pressedAskCategory = category;
                //         Navigator.pop(context);
                //         if (pressedAskCategory != null) {
                //           selectedAskCategory = pressedAskCategory;
                //           askCategory = selectedAskCategory!.name!;
                //           setState(() {});
                //         }
                //       },
                //     ),
                //   );
                // }
                return ListTile(
                  title: Text(
                    expiresList[index],
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        color: blackFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                  dense: true,
                  onTap: () {
                    // pressedAskCategory = category;
                    Navigator.pop(context);
                    // if (pressedAskCategory != null) {
                    //   selectedAskCategory = pressedAskCategory;
                    //   askCategory = selectedAskCategory!.name!;
                    //   setState(() {});
                    // }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> addYarnAndQuestion() async {
    AddYarnAndQuestion addYarnAndQuestion = AddYarnAndQuestion();
    addYarnAndQuestion.localImages = selectedImages.map((file) => File(file.path)).toList();
    addYarnAndQuestion.tags = userTags;
    addYarnAndQuestion.title = yarnController.text;
    addYarnAndQuestion.body = !widget.isYarn! ? textController.text : yarnController.text;
    addYarnAndQuestion.categoryId = selectedAskCategory!.id;
    addYarnAndQuestion.isQuestion = !widget.isYarn! ? true : false;
    addYarnAndQuestion.author = userBloc.user.userName;
    debugPrint("USER TAGS:- $userTags");
    debugPrint("USER TAGS:- ${addYarnAndQuestion.tags}");

    await AskAuth().addYarnAndQuestion(addYarnAndQuestion).then((value) {
      Navigator.pop(context);
      showToast(
          message: widget.isYarn! ? "Yarn add successfully" : "Question add successfully");
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });

  }

}

class TopicTextField extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool readOnly;
  final Widget leading;
  final double height;
  final Function()? function;
  final String? hint;
  final VoidCallback? onTap;
  final bool suffix;
  final Widget? suffixIcon;

  const TopicTextField({
    Key? key,
    required this.controller,
    this.hint,
    this.validator,
    this.height = 60,
    this.function,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.leading = const SizedBox(
      width: 0,
      height: 0,
    ),
    this.onTap,
    this.suffix = true,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: blackFont.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: TextFormField(
        textAlignVertical: TextAlignVertical.center,
        onEditingComplete: function,
        controller: controller,
        style: TextStyle(
          fontSize: 16,
          color: blackFont,
          fontWeight: FontWeight.w400,
        ),
        validator: validator,
        keyboardType: TextInputType.multiline,
        maxLines: 10,
        minLines: 1,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
          hintText: hint ?? '',
          hintStyle: const TextStyle(fontSize: 12),
          suffixIcon: suffixIcon ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
