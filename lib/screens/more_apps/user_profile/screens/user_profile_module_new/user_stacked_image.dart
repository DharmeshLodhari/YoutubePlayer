import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/util.dart';

class StackedWidgets extends StatelessWidget {
  final List<Widget> items;
  final TextDirection direction;
  final double size;
  final double xShift;

  const StackedWidgets({
    super.key,
    required this.items,
    this.direction = TextDirection.ltr,
    this.size = 100,
    this.xShift = 20,
  });

  @override
  Widget build(BuildContext context) {
    final allItems = items
        .asMap()
        .map((index, item) {
          final left = size - xShift;

          final value = Container(
            width: size,
            height: size,
            margin: EdgeInsets.only(left: left * index),
            child: item,
          );

          return MapEntry(index, value);
        })
        .values
        .toList();

    return Stack(
      children: direction == TextDirection.ltr
          ? allItems.reversed.toList()
          : allItems,
    );
  }
}

Widget buildImage(String urlImage, String fullName, String userType) {
  const double borderSize = 2;
  final Color borderColor = getUserTypeColorByType(type: userType);

  if (urlImage == "" ||
      urlImage ==
          "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
    return ClipOval(
      child: Container(
        padding: const EdgeInsets.all(borderSize),
        color: Colors.white,
        child: CircleAvatar(
          backgroundColor: navyBlue,
          radius: 10,
          child: Text(
            getInitials(fullName).toUpperCase(),
            style: TextStyle(
                color: white, fontWeight: FontWeight.w600, fontSize: 10),
          ),
        ),
      ),
    );
  } else {
    return ClipOval(
      child: Container(
        // padding: EdgeInsets.all(borderSize),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          shape: BoxShape.circle,
        ),
        // color: Colors.white,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: urlImage,
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
          ),
        ),
      ),
    );
  }

  // return ClipOval(
  //   child: Container(
  //     padding: EdgeInsets.all(borderSize),
  //     color: Colors.white,
  //     child: ClipOval(
  //       child: CachedNetworkImage(
  //         imageUrl: urlImage,
  //         fit: BoxFit.cover,
  //         errorWidget: imageErrorWidget,
  //       ),
  //     ),
  //   ),
  // );
}
