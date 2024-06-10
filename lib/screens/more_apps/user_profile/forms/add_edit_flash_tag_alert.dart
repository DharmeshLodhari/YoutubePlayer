import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/flash_tags/flash_tag_alert_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

class AddEditFlashTagAlert extends StatefulWidget {
  AddEditFlashTagAlert({Key? key, required this.user, this.flashTagAlertModel})
      : super(key: key);

  final CustomerProfile user;

  final FlashTagAlertModel? flashTagAlertModel;

  @override
  _AddEditFlashTagAlertState createState() => _AddEditFlashTagAlertState();
}

class _AddEditFlashTagAlertState extends State<AddEditFlashTagAlert> {
  final _formKey = GlobalKey<FormState>();

  List<FlashTagCategory> flashTagCategory = [
    FlashTagCategory("Crawling Text"),
    FlashTagCategory("Pop-up")
  ];

  DateTime? startFrom;
  DateTime? endFrom;
  bool isAPILoading = false;

  bool isDeleteLoading = false;

  late FlashTagAlertModel flashTagAlertModel;
  bool isEdit = false;

  @override
  void initState() {
    if (widget.flashTagAlertModel != null) {
      isEdit = true;
    }
    flashTagAlertModel =
        widget.flashTagAlertModel?.copyWith() ?? FlashTagAlertModel();

    flashTagAlertModel.merchant ??= widget.user.userName ?? "";
    startFrom = flashTagAlertModel.startDate;
    endFrom = flashTagAlertModel.endDate;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0.5,
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
        "Flash Tag",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      shadowColor: greySecondaryYarn,
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                addTitleField(),
                const SizedBox(
                  height: 16,
                ),
                flashTagDescription(),
                const SizedBox(
                  height: 16,
                ),
                flashTagType(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: startDate()),
                    const SizedBox(width: 16),
                    Expanded(child: endDate())
                  ],
                ),
                const SizedBox(height: 16),
                toggleActiveTag(),
                const SizedBox(height: 56),
                getSubmitButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showBackArrow() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget addTitleField() {
    return CustomizedTextFormField(
      labelText: "Flash Name",
      initialValue: flashTagAlertModel.title ?? "",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
        flashTagAlertModel.title = val;
      },
    );
  }

  Widget flashTagType() {
    return CustomizedDropDownField(
      title: "Flash Type",
      child: ListTile(
        dense: true,
        title: Text(
          flashTagAlertModel.type?.toString() ?? "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          selectItemCategory();
        },
      ),
    );
  }

  void selectItemCategory() async {
    final pressedCategory = await showDialog<FlashTagCategory>(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: SizedBox(
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
                        children: flashTagCategory.map<Widget>((category) {
                          if (flashTagAlertModel.type?.toString() ==
                              category.toString()) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  category.toString(),
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
                                  Navigator.pop(context, category);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              category.toString(),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, category);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCategory != null) {
      flashTagAlertModel.type = pressedCategory;
      setState(() {});
    }
  }

  Widget flashTagDescription() {
    return CustomizedTextFormField(
      labelText: "Flash Description",
      maxLines: 2,
      initialValue: flashTagAlertModel.message ?? "",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
        flashTagAlertModel.message = val;
      },
    );
  }

  Widget getSubmitButton() {
    if (isEdit) {
      return Row(
        children: [
          Expanded(
            child: CurvedButton(
              onPressed: isDeleteLoading
                  ? () {}
                  : () {
                      FocusScope.of(context).unfocus();
                      deleteFlashTagDialog();
                    },
              backgroundColor: red,
              textColor: Colors.white,
              text: "Delete",
              isLoading: isDeleteLoading,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: CurvedButton(
              onPressed: isAPILoading
                  ? () {}
                  : () async {
                      FocusScope.of(context).unfocus();
                      isAPILoading = true;
                      if (mounted) setState(() {});

                      await addEditItem();

                      isAPILoading = false;
                      if (mounted) setState(() {});
                    },
              backgroundColor: navyBlue,
              textColor: Colors.white,
              text: "Update",
              isLoading: isAPILoading,
            ),
          )
        ],
      );
    }

    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              FocusScope.of(context).unfocus();
              isAPILoading = true;
              if (mounted) setState(() {});

              await addEditItem();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Save",
      isLoading: isAPILoading,
    );
  }

  void deleteFlashTagDialog() {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: mateRed,
      title: 'Delete Flashtag',
      actionOneText: AppLocalization.of(context)!.discard,
      actionTwoText: AppLocalization.of(context)!.continueMsg,
      description: 'Are you sure you want to delete this flashtag?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () async {
        isDeleteLoading = true;
        if (mounted) setState(() {});

        await deleteItem();

        isDeleteLoading = false;
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> addEditItem() async {
    if (_formKey.currentState?.validate() ?? false) {
      //the api call will first create the product then use the id from the
      //response to save the variant

      await ShoppingAuthService()
          .addUpdateFlashTag(flashTagAlertModel, isEdit: isEdit)
          .then((value) async {
        Navigator.pop(context, true);
        showToast(
          message: isEdit
              ? "Flash Tag updated successfully"
              : "Flash Tag added successfully",
        );
      }).catchError((error) {
        debugPrint("Product check::: ${error.toString()}");
        showToast(message: error.toString());
      });
    } else {
      showToast(message: "Please fill all the details");
    }
  }

  Future<void> deleteItem() async {
    await ShoppingAuthService()
        .deleteFlashTag(flashTagAlertModel.id!)
        .then((value) async {
      Navigator.pop(context, true);
      showToast(
        message: "Flash Tag deleted successfully",
      );
    }).catchError((error) {
      debugPrint("Product check::: ${error.toString()}");
      showToast(message: error.toString());
    });
  }

  Widget toggleActiveTag() {
    return Row(
      children: [
        Switch(
          onChanged: (value) {
            flashTagAlertModel.isActive = !flashTagAlertModel.isActive;
            setState(() {});
          },
          value: flashTagAlertModel.isActive,
          activeColor: Theme.of(context).primaryColor,
        ),
        Text(
          "Toggle to activate this tag",
          style: TextStyle(
              fontSize: 14, color: blackFont, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget startDate() {
    return GestureDetector(
      onTap: () {
        showDatePicker(
          builder: customThemeBuilder,
          context: context,
          initialDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          firstDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          lastDate: DateTime(2101),
        ).then((value) {
          startFrom = DateTime(value!.year, value.month, value.day);
          flashTagAlertModel.startDate = startFrom;
          setState(() {});
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "Start Date",
        child: ListTile(
          dense: true,
          title: Text(
            startFrom != null ? formatDate(startFrom) : "",
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          trailing: Icon(
            SlydoAppIcon.date,
            size: 16,
            color: darkGrey,
          ),
        ),
      ),
    );
  }

  Widget endDate() {
    return GestureDetector(
      onTap: () {
        showDatePicker(
          builder: customThemeBuilder,
          context: context,
          initialDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          firstDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          lastDate: DateTime(2101),
        ).then((value) {
          endFrom = DateTime(value!.year, value.month, value.day);
          flashTagAlertModel.endDate = endFrom;
          setState(() {});
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "End Date",
        child: ListTile(
          dense: true,
          title: Text(
            endFrom != null ? formatDate(endFrom) : "",
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          trailing: Icon(
            SlydoAppIcon.date,
            size: 16,
            color: darkGrey,
          ),
        ),
      ),
    );
  }
}
