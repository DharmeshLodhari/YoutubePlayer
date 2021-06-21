import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/Envelope.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnvelopeTileForChat extends StatefulWidget {
  final Map<String, dynamic> message;
  final ChatConversation chatConversation;

  EnvelopeTileForChat({this.message, this.chatConversation});

  @override
  _EnvelopeTileForChatState createState() => _EnvelopeTileForChatState();
}

class _EnvelopeTileForChatState extends State<EnvelopeTileForChat> {
  UserBloc userBloc;

  CustomerProfile customerProfile;

  Envelope envelope;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    Map<String, dynamic> data;

    if (widget.message['meta_data'] is String) {
      data = jsonDecode(widget.message['meta_data']);
    } else if (widget.message['meta_data'] is Map) {
      data = widget.message['meta_data'];
    }

    // debugPrint("data=> $data");

    envelope = Envelope.fromJson(data);

    // customerProfile = CustomerProfile.fromJson(data);

    bool isSend = widget.message["author"] == userBloc.user.userName;

    Map<String, dynamic> message = widget.message;

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isSend ? Container() : Container(width: 20),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.30,
                  minWidth: MediaQuery.of(context).size.width / 1.30,
                  minHeight: 50),
              child: getEnvelopeUI(
                  message: message, envelope: envelope, isSend: isSend),
            ),
            isSend
                ? Container(
                    width: 20,
                    child: isSend
                        ? Center(
                            child: getMessageTick(message: widget.message),
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
              formatTime(widget.message['created_at']),
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

  Widget getEnvelopeUI(
      {Map<String, dynamic> message, Envelope envelope, bool isSend}) {
    bool isEmptyEnvelope = false;

    if (envelope.type == "empty-envelop") {
      isEmptyEnvelope = true;
    }
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: isEmptyEnvelope ? brownLight : naturalGreenLight,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(!isSend ? 0 : 10),
            bottomRight: Radius.circular(isSend ? 0 : 10),
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
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
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEmptyEnvelope ? "Empty Envelope" : "Envelope",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: blackFont),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: blackFont),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      onTap: () {

        if(isEmptyEnvelope)
          {

          }

        Navigator.of(context).pushNamed("/envelope-detail", arguments: {
          "searchedUserName": message["author"],
          "data": message
        });
      },
    );
  }
}
