import 'package:Slydo/screens/more_apps/yarn/models/Topics/YarnTopic.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_blog_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_customer_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_product_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_service_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/ask_reply_view.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/rich_text.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_comment_actions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linkwell/linkwell.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/link_preview/flutter_link_preview.dart';
import '../../../../utils/link_preview/web_analyzer.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../shopping/models/store.dart';
import '../../user_post/models/user_post.dart';
import '../../user_profile/models/user.dart';
import '../models/Topics/CommentDetails.dart';
import '../widgets/url_reader_of_yarn.dart';
import '../widgets/yarn_comment_media_renderer.dart';
import '../widgets/yarn_media_renderer.dart';
import '../widgets/yarn_options.dart';
import '../yarn_comment_detail_screen.dart';

class YarnCommentTile extends StatefulWidget {
  final Yarn yarn;
  final YarnComment yarnComment;
  List<YarnComment>? commentDetailsList = [];
  final bool? openReply;
  final bool? isCommentDetail;
  final Function(YarnComment)? onDeleteComment;

  YarnCommentTile({
    required this.yarn,
    required this.yarnComment,
    this.commentDetailsList,
    this.openReply = false,
    this.isCommentDetail = false,
    this.onDeleteComment,
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
    Map<String, dynamic> linkData =
        detectLinkInText(messageDecoderWithEmoji(widget.yarnComment.comment)!);

    if (linkData["hasLink"]) {
      isUrlPresent = true;

      linkToBePreview = linkData['links'][0];
      if (!linkToBePreview!.contains("http")) {
        linkToBePreview = "http://" + linkToBePreview!;
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
                        if (isAttachmentPresent &&
                            widget.yarnComment.attachment != null) ...[
                          _buildAttachment(),
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
      );
    } else if (widget.yarnComment.attachmentType == 'product') {
      Product product = Product.fromJson(widget.yarnComment.attachment);
      childWidget = YarnProductTile(
        product: product,
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
      );
    } else {
      childWidget = SizedBox();
    }
    return childWidget;
  }

  Widget _buildUserAvatar({required BuildContext context}) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
            arguments: widget.yarnComment.authorAvatar!);
      },
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.yarnComment.authorAvatar!,
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
          ),
        ),
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
                      style: TextStyle(fontSize: 12, color: yarnBlack),
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
        isComments(context)
            ? InkWell(
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
                          commentDetail: widget.yarnComment,
                          isComment: true,
                          onDeleteComment: (YarnComment yarnComment) {
                            widget.onDeleteComment!(yarnComment);
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
              )
            : SizedBox()
      ],
    );
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
              name: "@${widget.yarn.author}",
              isVerified: false,
              textStyle: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: navyBlue)),
        ),
      ],
    );
  }

  Widget _buildCommentDescription() {
    if (isUrlPresent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          LinkWell(
            messageDecoderWithEmoji(widget.yarnComment.comment)!,
            style: TextStyle(
                color: blackFont, fontSize: 17, fontFamily: "OpenSans"),
            textScaleFactor: 0.8,
            linkStyle: TextStyle(
                color: navyBlue,
                decoration: TextDecoration.underline,
                fontSize: 17,
                fontFamily: "OpenSans"),
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
                  return const SizedBox(
                    height: 0,
                    width: 0,
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
                      children: getWebPreview(webInfo, context)),
                );
              },
            ),
          ),
        ],
      );
    }
    return RichTextForTitle(
      description:
          messageDecoderWithEmoji(widget.yarnComment.comment ?? '') ?? '',
    );
    // return Text(
    //   messageDecoderWithEmoji(commentDetail!.comment!)!,
    //   maxLines: 30,
    //   style: TextStyle(
    //     color: blackFont,
    //     fontSize: 14,
    //     fontWeight: FontWeight.w400,
    //   ),
    // );
  }

  Widget _buildTopActions({required BuildContext context}) {
    return YarnCommentActions(
      comment: widget.yarnComment,
      yarn: widget.yarn,
      isCommentDetail: widget.isCommentDetail ?? false,
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
}
