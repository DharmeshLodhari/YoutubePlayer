import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/OpeningHour.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/image_crop.dart';
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
  final GlobalKey<FormState> _businessBioKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _userDetailKey = GlobalKey<FormState>();

  TextEditingController bioController;
  TextEditingController addressController;
  TextEditingController contactNumberController;
  TextEditingController _fullNameController;
  TextEditingController _userNameController;
  TextEditingController _nicknameController;

  List<String> openingHoursDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  List<Map<String, dynamic>> userAddedOpeningHours = [
    {
      "is_open": true,
      "day": "Monday",
      "starting_hour": "10:00 AM",
      "closing_hour": "6:00 PM"
    },
    {
      "is_open": true,
      "day": "Tuesday",
      "starting_hour": "10:00 AM",
      "closing_hour": "6:00 PM"
    },
    {
      "is_open": true,
      "day": "Wednesday",
      "starting_hour": "10:00 AM",
      "closing_hour": "6:00 PM"
    },
    {
      "is_open": true,
      "day": "Thursday",
      "starting_hour": "10:00 AM",
      "closing_hour": "6:00 PM"
    },
    {
      "is_open": true,
      "day": "Friday",
      "starting_hour": "10:00 AM",
      "closing_hour": "6:00 PM"
    },
    {
      "is_open": true,
      "day": "Saturday",
      "starting_hour": "10:00 AM",
      "closing_hour": "6:00 PM"
    },
    {
      "is_open": false,
      "day": "Sunday",
      "starting_hour": "10:00 AM",
      "closing_hour": "6:00 PM"
    }
  ];

  UserBloc userBloc;

  UserAbout userBioDetail;

  bool isSearchedUserAboutLoading;

  bool isLoading = false;

  bool isUserIsSimpleUser = false;

  bool isUserAvatarLoading = false;

  @override
  void initState() {
    bioController = TextEditingController();
    addressController = TextEditingController();
    contactNumberController = TextEditingController();
    _userNameController = TextEditingController();
    _nicknameController = TextEditingController();
    _fullNameController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      userBioDetail = userBloc.userAbout;
      bioController.text = userBioDetail.bio;
      addressController.text = userBioDetail.address;
      contactNumberController.text = userBioDetail.contact;
      _nicknameController.text = userBloc.user.nickName;
      _userNameController.text = userBloc.user.userName;
      _fullNameController.text = userBloc.user.fullName;
      if (userBioDetail.openingHours.isNotEmpty) {
        addUserAddedOpeningHour();
      }
    });

    super.initState();
  }

  void addUserAddedOpeningHour() {
    List<String> updatedDays = [];
    userBioDetail.openingHours.forEach((element) {
      String time = element.time.trim();
      List<String> openingAndClosingTime = time.split("-");

      userAddedOpeningHours.forEach((existing) {
        if (element.day == existing["day"]) {
          updatedDays.add(element.day);
          existing['is_open'] = true;
          existing['starting_hour'] = openingAndClosingTime[0].trim();
          existing['closing_hour'] = openingAndClosingTime[1].trim();
        }
      });
    });

    userAddedOpeningHours.forEach((element) {
      if (!updatedDays.contains(element["day"])) {
        element["is_open"] = false;
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    if (userBloc.user.type.toLowerCase() == "user") {
      isUserIsSimpleUser = true;
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {
          "userAbout": userBloc.userAbout,
          "user_avatar": userBloc.user.avatar
        });
        return false;
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

  Widget scaffoldBody() {
    return isUserIsSimpleUser
        ? Container()
        : SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  getUserPersonalDetail(),
                  isUserIsSimpleUser ? Container() : getUserBioDetails(),
                  SizedBox(height: 20),
                  getSubmitButton(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          );
  }

  Widget getUserBioDetails() {
    return Form(
      key: _businessBioKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          addBioField(),
          SizedBox(
            height: 20,
          ),
          addAddressField(),
          SizedBox(
            height: 20,
          ),
          addContactNumberField(),
          SizedBox(
            height: 20,
          ),
          addOpeningHour(),
        ],
      ),
    );
  }

  Widget getUserPersonalDetail() {
    return Form(
      key: _userDetailKey,
      child: Column(
        children: [
          SizedBox(height: 20),
          nickNameField(),
        ],
      ),
    );
  }

  String fullNameValidator(String enteredName) {
    List<String> nameList = enteredName.split(" ");

    /// For not allowing user to put any profession title
    List<String> notValidProfessionTitles = [
      "mr",
      "mrs",
      "miss",
      "ms",
      "chief",
      "dr",
      "prof",
      "engr",
      "evang",
    ];

    RegExp regExp = RegExp(r"^[A-Za-z\s]{1,}[A-Za-z\s]{0,}$");

    if (!regExp.hasMatch(enteredName)) {
      return "Please enter valid name";
    }
    if (nameList.length < 2) {
      return "Please enter full name";
    }
    if (notValidProfessionTitles.contains(nameList[0].toLowerCase())) {
      return "Please remove ${nameList[0]} from name";
    }
    if (nameList[0].length < 2 || nameList[1].length < 2) {
      return "Please enter valid name";
    }

    return null;
  }

  String userNameValidator(String username) {
    // alphanumeric and -_.
    RegExp validCharacters =
        RegExp(r'^[a-z0-9]([._-](?![._-])|[a-z0-9]){3,18}[a-z0-9]$');

    if (!validCharacters.hasMatch(username)) {
      return "Username is not valid";
    }

    return null;
  }

  Widget nickNameField() {
    return CustomizedTextFormField(
      controller: _nicknameController,
      labelColor: darkGrey,
      labelText: "Nick name",
      keyboardType: TextInputType.name,
    );
  }

  String nickNameValidator(String nickName) {
    return null;
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
              Navigator.pop(context, {
                "userAbout": userBloc.userAbout,
                "user_avatar": userBloc.user.avatar
              });
            },
          ),
          actions: isUserIsSimpleUser
              ? null
              : [
                  editProfileCoverIcon(),
                  SizedBox(
                    width: 16,
                  )
                ],
          title: Container(
            child: Text(
              userBloc.user.displayName(),
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
          : userBloc.userAbout.wallpaper == "" ||
                  !userBloc.userAbout.wallpaper.contains("http")
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
                    child: isUserAvatarLoading
                        ? Container(
                            height: 88,
                            width: 88,
                            child: Center(child: CircularLoadingIndicator()))
                        : CachedNetworkImage(
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
                  onTap: selectAvatarAction,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void selectAvatarAction() async {
    String result = await selectImageAction(imageName: "avatar");
    if (result != null) {
      if (result == "update") {
        updateProfilePicture();
      } else if (result == "remove") {
        isUserAvatarLoading = true;
        if (mounted) setState(() {});
        bool result = await UserAuth().deleteUserAvatar();

        isUserAvatarLoading = false;
        if (mounted) setState(() {});
        debugPrint("result :- $result");

        if (result) {
          userBloc.removeProfileAvatar();
        }
      }
    }
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
        /// for cropping the image
        String croppedImage = await ImageCrop().cropImage(file.path);
        if (croppedImage == null) {
          return;
        }

        try {
          isUserAvatarLoading = true;
          if (mounted) setState(() {});

          // Upload Image new image
          CustomerProfile customerProfile =
              await UserAuth().updateUserAvatar(File(croppedImage));

          isUserAvatarLoading = false;
          if (mounted) setState(() {});

          if (customerProfile != null) {
            debugPrint("==> ${customerProfile.avatar}");

            userBloc.updateProfileAvatar(customerProfile.avatar);
          }
        } catch (err) {
          isUserAvatarLoading = false;
          if (mounted) setState(() {});
          Toast.show(err.toString(), context,
              backgroundColor: blackFont, textColor: Colors.white);
          debugPrint("Cannot Update Avatar : " + err.toString());
        }
      }
    }
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hours",
          style: TextStyle(
              color: darkGrey, fontSize: 14, fontWeight: FontWeight.w400),
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
      ),
      margin: EdgeInsets.all(0),
      borderOnForeground: true,
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
            alignedDropdown: true,
            child: GestureDetector(
              child: Row(
                children: [
                  GestureDetector(
                    child: ClipRRect(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      child: SizedBox(
                        width: Checkbox.width,
                        height: Checkbox.width,
                        child: Container(
                          decoration: new BoxDecoration(
                            border: Border.all(
                              color: greyBorderColor,
                              width: 1,
                            ),
                            borderRadius: new BorderRadius.circular(4),
                          ),
                          child: Theme(
                            data: ThemeData(
                              unselectedWidgetColor: Colors.transparent,
                            ),
                            child: Checkbox(
                              value: element["is_open"],
                              onChanged: (newValue) {
                                element["is_open"] = newValue;
                                setState(() {});
                              },
                              activeColor: navyBlue,
                              checkColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      element["is_open"] = !element["is_open"];
                      setState(() {});
                    },
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      element["day"],
                      style: TextStyle(
                          color: blackFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
              onTap: () {
                element["is_open"] = !element["is_open"];
                setState(() {});
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
          child: Text(
            "${element["starting_hour"]}",
            style: TextStyle(
                color: blackFont, fontWeight: FontWeight.w600, fontSize: 16),
          ),
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
          child: Text(
            "${element["closing_hour"]}",
            style: TextStyle(
                color: blackFont, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ),
      onTap: () {
        selectTime(element: element, isOpening: false);
      },
    );
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
        Icons.camera_alt,
        size: 16,
        color: blackFont,
      ),
      onTap: selectProfileCoverAction,
      backgroundColor: lightGrey,
      enableMargin: true,
    );
  }

  void selectProfileCoverAction() async {
    String result = await selectImageAction(imageName: "profile cover");
    if (result != null) {
      if (result == "update") {
        pickImage();
      } else if (result == "remove") {
        bool result = await UserAuth().deleteImageCover();
        if (result) {
          userBloc.removeProfileCover();
        }
      }
    }
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
        /// for cropping the image
        String croppedImage = await ImageCrop().cropImage(file.path);
        if (croppedImage == null) {
          return;
        }

        isSearchedUserAboutLoading = true;
        if (mounted) setState(() {});

        UserBloc tempUserBloc = Provider.of<UserBloc>(context, listen: false);

        UserAbout userAbout = tempUserBloc.userAbout;

        userAbout.wallpaper = croppedImage;
        String nickName = _nicknameController.text.trim();

        await UserAuth()
            .addOrUpdateUserBio(userAbout: userAbout, nickName: nickName)
            .catchError((error) {
          isSearchedUserAboutLoading = false;
          if (mounted) setState(() {});

          Toast.show(error.toString(), context,
              backgroundColor: blackFont, textColor: Colors.white);
          debugPrint("Cannot Update Cover : " + error.toString());

          isSearchedUserAboutLoading = false;
          if (mounted) setState(() {});
        }).then((newUserAbout) {
          userBloc.userAbout = newUserAbout;

          isSearchedUserAboutLoading = false;
          if (mounted) setState(() {});
        });
      }
    }
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () async {
        FocusScope.of(context).unfocus();
        if (userBloc.user.type == "User") {
          updateUserDetail();
        } else {
          updateBio();
        }
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: userBloc.user.type == "User" ? "Update" : "Update Bio",
    );
  }

  void updateUserDetail() async {
    if (_userDetailKey.currentState.validate()) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
                child: CircularLoadingIndicator(),
              ));

      String nickName = _nicknameController.text.trim();
      await UserAuth().addOrUpdateUserBio(nickName: nickName).then((value) {
        Navigator.pop(context);
        Navigator.pop(
            context, {"userAbout": value, "user_avatar": userBloc.user.avatar});
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

  void updateBio() async {
    if (_businessBioKey.currentState.validate()) {
      addDataToUserAboutObject();

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
                child: CircularLoadingIndicator(),
              ));

      String nickName = _nicknameController.text.trim();
      await UserAuth()
          .addOrUpdateUserBio(userAbout: userBioDetail, nickName: nickName)
          .then((value) {
        Navigator.pop(context);
        Navigator.pop(
            context, {"userAbout": value, "user_avatar": userBloc.user.avatar});
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
      if (element["is_open"]) {
        OpeningHour openingHour = OpeningHour();

        openingHour.day = element["day"];
        openingHour.time =
            "${element["starting_hour"]} - ${element["closing_hour"]}";
        if (userBioDetail.openingHours == null) {
          userBioDetail.openingHours = [openingHour];
        } else {
          userBioDetail.openingHours.add(openingHour);
        }
      }
    });
  }

  Future<String> selectImageAction({String imageName}) async {
    String result = await showModalBottomSheet<String>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: generateBottomSheetItem(imageName),
                ),
              ));
        });
    return result;
  }

  List<Widget> generateBottomSheetItem(String imageName) {
    List<Widget> list = [];

    list.add(
      bottomSheetItem(
          title: "Update $imageName",
          icon: SlydoAppIcon.edit,
          onTap: () async {
            Navigator.pop(context, "update");
          }),
    );

    list.add(bottomSheetItem(
      title: "Remove $imageName",
      isLast: true,
      icon: SlydoAppIcon.delete,
      onTap: () {
        Navigator.pop(context, "remove");
      },
    ));

    return list;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
