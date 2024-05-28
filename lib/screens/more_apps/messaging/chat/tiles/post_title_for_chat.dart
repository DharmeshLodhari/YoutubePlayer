import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/post_detail_page.dart';
import 'package:Slydo/utils/video_player_controller/chewie_player.dart';
import 'package:Slydo/utils/video_player_controller/chewie_progress_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../../utils/enums.dart';
import '../../../../../utils/util.dart';
import '../../../user_post/models/user_post.dart';
import '../../../yarn/yarn_dashboard_bloc.dart';

class PostTileForChat extends StatefulWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  PostTileForChat(
      {Key? key, required this.message, required this.chatConversation})
      : super(key: key);

  @override
  State<PostTileForChat> createState() => _PostTileForChatState();
}

class _PostTileForChatState extends State<PostTileForChat> {
  late UserPost? post;
  late UserBloc userBloc;
  late PostForChatModel postForChatModel;
  ChewieController? _chewieMainController;
  VideoPlayerController? _mainVideoController;
  late YarnDashboardBloc yarnDashboardBloc;

  @override
  void initState() {
    super.initState();

    postForChatModel =
        PostForChatModel.fromJson(jsonDecode(widget.message!['meta_data']));

    if (postForChatModel.video != null) {
      _mainVideoController = VideoPlayerController.network(
          postForChatModel.video!,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));

      _chewieMainController = ChewieController(
          videoPlayerController: _mainVideoController!,
          aspectRatio: 2.5,
          allowFullScreen: false,
          showControlsOnInitialize: false,
          materialProgressColors: ChewieProgressColors(
            backgroundColor: Colors.transparent,
            handleColor: Colors.transparent,
            bufferedColor: Colors.transparent,
            playedColor: Colors.transparent,
          ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mainVideoController?.dispose();

    _chewieMainController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);

    bool isSend = widget.message!["author"] == userBloc.user.userName;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return PostDetailPage(
                onDeleteBlog: () {},
                postType: PostType.blog,
                postId: postForChatModel.id!,
              );
            },
          ),
        );
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
                  maxWidth: MediaQuery.of(context).size.width / 1.50,
                  minWidth: MediaQuery.of(context).size.width / 1.50,
                  maxHeight: 300,
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
                    topLeft: const Radius.circular(10),
                    topRight: const Radius.circular(10),
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
                          : Container(
                              height: 0,
                              width: 0,
                            )
                    else
                      Container(
                        height: 0,
                        width: 0,
                      ),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        decoration: decorateBox(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: postForChatModel.video != null
                                  ? Chewie(
                                      posterUrl: postForChatModel.image,
                                      controller: _chewieMainController!,
                                    )
                                  : CachedNetworkImage(
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.fill,
                                      errorWidget: imageErrorWidget,
                                      imageUrl: postForChatModel.image ?? "",
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    messageDecoderWithEmoji(
                                            postForChatModel.title) ??
                                        "",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: blackFont),
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            errorWidget: imageErrorWidget,
                                            imageUrl:
                                                postForChatModel.authorAvatar ??
                                                    "",
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        messageDecoderWithEmoji(postForChatModel
                                                .authorUsername) ??
                                            "",
                                        style: TextStyle(
                                            fontSize: 14, color: blackFont),
                                        maxLines: 2,
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSend)
                Container(
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
}

class PostForChatModel {
  String? id;
  String? title;
  String? image;
  String? video;
  String? authorAvatar;
  String? authorUsername;

  PostForChatModel({
    required this.id,
    required this.title,
    required this.image,
    required this.video,
    required this.authorAvatar,
    required this.authorUsername,
  });

  factory PostForChatModel.fromJson(Map<String, dynamic> json) {
    return PostForChatModel(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      video: json['video'],
      authorAvatar: json['author_avatar'],
      authorUsername: json['author_username'],
    );
  }
}
