import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/state_notifier.dart';
import '../../../utils/slydo_app_icon_icons.dart';
import '../../../utils/util.dart';
import '../../../widget/curved_btn.dart';
import '../../../widget/customized_dropdown_field.dart';
import '../../../widget/customized_textform_field.dart';
import 'yarn_auth.dart';
import 'yarn_dashboard_bloc.dart';

class AddReportScreen extends StatefulWidget {
  Map<String, dynamic>? object;
  String? type;
  bool? isCommentMoment;
  bool? isJobService;
  AddReportScreen({
    this.object,
    this.type,
    this.isCommentMoment,
    this.isJobService,
  });

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final textController = TextEditingController();
  late FocusNode textFieldTagFocusNode;
  // ScrollController _scrollController = ScrollController();
  int imageCount = 5;
  late UserBloc userBloc;
  List<ViolationType> violationTypeCopy = [];
  List<ViolationType> violationTypes = [];
  ViolationType? selectedViolationType;
  ViolationType? pressedViolationType;

  @override
  void initState() {
    Future.microtask(() => context.read<YarnDashboardBloc>().init());
    textFieldTagFocusNode = FocusNode();
    violationTypes = violationType;
    violationTypeCopy = violationTypes;
    log('object......${widget.object.toString()}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Consumer<YarnDashboardBloc>(builder: (context, model, child) {
        return ListView(
          padding: EdgeInsets.all(15),
          children: [_buildYarnOrQuestionForm(model)],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Report",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: blackFont,
          ),
        ),
        elevation: 0,
        titleSpacing: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.black,
            size: 26,
          ),
        )
        // IconButton(
        //   icon: Icon(
        //     Icons.keyboard_arrow_left,
        //     color: navyBlue,
        //     size: 26,
        //   ),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
        );
  }

  Widget _buildYarnOrQuestionForm(YarnDashboardBloc model) {
    return _buildYarnForm(model);
  }

  Widget _buildYarnForm(YarnDashboardBloc model) {
    return Column(
      children: [
        _buildInfoText(),
        SizedBox(
          height: 25,
        ),
        getCategoryField(),
        SizedBox(
          height: 25,
        ),
        _buildTextFiled(),
        SizedBox(
          height: 30,
        ),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: HexColor("#FFE3AB")),
      child: Text(
        "Do you think this is an inappropriate content? Please let us know!",
        style: TextStyle(fontSize: 14, color: HexColor("#553C08")),
      ),
    );
  }

  Widget _buildTextFiled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us more (Optional)',
          style: TextStyle(
              fontSize: 14, color: blackFont, fontWeight: FontWeight.w600),
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

  Widget getCategoryField() {
    return CustomizedDropDownField(
      title: "Reason",
      titleColor: blackFont,
      fontWeight: FontWeight.w600,
      borderWidth: 2.0,
      child: ListTile(
        dense: true,
        title: Text(
          selectedViolationType != null ? selectedViolationType!.type! : "",
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

  Widget _buildSubmitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          alignment: Alignment.center,
          child: OutlineCurvedButton(
            width: MediaQuery.of(context).size.width - 230,
            textColor: navyBlue,
            text: "Cancel",
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: CurvedButton(
            width: MediaQuery.of(context).size.width - 230,
            textColor: Colors.white,
            backgroundColor: navyBlue,
            text: "Submit",
            onPressed: () async {
              if (selectedViolationType == null) {
                showToast(message: "Selected reason to proceed");
              } else {
               if(widget.isJobService == true){
                reportJob();
               }
                else if (widget.isCommentMoment == false) {
                  addReport();
                } 
                else {
                  reportCommentInMoment();
                }
              }
            },
          ),
        ),
      ],
    );
  }

  void categoryAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Search Reason',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      violationTypes = violationTypeCopy
                          .where((element) => element.type!
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      violationTypes = violationTypeCopy;
                      changeState(() {});
                    }
                  },
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: violationTypes.length,
                    itemBuilder: (context, index) {
                      ViolationType selectViolation = violationTypes[index];
                      if (selectedViolationType == selectViolation) {
                        return Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              selectViolation.type ?? "",
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
                              pressedViolationType = selectViolation;
                              Navigator.pop(context);
                              if (pressedViolationType != null) {
                                selectedViolationType = pressedViolationType;
                                setState(() {});
                              }
                            },
                          ),
                        );
                      }
                      return ListTile(
                        title: Text(
                          selectViolation.type ?? "",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          pressedViolationType = selectViolation;
                          Navigator.pop(context);
                          if (pressedViolationType != null) {
                            selectedViolationType = pressedViolationType;
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

  Future<void> reportCommentInMoment() async {
    Map<String, dynamic> data = {
      "object": widget.object,
      "type": widget.type,
      "violation_type": selectedViolationType!.id,
      "reported_by": userBloc.user.userName,
      "report": messageDecoderWithEmoji(textController.text)
    };
    await YarnAuth()
        .reportCommentMoment(
      widget.object!['id'],
      data,
    )
        .then((value) {
      if (value != null) {
        if (value == true) {
          Navigator.pop(context);
          showToast(message: "Reported Successfully");
        }
      } else {
        showToast(message: 'Server error, report failed');
      }
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  Future<void> addReport() async {
    Map<String, dynamic> data = {
      "object": widget.object,
      "type": widget.type,
      "violation_type": selectedViolationType!.id,
      "reported_by": userBloc.user.userName,
      "report": messageDecoderWithEmoji(textController.text)
    };
    await YarnAuth()
        .addReport(
      widget.object!['id'],
      data,
    )
        .then((value) {
      if (value != null) {
        if (value == true) {
          Navigator.pop(context);
          showToast(message: "Reported Successfully");
        }
      } else {
        showToast(message: 'Server error, report failed');
      }
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  Future<void> reportJob() async {
    Map<String, dynamic> data = {
      "object": widget.object,
      "type": widget.type,
      "violation_type": selectedViolationType!.id,
      "reported_by": userBloc.user.userName,
      "report": messageDecoderWithEmoji(textController.text)
    };
    await YarnAuth()
        .reportJob(
      data
    )
        .then((value) {
      if (value != null) {
        if (value == true) {
          Navigator.pop(context);
          showToast(message: "Reported Successfully");
        }
      } else {
        showToast(message: 'Server error, report failed');
      }
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
