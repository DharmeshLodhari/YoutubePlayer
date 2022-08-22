import 'package:Slydo/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../../utils/util.dart';
import '../../../widget/curved_btn.dart';
import 'ask_viewmodel.dart';

class AddTopicScreen extends StatefulWidget {

  @override
  State<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final topicTitleController = TextEditingController();

  final topicTextController = TextEditingController();
  late FocusNode textFieldTagFocusNode;

  @override
  void initState(){
    textFieldTagFocusNode = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              'Add Topic',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: blackFont,
              ),
            ),
          ],
        ),
        elevation: 0,
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
      ),
      body: Consumer<AskViewModel>(
          builder: (context, model, child) {
          return SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Topic/Questions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: blackFont,
                        ),
                      ),
                      SizedBox(height: 7,),
                      TopicTextField(
                        controller: topicTextController,
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Text',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: blackFont,
                        ),
                      ),
                      SizedBox(height: 7,),
                      TopicTextField(
                        height: 140,
                        controller: topicTitleController,
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Focus(
                    focusNode: textFieldTagFocusNode,
                    child: TextFieldTags(
                      initialTags: model.userTags,
                      tagsStyler: textFieldTagStyler,
                      validator: (value) {
                        return null;
                      },
                      textFieldStyler: textFieldStyler,
                      onTag: (tag) {
                        setState(() {
                          model.userTags.add(tag);
                          model.userTags = model.userTags.toSet().toList();
                        });
                        model.userTags.removeWhere((tag) => tag.isEmpty);
                      },
                      onDelete: (tag) {
                        setState(() {
                          model.userTags.remove(tag);
                        });
                        model.userTags.removeWhere((tag) => tag.isEmpty);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: navyBlueLight.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(children: [
                        Text(
                          'Import Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: blackFont,
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                            color: navyBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                            child: Text(
                              'Choose file',
                              style: TextStyle(
                                color: navyBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          'Image should not be more than 2mb',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: blackFont.withOpacity(0.3),
                          ),
                        ),
                        SizedBox(height: 10,)
                      ],),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Expanded(child: SizedBox(height: 10,)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context)
                                .size
                                .width - 60),
                        child: CurvedButton(
                          height: 56,
                          textColor: Colors.white,
                          backgroundColor: navyBlue,
                          text: "Submit",
                          onPressed: () async {

                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 170,)
                ],),
              ),
            ),
          );
        }
      ),
    );
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
      height: height ?? 50,
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
