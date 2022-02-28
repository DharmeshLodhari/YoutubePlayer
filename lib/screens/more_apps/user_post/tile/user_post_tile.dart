import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostTile extends StatefulWidget {
  UserPost? post;
  CustomerProfile? postOfUser;
  bool? isNavigable;

  PostTile({Key? key, this.post, this.postOfUser, this.isNavigable = true})
      : super(key: key);

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  UserBloc? userBloc;
  bool isAuthor = false;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    if (userBloc!.user.userName == widget.post!.authorUsername) {
      isAuthor = true;
    }
    return _buildUserPostList();
  }

  Widget _buildUserPostList() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/user-post-detail", arguments: {
          "post": widget.post!,
          "postOfUser": widget.postOfUser!
        });
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          decoration: decorateBox(),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: CachedNetworkImage(
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.fill,
                        errorWidget: imageErrorWidget,
                        imageUrl: widget.post?.image ?? "",
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
                        messageDecoderWithEmoji(widget.post?.title) ?? "",
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
                        messageDecoderWithEmoji(widget.post?.tagLine) ?? "",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: darkGrey),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.clip,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      widget.post!.enableLike!
                          ? _buildLikeUnLikeReportTile()
                          : SizedBox.shrink()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
                width: 16,
              ),
              _buildPostUnLike(),
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
      onTap: isAuthor ? null : likeUnlikePost,
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
              widget.post?.likes.toString() ?? "",
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

  void likeUnlikePost() async {
    await UserPostAuth().likeUserPost(widget.post!).then((value) {
      widget.post = value;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("Error:- $error");
      showToast(message: "$error");
    });
    // await UserReviewAuth()
    //     .unlikeUserReview(widget.review!)
    //     .then((value) {})
    //     .catchError((error) {
    //   debugPrint("Error:- $error");
    //   showToast(message: "$error");
    // });
  }

  void dislikeUnlikePost() async {
    await UserPostAuth().dislikeUserPost(widget.post!).then((value) {
      widget.post = value;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("Error:- $error");
      showToast(message: "$error");
    });
    // await UserReviewAuth()
    //     .unlikeUserReview(widget.review!)
    //     .then((value) {})
    //     .catchError((error) {
    //   debugPrint("Error:- $error");
    //   showToast(message: "$error");
    // });
  }

  Widget _buildPostUnLike() {
    return GestureDetector(
      onTap: isAuthor ? null : dislikeUnlikePost,
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
              widget.post?.dislikes.toString() ?? "",
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
}
