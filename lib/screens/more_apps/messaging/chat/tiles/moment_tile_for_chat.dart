import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/moments/screens/moment_detail/moment_detail_page.dart';
import 'package:Slydo/screens/moments/screens/moments_service.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/util.dart';

class MomentTileForChat extends StatefulWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  MomentTileForChat(
      {Key? key, required this.message, required this.chatConversation})
      : super(key: key);

  @override
  State<MomentTileForChat> createState() => _MomentTileForChatState();
}

class _MomentTileForChatState extends State<MomentTileForChat> {
  late UserBloc userBloc;
  late MomentForChatModel momentForChatModel;
  // VideoPlayerController? _mainVideoController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    momentForChatModel =
        MomentForChatModel.fromJson(jsonDecode(widget.message!['meta_data']));

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

        await MomentsService()
            .getSingleMoment(momentId: momentForChatModel.id!)
            .then((momentsModelList) {
          isLoading = false;
          if (mounted) setState(() {});

          NavigationUtil.push(
            context,
            screen: MomentsDetailsScreen(
              indexOfMoment: 0,
              momentsModelList: [momentsModelList],
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
                  maxWidth: MediaQuery.of(context).size.width / 1.75,
                  minWidth: MediaQuery.of(context).size.width / 1.75,
                  maxHeight: 400,
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
                                  const SizedBox(
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
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          decoration: decorateBox(color: Colors.black),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      // child: momentForChatModel.video != null
                                      //     ? _buildVideoPlayer()
                                      //     : _buildImage(),
                                      child: _buildImage(),
                                    ),
                                    if (isLoading)
                                      const Align(
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator(),
                                      ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  height: 30,
                                                  width: 30,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    child: CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      errorWidget:
                                                          imageErrorWidget,
                                                      imageUrl: momentForChatModel
                                                              .authorAvatar ??
                                                          "",
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    messageDecoderWithEmoji(
                                                            momentForChatModel
                                                                .authorUsername) ??
                                                        "",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: white,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    maxLines: 2,
                                                    softWrap: true,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              messageDecoderWithEmoji(
                                                      momentForChatModel
                                                          .title) ??
                                                  "",
                                              style: TextStyle(
                                                  fontSize: 14, color: white),
                                              maxLines: 2,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
          const SizedBox(
            height: 2,
          ),
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              isSend
                  ? Container()
                  : const SizedBox(
                      width: 20,
                    ),
              Text(
                formatTime(widget.message!['created_at']),
                style: TextStyle(
                    color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
              ),
              isSend
                  ? const SizedBox(
                      width: 20,
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildVideoPlayer() {
  //   return VideoPlayer(
  //     _mainVideoController!,
  //     key: ValueKey("${momentForChatModel.id} ${momentForChatModel.video}"),
  //   );
  // }

  Widget _buildImage() {
    return CachedNetworkImage(
      width: double.infinity,
      fit: BoxFit.fill,
      errorWidget: imageErrorWidgetForMomentTile,
      imageUrl: momentForChatModel.image ?? "",
    );
  }
}

class MomentForChatModel {
  String? id;
  String? title;
  String? image;
  String? video;
  String? authorAvatar;
  String? authorUsername;

  MomentForChatModel({
    required this.id,
    required this.title,
    required this.image,
    required this.video,
    required this.authorAvatar,
    required this.authorUsername,
  });

  factory MomentForChatModel.fromJson(Map<String, dynamic> json) {
    return MomentForChatModel(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      video: json['video'],
      authorAvatar: json['author_avatar'],
      authorUsername: json['author_username'],
    );
  }
}
