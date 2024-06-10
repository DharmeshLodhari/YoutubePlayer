import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/news/custom_chip.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_utils.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/yarn_enum.dart';
import 'package:Slydo/screens/post_detail_page.dart';
import 'package:Slydo/utils/enums.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/utils/video_player_controller/chewie_progress_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../../../locale/app_localization.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/slydo_app_icon_icons.dart';
import '../../../../utils/video_player_controller/chewie_player.dart';
import '../../../../widget/bottom_sheet_item.dart';
import '../../../../widget/dialog.dart';
import '../../../../widget/rounded_background_icon.dart';

class YarnBlogPostTile extends StatefulWidget {
  UserPost? post;
  bool? isNavigable;
  Function onDeleteBlog;
  final bool showAuthorDetails;
  final TileRenderPlace tileRenderPlace;

  YarnBlogPostTile(
      {super.key,
      this.post,
      this.showAuthorDetails = true,
      required this.onDeleteBlog,
      this.tileRenderPlace = TileRenderPlace.YarnTimeLine,
      this.isNavigable = true});

  @override
  _YarnBlogPostTileState createState() => _YarnBlogPostTileState();
}

class _YarnBlogPostTileState extends State<YarnBlogPostTile> {
  UserBloc? userBloc;
  bool isAuthor = false;
  bool isSelected = false;
  ChewieController? _chewieMainController;
  VideoPlayerController? _mainVideoController;

  @override
  void initState() {
    super.initState();

    if (widget.post?.video != null && widget.post!.video!.isNotEmpty) {
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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    if (widget.post != null &&
        userBloc!.user.userName == widget.post!.authorUsername) {
      isAuthor = true;
    }

    return _buildUserPostList();
  }

  @override
  void dispose() {
    if (widget.post?.video != null && widget.post!.video!.isNotEmpty) {
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
          // width: getItemWidth(),
          decoration: decorateBox(borderColor: greySecondaryYarn),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: widget.post?.video != null &&
                                widget.post!.video!.isNotEmpty
                            ? SizedBox(
                                height: getContainerHeight(
                                    widget.tileRenderPlace, context),
                                child: Chewie(
                                  posterUrl: widget.post?.image,
                                  controller: _chewieMainController!,
                                ),
                              )
                            : CachedNetworkImage(
                                height: getContainerHeight(
                                    widget.tileRenderPlace, context),
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorWidget: imageErrorWidget,
                                imageUrl: widget.post?.image ?? ""),
                      ),
                      if (widget.showAuthorDetails)
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, Routes.USER_PROFILE, arguments: {
                                "searchedUserName": widget.post!.authorUsername
                              });
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: widget.post!.authorAvatar!,
                                      errorWidget: imageErrorWidget,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                userNameWithVerifiedIcon(
                                  name: widget.post?.authorName ?? '',
                                  isVerified: false,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: getFontSize(
                                        widget.tileRenderPlace, context),
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 2.0,
                                        color: blackFont,
                                        offset: const Offset(0.0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      if (widget.post!.isPublished!)
                        const SizedBox.shrink()
                      else
                        Positioned(
                          left: 10,
                          top: 10,
                          child: CustomChip(
                            textColor: blackFont,
                            color: starYellow,
                            text: 'Unpublished',
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                          ),
                        ),
                      // Center(child: SvgPicture.asset('play_icon'.toSVG())),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 19),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: SvgPicture.asset('heart'.toSVG()),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: widget.post?.video != null &&
                            widget.post!.video!.isNotEmpty
                        ? SizedBox(
                            height: getContainerHeight(
                                widget.tileRenderPlace, context),
                            child: Chewie(
                              posterUrl: widget.post?.image,
                              controller: _chewieMainController!,
                            ),
                          )
                        : CachedNetworkImage(
                            height: getContainerHeight(
                                widget.tileRenderPlace, context),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: imageErrorWidget,
                            imageUrl: widget.post?.image ?? "",
                          ),
                  ),
                  if (widget.showAuthorDetails)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.USER_PROFILE,
                              arguments: {
                                "searchedUserName": widget.post!.authorUsername
                              });
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 25,
                              height: 25,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: widget.post!.authorAvatar!,
                                  errorWidget: imageErrorWidget,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            userNameWithVerifiedIcon(
                              name: widget.post!.authorName ?? "",
                              isVerified: false,
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: getFontSize(
                                    widget.tileRenderPlace, context),
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: blackFont,
                                    offset: const Offset(0.0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  if (widget.post!.isPublished!)
                    const SizedBox.shrink()
                  else
                    Positioned(
                      left: 10,
                      top: 10,
                      child: CustomChip(
                        textColor: blackFont,
                        color: starYellow,
                        text: 'Unpublished',
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            messageDecoderWithEmoji(widget.post?.title) ?? "",
                            style: TextStyle(
                              fontSize:
                                  getFontSize(widget.tileRenderPlace, context),
                              fontWeight: FontWeight.w700,
                              color: blackFont,
                            ),
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      messageDecoderWithEmoji(widget.post?.tagLine) ?? "",
                      style: TextStyle(
                        fontSize: getFontSize(widget.tileRenderPlace, context),
                        fontWeight: FontWeight.w400,
                        color: darkGrey,
                      ),
                      maxLines: 3,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
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
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: generateBottomSheetItem(),
                ),
              ));
        });
  }

  List<Widget> generateBottomSheetItem() {
    final List<Widget> list = [];

    list.add(
      bottomSheetItem(
        title: AppLocalization.of(context)!.share,
        iconData: SlydoAppIcon.share,
        onTap: () {
          Navigator.pop(context);
          final shareBody =
              "https://slydo.co/store/${widget.post!.authorUsername}/blogs/${widget.post!.id}";
          Share.share(shareBody, subject: "${widget.post!.authorName}");
        },
      ),
    );

    list.add(
      bottomSheetItem(
        title: "Share in Chat",
        iconData: SlydoAppIcon.text_message,
        onTap: () async {
          Navigator.pop(context);
          UserPostUtils.sendPostToUserInChat(
            context: context,
            userPost: widget.post!,
          );
        },
      ),
    );

    if (userBloc!.user.userName == widget.post!.authorUsername!) {
      list.add(
        bottomSheetItem(
          title: AppLocalization.of(context)!.editPost,
          iconData: SlydoAppIcon.edit,
          onTap: () async {
            Navigator.pop(context);
            await Navigator.pushNamed(context, Routes.CREATE_BLOG,
                arguments: widget.post);
          },
        ),
      );
    }

    if (userBloc!.user.userName == widget.post!.authorUsername!) {
      list.add(
        bottomSheetItem(
          title: AppLocalization.of(context)!.deletePost,
          iconData: SlydoAppIcon.delete,
          onTap: () {
            Navigator.pop(context);
            showDialogBox(
              context: context,
              actionOneTextColor: blackFont,
              actionOneBgColor: greyBorderColor,
              actionTwoTextColor: white,
              actionTwoBgColor: mateRed,
              title: 'Delete Blog Post',
              actionOneText: AppLocalization.of(context)!.discard,
              actionTwoText: AppLocalization.of(context)!.continueMsg,
              description: 'Are you sure you want to delete this blog post?',
              roundedBackgroundIcon: RoundedBackgroundIcon(
                width: 90,
                height: 90,
                enableMargin: false,
                image: Image.asset('assets/images/delete_dialog_icon.png'),
              ),
              rightButtonOnPressed: () {
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
    }

    return list;
  }

  Widget _buildLikeUnLikeReportTile() {
    if (!widget.post!.enableLike!) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildReviewLike(),
            const SizedBox(width: 16),
            _buildPostUnLike(),
          ],
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
      child: Row(
        children: [
          Icon(
            widget.post?.userLiked == true
                ? Icons.thumb_up_alt_rounded
                : Icons.thumb_up_alt_outlined,
            size: 16,
            color: widget.post?.userLiked == true ? navyBlue : blackFont,
          ),
          const SizedBox(width: 4),
          Text(
            widget.post?.likes != null ? widget.post!.likes!.toString() : '0',
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ],
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
          ? () => showToast(message: 'You cannot dislike your post')
          : dislikeUnlikePost,
      child: Row(
        children: [
          Icon(
            widget.post?.userDisLiked == true
                ? Icons.thumb_down_alt_rounded
                : Icons.thumb_down_alt_outlined,
            size: 16,
            color: widget.post?.userDisLiked! == true ? mateRed : blackFont,
          ),
          const SizedBox(width: 4),
          Text(
            widget.post?.dislikes != null
                ? widget.post!.dislikes!.toString()
                : '0',
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
