import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/message.dart';
import 'package:Slydo/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageTile extends StatefulWidget {
  final PartialMessage partialMessage;
  MessageTile({this.partialMessage});

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
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
            leading: getLeading(),
            title: getTitle(),
            trailing: getTrailing(),
            subtitle: getSubtitle()),
      ),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: partialMessage.senderAvatar,
        height: 50,
        width: 50,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => partialMessage.senderAvatar == ""
            ? Icon(Icons.person)
            : CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      partialMessage.subject,
      style: TextStyle(
          color: partialMessage.isRead ? Colors.grey[600] : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 15),
    );
  }

  Widget getTrailing() {
    // this variable is responsible for the message which is user seeing isRecipient is seeing message
    // or isSender is seeing message we got that user and check if it is recipient then
    // we are showing and modifying star icon by message's isStarredByRecipient property and if it sender then
    // we are showing and modifying star icon by message's isStarredBySender property
    bool isRecipient = userBloc.user.userName == partialMessage.recipient;
    return Column(
      children: <Widget>[
        Expanded(
          child: Text(
            partialMessage.timeStamp,
            style: TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        Expanded(
            flex: 2,
            child: IconButton(
              icon: isRecipient
                  ? partialMessage.isStarredByRecipient
                      ? Icon(
                          Icons.star,
                          color: Colors.orangeAccent,
                        )
                      : Icon(Icons.star_border)
                  : partialMessage.isStarredBySender
                      ? Icon(
                          Icons.star,
                          color: Colors.orangeAccent,
                        )
                      : Icon(Icons.star_border),
              onPressed: () async {
                var action = isRecipient
                    ? partialMessage.isStarredByRecipient ? "unstar" : "star"
                    : partialMessage.isStarredBySender ? "unstar" : "star";
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
            )),
      ],
    );
  }

  Widget getSubtitle() {
    return Text(
      partialMessage.subtitle,
      style: TextStyle(
        color: Colors.grey[600],
      ),
    );
  }
}
