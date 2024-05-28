import 'dart:typed_data';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../../routes/route_constants.dart';

class VideoTileForChat extends StatelessWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  VideoTileForChat({required this.message, this.chatConversation});

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);

    final bool isSend = message!["author"] == userBloc.user.userName;
    String? messageText = message!['text'] ?? "";
    final bool isMessageEmpty = messageText == "";
    messageText = messageDecoderWithEmoji(messageText);

    if (message!["media"] == null) {
      message!["media"] =
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isSend)
              Container()
            else
              Container(
                width: 20,
              ),
            GestureDetector(
              onTap: () {
                final result = Navigator.of(context).pushNamed(
                  Routes.VIEW_CHAT_MEDIA,
                  arguments: {
                    "type": "video",
                    "file": message!["media"],
                    "message": message!['text']
                  },
                );
                debugPrint("Result:- $result");
              },
              child: Container(
                constraints: BoxConstraints(
                  // maxWidth: MediaQuery.of(context).size.width / 1.30,
                  // minWidth: MediaQuery.of(context).size.width / 1.30,
                  maxWidth: MediaQuery.of(context).size.width / 1.8,
                  minWidth: MediaQuery.of(context).size.width / 1.8,
                ),
                decoration: BoxDecoration(
                  color: chatConversation!.isGroupConversation!
                      ? isSend
                          ? isMessageEmpty
                              ? Colors.transparent
                              : navyBlue
                          : Colors.white
                      : isMessageEmpty
                          ? Colors.transparent
                          : isSend
                              ? navyBlue
                              : Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: const Radius.circular(10),
                    topRight: const Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.only(
                    top: chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : isMessageEmpty
                            ? 0
                            : 8,
                    bottom: chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : isMessageEmpty
                            ? 0
                            : 8,
                    left: chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : 0,
                    right: chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isSend
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (chatConversation!.isGroupConversation!)
                      message!['author'] != userBloc.user.userName
                          ? Column(
                              children: [
                                Text(
                                  message!['author_full_name'] ??
                                      message!['author'],
                                  style: TextStyle(
                                      color: isSend ? Colors.white : navyBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: isMessageEmpty ? 4 : 2,
                                ),
                              ],
                            )
                          : Container(
                              width: 0,
                            )
                    else
                      Container(
                        width: 0,
                      ),
                    if (isMessageEmpty)
                      Container()
                    else
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                chatConversation!.isGroupConversation! ? 0 : 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  messageText!,
                                  style: TextStyle(
                                      color: isSend ? Colors.white : blackFont,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isMessageEmpty)
                      Container()
                    else
                      const SizedBox(
                        height: 8,
                      ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              height: MediaQuery.of(context).size.width / 3,
                              width: MediaQuery.of(context).size.width / 1.8,
                              // height: MediaQuery.of(context).size.width / 2.2,
                              // width: MediaQuery.of(context).size.width / 1.30,
                              imageUrl: message!["poster"] ??
                                  "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg",
                              fit: BoxFit.cover,
                              color: Colors.black38,
                              colorBlendMode: BlendMode.darken,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(
                                      isSend ? Colors.white : navyBlue),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              errorWidget: imageErrorWidget,
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.width / 3,
                            width: MediaQuery.of(context).size.width / 1.8,
                            // height: MediaQuery.of(context).size.width / 2.2,
                            // width: MediaQuery.of(context).size.width / 1.30,
                            child: Center(
                              child: ClipOval(
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  color: Colors.white.withOpacity(0.2),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isSend)
              Container(
                width: 20,
                child: isSend
                    ? Center(
                        child: getMessageTick(message: message!),
                      )
                    : Container(),
              )
            else
              Container(),
          ],
        ),
        const SizedBox(height: 1),
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
              formatTime(message!['created_at']),
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
        const SizedBox(height: 4),
      ],
    );
  }

  Future<Uint8List?> getVideoThumbnail(String url) async {
    final Uint8List? uInt8list = await VideoThumbnail.thumbnailData(
      video: url,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          512, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    return uInt8list;
  }
}
