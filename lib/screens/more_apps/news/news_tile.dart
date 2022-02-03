import 'dart:math';

import 'package:Slydo/screens/more_apps/news/models/NewsListItem.dart';
import 'package:Slydo/screens/more_apps/news/models/SubscriptionItem.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NewsTile extends StatefulWidget {
  final NewsListItem? newsListItem;

  const NewsTile({Key? key, this.newsListItem}) : super(key: key);

  @override
  _NewsTileState createState() => _NewsTileState();
}

class _NewsTileState extends State<NewsTile> {
  bool isSelected = Random().nextBool();

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          decoration: decorateBox(),
          child: Container(
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      child: CachedNetworkImage(
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.fill,
                        errorWidget: imageErrorWidget,
                        imageUrl: widget.newsListItem?.image ?? "",
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: -5,
                      child: IconButton(
                        icon: Icon(
                          isSelected
                              ? SlydoAppIcon.heart_1
                              : SlydoAppIcon.heart_empty,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          isSelected = !isSelected;
                          setState(() {});
                        },
                      ),
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.newsListItem?.title ?? "",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: blackFont),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.clip,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        widget.newsListItem?.description ?? "",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: darkGrey),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.clip,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class SubscriptionTile extends StatelessWidget {
  final SubscriptionItem? subscriptionItem;

  const SubscriptionTile({Key? key, this.subscriptionItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget avatarImage = Container(
        height: 48,
        width: 48,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: subscriptionItem?.image ?? "",
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.high,
            errorWidget: imageErrorWidget,
          ),
        ));

    Widget tile = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            subscriptionItem?.name ?? "",
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          leading: avatarImage,
        ),
      ),
    );

    return tile;
  }
}
