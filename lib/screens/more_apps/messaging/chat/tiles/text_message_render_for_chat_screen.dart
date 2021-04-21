import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
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
        Center(
          child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.width / 2.5),
            child: CachedNetworkImage(
              imageUrl: webInfo.image,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width * 0.2,
            maxHeight: MediaQuery.of(context).size.width / 2.2,
          ),
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: getRepliedMessageUI(
              messageData: repliedTo,
              isSend: isSend,
              isRepliedSend: isRepliedSend),
        ),
        SizedBox(
          height: 2,
        ),
        Text(
          messageDecoderWithEmoji(newMessage['text'].toString()),
          style:
              TextStyle(color: isSend ? Colors.white : blackFont, fontSize: 16),
        ),
      ],
    );
  }

  Widget getRepliedMessageUI(
      {Map<String, dynamic> messageData, bool isSend, bool isRepliedSend}) {
    String messageType = messageData["kind"];
    switch (messageType) {
      case "text":
        Widget getMessageUi = renderReplyMessage(
            message: messageData, isSend: isSend, isRepliedSend: isRepliedSend);
        return getMessageUi;
        break;

      case "image":
        Widget getMessageUi = renderImageMedia(
            message: messageData, isSend: isSend, isRepliedSend: isRepliedSend);
        return getMessageUi;
        break;

      case "video":
        Widget getMessageUi = renderVideoMedia(
            message: messageData, isSend: isSend, isRepliedSend: isRepliedSend);
        return getMessageUi;
        break;

      case "audio":
        Widget getMessageUi = renderAudioMedia(
            message: messageData, isSend: isSend, isRepliedSend: isRepliedSend);
        return getMessageUi;
        break;

      case "transaction":
        Widget getPaymentUI = renderSendPayment(
            message: messageData, isSend: isSend, isRepliedSend: isRepliedSend);
        return getPaymentUI;

        break;
      case "payment-request":
        Widget getPaymentUI = renderPaymentRequest(
            message: messageData, isSend: isSend, isRepliedSend: isRepliedSend);
        return getPaymentUI;
        break;

      case "product":
        Widget getProductUI = renderProduct(
            message: messageData, isSend: isSend, isRepliedSend: isRepliedSend);
        return getProductUI;
        break;

      case "service":
        Widget getServiceUI = renderService(
            message: messageData, isSend: isSend, isRepliedSend: isRepliedSend);
        return getServiceUI;
        break;
      case "user-profile":
        Widget getUserProfileUI = renderUserProfile(
            message: messageData, isSend: isSend, isRepliedSend: isRepliedSend);
        return getUserProfileUI;

      case "user_location":
        Widget getUserLocationUI = renderUserLocation(
            message: messageData, isSend: isSend, isRepliedSend: isRepliedSend);
        return getUserLocationUI;
        break;

      case "gif_image":
        Widget getGIFImageUI = renderGIFImage(
            message: messageData, isSend: isSend, isRepliedSend: isRepliedSend);
        return getGIFImageUI;
        break;

      default:
        debugPrint(
            "Unknown Message Kind 4: $messageType Message:- $messageData");
        Widget getErrorRenderTypeUI = unKnownMessageType();
        return getErrorRenderTypeUI;
    }
  }

  Widget renderReplyMessage(
      {Map<String, dynamic> message, bool isSend, bool isRepliedSend}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              width: 2.0,
              color: getTitleAndDividerColor(
                  isSend: isSend, isRepliedSend: isRepliedSend)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getAuthorName(message: message, currentUser: userBloc.user),
            style: TextStyle(
                color: getTitleAndDividerColor(
                    isSend: isSend, isRepliedSend: isRepliedSend),
                fontSize: 14,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            message["text"],
            style: TextStyle(
                color: getDescriptionColor(
                    isSend: isSend, isRepliedSend: isRepliedSend),
                fontSize: 12,
                fontWeight: FontWeight.w400),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget renderImageMedia(
      {Map<String, dynamic> message, bool isSend, bool isRepliedSend}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              width: 2.0,
              color: getDividerColor(
                  isSend: isSend, isRepliedSend: isRepliedSend)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: CachedNetworkImage(
          width: double.infinity,
          fit: BoxFit.cover,
          imageUrl: message["media"],
        ),
      ),
    );
  }

  Widget renderVideoMedia(
      {Map<String, dynamic> message, bool isSend, bool isRepliedSend}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              width: 2.0,
              color: getDividerColor(
                  isSend: isSend, isRepliedSend: isRepliedSend)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          children: [
            CachedNetworkImage(
              width: double.infinity,
              fit: BoxFit.cover,
              imageUrl: message["poster"],
            ),
            Center(
              child: ClipOval(
                child: Container(
                  height: 60,
                  width: 60,
                  color: Colors.white12,
                  child: Icon(
                    SlydoAppIcon.music_play_1,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget renderAudioMedia(
      {Map<String, dynamic> message, bool isSend, bool isRepliedSend}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              width: 2.0,
              color: getTitleAndDividerColor(
                  isSend: isSend, isRepliedSend: isRepliedSend)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getAuthorName(message: message, currentUser: userBloc.user),
            style: TextStyle(
                color: getTitleAndDividerColor(
                    isSend: isSend, isRepliedSend: isRepliedSend),
                fontSize: 14,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            "Voice message",
            style: TextStyle(
                color: getDescriptionColor(
                    isSend: isSend, isRepliedSend: isRepliedSend),
                fontSize: 12,
                fontWeight: FontWeight.w400),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget renderSendPayment(
      {Map<String, dynamic> message, bool isSend, bool isRepliedSend}) {
    Map<String, dynamic> transaction;

    if (message['text'] is String) {
      transaction = jsonDecode(message['text']);
    } else if (message['text'] is Map) {
      transaction = message['text'];
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              width: 2.0,
              color: getDividerColor(
                  isSend: isSend, isRepliedSend: isRepliedSend)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            transaction["description"] == ""
                ? getAuthorName(message: message, currentUser: userBloc.user)
                : transaction["description"] ??
                    getAuthorName(message: message, currentUser: userBloc.user),
            style: TextStyle(
                color: getDividerColor(
                    isSend: isSend, isRepliedSend: isRepliedSend),
                fontSize: 14,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            children: [
              Text(
                "₦ ",
                style: TextStyle(
                    fontFamily: "Roberto",
                    color: getDescriptionColor(
                        isSend: isSend, isRepliedSend: isRepliedSend),
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                moneyDisplayNormalizer(
                    int.parse(transaction['amount'].toString())),
                style: TextStyle(
                    color: getDescriptionColor(
                        isSend: isSend, isRepliedSend: isRepliedSend),
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget renderPaymentRequest(
      {Map<String, dynamic> message, bool isSend, bool isRepliedSend}) {
    Map<String, dynamic> paymentRequest;

    if (message['text'] is String) {
      paymentRequest = jsonDecode(message['text']);
    } else if (message['text'] is Map) {
      paymentRequest = message['text'];
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              width: 2.0,
              color: getDividerColor(
                  isSend: isSend, isRepliedSend: isRepliedSend)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            paymentRequest["description"] == ""
                ? getAuthorName(message: message, currentUser: userBloc.user)
                : paymentRequest["description"] ??
                    getAuthorName(message: message, currentUser: userBloc.user),
            style: TextStyle(
                color: getDividerColor(
                    isSend: isSend, isRepliedSend: isRepliedSend),
                fontSize: 14,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            children: [
              Text(
                "₦ ",
                style: TextStyle(
                    fontFamily: "Roberto",
                    color: getDescriptionColor(
                        isSend: isSend, isRepliedSend: isRepliedSend),
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                moneyDisplayNormalizer(
                    double.parse(paymentRequest['amount'].toString()).toInt()),
                style: TextStyle(
                    color: getDescriptionColor(
                        isSend: isSend, isRepliedSend: isRepliedSend),
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget renderProduct(
      {Map<String, dynamic> message, bool isSend, bool isRepliedSend}) {
    Product product;
    if (message["meta_data"] is String) {
      product = Product.fromJson(jsonDecode(message["meta_data"]));
    } else if (message["meta_data"] is Map) {
      product = Product.fromJson(message["meta_data"]);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              width: 2.0,
              color: getDividerColor(
                  isSend: isSend, isRepliedSend: isRepliedSend)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: CachedNetworkImage(
              height: 48,
              width: 48,
              fit: BoxFit.cover,
              imageUrl: product.cover,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                      color: getDividerColor(
                          isSend: isSend, isRepliedSend: isRepliedSend),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Text(
                      "₦ ",
                      style: TextStyle(
                          fontFamily: "Roberto",
                          color: getDescriptionColor(
                              isSend: isSend, isRepliedSend: isRepliedSend),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      moneyDisplayNormalizer(
                          int.parse(product.price.toString())),
                      style: TextStyle(
                          color: getDescriptionColor(
                              isSend: isSend, isRepliedSend: isRepliedSend),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget renderService(
      {Map<String, dynamic> message, bool isSend, bool isRepliedSend}) {
    Service service;
    if (message["meta_data"] is String) {
      service = Service.fromJson(jsonDecode(message["meta_data"]));
    } else if (message["meta_data"] is Map) {
      service = Service.fromJson(message["meta_data"]);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              width: 2.0,
              color: getDividerColor(
                  isSend: isSend, isRepliedSend: isRepliedSend)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: CachedNetworkImage(
              height: 48,
              width: 48,
              fit: BoxFit.cover,
              imageUrl: service.cover,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  service.name,
                  style: TextStyle(
                      color: getDividerColor(
                          isSend: isSend, isRepliedSend: isRepliedSend),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Text(
                      "₦ ",
                      style: TextStyle(
                          fontFamily: "Roberto",
                          color: getDescriptionColor(
                              isSend: isSend, isRepliedSend: isRepliedSend),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      moneyDisplayNormalizer(
                          int.parse(service.price.toString())),
                      style: TextStyle(
                          color: getDescriptionColor(
                              isSend: isSend, isRepliedSend: isRepliedSend),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget renderUserProfile(
      {Map<String, dynamic> message, bool isSend, bool isRepliedSend}) {
    CustomerProfile customerProfile;

    if (message['meta_data'] is String) {
      customerProfile =
          CustomerProfile.fromJson(jsonDecode(message['meta_data']));
    } else if (message['meta_data'] is Map) {
      customerProfile = CustomerProfile.fromJson(message['meta_data']);
    }

    Color borderColor = getUserTypeColor(user: customerProfile);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              width: 2.0,
              color: getDividerColor(
                  isSend: isSend, isRepliedSend: isRepliedSend)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    25,
                  ),
                  border: Border.all(color: borderColor, width: 2)),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: customerProfile.avatar == ""
                      ? "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                      : customerProfile.avatar,
                  colorBlendMode: BlendMode.darken,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                  errorWidget: imageErrorWidget,
                ),
              )),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  customerProfile.fullName ?? "",
                  style: TextStyle(
                      color: getDividerColor(
                          isSend: isSend, isRepliedSend: isRepliedSend),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  customerProfile.userName ?? "",
                  style: TextStyle(
                      color: getDescriptionColor(
                          isSend: isSend, isRepliedSend: isRepliedSend),
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget renderUserLocation(
      {Map<String, dynamic> message, bool isSend, bool isRepliedSend}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              width: 2.0,
              color: getTitleAndDividerColor(
                  isSend: isSend, isRepliedSend: isRepliedSend)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: CachedNetworkImage(
              height: 48,
              width: 48,
              fit: BoxFit.cover,
              imageUrl: "https://i.dlpng.com/static/png/6635948_preview.png",
              color: navyBlue,
              colorBlendMode: BlendMode.color,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getAuthorName(message: message, currentUser: userBloc.user),
                  style: TextStyle(
                      color: getTitleAndDividerColor(
                          isSend: isSend, isRepliedSend: isRepliedSend),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Location",
                  style: TextStyle(
                      color: getDescriptionColor(
                          isSend: isSend, isRepliedSend: isRepliedSend),
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget renderGIFImage(
      {Map<String, dynamic> message, bool isSend, bool isRepliedSend}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              width: 2.0,
              color: getTitleAndDividerColor(
                  isSend: isSend, isRepliedSend: isRepliedSend)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: CachedNetworkImage(
              height: 48,
              width: 48,
              fit: BoxFit.cover,
              imageUrl: message["text"],
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getAuthorName(message: message, currentUser: userBloc.user),
                  style: TextStyle(
                      color: getTitleAndDividerColor(
                          isSend: isSend, isRepliedSend: isRepliedSend),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "GIF",
                  style: TextStyle(
                      color: getDescriptionColor(
                          isSend: isSend, isRepliedSend: isRepliedSend),
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget unKnownMessageType() {
    return Container();
  }

  Color getTitleAndDividerColor({bool isSend, bool isRepliedSend}) {
    if (isSend) {
      if (isRepliedSend) {
        return naturalGreen;
      } else {
        return Colors.white;
      }
    } else {
      if (isRepliedSend) {
        return naturalGreen;
      } else {
        return blackFont;
      }
    }
  }

  Color getDividerColor({bool isSend, bool isRepliedSend}) {
    if (isSend) {
      return Colors.white;
    } else {
      return blackFont;
    }
  }

  Color getDescriptionColor({bool isSend, bool isRepliedSend}) {
    if (isSend) {
      return Colors.white;
    } else {
      return blackFont;
    }
  }
}
