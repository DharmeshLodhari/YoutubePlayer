import 'package:Slydo/models/message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  final PartialMessage partialMessage;
  MessageTile({this.partialMessage});

  @override
  _MessageTileState createState() =>
      _MessageTileState(partialMessage: partialMessage);
}

class _MessageTileState extends State<MessageTile> {
  PartialMessage partialMessage;
  _MessageTileState({this.partialMessage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
        child: Column(
          children: <Widget>[
            ListTile(
                leading: getLeading(),
                title: getTitle(),
                trailing: getTrailing(),
                subtitle: getSubtitle()),
          ],
        ),
      ),
    );
  }

  Widget getLeading() {
    return CachedNetworkImage(
      imageUrl: partialMessage.senderAvtar,
      height: 45,
      width: 45,
      colorBlendMode: BlendMode.darken,
      fit: BoxFit.fitWidth,
      filterQuality: FilterQuality.high,
      placeholder: (context, url) =>
          partialMessage.senderAvtar == "assets/images/slydo.png"
              ? Icon(
                  Icons.email,
                  size: 45,
                  color: Colors.black,
                )
              : CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
    );
  }

  Widget getTitle() {
    return Text(
      partialMessage.subject,
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getTrailing() {
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
            icon: partialMessage.isStarred
                ? Icon(
                    Icons.star,
                    color: Colors.orangeAccent,
                  )
                : Icon(
                    Icons.star_border,
                  ),
            onPressed: () {
              setState(() {
                partialMessage.isStarred =
                    partialMessage.isStarred ? false : true;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget getSubtitle() {
    return Text(
      partialMessage.subtitle,
      style: TextStyle(
          color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 15),
    );
  }
}
