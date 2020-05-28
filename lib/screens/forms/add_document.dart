import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class AddDocument extends StatefulWidget {
  @override
  _AddDocumentState createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  final _formsPageViewController = PageController();
  //List of the all three form
  List _forms;

  File documentImage;
  File userImage;
  bool isPassportAllowed = true;
  bool isDrivingLicenceAllowed = false;
  bool isIdentityCardAllowed = false;
  bool userAgree = false;

  @override
  Widget build(BuildContext context) {
    _forms = [
      WillPopScope(
        onWillPop: () => Future.sync(this.onWillPop),
        child: formOne(),
      ),
      WillPopScope(
        onWillPop: () => Future.sync(this.onWillPop),
        child: formTwo(),
      ),
      WillPopScope(
        onWillPop: () => Future.sync(this.onWillPop),
        child: formThree(),
      ),
    ];

    return Scaffold(
      backgroundColor: lightBlue(),
      appBar: AppBar(
        backgroundColor: darkBlue(),
        title: Text(AppLocalization.of(context).verifyYourIdentity),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: _formsPageViewController,
              physics: NeverScrollableScrollPhysics(),
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
    if (userAgree) {
      _formsPageViewController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  // to navigate to the previous form
  void _previousFormStep() {
    _formsPageViewController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  bool onWillPop() {
    // if we are on the first page then it will pop the screen otherwise navigate to the privious screen
    if (_formsPageViewController.page.round() ==
        _formsPageViewController.initialPage) return true;

    _previousFormStep();

    return false;
  }

  // first form for choice the document type
  Widget formOne() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 35),
      child: Column(
        children: <Widget>[
          subtitleTextOne(),
          SizedBox(
            height: 20,
          ),
          documentTypeTile(
              icon: Icon(
                Icons.account_balance_wallet,
                size: 40,
              ),
              title: AppLocalization.of(context).passportMsg,
              subtitle: AppLocalization.of(context).facePhotoPage,
              onTap: _nextFormStep,
              enabled: isPassportAllowed),
          documentTypeTile(
              icon: Icon(
                Icons.directions_car,
                size: 40,
              ),
              title: AppLocalization.of(context).driverLicence,
              subtitle: AppLocalization.of(context).frontAndBack,
              onTap: _nextFormStep,
              enabled: isDrivingLicenceAllowed),
          documentTypeTile(
              icon: Icon(
                Icons.card_membership,
                size: 40,
              ),
              title: AppLocalization.of(context).identityCard,
              subtitle: AppLocalization.of(context).frontAndBack,
              onTap: _nextFormStep,
              enabled: isIdentityCardAllowed),
          SizedBox(
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
                activeColor: darkBlue(),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(AppLocalization.of(context)
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
      AppLocalization.of(context).selectTypeOfDocument,
      style: TextStyle(
          fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
    );
  }

  Widget documentTypeTile(
      {@required Widget icon,
      @required String title,
      @required String subtitle,
      @required Function onTap,
      @required bool enabled}) {
    return Card(
        child: ListTile(
      enabled: enabled,
      leading: icon,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue()),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: onTap,
    ));
  }

  // second form for the document file
  Widget formTwo() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          titleTextTwo(),
          SizedBox(
            height: 20,
          ),
          takeDocumentPhotoFromCamera(),
          takeDocumentPhotoFromGallery2(),
          SizedBox(
            height: 10,
          ),
          documentImage != null ? takeDocumentPhotoFromGallery() : Container(),
          buttonBarTwo()
        ],
      ),
    );
  }

  Widget titleTextTwo() {
    return Text(
      AppLocalization.of(context).passportPhotoPage,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
    );
  }

  Widget takeDocumentPhotoFromCamera() {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.camera_alt,
          size: 40,
        ),
        title: Text(
          AppLocalization.of(context).needToUseYourMobileToTake,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(AppLocalization.of(context).tapHereToContinue),
        onTap: () async {
          ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 70)
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
        leading: Icon(
          Icons.cloud_upload,
          size: 40,
        ),
        title: Text(
          AppLocalization.of(context).uploadPhotoFromDevice,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(AppLocalization.of(context).tapHereToContinue),
        onTap: () async {
          ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70)
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
          child: documentImage != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    documentImage,
                    filterQuality: FilterQuality.high,
                  ),
                )
              : Icon(
                  Icons.supervised_user_circle,
                  color: Colors.grey[200],
                  size: 300,
                ),
          height: 300,
          width: double.infinity,
        ),
      ],
    ));
  }

  Widget buttonBarTwo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        documentImage != null
            ? MaterialButton(
                child: Text(
                  AppLocalization.of(context).next,
                  style: TextStyle(color: Colors.white),
                ),
                color: darkBlue(),
                onPressed: _nextFormStep,
              )
            : Container(),
      ],
    );
  }

  // third form for the user photo
  Widget formThree() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          titleTextThree(),
          SizedBox(
            height: 20,
          ),
          takeUserPhotoFromCamera(),
          SizedBox(
            height: 10,
          ),
          userImage != null ? takeUserPhotoFromGallary() : Container(),
          buttonBarThree()
        ],
      ),
    );
  }

  Widget titleTextThree() {
    return Text(
      AppLocalization.of(context).userPhotoPage,
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 24, color: darkBlue()),
    );
  }

  Widget takeUserPhotoFromCamera() {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.camera_alt,
          size: 40,
        ),
        title: Text(
          AppLocalization.of(context).needToUseYourMobileToTake,
          style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue()),
        ),
        subtitle: Text(AppLocalization.of(context).tapHereToContinue),
        onTap: () {
          ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 70)
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
          child: userImage != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    userImage,
                    filterQuality: FilterQuality.high,
                  ),
                )
              : Icon(
                  Icons.supervised_user_circle,
                  color: Colors.grey[200],
                  size: 300,
                ),
          height: 300,
          width: double.infinity,
        ),
        SizedBox(
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
          child: Text(
            AppLocalization.of(context).previous,
            style: TextStyle(color: Colors.white),
          ),
          color: darkBlue(),
          onPressed: _previousFormStep,
        ),
        userImage != null
            ? MaterialButton(
                child: Text(
                  AppLocalization.of(context).finish,
                  style: TextStyle(color: Colors.white),
                ),
                color: darkBlue(),
                onPressed: () {
                  final _auth = AuthService();
                  final userBloc =
                      Provider.of<UserBloc>(context, listen: false);
                  // Get new token for user before attempting to post data to server
                  _auth
                      .authenticate(
                          userBloc.user.phoneNumber, userBloc.user.password)
                      .then((user) {
                    try {
                      _auth
                          .verifyUserDetail(documentImage, userImage)
                          .then((user) {
                        _auth
                            .authenticate(userBloc.user.phoneNumber,
                                userBloc.user.password)
                            .then((user) {
                          if (user.isVerified) {
                            userBloc.user = user;
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              "/dashboard",
                              (Route<dynamic> route) => false,
                            );
                          }
                        });
                      });
                    } catch (exception) {
                      Toast.show(exception, context,
                          textColor: Colors.white, backgroundColor: darkBlue());
                    }
                  });
                },
              )
            : Container(),
      ],
    );
  }

  @override
  void dispose() {
    _formsPageViewController.dispose();
    super.dispose();
  }
}
