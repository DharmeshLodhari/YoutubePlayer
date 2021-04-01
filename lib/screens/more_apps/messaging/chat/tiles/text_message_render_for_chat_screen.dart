import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:linkwell/linkwell.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

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

    Widget renderedMessage = renderMessage(message: message, isSend: isSend);

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(new ClipboardData(
            text: messageDecoderWithEmoji(message['text'].toString())));
        Toast.show("Text copied !!", context,
            gravity: Toast.BOTTOM,
            duration: Toast.LENGTH_LONG,
            backgroundColor: Colors.black,
            textColor: Colors.white);
      },
      child: Row(
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
                  Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      )),
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
      ),
    );
  }

  Map<String, dynamic> detectLinkInMessages(String text) {
    RegExp exp =
        new RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> matches = exp.allMatches(text);

    List<String> listOfLinks = [];

    matches.forEach((match) {
      print("===> " + text.substring(match.start, match.end));
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
              debugPrint("==:? $info");
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
                  color: const Color(0xFFF0F1F2),
                ),
                padding: const EdgeInsets.all(10),
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
          textAlign: TextAlign.justify,
          style: TextStyle(color: blackFont, fontSize: 14),
        ),
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
    
    children.add(
        SizedBox(
          height: 8,
        ),);

    return children;
  }

  Widget getSimpleMessage({Map<String, dynamic> message, bool isSend}) {
    return Text(
      messageDecoderWithEmoji(message['text'].toString()),
      style: TextStyle(color: isSend ? Colors.white : blackFont, fontSize: 16),
    );
  }
}
