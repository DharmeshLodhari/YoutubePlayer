import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/review/models/review.dart';
import 'package:Slydo/screens/more_apps/review/review_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReviewTile extends StatefulWidget {
  Review? review;
  CustomerProfile? reviewedUser;
  Product? product;
  Service? service;
  bool? isNavigable;

  ReviewTile({
    this.review,
    this.reviewedUser,
    this.isNavigable = true,
    this.product,
    this.service,
  });

  @override
  State<ReviewTile> createState() => _ReviewTileState();
}

class _ReviewTileState extends State<ReviewTile> {
  UserBloc? userBloc;

  bool isAuthor = false;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    if (userBloc!.user.userName == widget.review!.authorUsername) {
      isAuthor = true;
    }

    return _buildReviewList();
  }

  Widget _buildReviewList() {
    return GestureDetector(
      onTap: widget.isNavigable!
          ? () async {
              if (isAuthor) {
                var result = await Navigator.of(context).pushNamed(
                  "/edit-review",
                  arguments: {
                    "review": widget.review,
                    "reviewedUser": widget.reviewedUser,
                    "reviewedProduct": widget.product,
                    "reviewedService": widget.service,
                  },
                );

                if (result != null) {
                  if (result is Review) {
                    widget.review = result;
                    setState(() {});
                  }
                }
              } else {
                Navigator.of(context).pushNamed(
                  "/review-detail-screen",
                  arguments: {
                    "review": widget.review,
                    "reviewedUser": widget.reviewedUser,
                    "reviewedProduct": widget.product,
                    "reviewedService": widget.service,
                  },
                );
              }
            }
          : null,
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
        imageUrl: widget.review?.authorAvatar ?? userBloc!.user.avatar!,
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
          SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReviewUserName(),
              _buildReviewDate(),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          _buildRateReview(),
          SizedBox(
            height: 6,
          ),
          _buildReviewFirstValue(),
          getLikeUnlikeReportTile(),
        ],
      ),
    );
  }

  // URL https://api.slydo.co/api/v1/social/review/users/brijesh.sakariya/ STATUS CODE:- 200 BODY:- {"id":"04f49cdb-efc9-4880-beff-aab96f75fd9f","rating":{"id":"ce4cfb71-c999-4baa-9698-c5ca5561ccaf","rating":4,"overall_rating":{"rating":"3.5","number_of_ratings":2}},"author_avatar":"https://slydo-assets.s3.amazonaws.com/media/customer/avatar/4f4470b6dbf44b62859ddf2b945d7472.jpg","text":"Nice  work awesome","author_username":"black","likes":0,"dislikes":0,"created_at":"2022-01-20T04:58:29.716134+01:00","model_object":"c29af3e9-37a0-4f9c-a951-4e607168e515"}

  Widget getLikeUnlikeReportTile() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        _buildLikeUnLikeReportTile(),
      ],
    );
  }

  Widget _buildReviewUserName() {
    return Text(
      widget.review?.authorUsername ?? userBloc!.user.userName!,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: blackFont,
      ),
    );
  }

  Widget _buildReviewDate() {
    return Text(
      getFormattedDate(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: darkGrey,
      ),
    );
  }

  Widget _buildRateReview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RatingBar.builder(
          initialRating: widget.review!.rating == null
              ? 0
              : widget.review!.rating!.toDouble(),
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 1),
          itemBuilder: (context, _) => Icon(
            SlydoAppIcon.star,
            color: starYellow,
          ),
          itemSize: 12,
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
      messageDecoderWithEmoji(widget.review?.text ?? "")!,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: blackFont,
      ),
      maxLines: 2,
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildLikeUnLikeReportTile() {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReviewLike(),
              SizedBox(
                width: 12,
              ),
              _buildReviewUnLike(),
            ],
          ),
        ),

        Expanded(child: Container())
        // _buildReviewReport(),
      ],
    );
  }

  Widget _buildReviewLike() {
    return GestureDetector(
      onTap: isAuthor ? null : likeUnlikeReview,
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
              widget.review?.likes.toString() ?? "",
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

  void likeUnlikeReview() async {
    await ReviewAuth().likeReview(widget.review!).then((value) {
      widget.review = value;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("Error:- $error");
      showToast(message: "$error");
    });
  }

  void dislikeUnlikeReview() async {
    await ReviewAuth().dislikeReview(widget.review!).then((value) {
      widget.review = value;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("Error:- $error");
      showToast(message: "$error");
    });
  }

  Widget _buildReviewUnLike() {
    return GestureDetector(
      onTap: isAuthor ? null : dislikeUnlikeReview,
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
              widget.review?.dislikes.toString() ?? "",
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
    date = widget.review?.createdAt ?? "";
    if (date != "") {
      debugPrint("Date ==> $date");
      DateFormat dateFormat = DateFormat("MMM dd, yyyy");
      DateTime dateTime = DateTime.parse(date);
      date = dateFormat.format(dateTime);
    }
    return date;
  }
}
