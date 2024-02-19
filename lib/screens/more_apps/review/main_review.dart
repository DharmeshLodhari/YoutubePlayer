import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MainReview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context) as PreferredSizeWidget?,
      backgroundColor: Colors.white,
      body: scaffoldBody(),
    );
  }

  Widget appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Review",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: List.generate(
              10,
              (index) => Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ReviewTile(),
                  )),
        ),
      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl:
                            "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: imageErrorWidget,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    "Jamé Smith",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: blackFont),
                  )
                ],
              ),
              Text(
                "20 Aug",
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w400, color: darkGrey),
              )
            ],
          ),
          SizedBox(
            height: 16,
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
              Icon(
                SlydoAppIcon.star,
                color: starYellow,
                size: 11,
              ),
              SizedBox(
                width: 4,
              ),
              Icon(
                SlydoAppIcon.star,
                color: starYellow,
                size: 11,
              ),
              SizedBox(
                width: 4,
              ),
              Icon(
                SlydoAppIcon.star,
                color: starYellow,
                size: 11,
              ),
              SizedBox(
                width: 4,
              ),
              Icon(
                SlydoAppIcon.star,
                color: greyBorderColor,
                size: 11,
              ),
              SizedBox(
                width: 4,
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "Very knowledgeable about all the history, really friendly, always smile, and always up for a chat.",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: blackFont),
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: 8,
          ),
          Divider(
            thickness: 1,
            height: 4,
            color: dividerColor,
          ),
        ],
      ),
    );
  }
}
