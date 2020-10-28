import 'dart:math';

import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MusicTile extends StatelessWidget {
  String imageUrl;
  MusicTile({this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.fill,
                    height: 86,
                    width: 68,
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Container(
                    height: 86,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Thu, Oct 15 • 6:54 AM",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: mateRed,
                          ),
                        ),
                        flexibleSpace(flex: 2),
                        Text(
                          "5th Borough food festival",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: blackFont,
                          ),
                        ),
                        flexibleSpace(),
                        Text(
                          "Clove lakes park",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: blackFont,
                          ),
                        ),
                        flexibleSpace(flex: 5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class MusicTileWithHeart extends StatefulWidget {
  @override
  _MusicTileWithHeartState createState() => _MusicTileWithHeartState();
}

class _MusicTileWithHeartState extends State<MusicTileWithHeart> {
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
                      "https://www.naijaloaded.com.ng/wp-content/uploads/2019/10/erigga.jpg",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Are you happy? ",
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: blackFont,
                  ),
                ),
                Text(
                  "SHY Martin",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: blackFont,
                  ),
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

class MusicTileGeneral extends StatefulWidget {
  @override
  _MusicTileGeneralState createState() => _MusicTileGeneralState();
}

class _MusicTileGeneralState extends State<MusicTileGeneral> {
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
                      "https://www.musicinafrica.net/sites/default/files/styles/article_slider_large/public/images/article/202008/djcuppy21.jpg?itok=ruxfue_g",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Run it down",
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: blackFont,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              "Run it down",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: blackFont,
              ),
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

class PartnerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl:
                    "https://cdn.thewhistler.ng/wp-content/uploads/2020/06/ChiNna-Okoroafor-2.jpg",
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Bond street dojo",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: blackFont),
                ),
                SizedBox(
                  width: 8,
                ),
                Row(
                  children: [
                    Icon(
                      SlydoAppIcon.star,
                      color: starYellow,
                      size: 11,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "7.8 • Renter Friendly",
                      style: TextStyle(
                          fontSize: 12,
                          color: blackFont,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 16,
          ),
          Column(
            children: <Widget>[
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: navyBlue,
                size: 16,
              )
            ],
          ),
        ],
      ),
    );
  }
}
