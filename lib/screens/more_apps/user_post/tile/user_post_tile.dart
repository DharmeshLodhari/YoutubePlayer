import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/news/CustomChip.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_utils.dart';
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
import '../../../../routes/route_constants.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/slydo_app_icon_icons.dart';
import '../../../../utils/slydo_app_icon_new_icons.dart';
import '../../../../utils/video_player_controller/chewie_player.dart';
import '../../../../widget/bottom_sheet_item.dart';
import '../../../../widget/dialog.dart';
import '../../../../widget/rounded_background_icon.dart';
import '../../yarn/models/share_as_yarn_model.dart';
import '../../yarn/share_as_a_yarn_screen.dart';
import '../../yarn/yarn_auth.dart';
import '../../yarn/yarn_dashboard_bloc.dart';

class PostTile extends StatefulWidget {
  UserPost? post;
  bool? isNavigable;
  Function onDeleteBlog;
  final bool showAuthorDetails;

  PostTile(
      {Key? key,
      this.post,
      this.showAuthorDetails = true,
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
  late YarnDashboardBloc yarnDashboardBloc;

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
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    userBloc = Provider.of<UserBloc>(context);
    if (userBloc!.user.userName == widget.post!.authorUsername) {
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
                      child: widget.post?.video != null &&
                              widget.post!.video!.isNotEmpty
                          ? SizedBox(
                              height: 150,
                              child: Chewie(
                                posterUrl: widget.post?.image,
                                controller: _chewieMainController!,
                              ),
                            )
                          : CachedNetworkImage(
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: imageErrorWidget,
                              imageUrl: widget.post?.image ?? "",
                            ),
                    ),
                    widget.showAuthorDetails
                        ? Positioned(
                            left: 10,
                            bottom: 10,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, Routes.USER_PROFILE, arguments: {
                                  "searchedUserName":
                                      widget.post!.authorUsername
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
                                  SizedBox(width: 8),
                                  userNameWithVerifiedIcon(
                                    name: widget.post!.authorName!,
                                    isVerified: false,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 2.0,
                                          color: blackFont,
                                          offset: Offset(0.0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                color: blackFont,
                              ),
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
                      SizedBox(height: 8),
                      Text(
                        messageDecoderWithEmoji(widget.post?.tagLine) ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: darkGrey,
                        ),
                        maxLines: 3,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility_rounded,
                                size: 16,
                                color: blackFont,
                              ),
                              SizedBox(width: 6),
                              Text(
                                getFormattedViewCount(
                                  noOfViews: widget.post?.views != null
                                      ? widget.post!.views!
                                      : 1,
                                  addViewText: false,
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: blackFont,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 16),
                          _buildLikeUnLikeReportTile(),
                          Spacer(),
                          CustomChip(
                            color: greyBorderColor,
                            textColor: blackFont,
                            text: widget.post!.readTime == 0
                                ? '1 min read'
                                : '${widget.post!.readTime} min read',
                            padding: EdgeInsets.all(4),
                          ),
                          SizedBox(width: 8),
                        ],
                      )
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
        iconData: SlydoAppIcon.share,
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

    list.add(
      bottomSheetItem(
        isLast: true,
        title: "Share As A Yarn",
        iconData: SlydoAppIconNew.dashboard_yarn,
        onTap: () async {
          Navigator.pop(context);
          shareAsYarn();
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
    }

    return list;
  }

  void shareAsYarn() {
    NavigationUtil.push(context,
        screen: ShareAsAyarnScreen(
            askCategories: yarnDashboardBloc.yarnCategories,
            shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
            callback: (params) async {
              params..body = widget.post?.title ?? "";
              params
                ..attachment = {
                  "blog": widget.post?.toJson().cast<String, dynamic>() ?? {}
                };
              bool data = await YarnAuth().addYarnAndQuestion(params);
              if (data) {
                showToast(message: "Share in Yarn successfully created");
              }
            }));
  }

  Widget _buildLikeUnLikeReportTile() {
    if (!widget.post!.enableLike!) {
      return SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildReviewLike(),
            SizedBox(width: 16),
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
      child: Container(
        child: Row(
          children: [
            Icon(
              widget.post?.userLiked == true
                  ? Icons.thumb_up_alt_rounded
                  : Icons.thumb_up_alt_outlined,
              size: 16,
              color: widget.post?.userLiked == true ? navyBlue : blackFont,
            ),
            SizedBox(width: 4),
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
      child: Container(
        child: Row(
          children: [
            Icon(
              widget.post?.userDisLiked == true
                  ? Icons.thumb_down_alt_rounded
                  : Icons.thumb_down_alt_outlined,
              size: 16,
              color: widget.post?.userDisLiked! == true ? mateRed : blackFont,
            ),
            SizedBox(width: 4),
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
      ),
    );
  }
}
