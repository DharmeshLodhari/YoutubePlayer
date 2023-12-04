import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/post_title_for_chat.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/Envelope.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/flutter_gifimage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils.dart';

// ignore: must_be_immutable
class EditOrReplyMessageUI extends StatefulWidget {
  final Map<String, dynamic>? messageData;
  final ChatConversation? chatConversation;

  EditOrReplyMessageUI({this.messageData, this.chatConversation});

  @override
  _EditOrReplyMessageUIState createState() => _EditOrReplyMessageUIState();
}

class _EditOrReplyMessageUIState extends State<EditOrReplyMessageUI>
    with SingleTickerProviderStateMixin {
  late UserBloc userBloc;

  GifController? gifController;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    Widget uiTile =
        getUITileAccordingToMessageType(messageData: widget.messageData!);

    return Container(padding: EdgeInsets.only(top: 8), child: uiTile);
  }

  Widget getUITileAccordingToMessageType(
      {required Map<String, dynamic> messageData}) {
    String? messageType = messageData["kind"];
    switch (messageType) {
      case "text":
        Widget getMessageUi = renderMessage(message: messageData);
        return getMessageUi;

      case "image":
        Widget getMessageUi = renderImageMedia(message: messageData);
        return getMessageUi;

      case "video":
        Widget getMessageUi = renderVideoMedia(message: messageData);
        return getMessageUi;

      case "audio":
        Widget getMessageUi = renderAudioMedia(message: messageData);
        return getMessageUi;

      case "transaction":
        Widget getPaymentUI = renderSendPayment(message: messageData);
        return getPaymentUI;

      case "payment-request":
        Widget getPaymentUI = renderPaymentRequest(message: messageData);
        return getPaymentUI;

      case "product":
        Widget getProductUI = renderProduct(message: messageData);
        return getProductUI;

      case "service":
        Widget getServiceUI = renderService(message: messageData);
        return getServiceUI;

      case "user-profile":
        Widget getUserProfileUI = renderUserProfile(message: messageData);
        return getUserProfileUI;

      case "user_location":
        Widget getUserLocationUI = renderUserLocationUI(message: messageData);
        return getUserLocationUI;

      case "gif_image":
        if (gifController == null) {
          gifController = GifController(vsync: this);
          gifController!.value = 0;
        }
        Widget getGIFImageUI = renderGIFImageUI(message: messageData);
        return getGIFImageUI;

      case "envelope":
        Widget getEnvelopeUI = renderEnvelope(message: messageData);
        return getEnvelopeUI;
      case "blog_post":
        Widget getPostUI = renderPostUI(message: messageData);
        return getPostUI;
      case "job":
        Widget getJobUI = renderJobService(message: messageData);
        return getJobUI;

      default:
        debugPrint(
            "Unknown Message Kind 3: $messageType Message:- $messageData");
        Widget getErrorRenderTypeUI = unKnownMessageType();
        return getErrorRenderTypeUI;
    }
  }

  Widget renderMessage({required Map<String, dynamic> message}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getAuthorName(message: message, currentUser: userBloc.user)!,
            style: TextStyle(
                color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
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
                color: darkGrey, fontSize: 12, fontWeight: FontWeight.w400),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget renderImageMedia({required Map<String, dynamic> message}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
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
              imageUrl: message["media"],
              errorWidget: imageErrorWidget,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getAuthorName(message: message, currentUser: userBloc.user)!,
                  style: TextStyle(
                      color: blackFont,
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
                      color: darkGrey,
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

  Widget renderVideoMedia({required Map<String, dynamic> message}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
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
                  height: 48,
                  width: 48,
                  fit: BoxFit.cover,
                  imageUrl: message["poster"],
                  errorWidget: imageErrorWidget,
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
              children: [
                Text(
                  getAuthorName(message: message, currentUser: userBloc.user)!,
                  style: TextStyle(
                      color: blackFont,
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
                      color: darkGrey,
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

  Widget renderAudioMedia({required Map<String, dynamic> message}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getAuthorName(message: message, currentUser: userBloc.user)!,
            style: TextStyle(
                color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
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
                color: darkGrey, fontSize: 12, fontWeight: FontWeight.w400),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget renderSendPayment({required Map<String, dynamic> message}) {
    Map<String, dynamic>? transaction;

    if (message['text'] is String) {
      transaction = jsonDecode(message['text']);
    } else if (message['text'] is Map) {
      transaction = message['text'];
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
        ),
      ),
      padding: EdgeInsets.only(left: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction!["description"] == ""
                      ? getAuthorName(
                          message: message, currentUser: userBloc.user)!
                      : transaction["description"] ??
                          getAuthorName(
                              message: message, currentUser: userBloc.user)!,
                  style: TextStyle(
                      color: blackFont,
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
                          color: darkGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      moneyDisplayNormalizer(
                          int.parse(transaction['amount'].toString())),
                      style: TextStyle(
                          color: darkGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          widget.chatConversation!.isGroupConversation!
              ? Container(
                  height: 50,
                  width: 70,
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
                              imageUrl: message['to_customer_avatar'],
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
                            height: 40,
                            width: 40,
                            fit: BoxFit.fill,
                            errorWidget: imageErrorWidget,
                            imageUrl: message['from_customer_avatar'],
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

  Widget renderPaymentRequest({required Map<String, dynamic> message}) {
    Map<String, dynamic>? paymentRequest;

    if (message['text'] is String) {
      paymentRequest = jsonDecode(message['text']);
    } else if (message['text'] is Map) {
      paymentRequest = message['text'];
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
        ),
      ),
      padding: EdgeInsets.only(left: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paymentRequest!["description"] == ""
                      ? getAuthorName(
                          message: message, currentUser: userBloc.user)!
                      : paymentRequest["description"] ??
                          getAuthorName(
                              message: message, currentUser: userBloc.user)!,
                  style: TextStyle(
                      color: blackFont,
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
                          color: darkGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      moneyDisplayNormalizer(
                          double.parse(paymentRequest['amount'].toString())
                              .toInt()),
                      style: TextStyle(
                          color: darkGrey,
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
          widget.chatConversation!.isGroupConversation!
              ? Container(
                  height: 50,
                  width: 70,
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
                              imageUrl: message['to_customer_avatar'],
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
                            height: 40,
                            width: 40,
                            fit: BoxFit.fill,
                            errorWidget: imageErrorWidget,
                            imageUrl: message['from_customer_avatar'],
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

  Widget renderProduct({required Map<String, dynamic> message}) {
    late Product product;
    if (message["meta_data"] is String) {
      product = Product.fromJson(jsonDecode(message["meta_data"]));
    } else if (message["meta_data"] is Map) {
      product = Product.fromJson(message["meta_data"]);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
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
              imageUrl: product.cover!,
              errorWidget: imageErrorWidget,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name!,
                  style: TextStyle(
                      color: blackFont,
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
                          color: darkGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      moneyDisplayNormalizer(
                          int.parse(product.price.toString())),
                      style: TextStyle(
                          color: darkGrey,
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

  Widget renderService({required Map<String, dynamic> message}) {
    late Service service;
    if (message["meta_data"] is String) {
      service = Service.fromJson(jsonDecode(message["meta_data"]));
    } else if (message["meta_data"] is Map) {
      service = Service.fromJson(message["meta_data"]);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
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
              imageUrl: service.cover!,
              errorWidget: imageErrorWidget,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name!,
                  style: TextStyle(
                      color: blackFont,
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
                          color: darkGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      moneyDisplayNormalizer(
                          int.parse(service.price.toString())),
                      style: TextStyle(
                          color: darkGrey,
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

  Widget renderJobService({required Map<String, dynamic> message}) {
    Map<String, dynamic>? data;

    if (message["meta_data"] is String) {
      data = jsonDecode(message["meta_data"]);
    } else if (message["meta_data"] is Map) {
      data = message["meta_data"];
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
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
              imageUrl: data!['owner_avatar'],
              errorWidget: imageErrorWidget,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['owner_name'],
                  style: TextStyle(
                      color: blackFont,
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
                          color: darkGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      moneyDisplayNormalizer(
                          int.parse(data['pay'].toString())),
                      style: TextStyle(
                          color: darkGrey,
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

  Widget renderUserProfile({required Map<String, dynamic> message}) {
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
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
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
              children: [
                Text(
                  customerProfile.displayName() ?? "",
                  style: TextStyle(
                      color: blackFont,
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
                      color: darkGrey,
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

  Widget renderEnvelope({required Map<String, dynamic> message}) {
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
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
        ),
      ),
      padding: EdgeInsets.only(left: 12),
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
            ),
          ),
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
                    color: blackFont,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Envelope",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: blackFont),
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
                              imageUrl: message['to_customer_avatar'],
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
                            height: 40,
                            width: 40,
                            fit: BoxFit.fill,
                            errorWidget: imageErrorWidget,
                            imageUrl: message['from_customer_avatar'],
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

  Widget renderUserLocationUI({required Map<String, dynamic> message}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
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
              errorWidget: imageErrorWidget,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getAuthorName(message: message, currentUser: userBloc.user)!,
                  style: TextStyle(
                      color: blackFont,
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
                      color: darkGrey,
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

  Widget renderGIFImageUI({required Map<String, dynamic> message}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
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
              children: [
                Text(
                  getAuthorName(message: message, currentUser: userBloc.user)!,
                  style: TextStyle(
                      color: blackFont,
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
                      color: darkGrey,
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

  Widget renderPostUI({required Map<String, dynamic> message}) {
    PostForChatModel post =
        PostForChatModel.fromJson(jsonDecode(message['meta_data']));
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
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
              imageUrl: post.image!,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getAuthorName(message: message, currentUser: userBloc.user)!,
                  style: TextStyle(
                      color: blackFont,
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
                  messageDecoderWithEmoji(post.title) ?? '',
                  style: TextStyle(
                      color: darkGrey,
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

  Widget unKnownMessageType() {
    return Container();
  }

  @override
  void dispose() {
    gifController?.dispose();
    super.dispose();
  }
}
