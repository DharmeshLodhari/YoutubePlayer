import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/VirtualAccount.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../widget/customized_dropdown_field.dart';

// ignore: must_be_immutable
class AddBvnNumber extends StatefulWidget {
  final dynamic arguments;

  AddBvnNumber({this.arguments});

  @override
  _AddBvnNumberState createState() => _AddBvnNumberState();
}

class _AddBvnNumberState extends State<AddBvnNumber> {
  final _formKeyTwo = GlobalKey<FormState>();

  TextEditingController? bvnNumberController;

  Map<String, String>? selectedIdType;

  List<Map<String, String>> idTypes = [
    {"name": "Nigerian Passport", "value": "passport"},
    {"name": "NIN slip", "value": "nin_slip"},
    {"name": "Driver's License", "value": "driving_license"},
  ];

  String? pickedGovernmentId;
  String? pickedBusinessRegistrationLicense;

  VirtualAccount? virtualAccount;
  String? selectedTier;

  String? gender;
  bool? isValidAge;
  DateTime dob = DateTime.now();
  List<String> genders = ["Male", "Female"];

  @override
  void initState() {
    bvnNumberController = TextEditingController();
    if (widget.arguments != null) {
      if (widget.arguments["account"] != null) {
        virtualAccount = widget.arguments["account"];
      }
      if (widget.arguments["selected_tier"] != null) {
        selectedTier = widget.arguments["selected_tier"]
            .toString()
            .replaceAll("Tier ", "");
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
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
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      centerTitle: false,
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
        "Add BVN number",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Form(
          key: _formKeyTwo,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildBvnNumberDropDown(),
              buildDobField(),
              getGenderField(),
              buildGetIdType(),
              buildBusinessRegistrationLicense(),
              getVerificationWarning(),
              const SizedBox(height: 16),
              getSubmitButton(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDobField() {
    return Column(
      children: [
        getDOBField(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget getDOBField() {
    return GestureDetector(
      onTap: () {
        showDatePicker(
          builder: customThemeBuilder,
          context: context,
          initialDate: DateTime(dob.year, dob.month, dob.day),
          firstDate: DateTime(1920, 0, 1),
          lastDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
        ).then((value) {
          dob = DateTime(value!.year, value.month, value.day);
          setState(() {});
          validateDOB();
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "Birthdate",
        child: Container(
          child: ListTile(
            dense: true,
            title: Text(
              formatDate(dob),
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
      ),
    );
  }

  bool validateDOB() {
    final DateTime dateTime = DateTime.now();

    if (dob.add(const Duration(days: 4745)).isBefore(dateTime)) {
      isValidAge = true;
      return true;
    } else {
      isValidAge = false;
      setState(() {});
      return false;
    }
  }

  Widget getGenderField() {
    return Column(
      children: [
        CustomizedDropDownField(
          title: "Gender",
          child: ListTile(
            dense: true,
            title: Text(
              gender != null ? gender! : "",
              style: TextStyle(
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: darkGrey,
            ),
            onTap: () {
              selectGenderField();
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void selectGenderField() async {
    final pressedGender = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: genders.map<Widget>((data) {
                          if (gender == data) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  data,
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
                                  Navigator.pop(context, data);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              data,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, data);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedGender != null) {
      gender = pressedGender;
      setState(() {});
    }
  }

  Widget showBvnForm() {
    return Container();
  }

  Widget buildBvnNumberDropDown() {
    if ((selectedTier == "2" || selectedTier == "3") &&
        virtualAccount!.accountTier!.tierType! == "1") {
      return Column(
        children: [
          addBvnNumberTextField(),
          const SizedBox(height: 16),
        ],
      );
    }
    return Container();
  }

  Widget buildGetIdType() {
    if (selectedTier == "3" &&
        (virtualAccount!.accountTier!.tierType! == "2" ||
            virtualAccount!.accountTier!.tierType! == "1")) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getIdTypeDropDown(),
          const SizedBox(
            height: 16,
          ),
          Text(
            "Identification",
            style: TextStyle(color: darkGrey, fontSize: 14),
          ),
          getIdPhoto(),
          const SizedBox(
            height: 16,
          ),
        ],
      );
    }
    return Container();
  }

  Widget buildBusinessRegistrationLicense() {
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    if (selectedTier == "3" &&
        virtualAccount!.accountTier!.tierType! == "1" &&
        userBloc.user.type != "user") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Business registration license",
            style: TextStyle(color: darkGrey, fontSize: 14),
          ),
          getBusinessRegistrationLicense(),
          const SizedBox(height: 16),
        ],
      );
    }
    return Container();
  }

  Widget showBackArrow() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget getVerificationWarning() {
    if ((selectedTier == "3" || selectedTier == "2") &&
        (virtualAccount!.accountTier!.tierType! == "2" ||
            virtualAccount!.accountTier!.tierType! == "1")) {
      return const SizedBox.shrink();
    }

    return Text(
      "It may take up to 48 hours to verify user details.",
      textAlign: TextAlign.center,
      style:
          TextStyle(color: navyBlue, fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget getSubmitButton() {
    if ((selectedTier == "3" || selectedTier == "2") &&
        (virtualAccount!.accountTier!.tierType! == "2" ||
            virtualAccount!.accountTier!.tierType! == "1")) {
      return CurvedButton(
        onPressed: onSubmit,
        backgroundColor: navyBlue,
        textColor: Colors.white,
        text: "SUBMIT",
      );
    }
    return const SizedBox.shrink();
  }

  void onSubmit() async {
    //for closing the keypad if it is open
    FocusScope.of(context).unfocus();

    if (_formKeyTwo.currentState!.validate() && selectedIdType != null) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularLoadingIndicator()));

      var data;

      if (selectedTier == "2") {
        data = {
          "bvn_number": bvnNumberController!.text,
          "gender": gender,
          'dob': dob,
        };
      } else {
        data = {
          "bvn_number": bvnNumberController!.text,
          "government_id_type": selectedIdType!["value"],
          "government_id": pickedGovernmentId ?? "",
          "business_registration_license":
              pickedBusinessRegistrationLicense ?? "",
          "tier": selectedTier,
        };
      }

      PaymentAndBankingAuth().addBvnNumberAndIdProof(data).then((value) {
        if (value) {
          showToast(message: 'Account upgraded');

          Navigator.pop(context);
          Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
        }
      }).catchError((e) {
        Navigator.pop(context);
        debugPrint(e.toString());
        showToast(message: e);
      });
    } else {
      showToast(message: 'All fields must be filled correctly');
    }
  }

  Widget addBvnNumberTextField() {
    return CustomizedTextFormField(
      controller: bvnNumberController,
      hintText: "Enter BVN Number",
      labelText: "BVN Number",
      maxLength: 11,
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val.toString().length == 11) {
          return null;
        }
        return "Invalid BVN number";
      },
    );
  }

  Widget getIdPhoto() {
    return CustomBoxShadow(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: boxShadowTwo,
        margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Container(
          width: MediaQuery.of(context).size.width - 32,
          // height: MediaQuery.of(context).size.width - 32,
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.width / 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              child: pickedGovernmentId != null
                  ? Image.file(
                      File(pickedGovernmentId!),
                      fit: BoxFit.fitWidth,
                      height: MediaQuery.of(context).size.width / 3,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          SlydoAppIcon.add_image,
                          color: darkGrey,
                          size: 55,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          "Upload identification",
                          style: TextStyle(color: darkGrey, fontSize: 14),
                        ),
                      ],
                    ),
              onTap: () {
                pickIdImage();
              },
            ),
          ),
        ),
      ),
    );
  }

  void pickIdImage() async {
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
          final String? croppedImage = await ImageCrop().cropImage(value.path);
          if (croppedImage == null) {
            return;
          }
          if (mounted) setState(() {});

          pickedGovernmentId = croppedImage;
        }
      });
    }
  }

  Widget getBusinessRegistrationLicense() {
    return CustomBoxShadow(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: boxShadowTwo,
        margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Container(
          width: MediaQuery.of(context).size.width - 32,
          // height: MediaQuery.of(context).size.width - 32,
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.width / 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              child: pickedBusinessRegistrationLicense != null
                  ? Image.file(
                      File(pickedBusinessRegistrationLicense!),
                      fit: BoxFit.fitWidth,
                      height: MediaQuery.of(context).size.width / 3,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(SlydoAppIcon.add_image, color: darkGrey, size: 55),
                        const SizedBox(height: 16),
                        Text(
                          "Upload license",
                          style: TextStyle(color: darkGrey, fontSize: 14),
                        ),
                      ],
                    ),
              onTap: () {
                pickBusinessProof();
              },
            ),
          ),
        ),
      ),
    );
  }

  void pickBusinessProof() async {
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
          final String? croppedImage = await ImageCrop().cropImage(value.path);
          if (croppedImage == null) {
            return;
          }
          if (mounted) setState(() {});

          pickedBusinessRegistrationLicense = croppedImage;
        }
      });
    }
  }

  Widget getIdTypeDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Government Id type",
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        const SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: const EdgeInsets.all(0),
          borderOnForeground: true,
          child: ListTile(
            dense: true,
            title: Text(
              selectedIdType != null ? selectedIdType!["name"]! : "",
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: darkGrey,
            ),
            onTap: () {
              selectIdType();
            },
          ),
        ),
      ],
    );
  }

  void selectIdType() async {
    final pressedIdType = await showDialog<Map<String, String>>(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Container(
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
                        children: idTypes.map<Widget>((idType) {
                          if (selectedIdType == null ||
                              selectedIdType!["name"] != idType["name"]) {
                            return ListTile(
                              title: Text(
                                idType["name"]!,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                    color: blackFont,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                              dense: true,
                              onTap: () {
                                Navigator.pop(context, idType);
                              },
                            );
                          }

                          return Container(
                            color: selectedListItemBackgroundBlue,
                            child: ListTile(
                              dense: true,
                              title: Text(
                                idType["name"]!,
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
                                Navigator.pop(context, idType);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedIdType != null) {
      selectedIdType = pressedIdType;
      debugPrint("selected Id $selectedIdType");
      setState(() {});
    }
  }

  Widget userTopUpNote() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Please tick the box below after you have transferred payment.",
        style: TextStyle(
            fontSize: 12, color: mateRed, fontWeight: FontWeight.w600),
      ),
    );
  }
}
