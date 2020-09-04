import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/message.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';

// ignore: must_be_immutable
class MessageTile extends StatefulWidget {
  final PartialMessage partialMessage;
  Widget expandedWidget = Container();
  MessageTile({this.partialMessage, this.expandedWidget});

  @override
  _MessageTileState createState() =>
      _MessageTileState(partialMessage: partialMessage);
}

class _MessageTileState extends State<MessageTile> {
  UserBloc userBloc;
  final _auth = AuthService();
  PartialMessage partialMessage;
  _MessageTileState({this.partialMessage});

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: dividerColor,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dividerColor, width: 0.5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                  dense: true,
                  leading: getLeading(),
                  title: getTitle(),
                  trailing: getTrailing(),
                  subtitle: getSubtitle()),
            ),
            widget.expandedWidget,
          ],
        ),
      ),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: partialMessage.senderAvatar,
        height: 48,
        width: 48,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => partialMessage.senderAvatar == ""
            ? Icon(Icons.person)
            : CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
                backgroundColor: lightBlue(),
              ),
      ),
    );
  }

  Widget getTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Text(
        partialMessage.subject,
        maxLines: 1,
        style: TextStyle(
            color: partialMessage.isRead ? darkGrey : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15),
      ),
    );
  }

  Widget getTrailing() {
    // this variable is responsible for the message which is user seeing isRecipient is seeing message
    // or isSender is seeing message we got that user and check if it is recipient then
    // we are showing and modifying star icon by message's isStarredByRecipient property and if it sender then
    // we are showing and modifying star icon by message's isStarredBySender property
    bool isRecipient = userBloc.user.userName == partialMessage.recipient;
    return IconButton(
      icon: isRecipient
          ? partialMessage.isStarredByRecipient
          ? Icon(
        SlydoAppIcon.star,
        color: starYellow,
        size: 20,
      )
          : Icon(
        SlydoAppIcon.star,
        color: greyBorderColor,
        size: 20,
      )
          : partialMessage.isStarredBySender
          ? Icon(
        SlydoAppIcon.star,
        color: starYellow,
        size: 20,
      )
          : Icon(
        SlydoAppIcon.star,
        color: greyBorderColor,
        size: 20,
      ),
      onPressed: () async {
        var action = isRecipient
            ? partialMessage.isStarredByRecipient
            ? AppLocalization
            .of(context)
            .unstar
            : AppLocalization
            .of(context)
            .star
            : partialMessage.isStarredBySender
            ? AppLocalization
            .of(context)
            .unstar
            : AppLocalization
            .of(context)
            .star;
        await _auth.updateMessage(partialMessage.id, action);
        setState(() {
          if (isRecipient) {
            partialMessage.isStarredByRecipient =
                partialMessage.isStarredByRecipient ? false : true;
          } else {
            partialMessage.isStarredBySender =
                partialMessage.isStarredBySender ? false : true;
          }
        });
      },
    );
  }

  Widget getSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          partialMessage.subtitle,
          style: TextStyle(
            color: darkGrey,
            fontSize: 12,
          ),
        ),
        Text(
          partialMessage.timeStamp,
          style: TextStyle(
            color: darkGrey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
