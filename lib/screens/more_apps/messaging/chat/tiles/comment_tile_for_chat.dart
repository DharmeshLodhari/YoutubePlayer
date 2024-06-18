import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/comment_details.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/slydo_yarn_links.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_comment_media_renderer.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_comment_detail_screen.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_detail_screen.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_search_screen.dart';
import 'package:Slydo/utils/link_preview/flutter_link_preview.dart';
import 'package:Slydo/utils/link_preview/web_analyzer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../routes/route_constants.dart';
import '../../../../../utils/navigation_util.dart';
import '../../../../../utils/util.dart';
import '../../../shopping/models/store.dart';
import '../../../user_post/models/user_post.dart';
import '../../../user_profile/models/user.dart';
import '../../../yarn/tiles/yarn_blog_post_tile.dart';
import '../../../yarn/tiles/yarn_customer_post_tile.dart';
import '../../../yarn/tiles/yarn_product_tile.dart';
import '../../../yarn/tiles/yarn_service_tile.dart';
import '../../../yarn/utils/utils.dart';
import '../../../yarn/widgets/url_reader_of_yarn.dart';

class CommentTileForChat extends StatefulWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  const CommentTileForChat(
      {super.key, required this.message, required this.chatConversation});

  @override
  State<CommentTileForChat> createState() => _CommentTileForChatState();
}

class _CommentTileForChatState extends State<CommentTileForChat> {
  late UserBloc userBloc;
  late YarnQuestionForChatModel yarnQuestionForChatModel;
  late YarnComment yarnComment;
  bool isLoading = false;
  bool isMediaPresent = false;
  bool isNewModel = false;

  bool isAttachmentPresent = false;
  bool isUrlPresent = false;
  String? linkToBePreview;

  @override
  void initState() {
    super.initState();

    checkModel();
  }

  void checkModel() {
    try {
      yarnQuestionForChatModel = YarnQuestionForChatModel();
      final meta = widget.message!['meta_data'];

      yarnComment = YarnComment.fromJson(jsonDecode(meta));
      if (yarnComment != null) {
        final Map<String, dynamic> linkData =
            detectLinkInText(messageDecoderWithEmoji(yarnComment.comment)!);

        if (linkData["hasLink"]) {
          isUrlPresent = true;

          linkToBePreview = linkData['links'][0];
          if (!linkToBePreview!.contains("http")) {
            // debugPrint('Link to view question::: ${linkData.toString()}');

            linkToBePreview = "http://${linkToBePreview!}";
          }
        }
        if (yarnComment.attachment != null) {
          isAttachmentPresent = true;
        }

        if (yarnComment.media.isNotEmpty) {
          isMediaPresent = true;
        }
      }

      isNewModel = true;
      if (mounted) setState(() {});
      debugPrint("TRY:- $yarnQuestionForChatModel");
    } catch (error) {
      debugPrint("ERROR:- $error");

      debugPrint("CATCH:- $yarnComment");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    final bool isSend = widget.message!["author"] == userBloc.user.userName;

    return GestureDetector(
      onTap: () async {
        isLoading = true;
        if (mounted) setState(() {});

        // debugPrint('Comment in chat::::: ${widget.message!['meta_data']}');

        final Map body = json.decode(widget.message!['meta_data']);
        Yarn? yarnTopic;

        final Map<String, dynamic>? result =
            await YarnAuth().getSingleTopics(yarnId: body['related_object_id']);

        if (result == null) {
          isLoading = false;
          showToast(message: 'Yarn/comment no longer available');
          if (mounted) {
            setState(() {});
          }
          return;
        }

        yarnTopic = result['results'];
        isLoading = false;
        if (mounted) setState(() {});

        if (body['comment_type'] == 'yarn') {
          if (yarnTopic != null) {
            NavigationUtil.push(
              context,
              screen: YarnDetailScreen(
                yarn: yarnTopic,
              ),
            );
          }
        } else {
          final YarnComment yarnComment = YarnComment.fromJson(body);
          if (yarnTopic != null) {
            NavigationUtil.push(
              context,
              screen: YarnCommentDetailScreen(
                yarn: yarnTopic,
                yarnComment: yarnComment,
              ),
            );
          }
        }
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isSend) Container() else Container(width: 20),
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
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
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
                    if (widget.chatConversation!.isGroupConversation!)
                      widget.message!['author'] != userBloc.user.userName
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
                                const SizedBox(
                                  height: 4,
                                ),
                              ],
                            )
                          : const SizedBox(
                              height: 0,
                              width: 0,
                            )
                    else
                      const SizedBox(
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
                        padding: const EdgeInsets.only(
                            right: 10, top: 10, left: 10, bottom: 4),
                        child: _buildMainCard(),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSend)
                SizedBox(
                  width: 20,
                  child: isSend
                      ? Center(
                          child: getMessageTick(message: widget.message!),
                        )
                      : Container(),
                )
              else
                Container(),
            ],
          ),
          const SizedBox(
            height: 2,
          ),
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (isSend)
                Container()
              else
                const SizedBox(
                  width: 20,
                ),
              Text(
                formatTime(widget.message!['created_at']),
                style: TextStyle(
                    color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
              ),
              if (isSend)
                const SizedBox(
                  width: 20,
                )
              else
                Container(),
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
        const SizedBox(
          height: 10,
        ),
        _buildPostDescription(),
        const SizedBox(
          height: 10,
        ),
        if (yarnQuestionForChatModel.media != null) ...[
          _buildImagesRow(context: context),
          const SizedBox(
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
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: yarnQuestionForChatModel.authorAvatar!,
                  fit: BoxFit.cover,
                  errorWidget: imageErrorWidget,
                ),
              ),
            ),
            const SizedBox(
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

  Widget _buildPostDescription() {
    var removedLink = '';

    removedLink = removeLinksAndWords(
        yarnComment.comment != null ? yarnComment.comment! : '', []);

    if (isUrlPresent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          YarnSmartText(
            text: messageDecoderWithEmoji(removedLink)!,
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

    return YarnSmartText(
      text: messageDecoderWithEmoji(removedLink)!,
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
    return const SizedBox();
  }

  Widget _buildSingleImage({required BuildContext context}) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: yarnQuestionForChatModel.media!.first.file!,
          fit: BoxFit.cover,
          errorWidget: imageErrorWidget,
        ),
      ),
    );
  }

  Widget _buildTwoImageRow({required BuildContext context}) {
    return SizedBox(
      height: 175,
      child: Row(
        children: yarnQuestionForChatModel.media!
            .map(
              (mediaFile) => Expanded(
                child: Container(
                  height: (MediaQuery.of(context).size.width - 40) / 2,
                  width: (MediaQuery.of(context).size.width - 40) / 2,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
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
    return SizedBox(
      height: 175,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: (MediaQuery.of(context).size.width - 40) / 2,
              width: (MediaQuery.of(context).size.width - 40) / 2,
              padding: const EdgeInsets.symmetric(horizontal: 5),
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
              padding: const EdgeInsets.symmetric(horizontal: 5),
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
              padding: const EdgeInsets.symmetric(horizontal: 5),
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: (MediaQuery.of(context).size.width - 40) / 2,
                width: (MediaQuery.of(context).size.width - 40) / 2,
                padding: const EdgeInsets.symmetric(horizontal: 5),
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
                padding: const EdgeInsets.symmetric(horizontal: 5),
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
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: (MediaQuery.of(context).size.width - 40) / 2,
                width: (MediaQuery.of(context).size.width - 40) / 2,
                padding: const EdgeInsets.symmetric(horizontal: 5),
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
                padding: const EdgeInsets.symmetric(horizontal: 5),
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
    );
  }

  Widget _buildMain() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRowNew(),
        const SizedBox(
          height: 10,
        ),
        // if (yarnComment.isQuestion) ...[
        //   _buildPostTitleNew(),
        //   SizedBox(height: 8),
        // ],
        _buildPostDescriptionNew(),
        const SizedBox(
          height: 10,
        ),

        if (isAttachmentPresent &&
            yarnComment.attachment != null &&
            yarnComment.attachment?.isEmpty != true) ...[
          getDisplayWidget(_buildAttachment),
          const SizedBox(
            height: 8,
          ),
        ],
        if (isMediaPresent) ...[
          _buildImagesRowNew(),
          const SizedBox(
            height: 8,
          ),
        ],
        // yarnComment.factChecked == true ? _buildFactCheckWidget() : SizedBox.shrink(),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildUserInfoRowNew() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 4,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserAvatar(),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.USER_PROFILE, arguments: {
                    "searchedUserName": yarnComment.authorUsername
                  });
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
                            messageDecoderWithEmoji(
                                    yarnComment.authorName ?? "") ??
                                "",
                            style: TextStyle(fontSize: 12, color: yarnBlack),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          yarnComment.createdAt != null
                              ? getGetYarnQuestionDateTime(
                                  yarnComment.createdAt!)
                              : "",
                          overflow: TextOverflow.fade,
                          style: TextStyle(fontSize: 12, color: yarnBlack),
                        ),
                      ],
                    ),
                    Text(
                      "@${yarnComment.authorUsername!}",
                      style: TextStyle(
                        color: yarnBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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
            arguments: yarnComment.authorAvatar!);
      },
      child: Container(
        height: 36,
        width: 36,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: yarnComment.authorAvatar!,
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
          ),
        ),
      ),
    );
  }

  Widget _buildPostDescriptionNew() {
    var newString = '';
    final list = [];

    yarnComment.comment.toString().split(' ').forEach((ch) {
      list.add(ch);
      // debugPrint(ch);
    });

    for (var data in list) {
      if (data.toString().contains('.') &&
          !data.toString().trim().contains('@') &&
          !data.toString().trim().contains('..') &&
          !data.toString().trim().startsWith('.') &&
          !data.toString().trim().startsWith('http') &&
          !data.toString().trim().contains('.\n') &&
          !data.toString().trim().endsWith('.')) {
        final replaceWith = 'http://$data';

        newString = '$newString $replaceWith';
      } else {
        newString = '$newString $data';
      }
    }

    if (isUrlPresent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          YarnSmartText(
            text: messageDecoderWithEmoji(newString)!,
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

    return YarnSmartText(
      text: messageDecoderWithEmoji(newString)!,
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
    if (yarnComment.attachmentType == 'service') {
      final Service service = Service.fromJson(yarnComment.attachment);
      childWidget = YarnServiceTile(
        service: service,
      );
    } else if (yarnComment.attachmentType == 'product') {
      final Product product = Product.fromJson(yarnComment.attachment);
      childWidget = YarnProductTile(
        product: product,
      );
    } else if (yarnComment.attachmentType == 'blog') {
      final UserPost post = UserPost.fromJson(yarnComment.attachment);
      childWidget = YarnBlogPostTile(
        post: post,
        showAuthorDetails: true,
        onDeleteBlog: () {},
      );
    } else if (yarnComment.attachmentType == 'profile') {
      final CustomerProfile customerProfile =
          CustomerProfile.fromJson(yarnComment.attachment ?? {});
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

  Widget getDisplayWidget(Function() widgetDisplay) {
    return widgetDisplay();
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

  Widget _buildImagesRowNew() {
    return YarnCommentMediaRender(
      yarnTopic: yarnComment,
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
