import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/OpeningHour.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../../../utils/colors.dart';
import '../user_auth.dart';

class AddOrEditUserBioScreen extends StatefulWidget {
  @override
  _AddOrEditUserBioScreenState createState() => _AddOrEditUserBioScreenState();
}

class _AddOrEditUserBioScreenState extends State<AddOrEditUserBioScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, String>> openingHoursDays = [
    {"name": "Monday", "value": "mon"},
    {"name": "Tuesday", "value": "tue"},
    {"name": "Wednesday", "value": "wed"},
    {"name": "Thursday", "value": "thurs"},
    {"name": "Friday", "value": "fri"},
    {"name": "Saturday", "value": "sat"},
    {"name": "Sunday", "value": "sun"},
  ];

  /// {"day": {"name": "Monday", "value": "mon"},"starting_hour":"10:00 AM","closing_hour":"12:00 PM"}
  List<Map<String, dynamic>> userAddedOpeningHours = [];

  UserBloc userBloc;

  UserAbout userBioDetail;
  @override
  void initState() {
    userBioDetail = UserAbout();
    clearUserAddedOpeningHour();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: appBar(),
        body: scaffoldBody(),
      ),
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
        "Edit Bio",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10),
                addBioField(),
                SizedBox(
                  height: 10,
                ),
                addAddressField(),
                SizedBox(
                  height: 10,
                ),
                addContactNumberField(),
                SizedBox(
                  height: 10,
                ),
                addOpeningHour(),
                SizedBox(height: 20),
                getSubmitButton(),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showBackArrow() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget addAddressField() {
    return CustomizedTextFormField(
      labelText: "Address",
      maxLines: 3,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Invalid Address";
      },
      onChanged: (val) {
        userBioDetail.address = val;
      },
    );
  }

  Widget addBioField() {
    return CustomizedTextFormField(
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      labelText: "Bio",
      onChanged: (val) {
        userBioDetail.bio = val;
      },
    );
  }

  Widget addContactNumberField() {
    return CustomizedTextFormField(
      labelText: "Contact number",
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Invalid Contact number";
      },
      onChanged: (val) {
        userBioDetail.contact = val;
      },
    );
  }

  Widget addOpeningHour() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Opening hours",
              style: TextStyle(color: darkGrey, fontSize: 14),
            ),
            Row(
              children: [
                userAddedOpeningHours.length > 1
                    ? RoundedBackgroundIcon(
                        height: 28,
                        width: 28,
                        backgroundColor: mateRed,
                        icon: Icon(
                          SlydoAppIcon.delete,
                          color: Colors.white,
                          size: 12,
                        ),
                        onTap: () {
                          clearUserAddedOpeningHour();
                        })
                    : Container(),
                SizedBox(
                  width: userAddedOpeningHours.length > 1 ? 8 : 0,
                ),
                RoundedBackgroundIcon(
                    height: 28,
                    width: 28,
                    backgroundColor: iconBtnGrey,
                    icon: Icon(
                      SlydoAppIcon.add,
                      color: blackFont,
                      size: 12,
                    ),
                    onTap: () {
                      addOpeningHourItem();
                    }),
              ],
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        getOpeningHoursList()
      ],
    );
  }

  void addOpeningHourItem() {
    if (userAddedOpeningHours.length < 7) {
      Map<String, dynamic> newItem = {
        "day": openingHoursDays[userAddedOpeningHours.length],
        "starting_hour": "10:00 AM",
        "closing_hour": "6:00 PM"
      };
      userAddedOpeningHours.add(newItem);
      setState(() {});
    }
  }

  void clearUserAddedOpeningHour() {
    userAddedOpeningHours.clear();
    userAddedOpeningHours.add({
      "day": {"name": "Monday", "value": "mon"},
      "starting_hour": "10:00 AM",
      "closing_hour": "6:00 PM"
    });
    setState(() {});
  }

  Widget getOpeningHoursList() {
    return Container(
      child: Column(
        children: userAddedOpeningHours
            .map((element) => getOneOpeningHourTile(element))
            .toList(),
      ),
    );
  }

  Widget getOneOpeningHourTile(Map<String, dynamic> element) {
    return Container(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: getOpeningHourDay(element: element)),
          SizedBox(
            width: 10,
          ),
          getOpeningHourStartingTime(element: element),
          SizedBox(
            width: 10,
          ),
          getOpeningHourClosingTime(element: element)
        ],
      ),
    );
  }

  Widget getOpeningHourDay({Map<String, dynamic> element}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: greyBorderColor)),
      margin: EdgeInsets.all(0),
      borderOnForeground: true,
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
            alignedDropdown: true,
            child: ListTile(
              dense: true,
              title: Text(
                element["day"]["name"],
                style: TextStyle(
                    color: blackFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_down,
                color: darkGrey,
              ),
              onTap: () {
                selectDay(element: element);
              },
            )),
      ),
    );
  }

  Widget getOpeningHourStartingTime({Map<String, dynamic> element}) {
    return GestureDetector(
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: greyBorderColor)),
        margin: EdgeInsets.all(0),
        borderOnForeground: true,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Text("${element["starting_hour"]}"),
        ),
      ),
      onTap: () {
        selectTime(element: element);
      },
    );
  }

  Widget getOpeningHourClosingTime({Map<String, dynamic> element}) {
    return GestureDetector(
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: greyBorderColor)),
        margin: EdgeInsets.all(0),
        borderOnForeground: true,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Text("${element["closing_hour"]}"),
        ),
      ),
      onTap: () {
        selectTime(element: element, isOpening: false);
      },
    );
  }

  void selectDay({Map<String, dynamic> element}) async {
    final selectedDay = await showDialog<Map<String, String>>(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                        children: openingHoursDays.map<Widget>((day) {
                          return ListTile(
                            title: Text(
                              day["name"],
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, day);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (selectedDay != null) {
      Map<String, String> result = selectedDay;
      for (int i = 0; i < userAddedOpeningHours.length; i++) {
        if (element == userAddedOpeningHours[i]) {
          userAddedOpeningHours[i]["day"] = result;
          break;
        }
      }

      setState(() {});
    }
  }

  void selectTime({Map<String, dynamic> element, bool isOpening = true}) async {
    TimeOfDay selectedTimeRTL = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: navyBlue,
            accentColor: navyBlue,
            colorScheme: ColorScheme.light(primary: navyBlue),
            backgroundColor: Colors.white,
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: iconBtnGrey,
              dialBackgroundColor: iconBtnGrey,
              dayPeriodBorderSide: BorderSide(color: dividerColor),
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child,
          ),
        );
      },
    );

    if (selectedTimeRTL != null) {
      for (int i = 0; i < userAddedOpeningHours.length; i++) {
        if (element == userAddedOpeningHours[i]) {
          if (isOpening) {
            userAddedOpeningHours[i]["starting_hour"] =
                selectedTimeRTL.format(context);
          } else {
            userAddedOpeningHours[i]["closing_hour"] =
                selectedTimeRTL.format(context);
          }
          break;
        }
      }
      setState(() {});
    }
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () async {
        FocusScope.of(context).unfocus();
        updateBio();
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Update Bio",
    );
  }

  void updateBio() {
    if (_formKey.currentState.validate()) {
      addOpeningHourToUserAboutObject();

      UserAuth().addOrUpdateUserBio(userBioDetail).then((value) {
        Navigator.pop(context);
        Toast.show(
          "Bio updated successfully!!",
          context,
          textColor: Colors.white,
          duration: 3,
        );
      }).catchError((error) {
        debugPrint(error.toString());
        Toast.show(error.toString(), context, textColor: Colors.white);
      });
    }
  }

  void addOpeningHourToUserAboutObject() {
    userAddedOpeningHours.forEach((element) {
      OpeningHour openingHour = OpeningHour();

      openingHour.day = element["day"]["value"];
      openingHour.time =
          "${element["starting_hour"]} - ${element["closing_hour"]}";
      if (userBioDetail.openingHours == null) {
        userBioDetail.openingHours = [openingHour];
      } else {
        userBioDetail.openingHours.add(openingHour);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
