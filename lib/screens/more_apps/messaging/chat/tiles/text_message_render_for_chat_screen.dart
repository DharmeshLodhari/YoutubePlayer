import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/post_title_for_chat.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/Envelope.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/link_preview/flutter_link_preview.dart';
import 'package:Slydo/utils/link_preview/web_analyzer.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/flutter_gifimage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linkwell/linkwell.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../service_hub/models/jobs.dart';
import '../../../yarn/widgets/url_reader_of_yarn.dart';

// ignore: must_be_immutable
class TextMessageRendererForChat extends StatefulWidget {
  Map<String, dynamic>? message;
  ChatConversation? chatConversation;
  Function? onReplyMessageTap;
  TextMessageRendererForChat(
      {Key? key, this.message, this.chatConversation, this.onReplyMessageTap})
      : super(key: key);

  @override
  _TextMessageRendererForChatState createState() =>
      _TextMessageRendererForChatState();
}

class _TextMessageRendererForChatState extends State<TextMessageRendererForChat>
    with SingleTickerProviderStateMixin {
  late UserBloc userBloc;

  GifController? gifController;
  Function? onReplyMessageTap;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    onReplyMessageTap = widget.onReplyMessageTap;

    Map<String, dynamic> message = widget.message!;

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
                        color: isSend ? navyBlue : Colors.white,
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
                  formatTime(message["created_at"]),
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

  Widget renderMessage({required Map<String, dynamic> message, bool? isSend}) {
    /// check if message is reply message then render reply UI of message
    /// {id: 58fb1dce-d430-4074-9b4c-6f06e856dd15, check_id: f42e6f87-891a-415a-ab57-0fcfd83fe1f1, conversation: {id: 9ae68069-b342-4e04-b568-602bde6fe901, group_name: null, banner: null, participants: [black, brijesh.sakariya], blocked_participants: null, is_group_conversation: false, updated_at: 2021-03-09T08:14:18.467461+01:00, created_at: 2021-03-09T08:14:18.467517+01:00}, author: black, text: teset123, read_by_author: true, read_by_recipient: false, was_edited: false, media: null, poster: null, updated_at: 2021-04-13T09:21:24.922145+01:00, created_at: 2021-04-13T09:21:24.922169+01:00, kind: text, deleted_for_recipient: false, deleted_for_author: false, delivered: true, meta_data: {}, replied_to: {id: 736ab0e9-1c57-4452-98b4-13664a262b81, check_id: 5da0bcd7-831d-4d02-97bd-dd9e1f78ebef, author: black, text: test, media: null, poster: null, kind: text, read_by_author: true, read_by_recipient: false, deleted_for_recipient: false, deleted_for_author: false, delivered: true, was_edited

    Map<String, dynamic> isReplyTo = message["replied_to"] is String
        ? jsonDecode(message["replied_to"])
        : message["replied_to"] ?? {};

    if (isReplyTo.isNotEmpty) {
      return getReplyMessageUI(
          newMessage: message, isSend: isSend!, repliedTo: isReplyTo);
    }

    Map<String, dynamic> linkData =
        detectLinkInText(messageDecoderWithEmoji(message['text'].toString())!);

    if (linkData["hasLink"]) {
      String linkToBePreview = linkData['links'][0];

      if (!linkToBePreview.contains("http")) {
        linkToBePreview = "http://" + linkToBePreview;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.chatConversation!.isGroupConversation!
              ? message['author'] != userBloc.user.userName
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message!['author_full_name'] ??
                              widget.message!['author'],
                          style: TextStyle(
                              color: isSend! ? Colors.white : navyBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                      ],
                    )
                  : Container(
                      width: 0,
                    )
              : Container(
                  width: 0,
                ),
          FlutterLinkPreview(
            key: ValueKey("${linkToBePreview}233"),
            url: linkToBePreview,
            builder: (info) {
              if (info == null)
                return InkWell(
                  onTap: () {
                    launchUrl(Uri.parse(linkToBePreview));
                  },
                  child: Container(
                    margin:
                        EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
                    child: Text(
                      linkToBePreview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: navyBlue, fontSize: 14),
                    ),
                  ),
                );
              if (info is WebImageInfo) {
                return CachedNetworkImage(
                  imageUrl: info.image!,
                  fit: BoxFit.contain,
                  errorWidget: imageErrorWidget,
                );
              }

              final WebInfo webInfo = info as WebInfo;
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: getPreview(webInfo)),
              );
            },
          ),
          LinkWell(
            messageDecoderWithEmoji(message['text'].toString())!,
            style: TextStyle(
                color: isSend! ? Colors.white : blackFont,
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

    return getSimpleMessage(message: message, isSend: isSend!);
  }

  getPreviewIcon(String? url) {
    if (url != null) {
      if (url.endsWith('.png') ||
          url.endsWith('.jpg') ||
          url.endsWith('.jpeg')) {
        return url;
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  List<Widget> getPreview(WebInfo webInfo) {
    List<Widget> children = [
      Center(
        child: Row(
          children: <Widget>[
            getPreviewIcon(webInfo.icon).isEmpty
                ? SizedBox.shrink()
                : CachedNetworkImage(
                    imageUrl: getPreviewIcon(webInfo.icon),
                    errorWidget: imageErrorWidget,
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
            getPreviewIcon(webInfo.icon).isEmpty
                ? SizedBox.shrink()
                : const SizedBox(width: 8),
            Expanded(
              child: Text(
                webInfo.title!,
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
          webInfo.description!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
              errorWidget: imageErrorWidget,
              imageUrl: webInfo.image!,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ]);
    }

    return children;
  }

  Widget getSimpleMessage(
      {required Map<String, dynamic> message, required bool isSend}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.chatConversation!.isGroupConversation!
            ? message['author'] != userBloc.user.userName
                ? Column(
                    children: [
                      Text(
                        message['author_full_name'] ?? message['author'],
                        style: TextStyle(
                            color: isSend ? Colors.white : navyBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                    ],
                  )
                : Container(
                    width: 0,
                  )
            : Container(
                width: 0,
              ),
        Text(
          messageDecoderWithEmoji(message['text'].toString())!,
          style:
              TextStyle(color: isSend ? Colors.white : blackFont, fontSize: 16),
        ),
      ],
    );
  }

  Widget getReplyMessageUI(
      {required Map<String, dynamic> newMessage,
      required bool isSend,
      required Map<String, dynamic> repliedTo}) {
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
          padding: EdgeInsets.symmetric(
            horizontal: 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.chatConversation!.isGroupConversation!
                  ? newMessage['author'] != userBloc.user.userName
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              newMessage['author_full_name'] ??
                                  newMessage['author'],
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
                          width: 0,
                        )
                  : Container(
                      width: 0,
                    ),
              GestureDetector(
                onTap: onReplyMessageTap as void Function()? ?? null,
                child: getRepliedMessageUI(
                    messageData: repliedTo,
                    isSend: isSend,
                    isRepliedSend: isRepliedSend),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 2,
        ),
        Text(
          messageDecoderWithEmoji(newMessage['text'].toString())!,
          style:
              TextStyle(color: isSend ? Colors.white : blackFont, fontSize: 16),
        ),
      ],
    );
  }

  Widget getRepliedMessageUI(
      {required Map<String, dynamic> messageData,
      bool? isSend,
      bool? isRepliedSend}) {
    String? messageType = messageData["kind"];
    switch (messageType) {
      case "text":
        Widget getMessageUi = renderReplyMessage(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getMessageUi;

      case "image":
        Widget getMessageUi = renderImageMedia(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getMessageUi;

      case "video":
        Widget getMessageUi = renderVideoMedia(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getMessageUi;

      case "audio":
        Widget getMessageUi = renderAudioMedia(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getMessageUi;

      case "transaction":
        Widget getPaymentUI = renderSendPayment(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getPaymentUI;

      case "payment-request":
        Widget getPaymentUI = renderPaymentRequest(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getPaymentUI;

      case "product":
        Widget getProductUI = renderProduct(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getProductUI;

      case "service":
        Widget getServiceUI = renderService(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getServiceUI;

      case "job":
        Widget getServiceUI = renderJobService(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getServiceUI;

      case "user-profile":
        Widget getUserProfileUI = renderUserProfile(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getUserProfileUI;

      case "user_location":
        Widget getUserLocationUI = renderUserLocation(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getUserLocationUI;

      case "gif_image":
        if (gifController == null) {
          gifController = GifController(vsync: this);
          gifController!.value = 0;
        }

        Widget getGIFImageUI = renderGIFImage(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getGIFImageUI;

      case "envelope":
        Widget getEnvelopeUI = renderEnvelope(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getEnvelopeUI;

      case "blog_post":
        Widget getPostUI = renderPost(
            message: messageData,
            isSend: isSend!,
            isRepliedSend: isRepliedSend);
        return getPostUI;

      default:
        debugPrint(
            "Unknown Message Kind 4: $messageType Message:- $messageData");
        Widget getErrorRenderTypeUI = unKnownMessageType();
        return getErrorRenderTypeUI;
    }
  }

  Widget renderReplyMessage(
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
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
            getAuthorName(message: message, currentUser: userBloc.user)!,
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
            messageDecoderWithEmoji(message["text"])!,
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
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
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
              errorWidget: imageErrorWidget,
              height: 48,
              width: 48,
              fit: BoxFit.cover,
              imageUrl: message["media"],
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
                  getAuthorName(message: message, currentUser: userBloc.user)!,
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
                  "Photo",
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

  Widget renderVideoMedia(
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
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
            child: Stack(
              children: [
                CachedNetworkImage(
                  errorWidget: imageErrorWidget,
                  height: 48,
                  width: 48,
                  fit: BoxFit.cover,
                  imageUrl: message["poster"],
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Icon(
                    SlydoAppIcon.music_play_1,
                    color: Colors.white,
                    size: 14,
                  ),
                )
              ],
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
                  getAuthorName(message: message, currentUser: userBloc.user)!,
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
                  "Video",
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

  Widget renderAudioMedia(
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
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
            getAuthorName(message: message, currentUser: userBloc.user)!,
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
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
    Map<String, dynamic>? transaction;

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
            transaction!["description"] == ""
                ? getAuthorName(message: message, currentUser: userBloc.user)!
                : transaction["description"] ??
                    getAuthorName(
                        message: message, currentUser: userBloc.user)!,
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
                    fontFamily: "Inter",
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
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
    Map<String, dynamic>? paymentRequest;

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
            paymentRequest!["description"] == ""
                ? getAuthorName(message: message, currentUser: userBloc.user)!
                : paymentRequest["description"] ??
                    getAuthorName(
                        message: message, currentUser: userBloc.user)!,
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
                    fontFamily: "Inter",
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
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
    late Product product;
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
              errorWidget: imageErrorWidget,
              height: 48,
              width: 48,
              fit: BoxFit.cover,
              imageUrl: product.cover!,
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
                  product.name!,
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
                          fontFamily: "Inter",
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

  Widget renderPost(
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
    late PostForChatModel post;
    if (message["meta_data"] is String) {
      post = PostForChatModel.fromJson(jsonDecode(message["meta_data"]));
    } else if (message["meta_data"] is Map) {
      post = PostForChatModel.fromJson(message["meta_data"]);
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
              errorWidget: imageErrorWidget,
              height: 48,
              width: 48,
              fit: BoxFit.cover,
              imageUrl: post.image!,
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
                  post.title!,
                  style: TextStyle(
                      color: getDividerColor(
                          isSend: isSend, isRepliedSend: isRepliedSend),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
                SizedBox(height: 4),
                Text(
                  post.authorUsername!,
                  style: TextStyle(
                      color: greyBorderColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget renderService(
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
    late Service service;
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
              errorWidget: imageErrorWidget,
              height: 48,
              width: 48,
              fit: BoxFit.cover,
              imageUrl: service.cover!,
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
                  service.name!,
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
                          fontFamily: "Inter",
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

  Widget renderJobService(
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
    late JobModel jobModel;
    if (message["meta_data"] is String) {
      jobModel = JobModel.fromJson(jsonDecode(message["meta_data"]));
    } else if (message["meta_data"] is Map) {
      jobModel = JobModel.fromJson(message["meta_data"]);
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
              errorWidget: imageErrorWidget,
              height: 48,
              width: 48,
              fit: BoxFit.cover,
              imageUrl: jobModel.ownerAvatar!,
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
                  jobModel.owner!,
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
                          fontFamily: "Inter",
                          color: getDescriptionColor(
                              isSend: isSend, isRepliedSend: isRepliedSend),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      moneyDisplayNormalizer(
                          int.parse(jobModel.pay.toString())),
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
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
    late CustomerProfile customerProfile;

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
                      ? defaultImage
                      : customerProfile.avatar!,
                  errorWidget: imageErrorWidget,
                  colorBlendMode: BlendMode.darken,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
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
                  customerProfile.displayName() ?? "",
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

  Widget renderEnvelope(
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
    late Envelope envelope;

    bool isEmptyEnvelope = false;

    if (message['meta_data'] is String) {
      envelope = Envelope.fromJson(jsonDecode(message['meta_data']));
    } else if (message['meta_data'] is Map) {
      envelope = Envelope.fromJson(message['meta_data']);
    }

    if (envelope.type == "empty-envelop") {
      isEmptyEnvelope = true;
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
        children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image.asset(
                isEmptyEnvelope
                    ? "assets/images/envelope/envelope_brown.png"
                    : envelope.isOpen
                        ? "assets/images/envelope/envelope_green_open.png"
                        : "assets/images/envelope/envelope_green.png",
                height: MediaQuery.of(context).size.width / 8,
                width: MediaQuery.of(context).size.width / 8,
                fit: BoxFit.fill,
              )),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  messageDecoderWithEmoji("${envelope.title ?? ""}")!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: getDividerColor(
                        isSend: isSend, isRepliedSend: isRepliedSend),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  isEmptyEnvelope
                      ? message["author_full_name"] ?? message["author"]
                      : isSend
                          ? envelope.isOpen
                              ? "Opened"
                              : "Closed"
                          : message["author_full_name"] ?? message["author"],
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: getDescriptionColor(
                          isSend: isSend, isRepliedSend: isRepliedSend)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          widget.chatConversation!.isGroupConversation!
              ? Container(
                  height: 50,
                  width: 80,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 30,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: navyBlue, width: 2)),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              height: 40,
                              width: 40,
                              fit: BoxFit.fill,
                              errorWidget: imageErrorWidget,
                              imageUrl:
                                  message['to_customer_avatar'] ?? defaultImage,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: naturalGreen, width: 2)),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            errorWidget: imageErrorWidget,
                            height: 40,
                            width: 40,
                            fit: BoxFit.fill,
                            imageUrl:
                                message['from_customer_avatar'] ?? defaultImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  width: 1,
                  height: 1,
                ),
        ],
      ),
    );
  }

  Widget renderUserLocation(
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
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
              errorWidget: imageErrorWidget,
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
                  getAuthorName(message: message, currentUser: userBloc.user)!,
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
      {required Map<String, dynamic> message,
      required bool isSend,
      bool? isRepliedSend}) {
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
            child: GifImage(
              controller: gifController,
              height: 48,
              width: 48,
              fit: BoxFit.cover,
              image: NetworkImage(message["text"]),
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
                  getAuthorName(message: message, currentUser: userBloc.user)!,
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

  Color getTitleAndDividerColor({required bool isSend, bool? isRepliedSend}) {
    if (isSend) {
      if (isRepliedSend!) {
        return naturalGreen;
      } else {
        return Colors.white;
      }
    } else {
      if (isRepliedSend!) {
        return naturalGreen;
      } else {
        return blackFont;
      }
    }
  }

  Color getDividerColor({required bool isSend, bool? isRepliedSend}) {
    if (isSend) {
      return Colors.white;
    } else {
      return blackFont;
    }
  }

  Color getDescriptionColor({required bool isSend, bool? isRepliedSend}) {
    if (isSend) {
      return Colors.white;
    } else {
      return blackFont;
    }
  }

  @override
  void dispose() {
    gifController?.dispose();
    super.dispose();
  }
}
