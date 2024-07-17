import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_registration/models/rider_registration_model.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class StepsInfo extends StatefulWidget {
  const StepsInfo({super.key});

  @override
  State<StepsInfo> createState() => _StepsInfoState();
}

class _StepsInfoState extends State<StepsInfo> {
  late RiderRegistrationBloc riderRegistrationBloc;
  late UserBloc userBloc;
  List<Map<String, dynamic>> kycProof = [
    {
      "type": KYCTypes.riderPhoto,
      "title": 'Take your profile photo',
      "subtitle":
          "Your profile photo helps people recognize you. Please note that once you have submitted your profile photo, it cannot be changed.",
      "note":
          "1. Face the camera and make sure your eyes and mouth are clearly visible.\n2. Make sure the photo is well lit , Avoid harsh shadow and overly dim settings.\n3. Dress properly and ensure no filter",
      "image": "assets/images/rider_photo.png",
      // "imageText": "Example",
    },
    {
      "type": KYCTypes.identityCard,
      "title": 'Take your Identity Card Photo',
      "subtitle":
          "All four sides of the card should be photographed. Ensure the ID number is clearly visible in the image.",
      "note": "",
      "image": "assets/images/take_photo.svg",
      // "imageText": "Upload or take photo of your original Identity card.",
    },
    {
      "type": KYCTypes.vehicleInsurance,
      "title": 'Take a photo of your vehicle insurance document',
      "subtitle":
          "All four sides of the card should be photographed. Ensure the necessary details and numbers is clearly visible in the image.",
      "note": "",
      "image": "assets/images/take_photo2.svg",
      // "imageText":
      //     "Upload or take photo of your original vehicle insurance document.",
    },
    {
      "type": KYCTypes.hackneyPermit,
      "title": 'Take a photo of your Hackney Permit',
      "subtitle":
          "All four sides of the card should be photographed. Ensure the necessary details and numbers is clearly visible in the image.",
      "note": "",
      "image": "assets/images/take_photo3.svg",
      // "imageText":
      //     "Upload or take photo of your original Hackney permit document.",
    },
    {
      "type": KYCTypes.drivingLicense,
      "title": 'Take your Driving License Photo',
      "subtitle":
          "All four sides of the card should be photographed. Ensure the ID number is clearly visible in the image.",
      "note": "",
      "image": "assets/images/take_photo.svg",
      // "imageText": "Upload or take photo of your original Identity card.",
    },
  ];

  Map<String, dynamic> getListObjectByType() {
    for (Map<String, dynamic> data in kycProof) {
      if (data["type"] == riderRegistrationBloc.registrationModel?.kycTypes) {
        return data;
      }
    }
    return {};
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
      surfaceTintColor: Colors.transparent,
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
      padding: const EdgeInsets.all(16.0),
      child: _buildScreen(getListObjectByType()),
    );
  }

  Widget _buildScreen(Map<String, dynamic> details) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStepsInfo(details),
        Expanded(child: _buildImageAndINfo(details)),
        const SizedBox(height: 30.0),
        _buildTakePhotoBtn(),
      ],
    );
  }

  Widget _buildStepsInfo(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          details["title"],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: blackFont,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(height: 10.0),
        Text(
          details["subtitle"],
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: darkGrey,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(height: 5.0),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            details["note"],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: darkGrey,
              fontFamily: "Inter",
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageAndINfo(Map<String, dynamic> details) {
    return details["type"] == KYCTypes.riderPhoto
        ? _buildRiderPhoto(details["image"])
        : _builderTakePhoto(details["image"]);
  }

  Widget _buildRiderPhoto(String image) {
    return riderRegistrationBloc.registrationModel?.mRiderPhoto != null
        ? CircleAvatar(
            radius: 130,
            backgroundColor: Colors.white,
            backgroundImage: FileImage(
              File(riderRegistrationBloc.registrationModel?.mRiderPhoto!.path ??
                  ""),
            ),
          )
        : userBloc.user.rider?.isStatusApproved() == false
            ? CircleAvatar(
                radius: 130,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  riderRegistrationBloc.kycDataModel?.selfie ?? "",
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    image,
                    width: 250,
                    height: 250,
                    fit: BoxFit.fill,
                  ),
                ],
              );
  }

  Widget _builderTakePhoto(String image) {
    return riderRegistrationBloc.registrationModel?.getCurrentTypePhoto() !=
            null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image(
              image: FileImage(
                File(riderRegistrationBloc.registrationModel
                        ?.getCurrentTypePhoto()
                        ?.path ??
                    ""),
              ),
            ),
          )
        : userBloc.user.rider?.isStatusApproved() == false
            ? ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image(
                  image: NetworkImage(
                    riderRegistrationBloc.getUploadKYCTypePhoto() ?? "",
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    image,
                    fit: BoxFit.fill,
                  ),
                ],
              );
  }

  Widget _buildTakePhotoBtn() {
    return CurvedButton(
      onPressed: () async {
        Navigator.of(context).pushNamed(Routes.TAKE_PROOF_PHOTO);
      },
      backgroundColor: navyBlue,
      textColor: white,
      text: riderRegistrationBloc.registrationModel?.getCurrentTypePhoto() !=
                  null ||
              userBloc.user.rider?.isStatusApproved() == false
          ? 'Change Photo'
          : 'Take photo',
    );
  }
}
