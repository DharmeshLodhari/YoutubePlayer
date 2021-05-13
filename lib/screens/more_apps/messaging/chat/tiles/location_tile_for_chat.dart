import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';

class LocationTileForChatMessage extends StatelessWidget {
  final Map<String, dynamic> message;
  final ChatConversation chatConversation;

  LocationTileForChatMessage({this.message, this.chatConversation});

  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = Provider.of<UserBloc>(context);

    bool isSend = message["author"] == userBloc.user.userName;

    UserLocation location;

    if (message['text'] is Map) {
      location = UserLocation(
          latitude: message['text']["latitude"],
          longitude: message['text']["longitude"]);
    }
    if (message['text'] is String) {
      Map<String, dynamic> decodedLocation = jsonDecode(message['text']);
      location = UserLocation(
          latitude: decodedLocation["latitude"],
          longitude: decodedLocation["longitude"]);
    }

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
                MapsLauncher.launchCoordinates(
                    location.latitude, location.longitude);
              },
              child: Container(
                constraints: BoxConstraints(
                  // maxWidth: MediaQuery.of(context).size.width / 1.30,
                  // minWidth: MediaQuery.of(context).size.width / 1.30,
                  maxWidth: MediaQuery.of(context).size.width / 1.8,
                  minWidth: MediaQuery.of(context).size.width / 1.8,
                ),
                decoration: BoxDecoration(
                  color: chatConversation.isGroupConversation
                      ? isSend
                          ? Colors.transparent
                          : chatBackgroundColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: chatConversation.isGroupConversation
                        ? isSend
                            ? 0
                            : 8
                        : 0,
                    vertical: chatConversation.isGroupConversation
                        ? isSend
                            ? 0
                            : 8
                        : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    chatConversation.isGroupConversation
                        ? message['author'] != userBloc.user.userName
                            ? Column(
                                children: [
                                  Text(
                                    message['author_full_name'] ??
                                        message['author'],
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
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: ClipRRect(
                        child: CachedNetworkImage(
                          height: MediaQuery.of(context).size.width / 3,
                          width: MediaQuery.of(context).size.width / 1.8,
                          // height: MediaQuery.of(context).size.width / 2.2,
                          // width: MediaQuery.of(context).size.width / 1.30,
                          imageUrl:
                              "https://i.dlpng.com/static/png/6635948_preview.png",
                          fit: BoxFit.cover,
                          color: navyBlue,
                          colorBlendMode: BlendMode.color,
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
