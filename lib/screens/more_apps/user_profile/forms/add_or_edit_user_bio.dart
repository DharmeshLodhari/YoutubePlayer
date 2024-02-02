import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/OpeningHour.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../messaging/chat/screens/chat_screen_group_messages.dart';
import '../user_auth.dart';
import '../widgets/pick_state_widget.dart';

// ignore: must_be_immutable
class AddOrEditUserBioScreen extends StatefulWidget {
  @override
  _AddOrEditUserBioScreenState createState() => _AddOrEditUserBioScreenState();
}

class _AddOrEditUserBioScreenState extends State<AddOrEditUserBioScreen> {
  int? pickedStateId;
  String? pickedStateValue;

  final GlobalKey<FormState> _businessBioKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _userDetailKey = GlobalKey<FormState>();

  TextEditingController? bioController;
  TextEditingController? cityController;
  TextEditingController? addressLine1Controller;
  TextEditingController? addressLine2Controller;
  TextEditingController? contactNumberController;
  late TextEditingController _fullNameController;
  late TextEditingController _userNameController;
  TextEditingController? _nicknameController;

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
    },
  ];

  late UserBloc userBloc;
  UserAbout? userBioDetail;
  bool? isSearchedUserAboutLoading;
  bool isLoading = false;
  bool isUserIsSimpleUser = false;
  bool isUserAvatarLoading = false;

  @override
  void initState() {
    bioController = TextEditingController();
    cityController = TextEditingController();
    addressLine1Controller = TextEditingController();
    addressLine2Controller = TextEditingController();
    contactNumberController = TextEditingController();
    _userNameController = TextEditingController();
    _nicknameController = TextEditingController();
    _fullNameController = TextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      userBioDetail = userBloc.userAbout;
      bioController!.text = messageDecoderWithEmoji(userBloc.user.bio!)!;
      if (userBioDetail?.userAddress?.addressLine1 != null) {
        addressLine1Controller!.text =
            userBioDetail!.userAddress!.addressLine1!;
      }

      if (userBioDetail?.userAddress?.addressLine2 != null) {
        addressLine2Controller!.text =
            userBioDetail!.userAddress!.addressLine2!;
      }
      if (userBioDetail?.userAddress?.city != null) {
        cityController!.text = userBioDetail!.userAddress!.city!;
      }

      if (userBioDetail?.userAddress?.state != null) {
        pickedStateId = userBioDetail?.userAddress?.state;
      }

      if (userBioDetail?.contact != null) {
        contactNumberController!.text = userBioDetail!.contact;
      }
      if (userBloc.user.nickName != null) {
        _nicknameController!.text =
            messageDecoderWithEmoji(userBloc.user.nickName!)!;
      }
      if (userBloc.user.userName != null) {
        _userNameController.text = userBloc.user.userName!;
      }
      if (userBloc.user.fullName != null) {
        _fullNameController.text = userBloc.user.fullName!;
      }

      if (userBioDetail!.openingHours.isNotEmpty) {
        addUserAddedOpeningHour();
      }
    });

    super.initState();
  }

  void addUserAddedOpeningHour() {
    List<String?> updatedDays = [];
    userBioDetail!.openingHours.forEach((element) {
      String time = element.time!.trim();
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

    if (userBloc.user.type!.toLowerCase() == "user") {
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
    return SingleChildScrollView(
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
          SizedBox(height: 20),
          addContactNumberField(),
          SizedBox(height: 20),
          addAddressLine1Field(),
          SizedBox(height: 20),
          addAddressLine2Field(),
          SizedBox(height: 20),
          cityField(),
          SizedBox(height: 20),
          PickStateWidget(
            afterOnChanged: (stateId, stateValue) {
              pickedStateId = stateId;
              pickedStateValue = stateValue;
            },
          ),
          SizedBox(height: 20),
          addOpeningHour(),
        ],
      ),
    );
  }

  Widget getUserPersonalDetail() {
    if (userBloc.user.type.toString().toLowerCase() != "user") {
      return Container();
    }

    return Form(
      key: _userDetailKey,
      child: Column(
        children: [
          addBioField(),
          SizedBox(height: 20),
          nickNameField(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  String? fullNameValidator(String enteredName) {
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

  String? userNameValidator(String username) {
    // alphanumeric,-, and _.
    RegExp validCharacters =
        RegExp(r'^[a-z0-9]([._-](?![._-])|[a-z0-9]){3,18}[a-z0-9]$');

    if (!validCharacters.hasMatch(username)) {
      return "Username is not valid";
    }

    return checkSlydoName(username);
  }

  Widget nickNameField() {
    return CustomizedTextFormField(
      controller: _nicknameController,
      labelColor: darkGrey,
      labelText: "Nick name (optional)",
      keyboardType: TextInputType.name,
      validator: nickNameValidator,
    );
  }

  String? nickNameValidator(String nickName) {
    return checkSlydoName(nickName);
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
          actions: [editProfileCoverIcon(), SizedBox(width: 16)],
          title: Container(
            child: userNameWithVerifiedIcon(
              name: userBloc.user.displayName()!,
              isVerified: userBloc.user.isVerified,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
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
    debugPrint('USER ABOUT --> ${userBloc.userAbout == null}');
    debugPrint('USER ABOUT --> ${userBloc.userAbout!.wallpaper == ""}');
    debugPrint(
        'USER ABOUT --> ${!userBloc.userAbout!.wallpaper.contains("http")}');
    debugPrint(
        'USER ABOUT --> ${!userBloc.userAbout!.wallpaper.contains("https")}');

    debugPrint('MY WALL -> ${userBloc.userAbout!.wallpaper}');
    return Container(height: 206, child: getProfileWallpaper());
  }

  Widget getProfileWallpaper() {
    if (isUserIsSimpleUser) {
      if (userBloc.user.wallpaper == null ||
          userBloc.user.wallpaper == "" ||
          (!userBloc.user.wallpaper!.contains("http") &&
              !userBloc.user.wallpaper!.contains("https"))) {
        debugPrint('WALLPAPER IM-> ${userBloc.user.wallpaper}');
        debugPrint('WALLPAPER null-> ${userBloc.user.wallpaper == null}');
        debugPrint('WALLPAPER emp-> ${userBloc.userAbout!.wallpaper == ""}');
        debugPrint(
            'WALLPAPER no http-> ${!userBloc.userAbout!.wallpaper.contains("http")}');
        debugPrint(
            'WALLPAPER no https -> ${!userBloc.userAbout!.wallpaper.contains("https")}');

        return Image.asset(
          "assets/images/home_screen_background.png",
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else {
        debugPrint('WALLPAPER C -> ${userBloc.user.wallpaper}');

        return CachedNetworkImage(
          width: double.infinity,
          height: double.infinity,
          imageUrl: userBloc.user.wallpaper!,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Center(child: CircularLoadingIndicator()),
          color: blackFont.withOpacity(0.4),
          colorBlendMode: BlendMode.darken,
          filterQuality: FilterQuality.high,
        );
      }
    } else {
      return userBloc.userAbout == null
          ? Image.asset(
              "assets/images/home_screen_background.png",
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : userBloc.userAbout!.wallpaper == "" ||
                  (!userBloc.userAbout!.wallpaper.contains("http") &&
                      !userBloc.userAbout!.wallpaper.contains("https"))
              ? Image.asset(
                  "assets/images/home_screen_background.png",
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  width: double.infinity,
                  height: double.infinity,
                  imageUrl: userBloc.userAbout!.wallpaper,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularLoadingIndicator()),
                  color: blackFont.withOpacity(0.4),
                  colorBlendMode: BlendMode.darken,
                  filterQuality: FilterQuality.high,
                );
    }
  }

  Widget getProfilePhoto() {
    Color borderColor = getUserTypeColorByType(type: userBloc.user.type!);

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
                            imageUrl: userBloc.user.avatar!,
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
                  onTap: selectProfilePictureAction,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void selectProfilePictureAction() async {
    String? result = await selectImageAction(imageName: "avatar");
    if (result != null) {
      if (result == "update") {
        debugPrint('UPDATE ---> ');

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          AppLocalization.of(context)!.selectTheImageSource,
          style: TextStyle(fontSize: 18, color: blackFont),
        ),
        actions: <Widget>[
          MaterialButton(
            child: Text(
              AppLocalization.of(context)!.camera,
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
      ),
    );

    if (imageSource != null) {
      final file =
          await ImagePicker().pickImage(source: imageSource, imageQuality: 70);
      if (file != null) {
        /// for cropping the image
        String? croppedImage =
            await ImageCrop().cropImage(file.path, isProfilePicture: true);
        if (croppedImage == null) {
          return;
        }

        debugPrint('CROPPED IMAGE UPDATE ---> $croppedImage');

        try {
          isUserAvatarLoading = true;
          if (mounted) setState(() {});

          // Upload Image new image
          CustomerProfile customerProfile =
              await UserAuth().updateUserAvatar(File(croppedImage));

          isUserAvatarLoading = false;
          if (mounted) setState(() {});

          debugPrint("==> ${customerProfile.avatar}");

          userBloc.updateProfileAvatar(customerProfile.avatar);

          broadcastUserAvatarUpdate(
            context: context,
            avatar: customerProfile.avatar!,
          );
        } catch (err) {
          isUserAvatarLoading = false;
          if (mounted) setState(() {});
          showToast(message: err.toString());
        }
      }
    }
  }

  Widget addAddressLine1Field() {
    return CustomizedTextFormField(
      controller: addressLine1Controller,
      labelText: "Address Line 1",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Invalid Address";
      },
      hintText: "This address will be publicly available.",
    );
  }

  Widget addAddressLine2Field() {
    return CustomizedTextFormField(
      controller: addressLine2Controller,
      labelText: "Address Line 2",
      validator: (val) {
        return null;
      },
      hintText: "This address will be publicly available.",
    );
  }

  Widget cityField() {
    return CustomizedTextFormField(
      controller: cityController,
      labelText: "City",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Invalid City";
      },
      hintText: "Enter your city",
    );
  }

  Widget addBioField() {
    return CustomizedTextFormField(
      controller: bioController,
      maxLines: 5,
      maxLength: 200,
      textCapitalization: TextCapitalization.sentences,
      labelText: "Bio (optional)",
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
          SizedBox(width: 10),
          getOpeningHourStartingTime(element: element),
          SizedBox(width: 10),
          getOpeningHourClosingTime(element: element)
        ],
      ),
    );
  }

  Widget getOpeningHourDay({required Map<String, dynamic> element}) {
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

  Widget getOpeningHourStartingTime({required Map<String, dynamic> element}) {
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

  Widget getOpeningHourClosingTime({required Map<String, dynamic> element}) {
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

  void selectTime(
      {Map<String, dynamic>? element, bool isOpening = true}) async {
    TimeOfDay? selectedTimeRTL = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: navyBlue,
            backgroundColor: Colors.white,
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: iconBtnGrey,
              dialBackgroundColor: iconBtnGrey,
              dayPeriodBorderSide: BorderSide(color: dividerColor),
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: ColorScheme.light(primary: navyBlue)
                .copyWith(secondary: navyBlue),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
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
    String? result = await selectImageAction(imageName: "profile cover");
    if (result != null) {
      if (result == "update") {
        pickImage();
      } else if (result == "remove") {
        bool result = await UserAuth().deleteImageCover(isUserNormalUser: true);
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
                AppLocalization.of(context)!.selectTheImageSource,
                style: TextStyle(fontSize: 18, color: blackFont),
              ),
              actions: <Widget>[
                MaterialButton(
                  child: Text(
                    AppLocalization.of(context)!.camera,
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
          await ImagePicker().pickImage(source: imageSource, imageQuality: 70);
      if (file != null) {
        /// for cropping the image
        String? croppedImage = await ImageCrop().cropImage(file.path);
        if (croppedImage == null) {
          return;
        }

        if (isUserIsSimpleUser) {
          updateUserDetail(wallpaper: croppedImage);
        } else {
          isSearchedUserAboutLoading = true;
          if (mounted) setState(() {});
          String nickName = _nicknameController!.text.trim();

          UserBloc tempUserBloc = Provider.of<UserBloc>(context, listen: false);

          UserAbout userAbout = tempUserBloc.userAbout!;
          userAbout.wallpaper = croppedImage;
          await UserAuth()
              .addOrUpdateUserBio(userAbout: userAbout, nickName: nickName)
              .then((newUserAbout) {
            userBloc.userAbout = newUserAbout;

            isSearchedUserAboutLoading = false;
            if (mounted) setState(() {});
          }).catchError((error) {
            isSearchedUserAboutLoading = false;
            if (mounted) setState(() {});

            showToast(message: error.toString());

            isSearchedUserAboutLoading = false;
            if (mounted) setState(() {});
          });
        }
      }
    }
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () async {
        FocusScope.of(context).unfocus();
        if (userBloc.user.type!.toLowerCase() == "user") {
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

  void updateUserDetail({String? wallpaper}) async {
    if (_userDetailKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularLoadingIndicator(),
        ),
      );

      String nickName = _nicknameController!.text.trim();
      String bio = bioController!.text.trim();
      await UserAuth()
          .updateSimpleUserDetail(
              nickName: nickName, bio: bio, wallpaper: wallpaper)
          .then((value) async {
        UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
        userBloc.updateNickName = value['nickname'];
        userBloc.user.bio = value['bio'];
        userBloc.user.wallpaper = value['wallpaper'];

        if (wallpaper == null) {
          Navigator.pop(context);
          Navigator.pop(context);

          showToast(message: "Bio updated successfully");
        } else {
          Navigator.pop(context);
          if (mounted) setState(() {});
          showToast(message: 'Wallpaper updated successfully');
        }
      });

      // .catchError((error) {
      // Navigator.pop(context);
      // debugPrint(error.toString());
      // showToast(message: error.toString());
      // });
    }
  }

  void updateBio() async {
    if (_businessBioKey.currentState?.validate() ?? false) {
      addDataToUserAboutObject();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularLoadingIndicator(),
        ),
      );
      userBioDetail!.userAddress = UserAddress(
        state: pickedStateId,
        id: userBloc.userAbout?.userAddress?.id,
        city: userBloc.userAbout?.userAddress?.city,
        postCode: userBloc.userAbout?.userAddress?.postCode,
        addressLine1: userBloc.userAbout?.userAddress?.addressLine1,
        addressLine2: userBloc.userAbout?.userAddress?.addressLine2,
      );

      String nickName = _nicknameController!.text.trim();
      await UserAuth()
          .addOrUpdateUserBio(userAbout: userBioDetail, nickName: nickName)
          .then((value) async {
        await UserAuth()
            .authenticate(userBloc.user.phoneNumber, userBloc.user.password)
            .then((user) {
          userBloc.user = user;

          debugPrint(
              'USER ADDRESS P -> ${userBloc.user.userAbout?.userAddress?.addressLine1}');
        });

        Navigator.pop(context);
        Navigator.pop(
            context, {"userAbout": value, "user_avatar": userBloc.user.avatar});

        showToast(
          message: "Bio updated successfully!!",
        );
      }).catchError((e) {
        NavigationUtil.pop(context);
        showToast(message: e.toString());
      });
    }
  }

  void addDataToUserAboutObject() {
    userBioDetail!.bio = bioController!.text.trim();
    userBioDetail!.userAddress!.addressLine1 =
        addressLine1Controller!.text.trim();
    userBioDetail!.userAddress!.addressLine2 =
        addressLine2Controller!.text.trim();
    userBioDetail!.userAddress!.city = cityController!.text.trim();
    userBioDetail!.contact = contactNumberController!.text.trim();

    addOpeningHoursToUserAboutObject();
  }

  void addOpeningHoursToUserAboutObject() {
    userBioDetail!.openingHours = [];

    userAddedOpeningHours.forEach((element) {
      if (element["is_open"]) {
        OpeningHourForDay openingHour = OpeningHourForDay();

        openingHour.day = element["day"];
        openingHour.time =
            "${element["starting_hour"]} - ${element["closing_hour"]}";
        if (userBioDetail!.openingHours == null) {
          userBioDetail!.openingHours = [openingHour];
        } else {
          userBioDetail!.openingHours.add(openingHour);
        }
      }
    });

    userBioDetail!.openingHours.forEach((element) {
      debugPrint('OPENING HOURS ---> ${element.toJson()}');
    });
  }

  Future<String?> selectImageAction({String? imageName}) async {
    String? result = await showModalBottomSheet<String>(
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

  List<Widget> generateBottomSheetItem(String? imageName) {
    List<Widget> list = [];

    list.add(
      bottomSheetItem(
          title: "Update $imageName",
          iconData: SlydoAppIcon.edit,
          onTap: () async {
            Navigator.pop(context, "update");
          }),
    );

    list.add(
      bottomSheetItem(
        title: "Remove $imageName",
        isLast: true,
        iconData: SlydoAppIcon.delete,
        onTap: () {
          Navigator.pop(context, "remove");
        },
      ),
    );

    return list;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
