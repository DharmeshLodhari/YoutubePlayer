import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_registration/models/rider_registration_model.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviewScreen extends StatefulWidget {
  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late RiderRegistrationBloc riderRegistrationBloc;

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
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(25.0),
        child: Column(
          children: [
            Expanded(
              child: riderRegistrationBloc.registrationModel?.kycTypes ==
                      KYCTypes.riderPhoto
                  ? Column(
                      children: [
                        CircleAvatar(
                          radius: 150,
                          backgroundColor: Colors.white,
                          backgroundImage: FileImage(
                            File(riderRegistrationBloc.tempPicture!.path),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          'Want to use this photo?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: blackFont,
                            fontFamily: "Inter",
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'For safety reasons, riders will see your old picture until we can confirm that this is you.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: darkGrey,
                            fontFamily: "Inter",
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image(
                        image: FileImage(
                          File(riderRegistrationBloc.tempPicture!.path),
                        ),
                      ),
                    ),
              // SizedBox(height: 10.0),,
            ),
            SizedBox(height: 20.0),
            _buildButton()
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: OutlineCurvedButton(
            text: "Retake",
            textColor: navyBlue,
            onPressed: () {
              Navigator.of(context).popAndPushNamed(Routes.TAKE_PROOF_PHOTO);
            },
            backgroundColor: white,
          ),
        ),
        SizedBox(width: 15.0),
        Expanded(
          child: CurvedButton(
            onPressed: () {
              riderRegistrationBloc.setPhotoInRegistrationModel(
                  riderRegistrationBloc.tempPicture!,
                  riderRegistrationBloc.registrationModel?.kycTypes);
              Navigator.of(context)
                  .popAndPushNamed(Routes.COMPLETED_UPLOAD_PHOTO);
            },
            backgroundColor: navyBlue,
            textColor: white,
            text: 'Use Photo',
          ),
        ),
      ],
    );
  }
}
