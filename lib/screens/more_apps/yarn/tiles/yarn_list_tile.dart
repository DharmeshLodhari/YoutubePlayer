import 'dart:developer';

import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/re_yarn_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_blog_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_customer_post_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_product_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_service_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/rich_text.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_actions.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_category_individual_tag.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/state_notifier.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/link_preview/flutter_link_preview.dart';
import '../../../../utils/link_preview/web_analyzer.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../service_hub/models/jobs.dart';
import '../../service_hub/tiles/jos_description_card.dart';
import '../../user_post/models/user_post.dart';
import '../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../../user_profile/screens/user_profile_module_new/utils.dart';
import '../yarn_search_screen.dart';
import '../models/Topics/yarn_model.dart';
import '../utils/slydo_yarn_links.dart';
import '../widgets/url_reader_of_yarn.dart';
import '../widgets/yarn_media_renderer.dart';
import '../widgets/yarn_options.dart';
import '../yarn_dashboard_bloc.dart';
import '../yarn_setting_screen.dart';

class YarnTile extends StatefulWidget {
  Yarn yarn;
  Function(Yarn)? onDeleteYarn;
  Function(Yarn)? onReYarn;
  Function(Yarn)? onUpdateYarn;
  Function()? navigateToReyarn;
  final Color? backGroundColor;
  bool? minusComment;
  List<Yarn>? checkIfReyarned;
  Function(bool)? reloadView;

  YarnTile(
      {required this.yarn,
      this.backGroundColor,
      this.onDeleteYarn,
      this.onUpdateYarn,
      this.onReYarn,
      this.navigateToReyarn,
      this.minusComment,
      this.checkIfReyarned,
      this.reloadView});

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
  late UserBloc userBloc;

  @override
  void initState() {
    _yarnSettings = Provider.of<YarnDashboardBloc>(context, listen: false);

    if (widget.yarn.body != null) {
      // widget.yarn.body =
      //     'Read this https://www.fastcompany.com/90828081/take-time-back-2023-planning-strategies';
      // widget.yarn.body = 'Read this now espn.com';
      // widget.yarn.body =
      //     'Read this https://www.simplilearn.com/building-career-in-mobile-app-development-article';

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
    userBloc = Provider.of<UserBloc>(context);
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
        SizedBox(
          height: 4,
        ),
        if (shouldShowYarnText() == true) ...[
          if (widget.yarn.body.toString().isNotEmpty) ...[
            SizedBox(
              height: 10,
            ),
            _buildPostDescription(),
            SizedBox(
              height: 10,
            ),
          ]
        ] else
          SizedBox(
            height: 8,
          ),
        if (isMediaPresent) ...[
          SizedBox(
            height: 10,
          ),
          getDisplayWidget(_buildImagesRow),
          SizedBox(
            height: 8,
          ),
        ],
        if (isAttachmentPresent &&
            widget.yarn.attachment != null &&
            widget.yarn.attachment?.isEmpty == false) ...[
          SizedBox(
            height: 10,
          ),
          getDisplayWidget(_buildAttachment),
          SizedBox(
            height: 8,
          ),
        ],
        SizedBox(
          height: 8,
        ),
        if (isReYarnPresent && widget.yarn.reYarn != null) ...[
          SizedBox(
            height: 10,
          ),
          getDisplayWidget(_buildReYarnTile),
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
    var author = messageDecoderWithEmoji(widget.yarn.authorName ?? "") ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 4,
        ),
        if (widget.yarn.category != null && widget.yarn.reYarn != null) ...[
          _buildCategoryTypeChip(),
          SizedBox(
            height: 8,
          ),
        ] else if (widget.yarn.category != null) ...[
          _buildCategoryTypeChip(),
          SizedBox(
            height: 8,
          ),
        ] else if (widget.yarn.reYarn != null) ...[
          _checkCategoryTypeChipReyarn(),
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
                          appendStringDot(author, 25),
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
                      verifiedIconColor: verifyGreen,
                    ),
                    // SizedBox(height: 5.0,),
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
                        },
                        reloadView: (bool val) {
                          if (val == true) {
                            widget.reloadView!(true);
                          }
                        },
                      ),
                    );
                  },
                );
              },
              child: Icon(
                Icons.more_horiz_outlined,
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
        String? image = '';
        if (widget.yarn.authorAvatar! == "" ||
            widget.yarn.authorAvatar! ==
                "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
          image = getInitials(widget.yarn.authorName!).toUpperCase();
        } else {
          image = widget.yarn.authorAvatar!;
        }

        Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER, arguments: image);
      },
      child:
          getUserProfilePic(widget.yarn.authorAvatar!, widget.yarn.authorName!),
    );
  }

  Widget _buildCategoryTypeChip() {
    List<UserFollowers> viewers = [];

    if (widget.yarn.viewersAvatars != null) {
      for (ViewersAvatars avatars in widget.yarn.viewersAvatars!) {
        UserFollowers follower = UserFollowers(avatar: avatars.avatar!);
        viewers.add(follower);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _checkCategoryTypeChip(),
        if (viewers.length != 0) ...[
          Container(
            child: followersWidget(userImages: viewers),
          ),
        ],
      ],
    );
  }

  Widget _checkCategoryTypeChip() {
    if (widget.yarn.category != null) {
      return InkWell(
        onTap: () {
          NavigationUtil.push(
            context,
            screen: YarnCategoryIndividualTag(
              askCategories: widget.yarn.category,
            ),
          );
        },
        child: Container(
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
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Widget _checkCategoryTypeChipReyarn() {
    if (widget.yarn.reYarn != null) {
      return InkWell(
        onTap: () {
          NavigationUtil.push(
            context,
            screen: YarnCategoryIndividualTag(
              askCategories: widget.yarn.reYarn!.category,
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: yarnBlack,
          ),
          child: Text(
            widget.yarn.reYarn!.category!.name ?? "",
            style: TextStyle(
                color: white, fontSize: 10.5, fontWeight: FontWeight.w700),
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Widget _buildPostTitle() {
    return RichTextForTitle(
      description: widget.yarn.title ?? '',
      fontSize: 17,
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

  Widget _buildTopActions() {
    return YarnActions(
      yarn: widget.yarn,
      onReYarnAdded: (Yarn yarn) {
        widget.onReYarn!(yarn);
      },
      minusComment: widget.minusComment,
      checkIfReyarned: widget.checkIfReyarned,
    );
  }

  Widget _buildAttachment() {
    Widget childWidget;

    String? attachmentType = widget.yarn.attachmentType;

    switch (attachmentType) {
      case 'service':
        Service service = Service.fromJson(widget.yarn.attachment);
        childWidget = YarnServiceTile(
          service: service,
        );
        break;

      case 'product':
        Product product = Product.fromJson(widget.yarn.attachment);
        childWidget = YarnProductTile(
          product: product,
        );

        break;

      case 'blog':
        UserPost post = UserPost.fromJson(widget.yarn.attachment);
        childWidget = YarnBlogPostTile(
          post: post,
          showAuthorDetails: true,
          onDeleteBlog: () {},
        );
        break;

      case 'profile':
        CustomerProfile customerProfile =
            CustomerProfile.fromJson(widget.yarn.attachment ?? {});

        childWidget = YarnCustomerPostTile(
          customerProfile: customerProfile,
          showAuthorDetails: true,
          onDeleteBlog: () {},
        );

        break;
      case 'job':
        JobModel jobModel = JobModel.fromJson(widget.yarn.attachment ?? {});
        childWidget = GestureDetector(
            onTap: () {
              userBloc.user.userName == jobModel.owner
                  ? Navigator.pushNamed(context, Routes.MY_JOB_DETAILS,
                      arguments: {
                          'jobId': jobModel,
                          'listingId': jobModel.id,
                          'job': jobModel
                        })
                  : Navigator.pushNamed(context, Routes.JOBS_PREVIEW_DETAIL,
                      arguments: {
                          'jobId': jobModel.id,
                          'listingId': jobModel.id,
                          'job': jobModel
                        });
            },
            child: JobDescriptionCard(job: jobModel));
        break;

      default:
        childWidget = SizedBox();

        break;
    }

    return childWidget;
  }

  Widget _buildPostDescription() {
    var removedLink = '';

    removedLink = removeLinksAndWords(
        widget.yarn.body != null ? widget.yarn.body! : '', []);

    if (isUrlPresent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          YarnSmartText(
            text: messageDecoderWithEmoji(removedLink)! ?? '',
            style: TextStyle(
                color: blackFont, fontSize: 14, fontFamily: "OpenSans"),
            // atStyle: TextStyle(
            //     color: navyBlue, fontSize: 17, fontFamily: "OpenSans"),
            disableAt: false,
            onTagClick: (tag) {
              NavigationUtil.push(context,
                  screen: SearchScreen(searchText: tag.trim()));
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
              key: ValueKey("${linkToBePreview}211"),
              url: linkToBePreview!,
              builder: (info) {
                if (info == null)
                  // return const SizedBox(
                  //   height: 0,
                  //   width: 0,
                  // );

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
                          webInfo, context, linkToBePreview, 150.0)),
                );
              },
            ),
          ),
        ],
      );
    }

    return YarnSmartText(
      text: messageDecoderWithEmoji(removedLink)! ?? '',
      style: TextStyle(color: blackFont, fontSize: 14, fontFamily: "OpenSans"),
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
        Navigator.pushNamed(context, Routes.USER_PROFILE, arguments: {
          "searchedUserName": at.replaceAll(RegExp('@'), '').trim()
        });
      },
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
          SizedBox(
            width: 2,
          ),
          Text(
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
                text: 'Change sensitive media settings',
                onClick: () {
                  NavigationUtil.push(
                    context,
                    screen: YarnSettingsScreen(),
                  );
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
                text: 'Change adult content settings',
                onClick: () {
                  NavigationUtil.push(
                    context,
                    screen: YarnSettingsScreen(),
                  );
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
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
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
