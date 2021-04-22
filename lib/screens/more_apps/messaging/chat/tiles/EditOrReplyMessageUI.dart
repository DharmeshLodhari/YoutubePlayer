import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:provider/provider.dart';

import '../utils.dart';

// ignore: must_be_immutable
class EditOrReplyMessageUI extends StatefulWidget {
  final Map<String, dynamic> messageData;

  EditOrReplyMessageUI({this.messageData});

  @override
  _EditOrReplyMessageUIState createState() => _EditOrReplyMessageUIState();
}

class _EditOrReplyMessageUIState extends State<EditOrReplyMessageUI>
    with SingleTickerProviderStateMixin {
  UserBloc userBloc;

  GifController gifController;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    Widget uiTile =
        getUITileAccordingToMessageType(messageData: widget.messageData);

    return Container(padding: EdgeInsets.only(top: 8), child: uiTile);
  }

  Widget getUITileAccordingToMessageType({Map<String, dynamic> messageData}) {
    String messageType = messageData["kind"];
    switch (messageType) {
      case "text":
        Widget getMessageUi = renderMessage(message: messageData);
        return getMessageUi;
        break;

      case "image":
        Widget getMessageUi = renderImageMedia(message: messageData);
        return getMessageUi;
        break;

      case "video":
        Widget getMessageUi = renderVideoMedia(message: messageData);
        return getMessageUi;
        break;

      case "audio":
        Widget getMessageUi = renderAudioMedia(message: messageData);
        return getMessageUi;
        break;

      case "transaction":
        Widget getPaymentUI = renderSendPayment(message: messageData);
        return getPaymentUI;

        break;

      case "payment-request":
        Widget getPaymentUI = renderPaymentRequest(message: messageData);
        return getPaymentUI;
        break;

      case "product":
        Widget getProductUI = renderProduct(message: messageData);
        return getProductUI;
        break;
      case "service":
        Widget getServiceUI = renderService(message: messageData);
        return getServiceUI;
        break;
      case "user-profile":
        Widget getUserProfileUI = renderUserProfile(message: messageData);
        return getUserProfileUI;
      case "user_location":
        Widget getUserLocationUI = renderUserLocationUI(message: messageData);
        return getUserLocationUI;

      case "gif_image":
        if (gifController == null) {
          gifController = GifController(vsync: this);
          gifController.value = 0;
        }
        Widget getGIFImageUI = renderGIFImageUI(message: messageData);
        return getGIFImageUI;

      default:
        debugPrint(
            "Unknown Message Kind 3: $messageType Message:- $messageData");
        Widget getErrorRenderTypeUI = unKnownMessageType();
        return getErrorRenderTypeUI;
    }
  }

  Widget renderMessage({Map<String, dynamic> message}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getAuthorName(message: message, currentUser: userBloc.user),
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

  Widget renderImageMedia({Map<String, dynamic> message}) {
    return Container(
      decoration: BoxDecoration(
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
                  getAuthorName(message: message, currentUser: userBloc.user),
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

  Widget renderVideoMedia({Map<String, dynamic> message}) {
    return Container(
      decoration: BoxDecoration(
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
                  getAuthorName(message: message, currentUser: userBloc.user),
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

  Widget renderAudioMedia({Map<String, dynamic> message}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getAuthorName(message: message, currentUser: userBloc.user),
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

  Widget renderSendPayment({Map<String, dynamic> message}) {
    Map<String, dynamic> transaction;

    if (message['text'] is String) {
      transaction = jsonDecode(message['text']);
    } else if (message['text'] is Map) {
      transaction = message['text'];
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction["description"] == ""
                ? getAuthorName(message: message, currentUser: userBloc.user)
                : transaction["description"] ??
                    getAuthorName(message: message, currentUser: userBloc.user),
            style: TextStyle(
                color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
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
                    color: darkGrey, fontSize: 12, fontWeight: FontWeight.w400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget renderPaymentRequest({Map<String, dynamic> message}) {
    Map<String, dynamic> paymentRequest;

    if (message['text'] is String) {
      paymentRequest = jsonDecode(message['text']);
    } else if (message['text'] is Map) {
      paymentRequest = message['text'];
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 2.0, color: blackFont),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paymentRequest["description"] == ""
                ? getAuthorName(message: message, currentUser: userBloc.user)
                : paymentRequest["description"] ??
                    getAuthorName(message: message, currentUser: userBloc.user),
            style: TextStyle(
                color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
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
                    color: darkGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                moneyDisplayNormalizer(
                    double.parse(paymentRequest['amount'].toString()).toInt()),
                style: TextStyle(
                    color: darkGrey, fontSize: 12, fontWeight: FontWeight.w400),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget renderProduct({Map<String, dynamic> message}) {
    Product product;
    if (message["meta_data"] is String) {
      product = Product.fromJson(jsonDecode(message["meta_data"]));
    } else if (message["meta_data"] is Map) {
      product = Product.fromJson(message["meta_data"]);
    }

    return Container(
      decoration: BoxDecoration(
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
              imageUrl: product.cover,
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
                  product.name,
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
                          fontFamily: "Roberto",
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

  Widget renderService({Map<String, dynamic> message}) {
    Service service;
    if (message["meta_data"] is String) {
      service = Service.fromJson(jsonDecode(message["meta_data"]));
    } else if (message["meta_data"] is Map) {
      service = Service.fromJson(message["meta_data"]);
    }

    return Container(
      decoration: BoxDecoration(
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
              imageUrl: service.cover,
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
                  service.name,
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
                          fontFamily: "Roberto",
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

  Widget renderUserProfile({Map<String, dynamic> message}) {
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
              children: [
                Text(
                  customerProfile.fullName ?? "",
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

  Widget renderUserLocationUI({Map<String, dynamic> message}) {
    return Container(
      decoration: BoxDecoration(
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
                  getAuthorName(message: message, currentUser: userBloc.user),
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

  Widget renderGIFImageUI({Map<String, dynamic> message}) {
    return Container(
      decoration: BoxDecoration(
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
                  getAuthorName(message: message, currentUser: userBloc.user),
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

  Widget unKnownMessageType() {
    return Container();
  }

  @override
  void dispose() {
    gifController?.dispose();
    super.dispose();
  }
}
