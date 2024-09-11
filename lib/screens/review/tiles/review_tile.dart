import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/review/models/review.dart';
import 'package:Slydo/screens/review/review_auth.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReviewTile extends StatefulWidget {
  late final Review? review;
  final CustomerProfile? reviewedUser;
  final Product? product;
  final Service? service;
  final bool? isNavigable;

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
  Review? _review;

  @override
  void initState() {
    super.initState();
    _review = widget.review;
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('REVIEW LIKED :: ${_review!.likes}');
    userBloc = Provider.of<UserBloc>(context);
    if (userBloc!.user.userName == _review!.authorUsername) {
      isAuthor = true;
    }

    return _buildReviewList();
  }

  Widget _buildReviewList() {
    return GestureDetector(
      onTap: widget.isNavigable!
          ? () async {
              if (isAuthor) {
                final result = await Navigator.of(context).pushNamed(
                  "/edit-review",
                  arguments: {
                    "review": _review,
                    "reviewedUser": widget.reviewedUser,
                    "reviewedProduct": widget.product,
                    "reviewedService": widget.service,
                  },
                );

                if (result != null) {
                  if (result is Review) {
                    _review = result;
                    setState(() {});
                  }
                }
              } else {
                Navigator.of(context).pushNamed(
                  "/review-detail-screen",
                  arguments: {
                    "review": _review,
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
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          shadowColor: boxShadowTwo,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuthorReviewAvatar(),
                const SizedBox(width: 10),
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
        imageUrl: _review?.authorAvatar ?? userBloc!.user.avatar!,
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
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReviewUserName(),
              _buildReviewDate(),
            ],
          ),
          const SizedBox(height: 8),
          _buildRateReview(),
          const SizedBox(height: 6),
          _buildReviewFirstValue(),
          const SizedBox(height: 10),
          _buildLikeUnLikeReportTile(),
        ],
      ),
    );
  }

  Widget _buildReviewUserName() {
    return Text(
      _review?.authorUsername ?? userBloc!.user.userName!,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: fontDarkGrey,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildReviewDate() {
    return Text(
      getFormattedDate(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: fontLightGrey,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildRateReview() {
    return getRating(numberOfRating: _review!.rating);
  }

  Widget _buildReviewFirstValue() {
    return Text(
      messageDecoderWithEmoji(_review?.text ?? "")!,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: blackFont,
        fontFamily: "Inter",
      ),
      maxLines: 2,
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildLikeUnLikeReportTile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildReviewLike(),
            const SizedBox(
              width: 20,
            ),
            _buildReviewUnLike(),
          ],
        ),
        _buildReviewReport(),
      ],
    );
  }

  Widget _buildReviewLike() {
    return GestureDetector(
      onTap: isAuthor ? null : likeUnlikeReview,
      child: Row(
        children: [
          const Icon(
            Icons.thumb_up_alt_outlined,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            _review?.likes == null ? "0" : _review!.likes.toString(),
            style: TextStyle(
              color: fontDarkGrey,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }

  void likeUnlikeReview() async {
    await ReviewAuth().likeReview(_review!).then((value) {
      _review = value;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("Error:- $error");
      showToast(message: "$error");
    });
  }

  void dislikeUnlikeReview() async {
    await ReviewAuth().dislikeReview(_review!).then((value) {
      _review = value;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("Error:- $error");
      showToast(message: "$error");
    });
  }

  Widget _buildReviewUnLike() {
    return GestureDetector(
      onTap: isAuthor ? null : dislikeUnlikeReview,
      child: Row(
        children: [
          const Icon(
            Icons.thumb_down_alt_outlined,
            size: 16,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            _review?.dislikes == null ? "0" : _review!.dislikes.toString(),
            style: TextStyle(
              color: fontDarkGrey,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewReport() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(
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
            const Icon(
              Icons.flag_outlined,
              size: 16,
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              "REPORT",
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getFormattedDate() {
    String date = "";
    date = _review?.createdAt ?? "";
    if (date != "") {
      // debugPrint("Date ==> $date");
      final DateFormat dateFormat = DateFormat("MMM dd, yyyy");
      final DateTime dateTime = DateTime.parse(date);
      date = dateFormat.format(dateTime);
    }
    return date;
  }
}
