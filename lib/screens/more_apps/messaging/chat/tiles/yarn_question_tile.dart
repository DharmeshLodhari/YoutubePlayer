import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/slydo_yarn_links.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_detail_screen.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_search_screen.dart';
import 'package:Slydo/utils/link_preview/flutter_link_preview.dart';
import 'package:Slydo/utils/link_preview/web_analyzer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../main.dart';
import '../../../../../routes/route_constants.dart';
import '../../../../../utils/navigation_util.dart';
import '../../../../../utils/util.dart';
import '../../../shopping/models/store.dart';
import '../../../user_post/models/user_post.dart';
import '../../../user_profile/models/user.dart';
import '../../../yarn/tiles/re_yarn_tile.dart';
import '../../../yarn/tiles/yarn_blog_post_tile.dart';
import '../../../yarn/tiles/yarn_customer_post_tile.dart';
import '../../../yarn/tiles/yarn_product_tile.dart';
import '../../../yarn/tiles/yarn_service_tile.dart';
import '../../../yarn/utils/utils.dart';
import '../../../yarn/widgets/rich_text.dart';
import '../../../yarn/widgets/url_reader_of_yarn.dart';
import '../../../yarn/widgets/yarn_media_renderer.dart';
import '../../../yarn/yarn_dashboard_bloc.dart';

class YarnQuestionTileForChat extends StatefulWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  YarnQuestionTileForChat(
      {Key? key, required this.message, required this.chatConversation})
      : super(key: key);

  @override
  State<YarnQuestionTileForChat> createState() =>
      _YarnQuestionTileForChatState();
}

class _YarnQuestionTileForChatState extends State<YarnQuestionTileForChat> {
  late UserBloc userBloc;
  late YarnQuestionForChatModel yarnQuestionForChatModel;
  late Yarn yarn;
  // VideoPlayerController? _mainVideoController;
  bool isLoading = false;
  bool isMediaPresent = false;
  bool isNewModel = false;

  bool isAttachmentPresent = false;
  bool isReYarnPresent = false;
  bool isUrlPresent = false;
  String? linkToBePreview;

  late YarnDashboardBloc _yarnSettings;

  @override
  void initState() {
    super.initState();

    checkModel();
    // if (momentForChatModel.video != null) {
    //   isLoading = true;
    //   if (mounted) setState(() {});
    //   _mainVideoController = VideoPlayerController.network(
    //     momentForChatModel.video!,
    //     videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    //   )..initialize().then((_) {
    //       isLoading = false;
    //       if (mounted) setState(() {});
    //     });
    // }
  }

  void checkModel() {
    _yarnSettings = Provider.of<YarnDashboardBloc>(context, listen: false);
    try {
      yarnQuestionForChatModel = YarnQuestionForChatModel();
      var meta = widget.message!['meta_data'];

      yarn = Yarn.fromJson(jsonDecode(meta));
      if (yarn != null) {
        Map<String, dynamic> linkData =
            detectLinkInText(messageDecoderWithEmoji(yarn.body)!);

        if (linkData["hasLink"]) {
          isUrlPresent = true;

          linkToBePreview = linkData['links'][0];
          if (!linkToBePreview!.contains("http")) {
            // debugPrint('Link to view question::: ${linkData.toString()}');

            linkToBePreview = "http://" + linkToBePreview!;
          }
        }
        if (yarn.attachment != null) {
          isAttachmentPresent = true;
        }
        if (yarn.reYarn != null) {
          isReYarnPresent = true;
        }
        if (yarn.media.isNotEmpty) {
          isMediaPresent = true;
        }
      }

      isNewModel = true;
      if (mounted) setState(() {});
      debugPrint("TRY:- $yarnQuestionForChatModel");
    } catch (error) {
      debugPrint("ERROR:- $error");
      // yarnQuestionForChatModel = YarnQuestionForChatModel.fromJson(jsonDecode(widget.message!['meta_data']));
      // isNewModel = false;
      // if (mounted) setState(() {});
      debugPrint("CATCH:- $yarn");
    }
  }

  @override
  void dispose() {
    super.dispose();
    // _mainVideoController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    bool isSend = widget.message!["author"] == userBloc.user.userName;

    return GestureDetector(
      onTap: () async {
        isLoading = true;
        if (mounted) setState(() {});

        await YarnAuth().getSingleTopics(yarnId: yarn.id).then((data) {
          Yarn? yarnTopic;
          if (data != null) {
            yarnTopic = data['results'];
          }
          isLoading = false;
          if (mounted) setState(() {});

          if (yarnTopic != null) {
            NavigationUtil.push(
              context,
              screen: YarnDetailScreen(
                yarn: yarnTopic,
              ),
            );
          }
        }).catchError((e) {
          isLoading = false;
          if (mounted) setState(() {});
          showToast(message: 'ERROR -> $e');
        });
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isSend ? Container() : Container(width: 20),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.35,
                  minWidth: MediaQuery.of(context).size.width / 1.35,
                  //maxHeight: 200,
                ),
                decoration: BoxDecoration(
                  color: widget.chatConversation!.isGroupConversation!
                      ? isSend
                          ? Colors.transparent
                          : Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 20),
                    bottomRight: Radius.circular(isSend ? 0 : 20),
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: widget.chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : 0,
                    vertical: widget.chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.chatConversation!.isGroupConversation!
                        ? widget.message!['author'] != userBloc.user.userName
                            ? Column(
                                children: [
                                  Text(
                                    widget.message!['author_full_name'] ??
                                        widget.message!['author'],
                                    style: TextStyle(
                                        color: isSend ? Colors.white : navyBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                ],
                              )
                            : Container(
                                height: 0,
                                width: 0,
                              )
                        : Container(
                            height: 0,
                            width: 0,
                          ),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        decoration: decorateBox(color: Colors.white),
                        padding: EdgeInsets.only(
                            right: 10, top: 10, left: 10, bottom: 4),
                        child: _buildMainCard(),
                      ),
                    ),
                  ],
                ),
              ),
              isSend
                  ? Container(
                      width: 20,
                      child: isSend
                          ? Center(
                              child: getMessageTick(message: widget.message!),
                            )
                          : Container(),
                    )
                  : Container(),
            ],
          ),
          SizedBox(
            height: 2,
          ),
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              isSend
                  ? Container()
                  : SizedBox(
                      width: 20,
                    ),
              Text(
                formatTime(widget.message!['created_at']),
                style: TextStyle(
                    color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
              ),
              isSend
                  ? SizedBox(
                      width: 20,
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    if (isNewModel) {
      return _buildMain();
    } else {
      return _buildPostCard();
    }
  }

  Widget _buildPostCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(),
        SizedBox(
          height: 10,
        ),
        if (yarnQuestionForChatModel.isQuestion ?? false) ...[
          _buildPostTitle(),
          SizedBox(
            height: 10,
          ),
        ],
        _buildPostDescription(),
        SizedBox(
          height: 10,
        ),
        if (yarnQuestionForChatModel.media != null) ...[
          _buildImagesRow(context: context),
          SizedBox(
            height: 6,
          ),
        ]
      ],
    );
  }

  Widget _buildUserInfoRow() {
    return Row(
      children: [
        Row(
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: yarnQuestionForChatModel.authorAvatar!,
                  fit: BoxFit.cover,
                  errorWidget: imageErrorWidget,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        Expanded(
            child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userNameWithVerifiedIcon(
                      name: yarnQuestionForChatModel.authorName ?? "",
                      isVerified:
                          yarnQuestionForChatModel.authorIsVerified ?? false),
                  Text(
                    "@${yarnQuestionForChatModel.authorUsername ?? ''}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: HexColor("#3F61DB")),
                  ),
                ],
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildPostTitle() {
    return Text(
      yarnQuestionForChatModel.title!,
      overflow: TextOverflow.ellipsis,
      maxLines: 3,
      style: TextStyle(
        color: blackFont,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPostDescription() {
    var newString = '';
    var list = [];

    yarn.body.toString().split(' ').forEach((ch) {
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
                          webInfo, context, linkToBePreview, 150.0)),
                );
              },
            ),
          ),
        ],
      );
    }

    return YarnSmartText(
      text: messageDecoderWithEmoji(newString)! ?? '',
      style: TextStyle(color: blackFont, fontSize: 14, fontFamily: "OpenSans"),
      // atStyle: TextStyle(color: navyBlue, fontSize: 17, fontFamily: "OpenSans"),
      disableAt: false,
      onTagClick: (tag) {
        NavigationUtil.push(context,
            screen: SearchScreen(searchText: tag.trim()));
      },
      onAtClick: (at) {
        Navigator.pushNamed(context, Routes.USER_PROFILE, arguments: {
          "searchedUserName": at.replaceAll(RegExp('@'), '').trim()
        });
      },
    );
  }

  Widget _buildImagesRow({required BuildContext context}) {
    if (yarnQuestionForChatModel.media!.length == 1) {
      return _buildSingleImage(context: context);
    } else if (yarnQuestionForChatModel.media!.length == 2) {
      return _buildTwoImageRow(context: context);
    } else if (yarnQuestionForChatModel.media!.length == 3) {
      return _buildThreeImageRow(context: context);
    } else if (yarnQuestionForChatModel.media!.length >= 4) {
      return _buildFourImageRow(context: context);
    }
    return SizedBox();
  }

  Widget _buildSingleImage({required BuildContext context}) {
    return Container(
      width: double.infinity,
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: yarnQuestionForChatModel.media!.first.file!,
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
          ),
        ),
      ),
    );
  }

  Widget _buildTwoImageRow({required BuildContext context}) {
    return Container(
      height: 175,
      child: Row(
        children: yarnQuestionForChatModel.media!
            .map(
              (mediaFile) => Expanded(
                child: Container(
                  height: (MediaQuery.of(context).size.width - 40) / 2,
                  width: (MediaQuery.of(context).size.width - 40) / 2,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: yarnQuestionForChatModel.media![0].file!,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                      errorWidget: imageErrorWidget,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildThreeImageRow({required BuildContext context}) {
    return Container(
      height: 175,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: (MediaQuery.of(context).size.width - 40) / 2,
              width: (MediaQuery.of(context).size.width - 40) / 2,
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: yarnQuestionForChatModel.media![0].file!,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorWidget: imageErrorWidget,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: (MediaQuery.of(context).size.width - 40) / 2,
              width: (MediaQuery.of(context).size.width - 40) / 2,
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: yarnQuestionForChatModel.media![1].file!,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorWidget: imageErrorWidget,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: (MediaQuery.of(context).size.width - 40) / 2,
              width: (MediaQuery.of(context).size.width - 40) / 2,
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: yarnQuestionForChatModel.media![2].file!,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorWidget: imageErrorWidget,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourImageRow({required BuildContext context}) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: (MediaQuery.of(context).size.width - 40) / 2,
                  width: (MediaQuery.of(context).size.width - 40) / 2,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: yarnQuestionForChatModel.media![0].file!,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                      errorWidget: imageErrorWidget,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: (MediaQuery.of(context).size.width - 40) / 2,
                  width: (MediaQuery.of(context).size.width - 40) / 2,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: yarnQuestionForChatModel.media![1].file!,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                      errorWidget: imageErrorWidget,
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: (MediaQuery.of(context).size.width - 40) / 2,
                  width: (MediaQuery.of(context).size.width - 40) / 2,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: yarnQuestionForChatModel.media![2].file!,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                      errorWidget: imageErrorWidget,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: (MediaQuery.of(context).size.width - 40) / 2,
                  width: (MediaQuery.of(context).size.width - 40) / 2,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: yarnQuestionForChatModel.media![3].file!,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                      errorWidget: imageErrorWidget,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMain() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRowNew(),
        SizedBox(
          height: 10,
        ),
        if (yarn.isQuestion) ...[
          _buildPostTitleNew(),
          SizedBox(height: 8),
        ],
        _buildPostDescriptionNew(),
        SizedBox(
          height: 10,
        ),
        if (isReYarnPresent && yarn.reYarn != null) ...[
          getDisplayWidget(_buildReYarnTile),
          SizedBox(
            height: 8,
          ),
        ],
        if (isAttachmentPresent &&
            yarn.attachment != null &&
            yarn.attachment?.isEmpty != true) ...[
          getDisplayWidget(_buildAttachment),
          SizedBox(
            height: 8,
          ),
        ],
        if (isMediaPresent) ...[
          _buildImagesRowNew(),
          SizedBox(
            height: 8,
          ),
        ],
        yarn.factChecked == true ? _buildFactCheckWidget() : SizedBox.shrink(),
        SizedBox(height: 6),
      ],
    );
  }

  Widget _buildUserInfoRowNew() {
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
                      arguments: {"searchedUserName": yarn.author});
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            messageDecoderWithEmoji(yarn.authorName ?? "") ??
                                "",
                            style: TextStyle(fontSize: 12, color: yarnBlack),
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          yarn.createdAt != null
                              ? '${getGetYarnQuestionDateTime(yarn.createdAt!)}'
                              : "",
                          overflow: TextOverflow.fade,
                          style: TextStyle(fontSize: 12, color: yarnBlack),
                        ),
                      ],
                    ),
                    userNameWithVerifiedIcon(
                      name: "@${yarn.author!}",
                      isVerified: yarn.authorIsVerified ?? false,
                      verifiedIconSize: 16,
                      textStyle: TextStyle(
                        color: yarnBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
        Navigator.of(context)
            .pushNamed(Routes.PHOTO_VIEWER, arguments: yarn.authorAvatar!);
      },
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: yarn.authorAvatar!,
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
          ),
        ),
      ),
    );
  }

  Widget _buildPostTitleNew() {
    return RichTextForTitle(
      description: yarn.title ?? '',
    );
  }

  Widget _buildPostDescriptionNew() {
    var newString = '';
    var list = [];

    yarn.body.toString().split(' ').forEach((ch) {
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
      text: messageDecoderWithEmoji(newString)! ?? '',
      style: TextStyle(color: blackFont, fontSize: 14, fontFamily: "OpenSans"),
      // atStyle: TextStyle(color: navyBlue, fontSize: 17, fontFamily: "OpenSans"),
      disableAt: false,
      onTagClick: (tag) {
        NavigationUtil.push(context,
            screen: SearchScreen(searchText: tag.trim()));
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
    if (yarn.attachmentType == 'service') {
      Service service = Service.fromJson(yarn.attachment);
      childWidget = YarnServiceTile(
        service: service,
      );
    } else if (yarn.attachmentType == 'product') {
      Product product = Product.fromJson(yarn.attachment);
      childWidget = YarnProductTile(
        product: product,
      );
    } else if (yarn.attachmentType == 'blog') {
      UserPost post = UserPost.fromJson(yarn.attachment);
      childWidget = YarnBlogPostTile(
        post: post,
        showAuthorDetails: true,
        onDeleteBlog: () {},
      );
    } else if (yarn.attachmentType == 'profile') {
      // logger.d("profile yarn.attachment: ${yarn.attachment}, ${yarn.id}");
      // logger.d("profile yarn.createdAt: ${yarn.createdAt}");
      CustomerProfile customerProfile =
          CustomerProfile.fromJson(yarn.attachment ?? {});
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

  //
  // Widget _buildTopActions() {
  //   return YarnActions(
  //     yarn: yarn,
  //   );
  // }

  Widget _buildReYarnTile() {
    return ReYarnTile(
      yarn: yarn.reYarn ?? Yarn(),
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
                    yarn.isSensitiveContent = false;
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
                    yarn.isAdultContent = false;
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
    if (yarn.isSensitiveContent == true &&
        _yarnSettings.yarnSettings?.allowSensitiveContent == false) {
      return _buildSensitiveContentWidget();
    }
    if (yarn.isAdultContent == true &&
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
                color: white, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
      );

  Widget _buildImagesRowNew() {
    return YarnMediaRender(
      yarnTopic: yarn,
    );
  }
}

class YarnQuestionForChatModel {
  String? id;
  String? authorAvatar;
  String? authorUsername;
  String? authorName;
  String? title;
  String? description;
  List? tags;
  List<MediaFile>? media;
  bool? isQuestion;
  bool? authorIsVerified;

  YarnQuestionForChatModel({
    this.id,
    this.authorAvatar,
    this.authorUsername,
    this.authorName,
    this.title,
    this.description,
    this.tags,
    this.media,
    this.isQuestion,
    this.authorIsVerified,
  });

  factory YarnQuestionForChatModel.fromJson(Map<String, dynamic> json) {
    return YarnQuestionForChatModel(
        id: json['id'],
        authorAvatar: json['author_avatar'],
        authorUsername: json['author_username'],
        authorName: json['author_name'],
        title: json['title'],
        description: json['description'],
        tags: json['tags'],
        media: json['image'] != null
            ? (json['image'] as List<dynamic>)
                .map((e) => MediaFile.fromJson(e as Map<String, dynamic>))
                .toList()
            : [],
        isQuestion: json['is_question'],
        authorIsVerified: json['author_is_verified']);
  }
}

class MediaFile {
  String? file;
  MediaFile({
    this.file,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(file: json['file']);
  }
}
