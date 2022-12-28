import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/re_yarn_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_customer_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_product_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_service_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_blog_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/rich_text.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/viewer_screen.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_actions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkwell/linkwell.dart';
import 'package:provider/provider.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/link_preview/flutter_link_preview.dart';
import '../../../../utils/link_preview/web_analyzer.dart';
import '../../../../utils/util.dart';
import '../../user_post/models/user_post.dart';
import '../models/Topics/YarnTopic.dart';
import '../widgets/url_reader_of_yarn.dart';
import '../widgets/yarn_media_renderer.dart';
import '../widgets/yarn_options.dart';
import '../yarn_dashboard_bloc.dart';

class YarnTile extends StatefulWidget {
  Yarn yarn;
  Function(Yarn)? onDeleteYarn;
  Function(Yarn)? onReYarn;
  Function(Yarn)? onUpdateYarn;
  final Color? backGroundColor;

  YarnTile({
    required this.yarn,
    this.backGroundColor,
    this.onDeleteYarn,
    this.onUpdateYarn,
    this.onReYarn,
  });

  @override
  State<YarnTile> createState() => _YarnTileState();
}

class _YarnTileState extends State<YarnTile> {
  /// variables for yarn tile render TYPE
  bool isMediaPresent = false;
  bool isAttachmentPresent = false;
  bool isReYarnPresent = false;
  bool isUrlPresent = false;
  String? linkToBePreview;

  late YarnDashboardBloc _yarnSettings;

  @override
  void initState() {
    _yarnSettings = Provider.of<YarnDashboardBloc>(context, listen: false);
    Map<String, dynamic> linkData =
        detectLinkInText(messageDecoderWithEmoji(widget.yarn.body)!);

    if (linkData["hasLink"]) {
      isUrlPresent = true;

      linkToBePreview = linkData['links'][0];
      if (!linkToBePreview!.contains("http")) {
        linkToBePreview = "http://" + linkToBePreview!;
      }
    }

    if (widget.yarn.reYarn != null) {
      isReYarnPresent = true;
    }

    if (widget.yarn.media.isNotEmpty) {
      isMediaPresent = true;
    }

    if (widget.yarn.attachment != null) {
      isAttachmentPresent = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: _buildMain(),
    );
  }

  Widget _buildMain() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(),
        if (widget.yarn.body != null && widget.yarn.body!.isNotEmpty) ...[
          SizedBox(
            height: 10,
          ),
          _buildPostDescription(),
          SizedBox(
            height: 10,
          ),
        ],
        if (widget.yarn.tags != null && widget.yarn.viewersAvatars != null )...[
          _buildTagsAndViewerRow(),
        ],
        if (isReYarnPresent && widget.yarn.reYarn != null) ...[
          getDisplayWidget(_buildReYarnTile),
          SizedBox(
            height: 8,
          ),
        ],
        if (isAttachmentPresent && widget.yarn.attachment != null) ...[
          getDisplayWidget(_buildAttachment),
          SizedBox(
            height: 8,
          ),
        ],
        if (isMediaPresent) ...[
          getDisplayWidget(_buildImagesRow),
          SizedBox(
            height: 8,
          ),
        ],
        widget.yarn.factChecked == true
            ? _buildFactCheckWidget()
            : SizedBox.shrink(),
        SizedBox(height: 6),
        _buildTopActions(),
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
        if (widget.yarn.category != null) ...[
          _buildCategoryTypeChip(),
          SizedBox(
            height: 8,
          ),
        ],
        if (widget.yarn.isQuestion) ...[
          _buildPostTitle(),
          SizedBox(height: 8),
        ],
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
                      verifiedIconSize: 16,
                      textStyle: TextStyle(
                        color: yarnBlack.withOpacity(.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      verifiedIconColor: verifyBlue,
                    ),
                  ],
                ),
              ),
            ),
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
                        isComment: false,
                        onDeleteYarn: (Yarn yarn) {
                          widget.onDeleteYarn!(yarn);
                        },
                        onUpdate: (Yarn yarn) {
                          widget.onUpdateYarn!(yarn);
                          // widget.yarn = yarn;
                          // if(mounted) setState(() {});
                        },
                      ),
                    );
                  },
                );
              },
              child: Icon(
                Icons.more_horiz_rounded,
                color: darkGreyYarn,
              ),
            )
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
        height: 34,
        width: 34,
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

  Widget _buildCategoryTypeChip() {
    if (widget.yarn.category != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: yarnBlack,
        ),
        child: Text(
          widget.yarn.category!.name ?? "",
          style: TextStyle(
              color: white, fontSize: 10.5, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Widget _buildPostTitle() {
    return RichTextForTitle(
      description: messageDecoderWithEmoji(widget.yarn.title ?? '') ?? '',
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildTagsAndViewerRow() {
    List<String> selectedImages = [];
    if (widget.yarn.viewersAvatars != null) {
      for (ViewersAvatars avatars in widget.yarn.viewersAvatars!) {
        selectedImages.add(avatars.avatar!);
      }
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Wrap(
                runSpacing: 5,
                spacing: 2,
                children: widget.yarn.tags!
                    .map((e) => Text(
                          "#$e",
                          style: TextStyle(
                              fontSize: 12,
                              color: navyBlue,
                              fontWeight: FontWeight.w500),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(
              width: 70,
              child: ViewerArranger(selectedImages: selectedImages),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildReYarnTile() {
    return ReYarnTile(
      yarn: widget.yarn.reYarn ?? Yarn(),
    );
  }

  Widget _buildTopActions() {
    return YarnActions(
      yarn: widget.yarn,
      onReYarnAdded: (Yarn yarn) {
        widget.onReYarn!(yarn);
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

  Widget _buildPostDescription() {
    if (isUrlPresent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          LinkWell(
            messageDecoderWithEmoji(widget.yarn.body)!,
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
      description: messageDecoderWithEmoji(widget.yarn.body ?? '') ?? '',
      fontSize: 14,
    );
  }

  Widget _buildImagesRow() {
    return YarnMediaRender(
      yarnTopic: widget.yarn,
    );
  }

  Widget _buildFactCheckWidget() {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(right: 84),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.5),
          color: Color.fromARGB(255, 247, 224, 154)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset('assets/images/yarn/yell_icon.svg'),
          SizedBox(
            width: 2,
          ),
          Text(
            'We doubt the information in the Yarn is correct.',
            style: TextStyle(
                color: Color.fromARGB(255, 187, 118, 27), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSensitiveContentWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: deepPink),
          color: lightPink),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The following Yarn may contain sensitive information',
            style: TextStyle(
                color: blackFont, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'This media is not available because it contains content you’ve chosen not to see.',
            style: TextStyle(
                color: blackFont, fontSize: 12, fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              clickWidget(
                text: 'View',
                onClick: () {
                  setState(() {
                    widget.yarn.isSensitiveContent = false;
                  });
                },
              ),
              SizedBox(
                width: 10,
              ),
              clickWidget(
                text: 'Always show me sensitive media',
                onClick: () {
                  print('sensitive');
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAdultContentWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color.fromARGB(255, 187, 118, 27)),
          color: Color.fromARGB(255, 249, 242, 222)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The following Yarn may contain adult content',
            style: TextStyle(
                color: blackFont, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'This media is not available because it contains content you’ve chosen not to see.',
            style: TextStyle(
                color: blackFont, fontSize: 12, fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              clickWidget(
                text: 'View',
                onClick: () {
                  setState(() {
                    widget.yarn.isAdultContent = false;
                  });
                },
              ),
              SizedBox(
                width: 10,
              ),
              clickWidget(
                text: 'Always show me sensitive media',
                onClick: () {
                  print('sensitive');
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget getDisplayWidget(Function() widgetDisplay) {
    if (widget.yarn.isSensitiveContent == true &&
        _yarnSettings.yarnSettings?.allowSensitiveContent == false) {
      return _buildSensitiveContentWidget();
    }
    if (widget.yarn.isAdultContent == true &&
        _yarnSettings.yarnSettings?.allowAdultContent == false) {
      return _buildAdultContentWidget();
    }
    return widgetDisplay();
  }

  Widget clickWidget({String? text, Function()? onClick}) => GestureDetector(
        onTap: onClick,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: blackFont),
          child: Text(
            text ?? '',
            style: TextStyle(
                color: white, fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ),
      );
}
