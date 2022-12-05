import 'dart:convert';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/ask/ask_auth.dart';
import 'package:Slydo/screens/more_apps/ask/ask_detail_screen.dart';
import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/navigation_util.dart';
import '../../../../../utils/util.dart';

class YarnQuestionTileForChat extends StatefulWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  YarnQuestionTileForChat(
      {Key? key, required this.message, required this.chatConversation})
      : super(key: key);

  @override
  State<YarnQuestionTileForChat> createState() => _YarnQuestionTileForChatState();
}

class _YarnQuestionTileForChatState extends State<YarnQuestionTileForChat> {
  late UserBloc userBloc;
  late YarnQuestionForChatModel yarnQuestionForChatModel;
  // VideoPlayerController? _mainVideoController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    yarnQuestionForChatModel =
        YarnQuestionForChatModel.fromJson(jsonDecode(widget.message!['meta_data']));

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

        await AskAuth()
            .getSingleTopics(yarnId: yarnQuestionForChatModel.id!)
            .then((data) {
              YarnTopic? yarnTopic;
              if(data != null) {
                yarnTopic = data['results'];
              }
          isLoading = false;
          if (mounted) setState(() {});

          NavigationUtil.push(
            context,
            screen: AskDetailScreen(
              yarnTopic: yarnTopic,
            ),
          );
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
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
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
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        decoration: decorateBox(color: Colors.white),
                        padding: EdgeInsets.only(right: 10, top: 10, left: 10, bottom: 4),
                        child: _buildPostCard(),
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

  Widget _buildPostCard() {
    if (yarnQuestionForChatModel.media != null) {
      return _buildWithImagesPostCard();
    }
    return _buildWithOutImagesPostCard();
  }

  Widget _buildWithImagesPostCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(),
        SizedBox(
          height: 10,
        ),
        if (yarnQuestionForChatModel.isQuestion ?? false)...[
          _buildPostTitle(),
          SizedBox(
            height: 10,
          ),
        ],
        _buildPostDescription(),
        SizedBox(
          height: 10,
        ),
        _buildImagesRow(context: context),
        SizedBox(height: 6,),
      ],
    );
  }

  Widget _buildWithOutImagesPostCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(),
        SizedBox(
          height: 10,
        ),
        if (yarnQuestionForChatModel.isQuestion ?? false) ...[
          _buildPostTitle(),
          SizedBox(height: 10),
        ],
        _buildPostDescription(),
        SizedBox(
          height: 10,
        ),
        _buildTagsAndViewerRow(),
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
                          name: yarnQuestionForChatModel.authorName ?? "", isVerified: yarnQuestionForChatModel.authorIsVerified ?? false),
                      Text(
                        "@${yarnQuestionForChatModel.authorUsername ?? ''}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 10,
                            color: HexColor("#3F61DB")
                        ),
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
    return Text(
      yarnQuestionForChatModel.description ?? "",
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: blackFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildTagsAndViewerRow() {
    return Wrap(
      runSpacing: 5,
      spacing: 2,
      children: yarnQuestionForChatModel.tags != null ? yarnQuestionForChatModel.tags!
          .map((e) => Text(
        "#$e",
        style: TextStyle(
          fontSize: 12,
          color: HexColor("#3F61DB"),
        ),
      ))
          .toList() : [],
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
            .map((mediaFile) => Expanded(
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
        ),)
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
          SizedBox(height: 8,),
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
      media: json['image'] != null ? (json['image'] as List<dynamic>).map((e) => MediaFile.fromJson(e as Map<String, dynamic>)).toList() : [],
      isQuestion: json['is_question'],
      authorIsVerified: json['author_is_verified']
    );
  }
}

class MediaFile {
  String? file;
  MediaFile({
    this.file,});

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      file: json['file']
    );
  }
}
