import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/rider_registration/models/rider_registration_model.dart';
import 'package:Slydo/screens/more_apps/rider_registration/tiles/kyc_proof_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequireSteps extends StatefulWidget {
  const RequireSteps({super.key});

  @override
  State<RequireSteps> createState() => _RequireStepsState();
}

class _RequireStepsState extends State<RequireSteps> {
  bool riderType1 = false;
  bool? selected;
  String selectedOne = "";
  late RiderRegistrationBloc riderRegistrationBloc;

  List carSteps = [
    {
      "id": 0,
      "value": false,
      "title": 'Rider Photo',
      "subtitle": "Take a picture of your face for verification",
    },
    {
      "id": 1,
      "value": false,
      "title": 'Rider’s Identity Card',
      "subtitle":
          "Scan or take a picture of your NIN or International Passport.",
    },
    {
      "id": 2,
      "value": false,
      "title": 'Proof of vehicle Insurance',
      "subtitle": "Proof of vehicle Insurance",
    },
    {
      "id": 1,
      "value": false,
      "title": 'Proof of drivers license',
      "subtitle": "Upload or scan your drivers license",
    },
  ];

  List bicycleSteps = [
    {
      "id": 0,
      "value": false,
      "title": 'Rider Photo',
      "subtitle": "Take a picture of your face for verification",
    },
    {
      "id": 1,
      "value": false,
      "title": 'Rider’s Identity Card',
      "subtitle":
          "Scan or take a picture of your NIN or International Passport.",
    },
    {
      "id": 3,
      "value": false,
      "title": 'Hackney Permit : Bicycle',
      "subtitle": "Upload or scan your vehicle insurance",
    },
  ];

  List motorcycleSteps = [
    {
      "id": 0,
      "value": false,
      "title": 'Rider Photo',
      "subtitle": "Take a picture of your face for verification",
    },
    {
      "id": 1,
      "value": false,
      "title": 'Rider’s Identity Card',
      "subtitle":
          "Scan or take a picture of your NIN or International Passport.",
    },
    {
      "id": 2,
      "value": false,
      "title": 'Proof of Motorcycle Insurance',
      "subtitle": "Upload or scan your motorcycle insurance",
    },
    {
      "id": 3,
      "value": false,
      "title": 'Hackney Permit : Motorcycle',
      "subtitle": "Upload or scan your vehicle insurance",
    },
  ];

  @override
  Widget build(BuildContext context) {
    riderRegistrationBloc = Provider.of<RiderRegistrationBloc>(context);
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          backgroundColor: white,
          appBar: _buildAppBar() as PreferredSizeWidget?,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      title: Text(
        'Rider Registration',
        style: TextStyle(
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 16,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                _buildRequireSteps(),
                _buildHereWhatYouNeed(),
                SizedBox(
                  height: 40.0,
                ),
                if (riderRegistrationBloc.registrationModel?.rideTypeOptions ==
                    RideTypeOptions.car)
                  _buildList(carSteps),
                if (riderRegistrationBloc.registrationModel?.rideTypeOptions ==
                    RideTypeOptions.bicycle)
                  _buildList(bicycleSteps),
                if (riderRegistrationBloc.registrationModel?.rideTypeOptions ==
                    RideTypeOptions.motorcycle)
                  _buildList(motorcycleSteps),
              ],
            ),
          ),
          _buildSubmitBtn(),
        ],
      ),
    );
  }

  Widget _buildRequireSteps() {
    return Text(
      'Require Steps',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: blackFont,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildHereWhatYouNeed() {
    return Text(
      'Here’s what you need to do to set up your rider account.',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: darkGrey,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildList(List checkListItems) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: checkListItems.length,
      itemBuilder: (context, index) {
        return KYCProofTile(item: checkListItems[index]);
      },
    );
  }

  Widget _buildSubmitBtn() {
    return CurvedButton(
      onPressed: () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => RequireSteps(),
        //     ));
      },
      backgroundColor: greyBorderColor,
      textColor: white,
      text: 'Submit',
    );
  }
}
