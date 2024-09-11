import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class MomentsUtils {
  String? getGetMomentDetailDateTime(String dateTime) {
    // return toTimeAgoLabel(dateTime: DateTime.parse(dateTime));
    return elapsedTime(dateTime: DateTime.parse(dateTime));
  }

  Widget getUserProfilePic(String image, String fullName) {
    if (image == "" ||
        image ==
            "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 12,
        child: Text(
          getInitials(fullName).toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w600),
        ),
      );
    } else {
      return SizedBox(
        width: 35,
        child: getCircularUserAvatar(image),
      );
    }
  }
}
