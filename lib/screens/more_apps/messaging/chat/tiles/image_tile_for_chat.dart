import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ImageTileForChat extends StatelessWidget {
  Map<String, dynamic> message;

  ImageTileForChat({this.message});

  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = Provider.of<UserBloc>(context);

    bool isSend = message["author"] == userBloc.user.userName;
    String messageText = message['text'] ?? "";
    bool isMessageEmpty = messageText == "";

    messageText = messageDecoderWithEmoji(messageText);

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
              onTap: () {
                var result = Navigator.of(context).pushNamed(
                  "/view-chat-media",
                  arguments: {
                    "type": "image",
                    "file": message['media'],
                    "message": message['text'],
                    "poster": message["poster"] ?? null
                  },
                );

                debugPrint("Result:- $result");
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.30,
                  minWidth: MediaQuery.of(context).size.width / 1.30,
                ),
                decoration: BoxDecoration(
                  color: isMessageEmpty
                      ? Colors.transparent
                      : isSend
                          ? navyBlue
                          : chatBackgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.only(
                    top: isMessageEmpty ? 0 : 8,
                    bottom: isMessageEmpty ? 0 : 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isMessageEmpty
                        ? Container()
                        : Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    messageText,
                                    style: TextStyle(
                                        color:
                                            isSend ? Colors.white : blackFont,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    isMessageEmpty
                        ? Container()
                        : SizedBox(
                            height: 8,
                          ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMessageEmpty ? 0 : 8),
                      child: ClipRRect(
                        child: CachedNetworkImage(
                          height: MediaQuery.of(context).size.width / 2.2,
                          width: MediaQuery.of(context).size.width / 1.30,
                          imageUrl: message['media'],
                          fit: BoxFit.cover,
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
