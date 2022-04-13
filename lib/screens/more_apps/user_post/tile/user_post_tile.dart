import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/news/CustomChip.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/post_detail_page.dart';
import 'package:Slydo/utils/enums.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/utils/video_player_controller/chewie_progress_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';

import '../../../../locale/app_localization.dart';
import '../../../../utils/slydo_app_icon_icons.dart';
import '../../../../utils/video_player_controller/chewie_player.dart';
import '../../../../widget/bottom_sheet_item.dart';
import '../../../../widget/dialog.dart';
import '../../../../widget/rounded_background_icon.dart';

class PostTile extends StatefulWidget {
  UserPost? post;
  bool? isNavigable;
  Function onDeleteBlog;

  PostTile(
      {Key? key,
      this.post,
      required this.onDeleteBlog,
      this.isNavigable = true})
      : super(key: key);

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  UserBloc? userBloc;
  bool isAuthor = false;
  bool isSelected = false;
  ChewieController? _chewieMainController;
  VideoPlayerController? _mainVideoController;

  @override
  void initState() {
    super.initState();
    if (widget.post?.video != null) {
      _mainVideoController = VideoPlayerController.network(widget.post!.video!);

      _chewieMainController = ChewieController(
          videoPlayerController: _mainVideoController!,
          aspectRatio: 16 / 9,
          allowFullScreen: false,
          systemOverlaysAfterFullScreen: SystemUiOverlay.values,
          autoInitialize: true,
          materialProgressColors: ChewieProgressColors(
            backgroundColor: Colors.transparent,
            handleColor: Colors.transparent,
            bufferedColor: Colors.transparent,
            playedColor: Colors.transparent,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    if (userBloc!.user.userName == widget.post!.authorUsername) {
      isAuthor = true;
    }

    return _buildUserPostList();
  }

  @override
  void dispose() {
    if (widget.post?.video != null) {
      _mainVideoController!.dispose();
      _chewieMainController!.dispose();
    }

    super.dispose();
  }

  Widget _buildUserPostList() {
    return GestureDetector(
      onLongPress: () => showUserProfileActionsSheet(),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return PostDetailPage(
                postId: widget.post!.id,
                postType: PostType.blog,
                onDeleteBlog: () {
                  widget.onDeleteBlog();
                },
              );
            },
          ),
        );
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
                      child: widget.post?.video != null
                          ? Chewie(
                              posterUrl: widget.post?.image,
                              controller: _chewieMainController!,
                            )
                          : CachedNetworkImage(
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.fill,
                              errorWidget: imageErrorWidget,
                              imageUrl: widget.post?.image ?? "",
                            ),
                    ),
                    // Positioned(
                    //   right: 0,
                    //   top: -5,
                    //   child: IconButton(
                    //     icon: Icon(
                    //       isSelected
                    //           ? SlydoAppIcon.heart_1
                    //           : SlydoAppIcon.heart_empty,
                    //       color: Colors.white,
                    //       size: 20,
                    //     ),
                    //     onPressed: () {
                    //       isSelected = !isSelected;
                    //       setState(() {});
                    //     },
                    //   ),
                    // ),
                    widget.post!.isPublished!
                        ? SizedBox.shrink()
                        : Positioned(
                            left: 10,
                            top: 10,
                            child: CustomChip(
                              textColor: blackFont,
                              color: starYellow,
                              text: 'Unpublished',
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                            ),
                          ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: 15, top: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              messageDecoderWithEmoji(widget.post?.title) ?? "",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: blackFont),
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          InkWell(
                            onTap: () => showUserProfileActionsSheet(),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(SlydoAppIcon.menu, size: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        messageDecoderWithEmoji(widget.post?.tagLine) ?? "",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: darkGrey),
                        maxLines: 3,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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

  void showUserProfileActionsSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: generateBottomSheetItem(),
                ),
              ));
        });
  }

  List<Widget> generateBottomSheetItem() {
    List<Widget> list = [];

    list.add(
      bottomSheetItem(
        title: AppLocalization.of(context)!.share,
        icon: SlydoAppIcon.share,
        onTap: () {
          Navigator.pop(context);
          var shareBody =
              "https://merchant.slydo.co/${widget.post!.authorUsername}/blog/${widget.post!.id}";
          Share.share(shareBody, subject: "${widget.post!.authorName}");
        },
      ),
    );

    list.add(
      bottomSheetItem(
        title: "Share in Chat",
        icon: SlydoAppIcon.text_message,
        onTap: () async {
          Navigator.pop(context);
          UserPostUtils.sendPostToUserInChat(
            context: context,
            userPost: widget.post!,
          );
        },
      ),
    );

    list.add(
      bottomSheetItem(
        title: AppLocalization.of(context)!.editPost,
        icon: SlydoAppIcon.edit,
        onTap: () async {
          Navigator.pop(context);
          await Navigator.pushNamed(context, '/create-blog',
              arguments: widget.post);
        },
      ),
    );

    list.add(
      bottomSheetItem(
        title: AppLocalization.of(context)!.deletePost,
        icon: SlydoAppIcon.delete,
        onTap: () {
          Navigator.pop(context);
          showDialogBox(
            context: context,
            actionOneTextColor: white,
            actionOneBgColor: mateRed,
            actionTwoTextColor: blackFont,
            actionTwoBgColor: greyBorderColor,
            title: AppLocalization.of(context)!.delete,
            actionTwoText: AppLocalization.of(context)!.cancel,
            actionOneText: AppLocalization.of(context)!.delete,
            description: 'Are you sure you want to delete this blog post?',
            roundedBackgroundIcon: RoundedBackgroundIcon(
              width: 90,
              height: 90,
              enableMargin: false,
              image: Image.asset('assets/images/delete_dialog_icon.png'),
            ),
            leftButtonOnPressed: () {
              UserPostUtils.deleteBlogPost(
                context: context,
                blogId: widget.post!.id!,
                onDeleteBlog: widget.onDeleteBlog,
              );
            },
          );
        },
      ),
    );

    return list;
  }

  Widget _buildLikeUnLikeReportTile() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildReviewLike(),
              SizedBox(width: 8),
              _buildPostUnLike(),
            ],
          ),
        ),

        // Expanded(child: Container())

        // _buildReviewReport(),
      ],
    );
  }

  Widget _buildReviewLike() {
    return GestureDetector(
      onTap: isAuthor
          ? () => showToast(message: 'You cannot like your post')
          : likeUnlikePost,
      child: Container(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.thumb_up_alt_outlined, size: 16),
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
      onTap: isAuthor
          ? () => showToast(message: 'You cannot unlike your post')
          : dislikeUnlikePost,
      child: Container(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.thumb_down_alt_outlined,
              size: 16,
            ),
            SizedBox(width: 4),
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
