//TODO: Display sender message

//TODO: allow user to type recevierName like we do in payment request
//TODO: allow user to input body
//TODO: allow user to click send button
//TODO: inputs {recipient, subject, body, submitButton }

import 'dart:io';

import 'package:Slydo/models/message.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DetailedMessage extends StatefulWidget {
  var arguments;
  DetailedMessage({this.arguments});
  @override
  _DetailedMessageState createState() =>
      _DetailedMessageState(id: arguments['id']);
}

class _DetailedMessageState extends State<DetailedMessage> {
  String id;
  Message message;
  _DetailedMessageState({this.id});
  final _auth = AuthService();

  @override
  void initState() {
    message = _auth.getMessage();
    super.initState();
  }

  Widget showBackArrow() {
    if (Platform.isAndroid) {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            leading: showBackArrow(),
            automaticallyImplyLeading: Platform.isAndroid ? false : true,
            title: Center(child: Text("Message")),
            backgroundColor: darkBlue()),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                displayMessageInfo(),
                SizedBox(height: 10),
                displayReplayButton(),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget displaySubject() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
            text: message.subject,
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  Widget displaySenderInfo() {
    return Container(
      height: 50,
      width: double.infinity,
      child: ListTile(
//        contentPadding: EdgeInsets.symmetric(horizontal: 15),
        leading: getLeading(),
        title: getSender(),
        subtitle: getDate(),
        trailing: Container(
          width: 100,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[getArchivedButton(), getIsStarredButton()],
          ),
        ),
      ),
    );
  }

  getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: message.senderAvtar,
        height: 40,
        width: 40,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => message.senderAvtar == ""
            ? Icon(Icons.person)
            : CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
      ),
    );
  }

  getSender() {
    return Text(
      message.sender,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  getArchivedButton() {
    return IconButton(
      icon: message.isArchived
          ? Icon(
              Icons.archive,
            )
          : Icon(Icons.unarchive),
      onPressed: () {
        setState(() {
          // TODO : to call _auth.updateMessage with action: archived / unArchived
          message.isArchived = message.isArchived ? false : true;
        });
      },
    );
  }

  getIsStarredButton() {
    return IconButton(
      icon: message.isStarred
          ? Icon(
              Icons.star,
              color: Colors.orangeAccent,
            )
          : Icon(Icons.star_border),
      onPressed: () {
        setState(() {
          // TODO : to call _auth.updateMessage with action: Starred / unStarred
          message.isStarred = message.isStarred ? false : true;
        });
      },
    );
  }

  getDate() {
    return Text(
      message.timeStamp,
      style: TextStyle(color: Colors.grey, fontSize: 14),
    );
  }

  displayMessageInfo() {
    return Card(
      child: Column(
        children: <Widget>[
          displaySubject(),
          displaySenderInfo(),
          displayBodyOfMessage(),
        ],
      ),
    );
  }

  displayBodyOfMessage() {
    return Padding(
      padding: const EdgeInsets.all(35.0),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          text: message.body,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }

  displayReplayButton() {
    return MaterialButton(
      minWidth: double.infinity,
      elevation: 4.0,
      textColor: Colors.white,
      color: darkBlue(),
      height: 50,
      child: Text("Replay"),
      onPressed: () {},
    );
  }
}
