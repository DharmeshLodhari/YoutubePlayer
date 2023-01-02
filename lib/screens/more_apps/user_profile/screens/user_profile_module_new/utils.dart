import 'package:flutter/material.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_stacked_image.dart';


Widget followersWidget({List<UserFollowers>? userImages}) {
  int count = userImages!.length;
  if (count == 0) {
    return SizedBox();
  } else if (4 > count) {
    return buildStackedfollowersWidget(images: userImages);
  } else if (4 <= count) {
    return buildMultipleFollowersWidget(userImages: userImages);
  } else {
    return SizedBox();
  }
}


Widget buildMultipleFollowersWidget({List<UserFollowers>? userImages}) {
  final double size = 32;
  final double xShift = 10;
  return Padding(
    padding: EdgeInsets.only(right: 12),
    child: StackedWidgets(
      size: size,
      xShift: xShift,
      items: [
        ...List.generate(
            4, (index) => buildImage(userImages![index].avatar ?? "")),
        if (userImages != null && userImages.length != 4) buildfollowersCountWidget(userImages),
      ],
    ),
  );
}


Widget buildStackedfollowersWidget({
  List<UserFollowers>? images,
}) {
  if (images!.length != 0) {
    final double size = 32;
    final double xShift = 10;
    final items =
    images.map((image) => buildImage(image.avatar ?? "")).toList();

    return Padding(
      padding: EdgeInsets.only(right: 12),
      child: StackedWidgets(
        items: items,
        size: size,
        xShift: xShift,
      ),
    );
  }
  return SizedBox();
}


Widget buildfollowersCountWidget(List<UserFollowers> userFollowers) {
  int count = userFollowers.length - 4;
  return Container(
    height: 32,
    width: 32,
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