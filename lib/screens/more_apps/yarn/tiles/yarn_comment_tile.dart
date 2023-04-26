import 'package:Slydo/screens/more_apps/yarn/yarn_search_screen.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_blog_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_customer_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_product_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_service_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/slydo_yarn_links.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/yarn_enum.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/ask_reply_view.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_comment_actions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/link_preview/flutter_link_preview.dart';
import '../../../../utils/link_preview/web_analyzer.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../shopping/models/store.dart';
import '../../user_post/models/user_post.dart';
import '../../user_profile/models/user.dart';
import '../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../models/Topics/CommentDetails.dart';
import '../widgets/url_reader_of_yarn.dart';
import '../widgets/yarn_comment_media_renderer.dart';
import '../widgets/yarn_options.dart';
import '../yarn_comment_detail_screen.dart';

class YarnCommentTile extends StatefulWidget {
  final Yarn yarn;
  final YarnComment yarnComment;
  final YarnComment? yarnCommentReply;
  List<YarnComment>? commentDetailsList = [];
  final bool? openReply;
  final bool? isCommentDetail;
  final Function(YarnComment)? onDeleteComment;
  final Function(Yarn)? onUpdate;
  bool? minusComment;
  String? pinnedCommentId;
  String? commentType;

  YarnCommentTile({
    required this.yarn,
    required this.yarnComment,
    this.yarnCommentReply,
    this.commentDetailsList,
    this.openReply = false,
    this.isCommentDetail = false,
    this.onDeleteComment,
    this.onUpdate,
    this.minusComment,
    this.pinnedCommentId,
    this.commentType,
  });

  @override
  State<YarnCommentTile> createState() => _YarnCommentTileState();
}

class _YarnCommentTileState extends State<YarnCommentTile> {
  bool isUrlPresent = false;
  String? linkToBePreview;
  bool isMediaPresent = false;
  bool isAttachmentPresent = false;

  @override
  void initState() {
    if (widget.yarnComment.comment != null) {
      Map<String, dynamic> linkData = detectLinkInText(
          messageDecoderWithEmoji(widget.yarnComment.comment)!);

      if (linkData["hasLink"]) {
        isUrlPresent = true;

        linkToBePreview = linkData['links'][0];
        if (!linkToBePreview!.contains("http")) {
          linkToBePreview = "http://" + linkToBePreview!;
        }
      }
    }

    if (widget.yarnComment.media.isNotEmpty) {
      isMediaPresent = true;
    }

    if (widget.yarnComment.attachment != null) {
      isAttachmentPresent = true;
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
    return InkWell(
      onTap: () {
        if (!(widget.isCommentDetail ?? false)) {
          NavigationUtil.push(
            context,
            screen: YarnCommentDetailScreen(
              yarn: widget.yarn,
              yarnComment: widget.yarnComment,
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.only(top: 12),
        child: Column(
          children: [
            _buildUserInfoRow(context: context),
            SizedBox(
              height: 15,
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                  ),
                  Container(
                    width: 1,
                    color: greySecondaryYarn,
                    height: double.infinity,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.yarnComment.comment != null) ...[
                          _buildCommentDescription(),
                          SizedBox(
                            height: 8,
                          ),
                        ],
                        if (isMediaPresent) ...[
                          _buildImagesRow(),
                          SizedBox(
                            height: 8,
                          ),
                        ],
                        if (isAttachmentPresent &&
                            widget.yarnComment.attachment != null) ...[
                          _buildAttachment(),
                          SizedBox(
                            height: 8,
                          ),
                        ],
                        SizedBox(
                          height: 10,
                        ),
                        _buildTopActions(context: context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildReplyCommentView(context: context),
          ],
        ),
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
      Service service = Service.fromJson(widget.yarnComment.attachment);
      childWidget = YarnServiceTile(
        service: service,
        tileRenderPlace: TileRenderPlace.YarnComment,
      );
    } else if (widget.yarnComment.attachmentType == 'product') {
      Product product = Product.fromJson(widget.yarnComment.attachment);
      childWidget = YarnProductTile(
        product: product,
        tileRenderPlace: TileRenderPlace.YarnComment,
      );
    } else if (widget.yarnComment.attachmentType == 'blog') {
      UserPost post = UserPost.fromJson(widget.yarnComment.attachment);
      childWidget = YarnBlogPostTile(
        post: post,
        showAuthorDetails: true,
        onDeleteBlog: () {},
      );
    } else if (widget.yarnComment.attachmentType == 'profile') {
      CustomerProfile customerProfile =
          CustomerProfile.fromJson(widget.yarnComment.attachment ?? {});
      childWidget = YarnCustomerPostTile(
        customerProfile: customerProfile,
        showAuthorDetails: true,
        onDeleteBlog: () {},
        tileRenderPlace: TileRenderPlace.YarnComment,
      );
    } else {
      childWidget = SizedBox();
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
            SizedBox(
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
            SizedBox(
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
            SizedBox(
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
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    "@${widget.yarnComment.authorUsername!}",
                    style: TextStyle(fontSize: 12, color: yarnBlack),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  ClipOval(
                    child: Container(
                      height: 4,
                      width: 4,
                      color: yarnBlack,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    '${getGetYarnQuestionDateTime(widget.yarnComment.createdAt!)}',
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        fontSize: 12,
                        color: yarnBlack,
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 3,
            ),
            _buildRepliedText(),
          ],
        )),
        InkWell(
          onTap: () {
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
                  child: YarnOptions(
                    yarnTopic: widget.yarn,
                    commentDetail: widget.yarnComment,
                    isComment: true,
                    onDeleteComment: (YarnComment yarnComment) {
                      widget.onDeleteComment!(yarnComment);
                    },
                    onUpdate: (Yarn yarn) {
                      widget.onUpdate!(yarn);
                    },
                  ),
                );
              },
            );
          },
          child: Icon(
            Icons.more_horiz_rounded,
            color: Color(0xFF4B545A),
          ),
        ),
      ],
    );
  }

  String? getReplyingUsername() {
    String? username;

    // debugPrint('Comment reply:::: ${widget.yarnComment.comment}');
    // debugPrint('Comment reply:::: ${item.comment}');

    if (widget.yarnCommentReply != null) {
      username = widget.yarnCommentReply!.authorUsername;
    } else {
      username = widget.yarn.author;
    }
    return "@$username";
  }

  Widget _buildRepliedText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Replying to ",
          style: TextStyle(fontSize: 12, color: yarnBlack),
        ),
        Expanded(
          child: userNameWithVerifiedIcon(
              name: getReplyingUsername()!,
              isVerified: false,
              textStyle: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: navyBlue)),
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
          SizedBox(
            height: 5,
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
          SizedBox(
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
                if (info == null)
                  return InkWell(
                    onTap: () {
                      launchUrl(Uri.parse(linkToBePreview!));
                    },
                    child: Container(
                      margin:
                          EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
                      child: Text(
                        linkToBePreview!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: navyBlue, fontSize: 14),
                      ),
                    ),
                  );
                if (info is WebImageInfo) {
                  return CachedNetworkImage(
                    imageUrl: info.image!,
                    fit: BoxFit.contain,
                    errorWidget: imageErrorWidget,
                  );
                }

                final WebInfo webInfo = info as WebInfo;
                if (!WebAnalyzer.isNotEmpty(webInfo.title))
                  return const SizedBox(
                    height: 0,
                    width: 0,
                  );
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: EdgeInsets.only(bottom: 4, top: 8),
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

  Widget _buildTopActions({required BuildContext context}) {
    return YarnCommentActions(
      comment: widget.yarnComment,
      yarn: widget.yarn,
      isCommentDetail: widget.isCommentDetail ?? false,
      minusComment: widget.minusComment,
      commentType: widget.commentType,
    );
  }

  Widget _buildReplyCommentView({required BuildContext context}) {
    if (widget.openReply! &&
        widget.commentDetailsList!.isNotEmpty &&
        widget.commentDetailsList != null) {
      return Column(
        children: widget.commentDetailsList!.map((replyCommentDetail) {
          return InkWell(
            onTap: () {
              NavigationUtil.push(
                context,
                screen: YarnCommentDetailScreen(
                  yarn: widget.yarn,
                  yarnComment: replyCommentDetail,
                ),
              );
            },
            child: AskReplyView(
              yarnTopic: widget.yarn,
              commentDetail: widget.yarnComment,
              replyCommentDetail: replyCommentDetail,
            ),
          );
        }).toList(),
      );
    }
    return SizedBox();
  }

  bool isComments(BuildContext context) {
    DateTime messageCreatedTime =
        DateTime.parse(widget.yarnComment.createdAt!).toLocal();

    DateTime currentTime = DateTime.now();
    if (getLoggedInUserName(context) == widget.yarnComment.authorUsername) {
      if (currentTime.difference(messageCreatedTime) < Duration(minutes: 3)) {
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
        Container(
          child: Icon(
            Icons.push_pin,
            color: greySecondaryYarn,
            size: 15,
          ),
        ),
        SizedBox(
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
