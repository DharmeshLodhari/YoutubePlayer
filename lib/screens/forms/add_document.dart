import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
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
  bool isIdentiticardAllowed = false;

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
        title: Text("Verify Yourself"),
        automaticallyImplyLeading: Platform.isAndroid ? false : true,
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
    _formsPageViewController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
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
          SizedBox(
            height: 20,
          ),
          titleTextOne(),
          SizedBox(
            height: 10,
          ),
          subtitleTextOne(),
          SizedBox(
            height: 20,
          ),
          documentTypeTile(
              icon: Icon(
                Icons.account_balance_wallet,
                size: 40,
              ),
              title: "Passport",
              subtitle: "Face photo page",
              onTap: _nextFormStep,
              enabled: isPassportAllowed),
          documentTypeTile(
              icon: Icon(
                Icons.directions_car,
                size: 40,
              ),
              title: "Driver's License",
              subtitle: "Front and Back",
              onTap: _nextFormStep,
              enabled: isDrivingLicenceAllowed),
          documentTypeTile(
              icon: Icon(
                Icons.card_membership,
                size: 40,
              ),
              title: "Identical Card",
              subtitle: "Front and Back",
              onTap: _nextFormStep,
              enabled: isIdentiticardAllowed),
        ],
      ),
    );
  }

  Widget titleTextOne() {
    return Text(
      "Verify your identity",
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 24, color: darkBlue()),
    );
  }

  Widget subtitleTextOne() {
    return Text(
      "select the type of document you want to upload",
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
      "Passport Photo page",
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
          "Need to use your mobile to take photos?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Tap hear to continue"),
        onTap: () async {
          ImagePicker.pickImage(source: ImageSource.camera).then((value) {
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
          "Upload photo from your device",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Tap hear to continue"),
        onTap: () async {
          ImagePicker.pickImage(
            source: ImageSource.gallery,
          ).then((value) {
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
//        MaterialButton(
//          child: Text(
//            "Previous",
//            style: TextStyle(color: Colors.white),
//          ),
//          color: darkBlue(),
//          onPressed: _previousFormStep,
//        ),
        documentImage != null
            ? MaterialButton(
                child: Text(
                  "Next",
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
      "User Photo page",
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
          "Need to use your mobile to take photos?",
          style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue()),
        ),
        subtitle: Text("Tap hear to continue"),
        onTap: () {
          ImagePicker.pickImage(source: ImageSource.camera).then((value) {
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
            "Previous",
            style: TextStyle(color: Colors.white),
          ),
          color: darkBlue(),
          onPressed: _previousFormStep,
        ),
        userImage != null
            ? MaterialButton(
                child: Text(
                  "Finish",
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
                            Navigator.of(context).popAndPushNamed('/dashboard');
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
}
