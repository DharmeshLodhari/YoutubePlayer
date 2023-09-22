import 'package:flutter/material.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_stacked_image.dart';
import '../../../yarn/models/Topics/yarn_model.dart';

Widget getFollowersWidget(widget,
    {double radiusSize: 32,
    double radiusShift: 10,
    double radiusHeight: 32,
    double radiusWidth: 32}) {
  List<UserFollowers> viewers = [];

  if (widget.yarn.viewersAvatars != null) {
    for (ViewersAvatars avatars in widget.yarn.viewersAvatars!) {
      UserFollowers follower = UserFollowers(avatar: avatars.avatar!);
      viewers.add(follower);
    }
  }
  return followersWidget(
      userImages: viewers,
      radiusSize: radiusSize,
      radiusShift: radiusShift,
      radiusHeight: radiusHeight,
      radiusWidth: radiusWidth);
}

Widget followersWidget(
    {List<UserFollowers>? userImages,
    double radiusSize: 32,
    double radiusShift: 10,
    double radiusHeight: 32,
    double radiusWidth: 32}) {
  int count = userImages!.length;
  if (count == 0) {
    return SizedBox();
  } else if (4 > count) {
    return buildStackedFollowersWidget(
        images: userImages, radiusSize: radiusSize, radiusShift: radiusShift);
  } else if (4 <= count) {
    return buildMultipleFollowersWidget(
        userImages: userImages,
        radiusSize: radiusSize,
        radiusShift: radiusShift,
        radiusHeight: radiusHeight,
        radiusWidth: radiusWidth);
  } else {
    return SizedBox();
  }
}

Widget buildFollowersCountWidget(List<UserFollowers> userFollowers,
    {userImages, double radiusHeight: 32, double radiusWidth: 32}) {
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

Widget buildStackedFollowersWidget(
    {List<UserFollowers>? images,
    double radiusSize: 32,
    double radiusShift: 10}) {
  if (images!.length != 0) {
    final items = images
        .map((image) => buildImage(image.avatar ?? '', image.fullName ?? ''))
        .toList();

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

Widget buildMultipleFollowersWidget(
    {List<UserFollowers>? userImages,
    double radiusSize: 32,
    double radiusShift: 10,
    double radiusHeight: 32,
    radiusWidth: 32}) {
  return Padding(
    padding: EdgeInsets.only(right: 12),
    child: StackedWidgets(
      size: radiusSize,
      xShift: radiusShift,
      items: [
        ...List.generate(
            4,
            (index) => buildImage(userImages![index].avatar ?? "",
                userImages[index].fullName ?? '')),
        if (userImages != null && userImages.length != 4)
          buildFollowersCountWidget(userImages,
              radiusWidth: radiusWidth, radiusHeight: radiusHeight),
      ],
    ),
  );
}

String capitalizeAndRemoveUnderscores(String input) {
  if (input == null || input.isEmpty) {
    return input;
  }

  // Split the input string by underscores
  List<String> parts = input.split('_');

  // Capitalize the first letter of each part
  parts = parts.map((part) {
    if (part.isNotEmpty) {
      return part[0].toUpperCase() + part.substring(1);
    }
    return part;
  }).toList();

  // Join the parts back together with spaces
  String result = parts.join(' ');

  return result;
}

bool compareMaps(Map<String, bool> map1, Map<String, bool> map2) {
  // Check if both maps have the same length.
  if (map1.length != map2.length) {
    return false;
  }

  // Iterate through the keys in map1.
  for (var key in map1.keys) {
    // Check if the key exists in map2.
    if (!map2.containsKey(key)) {
      return false;
    }

    // Check if the values for the same key are different.
    if (map1[key] != map2[key]) {
      return false;
    }
  }

  // If all keys and values match, the maps are equal.
  return true;
}
