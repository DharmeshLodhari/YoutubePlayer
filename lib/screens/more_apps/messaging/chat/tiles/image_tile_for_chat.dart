import 'dart:ui' as ui;

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageTileForChat extends StatelessWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  ImageTileForChat({this.message, this.chatConversation});

  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = Provider.of<UserBloc>(context);

    bool isSend = message!["author"] == userBloc.user.userName;
    String? messageText = message!['text'] ?? "";
    bool isMessageEmpty = messageText == "";

    messageText = messageDecoderWithEmoji(messageText);

    debugPrint('IMAGE ==> ${message!['media']}');
    if (message!['media'] == null) {
      message!['media'] = defaultImage;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isSend ? Container() : Container(width: 20),

            GestureDetector(
              onTap: () async {
                await Navigator.of(context).pushNamed(
                  Routes.VIEW_CHAT_MEDIA,
                  arguments: {
                    "type": "image",
                    "file": message!['media'],
                    "message": message!['text'],
                    "poster": message!["poster"] ?? null
                  },
                );
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
                              ? navyBlue
                              : navyBlue
                          : Colors.white
                      : isSend
                          ? navyBlue
                          : Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.only(
                    top: chatConversation!.isGroupConversation!
                        ? isSend
                            ? 4
                            : 8
                        : isMessageEmpty
                            ? 4
                            : 8,
                    bottom: chatConversation!.isGroupConversation!
                        ? isSend
                            ? 4
                            : 8
                        : isMessageEmpty
                            ? 4
                            : 8,
                    left: chatConversation!.isGroupConversation!
                        ? isSend
                            ? 4
                            : 8
                        : isMessageEmpty
                            ? 4
                            : 0,
                    right: chatConversation!.isGroupConversation!
                        ? isSend
                            ? 4
                            : 8
                        : isMessageEmpty
                            ? 4
                            : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isSend
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    chatConversation!.isGroupConversation!
                        ? message!['author'] != userBloc.user.userName
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
                                    height: isMessageEmpty ? 4 : 0,
                                  ),
                                ],
                              )
                            : Container(width: 0)
                        : Container(width: 0),
                    isMessageEmpty
                        ? Container()
                        : Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    chatConversation!.isGroupConversation!
                                        ? 0
                                        : 8),
                            child: Text(
                              messageText!,
                              style: TextStyle(
                                  color: isSend ? Colors.white : blackFont,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                    isMessageEmpty ? Container() : SizedBox(height: 8),
                    Container(
                      height: 200,
                      padding: EdgeInsets.symmetric(
                          horizontal: chatConversation!.isGroupConversation!
                              ? 0
                              : isMessageEmpty
                                  ? 0
                                  : 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(isSend ? 10 : 0),
                          bottomRight: Radius.circular(isSend ? 0 : 10),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: message!['media'],
                          fit: BoxFit.cover,
                          imageBuilder: buildImage,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Container(
                            height: MediaQuery.of(context).size.width / 3,
                            width: MediaQuery.of(context).size.width / 1.8,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: downloadProgress.progress,
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation(
                                    isSend ? Colors.white : navyBlue),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),
                          errorWidget: imageErrorWidget,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //Message tick
            isSend
                ? Container(
                    width: 20,
                    child: isSend
                        ? Center(
                            child: getMessageTick(message: message!),
                          )
                        : Container(),
                  )
                : Container(),
          ],
        ),
        SizedBox(height: 1),
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
              formatTime(message!['created_at']),
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

  Widget buildImage(BuildContext context, ImageProvider imageProvider) {
    late ui.Image image;
    double width;
    double height;

    imageProvider.resolve(ImageConfiguration()).addListener(ImageStreamListener(
      (ImageInfo info, bool _) {
        image = info.image;
      },
    ));

    if (image.width > image.height) {
      height = MediaQuery.of(context).size.width / 3;
      width = MediaQuery.of(context).size.width / 1.8;
    } else {
      height = MediaQuery.of(context).size.width;
      width = MediaQuery.of(context).size.width / 1.8;
    }
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          image: DecorationImage(
        image: imageProvider,
        fit: BoxFit.cover,
      )),
    );
  }
}
