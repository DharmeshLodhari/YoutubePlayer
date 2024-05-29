import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/re_yarn_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_blog_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_customer_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_product_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_service_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/rich_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/link_preview/flutter_link_preview.dart';
import '../../../../utils/link_preview/web_analyzer.dart';
import '../../../../utils/util.dart';
import '../../user_post/models/user_post.dart';
import '../../user_profile/screens/user_profile_module_new/utils.dart';
import '../models/Topics/yarn_model.dart';
import '../utils/slydo_yarn_links.dart';
import '../widgets/url_reader_of_yarn.dart';
import '../widgets/yarn_media_renderer.dart';
import '../yarn_dashboard_bloc.dart';

class YarnQuotePreview extends StatefulWidget {
  Yarn yarn;
  Function(Yarn)? onDeleteYarn;
  Function(Yarn)? onReYarn;
  Function(Yarn)? onUpdateYarn;
  Function()? navigateToReyarn;
  final Color? backGroundColor;

  YarnQuotePreview(
      {required this.yarn,
      this.backGroundColor,
      this.onDeleteYarn,
      this.onUpdateYarn,
      this.onReYarn,
      this.navigateToReyarn});

  @override
  State<YarnQuotePreview> createState() => _YarnQuotePreviewState();
}

class _YarnQuotePreviewState extends State<YarnQuotePreview> {
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
    final Map<String, dynamic> linkData =
        detectLinkInText(messageDecoderWithEmoji(widget.yarn.body)!);

    if (linkData["hasLink"]) {
      isUrlPresent = true;

      linkToBePreview = linkData['links'][0];
      if (!linkToBePreview!.contains("http")) {
        linkToBePreview = "http://${linkToBePreview!}";
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

  bool _showText() {
    if (isAttachmentPresent &&
        widget.yarn.attachment != null &&
        widget.yarn.attachment?.isEmpty == false) {
      return false;
    }
    if (isMediaPresent) {
      return false;
    }
    if (widget.yarn.body != null && widget.yarn.body!.isNotEmpty) {
      return true;
    }
    return false;
  }

  bool shouldShowYarnText() {
    if (widget.yarn.isSensitiveContent == true &&
        _yarnSettings.yarnSettings.allowSensitiveContent == false) {
      return _showText();
    } else if (widget.yarn.isAdultContent == true &&
        _yarnSettings.yarnSettings.allowAdultContent == false) {
      return _showText();
    }
    return true;
  }

  Widget _buildMain() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(),

        const SizedBox(
          height: 4,
        ),

        if (shouldShowYarnText() == true) ...[
          if (widget.yarn.body.toString().isNotEmpty) ...[
            const SizedBox(
              height: 10,
            ),
            _buildPostDescription(),
            const SizedBox(
              height: 10,
            ),
          ]
        ] else
          const SizedBox(
            height: 8,
          ),
        if (isReYarnPresent && widget.yarn.reYarn != null) ...[
          const SizedBox(
            height: 10,
          ),
          getDisplayWidget(_buildReYarnTile),
          const SizedBox(
            height: 8,
          ),
        ],
        if (isAttachmentPresent &&
            widget.yarn.attachment != null &&
            widget.yarn.attachment?.isEmpty == false) ...[
          const SizedBox(
            height: 10,
          ),
          getDisplayWidget(_buildAttachment),
          const SizedBox(
            height: 8,
          ),
        ],
        // if (isReYarnPresent && widget.yarn.reYarn != null) ...[
        //   getDisplayWidget(_buildReYarnTile),
        //   SizedBox(
        //     height: 8,
        //   ),
        // ],
        // if (isAttachmentPresent && widget.yarn.attachment != null) ...[
        //   getDisplayWidget(_buildAttachment),
        //   SizedBox(
        //     height: 8,
        //   ),
        // ],
        if (isMediaPresent) ...[
          const SizedBox(
            height: 10,
          ),
          getDisplayWidget(_buildImagesRow),
          const SizedBox(
            height: 8,
          ),
        ],
        widget.yarn.factChecked == true
            ? _buildFactCheckWidget()
            : const SizedBox.shrink(),
        const SizedBox(height: 6),
        // _buildTopActions(),
      ],
    );
  }

  Widget _buildUserInfoRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 4,
        ),
        if (widget.yarn.category != null) ...[
          _buildCategoryTypeChip(),
          const SizedBox(
            height: 8,
          ),
        ],
        if (widget.yarn.isQuestion) ...[
          _buildPostTitle(),
          const SizedBox(height: 8),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserAvatar(),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        messageDecoderWithEmoji(widget.yarn.authorName ?? "") ??
                            "",
                        style: TextStyle(
                            fontSize: 14,
                            color: yarnBlack,
                            fontWeight: FontWeight.w700),
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
                    verifiedIconColor: verifyGreen,
                  ),
                  // SizedBox(height: 5.0,),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      height: 34,
      width: 34,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.yarn.authorAvatar!,
          fit: BoxFit.cover,
          errorWidget: imageErrorWidget,
        ),
      ),
    );
  }

  Widget _buildCategoryTypeChip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _checkCategoryTypeChip(),
        Container(
          child: getFollowersWidget(widget,
              radiusSize: 28,
              radiusShift: 10,
              radiusHeight: 28,
              radiusWidth: 28),
        ),
      ],
    );
  }

  Widget _checkCategoryTypeChip() {
    if (widget.yarn.category != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      return const SizedBox();
    }
  }

  Widget _buildPostTitle() {
    return RichTextForTitle(
      description: widget.yarn.title ?? '',
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildReYarnTile() {
    return ReYarnTile(
      yarn: widget.yarn.reYarn ?? Yarn(),
      onOptionsAction: () {
        if (widget.navigateToReyarn != null) widget.navigateToReyarn!();
      },
    );
  }

  Widget _buildAttachment() {
    Widget childWidget;
    if (widget.yarn.attachmentType == 'service') {
      final Service service = Service.fromJson(widget.yarn.attachment);
      childWidget = YarnServiceTile(
        service: service,
      );
    } else if (widget.yarn.attachmentType == 'product') {
      final Product product = Product.fromJson(widget.yarn.attachment);
      childWidget = YarnProductTile(
        product: product,
      );
    } else if (widget.yarn.attachmentType == 'blog') {
      final UserPost post = UserPost.fromJson(widget.yarn.attachment);
      childWidget = YarnBlogPostTile(
        post: post,
        showAuthorDetails: true,
        onDeleteBlog: () {},
      );
    } else if (widget.yarn.attachmentType == 'profile') {
      final CustomerProfile customerProfile =
          CustomerProfile.fromJson(widget.yarn.attachment ?? {});
      childWidget = YarnCustomerPostTile(
        customerProfile: customerProfile,
        showAuthorDetails: true,
        onDeleteBlog: () {},
      );
    } else {
      childWidget = const SizedBox();
    }
    return childWidget;
  }

  Widget _buildPostDescription() {
    var newString = '';
    final list = [];

    widget.yarn.body.toString().split(' ').forEach((ch) {
      list.add(ch);
      // debugPrint(ch);
    });

    list.forEach((data) {
      if (data.toString().contains('.') &&
          !data.toString().contains('@') &&
          !data.toString().contains('..') &&
          !data.toString().startsWith('.') &&
          !data.toString().startsWith('http') &&
          !data.toString().endsWith('.')) {
        final replaceWith = 'http://' + data;

        newString = '$newString $replaceWith';
      } else {
        newString = '$newString $data';
      }
    });

    if (isUrlPresent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          YarnSmartText(
            text: messageDecoderWithEmoji(newString)!,
            atStyle: TextStyle(color: navyBlue),
            disableAt: false,
            onTagClick: (tag) {},
            onUrlClicked: (open) {
              // launch  url
              debugPrint("opened $open");
            },
            onAtClick: (at) {
              debugPrint("at is  $at");
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
                          webInfo, context, linkToBePreview, 150.0)),
                );
              },
            ),
          ),
        ],
      );
    }

    // debugPrint('Yarn Body:::: ${widget.yarn.body}');

    return RichTextForTitle(
      description: messageDecoderWithEmoji(widget.yarn.body ?? '') ?? '',
      // description: widget.yarn.body ?? '',
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
      padding: const EdgeInsets.all(5),
      //margin: EdgeInsets.only(right: 64),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.5),
          border: Border.all(color: HexColor("#FCCF72")),
          color: HexColor("#FEE6B5")),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset('assets/images/yarn/yell_icon.svg'),
          const SizedBox(
            width: 2,
          ),
          const Text(
            'We doubt the information in the Yarn is correct.',
            style: TextStyle(
                color: Color.fromARGB(255, 187, 118, 27), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSensitiveContentWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
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
          const SizedBox(
            height: 20,
          ),
          Text(
            'This media is not available because it contains content you’ve chosen not to see.',
            style: TextStyle(
                color: blackFont, fontSize: 12, fontWeight: FontWeight.w400),
          ),
          const SizedBox(
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
              const SizedBox(
                width: 10,
              ),
              clickWidget(
                text: 'Always show me sensitive media',
                onClick: () {
                  debugPrint('sensitive');
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
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color.fromARGB(255, 187, 118, 27)),
          color: const Color.fromARGB(255, 249, 242, 222)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The following Yarn may contain adult content',
            style: TextStyle(
                color: blackFont, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'This media is not available because it contains content you’ve chosen not to see.',
            style: TextStyle(
                color: blackFont, fontSize: 12, fontWeight: FontWeight.w400),
          ),
          const SizedBox(
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
              const SizedBox(
                width: 10,
              ),
              clickWidget(
                text: 'Always show me sensitive media',
                onClick: () {
                  debugPrint('sensitive');
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
        _yarnSettings.yarnSettings.allowSensitiveContent == false) {
      return _buildSensitiveContentWidget();
    } else if (widget.yarn.isAdultContent == true &&
        _yarnSettings.yarnSettings.allowAdultContent == false) {
      return _buildAdultContentWidget();
    } else {
      return widgetDisplay();
    }
  }

  Widget clickWidget({String? text, Function()? onClick}) => GestureDetector(
        onTap: onClick,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: blackFont),
          child: Text(
            text ?? '',
            style: TextStyle(
                color: white, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
      );
}
