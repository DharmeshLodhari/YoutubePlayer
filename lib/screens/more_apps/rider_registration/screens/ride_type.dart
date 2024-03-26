import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RideType extends StatefulWidget {
  const RideType({super.key});

  @override
  State<RideType> createState() => _RideTypeState();
}

class _RideTypeState extends State<RideType> {
  late RiderRegistrationBloc riderRegistrationBloc;
  late UserBloc userBloc;
  List<String> rideType = ['Car', 'Bicycle', 'Motorcycle'];
  String selectType = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (userBloc.user.rider?.isStatusApproved() == false) {
          selectType = riderRegistrationBloc.kycDataModel?.vehicleType ?? "";
          riderRegistrationBloc.updateRideType(selectType);
          setState(() {});
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    riderRegistrationBloc = Provider.of<RiderRegistrationBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          backgroundColor: lightGrey,
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
      // shadowColor: greySecondaryYarn,
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
                Text(
                  'Select ride type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: blackFont,
                    fontFamily: "Inter",
                  ),
                ),
                Text(
                  'First step to set up your riders account.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: darkGrey,
                    fontFamily: "Inter",
                  ),
                ),
                SizedBox(height: 40),
                _buildRideTypeList(),
              ],
            ),
          ),
          _buildProceedBtn(),
        ],
      ),
    );
  }

  Widget _buildRideTypeList() {
    return ListView.builder(
      itemCount: rideType.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: 20,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: selectedListItemBackgroundBlue),
              borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(vertical: 5),
          shadowColor: boxShadowTwo,
          color: white,
          child: Container(
            decoration: decorateBox(),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildListTile(index),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile(int index) {
    return RadioListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity(horizontal: 0, vertical: -3),
      value: rideType[index],
      groupValue: selectType,
      onChanged: userBloc.user.rider?.isStatusApproved() == false
          ? null
          : (value) {
              selectType = value.toString();
              riderRegistrationBloc.updateRideType(selectType);
              // riderRegistrationBloc.registrationModel?.clearAllProof();
            },
      controlAffinity: ListTileControlAffinity.trailing,
      title: Text(
        rideType[index],
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: blackFont,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget _buildProceedBtn() {
    return CurvedButton(
      onPressed: () {
        Navigator.of(context).pushNamed(Routes.REQUIRE_STEPS);
      },
      backgroundColor: navyBlue,
      textColor: white,
      text: 'Proceed',
    );
  }
}
