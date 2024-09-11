import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/messaging/chat/utils.dart';
import 'package:Slydo/screens/payment_and_banking/models/envelope_model.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnvelopeTileForChat extends StatefulWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  const EnvelopeTileForChat({super.key, this.message, this.chatConversation});

  @override
  State<EnvelopeTileForChat> createState() => _EnvelopeTileForChatState();
}

class _EnvelopeTileForChatState extends State<EnvelopeTileForChat> {
  late UserBloc userBloc;

  CustomerProfile? customerProfile;

  late Envelope envelope;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    Map<String, dynamic>? data;

    if (widget.message!['meta_data'] is String) {
      data = jsonDecode(widget.message!['meta_data']);
    } else if (widget.message!['meta_data'] is Map) {
      data = widget.message!['meta_data'];
    }

    // debugPrint("data=> $data");

    envelope = Envelope.fromJson(data!);

    // customerProfile = CustomerProfile.fromJson(data);

    final bool isSend = widget.message!["author"] == userBloc.user.userName;

    final Map<String, dynamic>? message = widget.message;

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isSend) Container() else Container(width: 20),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.30,
                  minWidth: MediaQuery.of(context).size.width / 1.30,
                  minHeight: 50),
              child: getEnvelopeUI(
                  message: message, envelope: envelope, isSend: isSend),
            ),
            if (isSend)
              SizedBox(
                width: 20,
                child: isSend
                    ? Center(
                        child: getMessageTick(message: widget.message!),
                      )
                    : Container(),
              )
            else
              Container(),
          ],
        ),
        const SizedBox(
          height: 1,
        ),
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
              formatTime(widget.message!['created_at']),
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
        )
      ],
    );
  }

  Widget getEnvelopeUI(
      {Map<String, dynamic>? message,
      required Envelope envelope,
      required bool isSend}) {
    bool isEmptyEnvelope = false;

    if (envelope.type == "empty-envelop") {
      isEmptyEnvelope = true;
      // if (envelope.magicEnvelope != null || envelope.magicEnvelope != "{}") {
      //   isEmptyEnvelope = false;
      //   Envelope magicEnvelope =
      //       Envelope.fromJson(jsonDecode(envelope.magicEnvelope));
      //   envelope = magicEnvelope;
      // }
    }
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: isEmptyEnvelope ? brownLight : naturalGreenLight,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(!isSend ? 0 : 10),
            bottomRight: Radius.circular(isSend ? 0 : 10),
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: <Widget>[
                Image.asset(
                  isEmptyEnvelope
                      ? "assets/images/envelope/envelope_brown.png"
                      : envelope.isOpen
                          ? "assets/images/envelope/envelope_green_open.png"
                          : "assets/images/envelope/envelope_green.png",
                  height: MediaQuery.of(context).size.width / 7,
                  width: MediaQuery.of(context).size.width / 7,
                  fit: BoxFit.fill,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        messageDecoderWithEmoji(envelope.title ?? "")!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: blackFont,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: widget.chatConversation!.isGroupConversation!
                            ? 2
                            : 4,
                      ),
                      Text(
                        isEmptyEnvelope
                            ? message!["author_full_name"] ?? message["author"]
                            : isSend
                                ? envelope.isOpen
                                    ? "Opened"
                                    : "Closed"
                                : message!["author_full_name"] ??
                                    message["author"],
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: blackFont),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // SizedBox(
                      //   height:
                      //       widget.chatConversation.isGroupConversation ? 2 : 0,
                      // ),
                      // widget.chatConversation.isGroupConversation
                      //     ? Text(
                      //         envelope.toCustomer,
                      //         style: TextStyle(
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.w400,
                      //             color: navyBlue),
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //       )
                      //     : Container(),
                    ],
                  ),
                ),
                if (widget.chatConversation!.isGroupConversation!)
                  SizedBox(
                    width: 60,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 26,
                          child: Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: navyBlue, width: 2)),
                            child: ClipOval(
                              child: Container(
                                color: Colors.white,
                                child: CachedNetworkImage(
                                  height: 34,
                                  width: 34,
                                  fit: BoxFit.fill,
                                  imageUrl: message!['to_customer_avatar'],
                                  errorWidget: imageErrorWidget,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border:
                                  Border.all(color: naturalGreen, width: 2)),
                          child: ClipOval(
                            child: Container(
                              color: Colors.white,
                              child: CachedNetworkImage(
                                height: 34,
                                width: 34,
                                fit: BoxFit.fill,
                                errorWidget: imageErrorWidget,
                                imageUrl: message['from_customer_avatar'],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(),
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        if (isEmptyEnvelope) {
          if (envelope.toCustomer == userBloc.user.userName) {
            final ChatConversation chatConversation =
                ChatConversation.fromChatConversation(widget.chatConversation!);

            if (widget.chatConversation!.isGroupConversation!) {
              chatConversation.userName = userBloc.user.userName;
              chatConversation.fullName = userBloc.user.fullName;
              chatConversation.avatar = userBloc.user.avatar;
              chatConversation.qrCode = userBloc.user.qrCode;
            }

            Navigator.of(context).pushNamed("/put-money-in-envelope",
                arguments: {
                  "chatConversation": chatConversation,
                  "message": message,
                  "envelope": envelope
                });
            return;
          }
        }

        if (userBloc.user.userName == envelope.toCustomer ||
            userBloc.user.userName == envelope.fromCustomer) {
          Navigator.of(context).pushNamed("/envelope-detail", arguments: {
            "searchedUserName": message!["author"],
            "data": message,
            "envelope": envelope
          });
        }

        return;
      },
    );
  }
}
