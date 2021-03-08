import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/OpeningHour.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../../../utils/colors.dart';
import '../user_auth.dart';

// ignore: must_be_immutable
class AddOrEditUserBioScreen extends StatefulWidget {
  @override
  _AddOrEditUserBioScreenState createState() => _AddOrEditUserBioScreenState();
}

class _AddOrEditUserBioScreenState extends State<AddOrEditUserBioScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController bioController;
  TextEditingController addressController;
  TextEditingController contactNumberController;

  List<String> openingHoursDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  /// {"day": {"name": "Monday", "value": "mon"},"starting_hour":"10:00 AM","closing_hour":"12:00 PM"}
  List<Map<String, dynamic>> userAddedOpeningHours = [];

  UserBloc userBloc;

  UserAbout userBioDetail;

  bool isSearchedUserAboutLoading;

  bool isLoading = false;

  @override
  void initState() {
    bioController = TextEditingController();
    addressController = TextEditingController();
    contactNumberController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      userBioDetail = userBloc.userAbout;
      bioController.text = userBioDetail.bio;
      addressController.text = userBioDetail.address;
      contactNumberController.text = userBioDetail.contact;
      if (userBioDetail.openingHours.isEmpty) {
        clearUserAddedOpeningHour();
      } else {
        addUserAddedOpeningHour();
      }
    });

    super.initState();
  }

  void addUserAddedOpeningHour() {
    userBioDetail.openingHours.forEach((element) {
      String time = element.time.trim();
      List<String> openingAndClosingTime = time.split("-");
      userAddedOpeningHours.add({
        "day": element.day,
        "starting_hour": openingAndClosingTime[0].trim(),
        "closing_hour": openingAndClosingTime[1].trim()
      });
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
              return [getAppbar(context)];
            },
            body: scaffoldBody(),
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
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

  Widget getAppbar(var context) {
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverSafeArea(
        top: false,
        bottom: false,
        sliver: SliverAppBar(
          forceElevated: false,
          expandedHeight: 250,
          elevation: 0,
          stretch: true,
          pinned: true,
          floating: true,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            editProfileCoverIcon(),
            SizedBox(
              width: 16,
            )
          ],
          title: Container(
            child: Text(
              userBloc.user.fullName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          titleSpacing: 0,
          backgroundColor: navyBlue,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: <StretchMode>[
              StretchMode.zoomBackground,
              StretchMode.blurBackground
            ],
            background: isLoading
                ? SizedBox.shrink()
                : Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      SizedBox.expand(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top),
                          height: 30,
                          color: Colors.white,
                        ),
                      ),
                      // Container(height: 50, color: Colors.black),

                      /// Banner image
                      getProfileCover(),

                      /// UserModel avatar, message icon, profile edit
                      getProfilePhoto(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget getProfileCover() {
    return Container(
      height: 206,
      child: userBloc.userAbout == null
          ? Image.asset(
              "assets/images/home_screen_background.png",
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : userBloc.userAbout.wallpaper == ""
              ? Image.asset(
                  "assets/images/home_screen_background.png",
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  width: double.infinity,
                  height: double.infinity,
                  imageUrl: userBloc.userAbout.wallpaper,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularLoadingIndicator()),
                  color: blackFont.withOpacity(0.4),
                  colorBlendMode: BlendMode.darken,
                  filterQuality: FilterQuality.high,
                ),
    );
  }

  Widget getProfilePhoto() {
    Color borderColor = getUserTypeColorByType(type: userBloc.user.type);

    return Container(
      alignment: Alignment.bottomLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 3),
                    shape: BoxShape.circle),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    color: Colors.white,
                    child: CachedNetworkImage(
                      height: 88,
                      width: 88,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                      imageUrl: userBloc.user.avatar,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  child: ClipOval(
                    child: Container(
                      color: Colors.white,
                      width: 32,
                      height: 32,
                      child: Icon(
                        Icons.camera_alt,
                        size: 18,
                      ),
                    ),
                  ),
                  onTap: () {
                    updateProfilePicture();
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void updateProfilePicture() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text(
                AppLocalization.of(context).selectTheImageSource,
                style: TextStyle(fontSize: 18, color: blackFont),
              ),
              actions: <Widget>[
                MaterialButton(
                  child: Text(
                    AppLocalization.of(context).camera,
                    style: TextStyle(fontSize: 16, color: blackFont),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text(
                    "Gallery",
                    style: TextStyle(fontSize: 16, color: blackFont),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      final file =
          await ImagePicker().getImage(source: imageSource, imageQuality: 70);
      if (file != null) {
        try {
          isLoading = true;
          if (mounted) setState(() {});
          // Get user current login info so we can reuse it to login
          var dbUser = await UserAuth().getUser();
          var phoneNumber = dbUser.phoneNumber;
          var password = dbUser.password;

          // Upload Image new image
          await UserAuth().updateCustomerAvatar(File(file.path));

          // Get New updated user data and set new user data to userBloc
          await UserAuth().authenticate(phoneNumber, password).then((value) {
            userBloc.user = value;
            isLoading = false;
            if (mounted) setState(() {});
          });
        } catch (err) {
          isLoading = false;
          if (mounted) setState(() {});
          Toast.show(err.toString(), context,
              backgroundColor: blackFont, textColor: Colors.white);
          debugPrint("Cannot Update Avatar : " + err.toString());
        }
      }
    }
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
      controller: addressController,
      labelText: "Address",
      maxLines: 3,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Invalid Address";
      },
    );
  }

  Widget addBioField() {
    return CustomizedTextFormField(
      controller: bioController,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      labelText: "Bio",
    );
  }

  Widget addContactNumberField() {
    return CustomizedTextFormField(
      controller: contactNumberController,
      labelText: "Contact number",
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Invalid Contact number";
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
                          Icons.remove,
                          color: Colors.white,
                          size: 22,
                        ),
                        onTap: () {
                          removeLastUserAddedOpeningHour();
                        })
                    : Container(),
                SizedBox(
                  width: userAddedOpeningHours.length > 1 ? 8 : 0,
                ),
                RoundedBackgroundIcon(
                    height: 28,
                    width: 28,
                    backgroundColor: naturalGreen,
                    icon: Icon(
                      SlydoAppIcon.add,
                      color: Colors.white,
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
      "day": "Monday",
      "starting_hour": "10:00 AM",
      "closing_hour": "6:00 PM"
    });
    if (mounted) setState(() {});
  }

  void removeLastUserAddedOpeningHour() {
    if (userAddedOpeningHours.length > 1) {
      userAddedOpeningHours.removeLast();
      if (mounted) setState(() {});
    }
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
                element["day"],
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
    final selectedDay = await showDialog<String>(
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
                              day,
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
      for (int i = 0; i < userAddedOpeningHours.length; i++) {
        if (element == userAddedOpeningHours[i]) {
          userAddedOpeningHours[i]["day"] = selectedDay;
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

  Widget editProfileCoverIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.image,
        size: 16,
        color: Colors.white,
      ),
      onTap: () {
        pickImage();
      },
      backgroundColor: lightGrey.withOpacity(0.1),
      enableMargin: true,
    );
  }

  void pickImage() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text(
                AppLocalization.of(context).selectTheImageSource,
                style: TextStyle(fontSize: 18, color: blackFont),
              ),
              actions: <Widget>[
                MaterialButton(
                  child: Text(
                    AppLocalization.of(context).camera,
                    style: TextStyle(fontSize: 16, color: blackFont),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text(
                    "Gallery",
                    style: TextStyle(fontSize: 16, color: blackFont),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      final file =
          await ImagePicker().getImage(source: imageSource, imageQuality: 70);
      if (file != null) {
        try {
          isSearchedUserAboutLoading = true;
          if (mounted) setState(() {});

          UserAbout userAbout = userBloc.userAbout;

          userAbout.wallpaper = file.path;

          userAbout = await UserAuth()
              .addOrUpdateUserBio(userBloc.userAbout)
              .catchError((error) {
            debugPrint("Cannot Update Cover : " + error.toString());
            isSearchedUserAboutLoading = false;
            if (mounted) setState(() {});
          });

          userBloc.userAbout = userAbout;

          isSearchedUserAboutLoading = false;
          if (mounted) setState(() {});
        } catch (err) {
          isSearchedUserAboutLoading = false;
          if (mounted) setState(() {});
          Toast.show(err.toString(), context,
              backgroundColor: blackFont, textColor: Colors.white);
          debugPrint("Cannot Update Cover : " + err.toString());
        }
      }
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
      addDataToUserAboutObject();

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
                child: CircularLoadingIndicator(),
              ));

      UserAuth().addOrUpdateUserBio(userBioDetail).then((value) {
        Navigator.pop(context);
        Navigator.pop(context, value);
        Toast.show(
          "Bio updated successfully!!",
          context,
          textColor: Colors.white,
          duration: 3,
        );
      }).catchError((error) {
        Navigator.pop(context);
        debugPrint(error.toString());
        Toast.show(error.toString(), context, textColor: Colors.white);
      });
    }
  }

  void addDataToUserAboutObject() {
    userBioDetail.bio = bioController.text.trim();
    userBioDetail.address = addressController.text.trim();
    userBioDetail.contact = contactNumberController.text.trim();

    addOpeningHoursToUserAboutObject();
  }

  void addOpeningHoursToUserAboutObject() {
    userBioDetail.openingHours = [];

    userAddedOpeningHours.forEach((element) {
      OpeningHour openingHour = OpeningHour();

      openingHour.day = element["day"];
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
