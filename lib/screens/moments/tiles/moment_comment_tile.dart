import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_blog_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_customer_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_product_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_service_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/slydo_yarn_links.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/yarn_enum.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_search_screen.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/link_preview/flutter_link_preview.dart';
import '../../../../utils/link_preview/web_analyzer.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../more_apps/shopping/models/store.dart';
import '../../more_apps/user_post/models/user_post.dart';
import '../../more_apps/user_profile/models/user.dart';
import '../../more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../../more_apps/yarn/models/Topics/comment_details.dart';
import '../../more_apps/yarn/widgets/url_reader_of_yarn.dart';
import '../../more_apps/yarn/widgets/yarn_comment_media_renderer.dart';
import '../../more_apps/yarn/widgets/yarn_options.dart';
import '../../more_apps/yarn/yarn_auth.dart';
import '../screens/moment_detail/moment_comment.screen.dart';

// ignore: must_be_immutable
class MomentCommentTile extends StatefulWidget {
  final YarnComment yarnComment;
  final YarnComment? yarnCommentReply;
  List<YarnComment>? commentDetailsList = [];
  final bool? openReply;
  final bool? isCommentDetail;
  final Function(YarnComment)? onDeleteComment;
  final Function(Yarn)? onUpdate;
  final Function(YarnComment, bool)? onCommentUpdate;
  Function(bool)? minusComment;
  final String? pinnedCommentId;
  final String? momentUsername;
  final String? momentId;
  final String? commentType;
  final MomentsModel? moment;
  final Function(bool)? callbackUpdateCommentCount;

  MomentCommentTile({
    super.key,
    required this.yarnComment,
    this.yarnCommentReply,
    this.commentDetailsList,
    this.openReply = false,
    this.isCommentDetail = false,
    this.onDeleteComment,
    this.onUpdate,
    this.onCommentUpdate,
    this.minusComment,
    this.pinnedCommentId,
    this.momentUsername,
    this.momentId,
    this.commentType,
    this.moment,
    this.callbackUpdateCommentCount,
  });

  @override
  State<MomentCommentTile> createState() => _MomentCommentTileState();
}

class _MomentCommentTileState extends State<MomentCommentTile> {
  bool isUrlPresent = false;
  String? linkToBePreview;
  bool isMediaPresent = false;
  bool isAttachmentPresent = false;

  @override
  void initState() {
    if (widget.yarnComment.comment != null) {
      final Map<String, dynamic> linkData = detectLinkInText(
          messageDecoderWithEmoji(widget.yarnComment.comment)!);

      if (linkData["hasLink"]) {
        isUrlPresent = true;

        linkToBePreview = linkData['links'][0];
        if (!linkToBePreview!.contains("http")) {
          linkToBePreview = "http://${linkToBePreview!}";
        }
      }
    }

    if (widget.yarnComment.media.isNotEmpty) {
      isMediaPresent = true;
    }

    if (widget.yarnComment.attachment != null) {
      isAttachmentPresent = true;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          _buildUserInfoRow(context: context),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 34.0),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.yarnComment.comment != null) ...[
                          _buildCommentDescription(),
                          const SizedBox(
                            height: 2,
                          ),
                        ],
                        if (isMediaPresent) ...[
                          _buildImagesRow(),
                          const SizedBox(
                            height: 8,
                          ),
                        ],
                        if (isAttachmentPresent &&
                            widget.yarnComment.attachment != null) ...[
                          _buildAttachment(),
                          const SizedBox(
                            height: 8,
                          ),
                        ],
                        bottomSheetCommentIcons(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesRow() {
    return YarnCommentMediaRender(
      yarnTopic: widget.yarnComment,
    );
  }

  Widget _buildAttachment() {
    Widget childWidget;
    if (widget.yarnComment.attachmentType == 'service') {
      final Service service = Service.fromJson(widget.yarnComment.attachment);
      childWidget = YarnServiceTile(
        service: service,
        tileRenderPlace: TileRenderPlace.YarnComment,
      );
    } else if (widget.yarnComment.attachmentType == 'product') {
      final Product product = Product.fromJson(widget.yarnComment.attachment);
      childWidget = YarnProductTile(
        product: product,
        tileRenderPlace: TileRenderPlace.YarnComment,
      );
    } else if (widget.yarnComment.attachmentType == 'blog') {
      final UserPost post = UserPost.fromJson(widget.yarnComment.attachment);
      childWidget = YarnBlogPostTile(
        post: post,
        showAuthorDetails: true,
        onDeleteBlog: () {},
      );
    } else if (widget.yarnComment.attachmentType == 'profile') {
      final CustomerProfile customerProfile =
          CustomerProfile.fromJson(widget.yarnComment.attachment ?? {});
      childWidget = YarnCustomerPostTile(
        customerProfile: customerProfile,
        showAuthorDetails: true,
        onDeleteBlog: () {},
        tileRenderPlace: TileRenderPlace.YarnComment,
      );
    } else {
      childWidget = const SizedBox();
    }
    return childWidget;
  }

  Widget _buildUserAvatar({required BuildContext context}) {
    return InkWell(
      onTap: () {
        String? image = '';
        if (widget.yarnComment.authorAvatar! == "" ||
            widget.yarnComment.authorAvatar! ==
                "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
          image = getInitials(widget.yarnComment.authorName!).toUpperCase();
        } else {
          image = widget.yarnComment.authorAvatar!;
        }

        Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER, arguments: image);
      },
      child: Column(
        children: [
          if (widget.yarnComment.pinned == true) ...[
            const SizedBox(
              height: 10,
            ),
          ],
          getUserProfilePic(
              widget.yarnComment.authorAvatar!, widget.yarnComment.authorName!)
        ],
      ),
    );
  }

  Widget _buildUserInfoRow({required BuildContext context}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildUserAvatar(context: context),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.yarnComment.pinned == true) ...[
              _buildPinned(context: context),
            ],
            const SizedBox(
              height: 3,
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, Routes.USER_PROFILE, arguments: {
                  "searchedUserName": widget.yarnComment.authorUsername!
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      messageDecoderWithEmoji(
                              widget.yarnComment.authorName ?? "") ??
                          "",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 13,
                          color: yarnBlack,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  ClipOval(
                    child: Container(
                      height: 4,
                      width: 4,
                      color: yarnBlack,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    getGetYarnQuestionDateTime(widget.yarnComment.createdAt!),
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        fontSize: 12,
                        color: yarnBlack,
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ],
        )),
        InkWell(
          onTap: () {
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
                  child: YarnOptions(
                    moment: widget.moment,
                    commentDetail: widget.yarnComment,
                    isComment: true,
                    momentUsername: widget.momentUsername,
                    onDeleteComment: (YarnComment yarnComment) {
                      widget.onDeleteComment!(yarnComment);
                      if (widget.onCommentUpdate != null) {
                        widget.onCommentUpdate!(yarnComment, true);
                      }

                      if (mounted) setState(() {});
                    },
                    onUpdateMomentComment: (YarnComment yarnComment, bool val) {
                      widget.onCommentUpdate!(yarnComment, val);
                      if (widget.onCommentUpdate != null) {
                        widget.onCommentUpdate!(yarnComment, val);
                      }
                      if (mounted) setState(() {});
                    },
                    onUpdate: (Yarn yarn) {
                      widget.onUpdate!(yarn);
                    },
                  ),
                );
              },
            );
          },
          child: const Icon(
            Icons.more_vert_rounded,
            color: Color(0xFF4B545A),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentDescription() {
    var removedLink = '';

    removedLink = removeLinksAndWords(
        widget.yarnComment.comment != null ? widget.yarnComment.comment! : '',
        []);

    if (isUrlPresent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 2.5,
          ),
          YarnSmartText(
            text: messageDecoderWithEmoji(removedLink)!,
            style: TextStyle(
                color: blackFont, fontSize: 12, fontFamily: "OpenSans"),
            // atStyle: TextStyle(
            //     color: navyBlue, fontSize: 14, fontFamily: "OpenSans"),
            disableAt: false,
            onTagClick: (tag) {
              NavigationUtil.push(context,
                  screen: SearchScreen(searchText: tag.trim()));
            },
            onUrlClicked: (open) {
              // launch  url
              launchUrl(Uri.parse(open.toString()));
            },
            onAtClick: (at) {
              Navigator.pushNamed(context, Routes.USER_PROFILE, arguments: {
                "searchedUserName": at.replaceFirst("@", "").trim()
              });
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: darkGrey.withOpacity(
                      .4,
                    ),
                    width: .5)),
            child: FlutterLinkPreview(
              key: ValueKey("${linkToBePreview}233"),
              url: linkToBePreview!,
              builder: (info) {
                if (info == null) {
                  return InkWell(
                    onTap: () {
                      launchUrl(Uri.parse(linkToBePreview!));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 10.0, top: 10.0, bottom: 10.0),
                      child: Text(
                        linkToBePreview!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: navyBlue, fontSize: 14),
                      ),
                    ),
                  );
                }
                if (info is WebImageInfo) {
                  return CachedNetworkImage(
                    imageUrl: info.image!,
                    fit: BoxFit.contain,
                    errorWidget: imageErrorWidget,
                  );
                }

                final WebInfo webInfo = info as WebInfo;
                if (!WebAnalyzer.isNotEmpty(webInfo.title)) {
                  return const SizedBox(
                    height: 0,
                    width: 0,
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 4, top: 8),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: getWebPreview(
                          webInfo, context, linkToBePreview, 100.0)),
                );
              },
            ),
          ),
        ],
      );
    }

    return YarnSmartText(
      text: messageDecoderWithEmoji(removedLink)!,
      style: TextStyle(color: blackFont, fontSize: 12, fontFamily: "OpenSans"),
      // atStyle: TextStyle(color: navyBlue, fontSize: 17, fontFamily: "OpenSans"),
      disableAt: false,
      onTagClick: (tag) {
        NavigationUtil.push(context,
            screen: SearchScreen(searchText: tag.trim()));
      },
      onUrlClicked: (open) {
        // launch  url
        launchUrl(Uri.parse(open.toString()));
      },
      onAtClick: (at) {
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": at.replaceFirst("@", "").trim()});
      },
    );
  }

  Future<bool> addLikeToComment() async {
    final Map<String, dynamic>? data =
        await YarnAuth().addLikeComment(widget.yarnComment.id!);
    setState(() {
      widget.yarnComment.userLike = !widget.yarnComment.userLike!;
      widget.yarnComment.userDisLike = false;
    });
    if (data != null) {
      setState(() {
        widget.yarnComment.likes = data['likes'];
        widget.yarnComment.dislike = data['dislikes'];
      });
      return true;
    }
    return false;
  }

  Future<bool> addDisLikeToComment() async {
    final Map<String, dynamic>? data =
        await YarnAuth().addDisLikeComment(widget.yarnComment.id!);
    setState(() {
      widget.yarnComment.userDisLike = !widget.yarnComment.userDisLike!;
      widget.yarnComment.userLike = false;
    });
    if (data != null) {
      setState(() {
        widget.yarnComment.likes = data['likes'];
        widget.yarnComment.dislike = data['dislikes'];
      });
      return true;
    }
    return false;
  }

  Widget bottomSheetCommentIcons() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              LikeButton(
                size: 15,
                circleColor: CircleColor(start: red, end: red),
                bubblesColor: BubblesColor(
                  dotPrimaryColor: red,
                  dotSecondaryColor: red,
                ),
                onTap: (isLike) {
                  return addLikeToComment();
                },
                likeBuilder: (bool isLiked) {
                  return SvgPicture.asset(
                    widget.yarnComment.userLike!
                        ? "yarn/likeAfter".toSVG()
                        : "yarn/likeBefore".toSVG(),
                    color:
                        widget.yarnComment.userLike == true ? red : blackFont,
                    height: 15,
                    width: 15,
                  );
                },
                likeCount: widget.yarnComment.likes,
                countBuilder: (_, __, ___) {
                  final int count = widget.yarnComment.likes!;
                  return Text(
                    count == 0 ? '' : count.toString(),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: darkGreyYarn),
                  );
                },
              ),
            ],
          ),
          const SizedBox(
            width: 25,
          ),
          LikeButton(
            size: 15,
            circleColor: CircleColor(start: starYellow, end: starYellow),
            bubblesColor: BubblesColor(
              dotPrimaryColor: starYellow,
              dotSecondaryColor: starYellow,
            ),
            onTap: (isLike) {
              return addDisLikeToComment();
            },
            likeBuilder: (bool isLiked) {
              return SvgPicture.asset(
                widget.yarnComment.userDisLike!
                    ? "yarn/unlikeAfter".toSVG()
                    : "yarn/unlikeBefore".toSVG(),
                color: widget.yarnComment.userDisLike! ? starYellow : blackFont,
                height: 15,
                width: 15,
              );
            },
            likeCount: widget.yarnComment.dislike,
            countBuilder: (_, __, ___) {
              final int count = widget.yarnComment.dislike!;
              return Text(
                count == 0 ? '' : count.toString(),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: blackFont),
              );
            },
          ),
          const SizedBox(
            width: 25,
          ),
          if (widget.isCommentDetail == true) ...[
            GestureDetector(
              onTap: () => NavigationUtil.push(
                context,
                screen: MomentCommentScreen(
                  yarnComment: widget.yarnComment,
                  momentId: widget.momentId,
                  minusComment: widget.minusComment,
                  callbackUpdateCommentCount: (value) {
                    if (value == true) {
                      //increase the count by for the single moment detail + 1
                      widget.callbackUpdateCommentCount!(true);
                    }
                  },
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset("yarn/yarn_comment".toSVG()),
                  const SizedBox(
                    width: 5,
                  ),
                  // ignore: unrelated_type_equality_checks
                  if (widget.yarnComment.replyCount == '0' ||
                      // ignore: unrelated_type_equality_checks
                      widget.yarnComment.replyCount == '0')
                    const SizedBox.shrink()
                  else
                    Text(
                        '${widget.yarnComment.replyCount ?? widget.yarnComment.replyCount}'),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  bool isComments(BuildContext context) {
    final DateTime messageCreatedTime =
        DateTime.parse(widget.yarnComment.createdAt!).toLocal();

    final DateTime currentTime = DateTime.now();
    if (getLoggedInUserName(context) == widget.yarnComment.authorUsername) {
      if (currentTime.difference(messageCreatedTime) <
          const Duration(minutes: 3)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Widget _buildPinned({required BuildContext context}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.push_pin,
          color: greySecondaryYarn,
          size: 15,
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: Text(
            "Comment Pinned by ${widget.yarnComment.authorName}",
            style: TextStyle(
                fontSize: 12,
                color: greySecondaryYarn,
                fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
