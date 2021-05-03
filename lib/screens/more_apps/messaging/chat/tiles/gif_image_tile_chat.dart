import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GIFImageForChatMessage extends StatelessWidget {
  final Map<String, dynamic> message;
  final ChatConversation chatConversation;

  GIFImageForChatMessage({this.message, this.chatConversation});

  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = Provider.of<UserBloc>(context);

    bool isSend = message["author"] == userBloc.user.userName;

    String gifImage = message['text'];

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isSend
                ? Container()
                : Container(
                    width: 20,
                  ),
            GestureDetector(
              onTap: () async {
                await Navigator.of(context).pushNamed(
                  "/view-chat-media",
                  arguments: {
                    "type": "image",
                    "file": gifImage,
                    "message": "",
                    "poster": null
                  },
                );
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.30,
                ),
                decoration: BoxDecoration(
                  color: chatConversation.isGroupConversation
                      ? isSend
                          ? Colors.transparent
                          : chatBackgroundColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: chatConversation.isGroupConversation
                        ? isSend
                            ? 0
                            : 8
                        : 0,
                    vertical: chatConversation.isGroupConversation
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
                    chatConversation.isGroupConversation
                        ? message['author'] != userBloc.user.userName
                            ? Column(
                                children: [
                                  Text(
                                    message['author_full_name'] ??
                                        message['author'],
                                    style: TextStyle(
                                        color:
                                            isSend ? Colors.white : blackFont,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                ],
                              )
                            : Container(
                                width: 0,
                              )
                        : Container(
                            width: 0,
                          ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: ClipRRect(
                        child: CachedNetworkImage(
                          height: MediaQuery.of(context).size.width / 3,
                          width: MediaQuery.of(context).size.width / 1.8,
                          imageUrl: gifImage,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                              value: downloadProgress.progress,
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(navyBlue),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          errorWidget: imageErrorWidget,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isSend
                ? Container(
                    width: 20,
                    child: isSend
                        ? Center(
                            child: getMessageTick(message: message),
                          )
                        : Container(),
                  )
                : Container(),
          ],
        ),
        SizedBox(
          height: 1,
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
              formatTime(message['created_at']),
              style: TextStyle(
                  color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            isSend
                ? SizedBox(
                    width: 20,
                  )
                : Container(),
          ],
        )
      ],
    );
  }
}
