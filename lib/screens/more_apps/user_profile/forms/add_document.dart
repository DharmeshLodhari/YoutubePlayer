import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../user_auth.dart';

class AddDocument extends StatefulWidget {
  @override
  _AddDocumentState createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  final _formsPageViewController = PageController();

  //List of the all three form
  late List _forms;

  XFile? documentImage;
  XFile? userImage;
  bool isPassportAllowed = true;
  bool isDrivingLicenceAllowed = false;
  bool isIdentityCardAllowed = false;
  bool? userAgree = false;

  @override
  Widget build(BuildContext context) {
    _forms = [
      PopScope(
        onPopInvoked: (didPop) => Future.sync(onWillPop),
        child: formOne(),
      ),
      PopScope(
        onPopInvoked: (didPop) => Future.sync(onWillPop),
        child: formTwo(),
      ),
      PopScope(
        onPopInvoked: (didPop) => Future.sync(onWillPop),
        child: formThree(),
      ),
    ];

    return Scaffold(
      backgroundColor: chatBackgroundColor,
      appBar: AppBar(
        backgroundColor: navyBlue,
        title: Text(AppLocalization.of(context)!.verifyYourIdentity),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: _formsPageViewController,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return _forms[index];
              },
            ),
          ),
        ],
      ),
    );
  }

  // to navigate to the next form
  void _nextFormStep() {
    if (userAgree!) {
      _formsPageViewController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  // to navigate to the previous form
  void _previousFormStep() {
    _formsPageViewController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  bool onWillPop() {
    // if we are on the first page then it will pop the screen otherwise navigate to the privious screen
    if (_formsPageViewController.page!.round() ==
        _formsPageViewController.initialPage) return true;

    _previousFormStep();

    return false;
  }

  // first form for choice the document type
  Widget formOne() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 35),
      child: Column(
        children: <Widget>[
          subtitleTextOne(),
          const SizedBox(
            height: 20,
          ),
          documentTypeTile(
              icon: const Icon(
                Icons.account_balance_wallet,
                size: 40,
              ),
              title: AppLocalization.of(context)!.passportMsg,
              subtitle: AppLocalization.of(context)!.facePhotoPage,
              onTap: _nextFormStep,
              enabled: isPassportAllowed),
          documentTypeTile(
              icon: const Icon(
                Icons.directions_car,
                size: 40,
              ),
              title: AppLocalization.of(context)!.driverLicence,
              subtitle: AppLocalization.of(context)!.frontAndBack,
              onTap: _nextFormStep,
              enabled: isDrivingLicenceAllowed),
          documentTypeTile(
              icon: const Icon(
                Icons.card_membership,
                size: 40,
              ),
              title: AppLocalization.of(context)!.identityCard,
              subtitle: AppLocalization.of(context)!.frontAndBack,
              onTap: _nextFormStep,
              enabled: isIdentityCardAllowed),
          const SizedBox(
            height: 12,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: userAgree,
                onChanged: (value) {
                  setState(() {
                    userAgree = value;
                  });
                },
                activeColor: navyBlue,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(AppLocalization.of(context)!
                    .documentVerificationTermsAndCondition),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget subtitleTextOne() {
    return Text(
      AppLocalization.of(context)!.selectTypeOfDocument,
      style: const TextStyle(
          fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
    );
  }

  Widget documentTypeTile(
      {required Widget icon,
      required String title,
      required String subtitle,
      required Function onTap,
      required bool enabled}) {
    return Card(
        child: ListTile(
      enabled: enabled,
      leading: icon,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: blackFont),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: onTap as void Function()?,
    ));
  }

  // second form for the document file
  Widget formTwo() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          titleTextTwo(),
          const SizedBox(
            height: 20,
          ),
          takeDocumentPhotoFromCamera(),
          takeDocumentPhotoFromGallery2(),
          const SizedBox(
            height: 10,
          ),
          if (documentImage != null)
            takeDocumentPhotoFromGallery()
          else
            Container(),
          buttonBarTwo()
        ],
      ),
    );
  }

  Widget titleTextTwo() {
    return Text(
      AppLocalization.of(context)!.passportPhotoPage,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
    );
  }

  Widget takeDocumentPhotoFromCamera() {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.camera_alt,
          size: 40,
        ),
        title: Text(
          AppLocalization.of(context)!.needToUseYourMobileToTake,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(AppLocalization.of(context)!.tapHereToContinue),
        onTap: () async {
          ImagePicker()
              .pickImage(source: ImageSource.camera, imageQuality: 70)
              .then((value) {
            setState(() {
              documentImage = value;
            });
          });
        },
      ),
    );
  }

  Widget takeDocumentPhotoFromGallery2() {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.cloud_upload,
          size: 40,
        ),
        title: Text(
          AppLocalization.of(context)!.uploadPhotoFromDevice,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(AppLocalization.of(context)!.tapHereToContinue),
        onTap: () async {
          ImagePicker()
              .pickImage(source: ImageSource.gallery, imageQuality: 70)
              .then((value) {
            setState(() {
              documentImage = value;
            });
          });
        },
      ),
    );
  }

  Widget takeDocumentPhotoFromGallery() {
    return Card(
        child: Column(
      children: <Widget>[
        SizedBox(
          height: 300,
          width: double.infinity,
          child: documentImage != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    File(documentImage!.path),
                    filterQuality: FilterQuality.high,
                  ),
                )
              : Icon(
                  Icons.supervised_user_circle,
                  color: Colors.grey[200],
                  size: 300,
                ),
        ),
      ],
    ));
  }

  Widget buttonBarTwo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        if (documentImage != null)
          MaterialButton(
            color: blackFont,
            onPressed: _nextFormStep,
            child: Text(
              AppLocalization.of(context)!.next,
              style: const TextStyle(color: Colors.white),
            ),
          )
        else
          Container(),
      ],
    );
  }

  // third form for the user photo
  Widget formThree() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          titleTextThree(),
          const SizedBox(
            height: 20,
          ),
          takeUserPhotoFromCamera(),
          const SizedBox(
            height: 10,
          ),
          if (userImage != null) takeUserPhotoFromGallary() else Container(),
          buttonBarThree()
        ],
      ),
    );
  }

  Widget titleTextThree() {
    return Text(
      AppLocalization.of(context)!.userPhotoPage,
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 24, color: blackFont),
    );
  }

  Widget takeUserPhotoFromCamera() {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.camera_alt,
          size: 40,
        ),
        title: Text(
          AppLocalization.of(context)!.needToUseYourMobileToTake,
          style: TextStyle(fontWeight: FontWeight.bold, color: blackFont),
        ),
        subtitle: Text(AppLocalization.of(context)!.tapHereToContinue),
        onTap: () {
          ImagePicker()
              .pickImage(source: ImageSource.camera, imageQuality: 70)
              .then((value) {
            setState(() {
              userImage = value;
            });
          });
        },
      ),
    );
  }

  Widget takeUserPhotoFromGallary() {
    return Card(
        child: Column(
      children: <Widget>[
        SizedBox(
          height: 300,
          width: double.infinity,
          child: userImage != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    File(userImage!.path),
                    filterQuality: FilterQuality.high,
                  ),
                )
              : Icon(
                  Icons.supervised_user_circle,
                  color: Colors.grey[200],
                  size: 300,
                ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    ));
  }

  Widget buttonBarThree() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        MaterialButton(
          color: blackFont,
          onPressed: _previousFormStep,
          child: Text(
            AppLocalization.of(context)!.previous,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        if (userImage != null)
          MaterialButton(
            color: blackFont,
            onPressed: () {
              final _auth = AuthService();
              final userBloc = Provider.of<UserBloc>(context, listen: false);
              // Get new token for user before attempting to post data to server
              _auth
                  .authenticate(
                      userBloc.user.phoneNumber, userBloc.user.password)
                  .then((user) {
                try {
                  UserAuth()
                      .verifyUserDetail(
                          File(documentImage!.path), File(userImage!.path))
                      .then((user) {
                    _auth
                        .authenticate(
                            userBloc.user.phoneNumber, userBloc.user.password)
                        .then((user) {
                      if (user.isVerified!) {
                        userBloc.user = user;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          "/dashboard",
                          (Route<dynamic> route) => false,
                        );
                      }
                    });
                  });
                } catch (exception) {
                  showToast(message: exception.toString());
                }
              });
            },
            child: Text(
              AppLocalization.of(context)!.finish,
              style: const TextStyle(color: Colors.white),
            ),
          )
        else
          Container(),
      ],
    );
  }

  @override
  void dispose() {
    _formsPageViewController.dispose();
    super.dispose();
  }
}
