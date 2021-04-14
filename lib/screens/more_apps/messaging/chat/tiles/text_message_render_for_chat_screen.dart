import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:linkwell/linkwell.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TextMessageRendererForChat extends StatefulWidget {
  Map<String, dynamic> message;
  TextMessageRendererForChat({this.message});

  @override
  _TextMessageRendererForChatState createState() =>
      _TextMessageRendererForChatState();
}

class _TextMessageRendererForChatState
    extends State<TextMessageRendererForChat> {
  UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    Map<String, dynamic> message = widget.message;

    bool isSend = message["author"] == userBloc.user.userName;

    bool isEdited = message["was_edited"] ?? false;
    // bool isEdited = true;

    bool isReplyMessage = false;

    Widget renderedMessage = renderMessage(message: message, isSend: isSend);

    Map<String, dynamic> isReplyTo = message["replied_to"] is String
        ? jsonDecode(message["replied_to"])
        : message["replied_to"] ?? {};

    if (isReplyTo.isNotEmpty) {
      isReplyMessage = true;
    }

    return Row(
      mainAxisAlignment:
          isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment:
              isSend ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                isSend
                    ? Container()
                    : Container(
                        width: 20,
                      ),
                Row(
                  children: [
                    isSend
                        ? isEdited
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: navyBlue,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  )
                                ],
                              )
                            : Container()
                        : Container(),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: isReplyMessage ? 8 : 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSend ? navyBlue : chatBackgroundColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(!isSend ? 0 : 10),
                          bottomRight: Radius.circular(isSend ? 0 : 10),
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: renderedMessage,
                          ),
                        ],
                      ),
                    ),
                    isSend
                        ? Container()
                        : isEdited
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: darkGrey,
                                  ),
                                ],
                              )
                            : Container(),
                  ],
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
              children: [
                isSend
                    ? Container()
                    : SizedBox(
                        width: 20,
                      ),
                Text(
                  formatTime(message['created_at']),
                  style: TextStyle(
                      color: darkGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w500),
                ),
                isSend
                    ? SizedBox(
                        width: 20,
                      )
                    : Container(),
              ],
            )
          ],
        )
      ],
    );
  }

  Map<String, dynamic> detectLinkInMessages(String text) {
    RegExp exp =
        new RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> matches = exp.allMatches(text);

    List<String> listOfLinks = [];

    matches.forEach((match) {
      listOfLinks.add(text.substring(match.start, match.end));
    });

    Map<String, dynamic> linkData = {"hasLink": false, "links": listOfLinks};

    if (listOfLinks.isEmpty) {
      return linkData;
    } else {
      linkData["hasLink"] = true;
      return linkData;
    }
  }

  Widget renderMessage({Map<String, dynamic> message, bool isSend}) {
    /// check if message is reply message then render reply UI of message
    /// {id: 58fb1dce-d430-4074-9b4c-6f06e856dd15, check_id: f42e6f87-891a-415a-ab57-0fcfd83fe1f1, conversation: {id: 9ae68069-b342-4e04-b568-602bde6fe901, group_name: null, banner: null, participants: [black, brijesh.sakariya], blocked_participants: null, is_group_conversation: false, updated_at: 2021-03-09T08:14:18.467461+01:00, created_at: 2021-03-09T08:14:18.467517+01:00}, author: black, text: teset123, read_by_author: true, read_by_recipient: false, was_edited: false, media: null, poster: null, updated_at: 2021-04-13T09:21:24.922145+01:00, created_at: 2021-04-13T09:21:24.922169+01:00, kind: text, deleted_for_recipient: false, deleted_for_author: false, delivered: true, meta_data: {}, replied_to: {id: 736ab0e9-1c57-4452-98b4-13664a262b81, check_id: 5da0bcd7-831d-4d02-97bd-dd9e1f78ebef, author: black, text: test, media: null, poster: null, kind: text, read_by_author: true, read_by_recipient: false, deleted_for_recipient: false, deleted_for_author: false, delivered: true, was_edited

    Map<String, dynamic> isReplyTo = message["replied_to"] is String
        ? jsonDecode(message["replied_to"])
        : message["replied_to"] ?? {};

    if (isReplyTo.isNotEmpty) {
      return getReplyMessageUI(
          newMessage: message, isSend: isSend, repliedTo: isReplyTo);
    }

    Map<String, dynamic> linkData = detectLinkInMessages(
        messageDecoderWithEmoji(message['text'].toString()));

    if (linkData["hasLink"]) {
      String linkToBePreview = linkData['links'][0];

      if (!linkToBePreview.contains("http")) {
        linkToBePreview = "http://" + linkToBePreview;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlutterLinkPreview(
            key: ValueKey("${linkToBePreview}233"),
            url: linkToBePreview,
            builder: (info) {
              if (info == null)
                return const SizedBox(
                  height: 0,
                  width: 0,
                );
              if (info is WebImageInfo) {
                return CachedNetworkImage(
                  imageUrl: info.image,
                  fit: BoxFit.contain,
                );
              }

              final WebInfo webInfo = info;
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: getPreview(webInfo)),
              );
            },
          ),
          LinkWell(
            messageDecoderWithEmoji(message['text'].toString()),
            style: TextStyle(
                color: isSend ? Colors.white : blackFont,
                fontSize: 17,
                fontFamily: "OpenSans"),
            textScaleFactor: 0.8,
            linkStyle: TextStyle(
                color: isSend ? Colors.white : navyBlue,
                decoration: TextDecoration.underline,
                fontSize: 17,
                fontFamily: "OpenSans"),
          ),
        ],
      );
    }

    return getSimpleMessage(message: message, isSend: isSend);
  }

  List<Widget> getPreview(WebInfo webInfo) {
    List<Widget> children = [
      Center(
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: webInfo.icon ?? "",
              imageBuilder: (context, imageProvider) {
                return Image(
                  image: imageProvider,
                  fit: BoxFit.contain,
                  width: 30,
                  height: 30,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.link);
                  },
                );
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                webInfo.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ];

    if (WebAnalyzer.isNotEmpty(webInfo.description)) {
      children.addAll([
        const SizedBox(height: 4),
        Text(
          webInfo.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          // textAlign: TextAlign.justify,
          style: TextStyle(color: blackFont, fontSize: 14),
        ),
        const SizedBox(height: 8),
      ]);
    }

    if (WebAnalyzer.isNotEmpty(webInfo.image)) {
      children.addAll([
        const SizedBox(height: 8),
        CachedNetworkImage(
          imageUrl: webInfo.image,
          fit: BoxFit.contain,
        ),
      ]);
    }

    return children;
  }

  Widget getSimpleMessage({Map<String, dynamic> message, bool isSend}) {
    return Text(
      messageDecoderWithEmoji(message['text'].toString()),
      style: TextStyle(color: isSend ? Colors.white : blackFont, fontSize: 16),
    );
  }

  Widget getReplyMessageUI(
      {Map<String, dynamic> newMessage,
      bool isSend,
      Map<String, dynamic> repliedTo}) {
    bool isRepliedSend = repliedTo["author"] == userBloc.user.userName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width * 0.2,
          ),
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: naturalGreen,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isRepliedSend
                  ? "You"
                  : repliedTo["author_name"] ?? repliedTo["author"]),
              Text(
                messageDecoderWithEmoji(repliedTo['text'].toString()),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        Text(
          messageDecoderWithEmoji(newMessage['text'].toString()),
          style:
              TextStyle(color: isSend ? Colors.white : blackFont, fontSize: 16),
        ),
      ],
    );
  }
}
