import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/yarn/ask_search_screen.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_blog_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_customer_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_product_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_service_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/slydo_yarn_links.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/rich_text.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linkwell/linkwell.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../user_profile/screens/user_profile_module_new/utils.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/link_preview/flutter_link_preview.dart';
import '../../../../utils/link_preview/web_analyzer.dart';
import '../../../../utils/util.dart';
import '../../user_post/models/user_post.dart';
import '../../user_profile/models/user.dart';
import '../models/Topics/yarn_model.dart';
import '../widgets/url_reader_of_yarn.dart';
import '../widgets/yarn_media_renderer.dart';

class ReYarnTile extends StatefulWidget {
  final GestureTapCallback? onOptionsAction;

  final Yarn yarn;
  final Color? backGroundColor;

  ReYarnTile({
    required this.yarn,
    this.onOptionsAction,
    this.backGroundColor,
  });

  @override
  State<ReYarnTile> createState() => _ReYarnTileState();
}

class _ReYarnTileState extends State<ReYarnTile> {
  /// variables for yarn tile render TYPE
  bool isMediaPresent = false;
  bool isAttachmentPresent = false;

  bool isUrlPresent = false;
  String? linkToBePreview;

  @override
  void initState() {
    if (widget.yarn.body != null) {
      Map<String, dynamic> linkData =
          detectLinkInText(messageDecoderWithEmoji(widget.yarn.body)!);

      if (linkData["hasLink"]) {
        isUrlPresent = true;

        linkToBePreview = linkData['links'][0];
        if (!linkToBePreview!.contains("http")) {
          linkToBePreview = "http://" + linkToBePreview!;
        }
      }
    } else {}

    if ((widget.yarn.media.isNotEmpty)) {
      isMediaPresent = true;
    }
    if (widget.yarn.attachment != null) {
      isAttachmentPresent = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onOptionsAction,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: greySecondaryYarn)),
        child: _buildMain(),
      ),
    );
  }

  Widget _buildMain() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(),
        SizedBox(
          height: 10,
        ),
        if (widget.yarn.isQuestion) ...[
          _buildPostTitle(),
          SizedBox(height: 8),
        ],
        _buildPostDescription(),
        SizedBox(
          height: 9,
        ),
        if (isAttachmentPresent && widget.yarn.attachment != null) ...[
          SizedBox(height: 8),
          _buildAttachment(),
        ],
        if (isMediaPresent) ...[
          _buildImagesRow(),
        ],
      ],
    );
  }

  Widget _buildUserInfoRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 4,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserAvatar(),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.USER_PROFILE,
                      arguments: {"searchedUserName": widget.yarn.author});
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          messageDecoderWithEmoji(
                                  widget.yarn.authorName ?? "") ??
                              "",
                          style: TextStyle(
                              fontSize: 14,
                              color: yarnBlack,
                              fontWeight: FontWeight.w700),
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
                        Expanded(
                          child: Text(
                            '${getGetYarnQuestionDateTime(widget.yarn.createdAt!)}',
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 12, color: yarnBlack),
                          ),
                        )
                      ],
                    ),
                    userNameWithVerifiedIcon(
                      name: "@${widget.yarn.author!}",
                      isVerified: widget.yarn.authorIsVerified ?? false,
                      verifiedIconSize: 12,
                      textStyle: TextStyle(
                        color: yarnBlack.withOpacity(.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      verifiedIconColor: verifyGreen,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
            arguments: widget.yarn.authorAvatar!);
      },
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.yarn.authorAvatar!,
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
          ),
        ),
      ),
    );
  }

  Widget _buildPostTitle() {
    return RichTextForTitle(
      description: widget.yarn.title ?? '',
    );
  }

  Widget _buildPostDescription() {
    var newString = '';
    var list = [];

    widget.yarn.body.toString().split(' ').forEach((ch) {
      list.add(ch);
      // print(ch);
    });

    list.forEach((data) {
      if (data.toString().contains('.') &&
          !data.toString().trim().contains('@') &&
          !data.toString().trim().contains('..') &&
          !data.toString().trim().startsWith('.') &&
          !data.toString().trim().startsWith('http') &&
          !data.toString().trim().contains('.\n') &&
          !data.toString().trim().endsWith('.')) {
        final replaceWith = 'http://' + data;

        newString = newString + ' ' + replaceWith.toString();
      } else {
        newString = newString + ' ' + data.toString();
      }
    });

    if (isUrlPresent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          YarnSmartText(
            text: messageDecoderWithEmoji(newString)! ?? '',
            atStyle: TextStyle(color: navyBlue),
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

    return YarnSmartText(
      text: messageDecoderWithEmoji(newString)! ?? '',
      atStyle: TextStyle(color: navyBlue, fontSize: 14),
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
          "searchedUserName": at.replaceAll(RegExp('@'), '').trim()
        });
      },
    );
  }

  Widget _buildAttachment() {
    Widget childWidget;
    if (widget.yarn.attachmentType == 'service') {
      Service service = Service.fromJson(widget.yarn.attachment);
      childWidget = YarnServiceTile(
        service: service,
      );
    } else if (widget.yarn.attachmentType == 'product') {
      Product product = Product.fromJson(widget.yarn.attachment);
      childWidget = YarnProductTile(
        product: product,
      );
    } else if (widget.yarn.attachmentType == 'blog') {
      UserPost post = UserPost.fromJson(widget.yarn.attachment);
      childWidget = YarnBlogPostTile(
        post: post,
        showAuthorDetails: true,
        onDeleteBlog: () {},
      );
    } else if (widget.yarn.attachmentType == 'profile') {
      CustomerProfile customerProfile =
          CustomerProfile.fromJson(widget.yarn.attachment ?? {});
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

  Widget _buildImagesRow() {
    return YarnMediaRender(
      yarnTopic: widget.yarn,
    );
  }
}
