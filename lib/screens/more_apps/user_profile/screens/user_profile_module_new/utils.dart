import 'package:flutter/material.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_stacked_image.dart';

import '../../../yarn/models/Topics/yarn_model.dart';


Widget getFollowersWidget(widget, {double radiusSize: 32, double radiusShift: 10, double radiusHeight: 32, double radiusWidth: 32}) {
  List<UserFollowers> viewers = [];

  if (widget.yarn.viewersAvatars != null) {
    for (ViewersAvatars avatars in widget.yarn.viewersAvatars!) {
      UserFollowers follower = UserFollowers(avatar: avatars.avatar!);
      viewers.add(follower);
    }
  }
  return followersWidget(userImages: viewers, radiusSize: radiusSize, radiusShift: radiusShift, radiusHeight: radiusHeight, radiusWidth: radiusWidth);
}


Widget followersWidget({List<UserFollowers>? userImages, double radiusSize: 32, double radiusShift: 10, double radiusHeight: 32, double radiusWidth: 32}) {
  int count = userImages!.length;
  if (count == 0) {
    return SizedBox();
  } else if (4 > count) {
    return buildStackedfollowersWidget(images: userImages, radiusSize: radiusSize, radiusShift: radiusShift);
  } else if (4 <= count) {
    return buildMultipleFollowersWidget(userImages: userImages, radiusSize: radiusSize, radiusShift: radiusShift, radiusHeight: radiusHeight, radiusWidth: radiusWidth);
  } else {
    return SizedBox();
  }
}


Widget buildfollowersCountWidget(List<UserFollowers> userFollowers, {userImages, double radiusHeight: 32, double radiusWidth: 32}) {
  int count = userFollowers.length - 4;
  return Container(
    height: radiusHeight,
    width: radiusWidth,
    padding: EdgeInsets.all(2),
    child: ClipOval(
      child: Container(
        color: Colors.black,
        child: Center(
            child: Text(
              "+$count",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )),
      ),
    ),
  );
}


Widget buildStackedfollowersWidget({
  List<UserFollowers>? images, double radiusSize: 32, double radiusShift: 10
}) {
  if (images!.length != 0) {
    final items =
    images.map((image) => buildImage(image.avatar ?? "")).toList();

    return Padding(
      padding: EdgeInsets.only(right: 12),
      child: StackedWidgets(
        items: items,
        size: radiusSize,
        xShift: radiusShift,
      ),
    );
  }
  return SizedBox();
}


Widget buildMultipleFollowersWidget({List<UserFollowers>? userImages, double radiusSize: 32, double radiusShift: 10, double radiusHeight: 32, radiusWidth: 32}) {
  return Padding(
    padding: EdgeInsets.only(right: 12),
    child: StackedWidgets(
      size: radiusSize,
      xShift: radiusShift,
      items: [
        ...List.generate(
            4, (index) => buildImage(userImages![index].avatar ?? "")),
        if (userImages != null && userImages.length != 4) buildfollowersCountWidget(userImages, radiusWidth: radiusWidth, radiusHeight: radiusHeight),
      ],
    ),
  );
}
