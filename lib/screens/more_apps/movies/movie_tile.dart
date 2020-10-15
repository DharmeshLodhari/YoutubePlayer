import 'dart:math';

import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MovieTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            leading: Container(
              height: 68,
              width: 68,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl:
                      "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dawn Of Thunder",
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: blackFont,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      SlydoAppIcon.star,
                      color: starYellow,
                      size: 12,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "7.8",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: blackFont,
                      ),
                    )
                  ],
                ),
              ],
            ),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  SlydoAppIcon.naira,
                  color: navyBlue,
                  size: 10,
                ),
                Text(
                  "34.00",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: navyBlue,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class MovieTileWithHeart extends StatefulWidget {
  @override
  _MovieTileWithHeartState createState() => _MovieTileWithHeartState();
}

class _MovieTileWithHeartState extends State<MovieTileWithHeart> {
  bool isChange = false;

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            leading: Container(
              height: 68,
              width: 68,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl:
                      "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dawn Of Thunder",
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: blackFont,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      SlydoAppIcon.star,
                      color: starYellow,
                      size: 12,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "7.8",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: blackFont,
                      ),
                    )
                  ],
                ),
              ],
            ),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  SlydoAppIcon.naira,
                  color: navyBlue,
                  size: 10,
                ),
                Text(
                  "34.00",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: navyBlue,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isChange ? SlydoAppIcon.heart_empty : SlydoAppIcon.heart_1,
                color: isChange ? blackFont : navyBlue,
                size: 20,
              ),
              onPressed: () {
                isChange = !isChange;
                setState(() {});
              },
            ),
          ),
        ));
  }
}

class MovieTileGeneral extends StatefulWidget {
  @override
  _MovieTileGeneralState createState() => _MovieTileGeneralState();
}

class _MovieTileGeneralState extends State<MovieTileGeneral> {
  bool isDownloaded = Random().nextBool();

  bool isChange = Random().nextBool();

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            leading: Container(
              height: 68,
              width: 68,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl:
                      "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dawn Of Thunder",
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: blackFont,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      SlydoAppIcon.star,
                      color: starYellow,
                      size: 12,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "7.8",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: blackFont,
                      ),
                    )
                  ],
                ),
              ],
            ),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  SlydoAppIcon.naira,
                  color: navyBlue,
                  size: 10,
                ),
                Text(
                  "34.00",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: navyBlue,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isDownloaded
                    ? SlydoAppIcon.video_play
                    : isChange
                        ? SlydoAppIcon.heart_empty
                        : SlydoAppIcon.heart_1,
                color: isDownloaded
                    ? navyBlue
                    : isChange
                        ? blackFont
                        : navyBlue,
                size: 20,
              ),
              onPressed: () {
                isChange = !isChange;
                setState(() {});
              },
            ),
          ),
        ));
  }
}
