import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductAndServiceReviewTile extends StatefulWidget {
  @override
  State<ProductAndServiceReviewTile> createState() =>
      _ProductAndServiceReviewTileState();
}

class _ProductAndServiceReviewTileState
    extends State<ProductAndServiceReviewTile> {
  int rating = 0;
  UserBloc? userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return _buildUserReviewList();
  }

  Widget _buildUserReviewList() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/review-detail-screen");
      },
      child: CustomBoxShadow(
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.zero,
          shadowColor: boxShadowTwo,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuthorReviewAvatar(),
                SizedBox(
                  width: 10,
                ),
                _buildReviewDetail(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorReviewAvatar() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: userBloc!.user.avatar!,
        fit: BoxFit.fill,
        width: 30,
        height: 30,
        errorWidget: imageErrorWidget,
      ),
    );
  }

  Widget _buildReviewDetail() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReviewUserName(),
              _buildReviewDate(),
            ],
          ),
          SizedBox(
            height: 6,
          ),
          _buildRateReview(),
          SizedBox(
            height: 6,
          ),
          _buildReviewFirstValue(),
          SizedBox(
            height: 2,
          ),
          _buildReviewSecondValue(),
          SizedBox(
            height: 10,
          ),
          _buildLikeUnLikeReportTile(),
        ],
      ),
    );
  }

  Widget _buildReviewUserName() {
    return Text(
      userBloc!.user.userName!,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: blackFont,
      ),
    );
  }

  Widget _buildReviewDate() {
    return Text(
      "Jan 22, 2022",
      //getFormattedDate(),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: blackFont,
      ),
    );
  }

  Widget _buildRateReview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RatingBar.builder(
          initialRating: 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 1),
          itemBuilder: (context, _) => Icon(
            SlydoAppIcon.star,
            color: starYellow,
          ),
          itemSize: 10,
          onRatingUpdate: (rating) {
            print(rating);
          },
          unratedColor: starYellow.withOpacity(0.2),
          glowColor: starYellow.withOpacity(0.2),
        ),
      ],
    );
  }

  Widget _buildReviewFirstValue() {
    return Text(
      "Good Product",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: blackFont,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildReviewSecondValue() {
    return Text(
      "Good Product",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: blackFont,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildLikeUnLikeReportTile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReviewLike(),
              _buildReviewUnLike(),
            ],
          ),
        ),
        SizedBox(
          width: 5,
        ),
        _buildReviewReport(),
      ],
    );
  }

  Widget _buildReviewLike() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.thumb_up_alt_outlined,
              size: 16,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              "0",
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewUnLike() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.thumb_down_alt_outlined,
              size: 16,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              "12",
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewReport() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: greyBorderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.flag_outlined,
              size: 16,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              "REPORT",
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getFormattedDate() {
    String date = "";
    date = "jan 20, 2022";
    if (date != "") {
      debugPrint("Date ==> $date");
      DateFormat dateFormat = DateFormat("MMM dd, yyyy");
      DateTime dateTime = DateTime.parse(date);
      date = dateFormat.format(dateTime);
    }
    return date;
  }
}
